Scriptname IronSoulDeath extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()
; HasPersistenceRuntime()
; LogDeath()

; --- Death Runtime ---
; ---------------------
; ResetTransientState()
; PlayDeathInitialImod()
; PlayDeathImod()
; PlayDeathFarsightOverlay()
; PlayPermadeathImod()
; PlayLoadTransitionImodAndWait()
; PlayLoadPermadeathSequence()
; PlayBlackScreenImod()
; HandlePlayerDying()
; ClearPreparedDeathOutcome()
; IsPreparedDeathOutcomeForGuid()
; PrepareDeathOutcome()
; HandleDeathAndQuit()
; IsDeathEventLocked()
; ClearDeathEventLock()

; --- Death State ---
; -------------------
; GetCurrentDeathCount()
; GetTotalDeaths()
; GetWorldDeathCount()
; SetCurrentDeathCount()
; ResetCurrentCharacterCounts()
; SyncCurrentDeathCountMirrors()
; RemoveTrackedData()

; --- Death Helpers ---
; ---------------------
; IncrementDeathCount()
; SyncDeathCountMirrors()
; SyncDeathAV()
; RestoreOnDyingHook()
; RemoveOnDyingHook()
; GetEffectiveMaxLivesForTier()
; FinalizeDeathQuit()


; --- Wired Dependencies & Runtime State ---
; ==========================================

IronSoulController Property Controller Auto

Spell Property IronSoulOnDyingSpell Auto

ImageSpaceModifier Property DeathInitialImod Auto
ImageSpaceModifier Property DeathImod Auto
ImageSpaceModifier Property PermadeathImod Auto
ImageSpaceModifier Property BlackScreenImod Auto

VisualEffect Property FXFarsightCamAttachEffect1 Auto
VisualEffect Property FXFarsightCamAttachEffect2 Auto
VisualEffect Property FXFarsightCamAttachEffect3 Auto
VisualEffect Property FXFarsightCamAttachEffect4 Auto
VisualEffect Property FXFarsightCamAttachEffect5 Auto
VisualEffect Property FXFarsightCamAttachEffect6 Auto
VisualEffect Property FXFarsightCamAttachEffect7 Auto
VisualEffect Property FXFarsightCamAttachEffect8 Auto
VisualEffect Property FXFarsightCamAttachEffect9 Auto
VisualEffect Property FXFarsightCamAttachEffect10 Auto
VisualEffect Property FXFarsightCamAttachEffect11 Auto
VisualEffect Property FXFarsightCamAttachEffect12 Auto
VisualEffect Property FXFarsightCamAttachEffect13 Auto
VisualEffect Property FXFarsightCamAttachEffect14 Auto
VisualEffect Property FXFarsightCamAttachEffect15 Auto
VisualEffect Property FXFarsightCamAttachEffect16 Auto
VisualEffect Property FXFarsightCamAttachEffect17 Auto
VisualEffect Property FXFarsightCamAttachEffect18 Auto
VisualEffect Property FXFarsightCamAttachEffect19 Auto
VisualEffect Property FXFarsightCamAttachEffect20 Auto
VisualEffect Property FXFarsightCamAttachEffectCHIM Auto

; Brawl exception.
Quest Property brawlQuest Auto

String Property deathCount = "IS_8155" AutoReadOnly
String Property totalDeathCount = "IS_9132" AutoReadOnly ; Lifetime death counter; never resets.
String Property worldDeathCount = "DC.W" AutoReadOnly

; Death lock ownership:
; - Local death routes clear it before returning.
; - Dragon Soul Revive clears it when revive cleanup exits.
; - Respawn clears it after recovery, death-before-recovery, or watchdog fallback.
Bool _deathEventLocked = False
Float _deathInitialImodStartedAt = 0.0
Actor _deathFarsightOverlayPlayer = None
VisualEffect _deathFarsightOverlayCurrent = None
Bool[] _deathFarsightOverlayActiveSteps
Int DEATH_FARSIGHT_CHIM_STEP = 21
Int DEATH_FARSIGHT_TOTAL_STEPS = 21

Bool _preparedDeathOutcomeValid = False
String _preparedDeathOutcomeGuid = ""
Bool _preparedDeathOutcomeFailedLuck = False
Bool _preparedDeathOutcomeTierStateCommittedBeforeKill = False
Int _preparedDeathsNow = 0
Int _preparedSoulTier = 1
Int _preparedLuckFailureJournalCap = 10
Int _preparedPresentationMode = 0
String _preparedPresentationMenu = ""
Bool _preparedQuitToMainMenu = False
Int _preparedCommittedTier = 1
Bool _preparedLogDefiantActivationJournal = False
Bool _preparedLogCHIMRealizedJournal = False
Bool _preparedLogDefiantFatigueJournal = False
Bool _preparedDefiantFatigueJournalTerminal = False
Bool _preparedMaybeLogDefeatJournal = False
Int _preparedDefeatJournalMaxLives = 10
Bool _preparedLogTrueDeathJournal = False
Int _preparedTrueDeathJournalMaxLives = 10
Int _preparedFarsightOverlayStep = 1

; Permanent death counter AV (unused vanilla actor value; exposed for UI mods).
String _deathAVName = "DEPRECATED05"


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Identity || !Controller.Persistence
        return False
    endif
    if !Controller.Tiers || !Controller.Luck || !Controller.Presentation
        return False
    endif
    if !Controller.Journal || !Controller.SFX || !Controller.DragonSoulRevive
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

Function LogDeath(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("Death", level, msg, suppressNotify)
        return
    endif

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [Death] " + msg)
EndFunction


; --- Death Runtime ---
; =====================

Function ResetTransientState()
    _deathEventLocked = False
    _deathInitialImodStartedAt = 0.0
    ClearPreparedDeathOutcome()
    ClearDeathFarsightOverlay("reset")
    ImageSpaceModifier.RemoveCrossFade(0.75)
EndFunction

Function PlayDeathInitialImod()
    if !HasCoreRuntime() || !Controller.Config.IsTintOverlayEnabled()
        return
    endif

    if DeathInitialImod
        LogDeath(IronSoulConfig.LOG_INFO(), "PlayDeathInitialImod: applying crossfade=0.35 t=" + Utility.GetCurrentRealTime(), True)
        DeathInitialImod.ApplyCrossFade(0.35)
        _deathInitialImodStartedAt = Utility.GetCurrentRealTime()
        LogDeath(IronSoulConfig.LOG_INFO(), "PlayDeathInitialImod: applied t=" + _deathInitialImodStartedAt, True)
    else
        _deathInitialImodStartedAt = 0.0
        LogDeath(IronSoulConfig.LOG_ERR(), "PlayDeathInitialImod: DeathInitialImod property is not wired")
    endif
EndFunction

Bool Function PlayDeathImod()
    if !HasCoreRuntime() || !Controller.Config.IsTintOverlayEnabled()
        return False
    endif

    if DeathImod
        LogDeath(IronSoulConfig.LOG_INFO(), "PlayDeathImod: applying crossfade=2.0 t=" + Utility.GetCurrentRealTime(), True)
        DeathImod.ApplyCrossFade(1.2)
        LogDeath(IronSoulConfig.LOG_INFO(), "PlayDeathImod: applied t=" + Utility.GetCurrentRealTime(), True)
        return True
    endif

    LogDeath(IronSoulConfig.LOG_ERR(), "PlayDeathImod: DeathImod property is not wired")
    return False
EndFunction

VisualEffect Function ResolveDeathFarsightOverlay(Int step)
    if step == 1
        return FXFarsightCamAttachEffect1
    elseif step == 2
        return FXFarsightCamAttachEffect2
    elseif step == 3
        return FXFarsightCamAttachEffect3
    elseif step == 4
        return FXFarsightCamAttachEffect4
    elseif step == 5
        return FXFarsightCamAttachEffect5
    elseif step == 6
        return FXFarsightCamAttachEffect6
    elseif step == 7
        return FXFarsightCamAttachEffect7
    elseif step == 8
        return FXFarsightCamAttachEffect8
    elseif step == 9
        return FXFarsightCamAttachEffect9
    elseif step == 10
        return FXFarsightCamAttachEffect10
    elseif step == 11
        return FXFarsightCamAttachEffect11
    elseif step == 12
        return FXFarsightCamAttachEffect12
    elseif step == 13
        return FXFarsightCamAttachEffect13
    elseif step == 14
        return FXFarsightCamAttachEffect14
    elseif step == 15
        return FXFarsightCamAttachEffect15
    elseif step == 16
        return FXFarsightCamAttachEffect16
    elseif step == 17
        return FXFarsightCamAttachEffect17
    elseif step == 18
        return FXFarsightCamAttachEffect18
    elseif step == 19
        return FXFarsightCamAttachEffect19
    elseif step == 20
        return FXFarsightCamAttachEffect20
    elseif step == DEATH_FARSIGHT_CHIM_STEP
        return FXFarsightCamAttachEffectCHIM
    endif

    return None
EndFunction

Int Function ResolveDeathFarsightOverlayStep(Int presentationMode, Int deathsNow, Int soulTier)
    if presentationMode <= 0
        return 0
    endif

    ; CHIM deaths use the dedicated white overlay, but CHIM transitions use the red threshold endpoints.
    if HasCoreRuntime() && presentationMode == 3 && soulTier == Controller.Tiers.TIER_CHIM
        return DEATH_FARSIGHT_CHIM_STEP
    endif

    Bool simpleMode = HasCoreRuntime() && Controller.Config.GetFarsightOverlayMode() == 2

    if HasCoreRuntime() && soulTier == Controller.Tiers.TIER_DEFIANT
        if deathsNow >= 20
            return 20
        elseif deathsNow >= 11
            if simpleMode
                return 11
            endif
            return deathsNow
        endif
        return 10
    endif

    if deathsNow >= 10
        return 10
    elseif deathsNow >= 1
        if simpleMode
            return 1
        endif
        return deathsNow
    endif
    return 1
EndFunction

Bool Function PlayDeathFarsightOverlayStep(Int step, Float playSeconds)
    if !_deathFarsightOverlayPlayer
        return False
    endif

    VisualEffect nextOverlay = ResolveDeathFarsightOverlay(step)
    if !nextOverlay
        LogDeath(IronSoulConfig.LOG_ERR(), "PlayDeathFarsightOverlayStep: missing Farsight overlay property step=" + step)
        return False
    endif

    _deathFarsightOverlayCurrent = nextOverlay
    if !_deathFarsightOverlayActiveSteps || _deathFarsightOverlayActiveSteps.Length != DEATH_FARSIGHT_TOTAL_STEPS
        _deathFarsightOverlayActiveSteps = new Bool[21]
    endif
    _deathFarsightOverlayActiveSteps[step - 1] = True

    if playSeconds > 0.0
        LogDeath(IronSoulConfig.LOG_INFO(), "PlayDeathFarsightOverlayStep: playing step=" + step + " seconds=" + playSeconds + " t=" + Utility.GetCurrentRealTime(), True)
        nextOverlay.Play(_deathFarsightOverlayPlayer, playSeconds)
    else
        LogDeath(IronSoulConfig.LOG_INFO(), "PlayDeathFarsightOverlayStep: playing step=" + step + " indefinitely t=" + Utility.GetCurrentRealTime(), True)
        nextOverlay.Play(_deathFarsightOverlayPlayer)
    endif
    return True
EndFunction

Bool Function PlayDeathFarsightOverlay(Actor player, Int step)
    if !player
        return False
    endif
    if step <= 0 || step > DEATH_FARSIGHT_TOTAL_STEPS
        return False
    endif
    if !HasCoreRuntime() || !Controller.Config.IsFarsightOverlayEnabled()
        ClearDeathFarsightOverlay("disabled")
        return False
    endif
    if !ResolveDeathFarsightOverlay(step)
        LogDeath(IronSoulConfig.LOG_ERR(), "PlayDeathFarsightOverlay: missing Farsight overlay property step=" + step)
        ClearDeathFarsightOverlay("missing-step")
        return False
    endif

    UnregisterForUpdate()
    ClearDeathFarsightOverlay("restart")
    _deathFarsightOverlayPlayer = player
    _deathFarsightOverlayCurrent = None
    _deathFarsightOverlayActiveSteps = new Bool[21]

    Controller.SFX.Play(Controller.SFX.SFXFarsight, player)

    Bool playedAny = PlayDeathFarsightOverlayStep(step, 0.0)
    if playedAny
        Utility.Wait(1.5)
    endif

    if !playedAny
        ClearDeathFarsightOverlay("start-failed")
    endif
    return playedAny
EndFunction

Function ClearDeathFarsightOverlay(String reason = "")
    UnregisterForUpdate()
    if _deathFarsightOverlayPlayer
        Int step = 1
        while step <= DEATH_FARSIGHT_TOTAL_STEPS
            if _deathFarsightOverlayActiveSteps && _deathFarsightOverlayActiveSteps.Length == DEATH_FARSIGHT_TOTAL_STEPS && _deathFarsightOverlayActiveSteps[step - 1]
                VisualEffect overlay = ResolveDeathFarsightOverlay(step)
                if overlay
                    overlay.Stop(_deathFarsightOverlayPlayer)
                endif
            endif
            step += 1
        endwhile

        LogDeath(IronSoulConfig.LOG_INFO(), "ClearDeathFarsightOverlay: stopped reason=" + reason + " t=" + Utility.GetCurrentRealTime(), True)
    endif

    _deathFarsightOverlayPlayer = None
    _deathFarsightOverlayCurrent = None
    _deathFarsightOverlayActiveSteps = new Bool[21]
EndFunction

Bool Function PlayPermadeathImod()
    if !HasCoreRuntime() || !Controller.Config.IsTintOverlayEnabled()
        return False
    endif

    if PermadeathImod
        LogDeath(IronSoulConfig.LOG_INFO(), "PlayPermadeathImod: applying crossfade=2.0 t=" + Utility.GetCurrentRealTime(), True)
        PermadeathImod.ApplyCrossFade(1.2)
        LogDeath(IronSoulConfig.LOG_INFO(), "PlayPermadeathImod: applied t=" + Utility.GetCurrentRealTime(), True)
        return True
    endif

    LogDeath(IronSoulConfig.LOG_ERR(), "PlayPermadeathImod: PermadeathImod property is not wired")
    return False
EndFunction

Function PlayLoadTransitionImodAndWait()
    if PlayPermadeathImod()
        Utility.Wait(1.0)
    endif
EndFunction

Function PlayLoadPermadeathSequence(Actor player, String menuName, Sound sfx, String menuBlockReason)
    if !HasCoreRuntime() || !player || menuName == ""
        return
    endif
    if menuBlockReason == ""
        menuBlockReason = "load-terminal-permadeath"
    endif

    IronSoulNative.BeginMenuBlock(menuBlockReason, True)
    PlayLoadTransitionImodAndWait()
    LogDeath(IronSoulConfig.LOG_INFO(), "PlayLoadPermadeathSequence: opening menu=" + menuName + " t=" + Utility.GetCurrentRealTime(), True)
    Controller.Presentation.OpenTimedMessageSWF_KeyDismiss_SFX(menuName, 55.0, 27.0, sfx, player, False)
    LogDeath(IronSoulConfig.LOG_INFO(), "PlayLoadPermadeathSequence: menu returned=" + menuName + " t=" + Utility.GetCurrentRealTime(), True)
    PlayBlackScreenImod(1.9)
    FinalizeDeathQuit(True)
EndFunction

Bool Function PlayBlackScreenImod(Float fadeSeconds = 2.0)
    if !HasCoreRuntime() || !Controller.Config.IsTintOverlayEnabled()
        return False
    endif
    if fadeSeconds <= 0.0
        fadeSeconds = 0.1
    endif

    if BlackScreenImod
        LogDeath(IronSoulConfig.LOG_INFO(), "PlayBlackScreenImod: applying crossfade=" + fadeSeconds + " t=" + Utility.GetCurrentRealTime(), True)
        BlackScreenImod.ApplyCrossFade(fadeSeconds)
        LogDeath(IronSoulConfig.LOG_INFO(), "PlayBlackScreenImod: applied crossfade=" + fadeSeconds + " t=" + Utility.GetCurrentRealTime(), True)
        return True
    endif

    LogDeath(IronSoulConfig.LOG_ERR(), "PlayBlackScreenImod: BlackScreenImod property is not wired")
    return False
EndFunction

; Single entry point for ALL death events (HP <= 0).
Function HandlePlayerDying(Actor player, Actor caster)
    if !HasCoreRuntime() || _deathEventLocked
        return
    endif

    IronSoulConfig config = Controller.Config
    IronSoulIdentity identity = Controller.Identity
    IronSoulTiers tiers = Controller.Tiers
    IronSoulLuck luck = Controller.Luck
    IronSoulRespawn respawn = Controller.Respawn
    IronSoulDragonSoulRevive dragonSoulRevive = Controller.DragonSoulRevive

    if !player || Controller.IsModDisabled() || config.IsUninstallMode()
        return
    endif

    ; Brawl exception.
    if brawlQuest
        if brawlQuest.GetStage() > 0 && brawlQuest.GetStage() < 250
            LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Brawl detected, returning")
            return
        endif
    endif

    IronSoulNative.HoldDeathSlowMo("death-event")
    PlayDeathInitialImod()

    String guid = identity.GetTickGuid(player)
    if guid == ""
        LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: GUID missing -> routing to HandleDeathAndQuit")
        HandleDeathAndQuit(player)
        return
    endif

    _deathEventLocked = True

    LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Routing death event")

    ; Defiant terminal fatigue takes priority over Dragon Soul Revive and respawn paths.
    if tiers.IsDefiantSoulFatigueTerminal(player, guid)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Defiant Soul Fatigue terminal state has priority over revive/respawn")
        HandleDeathAndQuit(player)
        _deathEventLocked = False
        return
    endif

    ; 1) Dragon Soul Revive (highest priority).
    ; DSR owns the death lock until cleanup completes.
    if dragonSoulRevive.IsAvailable(player, guid)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Dragon Soul Revive")
        dragonSoulRevive.HandleRevive(player, caster, guid)
        return
    endif

    ; Respawn cannot handle transformed beast races; check before Luck can route there.
    if respawn && respawn.ShouldForceDeathBeforeLuck(player)
        HandleDeathAndQuit(player)
        _deathEventLocked = False
        return
    endif

    ; 2) Luck Mode.
    if luck.IsRuntimeAvailable()
        LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Luck mode")

        Bool luckSaved = luck.RollOutcomeNow(player, guid)
        Bool respawnReady = False
        Bool preparedFailedLuckDeath = False

        if luckSaved
            respawnReady = respawn && respawn.ArmRespawnWindow(player, guid)
        else
            preparedFailedLuckDeath = PrepareDeathOutcome(player, guid, True, Utility.GetCurrentRealTime(), "PrepareFailedLuckDeath")
            LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Luck failure precommit prepared=" + preparedFailedLuckDeath + " t=" + Utility.GetCurrentRealTime(), True)
        endif

        Float luckPresentationStartedAt = Utility.GetCurrentRealTime()
        LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Luck presentation start success=" + luckSaved + " t=" + luckPresentationStartedAt, True)
        luck.PlayRollPresentation(player, luckSaved)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Luck presentation returned success=" + luckSaved + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - luckPresentationStartedAt), True)

        if luckSaved
            ; Journal: luck-based survival line (tiered by luck value used for the roll).
            luck.JournalLogOutcome(True, player, guid)
            LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Luck SUCCESS -> Survival/Respawn")
            IronSoulNative.ReleaseDeathSlowMo(1.0, 0.0, "luck-success-menu-complete")
            if !respawnReady
                HandleDeathAndQuit(player)
            else
                respawn.QueueRespawnBlackFade(3.0, 6.0)
            endif
            if respawnReady && !respawn.TryStartRespawn(player, guid)
                respawn.ClearPendingRespawnState("luck-success-start-failed", False)
                HandleDeathAndQuit(player)
            endif
        else
            ; Journal: luck-based death line includes roll + luck (and predicted death count).
            if !preparedFailedLuckDeath
                luck.JournalLogOutcome(False, player, guid, True)
            endif
            LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Luck FAIL -> Death; entering HandleDeathAndQuit t=" + Utility.GetCurrentRealTime(), True)
            HandleDeathAndQuit(player)
        endif

        _deathEventLocked = False
        return
    endif

    ; 3) Final fallback - no DSR or Luck.
    LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Fallback Death")
    HandleDeathAndQuit(player)

    _deathEventLocked = False
EndFunction

Function ClearPreparedDeathOutcome()
    _preparedDeathOutcomeValid = False
    _preparedDeathOutcomeGuid = ""
    _preparedDeathOutcomeFailedLuck = False
    _preparedDeathOutcomeTierStateCommittedBeforeKill = False
    _preparedDeathsNow = 0
    _preparedSoulTier = 1
    _preparedLuckFailureJournalCap = 10
    _preparedPresentationMode = 0
    _preparedPresentationMenu = ""
    _preparedQuitToMainMenu = False
    _preparedCommittedTier = 1
    _preparedLogDefiantActivationJournal = False
    _preparedLogCHIMRealizedJournal = False
    _preparedLogDefiantFatigueJournal = False
    _preparedDefiantFatigueJournalTerminal = False
    _preparedMaybeLogDefeatJournal = False
    _preparedDefeatJournalMaxLives = 10
    _preparedLogTrueDeathJournal = False
    _preparedTrueDeathJournalMaxLives = 10
    _preparedFarsightOverlayStep = 1
EndFunction

Bool Function IsPreparedDeathOutcomeForGuid(String guid)
    return _preparedDeathOutcomeValid && _preparedDeathOutcomeGuid == guid
EndFunction

Bool Function PrepareDeathOutcome(Actor player, String guid, Bool failedLuck, Float startedAt, String logScope = "PrepareDeathOutcome")
    if !HasCoreRuntime() || !player || guid == ""
        return False
    endif

    ClearPreparedDeathOutcome()

    IronSoulConfig config = Controller.Config
    IronSoulTiers tiers = Controller.Tiers

    LogDeath(IronSoulConfig.LOG_INFO(), logScope + ": IncrementDeathCount() start t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - startedAt), True)
    IncrementDeathCount(player, guid, False)
    LogDeath(IronSoulConfig.LOG_INFO(), logScope + ": IncrementDeathCount() returned t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - startedAt), True)

    Int deathsNow = GetCurrentDeathCount(player, guid)
    Int soulTierTD = tiers.GetCurrentTier(player, guid)
    Bool chimActive = soulTierTD == tiers.TIER_CHIM
    Bool defiantActive = soulTierTD == tiers.TIER_DEFIANT
    Int luckFailureJournalCap = tiers.IRON_SOUL_MAX_LIVES
    if defiantActive
        luckFailureJournalCap = tiers.DEFIANT_SOUL_MAX_LIVES
    elseif chimActive
        luckFailureJournalCap = 2147483647
    endif
    LogDeath(IronSoulConfig.LOG_INFO(), logScope + ": Death state read deathsNow=" + deathsNow + " soulTier=" + soulTierTD + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - startedAt), True)

    Bool defiantFatigueTerminal = False
    if defiantActive && config.IsSoulFatigueEnabled()
        ; Terminal fatigue is observed from already-applied effects. Live death should not refresh actor spells.
        defiantFatigueTerminal = tiers.IsDefiantSoulFatigueTerminal(player, guid)
        LogDeath(IronSoulConfig.LOG_INFO(), logScope + ": Defiant fatigue terminal check terminal=" + defiantFatigueTerminal + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - startedAt), True)
    endif

    Int presentationMode = 0
    String presentationMenu = ""
    Bool quitToMainMenu = False

    Bool tierStateCommittedBeforeKill = False
    Int committedTier = soulTierTD
    Bool logDefiantActivationJournal = False
    Bool logCHIMRealizedJournal = False
    Bool logDefiantFatigueJournal = False
    Bool defiantFatigueJournalTerminal = False
    Bool maybeLogDefeatJournal = False
    Int defeatJournalMaxLives = 10
    Bool logTrueDeathJournal = False
    Int trueDeathJournalMaxLives = 10

    LogDeath(IronSoulConfig.LOG_INFO(), logScope + ": ResolveDeathTransitionTier() start t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - startedAt), True)
    Int transitionTier = tiers.ResolveDeathTransitionTier(player, guid, deathsNow, soulTierTD)
    LogDeath(IronSoulConfig.LOG_INFO(), logScope + ": ResolveDeathTransitionTier() returned transitionTier=" + transitionTier + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - startedAt), True)

    if !defiantActive && transitionTier == tiers.TIER_DEFIANT
        LogDeath(IronSoulConfig.LOG_INFO(), logScope + ": Defiant Soul state commit before kill")
        tiers.CommitDefiantTransitionStateForDeath(player, guid, soulTierTD)
        tierStateCommittedBeforeKill = True
        committedTier = tiers.TIER_DEFIANT
        logDefiantActivationJournal = True
        presentationMode = 1
    elseif defiantActive && defiantFatigueTerminal
        LogDeath(IronSoulConfig.LOG_INFO(), logScope + ": Defiant Soul FATIGUE terminal state reached")
        if config.IsCharacterJournalEnabled()
            Bool terminalFatigue = config.IsPermadeathEnabled() || chimActive
            logDefiantFatigueJournal = True
            defiantFatigueJournalTerminal = terminalFatigue
        endif
        if !config.IsPermadeathEnabled() && !chimActive
            LogDeath(IronSoulConfig.LOG_INFO(), logScope + ": CHIM Soul state commit before kill")
            tiers.CommitCHIMTransitionStateForDeath(player, guid)
            tierStateCommittedBeforeKill = True
            committedTier = tiers.TIER_CHIM
            logCHIMRealizedJournal = True
            presentationMode = 2
        else
            presentationMode = 4
            presentationMenu = "0_defiant_permadeath_soulfatigue"
            quitToMainMenu = True
        endif
    elseif !chimActive && transitionTier == tiers.TIER_CHIM
        LogDeath(IronSoulConfig.LOG_INFO(), logScope + ": CHIM Soul state commit before kill")
        tiers.CommitCHIMTransitionStateForDeath(player, guid)
        tierStateCommittedBeforeKill = True
        committedTier = tiers.TIER_CHIM
        logCHIMRealizedJournal = True
        presentationMode = 2
    elseif chimActive
        if config.IsCharacterJournalEnabled()
            maybeLogDefeatJournal = True
            defeatJournalMaxLives = tiers.GetEffectiveMaxLives(player, guid)
        endif
        if config.IsDeathMenuEnabled()
            presentationMode = 3
            presentationMenu = IronSoulUI.ResolveDeathMenu(soulTierTD, deathsNow)
        endif
    else
        Int hardCap = tiers.IRON_SOUL_MAX_LIVES
        if defiantActive
            hardCap = tiers.DEFIANT_SOUL_MAX_LIVES
        endif

        if config.IsCharacterJournalEnabled()
            if deathsNow < hardCap
                maybeLogDefeatJournal = True
                defeatJournalMaxLives = hardCap
            endif
        endif

        if deathsNow >= hardCap
            logTrueDeathJournal = True
            trueDeathJournalMaxLives = hardCap
            presentationMode = 4
            presentationMenu = IronSoulUI.ResolvePermadeathMenu(soulTierTD)
            quitToMainMenu = True
        else
            if config.IsDeathMenuEnabled()
                presentationMode = 3
                presentationMenu = IronSoulUI.ResolveDeathMenu(soulTierTD, deathsNow)
            endif
        endif
    endif

    Int farsightOverlayStep = ResolveDeathFarsightOverlayStep(presentationMode, deathsNow, soulTierTD)

    _preparedDeathOutcomeValid = True
    _preparedDeathOutcomeGuid = guid
    _preparedDeathOutcomeFailedLuck = failedLuck
    _preparedDeathOutcomeTierStateCommittedBeforeKill = tierStateCommittedBeforeKill
    _preparedDeathsNow = deathsNow
    _preparedSoulTier = soulTierTD
    _preparedLuckFailureJournalCap = luckFailureJournalCap
    _preparedPresentationMode = presentationMode
    _preparedPresentationMenu = presentationMenu
    _preparedQuitToMainMenu = quitToMainMenu
    _preparedCommittedTier = committedTier
    _preparedLogDefiantActivationJournal = logDefiantActivationJournal
    _preparedLogCHIMRealizedJournal = logCHIMRealizedJournal
    _preparedLogDefiantFatigueJournal = logDefiantFatigueJournal
    _preparedDefiantFatigueJournalTerminal = defiantFatigueJournalTerminal
    _preparedMaybeLogDefeatJournal = maybeLogDefeatJournal
    _preparedDefeatJournalMaxLives = defeatJournalMaxLives
    _preparedLogTrueDeathJournal = logTrueDeathJournal
    _preparedTrueDeathJournalMaxLives = trueDeathJournalMaxLives
    _preparedFarsightOverlayStep = farsightOverlayStep

    LogDeath(IronSoulConfig.LOG_INFO(), logScope + ": Outcome resolved mode=" + presentationMode + " menu=" + presentationMenu + " quitToMainMenu=" + quitToMainMenu + " committedTier=" + committedTier + " farsightStep=" + farsightOverlayStep + " failedLuck=" + failedLuck + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - startedAt), True)

    if failedLuck
        IronSoulNative.DataFlushIfDirty()
    endif

    return True
EndFunction

Function HandleDeathAndQuit(Actor player)
    if !HasCoreRuntime() || !player
        return
    endif

    Float deathQuitStartedAt = Utility.GetCurrentRealTime()

    IronSoulConfig config = Controller.Config
    IronSoulIdentity identity = Controller.Identity
    IronSoulTiers tiers = Controller.Tiers
    IronSoulLuck luck = Controller.Luck
    IronSoulUI presentation = Controller.Presentation
    IronSoulJournal journal = Controller.Journal
    IronSoulSFX sfx = Controller.SFX

    Controller.EnforceRequiemDeathHandlingDisabled("death-enter", True)
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Enter t=" + deathQuitStartedAt, True)
    IronSoulNative.HoldDeathSlowMo("death-failure")
    IronSoulNative.BeginMenuBlock("death", True)

    ; Identity (GUID required).
    String guid = identity.GetTickGuid(player)
    if guid == ""
        LogDeath(IronSoulConfig.LOG_ERR(), "HandleDeathAndQuit: Missing GUID; exiting without logging state")
        Debug.MessageBox(IronSoulNative.TextGet("MessageBox.MissingIdentityDeath"))
        IronSoulNative.ClearDeathSlowMo("death-missing-guid")
        FinalizeDeathQuit(False)
        return
    endif
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: GUID resolved t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)

    Bool preparedOutcome = IsPreparedDeathOutcomeForGuid(guid)
    if _preparedDeathOutcomeValid && !preparedOutcome
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: discarding stale prepared outcome guid=" + _preparedDeathOutcomeGuid + " currentGuid=" + guid)
        ClearPreparedDeathOutcome()
    endif

    if !preparedOutcome
        preparedOutcome = PrepareDeathOutcome(player, guid, False, deathQuitStartedAt, "HandleDeathAndQuit")
    endif

    if !preparedOutcome
        LogDeath(IronSoulConfig.LOG_ERR(), "HandleDeathAndQuit: Could not prepare death outcome; exiting")
        return
    endif

    Int deathsNow = _preparedDeathsNow
    Int soulTierTD = _preparedSoulTier
    Int luckFailureJournalCap = _preparedLuckFailureJournalCap
    Int presentationMode = _preparedPresentationMode
    String presentationMenu = _preparedPresentationMenu
    Bool quitToMainMenu = _preparedQuitToMainMenu
    Bool tierStateCommittedBeforeKill = _preparedDeathOutcomeTierStateCommittedBeforeKill
    Int committedTier = _preparedCommittedTier
    Bool logDefiantActivationJournal = _preparedLogDefiantActivationJournal
    Bool logCHIMRealizedJournal = _preparedLogCHIMRealizedJournal
    Bool logDefiantFatigueJournal = _preparedLogDefiantFatigueJournal
    Bool defiantFatigueJournalTerminal = _preparedDefiantFatigueJournalTerminal
    Bool maybeLogDefeatJournal = _preparedMaybeLogDefeatJournal
    Int defeatJournalMaxLives = _preparedDefeatJournalMaxLives
    Bool logTrueDeathJournal = _preparedLogTrueDeathJournal
    Int trueDeathJournalMaxLives = _preparedTrueDeathJournalMaxLives
    Int farsightOverlayStep = _preparedFarsightOverlayStep
    Bool preparedFailedLuck = _preparedDeathOutcomeFailedLuck
    ClearPreparedDeathOutcome()

    player.GetActorBase().SetEssential(False)
    Controller.EnforceRequiemDeathHandlingDisabled("pre-kill", True)
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Calling EndDeferredKill() t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
    player.EndDeferredKill()
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: EndDeferredKill() returned t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)

    if !preparedFailedLuck
        Utility.Wait(0.01)
    endif

    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Calling KillPlayerImmediate() t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
    Bool nativeKillQueued = IronSoulNative.KillPlayerImmediate(True, "death-failure")
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: KillPlayerImmediate() returned queued=" + nativeKillQueued + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
    if !nativeKillQueued
        if player.IsEssential()
            LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Native kill unavailable; calling KillEssential()")
            player.KillEssential()
        else
            LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Native kill unavailable; calling Kill()")
            player.Kill()
        endif
    endif
    if preparedFailedLuck
        luck.JournalLogOutcome(False, player, guid, True)
    endif
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Kill queued; post-kill phase start t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)

    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Playing post-kill IMOD t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
    if presentationMode == 1 || presentationMode == 2 || presentationMode == 4
        PlayPermadeathImod()
    else
        PlayDeathImod()
    endif
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Post-kill IMOD returned t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)

    ; Luck reset: death milestone should consume the current cycle.
    if luck.IsRuntimeAvailable() && !preparedFailedLuck
        luck.ResetValue(player, guid)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: ResetLuck() t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
    elseif preparedFailedLuck
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: ResetLuck() skipped; failed Luck roll already reset before menu t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
    endif
    IronSoulNative.DataFlushIfDirty()
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Post-kill state committed deathsNow=" + deathsNow + " tier=" + soulTierTD + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)

    if logDefiantActivationJournal
        journal.LogDefiantAwakenedForGuid(player, guid)
    endif
    if logDefiantFatigueJournal
        journal.LogDefiantFatigueOutcomeForGuid(player, guid, deathsNow, tiers.DEFIANT_SOUL_MAX_LIVES, defiantFatigueJournalTerminal)
    endif
    if logCHIMRealizedJournal
        journal.LogCHIMRealized(player, guid)
    endif
    Bool loggedLuckFailureJournal = luck.ConsumePendingFailureJournal(player, guid, deathsNow, luckFailureJournalCap)
    if maybeLogDefeatJournal
        if loggedLuckFailureJournal
            luck.ConsumeNextDeathJournalSuppression()
        elseif luck.ConsumeNextDeathJournalSuppression()
        else
            journal.LogDefeatOutcomeForGuid(player, guid, deathsNow, defeatJournalMaxLives)
        endif
    elseif loggedLuckFailureJournal
        luck.ConsumeNextDeathJournalSuppression()
    endif
    if logTrueDeathJournal
        journal.LogTrueDeathOutcomeForGuid(player, guid, deathsNow, trueDeathJournalMaxLives)
    endif

    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Post-kill journals and presentation state complete t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)

    ; Consume any queued front-delay marker, but start presentation sooner.
    luck.ConsumeDeathFrontDelay()

    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: transitioning death slowmo to menu hold t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
    IronSoulNative.TransitionDeathSlowMoToHold(0.8, 1.0, "death-failure-post-kill")

    ; Ensure the player is not essential (kept as-is).
    player.GetActorBase().SetEssential(False)

    if presentationMode == 1
        PlayDeathFarsightOverlay(player, farsightOverlayStep)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: opening Defiant transition menu t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
        tiers.PlayDefiantTransitionSWF(soulTierTD, False)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Defiant transition menu returned t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
        PlayBlackScreenImod(1.9)
    elseif presentationMode == 2
        PlayDeathFarsightOverlay(player, farsightOverlayStep)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: opening CHIM transition menu t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
        tiers.PlayCHIMTransitionSWF(soulTierTD, False)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: CHIM transition menu returned t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
        PlayBlackScreenImod(1.9)
    elseif presentationMode == 3
        PlayDeathFarsightOverlay(player, farsightOverlayStep)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: opening death menu=" + presentationMenu + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
        presentation.OpenTimedMessageSWF_SFX(presentationMenu, 6.0, sfx.SFXDeath, player, False)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: death menu returned=" + presentationMenu + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
        PlayBlackScreenImod(1.9)
    elseif presentationMode == 4
        PlayDeathFarsightOverlay(player, farsightOverlayStep)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: opening permadeath menu=" + presentationMenu + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
        presentation.OpenTimedMessageSWF_KeyDismiss_SFX(presentationMenu, 55.0, 27.0, sfx.SFXPermadeath, player, False)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: permadeath menu returned=" + presentationMenu + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
        PlayBlackScreenImod(1.9)
    endif

    if tierStateCommittedBeforeKill
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: syncing committed tier dynamic assets before quit tier=" + committedTier + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
        tiers.SyncTierDynamicAssets(committedTier)
    endif

    if quitToMainMenu
        FinalizeDeathQuit(True)
    else
        FinalizeDeathQuit(False)
    endif
EndFunction

Bool Function IsDeathEventLocked()
    return _deathEventLocked
EndFunction

Function ClearDeathEventLock()
    _deathEventLocked = False
EndFunction


; --- Death State ---
; ===================

Int Function GetCurrentDeathCount(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return 0
    endif
    return Controller.Persistence.GetGuidInt(player, guid, deathCount, 0)
EndFunction

Int Function GetTotalDeaths(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return 0
    endif
    return Controller.Persistence.GetGuidInt(player, guid, totalDeathCount, 0)
EndFunction

Int Function GetWorldDeathCount()
    if !HasCoreRuntime()
        return 0
    endif
    return Controller.Persistence.GetWorldInt(worldDeathCount, 0)
EndFunction

; Public/manual setter: intentionally syncs mirrors, globals, and presentation.
Function SetCurrentDeathCount(Actor player, String guid, Int deaths)
    if !HasCoreRuntime() || !player || guid == "" || deaths < 0
        return
    endif

    Controller.Persistence.SetGuidInt(player, guid, deathCount, deaths, True)
    SyncDeathCountMirrors(player, deaths)
    if Controller.Globals
        Controller.Globals.SyncDeath(player, guid)
    endif

    if Controller.Effects
        Controller.Effects.SyncSoulPresentationAndStats(player, guid)
    endif
EndFunction

Function ResetCurrentCharacterCounts(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    SetCurrentDeathCount(player, guid, 0)
    Controller.Persistence.SetGuidInt(player, guid, totalDeathCount, 0, True)
    if Controller.Globals
        Controller.Globals.SyncDeath(player, guid)
    endif
EndFunction

Function SyncCurrentDeathCountMirrors(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    SyncDeathCountMirrors(player, GetCurrentDeathCount(player, guid))
EndFunction

Function RemoveTrackedData(Actor player, String guid, Bool deleteMainData = True, Bool unsetCosave = False)
    if !HasPersistenceRuntime() || guid == ""
        return
    endif

    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, deathCount, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, totalDeathCount, deleteMainData, unsetCosave)
EndFunction


; --- Death Helpers ---
; =====================

; Internal death commit path. Do not call presentation sync here;
; HandleDeathAndQuit handles post-commit presentation once state is authoritative.
Function IncrementDeathCount(Actor player, String guid, Bool flushNow = True)
    if !HasCoreRuntime() || !player || guid == ""
        LogDeath(IronSoulConfig.LOG_ERR(), "IncrementDeathCount: Invalid args (player None or GUID empty); death count not incremented")
        return
    endif

    Int deaths = GetCurrentDeathCount(player, guid) + 1
    Controller.Persistence.SetGuidInt(player, guid, deathCount, deaths, True)

    Int totalDeaths = GetTotalDeaths(player, guid) + 1
    Controller.Persistence.SetGuidInt(player, guid, totalDeathCount, totalDeaths, True)

    if Controller.Identity && !Controller.Identity.IsCurrentCharacterTest(player)
        Int worldDeaths = GetWorldDeathCount() + 1
        Controller.Persistence.SetWorldInt(worldDeathCount, worldDeaths, True)
    endif

    SyncDeathCountMirrors(player, deaths)
    if Controller.Globals
        Controller.Globals.SyncDeath(player, guid)
    endif

    LogDeath(IronSoulConfig.LOG_INFO(), "IncrementDeathCount: GUID=" + guid + " deaths=" + deaths + " totalDeaths=" + totalDeaths)
    if flushNow
        IronSoulNative.DataFlushIfDirty()
    endif
EndFunction

Function SyncDeathCountMirrors(Actor player, Int deaths)
    if !HasCoreRuntime() || !player || deaths < 0
        return
    endif

    SyncDeathAV(player, deaths)
EndFunction

Function SyncDeathAV(Actor player, Int deaths)
    ; Mirror authoritative deaths into DEPRECATED05 so UI mods can read it (display-only; not an authority source).
    if !HasCoreRuntime() || !player || deaths < 0
        return
    endif
    if !Controller.Config.IsCharacterSheetCompatibilityEnabled()
        return
    endif

    Float cur = player.GetActorValue(_deathAVName)
    Float d = deaths as Float
    if cur != d
        player.SetActorValue(_deathAVName, d)
    endif
EndFunction

Function RestoreOnDyingHook(Actor player)
    if !player || !IronSoulOnDyingSpell
        return
    endif

    if !player.HasSpell(IronSoulOnDyingSpell)
        player.AddSpell(IronSoulOnDyingSpell, False)
    endif
EndFunction

Function RemoveOnDyingHook(Actor player)
    if !player || !IronSoulOnDyingSpell
        return
    endif

    if player.HasSpell(IronSoulOnDyingSpell)
        player.RemoveSpell(IronSoulOnDyingSpell)
    endif
EndFunction

Int Function GetEffectiveMaxLivesForTier(Int tierNow, Int ironMaxLives, Int defiantMaxLives) Global
    if tierNow == 9
        return 2147483647
    endif

    if tierNow == 0
        return defiantMaxLives
    endif

    return ironMaxLives
EndFunction

Function FinalizeDeathQuit(Bool mainMenu)
    Float finalDelay = 1.0
    Int deathQuitMode = Controller.Config.GetDeathQuitMode()
    Bool effectiveMainMenu = (deathQuitMode == 2)
    LogDeath(IronSoulConfig.LOG_INFO(), "FinalizeDeathQuit: start requestedMainMenu=" + mainMenu + " effectiveMainMenu=" + effectiveMainMenu + " deathQuitMode=" + deathQuitMode + " t=" + Utility.GetCurrentRealTime(), True)

    LogDeath(IronSoulConfig.LOG_INFO(), "FinalizeDeathQuit: waiting finalDelay=" + finalDelay + " requestedMainMenu=" + mainMenu + " effectiveMainMenu=" + effectiveMainMenu + " deathQuitMode=" + deathQuitMode + " t=" + Utility.GetCurrentRealTime(), True)
    Utility.Wait(finalDelay)
    LogDeath(IronSoulConfig.LOG_INFO(), "FinalizeDeathQuit: wait complete requestedMainMenu=" + mainMenu + " effectiveMainMenu=" + effectiveMainMenu + " deathQuitMode=" + deathQuitMode + " t=" + Utility.GetCurrentRealTime(), True)
    if effectiveMainMenu
        LogDeath(IronSoulConfig.LOG_INFO(), "FinalizeDeathQuit: calling FinalizeAndQuitMainMenu requestedMainMenu=" + mainMenu + " deathQuitMode=" + deathQuitMode + " t=" + Utility.GetCurrentRealTime(), True)
        Controller.FinalizeAndQuitMainMenu()
    else
        LogDeath(IronSoulConfig.LOG_INFO(), "FinalizeDeathQuit: calling FinalizeAndQuit requestedMainMenu=" + mainMenu + " deathQuitMode=" + deathQuitMode + " t=" + Utility.GetCurrentRealTime(), True)
        Controller.FinalizeAndQuit()
    endif
EndFunction
