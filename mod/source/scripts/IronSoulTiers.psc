Scriptname IronSoulTiers extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()
; HasPersistenceRuntime()
; CanWriteSharedProgression()
; LogTiers()
; LogTiersSnapshot()

; --- Component Runtime ---
; -------------------------
; ResetTransientState()
; SetPendingDragonSoulsRebaseline()
; RemoveTrackedData()
; Tick()
; Heartbeat()
; StartDragonSoulWatcher()
; StopDragonSoulWatcher()
; IsDragonSoulWatcherToken()
; IsDragonSoulWatcherCurrent()
; HandleDragonSoulWatcherUpdate()
; SyncDragonSoulsLive()
; RequiresFastPolling()
; LogSnapshot()

; --- Tier State ---
; ------------------
; GetCurrentTier()
; SetCurrentTier()
; SyncTierLuckState()
; SyncTierPresentationState()
; SyncTierDynamicAssets()
; SyncTierGlobalMirrors()
; GetDragonSoulsTotal()
; GetDragonSoulsTotalShared()
; SetDragonSoulsTotalFromConsole()
; IsManualTierOverrideActive()
; SetManualTierOverrideActive()
; GetHighestEligibleNormalTierForPlayer()
; ResolveSoulTierTarget()
; GetHighestEligibleSoulFeatTier()
; GetResetTargetTier()
; GetLoadCatchupTransitionTier()
; ResolveDeathTransitionTier()
; GetEffectiveMaxLives()
; GetGlobalEffectiveMaxLives()
; RebaselineDragonSoulsLastSeen()
; HandleProgressionRelevantChange()

; --- Defiant / CHIM ---
; ----------------------
; GetDefiantTrackedTier()
; WasDefiantEnteredByConsole()
; SetDefiantEnteredByConsole()
; WasCHIMEnteredByConsole()
; SetCHIMEnteredByConsole()
; InitializeDefiantState()
; ClearDefiantState()
; IsDefiantSoulFatigueTerminal()
; TryRestoreFromDefiant()
; CommitDefiantTransitionStateForDeath()
; CommitCHIMTransitionStateForDeath()
; PromoteToDefiantTier()
; PromoteToCHIMTier()

; --- Console Bridges ---
; -----------------------
; SetTierFromConsole()
; ResetTierFromConsole()

; --- Soul Feats ---
; ------------------
; ScheduleFeatUnlockSFX()
; ScheduleFeatCheck()
; HandleFeatUnlockSFX()
; QueueFeatUnlockMenuAlarmForDue()
; CancelFeatUnlockMenuAlarm()
; IsFeatUnlockMenuAlarmToken()
; HandleFeatUnlockMenuAlarm()
; TryScheduleFeats()
; ShouldScheduleShownTierMessage()
; HandleFeats()
; ClearFeatUnlockTiming()
; LogFeatUnlockMenuTiming()
; HandleDefiantFeatUnlock()
; PromoteFromSoulFeat()
; ShowNormalSoulFeatMessageForTier()
; ShowTierUnlockMessageIfNeeded()
; MaybePlayLuckImprovedAfterTierUnlock()
; ResolveSoulFeatUnlockMenu()
; ResolveDefiantRestoreMenu()

; --- Boss Latches ---
; --------------------
; PollBossDefeatLatches()
; IsMiraakDefeated()
; IsAlduinDefeated()
; IsHarkonDefeated()
; IsMolagBalDefeatedVigilant()

; --- UI / SFX ---
; ----------------
; MaybeNotifyDragonSoulIncrease()
; CanPlayTierSFX()
; PlayTierSFX()
; PlayTierSFXInstance()
; PlayCHIMTransitionSWF()
; PlayDefiantTransitionSWF()
; PlayDefiantRestoreSWF()

; --- Tier Policy Helpers ---
; ---------------------------
; IsCanonicalSoulTier()
; IsNormalSoulTier()
; GetSoulBonusOrdinal()
; NormalizeDefiantTrackedTier()
; GetMaxLuckForTierAtLevel()
; GetHighestEligibleNormalSoulTier()
; ResolveSoulTierTargetFromFacts()
; SoulTierLabel()
; NormalizeSoulFeatUnlockTier()

IronSoulController Property Controller Auto

; Boss quest latches
Quest Property MQ305 Auto
Quest Property DLC1VQ08 Auto
Quest Property DLC2MQ06 Auto

; Tier-specific UI SFX
Sound Property SFXCHIMTransition Auto
Sound Property SFXDefiantRestore Auto
Sound Property SFXDefiantTransition Auto
Sound Property SFXSunderheartAbsorb Auto
Sound Property SFXFeatUnlock Auto

; Soul / feats
String Property soulTierIndex              = "IS_2204" AutoReadOnly
String Property manualTierOverrideActive   = "IS_2719" AutoReadOnly
String Property ebonFeatVariant            = "IS_4520" AutoReadOnly
String Property platinumFeatVariant        = "IS_4779" AutoReadOnly
String Property dragonSoulsTotal           = "IS_9646" AutoReadOnly
String Property dragonSoulsTotalShared     = "DS.T" AutoReadOnly ; Shared accepted Dragon Soul counter.
String Property dragonSoulsLastSeen        = "IS_7440" AutoReadOnly

; Narrative / UI one-shots
String Property tierMsgShownSilver         = "IS_9921" AutoReadOnly
String Property tierMsgShownGold           = "IS_4797" AutoReadOnly
String Property tierMsgShownEbon           = "IS_4513" AutoReadOnly
String Property tierMsgShownPlatinum       = "IS_1155" AutoReadOnly
String Property tierMsgShownDevour         = "IS_1156" AutoReadOnly

; Boss latches
String Property miraakKilled               = "IS_4911" AutoReadOnly
String Property alduinKilled               = "IS_9897" AutoReadOnly
String Property harkonKilled               = "IS_9808" AutoReadOnly
String Property molagBalKilled             = "IS_1627" AutoReadOnly

; Defiant / CHIM
String Property defiantFeatUnlocked        = "IS_1989" AutoReadOnly
String Property defiantTrackedTier         = "IS_9131" AutoReadOnly
String Property defiantEnteredByConsole    = "IS_9136" AutoReadOnly
String Property chimEnteredByConsole       = "IS_9137" AutoReadOnly

; Canonical soul tier/state:
; 0=Defiant, 1=Iron, 2=Silver, 3=Gold, 4=Ebon, 5=Platinum, 6=Devour, 9=CHIM
Int Property TIER_DEFIANT = 0 AutoReadOnly
Int Property TIER_IRON = 1 AutoReadOnly
Int Property TIER_SILVER = 2 AutoReadOnly
Int Property TIER_GOLD = 3 AutoReadOnly
Int Property TIER_EBON = 4 AutoReadOnly
Int Property TIER_PLATINUM = 5 AutoReadOnly
Int Property TIER_DEVOUR = 6 AutoReadOnly
Int Property TIER_CHIM = 9 AutoReadOnly

Int Property TIER_TARGET_MODE_NORMAL_FEAT = 1 AutoReadOnly
Int Property TIER_TARGET_MODE_RESET = 2 AutoReadOnly
Int Property TIER_TARGET_MODE_TRUE_DEATH = 3 AutoReadOnly
Int Property TIER_TARGET_MODE_LOAD_CATCHUP = 4 AutoReadOnly

Int Property IRON_SOUL_MAX_LIVES = 10 AutoReadOnly
Int Property DEFIANT_SOUL_MAX_LIVES = 20 AutoReadOnly

Float DEFIANT_TRANSITION_SECONDS = 47.0
Float CHIM_TRANSITION_SECONDS = 49.0
Float DEFIANT_RESTORE_SECONDS = 11.0
Float TRANSITION_KEY_DISMISS_SECONDS = 7.0
Float DEFIANT_RESTORE_KEY_DISMISS_SECONDS = 7.0
Float FEAT_UNLOCK_SFX_DELAY_SECONDS = 4.0
Float FEAT_UNLOCK_MENU_AFTER_SFX_SECONDS = 4.07
Float FEAT_UNLOCK_SLOWMO_RAMP_SECONDS = 0.75

Bool _pendingDragonSoulsRebaseline = False
Int _dragonSoulWatcherToken = 0
String _dragonSoulWatcherGuid = ""
Int _dragonSoulWatcherBaseline = -1
Bool _pendingFeats = False
Float _featsAt = 0.0
Sound _pendingFeatUnlockSFX = None
Float _featUnlockSFXAt = 0.0
Float _featUnlockSFXStartedWallAt = 0.0
Float _featUnlockMenuDueWallAt = 0.0
Int _featUnlockMenuAlarmToken = 0

Quest _vigilantMq08Cache = None
Bool _vigilantMq08Tried = False


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Identity || !Controller.Persistence
        return False
    endif
    if !Controller.Death || !Controller.Journal || !Controller.Presentation
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

Bool Function CanWriteSharedProgression(Actor player)
    if player && Controller && Controller.Identity
        return !Controller.Identity.IsCurrentCharacterTest(player)
    endif
    return True
EndFunction

Function LogTiers(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("Tiers", level, msg, suppressNotify)
        return
    endif

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [Tiers] " + msg)
EndFunction

Function LogTiersSnapshot(Int level, String msg)
    if Controller && Controller.Config
        Controller.Config.LogComponentSnapshot("Tiers", level, msg)
        return
    endif

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [Snapshot] " + msg)
EndFunction


; --- Component Runtime ---
; =========================

Function ResetTransientState()
    StopDragonSoulWatcher("reset")
    CancelFeatUnlockMenuAlarm("reset")
    _pendingDragonSoulsRebaseline = False
    _dragonSoulWatcherGuid = ""
    _dragonSoulWatcherBaseline = -1
    _pendingFeats = False
    _featsAt = 0.0
    _pendingFeatUnlockSFX = None
    _featUnlockSFXAt = 0.0
    _featUnlockSFXStartedWallAt = 0.0
    _featUnlockMenuDueWallAt = 0.0
    _featUnlockMenuAlarmToken = 0
    _vigilantMq08Cache = None
    _vigilantMq08Tried = False
EndFunction

Function SetPendingDragonSoulsRebaseline(Bool pending)
    _pendingDragonSoulsRebaseline = pending
    if pending
        StopDragonSoulWatcher("pending-rebaseline")
    endif
EndFunction

Function RemoveTrackedData(Actor player, String guid, Bool deleteMainData = True, Bool unsetCosave = False)
    if !HasPersistenceRuntime() || guid == ""
        return
    endif

    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, tierMsgShownSilver, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, tierMsgShownGold, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, tierMsgShownEbon, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, tierMsgShownPlatinum, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, tierMsgShownDevour, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, soulTierIndex, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, manualTierOverrideActive, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, ebonFeatVariant, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, platinumFeatVariant, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, dragonSoulsTotal, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, dragonSoulsLastSeen, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, miraakKilled, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, alduinKilled, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, harkonKilled, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, molagBalKilled, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, defiantFeatUnlocked, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, defiantTrackedTier, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, defiantEnteredByConsole, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, chimEnteredByConsole, deleteMainData, unsetCosave)
EndFunction

Function Tick(Actor player)
    HandleFeatUnlockSFX(player)
    HandleFeats(player)
EndFunction

Function Heartbeat(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif
    if player.IsDead() || player.IsBleedingOut() || Utility.IsInMenuMode()
        return
    endif

    PollBossDefeatLatches(player, guid)
    TryScheduleFeats(player)
EndFunction

Function StartDragonSoulWatcher(Actor player, String guid, String reason = "dragon-souls-watch")
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    Int baseline = Controller.Persistence.GetGuidInt(player, guid, dragonSoulsLastSeen, -1)
    if baseline < 0
        baseline = player.GetActorValue("DragonSouls") as Int
        Controller.Persistence.SetGuidInt(player, guid, dragonSoulsLastSeen, baseline, True)
    endif

    if IsDragonSoulWatcherCurrent(guid, baseline)
        return
    endif

    StopDragonSoulWatcher("restart-" + reason)
    Int token = IronSoulNative.BeginDragonSoulWatcher(baseline, 0.5, "dragon-souls-changed")
    if token > 0
        _dragonSoulWatcherToken = token
        _dragonSoulWatcherGuid = guid
        _dragonSoulWatcherBaseline = baseline
    else
        _dragonSoulWatcherToken = 0
        _dragonSoulWatcherGuid = ""
        _dragonSoulWatcherBaseline = -1
        LogTiers(IronSoulConfig.LOG_DBG(), "StartDragonSoulWatcher: native watcher unavailable; live Dragon Soul watcher inactive reason=" + reason, True)
    endif
EndFunction

Function StopDragonSoulWatcher(String reason = "dragon-souls-stop")
    if _dragonSoulWatcherToken > 0
        IronSoulNative.EndDragonSoulWatcher(_dragonSoulWatcherToken, reason)
        _dragonSoulWatcherToken = 0
        _dragonSoulWatcherGuid = ""
        _dragonSoulWatcherBaseline = -1
    endif
EndFunction

Bool Function IsDragonSoulWatcherToken(Int token)
    return token > 0 && token == _dragonSoulWatcherToken
EndFunction

Bool Function IsDragonSoulWatcherCurrent(String guid, Int baseline)
    return _dragonSoulWatcherToken > 0 && _dragonSoulWatcherGuid == guid && _dragonSoulWatcherBaseline == baseline
EndFunction

Function HandleDragonSoulWatcherUpdate(Actor player, String guid, Int token)
    if !IsDragonSoulWatcherToken(token)
        LogTiers(IronSoulConfig.LOG_DBG(), "HandleDragonSoulWatcherUpdate: ignored stale token=" + token + " current=" + _dragonSoulWatcherToken, True)
        return
    endif

    StopDragonSoulWatcher("callback")
    SyncDragonSoulsLive(player, guid, "watcher")
EndFunction

Bool Function SyncDragonSoulsLive(Actor player, String guid, String reason = "dragon-souls-sync")
    if !HasCoreRuntime() || !player || guid == ""
        return False
    endif
    if player.IsDead() || player.IsBleedingOut() || Utility.IsInMenuMode()
        return False
    endif

    Int curSouls = player.GetActorValue("DragonSouls") as Int
    if _pendingDragonSoulsRebaseline
        RebaselineDragonSoulsLastSeen(player, guid, curSouls)
        _pendingDragonSoulsRebaseline = False
        if Controller.Respawn
            Controller.Respawn.UpdatePlayerProtectionState(player)
        endif

    else
        Int lastSouls = Controller.Persistence.GetGuidInt(player, guid, dragonSoulsLastSeen, -1)
        if lastSouls == -1
            RebaselineDragonSoulsLastSeen(player, guid, curSouls)
            StartDragonSoulWatcher(player, guid, reason + "-missing-baseline")
            return False
        endif

        Int delta = curSouls - lastSouls

        if Controller.Respawn
            Controller.Respawn.UpdatePlayerProtectionState(player)
        endif

        Int accepted = 0
        if delta > 0
            accepted = delta
        endif

        if accepted > 0
            Int soulsTotal = GetDragonSoulsTotal(player, guid)
            Bool writeSharedProgression = CanWriteSharedProgression(player)
            Int sharedSoulsTotal = GetDragonSoulsTotalShared(player)
            Int j = 0
            while j < accepted
                soulsTotal += 1
                if writeSharedProgression
                    sharedSoulsTotal += 1
                endif
                Controller.Persistence.SetGuidInt(player, guid, dragonSoulsTotal, soulsTotal, True)

                Int liveTierNow = GetCurrentTier(player, guid)
                MaybeNotifyDragonSoulIncrease(player, guid, liveTierNow, soulsTotal)

                Controller.Journal.LogDragonSoulAbsorbedForGuid(player, guid, soulsTotal)
                HandleProgressionRelevantChange(player, guid)

                j += 1
            endwhile
            if writeSharedProgression
                Controller.Persistence.SetSharedInt(dragonSoulsTotalShared, sharedSoulsTotal, True)
            endif
            if Controller.Globals
                Controller.Globals.SyncDragonSouls(player, guid)
            endif
        endif

        RebaselineDragonSoulsLastSeen(player, guid, curSouls)
    endif

    StartDragonSoulWatcher(player, guid, reason)
    return True
EndFunction

Bool Function RequiresFastPolling()
    return _pendingFeats || _pendingFeatUnlockSFX != None
EndFunction

Function LogSnapshot()
    if !HasCoreRuntime()
        return
    endif

    if !MQ305
        LogTiersSnapshot(IronSoulConfig.LOG_ERR(), "Tiers: MISSING PROPERTY: MQ305 (Quest)")
    endif
    if !DLC1VQ08
        LogTiersSnapshot(IronSoulConfig.LOG_ERR(), "Tiers: MISSING PROPERTY: DLC1VQ08 (Quest)")
    endif
    if !DLC2MQ06
        LogTiersSnapshot(IronSoulConfig.LOG_ERR(), "Tiers: MISSING PROPERTY: DLC2MQ06 (Quest)")
    endif

    Actor p = Game.GetPlayer()
    if p
        String guid = Controller.Identity.GetTickGuid(p)
        if guid != ""
            Int tier = GetCurrentTier(p, guid)
            Int totalDeaths = Controller.Death.GetTotalDeaths(p, guid)
            if tier == TIER_DEFIANT
                LogTiersSnapshot(IronSoulConfig.LOG_INFO(), "Tiers: SoulTier=" + tier + " DefiantTrackedTier=" + GetDefiantTrackedTier(p, guid) + " TotalDeaths=" + totalDeaths + " DragonSoulsTotal=" + GetDragonSoulsTotal(p, guid))
            else
                LogTiersSnapshot(IronSoulConfig.LOG_INFO(), "Tiers: SoulTier=" + tier + " TotalDeaths=" + totalDeaths + " DragonSoulsTotal=" + GetDragonSoulsTotal(p, guid))
            endif
        endif
    endif
EndFunction


; --- Tier State ---
; ==================

Int Function GetCurrentTier(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return TIER_IRON
    endif
    return Controller.Persistence.GetGuidInt(player, guid, soulTierIndex, TIER_IRON)
EndFunction

Function SetCurrentTier(Actor player, String guid, Int tier, Bool syncPresentation = True)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif
    if !IsCanonicalSoulTier(tier)
        tier = TIER_IRON
    endif

    Controller.Persistence.SetGuidInt(player, guid, soulTierIndex, tier, True)
    SyncTierLuckState(player, guid)
    if syncPresentation
        SyncTierPresentationState(player, guid)
    endif
    SyncTierDynamicAssets(tier)
    SyncTierGlobalMirrors(player, guid)
EndFunction

Function SyncTierLuckState(Actor player, String guid)
    if Controller.Luck
        Controller.Luck.SyncNotifiedTierToCurrent(player, guid)
    endif
EndFunction

Function SyncTierPresentationState(Actor player, String guid)
    if Controller.Effects
        Controller.Effects.SyncSoulPresentationAndStats(player, guid)
    endif
EndFunction

Function SyncTierDynamicAssets(Int tier)
    if Controller.Config
        Controller.Config.ApplyDynamicPresetAssetsForTier(tier)
    endif
    IronSoulNative.ApplyDynamicLevelWidget(tier)
EndFunction

Function SyncTierGlobalMirrors(Actor player, String guid)
    if Controller.Globals
        Controller.Globals.SyncTier(player, guid)
        Controller.Globals.SyncDragonSouls(player, guid)
        Controller.Globals.SyncLuck(player, guid)
    endif
EndFunction

Int Function GetDragonSoulsTotal(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return 0
    endif
    return Controller.Persistence.GetGuidInt(player, guid, dragonSoulsTotal, 0)
EndFunction

Int Function GetDragonSoulsTotalShared(Actor player = None)
    if !Controller || !Controller.Persistence
        return 0
    endif
    if player && Controller.Identity && Controller.Identity.IsCurrentCharacterTest(player)
        return 0
    endif
    return Controller.Persistence.GetSharedInt(dragonSoulsTotalShared, 0)
EndFunction

String Function SetDragonSoulsTotalFromConsole(Actor player, String guid, Int totalValue)
    if !HasCoreRuntime() || !player || guid == ""
        return IronSoulNative.TextGet("Console.TiersUnavailable")
    endif

    Int clampedTotal = totalValue
    if clampedTotal < 0
        clampedTotal = 0
    endif
    Int liveSouls = player.GetActorValue("DragonSouls") as Int
    if liveSouls < 0
        liveSouls = 0
    endif

    Controller.Persistence.SetGuidInt(player, guid, dragonSoulsTotal, clampedTotal, True)
    Controller.Persistence.SetGuidInt(player, guid, dragonSoulsLastSeen, liveSouls, True)
    HandleProgressionRelevantChange(player, guid)
    if Controller.Globals
        Controller.Globals.SyncDragonSouls(player, guid)
    endif
    IronSoulNative.DataFlushIfDirty()

    return IronSoulNative.TextFormat1("Console.SoulsTotalSet", "total", "" + clampedTotal)
EndFunction

Bool Function IsManualTierOverrideActive(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return False
    endif
    return Controller.Persistence.GetGuidInt(player, guid, manualTierOverrideActive, 0) == 1
EndFunction

Function SetManualTierOverrideActive(Actor player, String guid, Bool enabled)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif
    if enabled
        Controller.Persistence.SetGuidInt(player, guid, manualTierOverrideActive, 1, True)
    else
        Controller.Persistence.SetGuidInt(player, guid, manualTierOverrideActive, 0, True)
    endif
EndFunction

Int Function GetHighestEligibleNormalTierForPlayer(Actor player, String guid, Int soulsObtained)
    if !HasCoreRuntime() || !player || guid == ""
        return TIER_IRON
    endif

    Int molagFlag = Controller.Persistence.GetGuidInt(player, guid, molagBalKilled, 0)
    Int miraakFlag = Controller.Persistence.GetGuidInt(player, guid, miraakKilled, 0)
    Int alduinFlag = Controller.Persistence.GetGuidInt(player, guid, alduinKilled, 0)
    Int harkonFlag = Controller.Persistence.GetGuidInt(player, guid, harkonKilled, 0)
    return GetHighestEligibleNormalSoulTier(soulsObtained, molagFlag == 1, miraakFlag == 1, alduinFlag == 1, harkonFlag == 1)
EndFunction

Int Function ResolveSoulTierTarget(Actor player, String guid, Int resolveMode, Int deaths = -1, Int soulsObtained = -1, Int liveTier = -1)
    if !HasCoreRuntime() || !player || guid == ""
        return TIER_IRON
    endif

    if deaths < 0
        deaths = Controller.Death.GetCurrentDeathCount(player, guid)
    endif
    if soulsObtained < 0
        soulsObtained = GetDragonSoulsTotal(player, guid)
    endif
    if !IsCanonicalSoulTier(liveTier)
        liveTier = GetCurrentTier(player, guid)
    endif

    Int highestEligibleNormalTier = GetHighestEligibleNormalTierForPlayer(player, guid, soulsObtained)
    Int defiantFeatFlag = Controller.Persistence.GetGuidInt(player, guid, defiantFeatUnlocked, 0)
    return ResolveSoulTierTargetFromFacts(resolveMode, deaths, liveTier, highestEligibleNormalTier, IRON_SOUL_MAX_LIVES, DEFIANT_SOUL_MAX_LIVES, Controller.Config.IsSoulFeatsEnabled(), Controller.Config.IsDefiantSoulEnabled(), Controller.Config.IsPermadeathEnabled(), IsManualTierOverrideActive(player, guid), WasCHIMEnteredByConsole(player, guid), defiantFeatFlag == 1)
EndFunction

Int Function GetHighestEligibleSoulFeatTier(Actor player, String guid, Int deaths, Int soulsObtained)
    return ResolveSoulTierTarget(player, guid, TIER_TARGET_MODE_NORMAL_FEAT, deaths, soulsObtained)
EndFunction

Int Function GetResetTargetTier(Actor player, String guid)
    return ResolveSoulTierTarget(player, guid, TIER_TARGET_MODE_RESET)
EndFunction

Int Function GetLoadCatchupTransitionTier(Actor player, String guid, Int deathsNow, Int soulTier)
    Int targetTier = ResolveSoulTierTarget(player, guid, TIER_TARGET_MODE_LOAD_CATCHUP, deathsNow, -1, soulTier)
    if targetTier == soulTier
        return -1
    endif
    return targetTier
EndFunction

Int Function ResolveDeathTransitionTier(Actor player, String guid, Int deathsNow, Int soulTier)
    return ResolveSoulTierTarget(player, guid, TIER_TARGET_MODE_TRUE_DEATH, deathsNow, -1, soulTier)
EndFunction

Int Function GetEffectiveMaxLives(Actor player, String guid)
    Int tierNow = GetCurrentTier(player, guid)
    if tierNow == TIER_DEFIANT
        return DEFIANT_SOUL_MAX_LIVES
    elseif tierNow == TIER_CHIM
        return 2147483647
    endif
    return IRON_SOUL_MAX_LIVES
EndFunction

Int Function GetGlobalEffectiveMaxLives(Actor player, String guid)
    if GetCurrentTier(player, guid) == TIER_CHIM
        return 42
    endif
    return GetEffectiveMaxLives(player, guid)
EndFunction

Function RebaselineDragonSoulsLastSeen(Actor player, String guid, Int curSouls = -1)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    if curSouls < 0
        curSouls = player.GetActorValue("DragonSouls") as Int
    endif

    Controller.Persistence.SetGuidInt(player, guid, dragonSoulsLastSeen, curSouls, True)
EndFunction

Function HandleProgressionRelevantChange(Actor player, String guid)
    if !player || guid == ""
        return
    endif

    Int liveTier = GetCurrentTier(player, guid)
    if liveTier == TIER_DEFIANT
        return
    endif

    TryScheduleFeats(player)
EndFunction


; --- Defiant / CHIM ---
; ======================

Bool Function WasCHIMEnteredByConsole(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return False
    endif
    return Controller.Persistence.GetGuidInt(player, guid, chimEnteredByConsole, 0) == 1
EndFunction

Function SetCHIMEnteredByConsole(Actor player, String guid, Bool enteredByConsole)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    if enteredByConsole
        Controller.Persistence.SetGuidInt(player, guid, chimEnteredByConsole, 1, True)
    else
        Controller.Persistence.SetGuidInt(player, guid, chimEnteredByConsole, 0, True)
    endif
EndFunction

Int Function GetDefiantTrackedTier(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return TIER_IRON
    endif
    return NormalizeDefiantTrackedTier(Controller.Persistence.GetGuidInt(player, guid, defiantTrackedTier, TIER_IRON))
EndFunction

Bool Function WasDefiantEnteredByConsole(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return False
    endif
    return Controller.Persistence.GetGuidInt(player, guid, defiantEnteredByConsole, 0) == 1
EndFunction

Function SetDefiantEnteredByConsole(Actor player, String guid, Bool enteredByConsole)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    if enteredByConsole
        Controller.Persistence.SetGuidInt(player, guid, defiantEnteredByConsole, 1, True)
    else
        Controller.Persistence.SetGuidInt(player, guid, defiantEnteredByConsole, 0, True)
    endif
EndFunction

Function InitializeDefiantState(Actor player, String guid, Int storedTier = -1)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    Int liveTier = GetCurrentTier(player, guid)
    Int seedTier = storedTier
    if !IsNormalSoulTier(seedTier)
        if IsNormalSoulTier(liveTier)
            seedTier = liveTier
        else
            seedTier = GetHighestEligibleNormalTierForPlayer(player, guid, GetDragonSoulsTotal(player, guid))
        endif
    endif

    Controller.Persistence.SetGuidInt(player, guid, defiantTrackedTier, NormalizeDefiantTrackedTier(seedTier), True)
EndFunction

Function ClearDefiantState(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif
    Controller.Persistence.SetGuidInt(player, guid, defiantTrackedTier, TIER_IRON, True)
    Controller.Persistence.SetGuidInt(player, guid, defiantEnteredByConsole, 0, True)
EndFunction

Bool Function IsDefiantSoulFatigueTerminal(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return False
    endif
    if GetCurrentTier(player, guid) != TIER_DEFIANT
        return False
    endif
    if !Controller.Config.IsSoulFatigueEnabled()
        return False
    endif
    return player.GetAVMax("Health") <= 0.0
EndFunction

Bool Function TryRestoreFromDefiant(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return False
    endif
    if GetCurrentTier(player, guid) != TIER_DEFIANT
        return False
    endif
    if Controller.Death.GetCurrentDeathCount(player, guid) >= IRON_SOUL_MAX_LIVES
        return False
    endif

    Int targetTier = NormalizeDefiantTrackedTier(GetDefiantTrackedTier(player, guid))
    String restoreMenu = ResolveDefiantRestoreMenu(targetTier)

    Controller.Persistence.SetGuidInt(player, guid, soulTierIndex, targetTier, True)
    SetManualTierOverrideActive(player, guid, False)
    ClearDefiantState(player, guid)
    if Controller.Config.IsCharacterJournalEnabled()
        Int molagFlagR = Controller.Persistence.GetGuidInt(player, guid, molagBalKilled, 0)
        Int miraakFlagR = Controller.Persistence.GetGuidInt(player, guid, miraakKilled, 0)
        Int alduinFlagR = Controller.Persistence.GetGuidInt(player, guid, alduinKilled, 0)
        Int harkonFlagR = Controller.Persistence.GetGuidInt(player, guid, harkonKilled, 0)
        Controller.Journal.LogDefiantRestoreForGuid(player, guid, targetTier, Controller.Death.GetTotalDeaths(player, guid), molagFlagR == 1, miraakFlagR == 1, alduinFlagR == 1, harkonFlagR == 1)
    endif

    IronSoulNative.DataFlushIfDirty()

    PlayDefiantRestoreSWF(player, restoreMenu, True)

    ; Keep the post-Sunderheart pause short; these live mirrors can safely update after the restore intro closes.
    SyncTierLuckState(player, guid)
    SyncTierPresentationState(player, guid)
    SyncTierDynamicAssets(targetTier)
    SyncTierGlobalMirrors(player, guid)
    return True
EndFunction

Function CommitCHIMTransitionStateForDeath(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    ClearDefiantState(player, guid)
    SetCHIMEnteredByConsole(player, guid, False)
    SetManualTierOverrideActive(player, guid, False)
    Controller.Persistence.SetGuidInt(player, guid, soulTierIndex, TIER_CHIM, True)
    IronSoulNative.DataFlushIfDirty()
EndFunction

Function CommitDefiantTransitionStateForDeath(Actor player, String guid, Int storedTier = -1)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    if Controller.Persistence.GetGuidInt(player, guid, defiantFeatUnlocked, 0) != 1
        Controller.Persistence.SetGuidInt(player, guid, defiantFeatUnlocked, 1, True)
    endif

    InitializeDefiantState(player, guid, storedTier)
    SetDefiantEnteredByConsole(player, guid, False)
    SetManualTierOverrideActive(player, guid, False)
    Controller.Persistence.SetGuidInt(player, guid, soulTierIndex, TIER_DEFIANT, True)
    IronSoulNative.DataFlushIfDirty()
EndFunction

Function PromoteToCHIMTier(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    ClearDefiantState(player, guid)
    SetCHIMEnteredByConsole(player, guid, False)
    SetManualTierOverrideActive(player, guid, False)
    SetCurrentTier(player, guid, TIER_CHIM)

    Controller.Journal.LogCHIMRealized(player, guid)

    IronSoulNative.DataFlushIfDirty()
EndFunction

Function PromoteToDefiantTier(Actor player, String guid, Int storedTier = -1)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    if Controller.Persistence.GetGuidInt(player, guid, defiantFeatUnlocked, 0) != 1
        Controller.Persistence.SetGuidInt(player, guid, defiantFeatUnlocked, 1, True)
    endif

    InitializeDefiantState(player, guid, storedTier)
    SetDefiantEnteredByConsole(player, guid, False)
    SetManualTierOverrideActive(player, guid, False)
    SetCurrentTier(player, guid, TIER_DEFIANT)

    IronSoulNative.DataFlushIfDirty()
EndFunction


; --- Console Bridges ---
; =======================

String Function SetTierFromConsole(Actor player, String guid, Int tierValue, Int parsedForce)
    if !HasCoreRuntime() || !player || guid == ""
        return IronSoulNative.TextGet("Console.TiersUnavailable")
    endif
    if !IsCanonicalSoulTier(tierValue)
        return IronSoulNative.TextGet("Console.ErrorTierInvalid")
    endif

    Int previousTier = GetCurrentTier(player, guid)
    if parsedForce == 1
        SetManualTierOverrideActive(player, guid, True)
    endif

    if tierValue == TIER_CHIM
        SetCHIMEnteredByConsole(player, guid, True)
    else
        SetCHIMEnteredByConsole(player, guid, False)
    endif

    if tierValue == TIER_DEFIANT
        Int seedTier = previousTier
        if seedTier == TIER_DEFIANT
            seedTier = GetDefiantTrackedTier(player, guid)
        endif
        InitializeDefiantState(player, guid, seedTier)
        SetDefiantEnteredByConsole(player, guid, True)
    else
        ClearDefiantState(player, guid)
    endif

    SetCurrentTier(player, guid, tierValue)
    IronSoulNative.DataFlushIfDirty()

    Bool manualTierOverride = IsManualTierOverrideActive(player, guid)
    String msg = IronSoulNative.TextFormat2("Console.TierSet", "tier", "" + tierValue, "label", SoulTierLabel(tierValue))
    if manualTierOverride
        if parsedForce == 1
            msg = msg + " " + IronSoulNative.TextGet("Console.TierManualOverrideActive")
        else
            msg = msg + " " + IronSoulNative.TextGet("Console.TierForceHintManual")
        endif
    elseif parsedForce == 0
        msg = msg + " " + IronSoulNative.TextGet("Console.TierForceHint")
    endif
    return msg
EndFunction

String Function ResetTierFromConsole(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return IronSoulNative.TextGet("Console.TiersUnavailable")
    endif

    Int targetTier = GetResetTargetTier(player, guid)
    Int liveTier = GetCurrentTier(player, guid)
    if liveTier == TIER_DEFIANT && WasDefiantEnteredByConsole(player, guid)
        targetTier = GetDefiantTrackedTier(player, guid)
    endif

    SetManualTierOverrideActive(player, guid, False)
    SetCHIMEnteredByConsole(player, guid, False)

    if targetTier == TIER_DEFIANT
        if liveTier != TIER_DEFIANT
            Int seedTier = liveTier
            if !IsNormalSoulTier(seedTier)
                seedTier = GetDefiantTrackedTier(player, guid)
            endif
            InitializeDefiantState(player, guid, seedTier)
        endif
    else
        ClearDefiantState(player, guid)
    endif

    SetCurrentTier(player, guid, targetTier)
    IronSoulNative.DataFlushIfDirty()

    return IronSoulNative.TextFormat2("Console.TierReset", "tier", "" + targetTier, "label", SoulTierLabel(targetTier))
EndFunction


; --- Soul Feats ---
; ==================

Function ScheduleFeatUnlockSFX(Sound sfx, Float playAtRT)
    if !sfx
        _pendingFeatUnlockSFX = None
        _featUnlockSFXAt = 0.0
        _featUnlockSFXStartedWallAt = 0.0
        _featUnlockMenuDueWallAt = 0.0
        CancelFeatUnlockMenuAlarm("schedule-no-sfx")
        return
    endif

    CancelFeatUnlockMenuAlarm("schedule-replace")
    _pendingFeatUnlockSFX = sfx
    _featUnlockSFXAt = playAtRT
    _featUnlockSFXStartedWallAt = 0.0
    _featUnlockMenuDueWallAt = 0.0
EndFunction

Function ScheduleFeatCheck(Float nowRT, Sound sfx = None, Bool scheduleSFX = True)
    _pendingFeats = True
    Float sfxAt = nowRT + FEAT_UNLOCK_SFX_DELAY_SECONDS
    Float menuAt = nowRT + FEAT_UNLOCK_SFX_DELAY_SECONDS
    if scheduleSFX && sfx
        menuAt = sfxAt + FEAT_UNLOCK_MENU_AFTER_SFX_SECONDS
    endif
    if _featsAt < menuAt
        _featsAt = menuAt
    endif
    if scheduleSFX && sfx
        ScheduleFeatUnlockSFX(sfx, sfxAt)
    else
        ScheduleFeatUnlockSFX(None, 0.0)
    endif
EndFunction

Function HandleFeatUnlockSFX(Actor player)
    if !_pendingFeatUnlockSFX
        return
    endif
    Float nowRT = Utility.GetCurrentRealTime()
    if nowRT < _featUnlockSFXAt
        return
    endif
    if !player
        return
    endif
    if Utility.IsInMenuMode() || player.IsDead() || player.IsBleedingOut()
        _featUnlockSFXAt = nowRT + 1.0
        return
    endif

    Sound sfx = _pendingFeatUnlockSFX
    _pendingFeatUnlockSFX = None
    _featUnlockSFXAt = 0.0
    if CanPlayTierSFX(sfx)
        Float sfxStartedWallAt = IronSoulNative.GetWallClockSeconds()
        _featUnlockSFXStartedWallAt = sfxStartedWallAt
        _featUnlockMenuDueWallAt = sfxStartedWallAt + FEAT_UNLOCK_MENU_AFTER_SFX_SECONDS
        IronSoulNative.TryStartFeatUnlockSlowMo(FEAT_UNLOCK_SLOWMO_RAMP_SECONDS, "feat-unlock-sfx")
        PlayTierSFX(sfx, player)
        _featsAt = nowRT + FEAT_UNLOCK_MENU_AFTER_SFX_SECONDS
        LogTiers(IronSoulConfig.LOG_INFO(), "HandleFeatUnlockSFX: started feat unlock SFX; menu target seconds=" + FEAT_UNLOCK_MENU_AFTER_SFX_SECONDS + " slowmoRamp=" + FEAT_UNLOCK_SLOWMO_RAMP_SECONDS, True)
        QueueFeatUnlockMenuAlarmForDue("feat-unlock-sfx")
        Controller.QueueUpdate(FEAT_UNLOCK_MENU_AFTER_SFX_SECONDS)
    else
        _featUnlockSFXStartedWallAt = 0.0
        _featUnlockMenuDueWallAt = 0.0
        CancelFeatUnlockMenuAlarm("feat-unlock-sfx-disabled")
        _featsAt = nowRT
        Controller.QueueUpdate(0.1)
    endif
EndFunction

Function QueueFeatUnlockMenuAlarmForDue(String reason = "feat-unlock-menu")
    if _featUnlockMenuDueWallAt <= 0.0
        return
    endif

    CancelFeatUnlockMenuAlarm(reason + "-replace")

    Float delaySeconds = _featUnlockMenuDueWallAt - IronSoulNative.GetWallClockSeconds()
    if delaySeconds < 0.0
        delaySeconds = 0.0
    endif

    Int token = IronSoulNative.QueueFeatUnlockMenuAlarm(delaySeconds, "feat-unlock-menu")
    if token > 0
        _featUnlockMenuAlarmToken = token
        LogTiers(IronSoulConfig.LOG_DBG(), "QueueFeatUnlockMenuAlarmForDue: queued token=" + token + " delay=" + delaySeconds + " reason=" + reason, True)
    else
        LogTiers(IronSoulConfig.LOG_ERR(), "QueueFeatUnlockMenuAlarmForDue: native queue failed; falling back to controller polling reason=" + reason)
    endif
EndFunction

Function CancelFeatUnlockMenuAlarm(String reason = "cancel-feat-unlock-menu")
    if _featUnlockMenuAlarmToken > 0
        IronSoulNative.CancelFeatUnlockMenuAlarm(_featUnlockMenuAlarmToken, reason)
        _featUnlockMenuAlarmToken = 0
    endif
EndFunction

Bool Function IsFeatUnlockMenuAlarmToken(Int token)
    return token > 0 && token == _featUnlockMenuAlarmToken
EndFunction

Function HandleFeatUnlockMenuAlarm(Actor player, Int token, String source = "feat-unlock-menu")
    if !IsFeatUnlockMenuAlarmToken(token)
        LogTiers(IronSoulConfig.LOG_DBG(), "HandleFeatUnlockMenuAlarm: ignored stale token=" + token + " current=" + _featUnlockMenuAlarmToken, True)
        return
    endif

    _featUnlockMenuAlarmToken = 0
    HandleFeats(player)
    if _pendingFeats && _featUnlockMenuDueWallAt > 0.0
        QueueFeatUnlockMenuAlarmForDue(source + "-retry")
    endif
EndFunction

Function TryScheduleFeats(Actor player)
    if !HasCoreRuntime() || !player
        return
    endif
    if _pendingFeats
        return
    endif

    String guid = Controller.Identity.GetTickGuid(player)
    if guid == ""
        return
    endif

    if Utility.IsInMenuMode() || player.IsDead() || player.IsBleedingOut()
        return
    endif

    Int deaths = Controller.Death.GetCurrentDeathCount(player, guid)
    Int soulsObtained = GetDragonSoulsTotal(player, guid)
    Int curTier = GetCurrentTier(player, guid)
    Bool manualTierOverride = IsManualTierOverrideActive(player, guid)

    if curTier == TIER_CHIM || curTier == TIER_DEFIANT
        return
    endif

    Float nowRT = Utility.GetCurrentRealTime()

    Bool defiantEligible = (soulsObtained >= 1 && deaths < IRON_SOUL_MAX_LIVES)
    Int defFeat = Controller.Persistence.GetGuidInt(player, guid, defiantFeatUnlocked, 0)
    if defiantEligible && defFeat != 1
        if Controller.Config.IsDefiantSoulEnabled()
            ScheduleFeatCheck(nowRT, SFXFeatUnlock)
        else
            ScheduleFeatCheck(nowRT, None, False)
        endif
        return
    endif

    if Controller.Config.IsSoulFeatsEnabled()
        Int desiredTier = GetHighestEligibleSoulFeatTier(player, guid, deaths, soulsObtained)

        if !manualTierOverride && desiredTier > curTier
            ScheduleFeatCheck(nowRT, SFXFeatUnlock)
            return
        endif

        if manualTierOverride
            return
        endif

        if ShouldScheduleShownTierMessage(player, guid, curTier)
            ScheduleFeatCheck(nowRT, SFXFeatUnlock)
        endif
    endif
EndFunction

Bool Function ShouldScheduleShownTierMessage(Actor player, String guid, Int curTier)
    if curTier == TIER_DEVOUR
        return Controller.Persistence.GetGuidInt(player, guid, tierMsgShownDevour, 0) != 1
    elseif curTier == TIER_PLATINUM
        return Controller.Persistence.GetGuidInt(player, guid, tierMsgShownPlatinum, 0) != 1
    elseif curTier == TIER_EBON
        return Controller.Persistence.GetGuidInt(player, guid, tierMsgShownEbon, 0) != 1
    elseif curTier == TIER_GOLD
        return Controller.Persistence.GetGuidInt(player, guid, tierMsgShownGold, 0) != 1
    elseif curTier == TIER_SILVER
        return Controller.Persistence.GetGuidInt(player, guid, tierMsgShownSilver, 0) != 1
    endif
    return False
EndFunction

Function HandleFeats(Actor player)
    if !_pendingFeats
        return
    endif

    Float nowRT = Utility.GetCurrentRealTime()
    if _featUnlockMenuDueWallAt > 0.0
        if IronSoulNative.GetWallClockSeconds() < _featUnlockMenuDueWallAt
            return
        endif
    else
        if nowRT < _featsAt
            return
        endif
    endif

    if Utility.IsInMenuMode() || !player || player.IsDead() || player.IsBleedingOut()
        _featsAt = nowRT + 1.0
        if _featUnlockMenuDueWallAt > 0.0
            _featUnlockMenuDueWallAt = IronSoulNative.GetWallClockSeconds() + 1.0
        endif
        return
    endif

    String guid = Controller.Identity.GetTickGuid(player)
    if guid == ""
        _featsAt = nowRT + 1.0
        if _featUnlockMenuDueWallAt > 0.0
            _featUnlockMenuDueWallAt = IronSoulNative.GetWallClockSeconds() + 1.0
        endif
        return
    endif

    _pendingFeats = False

    Int deaths = Controller.Death.GetCurrentDeathCount(player, guid)
    Int soulsObtained = GetDragonSoulsTotal(player, guid)
    Int curTier = GetCurrentTier(player, guid)
    Bool manualTierOverride = IsManualTierOverrideActive(player, guid)

    if curTier == TIER_CHIM || curTier == TIER_DEFIANT
        ClearFeatUnlockTiming()
        return
    endif

    if HandleDefiantFeatUnlock(player, guid, deaths, soulsObtained)
        return
    endif

    if Controller.Config.IsSoulFeatsEnabled()
        Int desiredTier = GetHighestEligibleSoulFeatTier(player, guid, deaths, soulsObtained)
        Bool promotedFromSoulFeat = False
        Int promotedTier = curTier

        if !manualTierOverride && desiredTier > curTier
            PromoteFromSoulFeat(player, guid, desiredTier)
            curTier = desiredTier
            promotedFromSoulFeat = True
            promotedTier = desiredTier
        endif

        if manualTierOverride
            ClearFeatUnlockTiming()
            return
        endif

        ShowNormalSoulFeatMessageForTier(player, guid, curTier)
        if promotedFromSoulFeat
            SyncTierLuckState(player, guid)
            if Controller.Config.IsCharacterJournalEnabled()
                Int molagFlagS = Controller.Persistence.GetGuidInt(player, guid, molagBalKilled, 0)
                Int miraakFlagS = Controller.Persistence.GetGuidInt(player, guid, miraakKilled, 0)
                Int alduinFlagS = Controller.Persistence.GetGuidInt(player, guid, alduinKilled, 0)
                Int harkonFlagS = Controller.Persistence.GetGuidInt(player, guid, harkonKilled, 0)
                Controller.Journal.LogSoulFeatForGuid(player, guid, promotedTier, Controller.Death.GetTotalDeaths(player, guid), molagFlagS == 1, miraakFlagS == 1, alduinFlagS == 1, harkonFlagS == 1)
            endif
            SyncTierDynamicAssets(promotedTier)
            SyncTierPresentationState(player, guid)
            SyncTierGlobalMirrors(player, guid)
            IronSoulNative.DataFlushIfDirty()
        endif
    endif
    ClearFeatUnlockTiming()
EndFunction

Function ClearFeatUnlockTiming()
    CancelFeatUnlockMenuAlarm("clear-feat-unlock-timing")
    _featUnlockSFXStartedWallAt = 0.0
    _featUnlockMenuDueWallAt = 0.0
EndFunction

Function LogFeatUnlockMenuTiming(String menuName)
    if _featUnlockSFXStartedWallAt <= 0.0
        ClearFeatUnlockTiming()
        return
    endif

    Float elapsedWall = IronSoulNative.GetWallClockSeconds() - _featUnlockSFXStartedWallAt
    Float lateWall = elapsedWall - FEAT_UNLOCK_MENU_AFTER_SFX_SECONDS
    LogTiers(IronSoulConfig.LOG_INFO(), "FeatUnlockTiming: opening menu=" + menuName + " elapsed=" + elapsedWall + " target=" + FEAT_UNLOCK_MENU_AFTER_SFX_SECONDS + " late=" + lateWall, True)
    ClearFeatUnlockTiming()
EndFunction

Bool Function HandleDefiantFeatUnlock(Actor player, String guid, Int deaths, Int soulsObtained)
    Bool defiantEligible = (soulsObtained >= 1 && deaths < IRON_SOUL_MAX_LIVES)
    Int defFeat = Controller.Persistence.GetGuidInt(player, guid, defiantFeatUnlocked, 0)
    if !defiantEligible || defFeat == 1
        return False
    endif

    Controller.Persistence.SetGuidInt(player, guid, defiantFeatUnlocked, 1, True)
    if Controller.Config.IsDefiantSoulEnabled()
        LogTiers(IronSoulConfig.LOG_INFO(), "HandleFeats: Defiant Soul feat unlocked (eligibility met); showing unlock message")
        String defiantMenu = IronSoulUI.ResolveDefiantFeatUnlockMenu(Controller.Config.IsSoulFatigueEnabled())
        LogFeatUnlockMenuTiming(defiantMenu)
        Controller.Presentation.OpenTimedMessageSWF_KeyDismiss(defiantMenu, 30.0, 8.0, True, True)
        if Controller.Config.IsCharacterJournalEnabled()
            Controller.Journal.LogDefiantSoulFeatForGuid(player, guid, Controller.Death.GetTotalDeaths(player, guid))
        endif
        IronSoulNative.DataFlushIfDirty()
        return True
    endif

    IronSoulNative.DataFlushIfDirty()
    LogTiers(IronSoulConfig.LOG_INFO(), "HandleFeats: Defiant Soul feat tracked silently (DefiantSoul=0)")
    ClearFeatUnlockTiming()
    return False
EndFunction

Function PromoteFromSoulFeat(Actor player, String guid, Int desiredTier)
    Controller.Persistence.SetGuidInt(player, guid, soulTierIndex, desiredTier, True)
EndFunction

Function ShowNormalSoulFeatMessageForTier(Actor player, String guid, Int curTier)
    if curTier == TIER_DEVOUR
        ShowTierUnlockMessageIfNeeded(player, guid, curTier, tierMsgShownDevour, "HandleFeats: Showing Devour Soul feat unlock message (one-shot); locking out lower-tier messages")
    elseif curTier == TIER_PLATINUM
        ShowTierUnlockMessageIfNeeded(player, guid, curTier, tierMsgShownPlatinum, "HandleFeats: Showing Platinum Soul feat unlock message (one-shot); locking out lower-tier messages")
    elseif curTier == TIER_EBON
        ShowTierUnlockMessageIfNeeded(player, guid, curTier, tierMsgShownEbon, "HandleFeats: Showing Ebon Soul feat unlock message (one-shot); locking out Silver/Gold messages")
    elseif curTier == TIER_GOLD
        ShowTierUnlockMessageIfNeeded(player, guid, curTier, tierMsgShownGold, "HandleFeats: Showing Gold Soul feat unlock message (one-shot)")
    elseif curTier == TIER_SILVER
        ShowTierUnlockMessageIfNeeded(player, guid, curTier, tierMsgShownSilver, "HandleFeats: Showing Silver Soul feat unlock message (one-shot)")
    endif
EndFunction

Function ShowTierUnlockMessageIfNeeded(Actor player, String guid, Int curTier, String shownKey, String logMessage)
    if Controller.Persistence.GetGuidInt(player, guid, shownKey, 0) == 1
        ClearFeatUnlockTiming()
        return
    endif
    LogTiers(IronSoulConfig.LOG_INFO(), logMessage)
    String unlockMenu = ResolveSoulFeatUnlockMenu(player, guid, curTier, True)
    Int cursorToken = IronSoulNative.BeginCursorSuppress()
    LogFeatUnlockMenuTiming(unlockMenu)
    Controller.Presentation.OpenTimedMessageSWF_KeyDismiss(unlockMenu, 30.0, 8.0, False, True)
    MaybePlayLuckImprovedAfterTierUnlock(player)
    IronSoulNative.EndCursorSuppress(cursorToken)
    Controller.Presentation.RestoreMusic()
EndFunction

Function MaybePlayLuckImprovedAfterTierUnlock(Actor player)
    if !player
        return
    endif
    if !Controller.Config.IsSoulFeatsEnabled()
        return
    endif
    if !Controller.Respawn || !Controller.Respawn.IsRuntimeAvailable()
        return
    endif
    if !Controller.Luck || !Controller.Luck.IsRuntimeAvailable()
        return
    endif

    Int cursorToken = IronSoulNative.BeginCursorSuppress()
    UI.CloseCustomMenu()
    IronSoulNative.RefreshCursorSuppress()
    UI.OpenCustomMenu("luck_improved", 0)
    IronSoulNative.RefreshCursorSuppress()
    Controller.SFX.Play(Controller.SFX.SFXLuckImproved, player)
    Utility.WaitMenuMode(3.0)
    UI.CloseCustomMenu()
    IronSoulNative.EndCursorSuppress(cursorToken)
EndFunction

String Function ResolveSoulFeatUnlockMenu(Actor player, String guid, Int soulTier, Bool consumeState = False)
    if !HasCoreRuntime() || !player || guid == ""
        return ""
    endif

    Int unlockTier = NormalizeSoulFeatUnlockTier(soulTier)
    Int platinumVariant = 0
    Int ebonVariant = 0

    if unlockTier == TIER_DEVOUR
        if consumeState
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownSilver, 1, True)
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownGold, 1, True)
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownEbon, 1, True)
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownPlatinum, 1, True)
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownDevour, 1, True)
        endif

    elseif unlockTier == TIER_PLATINUM
        if consumeState
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownEbon, 1, True)
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownGold, 1, True)
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownSilver, 1, True)
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownPlatinum, 1, True)
        endif

        platinumVariant = Controller.Persistence.GetGuidInt(player, guid, platinumFeatVariant, 0)
        if platinumVariant == 0
            Int molagFlagV = Controller.Persistence.GetGuidInt(player, guid, molagBalKilled, 0)
            if molagFlagV == 1
                platinumVariant = 1
            else
                platinumVariant = 2
            endif
            if consumeState
                Controller.Persistence.SetGuidInt(player, guid, platinumFeatVariant, platinumVariant, True)
            endif
        endif

    elseif unlockTier == TIER_EBON
        if consumeState
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownGold, 1, True)
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownSilver, 1, True)
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownEbon, 1, True)
        endif

        ebonVariant = Controller.Persistence.GetGuidInt(player, guid, ebonFeatVariant, 0)
        if ebonVariant == 0
            Int alduinFlagV = Controller.Persistence.GetGuidInt(player, guid, alduinKilled, 0)
            if alduinFlagV == 1
                ebonVariant = 1
            else
                ebonVariant = 2
            endif
            if consumeState
                Controller.Persistence.SetGuidInt(player, guid, ebonFeatVariant, ebonVariant, True)
            endif
        endif

    elseif unlockTier == TIER_GOLD
        if consumeState
            Controller.Persistence.SetGuidInt(player, guid, tierMsgShownGold, 1, True)
        endif
    elseif consumeState
        Controller.Persistence.SetGuidInt(player, guid, tierMsgShownSilver, 1, True)
    endif

    String menu = IronSoulUI.ResolveSoulFeatUnlockMenuFromFacts(unlockTier, Controller.Config.IsSoulBonusEnabled(), Controller.Config.IsDragonSoulReviveEnabled(), platinumVariant, ebonVariant)
    if unlockTier == TIER_PLATINUM
        LogTiers(IronSoulConfig.LOG_INFO(), "ResolveSoulFeatUnlockMenu: Platinum variant=" + platinumVariant + " menu=" + menu + " consumeState=" + consumeState)
    elseif unlockTier == TIER_EBON
        LogTiers(IronSoulConfig.LOG_INFO(), "ResolveSoulFeatUnlockMenu: Ebon variant=" + ebonVariant + " menu=" + menu + " consumeState=" + consumeState)
    endif
    return menu
EndFunction

String Function ResolveDefiantRestoreMenu(Int targetTier)
    if targetTier == TIER_DEVOUR
        return "0_defiant_restore_transitiondevour"
    elseif targetTier == TIER_PLATINUM
        return "0_defiant_restore_transitionplatinum"
    elseif targetTier == TIER_EBON
        return "0_defiant_restore_transitionebon"
    elseif targetTier == TIER_GOLD
        return "0_defiant_restore_transitiongold"
    elseif targetTier == TIER_SILVER
        return "0_defiant_restore_transitionsilver"
    endif
    return "0_defiant_restore_transitioniron"
EndFunction


; --- Boss Latches ---
; ====================

Function PollBossDefeatLatches(Actor player, String guid)
    Int curTier = GetCurrentTier(player, guid)

    if Controller.Config.IsSoulFeatsEnabled() || curTier == TIER_DEFIANT
        if curTier < TIER_PLATINUM
            Int molagFlag = Controller.Persistence.GetGuidInt(player, guid, molagBalKilled, 0)
            if molagFlag != 1
                IsMolagBalDefeatedVigilant(player, guid)
            endif

            Int miraakFlag = Controller.Persistence.GetGuidInt(player, guid, miraakKilled, 0)
            if miraakFlag != 1
                IsMiraakDefeated(player, guid)
            endif
        endif

        if curTier < TIER_EBON
            Int alduinFlag = Controller.Persistence.GetGuidInt(player, guid, alduinKilled, 0)
            if alduinFlag != 1
                IsAlduinDefeated(player, guid)
            endif

            Int harkonFlag = Controller.Persistence.GetGuidInt(player, guid, harkonKilled, 0)
            if harkonFlag != 1
                IsHarkonDefeated(player, guid)
            endif
        endif
    endif
EndFunction

Bool Function IsMiraakDefeated(Actor player, String guid)
    Int flag = Controller.Persistence.GetGuidInt(player, guid, miraakKilled, 0)
    if flag == 1
        return True
    endif

    if DLC2MQ06
        if DLC2MQ06.GetStageDone(580) || DLC2MQ06.GetStageDone(600) || DLC2MQ06.IsCompleted()
            LogTiers(IronSoulConfig.LOG_INFO(), "miraakKilled: latched TRUE (one-shot)")
            Controller.Persistence.SetGuidInt(player, guid, miraakKilled, 1, True)
            HandleProgressionRelevantChange(player, guid)
            return True
        endif
    endif

    return False
EndFunction

Bool Function IsAlduinDefeated(Actor player, String guid)
    Int flag = Controller.Persistence.GetGuidInt(player, guid, alduinKilled, 0)
    if flag == 1
        return True
    endif

    if MQ305
        if MQ305.GetStage() >= 190
            LogTiers(IronSoulConfig.LOG_INFO(), "alduinKilled: latched TRUE (one-shot)")
            Controller.Persistence.SetGuidInt(player, guid, alduinKilled, 1, True)
            HandleProgressionRelevantChange(player, guid)
            return True
        endif
    endif

    return False
EndFunction

Bool Function IsHarkonDefeated(Actor player, String guid)
    Int flag = Controller.Persistence.GetGuidInt(player, guid, harkonKilled, 0)
    if flag == 1
        return True
    endif

    if DLC1VQ08
        if DLC1VQ08.GetStage() >= 200
            LogTiers(IronSoulConfig.LOG_INFO(), "harkonKilled: latched TRUE (one-shot)")
            Controller.Persistence.SetGuidInt(player, guid, harkonKilled, 1, True)
            HandleProgressionRelevantChange(player, guid)
            return True
        endif
    endif

    return False
EndFunction

Bool Function IsMolagBalDefeatedVigilant(Actor player, String guid)
    Int flag = Controller.Persistence.GetGuidInt(player, guid, molagBalKilled, 0)
    if flag == 1
        return True
    endif

    if !_vigilantMq08Tried
        _vigilantMq08Tried = True
        _vigilantMq08Cache = Game.GetFormFromFile(0x0000EA8A, "Vigilant.esm") as Quest
    endif

    if _vigilantMq08Cache
        if _vigilantMq08Cache.GetStage() >= 310
            LogTiers(IronSoulConfig.LOG_INFO(), "molagBalKilled: latched TRUE (one-shot)")
            Controller.Persistence.SetGuidInt(player, guid, molagBalKilled, 1, True)
            HandleProgressionRelevantChange(player, guid)
            return True
        endif
    endif

    return False
EndFunction


; --- UI / SFX ---
; ================

Function MaybeNotifyDragonSoulIncrease(Actor player, String guid, Int soulTier, Int soulsTotal)
    if !HasCoreRuntime() || !Controller.Config.IsDragonSoulNotificationEnabled()
        return
    endif

    Debug.Notification(IronSoulNative.TextFormat1("Notification.DragonSoulsTotal", "total", "" + soulsTotal))
EndFunction

Bool Function CanPlayTierSFX(Sound sfx)
    if !HasCoreRuntime() || !sfx
        return False
    endif
    if !IronSoulSFX.CanPlaySFX(Controller.Config.IsSFXEnabled(), Controller.Config.IsUninstallMode(), Controller.IsModDisabled())
        return False
    endif

    if sfx == SFXDefiantTransition
        return Controller.Config.IsDefiantTransitionSFXEnabled()
    elseif sfx == SFXCHIMTransition
        return Controller.Config.IsCHIMTransitionSFXEnabled()
    elseif sfx == SFXDefiantRestore
        return Controller.Config.IsDefiantRestoreSFXEnabled()
    elseif sfx == SFXSunderheartAbsorb
        return Controller.Config.IsSunderheartAbsorbSFXEnabled()
    elseif sfx == SFXFeatUnlock
        return Controller.Config.IsFeatUnlockSFXEnabled()
    endif

    return False
EndFunction

Function PlayTierSFX(Sound sfx, Actor source)
    if !source
        return
    endif
    if CanPlayTierSFX(sfx)
        IronSoulNative.AudioPlay(sfx, source, 1.0, "tier-sfx")
    endif
EndFunction

Int Function PlayTierSFXInstance(Sound sfx, Actor source)
    if !source
        return -1
    endif
    if CanPlayTierSFX(sfx)
        return IronSoulNative.AudioPlayTracked(sfx, source, 1.0, "tier-sfx-tracked")
    endif
    return -1
EndFunction

Function PlayCHIMTransitionSWF(Int soulTierTD, Bool restoreMusicAfterIntro = True)
    String menu = IronSoulUI.ResolveCHIMTransitionMenu(soulTierTD)

    if menu == ""
        LogTiers(IronSoulConfig.LOG_ERR(), "PlayCHIMTransitionSWF: Transition menu resolved empty")
        return
    endif

    Actor player = Game.GetPlayer()

    Int transitionSFXInstance = -1
    Float transitionSFXStartedAt = 0.0
    if restoreMusicAfterIntro
        transitionSFXStartedAt = Utility.GetCurrentRealTime()
        transitionSFXInstance = PlayTierSFXInstance(SFXCHIMTransition, player)
        Controller.Presentation.OpenTimedMessageSWF_KeyDismissTrackedSFX(menu, CHIM_TRANSITION_SECONDS, TRANSITION_KEY_DISMISS_SECONDS, True, transitionSFXInstance, transitionSFXStartedAt, CHIM_TRANSITION_SECONDS)
    else
        PlayTierSFX(SFXCHIMTransition, player)
        Controller.Presentation.OpenTimedMessageSWF_KeyDismiss(menu, CHIM_TRANSITION_SECONDS, TRANSITION_KEY_DISMISS_SECONDS, False)
    endif
EndFunction

Function PlayDefiantTransitionSWF(Int soulTierTD, Bool restoreMusicAfterIntro = True)
    String menu = IronSoulUI.ResolveDefiantTransitionMenu(soulTierTD, Controller.Config.IsSoulBonusEnabled(), Controller.Config.IsSoulFatigueEnabled())

    if menu == ""
        LogTiers(IronSoulConfig.LOG_ERR(), "PlayDefiantTransitionSWF: Transition menu resolved empty")
        return
    endif

    Actor player = Game.GetPlayer()

    Int transitionSFXInstance = -1
    Float transitionSFXStartedAt = 0.0
    if restoreMusicAfterIntro
        transitionSFXStartedAt = Utility.GetCurrentRealTime()
        transitionSFXInstance = PlayTierSFXInstance(SFXDefiantTransition, player)
        Controller.Presentation.OpenTimedMessageSWF_KeyDismissTrackedSFX(menu, DEFIANT_TRANSITION_SECONDS, TRANSITION_KEY_DISMISS_SECONDS, True, transitionSFXInstance, transitionSFXStartedAt, DEFIANT_TRANSITION_SECONDS)
    else
        PlayTierSFX(SFXDefiantTransition, player)
        Controller.Presentation.OpenTimedMessageSWF_KeyDismiss(menu, DEFIANT_TRANSITION_SECONDS, TRANSITION_KEY_DISMISS_SECONDS, False)
    endif
EndFunction

Function PlayDefiantRestoreSWF(Actor player, String restoreMenu, Bool restoreMusicAfterIntro = True)
    if restoreMenu == ""
        LogTiers(IronSoulConfig.LOG_ERR(), "PlayDefiantRestoreSWF: Restore menu resolved empty")
        return
    endif

    IronSoulNative.DataFlushIfDirty()

    PlayTierSFX(SFXDefiantRestore, player)
    Controller.Presentation.OpenTimedMessageSWF_KeyDismiss(restoreMenu, DEFIANT_RESTORE_SECONDS, DEFIANT_RESTORE_KEY_DISMISS_SECONDS, restoreMusicAfterIntro)
EndFunction


; --- Tier Policy Helpers ---
; ===========================

Bool Function IsCanonicalSoulTier(Int tier) Global
    if tier == 0 || tier == 9
        return True
    endif
    return tier >= 1 && tier <= 6
EndFunction

Bool Function IsNormalSoulTier(Int tier) Global
    return tier >= 1 && tier <= 6
EndFunction

Int Function GetSoulBonusOrdinal(Int tier) Global
    if !IsNormalSoulTier(tier)
        return 0
    endif
    return tier
EndFunction

Int Function NormalizeDefiantTrackedTier(Int tier) Global
    if tier < 1
        return 1
    elseif tier > 6
        return 6
    endif
    return tier
EndFunction

Int Function GetMaxLuckForTierAtLevel(Int tier, Int luckLevel) Global
    luckLevel = IronSoulConfig.ClampLuckLevel(luckLevel)
    if tier == 9
        return 100
    elseif tier == 0
        if luckLevel == 1
            return 25
        elseif luckLevel == 2
            return 30
        elseif luckLevel == 3
            return 35
        elseif luckLevel == 4
            return 40
        endif
        return 50
    elseif tier == 1
        if luckLevel == 1
            return 50
        elseif luckLevel == 2
            return 60
        elseif luckLevel == 3
            return 70
        elseif luckLevel == 4
            return 75
        endif
        return 80
    elseif tier == 2
        if luckLevel == 1
            return 55
        elseif luckLevel == 2
            return 65
        elseif luckLevel == 3
            return 75
        elseif luckLevel == 4
            return 80
        endif
        return 85
    elseif tier == 3
        if luckLevel == 1
            return 60
        elseif luckLevel == 2
            return 70
        elseif luckLevel == 3
            return 80
        elseif luckLevel == 4
            return 85
        endif
        return 90
    elseif tier == 4
        if luckLevel == 1
            return 65
        elseif luckLevel == 2
            return 75
        elseif luckLevel == 3
            return 85
        elseif luckLevel == 4
            return 90
        endif
        return 95
    elseif tier == 5
        if luckLevel == 1
            return 70
        elseif luckLevel == 2
            return 80
        elseif luckLevel == 3
            return 90
        elseif luckLevel == 4
            return 95
        endif
        return 99
    elseif tier == 6
        if luckLevel == 1
            return 75
        elseif luckLevel == 2
            return 85
        elseif luckLevel == 3
            return 95
        elseif luckLevel == 4
            return 99
        endif
        return 100
    endif
    return GetMaxLuckForTierAtLevel(1, luckLevel)
EndFunction

Int Function GetHighestEligibleNormalSoulTier(Int soulsObtained, Bool molagKilled, Bool miraakKilled, Bool alduinKilled, Bool harkonKilled) Global
    if soulsObtained >= 50
        return 6
    endif
    if molagKilled || miraakKilled
        return 5
    endif
    if alduinKilled || harkonKilled
        return 4
    endif
    if soulsObtained >= 20
        return 3
    elseif soulsObtained >= 10
        return 2
    endif
    return 1
EndFunction

Int Function ResolveSoulTierTargetFromFacts(Int resolveMode, Int deaths, Int liveTier, Int highestEligibleNormalTier, Int ironSoulMaxLives, Int defiantSoulMaxLives, Bool soulFeatsEnabled, Bool defiantSoulEnabled, Bool permadeathEnabled, Bool manualTierOverrideActive, Bool chimEnteredByConsole, Bool defiantFeatUnlocked) Global
    if resolveMode == 1
        if !soulFeatsEnabled
            return 1
        endif
        if deaths >= ironSoulMaxLives
            return 1
        endif
        return highestEligibleNormalTier

    elseif resolveMode == 2
        if liveTier == 6
            return 6
        elseif liveTier == 9 && !manualTierOverrideActive && !chimEnteredByConsole
            return 9
        elseif liveTier == 0
            return 0
        endif

        Bool defiantBlockedAtIronCap = False
        if defiantFeatUnlocked && deaths >= ironSoulMaxLives
            if defiantSoulEnabled
                if !permadeathEnabled && deaths >= defiantSoulMaxLives
                    return 9
                endif
                return 0
            endif
            defiantBlockedAtIronCap = True
        endif

        if !permadeathEnabled && liveTier != 6 && deaths >= ironSoulMaxLives && !defiantBlockedAtIronCap
            return 9
        endif

        return ResolveSoulTierTargetFromFacts(1, deaths, liveTier, highestEligibleNormalTier, ironSoulMaxLives, defiantSoulMaxLives, soulFeatsEnabled, defiantSoulEnabled, permadeathEnabled, manualTierOverrideActive, chimEnteredByConsole, defiantFeatUnlocked)

    elseif resolveMode == 3
        if liveTier == 6
            if !permadeathEnabled && deaths >= ironSoulMaxLives
                return 9
            endif
            return 6
        endif

        Bool chimActive = (liveTier == 9)
        Bool defiantActive = (liveTier == 0)

        if deaths == ironSoulMaxLives && !defiantActive && !chimActive
            if defiantFeatUnlocked
                if defiantSoulEnabled
                    return 0
                endif
                return liveTier
            endif
        endif

        if !permadeathEnabled && liveTier != 6 && !chimActive
            Bool defiantBlockedAtIronCapTD = False
            if !defiantActive && deaths == ironSoulMaxLives
                defiantBlockedAtIronCapTD = (defiantFeatUnlocked && !defiantSoulEnabled)
            endif
            Bool chimAtIronCap = (!defiantActive && deaths == ironSoulMaxLives && !defiantBlockedAtIronCapTD)
            Bool chimAtDefiantCap = (defiantActive && deaths == defiantSoulMaxLives)
            if chimAtIronCap || chimAtDefiantCap
                return 9
            endif
        endif

        return liveTier

    elseif resolveMode == 4
        if liveTier == 6
            if !permadeathEnabled && deaths >= ironSoulMaxLives
                return 9
            endif
            return 6
        endif

        Bool chimActiveLC = (liveTier == 9)
        Bool defiantActiveLC = (liveTier == 0)

        Bool defiantBlockedAtIronCapLC = False
        if !defiantActiveLC && !chimActiveLC && deaths >= ironSoulMaxLives
            if defiantFeatUnlocked
                if defiantSoulEnabled
                    return 0
                endif
                defiantBlockedAtIronCapLC = True
            endif
        endif

        if permadeathEnabled || chimActiveLC || liveTier == 6
            return liveTier
        endif

        if defiantActiveLC
            if deaths >= defiantSoulMaxLives
                return 9
            endif
            return liveTier
        endif

        if deaths < ironSoulMaxLives
            return liveTier
        endif

        if defiantBlockedAtIronCapLC
            return liveTier
        endif

        return 9
    endif

    return 1
EndFunction

String Function SoulTierLabel(Int tier) Global
    if tier == 0
        return "Defiant"
    elseif tier == 1
        return "Iron"
    elseif tier == 2
        return "Silver"
    elseif tier == 3
        return "Gold"
    elseif tier == 4
        return "Ebon"
    elseif tier == 5
        return "Platinum"
    elseif tier == 6
        return "Devour"
    elseif tier == 9
        return "CHIM"
    endif
    return "Iron"
EndFunction

Int Function NormalizeSoulFeatUnlockTier(Int tier) Global
    if IsNormalSoulTier(tier) && tier >= 2
        return tier
    endif
    return 2
EndFunction
