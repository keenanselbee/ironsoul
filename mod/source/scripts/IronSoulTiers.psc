Scriptname IronSoulTiers extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()
; HasPersistenceRuntime()
; LogTiers()
; LogTiersSnapshot()

; --- Component Runtime ---
; -------------------------
; ResetTransientState()
; SetPendingDragonSoulsRebaseline()
; RemoveTrackedData()
; Tick()
; Heartbeat()
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
; TryResetFromDefiant()
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
; TryScheduleFeats()
; ShouldScheduleShownTierMessage()
; HandleFeats()
; HandleDefiantFeatUnlock()
; PromoteFromSoulFeat()
; ShowNormalSoulFeatMessageForTier()
; ShowTierUnlockMessageIfNeeded()
; MaybePlayDeathsPurgedAfterReset()
; MaybePlayLuckImprovedAfterTierUnlock()
; ResolveSoulFeatUnlockMenu()
; ResolveSoulFeatUnlockJournalEntry()
; ResolveDefiantResetJournalEntry()
; ResolveDefiantResetEndingMenu()

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
; FadeMusicForTransitionSequence()
; CanPlayTierSFX()
; PlayTierSFX()
; PlayTierSFXInstance()
; PlayCHIMTransitionMessageSequenceSWF()
; PlayDefiantTransitionMessageSequenceSWF()
; PlayDefiantResetMessageSequenceSWF()

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

; --- Feat Journal Helpers ---
; ----------------------------
; ResolveSoulFeatUnlockJournalBase()
; ResolveDefiantResetJournalBase()


IronSoulController Property Controller Auto

; Boss quest latches
Quest Property MQ305 Auto
Quest Property DLC1VQ08 Auto
Quest Property DLC2MQ06 Auto

; Tier-specific UI SFX
Sound Property SFXDefiantTransition Auto
Sound Property SFXCHIMTransition Auto
Sound Property SFXDefiantReset Auto
Sound Property SFXHeartstoneAbsorb Auto
Sound Property SFXFeatDefiant Auto
Sound Property SFXFeatSilver Auto
Sound Property SFXFeatGold Auto
Sound Property SFXFeatEbon Auto
Sound Property SFXFeatPlatinum Auto
Sound Property SFXFeatDevour Auto

; Soul / feats
String Property soulTierIndex              = "IS_2204" AutoReadOnly
String Property manualTierOverrideActive   = "IS_2719" AutoReadOnly
String Property ebonFeatVariant            = "IS_4520" AutoReadOnly
String Property platinumFeatVariant        = "IS_4779" AutoReadOnly
String Property dragonSoulsTotal           = "IS_9646" AutoReadOnly
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

Float DEFIANT_TRANSITION_SFX_SECONDS = 72.54
Float CHIM_TRANSITION_SFX_SECONDS = 72.54

Bool _pendingDragonSoulsRebaseline = False
Bool _pendingFeats = False
Float _featsAt = 0.0
Sound _pendingFeatUnlockSFX = None
Float _featUnlockSFXAt = 0.0

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

Function LogTiers(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("Tiers", level, msg, suppressNotify)
        return
    endif

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [" + levelText + "] [Tiers] " + msg)
EndFunction

Function LogTiersSnapshot(Int level, String msg)
    if Controller && Controller.Config
        Controller.Config.LogComponentSnapshot("Tiers", level, msg)
        return
    endif

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [Snapshot] [" + levelText + "] [Tiers] " + msg)
EndFunction


; --- Component Runtime ---
; =========================

Function ResetTransientState()
    _pendingDragonSoulsRebaseline = False
    _pendingFeats = False
    _featsAt = 0.0
    _pendingFeatUnlockSFX = None
    _featUnlockSFXAt = 0.0
    _vigilantMq08Cache = None
    _vigilantMq08Tried = False
EndFunction

Function SetPendingDragonSoulsRebaseline(Bool pending)
    _pendingDragonSoulsRebaseline = pending
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
            return
        endif

        Int delta = curSouls - lastSouls

        if Controller.Respawn
            Controller.Respawn.UpdatePlayerProtectionState(player)
        endif

        Int accepted = 0
        if delta > 0
            if !Controller.Config.IsDragonSoulAnticheatEnabled()
                accepted = delta
            else
                if delta > 3 && Controller.Config.IsDragonSoulIncreaseNotificationEnabled()
                    Debug.Notification("[Iron Soul] Unusual Dragon Soul increase detected (D=" + delta + ")")
                endif
                if delta <= 3
                    accepted = delta
                endif
            endif
        endif

        if accepted > 0
            Int soulsTotal = GetDragonSoulsTotal(player, guid)
            Int j = 0
            while j < accepted
                soulsTotal += 1
                Controller.Persistence.SetGuidInt(player, guid, dragonSoulsTotal, soulsTotal, True)

                Int liveTierNow = GetCurrentTier(player, guid)
                MaybeNotifyDragonSoulIncrease(player, guid, liveTierNow, soulsTotal)

                Controller.Journal.LogEventForGuid(player, guid, "Absorbed a Dragon's Soul. Dragon Souls Total: " + soulsTotal + ".")
                HandleProgressionRelevantChange(player, guid)

                j += 1
            endwhile
        endif

        RebaselineDragonSoulsLastSeen(player, guid, curSouls)
    endif

    PollBossDefeatLatches(player, guid)
    TryScheduleFeats(player)
EndFunction

Bool Function RequiresFastPolling()
    return _pendingFeatUnlockSFX != None
EndFunction

Function LogSnapshot()
    if !HasCoreRuntime()
        return
    endif

    if !MQ305
        LogTiersSnapshot(IronSoulConfig.LOG_ERR(), "MISSING PROPERTY: MQ305 (Quest)")
    endif
    if !DLC1VQ08
        LogTiersSnapshot(IronSoulConfig.LOG_ERR(), "MISSING PROPERTY: DLC1VQ08 (Quest)")
    endif
    if !DLC2MQ06
        LogTiersSnapshot(IronSoulConfig.LOG_ERR(), "MISSING PROPERTY: DLC2MQ06 (Quest)")
    endif

    Actor p = Game.GetPlayer()
    if p
        String guid = Controller.Identity.GetTickGuid(p)
        if guid != ""
            Int tier = GetCurrentTier(p, guid)
            Int totalDeaths = Controller.Death.GetTotalDeaths(p, guid)
            if tier == TIER_DEFIANT
                LogTiersSnapshot(IronSoulConfig.LOG_INFO(), "SoulTier=" + tier + " DefiantTrackedTier=" + GetDefiantTrackedTier(p, guid) + " TotalDeaths=" + totalDeaths + " DragonSoulsTotal=" + GetDragonSoulsTotal(p, guid))
            else
                LogTiersSnapshot(IronSoulConfig.LOG_INFO(), "SoulTier=" + tier + " TotalDeaths=" + totalDeaths + " DragonSoulsTotal=" + GetDragonSoulsTotal(p, guid))
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
        Controller.Globals.SyncLuck(player, guid)
    endif
EndFunction

Int Function GetDragonSoulsTotal(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return 0
    endif
    return Controller.Persistence.GetGuidInt(player, guid, dragonSoulsTotal, 0)
EndFunction

String Function SetDragonSoulsTotalFromConsole(Actor player, String guid, Int totalValue)
    if !HasCoreRuntime() || !player || guid == ""
        return "Error: IronSoulTiers is not available."
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
    IronSoulNative.DataFlushIfDirty()

    return "SoulsTotal set to " + clampedTotal + "."
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
        if Controller.Config.IsSoulFeatsEnabled() && Controller.Config.IsDeathResetEnabled()
            TryResetFromDefiant(player, guid)
        endif
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

Function TryResetFromDefiant(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif
    if GetCurrentTier(player, guid) != TIER_DEFIANT
        return
    endif
    if !Controller.Config.IsSoulFeatsEnabled() || !Controller.Config.IsDeathResetEnabled()
        return
    endif

    Int trackedTier = GetDefiantTrackedTier(player, guid)
    Int targetTier = GetHighestEligibleNormalTierForPlayer(player, guid, GetDragonSoulsTotal(player, guid))
    Int deathsBeforeReset = Controller.Death.GetCurrentDeathCount(player, guid)
    if targetTier <= trackedTier || targetTier < TIER_SILVER
        return
    endif

    String endingMenu = ResolveDefiantResetEndingMenu(player, guid, targetTier, True)

    Controller.Persistence.SetGuidInt(player, guid, soulTierIndex, targetTier, True)
    Controller.Death.SetCurrentDeathCount(player, guid, 0)
    SetManualTierOverrideActive(player, guid, False)
    ClearDefiantState(player, guid)
    SyncTierLuckState(player, guid)
    SyncTierPresentationState(player, guid)
    SyncTierDynamicAssets(targetTier)
    SyncTierGlobalMirrors(player, guid)

    if Controller.Config.IsCharacterJournalEnabled()
        Controller.Journal.LogEventForGuid(player, guid, ResolveDefiantResetJournalEntry(player, guid, targetTier))
    endif

    IronSoulNative.DataFlushIfDirty()

    PlayDefiantResetMessageSequenceSWF(player, endingMenu, deathsBeforeReset, True)
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
        return "Error: IronSoulTiers is not available."
    endif
    if !IsCanonicalSoulTier(tierValue)
        return "Error: tier must be one of 0, 1, 2, 3, 4, 5, 6, or 9."
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
    String msg = "Tier set to " + tierValue + " (" + SoulTierLabel(tierValue) + ")."
    if manualTierOverride
        if parsedForce == 1
            msg = msg + " Manual override is active until ResetTier or a progression transition reclaims tier control."
        else
            msg = msg + " Add f or force to is st to force manual override. Use is rt or ResetTier to enable normal functionality again. Manual override remains active until ResetTier or a progression transition reclaims tier control."
        endif
    elseif parsedForce == 0
        msg = msg + " Add f or force to is st to force manual override. Use is rt or ResetTier to enable normal functionality again."
    endif
    return msg
EndFunction

String Function ResetTierFromConsole(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return "Error: IronSoulTiers is not available."
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

    return "Tier reset to " + targetTier + " (" + SoulTierLabel(targetTier) + "). Auto-upgrade restored."
EndFunction


; --- Soul Feats ---
; ==================

Function ScheduleFeatUnlockSFX(Sound sfx, Float nowRT)
    if !sfx
        _pendingFeatUnlockSFX = None
        _featUnlockSFXAt = 0.0
        return
    endif

    _pendingFeatUnlockSFX = sfx
    _featUnlockSFXAt = nowRT + 2.2
EndFunction

Function ScheduleFeatCheck(Float nowRT, Sound sfx = None, Bool scheduleSFX = True)
    _pendingFeats = True
    if _featsAt < (nowRT + 4.0)
        _featsAt = nowRT + 4.0
    endif
    if scheduleSFX
        ScheduleFeatUnlockSFX(sfx, nowRT)
    endif
EndFunction

Function HandleFeatUnlockSFX(Actor player)
    if !_pendingFeatUnlockSFX
        return
    endif
    if Utility.GetCurrentRealTime() < _featUnlockSFXAt
        return
    endif
    if !player
        return
    endif

    Sound sfx = _pendingFeatUnlockSFX
    _pendingFeatUnlockSFX = None
    _featUnlockSFXAt = 0.0
    PlayTierSFX(sfx, player)
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
            ScheduleFeatCheck(nowRT, SFXFeatDefiant)
        else
            ScheduleFeatCheck(nowRT, None, False)
        endif
        return
    endif

    if Controller.Config.IsSoulFeatsEnabled()
        Int desiredTier = GetHighestEligibleSoulFeatTier(player, guid, deaths, soulsObtained)

        if !manualTierOverride && desiredTier > curTier
            ScheduleFeatCheck(nowRT, IronSoulSFX.ResolveSoulFeatUnlockSFX(desiredTier, SFXFeatSilver, SFXFeatGold, SFXFeatEbon, SFXFeatPlatinum, SFXFeatDevour))
            return
        endif

        if manualTierOverride
            return
        endif

        if ShouldScheduleShownTierMessage(player, guid, curTier)
            ScheduleFeatCheck(nowRT, IronSoulSFX.ResolveSoulFeatUnlockSFX(curTier, SFXFeatSilver, SFXFeatGold, SFXFeatEbon, SFXFeatPlatinum, SFXFeatDevour))
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
    if nowRT < _featsAt
        return
    endif

    if Utility.IsInMenuMode() || !player || player.IsDead() || player.IsBleedingOut()
        _featsAt = nowRT + 1.0
        return
    endif

    String guid = Controller.Identity.GetTickGuid(player)
    if guid == ""
        _featsAt = nowRT + 1.0
        return
    endif

    _pendingFeats = False

    Int deaths = Controller.Death.GetCurrentDeathCount(player, guid)
    Int soulsObtained = GetDragonSoulsTotal(player, guid)
    Int curTier = GetCurrentTier(player, guid)
    Bool manualTierOverride = IsManualTierOverrideActive(player, guid)
    Bool deathsPurgedThisPass = False

    if curTier == TIER_CHIM || curTier == TIER_DEFIANT
        return
    endif

    if HandleDefiantFeatUnlock(player, guid, deaths, soulsObtained)
        return
    endif

    if Controller.Config.IsSoulFeatsEnabled()
        Int desiredTier = GetHighestEligibleSoulFeatTier(player, guid, deaths, soulsObtained)

        if !manualTierOverride && desiredTier > curTier
            Bool resetDeaths = Controller.Config.IsDeathResetEnabled()
            deathsPurgedThisPass = PromoteFromSoulFeat(player, guid, desiredTier, deaths, resetDeaths)
            curTier = desiredTier
        endif

        if manualTierOverride
            return
        endif

        ShowNormalSoulFeatMessageForTier(player, guid, curTier, deathsPurgedThisPass, deaths)
    endif
EndFunction

Bool Function HandleDefiantFeatUnlock(Actor player, String guid, Int deaths, Int soulsObtained)
    Bool defiantEligible = (soulsObtained >= 1 && deaths < IRON_SOUL_MAX_LIVES)
    Int defFeat = Controller.Persistence.GetGuidInt(player, guid, defiantFeatUnlocked, 0)
    if !defiantEligible || defFeat == 1
        return False
    endif

    Controller.Persistence.SetGuidInt(player, guid, defiantFeatUnlocked, 1, True)
    if Controller.Config.IsDefiantSoulEnabled()
        Bool deathsPurgedThisPass = False
        if Controller.Config.IsDeathResetEnabled()
            Controller.Death.SetCurrentDeathCount(player, guid, 0)
            deathsPurgedThisPass = deaths > 0
        endif
        IronSoulNative.DataFlushIfDirty()
        LogTiers(IronSoulConfig.LOG_INFO(), "HandleFeats: Defiant Soul feat unlocked (eligibility met); showing unlock message")
        if Controller.Config.IsCharacterJournalEnabled()
            Controller.Journal.LogEventForGuid(player, guid, IronSoulJournal.AppendTotalDeaths("Soul Feat achieved: Defiant Soul unlocked.", Controller.Death.GetTotalDeaths(player, guid)))
        endif
        Controller.Presentation.OpenTimedMessageSWF_KeyDismiss(IronSoulUI.ResolveDefiantFeatUnlockMenu(Controller.Config.IsSoulFatigueEnabled()), 30.0, 8.0)
        if deathsPurgedThisPass
            MaybePlayDeathsPurgedAfterReset(player, deaths)
        endif
        return True
    endif

    IronSoulNative.DataFlushIfDirty()
    LogTiers(IronSoulConfig.LOG_INFO(), "HandleFeats: Defiant Soul feat tracked silently (DefiantSoul=0)")
    return False
EndFunction

Bool Function PromoteFromSoulFeat(Actor player, String guid, Int desiredTier, Int deaths, Bool resetDeaths)
    Bool deathsPurgedThisPass = False

    Controller.Persistence.SetGuidInt(player, guid, soulTierIndex, desiredTier, True)
    if resetDeaths
        Controller.Death.SetCurrentDeathCount(player, guid, 0)
        deathsPurgedThisPass = deaths > 0
    endif
    SyncTierLuckState(player, guid)

    SyncTierDynamicAssets(desiredTier)

    if Controller.Config.IsCharacterJournalEnabled()
        String journalEntry = ResolveSoulFeatUnlockJournalEntry(player, guid, desiredTier, resetDeaths)
        if journalEntry != ""
            Controller.Journal.LogEventForGuid(player, guid, journalEntry)
        endif
    endif

    IronSoulNative.DataFlushIfDirty()
    SyncTierPresentationState(player, guid)
    SyncTierGlobalMirrors(player, guid)

    return deathsPurgedThisPass
EndFunction

Function ShowNormalSoulFeatMessageForTier(Actor player, String guid, Int curTier, Bool deathsPurgedThisPass, Int deaths)
    if curTier == TIER_DEVOUR
        ShowTierUnlockMessageIfNeeded(player, guid, curTier, tierMsgShownDevour, deathsPurgedThisPass, deaths, "HandleFeats: Showing Devour Soul feat unlock message (one-shot); locking out lower-tier messages")
    elseif curTier == TIER_PLATINUM
        ShowTierUnlockMessageIfNeeded(player, guid, curTier, tierMsgShownPlatinum, deathsPurgedThisPass, deaths, "HandleFeats: Showing Platinum Soul feat unlock message (one-shot); locking out lower-tier messages")
    elseif curTier == TIER_EBON
        ShowTierUnlockMessageIfNeeded(player, guid, curTier, tierMsgShownEbon, deathsPurgedThisPass, deaths, "HandleFeats: Showing Ebon Soul feat unlock message (one-shot); locking out Silver/Gold messages")
    elseif curTier == TIER_GOLD
        ShowTierUnlockMessageIfNeeded(player, guid, curTier, tierMsgShownGold, deathsPurgedThisPass, deaths, "HandleFeats: Showing Gold Soul feat unlock message (one-shot)")
    elseif curTier == TIER_SILVER
        ShowTierUnlockMessageIfNeeded(player, guid, curTier, tierMsgShownSilver, deathsPurgedThisPass, deaths, "HandleFeats: Showing Silver Soul feat unlock message (one-shot)")
    endif
EndFunction

Function ShowTierUnlockMessageIfNeeded(Actor player, String guid, Int curTier, String shownKey, Bool deathsPurgedThisPass, Int deaths, String logMessage)
    if Controller.Persistence.GetGuidInt(player, guid, shownKey, 0) == 1
        return
    endif
    LogTiers(IronSoulConfig.LOG_INFO(), logMessage)
    Controller.Presentation.OpenTimedMessageSWF_KeyDismiss(ResolveSoulFeatUnlockMenu(player, guid, curTier, True), 30.0, 8.0)
    if deathsPurgedThisPass
        MaybePlayDeathsPurgedAfterReset(player, deaths)
    endif
    MaybePlayLuckImprovedAfterTierUnlock(player)
EndFunction

Function MaybePlayDeathsPurgedAfterReset(Actor player, Int deathsBeforeReset = 0)
    if !player || deathsBeforeReset <= 0
        return
    endif

    UI.CloseCustomMenu()
    UI.OpenCustomMenu("deathspurged", 0)
    PlayTierSFX(SFXHeartstoneAbsorb, player)
    Utility.WaitMenuMode(6.0)
    UI.CloseCustomMenu()
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

    UI.CloseCustomMenu()
    UI.OpenCustomMenu("luckimproved", 0)
    Controller.SFX.Play(Controller.SFX.SFXLuckSuccess, player)
    Utility.WaitMenuMode(3.0)
    UI.CloseCustomMenu()
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

String Function ResolveSoulFeatUnlockJournalEntry(Actor player, String guid, Int soulTier, Bool resetDeaths)
    Int molagFlagJ = Controller.Persistence.GetGuidInt(player, guid, molagBalKilled, 0)
    Int miraakFlagJ = Controller.Persistence.GetGuidInt(player, guid, miraakKilled, 0)
    Int alduinFlagJ = Controller.Persistence.GetGuidInt(player, guid, alduinKilled, 0)
    Int harkonFlagJ = Controller.Persistence.GetGuidInt(player, guid, harkonKilled, 0)
    String baseText = ResolveSoulFeatUnlockJournalBase(soulTier, molagFlagJ == 1, miraakFlagJ == 1, alduinFlagJ == 1, harkonFlagJ == 1, resetDeaths)
    if baseText == ""
        return ""
    endif
    return IronSoulJournal.AppendTotalDeaths(baseText, Controller.Death.GetTotalDeaths(player, guid))
EndFunction

String Function ResolveDefiantResetJournalEntry(Actor player, String guid, Int targetTier)
    if !player || guid == "" || targetTier < TIER_SILVER || !IsNormalSoulTier(targetTier)
        return ""
    endif

    Int molagFlagJ = Controller.Persistence.GetGuidInt(player, guid, molagBalKilled, 0)
    Int miraakFlagJ = Controller.Persistence.GetGuidInt(player, guid, miraakKilled, 0)
    Int alduinFlagJ = Controller.Persistence.GetGuidInt(player, guid, alduinKilled, 0)
    Int harkonFlagJ = Controller.Persistence.GetGuidInt(player, guid, harkonKilled, 0)
    String baseText = ResolveDefiantResetJournalBase(targetTier, molagFlagJ == 1, miraakFlagJ == 1, alduinFlagJ == 1, harkonFlagJ == 1)
    return IronSoulJournal.AppendTotalDeaths(baseText, Controller.Death.GetTotalDeaths(player, guid))
EndFunction

String Function ResolveDefiantResetEndingMenu(Actor player, String guid, Int targetTier, Bool consumeState = False)
    return ResolveSoulFeatUnlockMenu(player, guid, targetTier, consumeState)
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
    if !HasCoreRuntime() || !Controller.Config.IsDragonSoulIncreaseNotificationEnabled()
        return
    endif

    Debug.Notification("Dragon Souls Total: " + soulsTotal)
EndFunction

Function FadeMusicForTransitionSequence()
    Controller.Presentation.FadeMusicForTransitionSequence()
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
    elseif sfx == SFXDefiantReset
        return Controller.Config.IsDefiantResetSFXEnabled()
    elseif sfx == SFXHeartstoneAbsorb
        return Controller.Config.IsHeartstoneAbsorbSFXEnabled()
    elseif sfx == SFXFeatSilver || sfx == SFXFeatGold || sfx == SFXFeatEbon || sfx == SFXFeatPlatinum || sfx == SFXFeatDevour || sfx == SFXFeatDefiant
        return Controller.Config.IsFeatUnlockSFXEnabled()
    endif

    return False
EndFunction

Function PlayTierSFX(Sound sfx, Actor source)
    if !source
        return
    endif
    if CanPlayTierSFX(sfx)
        sfx.Play(source)
    endif
EndFunction

Int Function PlayTierSFXInstance(Sound sfx, Actor source)
    if !source
        return -1
    endif
    if CanPlayTierSFX(sfx)
        return sfx.Play(source)
    endif
    return -1
EndFunction

Function PlayCHIMTransitionMessageSequenceSWF(Int soulTierTD, Bool restoreMusicAfterIntro = True, String firstOpeningMenuOverride = "")
    String m0 = "0defianttransitionflash"
    String permadeathMenu = IronSoulUI.ResolvePermadeathMenu(soulTierTD)
    String m1First = firstOpeningMenuOverride
    if m1First == ""
        m1First = permadeathMenu
    endif
    String m1Second = m1First
    String m2 = IronSoulUI.ResolveCHIMTransitionMenu(soulTierTD)
    String m3 = "9chimintro"

    if m1First == "" || m1Second == "" || m2 == "" || m3 == ""
        LogTiers(IronSoulConfig.LOG_ERR(), "PlayCHIMTransitionMessageSequenceSWF: One or more menus resolved empty")
        return
    endif

    Actor player = Game.GetPlayer()

    UI.CloseCustomMenu()
    FadeMusicForTransitionSequence()

    Int transitionSFXInstance = -1
    Float transitionSFXStartedAt = 0.0
    if restoreMusicAfterIntro
        transitionSFXStartedAt = Utility.GetCurrentRealTime()
        transitionSFXInstance = PlayTierSFXInstance(SFXCHIMTransition, player)
    else
        PlayTierSFX(SFXCHIMTransition, player)
    endif

    UI.OpenCustomMenu(m1First, 0)
    Utility.WaitMenuMode(4.0)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.25)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m1Second, 0)
    Utility.WaitMenuMode(3.35)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.25)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m2, 0)
    Utility.WaitMenuMode(3.35)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.5)

    if restoreMusicAfterIntro
        Controller.Presentation.OpenTimedMessageSWF_KeyDismissTrackedSFX(m3, 30.0, 5.0, True, transitionSFXInstance, transitionSFXStartedAt, CHIM_TRANSITION_SFX_SECONDS)
    else
        Controller.Presentation.OpenTimedMessageSWF_KeyDismiss(m3, 30.0, 5.0, False)
    endif
EndFunction

Function PlayDefiantTransitionMessageSequenceSWF(Int soulTierTD, Bool restoreMusicAfterIntro = True)
    String m0 = "0defianttransitionflash"
    String m1 = IronSoulUI.ResolvePermadeathMenu(soulTierTD)
    String m2 = IronSoulUI.ResolveDefiantTransitionMenu(soulTierTD)
    String m3 = IronSoulUI.ResolveDefiantIntroMenu(Controller.Config.IsSoulBonusEnabled(), Controller.Config.IsSoulFatigueEnabled(), Controller.Config.IsDeathResetEnabled())

    if m1 == "" || m2 == "" || m3 == ""
        LogTiers(IronSoulConfig.LOG_ERR(), "PlayDefiantTransitionMessageSequenceSWF: One or more menus resolved empty")
        return
    endif

    Actor player = Game.GetPlayer()

    UI.CloseCustomMenu()
    FadeMusicForTransitionSequence()

    Int transitionSFXInstance = -1
    Float transitionSFXStartedAt = 0.0
    if restoreMusicAfterIntro
        transitionSFXStartedAt = Utility.GetCurrentRealTime()
        transitionSFXInstance = PlayTierSFXInstance(SFXDefiantTransition, player)
    else
        PlayTierSFX(SFXDefiantTransition, player)
    endif

    UI.OpenCustomMenu(m1, 0)
    Utility.WaitMenuMode(4.0)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.25)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m1, 0)
    Utility.WaitMenuMode(3.35)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.25)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m2, 0)
    Utility.WaitMenuMode(3.35)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.5)

    if restoreMusicAfterIntro
        Controller.Presentation.OpenTimedMessageSWF_KeyDismissTrackedSFX(m3, 60.0, 10.0, True, transitionSFXInstance, transitionSFXStartedAt, DEFIANT_TRANSITION_SFX_SECONDS)
    else
        Controller.Presentation.OpenTimedMessageSWF_KeyDismiss(m3, 60.0, 10.0, False)
    endif
EndFunction

Function PlayDefiantResetMessageSequenceSWF(Actor player, String endingMenu, Int deathsBeforeReset = 0, Bool restoreMusicAfterIntro = True)
    String m0 = "0defianttransitionflash"
    String m1 = "0defiantreset"
    String m2 = "0defiantresetcracks"
    String m3 = endingMenu

    if m3 == ""
        LogTiers(IronSoulConfig.LOG_ERR(), "PlayDefiantResetMessageSequenceSWF: Reset menu resolved empty")
        return
    endif

    IronSoulNative.DataFlushIfDirty()

    UI.CloseCustomMenu()
    FadeMusicForTransitionSequence()
    PlayTierSFX(SFXDefiantReset, player)

    UI.OpenCustomMenu(m1, 0)
    Utility.WaitMenuMode(4.0)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.25)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m2, 0)
    Utility.WaitMenuMode(3.35)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.5)

    Controller.Presentation.OpenTimedMessageSWF_KeyDismiss(m3, 60.0, 10.0, restoreMusicAfterIntro)
    MaybePlayDeathsPurgedAfterReset(player, deathsBeforeReset)
    MaybePlayLuckImprovedAfterTierUnlock(player)
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


; --- Feat Journal Helpers ---
; ============================

String Function ResolveSoulFeatUnlockJournalBase(Int soulTier, Bool molagKilled, Bool miraakKilled, Bool alduinKilled, Bool harkonKilled, Bool resetDeaths) Global
    String baseText = ""

    if soulTier == 6
        baseText = "Soul Feat achieved: Devour Soul awakened."
    elseif soulTier == 5
        if molagKilled
            baseText = "Molag Bal Defeated: Soul Feat achieved: Platinum Soul awakened."
        elseif miraakKilled
            baseText = "Miraak Defeated: Soul Feat achieved: Platinum Soul awakened."
        else
            baseText = "Soul Feat achieved: Platinum Soul awakened."
        endif
    elseif soulTier == 4
        if alduinKilled
            baseText = "Alduin Defeated: Soul Feat achieved: Ebon Soul awakened."
        elseif harkonKilled
            baseText = "Harkon Defeated: Soul Feat achieved: Ebon Soul awakened."
        else
            baseText = "Soul Feat achieved: Ebon Soul awakened."
        endif
    elseif soulTier == 3
        baseText = "Soul Feat achieved: Gilded Soul awakened."
    elseif soulTier == 2
        baseText = "Soul Feat achieved: Silver Soul awakened."
    endif

    if baseText == ""
        return ""
    endif
    if resetDeaths
        baseText = baseText + " Deaths purged."
    endif
    return baseText
EndFunction

String Function ResolveDefiantResetJournalBase(Int targetTier, Bool molagKilled, Bool miraakKilled, Bool alduinKilled, Bool harkonKilled) Global
    if targetTier < 2 || !IsNormalSoulTier(targetTier)
        return ""
    endif

    if targetTier == 6
        return "Defiant Soul ended. Deaths purged. Devour Soul claimed."
    elseif targetTier == 5
        if molagKilled
            return "Defiant Soul ended. Deaths purged. Molag Bal Defeated: Platinum Soul claimed."
        elseif miraakKilled
            return "Defiant Soul ended. Deaths purged. Miraak Defeated: Platinum Soul claimed."
        endif
        return "Defiant Soul ended. Deaths purged. Platinum Soul claimed."
    elseif targetTier == 4
        if alduinKilled
            return "Defiant Soul ended. Deaths purged. Alduin Defeated: Ebon Soul claimed."
        elseif harkonKilled
            return "Defiant Soul ended. Deaths purged. Harkon Defeated: Ebon Soul claimed."
        endif
        return "Defiant Soul ended. Deaths purged. Ebon Soul claimed."
    elseif targetTier == 3
        return "Defiant Soul ended. Deaths purged. Gilded Soul claimed."
    endif

    return "Defiant Soul ended. Deaths purged. Silver Soul claimed."
EndFunction
