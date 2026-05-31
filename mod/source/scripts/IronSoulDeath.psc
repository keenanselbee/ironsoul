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


; --- Wired Dependencies & Runtime State ---
; ==========================================

IronSoulController Property Controller Auto

Spell Property IronSoulOnDyingSpell Auto

; Brawl exception.
Quest Property brawlQuest Auto

String Property deathCount = "IS_8155" AutoReadOnly
String Property totalDeathCount = "IS_9132" AutoReadOnly ; Lifetime death counter; never resets.

; Death lock ownership:
; - Local death routes clear it before returning.
; - Dragon Soul Revive clears it when revive cleanup exits.
; - Respawn clears it after recovery, death-before-recovery, or watchdog fallback.
Bool _deathEventLocked = False

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

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [" + levelText + "] [Death] " + msg)
EndFunction


; --- Death Runtime ---
; =====================

Function ResetTransientState()
    _deathEventLocked = False
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

        Bool luckSaved = luck.PerformRoll(player, guid)

        if luckSaved
            ; Journal: luck-based survival line (tiered by luck value used for the roll).
            luck.JournalLogOutcome(True, player, guid)
            LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Luck SUCCESS -> Survival/Respawn")
            if !respawn || !respawn.TryStartRespawn(player, guid)
                HandleDeathAndQuit(player)
            endif
        else
            ; Journal: luck-based death line includes roll + luck (and predicted death count).
            luck.JournalLogOutcome(False, player, guid)
            LogDeath(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Luck FAIL -> Death")
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

    IronSoulConfig config = Controller.Config
    IronSoulIdentity identity = Controller.Identity
    IronSoulTiers tiers = Controller.Tiers
    IronSoulLuck luck = Controller.Luck
    IronSoulUI presentation = Controller.Presentation
    IronSoulJournal journal = Controller.Journal
    IronSoulSFX sfx = Controller.SFX
    IronSoulEffects effects = Controller.Effects

    IronSoulNative.BeginMenuBlock("death", True)

    ; Identity (GUID required).
    String guid = identity.GetTickGuid(player)
    if guid == ""
        LogDeath(IronSoulConfig.LOG_ERR(), "HandleDeathAndQuit: Missing GUID; exiting without logging state")
        Debug.MessageBox("Could not determine character identity. Exiting to prevent state corruption.")
        Controller.FinalizeAndQuit()
        return
    endif

    ; Commit: death + cycle reset.
    IncrementDeathCount(player, guid)

    ; Read deaths AFTER increment so first recorded death is deathsNow == 1.
    Int deathsNow = GetCurrentDeathCount(player, guid)

    ; Recompute Soul Bonus / Soul Fatigue after the authoritative death count changes.
    effects.SyncSoulPresentationAndStats(player, guid)
    Bool defiantFatigueTerminal = tiers.IsDefiantSoulFatigueTerminal(player, guid)

    ; Luck reset: death milestone should consume the current cycle.
    if luck.IsRuntimeAvailable()
        luck.ResetValue(player, guid)
        luck.ForcePersistNow(player, guid)
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: ResetLuck()")
    endif

    ; Non-luck death routes still need the fixed front-delay.
    if !luck.ConsumeDeathFrontDelay()
        Utility.Wait(0.5)
    endif

    player.GetActorBase().SetEssential(False)
    player.EndDeferredKill()

    Utility.Wait(0.01)

    if player.IsEssential()
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Player is essential; calling KillEssential()")
        player.KillEssential()
    else
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Calling Kill()")
        player.Kill()
    endif

    Utility.Wait(1.0)

    presentation.ShowIronIntro(player, guid)

    ; Ensure the player is not essential (kept as-is).
    player.GetActorBase().SetEssential(False)

    ; Cached state for tier-aware menus.
    ; Soul tier/state: 0=Defiant, 1=Iron, 2=Silver, 3=Gold, 4=Ebon, 5=Platinum, 6=Devour, 9=CHIM.
    Int soulTierTD = tiers.GetCurrentTier(player, guid)

    ; Transition gating + CHIM/Defiant state.
    Bool chimActive = soulTierTD == tiers.TIER_CHIM
    Bool defiantActive = soulTierTD == tiers.TIER_DEFIANT
    Int transitionTier = tiers.ResolveDeathTransitionTier(player, guid, deathsNow, soulTierTD)

    ; Defiant transition sequence (10th death, feat earned, not yet activated).
    if !defiantActive && transitionTier == tiers.TIER_DEFIANT
        ; Commit Defiant activation FIRST so quitting/crashing during the UI sequence cannot lose it.
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Defiant Soul ACTIVATED (one-shot latch)")
        tiers.PromoteToDefiantTier(player, guid, soulTierTD)

        ; Journal: Defiant activation milestone.
        journal.LogEventForGuid(player, guid, "You refuse Sovngarde and rise again. Defiant Soul awakened. Death limit is now 20.")

        tiers.PlayDefiantTransitionMessageSequenceSWF(soulTierTD, False)
        Controller.FinalizeAndQuit()
        return
    endif

    if defiantActive && defiantFatigueTerminal
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: Defiant Soul FATIGUE terminal state reached")
        if config.IsCharacterJournalEnabled()
            Bool terminalFatigue = config.IsPermadeathEnabled() || chimActive
            journal.LogEventForGuid(player, guid, IronSoulJournal.DefiantFatigueOutcomeText(deathsNow, tiers.DEFIANT_SOUL_MAX_LIVES, terminalFatigue))
        endif
        if !config.IsPermadeathEnabled() && !chimActive
            tiers.PromoteToCHIMTier(player, guid)
            tiers.PlayCHIMTransitionMessageSequenceSWF(soulTierTD, False, "0_defiant_permadeath_soulfatigue")
            Controller.FinalizeAndQuit()
            return
        endif

        presentation.OpenTimedMessageSWF_KeyDismiss_SFX("0_defiant_permadeath_soulfatigue", 55.0, 27.0, sfx.SFXPermadeath, player, False)
        Controller.FinalizeAndQuitMainMenu()
        return
    endif

    ; CHIM transition sequence (10th death without Defiant transition, 10th Devour death with Permadeath off, or 20th death in Defiant).
    if !chimActive && transitionTier == tiers.TIER_CHIM
        LogDeath(IronSoulConfig.LOG_INFO(), "HandleDeathAndQuit: CHIM Soul ACTIVATED (one-shot latch)")
        tiers.PromoteToCHIMTier(player, guid)
        tiers.PlayCHIMTransitionMessageSequenceSWF(soulTierTD, False)
        Controller.FinalizeAndQuit()
        return
    endif

    ; CHIM tier: every death uses a random dedicated CHIM death menu and exits.
    if chimActive
        if config.IsCharacterJournalEnabled()
            if luck.ConsumeNextDeathJournalSuppression()
            else
                journal.LogEventForGuid(player, guid, IronSoulJournal.DefeatOutcomeText(deathsNow, tiers.GetEffectiveMaxLives(player, guid)))
            endif
        endif
        if config.IsDeathMessageEnabled()
            presentation.OpenTimedMessageSWF_SFX(IronSoulUI.ResolveDeathMessageMenu(soulTierTD, deathsNow), 6.0, sfx.SFXDeath, player, False)
        endif
        Controller.FinalizeAndQuit()
        return
    endif

    ; Non-CHIM caps + messaging.
    Int hardCap = tiers.IRON_SOUL_MAX_LIVES
    if defiantActive
        hardCap = tiers.DEFIANT_SOUL_MAX_LIVES
    endif

    Bool quitToMainMenu = False

    ; Journal: normal death (non-cap). Special cases are handled above.
    if config.IsCharacterJournalEnabled()
        if luck.ConsumeNextDeathJournalSuppression()
        elseif deathsNow < hardCap
            journal.LogEventForGuid(player, guid, IronSoulJournal.DefeatOutcomeText(deathsNow, hardCap))
        endif
    endif

    if deathsNow >= hardCap
        ; Permadeath scenario:
        ; - 10th death without Defiant/CHIM transition
        ; - 10th Devour death when Permadeath is enabled
        ; - 20th death with Defiant active when CHIM transition is not taken.
        journal.LogEventForGuid(player, guid, IronSoulJournal.TrueDeathOutcomeText(deathsNow, hardCap))
        presentation.OpenTimedMessageSWF_KeyDismiss_SFX(IronSoulUI.ResolvePermadeathMenu(soulTierTD), 55.0, 27.0, sfx.SFXPermadeath, player, False)
        quitToMainMenu = True
    else
        if config.IsDeathMessageEnabled()
            presentation.OpenTimedMessageSWF_SFX(IronSoulUI.ResolveDeathMessageMenu(soulTierTD, deathsNow), 6.0, sfx.SFXDeath, player, False)
        endif
    endif

    if quitToMainMenu
        Controller.FinalizeAndQuitMainMenu()
    else
        Controller.FinalizeAndQuit()
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
