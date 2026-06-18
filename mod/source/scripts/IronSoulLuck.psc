Scriptname IronSoulLuck extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()
; HasPersistenceRuntime()
; LogLuck()

; --- Luck Runtime ---
; --------------------
; ResetTransientState()
; GetCacheSnapshot()
; IsRuntimeAvailable()
; GetMaxForTier()
; GetCurrentMax()
; RefreshRegenState()
; IsActiveGameplayAlarmToken()
; HandleActiveGameplayAlarm()
; RollOutcomeNow()
; PlayRollPresentation()
; PerformRoll()
; JournalLogOutcome()
; AllowThresholdNotifications()
; SyncNotifiedTierToCurrent()
; MaybeNotifyThreshold()

; --- Luck Cache & Persistence ---
; --------------------------------
; EnsureLoaded()
; MarkDirty()
; PersistIfDue()
; CancelRegenAlarm()
; ArmRegenAlarm()
; ForcePersistNow()
; FlushDirtyCache()
; GetValue()
; SetValue()
; ResetValue()
; RemoveTrackedData()

; --- Death Coupling ---
; ----------------------
; ConsumeDeathFrontDelay()
; ConsumeNextDeathJournalSuppression()
; ConsumePendingFailureJournal()

; --- Luck Math Helpers ---
; -------------------------
; GetValueFromPlayedSeconds()
; PercentThresholdCeil()
; ComputeLuckRollD20()
; LuckTier()

; --- Luck Persistence Helpers ---
; -------------------------------
; DecodePlayed()
; EncodePlayed()


; --- Wired Dependencies & Runtime State ---
; ==========================================

IronSoulController Property Controller Auto

String Property luckLastSec = "IS_7314" AutoReadOnly ; Luck: last active-time second anchor
String Property luckPlayedToken = "IS_7315" AutoReadOnly ; Luck: played seconds
String Property luckNotifiedTier = "IS_7316" AutoReadOnly ; Luck: last notified threshold tier

Int Property LUCK_REGEN_SECONDS = 3600 AutoReadOnly ; Luck 0->maxLuck duration (60 minutes)
Int _luckPersistGateSeconds = 60

Bool _suppressLuckNotify = True

String _luckGuid = ""
Int _luckLastSec = 0
Int _luckPlayedSec = 0
Int _luckNextPersistAt = 0
Int _luckAlarmToken = 0
Bool _luckLoaded = False
Bool _luckDirty = False
Bool _luckFreshState = False

Int _lastLuckRoll = 0
Int _lastLuckValue = 0
Bool _lastLuckRollValid = False
Bool _deathFrontDelayConsumed = False
Bool _suppressNextDeathJournal = False
Bool _pendingLuckFailureJournal = False
Int _pendingLuckFailureRoll = 0
Int _pendingLuckFailureLuck = 0


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Persistence || !Controller.Respawn
        return False
    endif
    if !Controller.Death || !Controller.SFX
        return False
    endif
    return True
EndFunction

Bool Function HasPersistenceRuntime()
    if !Controller
        return False
    endif
    if !Controller.Persistence
        return False
    endif
    return True
EndFunction

Function LogLuck(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("Luck", level, msg, suppressNotify)
        return
    endif

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [Luck] " + msg)
EndFunction


; --- Luck Runtime ---
; ====================

Function ResetTransientState()
    CancelRegenAlarm("reset")
    _suppressLuckNotify = True

    _luckGuid = ""
    _luckLastSec = 0
    _luckPlayedSec = 0
    _luckNextPersistAt = 0
    _luckAlarmToken = 0
    _luckLoaded = False
    _luckDirty = False
    _luckFreshState = False

    _lastLuckRoll = 0
    _lastLuckValue = 0
    _lastLuckRollValid = False
    _deathFrontDelayConsumed = False
    _suppressNextDeathJournal = False
    _pendingLuckFailureJournal = False
    _pendingLuckFailureRoll = 0
    _pendingLuckFailureLuck = 0
EndFunction

String Function GetCacheSnapshot()
    return "Loaded=" + _luckLoaded \
        + " Dirty=" + _luckDirty \
        + " LastSec=" + _luckLastSec \
        + " PlayedSec=" + _luckPlayedSec \
        + " NextPersistAt=" + _luckNextPersistAt \
        + " Alarm=" + _luckAlarmToken
EndFunction

Bool Function IsRuntimeAvailable()
    if !HasCoreRuntime()
        return False
    endif

    return Controller.Respawn.IsRuntimeAvailable()
EndFunction

Int Function GetMaxForTier(Int tier)
    Int luckLevel = 5
    if Controller && Controller.Config
        luckLevel = Controller.Config.GetLuckLevel()
    endif
    return IronSoulTiers.GetMaxLuckForTierAtLevel(tier, luckLevel)
EndFunction

Int Function GetCurrentMax(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return 100
    endif

    Int tierNow = 1
    if Controller.Tiers
        tierNow = Controller.Tiers.GetCurrentTier(player, guid)
    endif
    if tierNow == 0
        Int deathsNow = Controller.Death.GetCurrentDeathCount(player, guid)
        Int defiantBaseTier = 1
        if Controller.Tiers
            defiantBaseTier = Controller.Tiers.GetDefiantTrackedTier(player, guid)
        endif
        Int maxLuck = GetMaxForTier(defiantBaseTier)
        Int ironMaxLives = 10
        if Controller.Tiers
            ironMaxLives = Controller.Tiers.IRON_SOUL_MAX_LIVES
        endif
        Int excessDeaths = deathsNow - ironMaxLives
        if excessDeaths > 0
            maxLuck -= excessDeaths
        endif
        Int defiantMaxLuck = GetMaxForTier(0)
        if maxLuck > defiantMaxLuck
            maxLuck = defiantMaxLuck
        endif
        if maxLuck < 0
            maxLuck = 0
        endif
        return maxLuck
    endif

    return GetMaxForTier(tierNow)
EndFunction

Function RefreshRegenState(Actor player, String guid, String reason = "luck-refresh", Bool rebaselineClock = False)
    if !HasCoreRuntime() || !player || guid == "" || !IsRuntimeAvailable()
        return
    endif

    Int nowSec = IronSoulNative.GetActiveGameplaySeconds()
    EnsureLoaded(player, guid, nowSec)

    Int lastSec = _luckLastSec
    Int played = _luckPlayedSec

    ; A fresh character starts at tier max.
    if _luckFreshState
        Int initialMaxLuck = GetCurrentMax(player, guid)
        played = LUCK_REGEN_SECONDS
        _luckPlayedSec = played
        _luckLastSec = nowSec
        _luckFreshState = False
        MarkDirty()
        Controller.Persistence.SetGuidInt(player, guid, luckNotifiedTier, 4, True)
        PersistIfDue(player, guid, nowSec, True)
        if Controller.Globals
            Controller.Globals.SyncLuckValues(initialMaxLuck, initialMaxLuck)
        endif
        ArmRegenAlarm(player, guid, nowSec, reason + "-fresh")
        return
    endif

    if rebaselineClock
        _luckLastSec = nowSec
        lastSec = nowSec
        MarkDirty()
    endif

    Int maxLuck = GetCurrentMax(player, guid)
    Int previousLuck = GetValueFromPlayedSeconds(played, maxLuck)

    Int delta = nowSec - lastSec
    if delta < 0
        delta = 0
    endif

    if delta > 0
        played += delta
        if played > LUCK_REGEN_SECONDS
            played = LUCK_REGEN_SECONDS
        endif
        _luckPlayedSec = played
        _luckLastSec = nowSec
        MarkDirty()
    elseif nowSec != lastSec
        _luckLastSec = nowSec
        MarkDirty()
    endif

    PersistIfDue(player, guid, nowSec, rebaselineClock)

    Int luckNow = GetValueFromPlayedSeconds(played, maxLuck)
    MaybeNotifyThreshold(player, guid, luckNow, maxLuck)
    if Controller.Globals && luckNow != previousLuck
        Controller.Globals.SyncLuckValues(luckNow, maxLuck)
    endif
    if luckNow < maxLuck
        LogLuck(IronSoulConfig.LOG_DBG(), "RefreshLuckRegen: Luck=" + luckNow + "/" + maxLuck + " (" + played + "/" + LUCK_REGEN_SECONDS + "s) reason=" + reason, True)
    endif
    ArmRegenAlarm(player, guid, nowSec, reason)
EndFunction

Bool Function IsActiveGameplayAlarmToken(Int token)
    return token > 0 && token == _luckAlarmToken
EndFunction

Function HandleActiveGameplayAlarm(Actor player, String guid, Int token)
    if !IsActiveGameplayAlarmToken(token)
        LogLuck(IronSoulConfig.LOG_DBG(), "HandleActiveGameplayAlarm: ignored stale token=" + token + " current=" + _luckAlarmToken, True)
        return
    endif

    _luckAlarmToken = 0
    RefreshRegenState(player, guid, "luck-active-alarm")
EndFunction

Bool Function PerformRoll(Actor player, String guid)
    ; Returns True when Luck saves the player from death.
    Bool success = RollOutcomeNow(player, guid)
    PlayRollPresentation(player, success)
    return success
EndFunction

Bool Function RollOutcomeNow(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        LogLuck(IronSoulConfig.LOG_ERR(), "PerformLuckRoll: Invalid args (player None or GUID empty) -> FAIL")
        return False
    endif

    _deathFrontDelayConsumed = False
    _lastLuckRollValid = False

    if !IsRuntimeAvailable()
        LogLuck(IronSoulConfig.LOG_INFO(), "PerformLuckRoll: Inactive (Luck tied to Respawn; Respawn disabled/unavailable) -> FAIL")
        return False
    endif

    RefreshRegenState(player, guid, "luck-roll")

    Int luck = GetValue(player, guid)
    if luck < 0
        luck = 0
    elseif luck > 100
        luck = 100
    endif

    Int roll100 = Utility.RandomInt(1, 100)
    Bool success = (roll100 <= luck)

    if !success
        ResetValue(player, guid)
    endif

    _lastLuckRollValid = True
    _lastLuckRoll = roll100
    _lastLuckValue = luck

    String outcome = "Death"
    if success
        outcome = "Survival/Respawn"
    endif
    LogLuck(IronSoulConfig.LOG_INFO(), "PerformLuckRoll: LuckRoll: roll100=" + roll100 + " vs luck=" + luck + " -> " + outcome)

    if !success
        _deathFrontDelayConsumed = True
    endif

    return success
EndFunction

Function PlayRollPresentation(Actor player, Bool success)
    if !HasCoreRuntime() || !player || !_lastLuckRollValid
        return
    endif

    Float presentationStartedAt = Utility.GetCurrentRealTime()
    ;Utility.Wait(0.5)

    if !Controller.Config.IsLuckRollMenuEnabled()
        LogLuck(IronSoulConfig.LOG_INFO(), "PlayRollPresentation: LuckRollMenu disabled success=" + success + " roll100=" + _lastLuckRoll + " luck=" + _lastLuckValue, True)
        return
    endif

    Int roll20 = ComputeLuckRollD20(_lastLuckValue, _lastLuckRoll)

    String rollMenu = "luck_roll_" + roll20
    Sound resultSFX = Controller.SFX.SFXLuckFailure
    if success
        resultSFX = Controller.SFX.SFXLuckSuccess
    endif

    UI.CloseCustomMenu()
    Int cursorToken = IronSoulNative.BeginCursorSuppress()

    Controller.SFX.Play(resultSFX, player)
    Utility.Wait(0.05)

    UI.OpenCustomMenu(rollMenu, 0)
    IronSoulNative.RefreshCursorSuppress()
    LogLuck(IronSoulConfig.LOG_INFO(), "PlayRollPresentation: Menu opened success=" + success + " menu=" + rollMenu + " roll100=" + _lastLuckRoll + " luck=" + _lastLuckValue + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - presentationStartedAt), True)
    Utility.WaitMenuMode((46.0 / 18.0) + 1.0)
    UI.CloseCustomMenu()
    LogLuck(IronSoulConfig.LOG_INFO(), "PlayRollPresentation: Menu close requested menu=" + rollMenu + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - presentationStartedAt), True)
    IronSoulNative.EndCursorSuppress(cursorToken)
    LogLuck(IronSoulConfig.LOG_INFO(), "PlayRollPresentation: Complete success=" + success + " menu=" + rollMenu + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - presentationStartedAt), True)
EndFunction

Function JournalLogOutcome(Bool survived, Actor player, String guid, Bool deferFailure = False)
    if !HasCoreRuntime() || !Controller.Journal || !Controller.Config.IsCharacterJournalEnabled()
        return
    endif
    if !player || guid == "" || !_lastLuckRollValid
        return
    endif

    Int roll = _lastLuckRoll
    Int luck = _lastLuckValue

    _lastLuckRollValid = False

    if survived
        Int maxLuck = GetCurrentMax(player, guid)
        Controller.Journal.LogLuckOutcomeForGuid(player, guid, luck, roll, maxLuck)
        return
    endif

    if deferFailure
        _pendingLuckFailureJournal = True
        _pendingLuckFailureRoll = roll
        _pendingLuckFailureLuck = luck
        _suppressNextDeathJournal = True
        LogLuck(IronSoulConfig.LOG_INFO(), "JournalLogOutcome: Staged luck failure journal roll=" + roll + " luck=" + luck, True)
        return
    endif

    Int deathsPred = Controller.Death.GetCurrentDeathCount(player, guid) + 1
    Int cap = 10
    if Controller.Tiers
        cap = Controller.Tiers.GetEffectiveMaxLives(player, guid)
    endif
    Controller.Journal.LogDefeatLuckOutcomeForGuid(player, guid, deathsPred, cap, roll, luck)
    _suppressNextDeathJournal = True
EndFunction

Function AllowThresholdNotifications()
    _suppressLuckNotify = False
EndFunction

Function SyncNotifiedTierToCurrent(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    Int maxLuck = GetCurrentMax(player, guid)
    Int luckNow = GetValue(player, guid)
    Int tierNow = LuckTier(luckNow, maxLuck)
    Controller.Persistence.SetGuidInt(player, guid, luckNotifiedTier, tierNow, True)
EndFunction

Function MaybeNotifyThreshold(Actor player, String guid, Int luck, Int maxLuck = -1)
    if !HasCoreRuntime() || _suppressLuckNotify
        return
    endif
    if !player || guid == "" || !IsRuntimeAvailable()
        return
    endif
    if !Controller.Config || !Controller.Config.IsLuckReminderNotificationEnabled()
        return
    endif

    if maxLuck <= 0
        maxLuck = GetCurrentMax(player, guid)
    endif
    if maxLuck <= 0
        return
    endif

    Int tierNow = LuckTier(luck, maxLuck)
    if tierNow <= 0
        return
    endif

    Int tierPrev = Controller.Persistence.GetGuidInt(player, guid, luckNotifiedTier, 0)
    if tierNow <= tierPrev
        return
    endif

    Controller.Persistence.SetGuidInt(player, guid, luckNotifiedTier, tierNow, True)
    LogLuck(IronSoulConfig.LOG_INFO(), "MaybeNotifyLuckThreshold: Luck threshold reached: tier " + tierPrev + " -> " + tierNow + " (luck=" + luck + "/" + maxLuck + ")", True)
    Debug.Notification(IronSoulUI.ResolveLuckThresholdNotification(tierNow))
EndFunction


; --- Luck Cache & Persistence ---
; ================================

Function EnsureLoaded(Actor player, String guid, Int nowSec)
    ; Cached timing state preserves delta math while datastore writes are gated.
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif
    if !_luckLoaded || _luckGuid != guid
        String lastKey = IronSoulPersistence.GetKey(luckLastSec, guid)
        String playedKey = IronSoulPersistence.GetKey(luckPlayedToken, guid)
        Bool hasLastKey = IronSoulNative.DataHasKey(lastKey)
        Bool hasPlayedKey = IronSoulNative.DataHasKey(playedKey)

        _luckGuid = guid
        _luckLastSec = Controller.Persistence.GetGuidInt(player, guid, luckLastSec, 0)
        _luckPlayedSec = DecodePlayed(Controller.Persistence.GetGuidInt(player, guid, luckPlayedToken, 0))
        _luckDirty = False
        if _luckPlayedSec < 0
            _luckPlayedSec = 0
        elseif _luckPlayedSec > LUCK_REGEN_SECONDS
            _luckPlayedSec = LUCK_REGEN_SECONDS
        endif
        _luckFreshState = !hasLastKey && !hasPlayedKey
        if _luckLastSec < 0 || _luckLastSec > nowSec
            _luckLastSec = nowSec
            MarkDirty()
        endif
        _luckNextPersistAt = nowSec + _luckPersistGateSeconds
        _luckLoaded = True
        LogLuck(IronSoulConfig.LOG_DBG(), "LuckEnsureLoaded: Loaded state for GUID=" + guid + " (lastSec=" + _luckLastSec + ", playedSec=" + _luckPlayedSec + ", fresh=" + _luckFreshState + ")")
    endif
EndFunction

Function MarkDirty()
    _luckDirty = True
EndFunction

Function PersistIfDue(Actor player, String guid, Int nowSec, Bool force)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif
    if !_luckLoaded || _luckGuid != guid
        return
    endif
    if !_luckDirty && !force
        return
    endif
    if !force && nowSec < _luckNextPersistAt
        return
    endif

    Controller.Persistence.SetGuidInt(player, guid, luckPlayedToken, _luckPlayedSec, True)
    Controller.Persistence.SetGuidInt(player, guid, luckLastSec, _luckLastSec, True)

    _luckDirty = False
    _luckNextPersistAt = nowSec + _luckPersistGateSeconds
EndFunction

Function CancelRegenAlarm(String reason = "luck-cancel")
    if _luckAlarmToken > 0
        IronSoulNative.CancelActiveGameplayAlarm(_luckAlarmToken, reason)
        _luckAlarmToken = 0
    endif
EndFunction

Bool Function ArmRegenAlarm(Actor player, String guid, Int nowSec, String reason = "luck-arm")
    CancelRegenAlarm("luck-rearm")
    if !HasCoreRuntime() || !player || guid == "" || !_luckLoaded || _luckGuid != guid
        return False
    endif
    if !IsRuntimeAvailable()
        return False
    endif

    Int maxLuck = GetCurrentMax(player, guid)
    if maxLuck <= 0 || _luckPlayedSec >= LUCK_REGEN_SECONDS
        return False
    endif

    Int luckNow = GetValueFromPlayedSeconds(_luckPlayedSec, maxLuck)
    Int nextLuck = luckNow + 1
    if nextLuck > maxLuck
        nextLuck = maxLuck
    endif

    Int nextPlayed = ((nextLuck * LUCK_REGEN_SECONDS) + maxLuck - 1) / maxLuck
    if nextPlayed <= _luckPlayedSec
        nextPlayed = _luckPlayedSec + 1
    endif
    if nextPlayed > LUCK_REGEN_SECONDS
        nextPlayed = LUCK_REGEN_SECONDS
    endif

    Int targetSecond = nowSec + (nextPlayed - _luckPlayedSec)
    if _luckDirty
        if _luckNextPersistAt <= nowSec
            targetSecond = nowSec
        elseif _luckNextPersistAt < targetSecond
            targetSecond = _luckNextPersistAt
        endif
    endif

    Int token = IronSoulNative.QueueActiveGameplayAlarm(targetSecond, "luck-active-alarm")
    if token <= 0
        LogLuck(IronSoulConfig.LOG_DBG(), "ArmRegenAlarm: native alarm unavailable reason=" + reason, True)
        return False
    endif

    _luckAlarmToken = token
    return True
EndFunction

Function ForcePersistNow(Actor player, String guid)
    Int nowSec = IronSoulNative.GetActiveGameplaySeconds()
    EnsureLoaded(player, guid, nowSec)
    PersistIfDue(player, guid, nowSec, True)
    ArmRegenAlarm(player, guid, nowSec, "force-persist")
    IronSoulNative.DataFlushIfDirty()
EndFunction

Function FlushDirtyCache()
    if !HasCoreRuntime() || !_luckLoaded || !_luckDirty || _luckGuid == ""
        return
    endif

    Actor player = Game.GetPlayer()
    if player
        Int nowSec = IronSoulNative.GetActiveGameplaySeconds()
        PersistIfDue(player, _luckGuid, nowSec, True)
        ArmRegenAlarm(player, _luckGuid, nowSec, "flush-dirty")
    endif
EndFunction

Int Function GetValue(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return 100
    endif

    Int maxLuck = GetCurrentMax(player, guid)
    if maxLuck <= 0
        return 0
    endif
    if !IsRuntimeAvailable()
        return maxLuck
    endif

    Int playedSec = 0
    if _luckLoaded && _luckGuid == guid
        playedSec = _luckPlayedSec
    else
        playedSec = DecodePlayed(Controller.Persistence.GetGuidInt(player, guid, luckPlayedToken, 0))
    endif

    if playedSec < 0
        playedSec = 0
    elseif playedSec > LUCK_REGEN_SECONDS
        playedSec = LUCK_REGEN_SECONDS
    endif

    return GetValueFromPlayedSeconds(playedSec, maxLuck)
EndFunction

Int Function SetValue(Actor player, String guid, Int targetLuck)
    if !HasCoreRuntime() || !player || guid == ""
        return -1
    endif

    Int nowSec = IronSoulNative.GetActiveGameplaySeconds()
    EnsureLoaded(player, guid, nowSec)

    Int maxLuck = GetCurrentMax(player, guid)
    Int clampedLuck = targetLuck
    if clampedLuck < 0
        clampedLuck = 0
    elseif clampedLuck > maxLuck
        clampedLuck = maxLuck
    endif

    Int playedSec = 0
    if maxLuck > 0 && clampedLuck > 0
        playedSec = ((clampedLuck * LUCK_REGEN_SECONDS) + maxLuck - 1) / maxLuck
    endif
    if playedSec < 0
        playedSec = 0
    elseif playedSec > LUCK_REGEN_SECONDS
        playedSec = LUCK_REGEN_SECONDS
    endif

    _luckGuid = guid
    _luckLastSec = nowSec
    _luckPlayedSec = EncodePlayed(nowSec, playedSec)
    _luckLoaded = True
    _luckDirty = True
    _luckFreshState = False
    _luckNextPersistAt = nowSec + _luckPersistGateSeconds

    PersistIfDue(player, guid, nowSec, True)
    ArmRegenAlarm(player, guid, nowSec, "set-value")

    Int tierNow = LuckTier(clampedLuck, maxLuck)
    Controller.Persistence.SetGuidInt(player, guid, luckNotifiedTier, tierNow, True)
    if Controller.Globals
        Controller.Globals.SyncLuckValues(clampedLuck, maxLuck)
    endif

    return clampedLuck
EndFunction

Function ResetValue(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == "" || !IsRuntimeAvailable()
        return
    endif

    Int nowSec = IronSoulNative.GetActiveGameplaySeconds()
    _luckGuid = guid
    _luckLastSec = nowSec
    _luckPlayedSec = EncodePlayed(nowSec, 0)
    _luckLoaded = True
    _luckDirty = True
    _luckFreshState = False
    _luckNextPersistAt = nowSec + _luckPersistGateSeconds

    PersistIfDue(player, guid, nowSec, True)
    ArmRegenAlarm(player, guid, nowSec, "reset-value")
    LogLuck(IronSoulConfig.LOG_INFO(), "ResetLuck: Luck set to 0; regen timer armed (played=0/" + LUCK_REGEN_SECONDS + "s)")
    Controller.Persistence.SetGuidInt(player, guid, luckNotifiedTier, 0, True)
    if Controller.Globals
        Controller.Globals.SyncLuckValues(0, GetCurrentMax(player, guid))
    endif
EndFunction

Function RemoveTrackedData(Actor player, String guid, Bool deleteMainData = True, Bool unsetCosave = False)
    if !HasPersistenceRuntime() || guid == ""
        return
    endif

    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, luckLastSec, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, luckPlayedToken, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, luckNotifiedTier, deleteMainData, unsetCosave)
EndFunction


; --- Death Coupling ---
; ======================

Bool Function ConsumeDeathFrontDelay()
    Bool consumed = _deathFrontDelayConsumed
    _deathFrontDelayConsumed = False
    return consumed
EndFunction

Bool Function ConsumeNextDeathJournalSuppression()
    Bool suppress = _suppressNextDeathJournal
    _suppressNextDeathJournal = False
    return suppress
EndFunction

Bool Function ConsumePendingFailureJournal(Actor player, String guid, Int deathsNow, Int cap)
    if !_pendingLuckFailureJournal
        return False
    endif

    Int roll = _pendingLuckFailureRoll
    Int luck = _pendingLuckFailureLuck
    _pendingLuckFailureJournal = False
    _pendingLuckFailureRoll = 0
    _pendingLuckFailureLuck = 0

    if !HasCoreRuntime() || !Controller.Journal || !Controller.Config.IsCharacterJournalEnabled()
        return False
    endif
    if !player || guid == ""
        return False
    endif

    if cap <= 0
        cap = 10
    endif

    Controller.Journal.LogDefeatLuckOutcomeForGuid(player, guid, deathsNow, cap, roll, luck)
    LogLuck(IronSoulConfig.LOG_INFO(), "ConsumePendingFailureJournal: Logged luck failure journal deaths=" + deathsNow + " cap=" + cap + " roll=" + roll + " luck=" + luck, True)
    return True
EndFunction


; --- Luck Math Helpers ---
; =========================

Int Function GetValueFromPlayedSeconds(Int playedSec, Int maxLuck)
    if maxLuck <= 0
        return 0
    endif
    if playedSec < 0
        return maxLuck
    endif
    if playedSec == 0
        return 0
    endif
    if LUCK_REGEN_SECONDS <= 0
        return maxLuck
    endif

    Int luck = (playedSec * maxLuck) / LUCK_REGEN_SECONDS
    if luck < 0
        luck = 0
    elseif luck > maxLuck
        luck = maxLuck
    endif
    return luck
EndFunction

Int Function PercentThresholdCeil(Int maxLuck, Int pct) Global
    if maxLuck <= 0
        return 0
    endif
    if pct <= 0
        return 0
    elseif pct >= 100
        return maxLuck
    endif
    Int scaled = maxLuck * pct
    return (scaled + 99) / 100
EndFunction

Int Function ComputeLuckRollD20(Int luck, Int roll100) Global
    if luck < 0
        luck = 0
    elseif luck > 100
        luck = 100
    endif

    if roll100 < 1
        roll100 = 1
    elseif roll100 > 100
        roll100 = 100
    endif

    Int delta = luck - roll100
    Int roll20 = ((delta + 100) / 10) + 1
    if roll20 < 1
        roll20 = 1
    elseif roll20 > 20
        roll20 = 20
    endif
    return roll20
EndFunction

Int Function LuckTier(Int luck, Int maxLuck) Global
    if maxLuck <= 0
        return 0
    endif
    if luck < 0
        luck = 0
    elseif luck > maxLuck
        luck = maxLuck
    endif
    if luck >= maxLuck
        return 4
    elseif luck >= PercentThresholdCeil(maxLuck, 75)
        return 3
    elseif luck >= PercentThresholdCeil(maxLuck, 50)
        return 2
    elseif luck >= PercentThresholdCeil(maxLuck, 25)
        return 1
    endif
    return 0
EndFunction


; --- Luck Persistence Helpers ---
; ================================

Int Function DecodePlayed(Int token) Global
    if token < 0
        return 0
    endif
    if token > 3600
        return 3600
    endif
    return token
EndFunction

Int Function EncodePlayed(Int nowSec, Int playedSec) Global
    if playedSec < 0
        playedSec = 0

    elseif playedSec > 3600
        playedSec = 3600
    endif
    return playedSec
EndFunction
