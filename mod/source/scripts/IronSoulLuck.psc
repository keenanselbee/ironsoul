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
; TickRegen()
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

; --- Luck Math Helpers ---
; -------------------------
; GetValueFromPlayedSeconds()
; PercentThresholdCeil()
; ComputeLuckRollD20()
; LuckTier()

; --- Luck Persistence Encoding ---
; ---------------------------------
; DecodePlayed()
; EncodePlayed()


; --- Wired Dependencies & Runtime State ---
; ==========================================

IronSoulController Property Controller Auto

String Property luckLastSec = "IS_7314" AutoReadOnly ; Luck: last real-time second anchor
String Property luckPlayedToken = "IS_7315" AutoReadOnly ; Luck: played-seconds token (encoded)
String Property luckNotifiedTier = "IS_7316" AutoReadOnly ; Luck: last notified threshold tier

Int Property LUCK_REGEN_SECONDS = 3600 AutoReadOnly ; Luck 0->maxLuck duration (60 minutes)
Int _luckPersistGateSeconds = 60

Float _luckTickAt = 0.0
Bool _suppressLuckNotify = True

String _luckGuid = ""
Int _luckLastSec = 0
Int _luckPlayedTok = 0
Int _luckNextPersistAt = 0
Bool _luckLoaded = False
Bool _luckDirty = False

Int _lastLuckRoll = 0
Int _lastLuckValue = 0
Bool _lastLuckRollValid = False
Bool _deathFrontDelayConsumed = False
Bool _suppressNextDeathJournal = False


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

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [" + levelText + "] [Luck] " + msg)
EndFunction


; --- Luck Runtime ---
; ====================

Function ResetTransientState()
    _luckTickAt = 0.0
    _suppressLuckNotify = True

    _luckGuid = ""
    _luckLastSec = 0
    _luckPlayedTok = 0
    _luckNextPersistAt = 0
    _luckLoaded = False
    _luckDirty = False

    _lastLuckRoll = 0
    _lastLuckValue = 0
    _lastLuckRollValid = False
    _deathFrontDelayConsumed = False
    _suppressNextDeathJournal = False
EndFunction

String Function GetCacheSnapshot()
    return "Loaded=" + _luckLoaded \
        + " Dirty=" + _luckDirty \
        + " LastSec=" + _luckLastSec \
        + " NextPersistAt=" + _luckNextPersistAt
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

Function TickRegen(Actor player, String guid)
    ; Uses real-time seconds but pauses while menus are open.
    if !HasCoreRuntime() || !player || guid == "" || !IsRuntimeAvailable()
        return
    endif

    Float nowRT = Utility.GetCurrentRealTime()
    if nowRT < _luckTickAt
        _luckTickAt = nowRT
    endif
    if (nowRT - _luckTickAt) < 1.0
        return
    endif
    _luckTickAt = nowRT

    Int nowSec = nowRT as Int
    EnsureLoaded(player, guid, nowSec)

    Int lastSec = _luckLastSec
    Int playedTok = _luckPlayedTok
    Int played = DecodePlayed(playedTok)

    ; A fresh character starts at tier max.
    if lastSec <= 0 || playedTok <= 0
        Int initialMaxLuck = GetCurrentMax(player, guid)
        played = LUCK_REGEN_SECONDS
        _luckPlayedTok = EncodePlayed(nowSec, played)
        _luckLastSec = nowSec
        MarkDirty()
        Controller.Persistence.SetGuidInt(player, guid, luckNotifiedTier, 4, True)
        PersistIfDue(player, guid, nowSec, True)
        if Controller.Globals
            Controller.Globals.SyncLuckValues(initialMaxLuck, initialMaxLuck)
        endif
        return
    endif

    if Utility.IsInMenuMode()
        if nowSec != lastSec
            _luckLastSec = nowSec
            MarkDirty()
        endif
        PersistIfDue(player, guid, nowSec, False)
        return
    endif

    Int maxLuck = GetCurrentMax(player, guid)
    Int previousLuck = GetValueFromPlayedSeconds(played, maxLuck)

    Int delta = nowSec - lastSec
    if delta < 0
        delta = 0
    elseif delta > 60
        delta = 60
    endif

    if delta > 0
        played += delta
        if played > LUCK_REGEN_SECONDS
            played = LUCK_REGEN_SECONDS
        endif
        _luckPlayedTok = EncodePlayed(nowSec, played)
        _luckLastSec = nowSec
        MarkDirty()
    elseif nowSec != lastSec
        _luckLastSec = nowSec
        MarkDirty()
    endif

    PersistIfDue(player, guid, nowSec, False)

    Int luckNow = GetValueFromPlayedSeconds(played, maxLuck)
    MaybeNotifyThreshold(player, guid, luckNow, maxLuck)
    if Controller.Globals && luckNow != previousLuck
        Controller.Globals.SyncLuckValues(luckNow, maxLuck)
    endif
    if luckNow < maxLuck
        LogLuck(IronSoulConfig.LOG_DBG(), "TickLuckRegen: Luck=" + luckNow + "/" + maxLuck + " (" + played + "/" + LUCK_REGEN_SECONDS + "s)", True)
    endif
EndFunction

Bool Function PerformRoll(Actor player, String guid)
    ; Returns True when Luck saves the player from death.
    if !HasCoreRuntime() || !player || guid == ""
        LogLuck(IronSoulConfig.LOG_ERR(), "PerformLuckRoll: Invalid args (player None or GUID empty) -> FAIL")
        return False
    endif

    _deathFrontDelayConsumed = False

    if !IsRuntimeAvailable()
        LogLuck(IronSoulConfig.LOG_INFO(), "PerformLuckRoll: Inactive (Luck tied to Respawn; Respawn disabled/unavailable) -> FAIL")
        return False
    endif

    Utility.Wait(0.5)

    Int nowSec = Utility.GetCurrentRealTime() as Int
    EnsureLoaded(player, guid, nowSec)

    Int luck = GetValue(player, guid)
    if luck < 0
        luck = 0
    elseif luck > 100
        luck = 100
    endif

    Int roll100 = Utility.RandomInt(1, 100)
    Bool success = (roll100 <= luck)
    Int roll20 = ComputeLuckRollD20(luck, roll100)

    if !success
        ResetValue(player, guid)
        ForcePersistNow(player, guid)
    endif

    Int messageMode = 1
    if Controller.Config
        messageMode = Controller.Config.GetLuckRollMessageMode()
    endif

    if messageMode == 1
        String rollMenu = "luck_roll_" + roll20
        String resultMenu = "luck_defeat_" + roll20
        Sound resultSFX = Controller.SFX.SFXLuckFailure
        if roll20 >= 11
            resultMenu = "luck_survival_" + roll20
            resultSFX = Controller.SFX.SFXLuckSuccess
        endif

        UI.CloseCustomMenu()
        Int cursorToken = IronSoulNative.BeginCursorSuppress()
        Utility.Wait(0.05)

        Controller.SFX.Play(Controller.SFX.SFXLuckRoll, player)

        UI.OpenCustomMenu(rollMenu, 0)
        Utility.WaitMenuMode(2.5)

        Controller.SFX.Play(resultSFX, player)
        UI.CloseCustomMenu()

        UI.OpenCustomMenu(resultMenu, 0)
        Utility.WaitMenuMode(1.5)
        UI.CloseCustomMenu()
        IronSoulNative.EndCursorSuppress(cursorToken)

    elseif messageMode == 2
        String resultMenuOnly = "luck_defeat_" + roll20
        Sound resultSFXOnly = Controller.SFX.SFXLuckFailure
        if roll20 >= 11
            resultMenuOnly = "luck_survival_" + roll20
            resultSFXOnly = Controller.SFX.SFXLuckSuccess
        endif

        Int cursorTokenOnly = IronSoulNative.BeginCursorSuppress()
        Controller.SFX.Play(resultSFXOnly, player)
        UI.OpenCustomMenu(resultMenuOnly, 0)
        Utility.WaitMenuMode(1.0)
        UI.CloseCustomMenu()
        IronSoulNative.EndCursorSuppress(cursorTokenOnly)
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

Function JournalLogOutcome(Bool survived, Actor player, String guid)
    if !HasCoreRuntime() || !Controller.Journal || !Controller.Config.IsCharacterJournalEnabled()
        return
    endif
    if !player || guid == "" || !_lastLuckRollValid
        return
    endif

    Int roll = _lastLuckRoll
    Int luck = _lastLuckValue
    Int maxLuck = GetCurrentMax(player, guid)

    _lastLuckRollValid = False

    if survived
        Controller.Journal.LogEventForGuid(player, guid, IronSoulJournal.JournalLuckOutcomeText(luck, roll, maxLuck))
        return
    endif

    Int deathsPred = Controller.Death.GetCurrentDeathCount(player, guid) + 1
    Int cap = 10
    if Controller.Tiers
        cap = Controller.Tiers.GetEffectiveMaxLives(player, guid)
    endif
    Controller.Journal.LogEventForGuid(player, guid, IronSoulJournal.DefeatLuckOutcomeText(deathsPred, cap, roll, luck))
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
        _luckGuid = guid
        _luckLastSec = Controller.Persistence.GetGuidInt(player, guid, luckLastSec, 0)
        _luckPlayedTok = Controller.Persistence.GetGuidInt(player, guid, luckPlayedToken, 0)
        _luckNextPersistAt = nowSec + _luckPersistGateSeconds
        _luckLoaded = True
        _luckDirty = False
        LogLuck(IronSoulConfig.LOG_DBG(), "LuckEnsureLoaded: Loaded state for GUID=" + guid + " (lastSec=" + _luckLastSec + ", playedTok=" + _luckPlayedTok + ")")
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

    Controller.Persistence.SetGuidInt(player, guid, luckPlayedToken, _luckPlayedTok, True)
    Controller.Persistence.SetGuidInt(player, guid, luckLastSec, _luckLastSec, True)

    _luckDirty = False
    _luckNextPersistAt = nowSec + _luckPersistGateSeconds
EndFunction

Function ForcePersistNow(Actor player, String guid)
    Int nowSec = Utility.GetCurrentRealTime() as Int
    PersistIfDue(player, guid, nowSec, True)
    IronSoulNative.DataFlushIfDirty()
EndFunction

Function FlushDirtyCache()
    if !HasCoreRuntime() || !_luckLoaded || !_luckDirty || _luckGuid == ""
        return
    endif

    Actor player = Game.GetPlayer()
    if player
        Int nowSec = Utility.GetCurrentRealTime() as Int
        PersistIfDue(player, _luckGuid, nowSec, True)
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

    Int playedTok = 0
    if _luckLoaded && _luckGuid == guid
        playedTok = _luckPlayedTok
    else
        playedTok = Controller.Persistence.GetGuidInt(player, guid, luckPlayedToken, 0)
    endif

    if playedTok == 0
        return maxLuck
    endif

    Int playedSec = DecodePlayed(playedTok)
    return GetValueFromPlayedSeconds(playedSec, maxLuck)
EndFunction

Int Function SetValue(Actor player, String guid, Int targetLuck)
    if !HasCoreRuntime() || !player || guid == ""
        return -1
    endif

    Int nowSec = Utility.GetCurrentRealTime() as Int
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
    _luckPlayedTok = EncodePlayed(nowSec, playedSec)
    _luckLoaded = True
    _luckDirty = True
    _luckNextPersistAt = nowSec + _luckPersistGateSeconds

    PersistIfDue(player, guid, nowSec, True)

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

    Int nowSec = Utility.GetCurrentRealTime() as Int
    _luckGuid = guid
    _luckLastSec = nowSec
    _luckPlayedTok = EncodePlayed(nowSec, 0)
    _luckLoaded = True
    _luckDirty = True
    _luckNextPersistAt = nowSec + _luckPersistGateSeconds

    PersistIfDue(player, guid, nowSec, True)
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


; --- Luck Persistence Encoding ---
; =================================

Int Function DecodePlayed(Int token) Global
    if token < 8192
        return token
    endif
    return token - ((token / 8192) * 8192)
EndFunction

Int Function EncodePlayed(Int nowSec, Int playedSec) Global
    if playedSec < 0
        playedSec = 0

    elseif playedSec > 8191
        playedSec = 8191
    endif
    Int epochMod = 262144
    Int chunks = nowSec / epochMod
    Int trimmedNow = nowSec - (chunks * epochMod)
    return (trimmedNow * 8192) + playedSec
EndFunction
