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
; PlayPermadeathImod()
; PlayLoadTransitionImodAndWait()
; PlayLoadPermadeathSequence()
; PlayBlackScreenImod()
; HandlePlayerDying()
; HandleDeathAndQuit()
; IsDeathEventLocked()
; ClearDeathEventLock()

; --- Death State ---
; -------------------
; GetCurrentDeathCount()
; GetTotalDeaths()
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

; Brawl exception.
Quest Property brawlQuest Auto

String Property deathCount = "IS_8155" AutoReadOnly
String Property totalDeathCount = "IS_9132" AutoReadOnly ; Lifetime death counter; never resets.

; Death lock ownership:
; - Local death routes clear it before returning.
; - Dragon Soul Revive clears it when revive cleanup exits.
; - Respawn clears it after recovery, death-before-recovery, or watchdog fallback.
Bool _deathEventLocked = False
Float _deathInitialImodStartedAt = 0.0

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
    ImageSpaceModifier.RemoveCrossFade(0.75)
EndFunction

Function PlayDeathInitialImod()
    if !HasCoreRuntime() || !Controller.Config.IsRedTintOnDeathEnabled()
        return
    endif

    if DeathInitialImod
        DeathInitialImod.ApplyCrossFade(0.35)
        _deathInitialImodStartedAt = Utility.GetCurrentRealTime()
    else
        _deathInitialImodStartedAt = 0.0
        LogDeath(IronSoulConfig.LOG_ERR(), "PlayDeathInitialImod: DeathInitialImod property is not wired")
    endif
EndFunction

Bool Function PlayDeathImod()
    if !HasCoreRuntime() || !Controller.Config.IsRedTintOnDeathEnabled()
        return False
    endif

    if DeathImod
        DeathImod.ApplyCrossFade(1.0)
        return True
    endif

    LogDeath(IronSoulConfig.LOG_ERR(), "PlayDeathImod: DeathImod property is not wired")
    return False
EndFunction

Bool Function PlayPermadeathImod()
    if !HasCoreRuntime() || !Controller.Config.IsRedTintOnDeathEnabled()
        return False
    endif

    if PermadeathImod
        PermadeathImod.ApplyCrossFade(1.0)
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
    Controller.Presentation.OpenTimedMessageSWF_KeyDismiss_SFX(menuName, 55.0, 27.0, sfx, player, False)
    FinalizeDeathQuit(True)
EndFunction

Bool Function PlayBlackScreenImod(Float fadeSeconds = 2.0)
    if !HasCoreRuntime() || !Controller.Config.IsRedTintOnDeathEnabled()
        return False
    endif
    if fadeSeconds <= 0.0
        fadeSeconds = 0.1
    endif

    if BlackScreenImod
        BlackScreenImod.ApplyCrossFade(fadeSeconds)
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

        if luckSaved
            respawnReady = respawn && respawn.ArmRespawnWindow(player, guid)
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
            luck.JournalLogOutcome(False, player, guid)
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
    IronSoulEffects effects = Controller.Effects

    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Enter t=" + deathQuitStartedAt, True)
    IronSoulNative.HoldDeathSlowMo("death-failure")
    IronSoulNative.BeginMenuBlock("death", True)

    ; Identity (GUID required).
    String guid = identity.GetTickGuid(player)
    if guid == ""
        LogDeath(IronSoulConfig.LOG_ERR(), "HandleDeathAndQuit: Missing GUID; exiting without logging state")
        Debug.MessageBox("Could not determine character identity. Exiting to prevent state corruption.")
        IronSoulNative.ClearDeathSlowMo("death-missing-guid")
        FinalizeDeathQuit(False)
        return
    endif

    ; Commit: death + cycle reset.
    IncrementDeathCount(player, guid)

    ; Read deaths AFTER increment so first recorded death is deathsNow == 1.
    Int deathsNow = GetCurrentDeathCount(player, guid)

    ; Cached state for tier-aware menus.
    ; Soul tier/state: 0=Defiant, 1=Iron, 2=Silver, 3=Gold, 4=Ebon, 5=Platinum, 6=Devour, 9=CHIM.
    Int soulTierTD = tiers.GetCurrentTier(player, guid)
    Bool chimActive = soulTierTD == tiers.TIER_CHIM
    Bool defiantActive = soulTierTD == tiers.TIER_DEFIANT

    ; Defiant fatigue terminal detection needs post-death fatigue synced before the kill.
    Bool syncedEffectsBeforeKill = False
    Bool defiantFatigueTerminal = False
    if defiantActive && config.IsSoulFatigueEnabled()
        effects.SyncSoulPresentationAndStats(player, guid)
        syncedEffectsBeforeKill = True
        defiantFatigueTerminal = tiers.IsDefiantSoulFatigueTerminal(player, guid)
    endif

    ; Luck reset: death milestone should consume the current cycle.
    if luck.IsRuntimeAvailable()
        luck.ResetValue(player, guid)
        luck.ForcePersistNow(player, guid)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: ResetLuck()")
    endif
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Pre-kill state committed deathsNow=" + deathsNow + " tier=" + soulTierTD + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)

    ; Resolve the death outcome before the kill; defer journals and presentation.
    ; presentationMode: 0 none, 1 Defiant transition, 2 CHIM transition, 3 death, 4 permadeath.
    Int presentationMode = 0
    String presentationMenu = ""
    Bool quitToMainMenu = False

    Bool tierStateCommittedBeforeKill = False
    Int committedTier = soulTierTD
    Bool logDefiantActivationJournal = False
    Bool logCHIMRealizedJournal = False
    Bool logDefiantFatigueJournal = False
    String defiantFatigueJournalText = ""
    Bool maybeLogDefeatJournal = False
    String defeatJournalText = ""
    Bool logTrueDeathJournal = False
    String trueDeathJournalText = ""

    Int transitionTier = tiers.ResolveDeathTransitionTier(player, guid, deathsNow, soulTierTD)

    ; Defiant transition sequence (10th death, feat earned, not yet activated).
    if !defiantActive && transitionTier == tiers.TIER_DEFIANT
        ; Commit Defiant activation before native kill so quitting/crashing during the UI sequence cannot lose it.
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Defiant Soul state commit before kill")
        tiers.CommitDefiantTransitionStateForDeath(player, guid, soulTierTD)
        tierStateCommittedBeforeKill = True
        committedTier = tiers.TIER_DEFIANT
        logDefiantActivationJournal = True
        presentationMode = 1
    elseif defiantActive && defiantFatigueTerminal
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Defiant Soul FATIGUE terminal state reached")
        if config.IsCharacterJournalEnabled()
            Bool terminalFatigue = config.IsPermadeathEnabled() || chimActive
            logDefiantFatigueJournal = True
            defiantFatigueJournalText = IronSoulJournal.DefiantFatigueOutcomeText(deathsNow, tiers.DEFIANT_SOUL_MAX_LIVES, terminalFatigue)
        endif
        if !config.IsPermadeathEnabled() && !chimActive
            LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: CHIM Soul state commit before kill")
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
        ; CHIM transition sequence (10th death without Defiant transition, 10th Devour death with Permadeath off, or 20th death in Defiant).
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: CHIM Soul state commit before kill")
        tiers.CommitCHIMTransitionStateForDeath(player, guid)
        tierStateCommittedBeforeKill = True
        committedTier = tiers.TIER_CHIM
        logCHIMRealizedJournal = True
        presentationMode = 2
    elseif chimActive
        ; CHIM tier: every death uses a random dedicated CHIM death menu and exits.
        if config.IsCharacterJournalEnabled()
            maybeLogDefeatJournal = True
            defeatJournalText = IronSoulJournal.DefeatOutcomeText(deathsNow, tiers.GetEffectiveMaxLives(player, guid))
        endif
        if config.IsDeathMessageEnabled()
            presentationMode = 3
            presentationMenu = IronSoulUI.ResolveDeathMessageMenu(soulTierTD, deathsNow)
        endif
    else
        ; Non-CHIM caps + messaging.
        Int hardCap = tiers.IRON_SOUL_MAX_LIVES
        if defiantActive
            hardCap = tiers.DEFIANT_SOUL_MAX_LIVES
        endif

        ; Journal: normal death (non-cap). Special cases are handled above.
        if config.IsCharacterJournalEnabled()
            if deathsNow < hardCap
                maybeLogDefeatJournal = True
                defeatJournalText = IronSoulJournal.DefeatOutcomeText(deathsNow, hardCap)
            endif
        endif

        if deathsNow >= hardCap
            ; Permadeath scenario:
            ; - 10th death without Defiant/CHIM transition
            ; - 10th Devour death when Permadeath is enabled
            ; - 20th death with Defiant active when CHIM transition is not taken.
            logTrueDeathJournal = True
            trueDeathJournalText = IronSoulJournal.TrueDeathOutcomeText(deathsNow, hardCap)
            presentationMode = 4
            presentationMenu = IronSoulUI.ResolvePermadeathMenu(soulTierTD)
            quitToMainMenu = True
        else
            if config.IsDeathMessageEnabled()
                presentationMode = 3
                presentationMenu = IronSoulUI.ResolveDeathMessageMenu(soulTierTD, deathsNow)
            endif
        endif
    endif

    IronSoulNative.DataFlushIfDirty()
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Outcome resolved mode=" + presentationMode + " menu=" + presentationMenu + " quitToMainMenu=" + quitToMainMenu + " committedTier=" + committedTier + " t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)

    if presentationMode == 1 || presentationMode == 2 || presentationMode == 4
        PlayPermadeathImod()
    else
        PlayDeathImod()
    endif

    ; Non-luck death routes still need the fixed front-delay.
    if !luck.ConsumeDeathFrontDelay()
        Utility.Wait(0.5)
    endif

    player.GetActorBase().SetEssential(False)
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Calling EndDeferredKill() t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)
    player.EndDeferredKill()
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: EndDeferredKill() returned t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)

    Utility.Wait(0.01)

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
    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Kill queued; post-kill phase start t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)

    if tierStateCommittedBeforeKill
        tiers.SyncCommittedTierStateAfterDeath(player, guid, committedTier)
    elseif !syncedEffectsBeforeKill
        effects.SyncSoulPresentationAndStats(player, guid)
    endif

    if logDefiantActivationJournal
        journal.LogEventForGuid(player, guid, "You refuse Sovngarde and rise again. Defiant Soul awakened. Death limit is now 20.")
    endif
    if logDefiantFatigueJournal
        journal.LogEventForGuid(player, guid, defiantFatigueJournalText)
    endif
    if logCHIMRealizedJournal
        journal.LogCHIMRealized(player, guid)
    endif
    if maybeLogDefeatJournal
        if luck.ConsumeNextDeathJournalSuppression()
        else
            journal.LogEventForGuid(player, guid, defeatJournalText)
        endif
    endif
    if logTrueDeathJournal
        journal.LogEventForGuid(player, guid, trueDeathJournalText)
    endif

    LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Post-kill journals and presentation state complete t=" + Utility.GetCurrentRealTime() + " elapsed=" + (Utility.GetCurrentRealTime() - deathQuitStartedAt), True)

    IronSoulNative.ReleaseDeathSlowMo(1.0, 0.0, "death-failure-kill")
    Utility.Wait(1.0)

    ; Ensure the player is not essential (kept as-is).
    player.GetActorBase().SetEssential(False)

    if presentationMode == 1
        tiers.PlayDefiantTransitionSWF(soulTierTD, False)
    elseif presentationMode == 2
        tiers.PlayCHIMTransitionSWF(soulTierTD, False)
    elseif presentationMode == 3
        presentation.OpenTimedMessageSWF_SFX(presentationMenu, 6.0, sfx.SFXDeath, player, False)
    elseif presentationMode == 4
        presentation.OpenTimedMessageSWF_KeyDismiss_SFX(presentationMenu, 55.0, 27.0, sfx.SFXPermadeath, player, False)
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
Function IncrementDeathCount(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        LogDeath(IronSoulConfig.LOG_ERR(), "IncrementDeathCount: Invalid args (player None or GUID empty); death count not incremented")
        return
    endif

    Int deaths = GetCurrentDeathCount(player, guid) + 1
    Controller.Persistence.SetGuidInt(player, guid, deathCount, deaths, True)

    Int totalDeaths = GetTotalDeaths(player, guid) + 1
    Controller.Persistence.SetGuidInt(player, guid, totalDeathCount, totalDeaths, True)

    SyncDeathCountMirrors(player, deaths)
    if Controller.Globals
        Controller.Globals.SyncDeath(player, guid)
    endif

    LogDeath(IronSoulConfig.LOG_INFO(), "IncrementDeathCount: GUID=" + guid + " deaths=" + deaths + " totalDeaths=" + totalDeaths)
    IronSoulNative.DataFlushIfDirty()
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
    if PlayBlackScreenImod(2.0)
        finalDelay = 2.0
    endif

    Utility.Wait(finalDelay)
    if mainMenu
        Controller.FinalizeAndQuitMainMenu()
    else
        Controller.FinalizeAndQuit()
    endif
EndFunction
