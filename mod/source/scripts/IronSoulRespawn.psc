Scriptname IronSoulRespawn extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()
; LogRespawn()
; LogRespawnSnapshot()

; --- Respawn Runtime ---
; -----------------------
; ResetTransientState()
; RefreshRuntime()
; IsRuntimeAvailable()
; IsResolvedRuntimeAvailable()
; ShouldForceDeathBeforeLuck()
; TryStartRespawn()
; Tick()
; RequiresFastPolling()
; UpdatePlayerProtectionState()
; LogSnapshot()

; --- Respawn Helpers ---
; -----------------------
; IsBlockedByTransform()
; HandleDisableRespawn()
; HandleDisableRespawnWithRuntime()
; HandleRespawnMenu()
; HandleRespawnMenuWithRuntime()
; ClearPendingRespawnState()


; --- Wired Dependencies & Runtime State ---
; ==========================================

IronSoulController Property Controller Auto

Quest _respawnQuest = None
Bool _respawnAvailable = False

Bool _pendingDisableRespawn = False
Bool _respawnWindowArmed = False
Float _pendingDisableRespawnStartedAt = 0.0

Bool _pendingRespawnMenu = False
Bool _respawnMenuArmed = False
Float _respawnWarningAt = 0.0


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Death || !Controller.Identity
        return False
    endif
    if !Controller.Presentation || !Controller.SFX
        return False
    endif
    return True
EndFunction

Function LogRespawn(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("Respawn", level, msg, suppressNotify)
        return
    endif

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [" + levelText + "] [Respawn] " + msg)
EndFunction

Function LogRespawnSnapshot(Int level, String msg)
    if Controller && Controller.Config
        Controller.Config.LogComponentSnapshot("Respawn", level, msg)
        return
    endif

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [Snapshot] [" + levelText + "] [Respawn] " + msg)
EndFunction


; --- Respawn Runtime ---
; =======================

Function ResetTransientState()
    _respawnQuest = None
    _respawnAvailable = False

    _pendingDisableRespawn = False
    _respawnWindowArmed = False
    _pendingDisableRespawnStartedAt = 0.0

    _pendingRespawnMenu = False
    _respawnMenuArmed = False
    _respawnWarningAt = 0.0
EndFunction

Function RefreshRuntime()
    _respawnQuest = None
    _respawnAvailable = False

    if !HasCoreRuntime()
        return
    endif

    if !Controller.Config.IsRespawnEnabled()
        if Controller.Globals
            Controller.Globals.SyncIntegrationStatus(Game.GetPlayer())
        endif
        return
    endif

    Form f = Game.GetFormFromFile(0x00000D61, "Respawn - Death Overhaul.esp")
    Quest q = f as Quest
    if q
        _respawnQuest = q
        _respawnAvailable = True
        LogRespawn(IronSoulConfig.LOG_INFO(), "RefreshRespawnRuntime: Respawn quest resolved: running=" + q.IsRunning())
    else
        _respawnAvailable = False
        LogRespawn(IronSoulConfig.LOG_INFO(), "RefreshRespawnRuntime: Respawn quest not found; treating Respawn integration as disabled")
    endif
    if Controller.Globals
        Controller.Globals.SyncIntegrationStatus(Game.GetPlayer())
    endif
EndFunction

Bool Function IsRuntimeAvailable()
    if !HasCoreRuntime()
        return False
    endif
    return IsResolvedRuntimeAvailable()
EndFunction

Bool Function IsResolvedRuntimeAvailable()
    if !Controller.Config.IsRespawnEnabled()
        return False
    endif
    if !_respawnAvailable || _respawnQuest == None
        return False
    endif
    return _respawnQuest.IsRunning()
EndFunction

Bool Function ShouldForceDeathBeforeLuck(Actor player)
    if !IsRuntimeAvailable()
        return False
    endif
    if IsBlockedByTransform(player)
        LogRespawn(IronSoulConfig.LOG_INFO(), "HandlePlayerDying: Respawn blocked while transformed race=" + player.GetRace())
        return True
    endif
    return False
EndFunction

Bool Function TryStartRespawn(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        LogRespawn(IronSoulConfig.LOG_ERR(), "TryStartRespawn: Invalid args (player None or GUID empty); aborting respawn handler")
        return False
    endif
    if !IsResolvedRuntimeAvailable()
        LogRespawn(IronSoulConfig.LOG_INFO(), "TryStartRespawn: Respawn integration unavailable; routing to HandleDeathAndQuit")
        return False
    endif
    if IsBlockedByTransform(player)
        LogRespawn(IronSoulConfig.LOG_INFO(), "TryStartRespawn: Respawn blocked while transformed race=" + player.GetRace())
        return False
    endif

    if Controller.Luck && Controller.Luck.IsRuntimeAvailable()
        Controller.Luck.ResetValue(player, guid)
        Controller.Luck.ForcePersistNow(player, guid)
        LogRespawn(IronSoulConfig.LOG_INFO(), "TryStartRespawn: Resetting luck")
    endif

    LogRespawn(IronSoulConfig.LOG_INFO(), "TryStartRespawn: Begin respawn")

    _respawnWindowArmed = True
    LogRespawn(IronSoulConfig.LOG_INFO(), "TryStartRespawn: Armed respawn window")
    player.GetActorBase().SetEssential(True)
    player.EndDeferredKill()
    LogRespawn(IronSoulConfig.LOG_INFO(), "TryStartRespawn: Armed respawn window + SetEssential(TRUE) + EndDeferredKill()")

    if Controller.Config.IsRespawnMessageEnabled()
        Controller.Presentation.FadeMusicForTransitionSequence()
    endif

    Bool introShown = Controller.Presentation.ShowIronIntro(player, guid)

    if introShown && !Controller.Config.IsRespawnMessageEnabled()
        Controller.Presentation.RestoreMusic()
    endif

    _pendingRespawnMenu = True
    _respawnMenuArmed = False

    Sound heavyBreathingSFX = Controller.SFX.PickHeavyBreathingForPlayer(player)
    Int heavyBreathingRace = 0
    Int heavyBreathingSex = 0
    Race heavyBreathingRaceRef = player.GetRace()
    ActorBase heavyBreathingBase = player.GetActorBase()
    if heavyBreathingRaceRef
        heavyBreathingRace = heavyBreathingRaceRef.GetFormID()
    endif
    if heavyBreathingBase
        heavyBreathingSex = heavyBreathingBase.GetSex()
    endif
    LogRespawn(IronSoulConfig.LOG_INFO(), "TryStartRespawn: HeavyBreathing race=" + heavyBreathingRace + " sex=" + heavyBreathingSex + " sfx=" + heavyBreathingSFX)
    Utility.Wait(1.0)
    Controller.SFX.Play(heavyBreathingSFX, player)
    Utility.Wait(8.0)

    Controller.Death.ClearDeathEventLock()
    UpdatePlayerProtectionState(player)

    player.StartDeferredKill()
    LogRespawn(IronSoulConfig.LOG_INFO(), "TryStartRespawn: StartDeferredKill()")

    LogRespawn(IronSoulConfig.LOG_INFO(), "TryStartRespawn: Respawn finished")

    _pendingDisableRespawnStartedAt = Utility.GetCurrentRealTime()
    _pendingDisableRespawn = True
    return True
EndFunction

Bool Function Tick(Actor player)
    if !_pendingDisableRespawn && !_pendingRespawnMenu && !_respawnWindowArmed
        return False
    endif

    if !HasCoreRuntime()
        return False
    endif

    Bool runtimeAvailable = IsResolvedRuntimeAvailable()
    HandleRespawnMenuWithRuntime(player, runtimeAvailable)
    return HandleDisableRespawnWithRuntime(player, runtimeAvailable)
EndFunction

Bool Function RequiresFastPolling()
    return _pendingDisableRespawn
EndFunction

Function UpdatePlayerProtectionState(Actor player)
    if !HasCoreRuntime()
        return
    endif
    if !player
        LogRespawn(IronSoulConfig.LOG_ERR(), "UpdatePlayerProtectionState: Player is None; skipping")
        return
    endif

    if player.IsDead() || player.IsBleedingOut() || (Controller.Death && Controller.Death.IsDeathEventLocked())
        return
    endif

    if !IsResolvedRuntimeAvailable()
        if player.IsEssential()
            player.GetActorBase().SetEssential(False)
            LogRespawn(IronSoulConfig.LOG_INFO(), "UpdatePlayerProtectionState: SetEssential(FALSE) reason=respawn_unavailable")
        endif
        return
    endif

    if _respawnWindowArmed
        if !player.IsEssential()
            player.GetActorBase().SetEssential(True)
            LogRespawn(IronSoulConfig.LOG_INFO(), "UpdatePlayerProtectionState: SetEssential(TRUE) reason=respawn_window_armed")
        endif
        return
    endif

    if player.IsEssential()
        player.GetActorBase().SetEssential(False)
        LogRespawn(IronSoulConfig.LOG_INFO(), "UpdatePlayerProtectionState: SetEssential(FALSE) reason=respawn_window_disarmed")
    endif
EndFunction

Function LogSnapshot()
    if !HasCoreRuntime()
        return
    endif

    Bool hasRespawn = (_respawnQuest != None)
    Bool respawnRunning = (hasRespawn && _respawnQuest.IsRunning())

    LogRespawnSnapshot(IronSoulConfig.LOG_INFO(), "Respawn: Present=" + hasRespawn \
        + " Running=" + respawnRunning \
        + " Respawn=" + (Controller.Config.IsRespawnEnabled()) \
        + " Available=" + _respawnAvailable \
        + " WindowArmed=" + _respawnWindowArmed \
        + " PendingDisable=" + _pendingDisableRespawn \
        + " PendingMenu=" + _pendingRespawnMenu \
        + " MenuArmed=" + _respawnMenuArmed)

    if Controller.Config.IsRespawnEnabled() && !hasRespawn
        LogRespawnSnapshot(IronSoulConfig.LOG_INFO(), "Respawn optional dependency not resolved; integration disabled")
    endif

    if hasRespawn && Controller.Config.IsRespawnEnabled() && !respawnRunning
        LogRespawnSnapshot(IronSoulConfig.LOG_ERR(), "WARNING: Respawn quest present but NOT running")
    endif
EndFunction


; --- Respawn Helpers ---
; =======================

Bool Function IsBlockedByTransform(Actor player)
    if !HasCoreRuntime() || !player || !Controller.BeastList
        return False
    endif

    Race currentRace = player.GetRace()
    if !currentRace
        return False
    endif

    return Controller.BeastList.HasForm(currentRace)
EndFunction

Bool Function HandleDisableRespawn(Actor player)
    if !HasCoreRuntime()
        return False
    endif
    return HandleDisableRespawnWithRuntime(player, IsResolvedRuntimeAvailable())
EndFunction

Bool Function HandleDisableRespawnWithRuntime(Actor player, Bool runtimeAvailable)
    if !player
        return False
    endif

    if _pendingDisableRespawn
        Float nowRT = Utility.GetCurrentRealTime()
        if _pendingDisableRespawnStartedAt <= 0.0
            _pendingDisableRespawnStartedAt = nowRT
        elseif (nowRT - _pendingDisableRespawnStartedAt) > Controller.PendingFastLoopWatchdogSeconds
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: watchdog cleared pending disable-respawn after " + (nowRT - _pendingDisableRespawnStartedAt) + "s")
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: Calling HandleDeathAndQuit")
            ClearPendingRespawnState()
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: Disarmed respawn window reason=watchdog_timeout")
            Controller.Death.HandleDeathAndQuit(player)
            return False
        endif
    endif

    if !runtimeAvailable
        if _pendingDisableRespawn || _respawnWindowArmed
            _pendingDisableRespawn = False
            _respawnWindowArmed = False
            _pendingDisableRespawnStartedAt = 0.0
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: Disarmed respawn window reason=respawn_unavailable")
        endif
        return False
    endif

    if _pendingDisableRespawn
        LogRespawn(IronSoulConfig.LOG_DBG(), "HandleDisableRespawn: pending disable respawn. dead=" + player.IsDead() + " bleed=" + player.IsBleedingOut())
        if player.IsDead() && !player.IsBleedingOut()
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: Player is dead; clearing pending disable-respawn state")
            ClearPendingRespawnState()
            Controller.Death.ClearDeathEventLock()
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: Disarmed respawn window reason=player_dead_before_recovery")
            return False
        endif
        if !player.IsBleedingOut() && !player.IsDead()
            if _pendingRespawnMenu && !_respawnMenuArmed
                _respawnMenuArmed = True
                _respawnWarningAt = Utility.GetCurrentRealTime() + 1.0
            endif

            _pendingDisableRespawn = False
            _respawnWindowArmed = False
            Controller.Death.ClearDeathEventLock()
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: Disarmed respawn window reason=recovered_from_bleedout")
            UpdatePlayerProtectionState(player)
            return False
        else
            Controller.QueueUpdate(Controller.FastPollSeconds)
            return True
        endif
    endif
    return False
EndFunction

Function HandleRespawnMenu(Actor player)
    if !HasCoreRuntime()
        return
    endif
    HandleRespawnMenuWithRuntime(player, IsResolvedRuntimeAvailable())
EndFunction

Function HandleRespawnMenuWithRuntime(Actor player, Bool runtimeAvailable)
    if !runtimeAvailable
        if _pendingRespawnMenu || _respawnMenuArmed
            _pendingRespawnMenu = False
            _respawnMenuArmed = False
            _respawnWarningAt = 0.0
        endif
        return
    endif

    if !_pendingRespawnMenu || !_respawnMenuArmed
        return
    endif

    if Utility.GetCurrentRealTime() < _respawnWarningAt
        return
    endif

    if Utility.IsInMenuMode()
        return
    endif

    _pendingRespawnMenu = False
    _respawnMenuArmed = False

    if player && !player.IsDead() && Controller.Config.IsRespawnMessageEnabled()
        String guid = Controller.Identity.GetTickGuid(player)
        if guid != ""
            Int soulTier = 1
            if Controller.Tiers
                soulTier = Controller.Tiers.GetCurrentTier(player, guid)
            endif
            Controller.Presentation.OpenTimedMessageSWF_SFX(IronSoulUI.ResolveRespawnMenu(soulTier), 6.0, Controller.SFX.SFXRespawn, player)
        endif
    endif
EndFunction

Function ClearPendingRespawnState()
    _pendingDisableRespawn = False
    _pendingRespawnMenu = False
    _respawnMenuArmed = False
    _respawnWindowArmed = False
    _pendingDisableRespawnStartedAt = 0.0
    _respawnWarningAt = 0.0
EndFunction
