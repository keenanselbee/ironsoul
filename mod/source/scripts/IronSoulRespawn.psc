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
; SyncDisplayDifficulty()
; IsRuntimeAvailable()
; IsResolvedRuntimeAvailable()
; ShouldForceDeathBeforeLuck()
; ArmRespawnWindow()
; QueueRespawnBlackFade()
; TryStartRespawn()
; Tick()
; RequiresFastPolling()
; HasPendingRespawnState()
; UpdatePlayerProtectionState()
; LogSnapshot()

; --- Respawn Helpers ---
; -----------------------
; BeginRespawnMenuBlock()
; EndRespawnMenuBlock()
; IsBlockedByTransform()
; HandleRespawnBlackFade()
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
Int _respawnMenuBlockToken = 0

Bool _pendingRespawnBlackFade = False
Bool _respawnBlackFadeStarted = False
Float _respawnBlackFadeAt = 0.0
Float _respawnBlackFadeStartedAt = 0.0
Float _respawnBlackFadeOutCompleteAt = 0.0
Float _respawnBlackFadeSeconds = 0.0


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

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [Respawn] " + msg)
EndFunction

Function LogRespawnSnapshot(Int level, String msg)
    if Controller && Controller.Config
        Controller.Config.LogComponentSnapshot("Respawn", level, msg)
        return
    endif

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [Snapshot] " + msg)
EndFunction


; --- Respawn Runtime ---
; =======================

Function ResetTransientState()
    ClearPendingRespawnState("reset")
    _respawnQuest = None
    _respawnAvailable = False
EndFunction

Function RefreshRuntime()
    _respawnQuest = None
    _respawnAvailable = False

    if !HasCoreRuntime()
        return
    endif

    if !Controller.Config.IsRespawnEnabled()
        SyncDisplayDifficulty()
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
    SyncDisplayDifficulty()
    if Controller.Globals
        Controller.Globals.SyncIntegrationStatus(Game.GetPlayer())
    endif
EndFunction

Function SyncDisplayDifficulty()
    if !HasCoreRuntime()
        return
    endif

    Bool draugnarokEnabled = False
    _DS_DN_Draugnarok draugnarok = Controller.ResolveDraugnarokQuest()
    if draugnarok
        draugnarokEnabled = draugnarok.IsDraugnarokSystemEnabled()
    endif
    Controller.Config.SyncEffectiveDisplayDifficulty(IsResolvedRuntimeAvailable(), draugnarokEnabled)
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
    if !ArmRespawnWindow(player, guid)
        return False
    endif

    if Controller.Luck && Controller.Luck.IsRuntimeAvailable()
        Controller.Luck.ResetValue(player, guid)
        Controller.Luck.ForcePersistNow(player, guid)
        LogRespawn(IronSoulConfig.LOG_INFO(), "TryStartRespawn: Resetting luck")
    endif

    LogRespawn(IronSoulConfig.LOG_INFO(), "TryStartRespawn: Begin respawn")

    BeginRespawnMenuBlock()

    if Controller.Config.IsRespawnMenuEnabled()
        Controller.Presentation.FadeMusicForTransitionSequence()
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
    if !_pendingDisableRespawn && !_pendingRespawnMenu && !_respawnWindowArmed && !_pendingRespawnBlackFade && !_respawnBlackFadeStarted && _respawnBlackFadeOutCompleteAt <= 0.0
        EndRespawnMenuBlock("no-pending-state")
        return False
    endif

    if !HasCoreRuntime()
        return False
    endif

    Bool runtimeAvailable = IsResolvedRuntimeAvailable()
    HandleRespawnBlackFade()
    HandleRespawnMenuWithRuntime(player, runtimeAvailable)
    return HandleDisableRespawnWithRuntime(player, runtimeAvailable)
EndFunction

Bool Function RequiresFastPolling()
    return _pendingDisableRespawn || _pendingRespawnMenu || _respawnWindowArmed || _pendingRespawnBlackFade || _respawnBlackFadeStarted || _respawnBlackFadeOutCompleteAt > 0.0
EndFunction

Bool Function HasPendingRespawnState()
    return _pendingDisableRespawn || _pendingRespawnMenu || _respawnMenuArmed || _respawnWindowArmed || _pendingRespawnBlackFade || _respawnBlackFadeStarted || _respawnBlackFadeOutCompleteAt > 0.0 || _respawnMenuBlockToken > 0
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
        + " Available=" + _respawnAvailable)

    LogRespawnSnapshot(IronSoulConfig.LOG_INFO(), "Respawn State: WindowArmed=" + _respawnWindowArmed \
        + " PendingDisable=" + _pendingDisableRespawn \
        + " PendingMenu=" + _pendingRespawnMenu \
        + " MenuArmed=" + _respawnMenuArmed \
        + " PendingBlackFade=" + _pendingRespawnBlackFade \
        + " BlackFadeStarted=" + _respawnBlackFadeStarted \
        + " BlackFadeOutCompleteAt=" + _respawnBlackFadeOutCompleteAt)

    if Controller.Config.IsRespawnEnabled() && !hasRespawn
        LogRespawnSnapshot(IronSoulConfig.LOG_INFO(), "Respawn optional dependency not resolved; integration disabled")
    endif

    if hasRespawn && Controller.Config.IsRespawnEnabled() && !respawnRunning
        LogRespawnSnapshot(IronSoulConfig.LOG_ERR(), "Respawn: Quest present but NOT running")
    endif
EndFunction


; --- Respawn Helpers ---
; =======================

Function BeginRespawnMenuBlock()
    if _respawnMenuBlockToken > 0
        return
    endif

    _respawnMenuBlockToken = IronSoulNative.BeginMenuBlock("respawn", False)
    if _respawnMenuBlockToken > 0
        LogRespawn(IronSoulConfig.LOG_INFO(), "BeginRespawnMenuBlock: token=" + _respawnMenuBlockToken)
    endif
EndFunction

Function EndRespawnMenuBlock(String reason = "")
    Int token = _respawnMenuBlockToken
    _respawnMenuBlockToken = 0
    if token <= 0
        return
    endif

    IronSoulNative.EndMenuBlock(token)
    if reason != ""
        LogRespawn(IronSoulConfig.LOG_INFO(), "EndRespawnMenuBlock: reason=" + reason + " token=" + token)
    endif
EndFunction

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

Bool Function ArmRespawnWindow(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        LogRespawn(IronSoulConfig.LOG_ERR(), "ArmRespawnWindow: Invalid args (player None or GUID empty); aborting respawn handler")
        return False
    endif
    if !IsResolvedRuntimeAvailable()
        LogRespawn(IronSoulConfig.LOG_INFO(), "ArmRespawnWindow: Respawn integration unavailable; routing to HandleDeathAndQuit")
        return False
    endif
    if IsBlockedByTransform(player)
        LogRespawn(IronSoulConfig.LOG_INFO(), "ArmRespawnWindow: Respawn blocked while transformed race=" + player.GetRace())
        return False
    endif
    if _respawnWindowArmed
        return True
    endif

    _respawnWindowArmed = True
    player.GetActorBase().SetEssential(True)
    player.EndDeferredKill()
    LogRespawn(IronSoulConfig.LOG_INFO(), "ArmRespawnWindow: Armed respawn window + SetEssential(TRUE) + EndDeferredKill()")
    return True
EndFunction

Function QueueRespawnBlackFade(Float delaySeconds = 3.0, Float fadeSeconds = 6.0)
    if !HasCoreRuntime()
        return
    endif
    if !Controller.Config.IsRedTintOnDeathEnabled()
        return
    endif
    if delaySeconds < 0.0
        delaySeconds = 0.0
    endif
    if fadeSeconds <= 0.0
        fadeSeconds = 0.1
    endif

    _pendingRespawnBlackFade = True
    _respawnBlackFadeStarted = False
    _respawnBlackFadeAt = Utility.GetCurrentRealTime() + delaySeconds
    _respawnBlackFadeSeconds = fadeSeconds
    LogRespawn(IronSoulConfig.LOG_INFO(), "QueueRespawnBlackFade: delay=" + delaySeconds + " fade=" + fadeSeconds)
    Controller.QueueUpdate(Controller.FastPollSeconds)
EndFunction

Function HandleRespawnBlackFade()
    if !_pendingRespawnBlackFade
        return
    endif
    if Utility.GetCurrentRealTime() < _respawnBlackFadeAt
        return
    endif
    if Utility.IsInMenuMode()
        return
    endif

    _pendingRespawnBlackFade = False
    _respawnBlackFadeStartedAt = Utility.GetCurrentRealTime()
    if Controller.Death && Controller.Death.PlayBlackScreenImod(_respawnBlackFadeSeconds)
        _respawnBlackFadeStarted = True
        LogRespawn(IronSoulConfig.LOG_INFO(), "HandleRespawnBlackFade: started fade=" + _respawnBlackFadeSeconds)
    else
        Float fadeOutSeconds = 3.0
        ImageSpaceModifier.RemoveCrossFade(fadeOutSeconds)
        IronSoulNative.StartTimeMultiplierRamp(0.5, 1.0, fadeOutSeconds, "respawn-route-fadeout")
        _respawnBlackFadeOutCompleteAt = _respawnBlackFadeStartedAt + fadeOutSeconds
        LogRespawn(IronSoulConfig.LOG_INFO(), "HandleRespawnBlackFade: black IMOD unavailable; fading out route IMOD before menu")
    endif
EndFunction

Bool Function HandleDisableRespawn(Actor player)
    if !HasCoreRuntime()
        return False
    endif
    return HandleDisableRespawnWithRuntime(player, IsResolvedRuntimeAvailable())
EndFunction

Bool Function HandleDisableRespawnWithRuntime(Actor player, Bool runtimeAvailable)
    if !player
        if _pendingDisableRespawn || _respawnWindowArmed || _pendingRespawnMenu || _respawnMenuArmed || _respawnMenuBlockToken > 0
            ClearPendingRespawnState("player-unavailable")
        endif
        return False
    endif

    if _pendingDisableRespawn
        Float nowRT = Utility.GetCurrentRealTime()
        if _pendingDisableRespawnStartedAt <= 0.0
            _pendingDisableRespawnStartedAt = nowRT
        elseif (nowRT - _pendingDisableRespawnStartedAt) > Controller.PendingFastLoopWatchdogSeconds
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: watchdog cleared pending disable-respawn after " + (nowRT - _pendingDisableRespawnStartedAt) + "s")
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: Calling HandleDeathAndQuit")
            ClearPendingRespawnState("watchdog-timeout", False)
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: Disarmed respawn window reason=watchdog_timeout")
            Controller.Death.HandleDeathAndQuit(player)
            return False
        endif
    endif

    if !runtimeAvailable
        if _pendingDisableRespawn || _respawnWindowArmed || _pendingRespawnMenu || _respawnMenuArmed || _respawnMenuBlockToken > 0
            ClearPendingRespawnState("runtime-unavailable")
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: Disarmed respawn window reason=respawn_unavailable")
        endif
        return False
    endif

    if _pendingDisableRespawn
        LogRespawn(IronSoulConfig.LOG_DBG(), "HandleDisableRespawn: pending disable respawn. dead=" + player.IsDead() + " bleed=" + player.IsBleedingOut())
        if player.IsDead() && !player.IsBleedingOut()
            LogRespawn(IronSoulConfig.LOG_INFO(), "HandleDisableRespawn: Player is dead; clearing pending disable-respawn state")
            ClearPendingRespawnState("player-dead-before-recovery")
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
        if _pendingRespawnMenu || _respawnMenuArmed || _respawnMenuBlockToken > 0
            ClearPendingRespawnState("menu-runtime-unavailable")
        endif
        return
    endif

    if !_pendingRespawnMenu || !_respawnMenuArmed
        return
    endif

    Float nowRT = Utility.GetCurrentRealTime()
    if _pendingRespawnBlackFade
        return
    endif
    if _respawnBlackFadeStarted
        if nowRT < (_respawnBlackFadeStartedAt + _respawnBlackFadeSeconds)
            return
        endif
        Float fadeOutSeconds = 3.0
        ImageSpaceModifier.RemoveCrossFade(fadeOutSeconds)
        IronSoulNative.StartTimeMultiplierRamp(0.5, 1.0, fadeOutSeconds, "respawn-black-fadeout")
        _respawnBlackFadeStarted = False
        _respawnBlackFadeOutCompleteAt = nowRT + fadeOutSeconds
        LogRespawn(IronSoulConfig.LOG_INFO(), "HandleRespawnMenu: black fade complete; fading out before menu")
        return
    endif
    if _respawnBlackFadeOutCompleteAt > 0.0
        if nowRT < _respawnBlackFadeOutCompleteAt
            return
        endif
        _respawnBlackFadeOutCompleteAt = 0.0
        IronSoulNative.ClearTimeMultiplierRamp("respawn-black-fadeout-complete")
    endif

    if Utility.GetCurrentRealTime() < _respawnWarningAt
        return
    endif

    if Utility.IsInMenuMode()
        return
    endif

    _pendingRespawnMenu = False
    _respawnMenuArmed = False

    if player && !player.IsDead()
        if Controller.Config.IsRespawnMenuEnabled()
            String guid = Controller.Identity.GetTickGuid(player)
            if guid != ""
                Int soulTier = 1
                if Controller.Tiers
                    soulTier = Controller.Tiers.GetCurrentTier(player, guid)
                endif
                Controller.Presentation.OpenTimedMessageSWF_SFX(IronSoulUI.ResolveRespawnMenu(soulTier), 6.0, Controller.SFX.SFXRespawn, player)
            endif
            IronSoulNative.ReleaseDeathSlowMo(1.0, 0.0, "respawn-menu-complete")
        else
            IronSoulNative.ReleaseDeathSlowMo(1.0, 0.0, "respawn-message-disabled")
        endif
    else
        IronSoulNative.ReleaseDeathSlowMo(1.0, 0.0, "respawn-menu-skipped")
    endif
    _respawnBlackFadeStarted = False
    EndRespawnMenuBlock("respawn-menu-complete")
EndFunction

Function ClearPendingRespawnState(String reason = "clear-pending-respawn", Bool clearSlowMo = True)
    Bool hadPendingState = _pendingDisableRespawn || _pendingRespawnMenu || _respawnMenuArmed || _respawnWindowArmed || _pendingRespawnBlackFade || _respawnBlackFadeStarted || _respawnBlackFadeOutCompleteAt > 0.0 || _respawnMenuBlockToken > 0

    EndRespawnMenuBlock(reason)

    _pendingDisableRespawn = False
    _pendingRespawnMenu = False
    _respawnMenuArmed = False
    _respawnWindowArmed = False
    _pendingDisableRespawnStartedAt = 0.0
    _respawnWarningAt = 0.0
    _pendingRespawnBlackFade = False
    _respawnBlackFadeStarted = False
    _respawnBlackFadeAt = 0.0
    _respawnBlackFadeStartedAt = 0.0
    _respawnBlackFadeOutCompleteAt = 0.0
    _respawnBlackFadeSeconds = 0.0

    if clearSlowMo && hadPendingState
        ImageSpaceModifier.RemoveCrossFade(0.75)
        IronSoulNative.ClearTimeMultiplierRamp("respawn-" + reason)
        IronSoulNative.ClearDeathSlowMo("respawn-" + reason)
    endif
EndFunction
