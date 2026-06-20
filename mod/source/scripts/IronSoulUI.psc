Scriptname IronSoulUI extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()
; HasMusicRuntime()
; LogUI()

; --- Presentation Runtime ---
; ----------------------------
; ResetTransientState()
; RegisterMusicFadeBridge()
; ExtractMusicFadeEventField()
; ParseMusicFadeEventToken()
; ParseMusicFadeEventStep()
; ClearMusicFadeFinalVolumeState()
; ClearMusicFadeVolumeOrderState()
; ResetMusicFadeSessionToken()
; SetMusicFadeEventToken()
; PrepareMusicFadeTokenAdvance()
; AcceptMusicFadeEventToken()
; AcceptMusicFadeVolumeOrder()
; ClampMusicFadeVolume()
; MarkMusicFadeFinalVolumeApplied()
; HasMusicFadeFinalVolumeApplied()
; RegisterMusicVolumeCacheMenus()
; ScheduleLoadMessage()
; ClearDelayedIronIntro()
; ScheduleIronIntroFromNewGameClock()
; RequiresFastPolling()
; HandleLoadNotification()
; HandleDelayedIronIntro()
; OpenTimedMessageSWF()
; OpenTimedMessageSWF_SFX()
; OpenTimedMessageSWF_KeyDismiss()
; OpenTimedMessageSWF_KeyDismissTrackedSFX()
; OpenTimedMessageSWF_KeyDismiss_SFX()
; OpenTimedMessageSWF_KeyDismissIronIntro()
; OpenKeyDismissMenu()
; WaitKeyDismissMenu()
; PlayPresentationSFX()
; MarkPendingIronIntroShown()
; ShouldShowIronIntro()
; ShowIronIntro()
; RefreshConfiguredMusicVolumeCache()
; InvalidateConfiguredMusicVolumeCache()
; ResolveConfiguredMusicVolume()
; HandleMusicAfterPlayerLoad()
; FadeMusicForTransitionSequence()
; RestoreMusic()
; OnKeyDown()
; RegisterForAllKeys()
; UnregisterForAllKeys()
; OnMenuClose()
; OnMusicFadeSetVolume()
; OnMusicFadeComplete()

; --- Menu Naming ---
; -------------------
; TierMenuPrefix()
; SwfNoBonus()
; ResolveDeathMenu()
; ResolvePermadeathMenu()
; ResolveRespawnMenu()
; ResolveSoulFeatUnlockMenuFromFacts()
; ResolveDefiantFeatUnlockMenu()
; ResolveDefiantTransitionMenu()
; ResolveCHIMTransitionMenu()
; IsLuckRollMenu()
; ResolveLuckThresholdNotification()

; --- Load Notification Text ---
; ------------------------------
; BuildLoadStatsNotification()


; --- Wired Dependencies & Runtime State ---
; ==========================================

IronSoulController Property Controller Auto

; Music fade
SoundCategory Property AudioCategoryMUS Auto

Bool _keyDismissActive = False
Bool _keyDismissPressed = False
Float _keyDismissPressedAt = 0.0

Bool _pendingLoadMessage = False
Float _loadMessageAt = 0.0
Float _pendingLoadMessageStartedAt = 0.0

Bool _pendingIronIntro = False
String _pendingIronIntroGuid = ""
Float _ironIntroAt = 0.0
Float _ironIntroTargetSeconds = 0.0
Bool _ironIntroShownThisSession = False
Bool _ironIntroShownPendingGuid = False

Float IRON_INTRO_MAX_SECONDS = 30.0
Float IRON_INTRO_MIN_DISMISS_SECONDS = 2.0
Float IRON_INTRO_CLOSE_SFX_MAX_SECONDS = 13.5
Float TRANSITION_SFX_FADE_SECONDS = 1.0

Float _cachedMenuMusicVolume = 1.0
Bool _menuMusicVolumeCached = False
String _menuMusicVolumeCacheReason = ""
Bool _musicFadeActive = False
Bool _menuMusicVolumeRefreshPending = False
Int _musicFadeToken = 0
Bool _musicFadeTokenValid = False
Bool _musicFadeAwaitingNewToken = False
Int _musicFadeFinalVolumeToken = 0
Bool _musicFadeFinalVolumeApplied = False
Int _musicFadeVolumeOrderToken = 0
Int _musicFadeVolumeOrderStep = 0


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Identity || !Controller.Persistence
        return False
    endif
    if !Controller.Death || !Controller.Tiers || !Controller.SFX
        return False
    endif
    return True
EndFunction

Bool Function HasMusicRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !AudioCategoryMUS
        return False
    endif
    if !Controller.Config.IsMusicFadeEnabled()
        return False
    endif
    return True
EndFunction

Function LogUI(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("UI", level, msg, suppressNotify)
        return
    endif

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [UI] " + msg)
EndFunction


; --- Presentation Runtime ---
; ============================

Function ResetTransientState()
    _keyDismissActive = False
    _keyDismissPressed = False
    _keyDismissPressedAt = 0.0
    UnregisterForAllKeys()

    _pendingLoadMessage = False
    _loadMessageAt = 0.0
    _pendingLoadMessageStartedAt = 0.0

    ClearDelayedIronIntro()
    _ironIntroShownThisSession = False
    _ironIntroShownPendingGuid = False
EndFunction

Function RegisterMusicFadeBridge()
    UnregisterForModEvent("IronSoul_MusicFadeSetVolume")
    UnregisterForModEvent("IronSoul_MusicFadeComplete")
    ResetMusicFadeSessionToken()
    RegisterForModEvent("IronSoul_MusicFadeSetVolume", "OnMusicFadeSetVolume")
    RegisterForModEvent("IronSoul_MusicFadeComplete", "OnMusicFadeComplete")
EndFunction

String Function ExtractMusicFadeEventField(String payload, String fieldName)
    if payload == "" || fieldName == ""
        return ""
    endif

    String prefix = fieldName + "="
    Int valueStart = StringUtil.Find(payload, prefix)
    if valueStart == -1
        return ""
    endif

    valueStart += StringUtil.GetLength(prefix)
    Int valueEnd = StringUtil.Find(payload, ";", valueStart)
    if valueEnd == -1
        return StringUtil.Substring(payload, valueStart)
    endif
    return StringUtil.Substring(payload, valueStart, valueEnd - valueStart)
EndFunction

Int Function ParseMusicFadeEventToken(String payload)
    String tokenText = ExtractMusicFadeEventField(payload, "token")
    if tokenText == ""
        return -1
    endif
    return tokenText as Int
EndFunction

Int Function ParseMusicFadeEventStep(String payload)
    String stepText = ExtractMusicFadeEventField(payload, "step")
    if stepText == ""
        return 0
    endif
    return stepText as Int
EndFunction

Function ClearMusicFadeFinalVolumeState()
    _musicFadeFinalVolumeToken = 0
    _musicFadeFinalVolumeApplied = False
EndFunction

Function ClearMusicFadeVolumeOrderState()
    _musicFadeVolumeOrderToken = 0
    _musicFadeVolumeOrderStep = 0
EndFunction

Function ResetMusicFadeSessionToken()
    _musicFadeToken = 0
    _musicFadeTokenValid = False
    _musicFadeAwaitingNewToken = False
    ClearMusicFadeFinalVolumeState()
    ClearMusicFadeVolumeOrderState()
EndFunction

Function SetMusicFadeEventToken(Int token)
    if token != _musicFadeToken
        ClearMusicFadeFinalVolumeState()
        ClearMusicFadeVolumeOrderState()
    endif

    _musicFadeToken = token
    _musicFadeTokenValid = True
    _musicFadeAwaitingNewToken = False
EndFunction

Function PrepareMusicFadeTokenAdvance()
    _musicFadeAwaitingNewToken = True
EndFunction

Bool Function AcceptMusicFadeEventToken(Int token, String kind)
    if token <= 0
        LogUI(IronSoulConfig.LOG_INFO(), "Music fade event ignored without valid token: kind=" + kind + " token=" + token, True)
        return False
    endif

    if _musicFadeAwaitingNewToken
        if _musicFadeToken > 0 && token <= _musicFadeToken
            LogUI(IronSoulConfig.LOG_DBG(), "Music fade stale event ignored while awaiting new token: kind=" + kind \
                + " token=" + token \
                + " current=" + _musicFadeToken, True)
            return False
        endif
        SetMusicFadeEventToken(token)
        return True
    endif

    if _musicFadeTokenValid
        if token == _musicFadeToken
            return True
        endif
        if token < _musicFadeToken
            LogUI(IronSoulConfig.LOG_DBG(), "Music fade stale event ignored: kind=" + kind \
                + " token=" + token \
                + " current=" + _musicFadeToken, True)
            return False
        endif
    elseif _musicFadeToken > 0 && token <= _musicFadeToken
        LogUI(IronSoulConfig.LOG_DBG(), "Music fade late event ignored after token completed: kind=" + kind \
            + " token=" + token \
            + " current=" + _musicFadeToken, True)
        return False
    else
        LogUI(IronSoulConfig.LOG_DBG(), "Music fade unsolicited event ignored: kind=" + kind \
            + " token=" + token, True)
        return False
    endif

    LogUI(IronSoulConfig.LOG_DBG(), "Music fade token synchronized: kind=" + kind \
        + " previous=" + _musicFadeToken \
        + " next=" + token, True)
    SetMusicFadeEventToken(token)
    return True
EndFunction

Bool Function AcceptMusicFadeVolumeOrder(Int token, Int step, String kind)
    if kind != "step" && kind != "final" && kind != "recovery"
        return True
    endif

    if step <= 0
        if kind == "step"
            LogUI(IronSoulConfig.LOG_INFO(), "Music fade step event ignored without valid step: token=" + token \
                + " step=" + step, True)
            return False
        endif
        step = 999999
    endif

    if _musicFadeVolumeOrderToken == token && step <= _musicFadeVolumeOrderStep
        LogUI(IronSoulConfig.LOG_DBG(), "Music fade out-of-order volume ignored: token=" + token \
            + " kind=" + kind \
            + " step=" + step \
            + " currentStep=" + _musicFadeVolumeOrderStep, True)
        return False
    endif

    _musicFadeVolumeOrderToken = token
    _musicFadeVolumeOrderStep = step
    return True
EndFunction

Float Function ClampMusicFadeVolume(Float volume)
    if volume < 0.0
        return 0.0
    endif
    if volume > 1.0
        return 1.0
    endif
    return volume
EndFunction

Function MarkMusicFadeFinalVolumeApplied(Int token)
    _musicFadeFinalVolumeToken = token
    _musicFadeFinalVolumeApplied = True
EndFunction

Bool Function HasMusicFadeFinalVolumeApplied(Int token)
    return _musicFadeFinalVolumeApplied && _musicFadeFinalVolumeToken == token
EndFunction

Function RegisterMusicVolumeCacheMenus()
    UnregisterForMenu("Journal Menu")
    UnregisterForMenu("TweenMenu")
    RegisterForMenu("Journal Menu")
    RegisterForMenu("TweenMenu")
    LogUI(IronSoulConfig.LOG_DBG(), "Music volume cache menu watchers registered: Journal Menu, TweenMenu", True)
EndFunction

Function ScheduleLoadMessage(Bool isLoadGame)
    if isLoadGame
        Float nowRT = Utility.GetCurrentRealTime()
        _pendingLoadMessage = True

        if _pendingLoadMessageStartedAt <= 0.0
            _pendingLoadMessageStartedAt = nowRT
        endif
        _loadMessageAt = nowRT + 2.00
    else
        _pendingLoadMessage = False
    endif

    if Controller
        Controller.QueueUpdate(Controller.StandardPollSeconds)
    endif
EndFunction

Function ClearDelayedIronIntro()
    _pendingIronIntro = False
    _pendingIronIntroGuid = ""
    _ironIntroAt = 0.0
    _ironIntroTargetSeconds = 0.0
EndFunction

Function ScheduleIronIntroFromNewGameClock(Actor player)
    if !HasCoreRuntime() || !player
        return
    endif

    if _pendingIronIntro || _ironIntroShownThisSession
        return
    endif

    if player.GetLevel() > 1
        return
    endif

    Float introElapsed = IronSoulNative.GetNewGameIntroElapsedSeconds()
    if introElapsed < 0.0
        return
    endif

    String guid = Controller.Identity.GetKnownGuidNoMint(player)
    if !ShouldShowIronIntro(player, guid)
        ClearDelayedIronIntro()
        return
    endif

    _ironIntroTargetSeconds = Controller.Config.GetIronSoulIntroTargetSeconds() as Float
    Float delaySeconds = _ironIntroTargetSeconds - introElapsed
    if delaySeconds < 0.0
        delaySeconds = 0.0
    endif

    _pendingIronIntro = True
    _pendingIronIntroGuid = guid
    _ironIntroAt = Utility.GetCurrentRealTime() + delaySeconds

    String displayGuid = guid
    if displayGuid == ""
        displayGuid = "<pending>"
    endif
    LogUI(IronSoulConfig.LOG_INFO(), "ScheduleIronIntroFromNewGameClock: delayed intro pending for GUID=" + displayGuid \
        + " elapsed=" + introElapsed \
        + " target=" + _ironIntroTargetSeconds \
        + " delay=" + delaySeconds + "s")

    if Controller
        Controller.QueueUpdate(delaySeconds)
    endif
EndFunction

Bool Function RequiresFastPolling(Float watchdogSeconds)
    Float nowRT = Utility.GetCurrentRealTime()
    Float introRemainingSeconds = _ironIntroAt - nowRT
    Bool ironIntroDue = _pendingIronIntro && introRemainingSeconds <= 0.0
    Bool ironIntroSoon = _pendingIronIntro && Controller && introRemainingSeconds <= Controller.StandardPollSeconds

    if !_pendingLoadMessage
        _pendingLoadMessageStartedAt = 0.0
        return ironIntroDue || ironIntroSoon
    endif

    Float elapsed = nowRT - _pendingLoadMessageStartedAt
    if watchdogSeconds > 0.0 && _pendingLoadMessageStartedAt > 0.0 && elapsed > watchdogSeconds
        _pendingLoadMessage = False
        _pendingLoadMessageStartedAt = 0.0
        LogUI(IronSoulConfig.LOG_INFO(), "RequiresFastPolling: cleared pending load message after " + elapsed + "s")
        return ironIntroDue || ironIntroSoon
    endif

    return True
EndFunction

Function HandleLoadNotification(Actor player)
    if !_pendingLoadMessage
        return
    endif

    if Utility.GetCurrentRealTime() < _loadMessageAt
        return
    endif

    if !HasCoreRuntime() || !player
        return
    endif

    String guid = Controller.Identity.GetTickGuid(player)
    if guid == ""
        _loadMessageAt = Utility.GetCurrentRealTime() + 1.0
        return
    endif

    _pendingLoadMessage = False

    if !Controller.Config.IsLoadNotificationEnabled()
        return
    endif

    Int deaths     = Controller.Death.GetCurrentDeathCount(player, guid)
    Int maxDeaths  = Controller.Tiers.GetGlobalEffectiveMaxLives(player, guid)
    Int daysPassed = Utility.GetCurrentGameTime() as Int
    Int animaVal = 245
    Int luckVal = 100
    if Controller.Luck
        luckVal = Controller.Luck.GetValue(player, guid)
    endif
    Debug.Notification(BuildLoadStatsNotification(daysPassed, deaths, maxDeaths, animaVal, luckVal))
EndFunction

Function HandleDelayedIronIntro(Actor player)
    if !_pendingIronIntro
        return
    endif

    Float nowRT = Utility.GetCurrentRealTime()
    Float introElapsed = IronSoulNative.GetNewGameIntroElapsedSeconds()
    if introElapsed >= 0.0 && _ironIntroTargetSeconds > 0.0 && introElapsed < _ironIntroTargetSeconds
        Float remainingIntroSeconds = _ironIntroTargetSeconds - introElapsed
        _ironIntroAt = nowRT + remainingIntroSeconds
        if Controller
            Controller.QueueUpdate(remainingIntroSeconds)
        endif
        return
    endif

    if introElapsed < 0.0 && nowRT < _ironIntroAt
        if Controller
            Controller.QueueUpdate(_ironIntroAt - nowRT)
        endif
        return
    endif

    if !HasCoreRuntime() || !player
        return
    endif

    if Utility.IsInMenuMode() || player.IsDead() || player.IsBleedingOut()
        return
    endif

    if _keyDismissActive
        return
    endif

    if Controller.Death && Controller.Death.IsDeathEventLocked()
        return
    endif

    if Controller.Respawn && Controller.Respawn.HasPendingRespawnState()
        return
    endif

    String guid = Controller.Identity.GetKnownGuidNoMint(player)
    if _pendingIronIntroGuid != "" && guid != "" && guid != _pendingIronIntroGuid
        LogUI(IronSoulConfig.LOG_INFO(), "HandleDelayedIronIntro: cleared pending intro after GUID changed from " + _pendingIronIntroGuid + " to " + guid)
        ClearDelayedIronIntro()
        return
    endif

    if !ShouldShowIronIntro(player, guid)
        LogUI(IronSoulConfig.LOG_INFO(), "HandleDelayedIronIntro: cleared pending intro because it is no longer eligible")
        ClearDelayedIronIntro()
        return
    endif

    Float dueAt = _ironIntroAt
    nowRT = Utility.GetCurrentRealTime()
    String displayGuid = guid
    if displayGuid == ""
        displayGuid = "<pending>"
    endif
    LogUI(IronSoulConfig.LOG_INFO(), "HandleDelayedIronIntro: opening intro for GUID=" + displayGuid \
        + " due=" + dueAt \
        + " now=" + nowRT \
        + " elapsed=" + introElapsed \
        + " target=" + _ironIntroTargetSeconds \
        + " late=" + (nowRT - dueAt) + "s")

    ClearDelayedIronIntro()
    ShowIronIntro(player, guid)
EndFunction

Function OpenTimedMessageSWF(String menuName, Float duration = 6.0, Bool restoreMusic = True)
    if menuName == ""
        return
    endif

    if duration <= 0.0
        duration = 0.1
    endif
    if IsLuckRollMenu(menuName)
        duration += 0.5
    endif

    Int cursorToken = IronSoulNative.BeginCursorSuppress()
    FadeMusicForTransitionSequence()

    UI.CloseCustomMenu()
    IronSoulNative.PrimeCursorSuppress()
    UI.OpenCustomMenu(menuName, 0)
    IronSoulNative.RefreshCursorSuppress()
    Utility.WaitMenuMode(duration)
    UI.CloseCustomMenu()
    IronSoulNative.EndCursorSuppress(cursorToken)

    if restoreMusic
        RestoreMusic()
    endif
EndFunction

Function OpenTimedMessageSWF_SFX(String swfName, Float seconds, Sound sfx, Actor player, Bool restoreMusic = True)
    PlayPresentationSFX(sfx, player)
    OpenTimedMessageSWF(swfName, seconds, restoreMusic)
EndFunction

Function OpenTimedMessageSWF_KeyDismiss(String menuName, Float maxDuration = 6.0, Float minDismissSeconds = 6.0, Bool restoreMusic = True, Bool releaseFeatSlowMoOnClose = False)
    if menuName == ""
        return
    endif

    FadeMusicForTransitionSequence()
    OpenKeyDismissMenu(menuName, maxDuration, minDismissSeconds, releaseFeatSlowMoOnClose)

    if restoreMusic
        RestoreMusic()
    endif
EndFunction

Function OpenTimedMessageSWF_KeyDismissTrackedSFX(String menuName, Float maxDuration = 6.0, Float minDismissSeconds = 6.0, Bool restoreMusic = True, Int sfxInstance = -1, Float sfxStartedAt = 0.0, Float sfxSeconds = 0.0, Bool releaseFeatSlowMoOnClose = False)
    if menuName == ""
        return
    endif

    FadeMusicForTransitionSequence()
    Bool dismissedByKey = OpenKeyDismissMenu(menuName, maxDuration, minDismissSeconds, releaseFeatSlowMoOnClose)

    if restoreMusic
        if Controller && Controller.SFX && dismissedByKey
            Controller.SFX.FadeOutInstance(sfxInstance, TRANSITION_SFX_FADE_SECONDS)
        elseif sfxInstance >= 0 && sfxStartedAt > 0.0 && sfxSeconds > 0.0
            Float elapsedSFX = Utility.GetCurrentRealTime() - sfxStartedAt
            if elapsedSFX < 0.0
                elapsedSFX = 0.0
            endif
            Float remainingSFX = sfxSeconds - elapsedSFX
            if remainingSFX > 0.0
                Utility.Wait(remainingSFX)
            endif
        endif

        RestoreMusic()
    endif
EndFunction

Function OpenTimedMessageSWF_KeyDismiss_SFX(String swfName, Float maxSeconds, Float minDismissSeconds, Sound sfx, Actor player, Bool restoreMusic = True)
    PlayPresentationSFX(sfx, player)
    OpenTimedMessageSWF_KeyDismiss(swfName, maxSeconds, minDismissSeconds, restoreMusic)
EndFunction

Function OpenTimedMessageSWF_KeyDismissIronIntro(String menuName, Float maxDuration = 6.0, Float minDismissSeconds = 6.0, Sound introSFX = None, Sound earlyCloseSFX = None, Actor player = None)
    if menuName == ""
        return
    endif

    Int introSFXInstance = -1
    if Controller && Controller.SFX
        introSFXInstance = Controller.SFX.PlayInstance(introSFX, player)
    endif
    FadeMusicForTransitionSequence()
    Float openedAt = Utility.GetCurrentRealTime()
    Bool dismissedByKey = OpenKeyDismissMenu(menuName, maxDuration, minDismissSeconds)
    if dismissedByKey && Controller && Controller.SFX
        Controller.SFX.FadeOutInstance(introSFXInstance, TRANSITION_SFX_FADE_SECONDS)
    endif

    Float dismissedAt = _keyDismissPressedAt
    if dismissedAt <= 0.0
        dismissedAt = Utility.GetCurrentRealTime()
    endif
    Float elapsedSeconds = dismissedAt - openedAt
    if dismissedByKey && elapsedSeconds <= IRON_INTRO_CLOSE_SFX_MAX_SECONDS
        PlayPresentationSFX(earlyCloseSFX, player)
    endif
EndFunction

Bool Function OpenKeyDismissMenu(String menuName, Float maxDuration = 6.0, Float minDismissSeconds = 6.0, Bool releaseFeatSlowMoOnClose = False)
    if menuName == ""
        return False
    endif

    if maxDuration <= 0.0
        maxDuration = 0.1
    endif
    if IsLuckRollMenu(menuName)
        maxDuration += 0.5
    endif
    if minDismissSeconds < 0.0
        minDismissSeconds = 0.0
    endif
    if minDismissSeconds > maxDuration
        minDismissSeconds = maxDuration
    endif

    Int cursorToken = IronSoulNative.BeginCursorSuppress()
    UI.CloseCustomMenu()
    IronSoulNative.PrimeCursorSuppress()

    UI.OpenCustomMenu(menuName, 0)
    IronSoulNative.RefreshCursorSuppress()

    Bool dismissedByKey = WaitKeyDismissMenu(maxDuration, minDismissSeconds)
    if releaseFeatSlowMoOnClose
        IronSoulNative.ReleaseFeatUnlockSlowMo(2.0, "feat-menu-close")
    endif
    IronSoulNative.EndCursorSuppress(cursorToken)
    return dismissedByKey
EndFunction

Bool Function WaitKeyDismissMenu(Float maxDuration = 6.0, Float minDismissSeconds = 6.0)
    if maxDuration <= 0.0
        maxDuration = 0.1
    endif
    if minDismissSeconds < 0.0
        minDismissSeconds = 0.0
    endif
    if minDismissSeconds > maxDuration
        minDismissSeconds = maxDuration
    endif

    _keyDismissPressed = False
    _keyDismissActive  = False
    _keyDismissPressedAt = 0.0

    if minDismissSeconds > 0.0
        Utility.WaitMenuMode(minDismissSeconds)
    endif

    Float remaining = maxDuration - minDismissSeconds
    if remaining > 0.0
        _keyDismissPressed = False
        _keyDismissActive  = True
        RegisterForAllKeys()

        while remaining > 0.0 && !_keyDismissPressed
            Utility.WaitMenuMode(0.20)
            remaining -= 0.20
        endwhile

        _keyDismissActive = False
        UnregisterForAllKeys()
    endif

    UI.CloseCustomMenu()
    return _keyDismissPressed
EndFunction

Function PlayPresentationSFX(Sound sfx, Actor player)
    if Controller && Controller.SFX
        Controller.SFX.Play(sfx, player)
    endif
EndFunction

Function MarkPendingIronIntroShown(Actor player, String guid)
    if !_ironIntroShownPendingGuid || !player || guid == ""
        return
    endif
    if !Controller || !Controller.Persistence
        return
    endif

    Controller.Persistence.MarkIronIntroShown(player, guid)
    _ironIntroShownPendingGuid = False
    LogUI(IronSoulConfig.LOG_INFO(), "MarkPendingIronIntroShown: marked deferred Iron Intro shown for GUID=" + guid)
EndFunction

Bool Function ShouldShowIronIntro(Actor player, String guid)
    if !HasCoreRuntime() || !player
        return False
    endif

    if _ironIntroShownThisSession
        return False
    endif

    if !Controller.Config.IsIronSoulIntroEnabled()
        return False
    endif

    if player.GetLevel() > 1
        return False
    endif

    Int liveTier = Controller.Tiers.GetCurrentTier(player, guid)
    if liveTier != Controller.Tiers.TIER_IRON
        return False
    endif

    if guid != "" && (!Controller.Persistence || Controller.Persistence.IsIronIntroShown(player, guid))
        return False
    endif

    return True
EndFunction

Bool Function ShowIronIntro(Actor player, String guid)
    if !ShouldShowIronIntro(player, guid)
        return False
    endif

    String introMenu = SwfNoBonus("1_iron_intro", Controller.Config.IsSoulBonusEnabled())
    Sound introSFX = Controller.SFX.SFXIronIntro
    Sound earlyCloseSFX = Controller.SFX.SFXIronIntroClose
    Float minDismissSeconds = IRON_INTRO_MIN_DISMISS_SECONDS
    if Controller.Identity.IsCurrentCharacterTest(player)
        introMenu = "1_iron_intro_prisoner"
        earlyCloseSFX = Controller.SFX.SFXIronIntroPrisoner
    endif

    OpenTimedMessageSWF_KeyDismissIronIntro(introMenu, IRON_INTRO_MAX_SECONDS, minDismissSeconds, introSFX, earlyCloseSFX, player)
    RestoreMusic()
    _ironIntroShownThisSession = True
    if guid != ""
        Controller.Persistence.MarkIronIntroShown(player, guid)
    else
        _ironIntroShownPendingGuid = True
        LogUI(IronSoulConfig.LOG_INFO(), "ShowIronIntro: deferred shown mark until GUID finalizes")
    endif
    Utility.Wait(1.0)
    return True
EndFunction

Float Function RefreshConfiguredMusicVolumeCache(String reason = "")
    String refreshReason = reason
    if refreshReason == ""
        refreshReason = "unspecified"
    endif

    Bool fromMenuClose = StringUtil.Find(refreshReason, "menu-close:") == 0
    Bool nativeFadeActive = IronSoulNative.MusicFadeIsActive()
    Bool bridgeFadeActive = nativeFadeActive || _musicFadeTokenValid || _musicFadeAwaitingNewToken
    if _musicFadeActive != bridgeFadeActive
        Bool previousFadeActive = _musicFadeActive
        _musicFadeActive = bridgeFadeActive
        LogUI(IronSoulConfig.LOG_INFO(), "Music volume cache synchronized fade state: reason=" + refreshReason \
            + " previous=" + previousFadeActive \
            + " native=" + nativeFadeActive \
            + " tokenValid=" + _musicFadeTokenValid \
            + " awaitingToken=" + _musicFadeAwaitingNewToken, True)
    endif

    if _musicFadeActive
        if fromMenuClose
            _menuMusicVolumeRefreshPending = True
        endif

        Float activeVolume = 1.0
        if _menuMusicVolumeCached
            activeVolume = _cachedMenuMusicVolume
        endif
        Int skipLevel = IronSoulConfig.LOG_DBG()
        if !_menuMusicVolumeCached
            skipLevel = IronSoulConfig.LOG_INFO()
        endif
        LogUI(skipLevel, "Music volume cache refresh skipped during fade: reason=" + refreshReason \
            + " cached=" + _menuMusicVolumeCached \
            + " value=" + activeVolume \
            + " pendingMenuRefresh=" + _menuMusicVolumeRefreshPending, True)
        return activeVolume
    endif

    Float previousVolume = _cachedMenuMusicVolume
    Bool hadPrevious = _menuMusicVolumeCached
    Float resolvedVolume = 1.0
    String source = "default"
    Bool matched = False

    Int i = 0
    while i < 8 && !matched
        Int uid = Utility.GetINIInt("uID" + i + ":AudioMenu")
        if uid == 466532
            Float matchedVolume = Utility.GetINIFloat("fVal" + i + ":AudioMenu")
            source = "matched slot " + i
            if matchedVolume >= 0.0 && matchedVolume <= 1.0
                resolvedVolume = matchedVolume
            else
                source = source + " invalid default"
            endif
            matched = True
        endif
        i += 1
    endwhile

    if !matched
        Float fallbackVolume = Utility.GetINIFloat("fVal3:AudioMenu")
        if fallbackVolume >= 0.0 && fallbackVolume <= 1.0
            resolvedVolume = fallbackVolume
            source = "fallback fVal3"
        endif
    endif

    _cachedMenuMusicVolume = resolvedVolume
    _menuMusicVolumeCached = True
    _menuMusicVolumeCacheReason = refreshReason
    Bool clearedPendingRefresh = _menuMusicVolumeRefreshPending
    _menuMusicVolumeRefreshPending = False

    Bool changed = !hadPrevious || previousVolume != resolvedVolume
    LogUI(IronSoulConfig.LOG_INFO(), "Music volume cache refreshed: reason=" + refreshReason \
        + " value=" + resolvedVolume \
        + " source=" + source \
        + " previousValid=" + hadPrevious \
        + " previous=" + previousVolume \
        + " changed=" + changed \
        + " menuClose=" + fromMenuClose \
        + " pendingCleared=" + clearedPendingRefresh, True)

    return resolvedVolume
EndFunction

Function InvalidateConfiguredMusicVolumeCache(String reason = "")
    String invalidateReason = reason
    if invalidateReason == ""
        invalidateReason = "unspecified"
    endif

    Bool hadPrevious = _menuMusicVolumeCached
    _menuMusicVolumeCached = False
    _menuMusicVolumeCacheReason = invalidateReason
    LogUI(IronSoulConfig.LOG_DBG(), "Music volume cache invalidated: reason=" + invalidateReason \
        + " previousValid=" + hadPrevious \
        + " previous=" + _cachedMenuMusicVolume, True)
EndFunction

Float Function ResolveConfiguredMusicVolume(String reason = "")
    String resolveReason = reason
    if resolveReason == ""
        resolveReason = "unspecified"
    endif

    if _menuMusicVolumeCached
        LogUI(IronSoulConfig.LOG_DBG(), "Music volume cache hit: reason=" + resolveReason + " value=" + _cachedMenuMusicVolume + " cachedBy=" + _menuMusicVolumeCacheReason, True)
        return _cachedMenuMusicVolume
    endif

    return RefreshConfiguredMusicVolumeCache("lazy:" + resolveReason)
EndFunction

Function HandleMusicAfterPlayerLoad(String reason = "")
    String loadReason = reason
    if loadReason == ""
        loadReason = "player-load"
    endif

    Float fallbackVolume = 1.0
    if _menuMusicVolumeCached
        fallbackVolume = _cachedMenuMusicVolume
    endif

    Bool savedFadeActive = _musicFadeActive
    PrepareMusicFadeTokenAdvance()
    Bool recoveryStarted = IronSoulNative.MusicFadeRecoverAfterLoad(AudioCategoryMUS, fallbackVolume, savedFadeActive)
    if recoveryStarted
        _musicFadeActive = True
        LogUI(IronSoulConfig.LOG_INFO(), "Music load recovery started: reason=" + loadReason \
            + " savedFadeActive=" + savedFadeActive \
            + " cached=" + _menuMusicVolumeCached \
            + " fallback=" + fallbackVolume, True)
        return
    endif

    _musicFadeActive = False
    _musicFadeTokenValid = False
    _musicFadeAwaitingNewToken = False
    ClearMusicFadeFinalVolumeState()
    ClearMusicFadeVolumeOrderState()
    RefreshConfiguredMusicVolumeCache(loadReason)
EndFunction

Function FadeMusicForTransitionSequence()
    Bool nativeFadeActive = IronSoulNative.MusicFadeIsActive()
    if !HasMusicRuntime()
        _musicFadeActive = nativeFadeActive
        return
    endif
    if nativeFadeActive
        _musicFadeActive = True
    endif

    Float menuMusicVol = ResolveConfiguredMusicVolume("fade-out")
    _musicFadeActive = True
    PrepareMusicFadeTokenAdvance()
    IronSoulNative.MusicFadeOut(AudioCategoryMUS, 2.0, menuMusicVol)
EndFunction

Function RestoreMusic(Float seconds = 2.0)
    Bool nativeFadeActive = IronSoulNative.MusicFadeIsActive()
    if nativeFadeActive
        _musicFadeActive = True
    endif
    if !HasMusicRuntime()
        if !nativeFadeActive
            _musicFadeActive = False
            return
        endif
        if !Controller || !Controller.Config || !AudioCategoryMUS
            _musicFadeActive = True
            LogUI(IronSoulConfig.LOG_INFO(), "Music fade restore deferred: active native session but runtime wiring is unavailable", True)
            return
        endif
        LogUI(IronSoulConfig.LOG_INFO(), "Music fade restore continuing for active native session despite MusicFade=0", True)
    endif

    if seconds <= 0.0
        seconds = 0.1
    endif
    Float menuMusicVol = ResolveConfiguredMusicVolume("fade-in")
    _musicFadeActive = True
    PrepareMusicFadeTokenAdvance()
    IronSoulNative.MusicFadeIn(AudioCategoryMUS, seconds, menuMusicVol)
EndFunction

Event OnKeyDown(Int keyCode)
    if !_keyDismissActive
        return
    endif
    _keyDismissPressed = True
    _keyDismissPressedAt = Utility.GetCurrentRealTime()
EndEvent

Function RegisterForAllKeys()
    RegisterForKey(1)   ; Esc
    RegisterForKey(28)  ; Enter
    RegisterForKey(57)  ; Space

    RegisterForKey(256) ; LeftMouseButton
    RegisterForKey(257) ; RightMouseButton

    RegisterForKey(270) ; Start
    RegisterForKey(271) ; Back
    RegisterForKey(276) ; GamepadA
    RegisterForKey(277) ; GamepadB
    RegisterForKey(278) ; GamepadX
    RegisterForKey(279) ; GamepadY
EndFunction

Function UnregisterForAllKeys()
    UnregisterForKey(1)   ; Esc
    UnregisterForKey(28)  ; Enter
    UnregisterForKey(57)  ; Space

    UnregisterForKey(256) ; LeftMouseButton
    UnregisterForKey(257) ; RightMouseButton

    UnregisterForKey(270) ; Start
    UnregisterForKey(271) ; Back
    UnregisterForKey(276) ; GamepadA
    UnregisterForKey(277) ; GamepadB
    UnregisterForKey(278) ; GamepadX
    UnregisterForKey(279) ; GamepadY
EndFunction

Event OnMenuClose(String menuName)
    if menuName == "Journal Menu" || menuName == "TweenMenu"
        RefreshConfiguredMusicVolumeCache("menu-close:" + menuName)
    endif
EndEvent

Event OnMusicFadeSetVolume(String eventName, String strArg, Float numArg, Form sender)
    SoundCategory cat = sender as SoundCategory
    if !cat
        return
    endif

    Int token = ParseMusicFadeEventToken(strArg)
    if !AcceptMusicFadeEventToken(token, "set-volume")
        return
    endif

    String phase = ExtractMusicFadeEventField(strArg, "phase")
    String kind = ExtractMusicFadeEventField(strArg, "kind")
    Int step = ParseMusicFadeEventStep(strArg)
    if !AcceptMusicFadeVolumeOrder(token, step, kind)
        return
    endif

    Float volume = ClampMusicFadeVolume(numArg)
    _musicFadeActive = True

    cat.SetVolume(volume)
    if kind == "final" || kind == "recovery"
        MarkMusicFadeFinalVolumeApplied(token)
    endif
EndEvent

Event OnMusicFadeComplete(String eventName, String strArg, Float numArg, Form sender)
    SoundCategory cat = sender as SoundCategory
    if !cat
        return
    endif

    String phase = ExtractMusicFadeEventField(strArg, "phase")
    if phase == ""
        phase = strArg
    endif
    String kind = ExtractMusicFadeEventField(strArg, "kind")
    Int token = ParseMusicFadeEventToken(strArg)

    if token <= 0
        _musicFadeActive = IronSoulNative.MusicFadeIsActive()
        LogUI(IronSoulConfig.LOG_INFO(), "Music fade untokened completion synchronized from native: phase=" + phase \
            + " final=" + numArg \
            + " active=" + _musicFadeActive, True)
        return
    endif

    if !AcceptMusicFadeEventToken(token, "complete")
        return
    endif

    Bool nativeFadeActive = IronSoulNative.MusicFadeIsActive()
    _musicFadeActive = nativeFadeActive

    LogUI(IronSoulConfig.LOG_DBG(), "Music fade complete: token=" + token \
        + " phase=" + phase \
        + " kind=" + kind \
        + " final=" + numArg \
        + " active=" + _musicFadeActive \
        + " pendingMenuRefresh=" + _menuMusicVolumeRefreshPending, True)

    if phase == "in" && !nativeFadeActive
        if !HasMusicFadeFinalVolumeApplied(token)
            Float finalVolume = ClampMusicFadeVolume(numArg)
            cat.SetVolume(finalVolume)
            MarkMusicFadeFinalVolumeApplied(token)
            LogUI(IronSoulConfig.LOG_INFO(), "Music fade completion applied missing final volume: token=" + token \
                + " final=" + finalVolume, True)
        endif

        _musicFadeTokenValid = False
        _musicFadeAwaitingNewToken = False
        ClearMusicFadeFinalVolumeState()
        ClearMusicFadeVolumeOrderState()
        if _menuMusicVolumeRefreshPending
            RefreshConfiguredMusicVolumeCache("pending-menu-close-after-fade")
        endif
    endif
EndEvent


; --- Menu Naming ---
; ===================

String Function TierMenuPrefix(Int soulTier) Global
    if soulTier == 0
        return "0_defiant"
    elseif soulTier == 1
        return "1_iron"
    elseif soulTier == 2
        return "2_silver"
    elseif soulTier == 3
        return "3_gold"
    elseif soulTier == 4
        return "4_ebon"
    elseif soulTier == 5
        return "5_platinum"
    elseif soulTier == 6
        return "6_devour"
    elseif soulTier == 9
        return "9_chim"
    endif
    return "1_iron"
EndFunction

String Function SwfNoBonus(String menuName, Bool soulBonusEnabled) Global
    if menuName == ""
        return ""
    endif
    if StringUtil.Find(menuName, "dragon_soul_revive") != -1
        return menuName
    endif
    if !soulBonusEnabled
        return menuName + "_nobonus"
    endif
    return menuName
EndFunction

String Function ResolveDeathMenu(Int soulTier, Int deathsNow) Global
    if soulTier == 6
        return "6_devour_death_" + deathsNow
    endif
    if soulTier == 9
        return "9_chim_death_" + Utility.RandomInt(1, 9)
    endif
    if soulTier == 0
        return "0_defiant_death_" + deathsNow
    endif
    return TierMenuPrefix(soulTier) + "_death_" + deathsNow
EndFunction

String Function ResolvePermadeathMenu(Int soulTier) Global
    if soulTier == 6
        return "6_devour_permadeath"
    endif
    if soulTier == 9
        return "9_chim_death_" + Utility.RandomInt(1, 9)
    endif
    if soulTier == 0
        return "0_defiant_permadeath"
    endif
    return TierMenuPrefix(soulTier) + "_permadeath"
EndFunction

String Function ResolveRespawnMenu(Int soulTier) Global
    if soulTier == 9
        return "9_chim_respawn"
    endif
    if soulTier == 0
        return "0_defiant_respawn"
    endif
    return TierMenuPrefix(soulTier) + "_respawn"
EndFunction

String Function ResolveSoulFeatUnlockMenuFromFacts(Int soulTier, Bool soulBonusEnabled, Bool dragonSoulReviveEnabled) Global
    Int unlockTier = IronSoulTiers.NormalizeSoulFeatUnlockTier(soulTier)

    if unlockTier == 6
        if !soulBonusEnabled && !dragonSoulReviveEnabled
            return "6_devour_feat_unlock_nobonus_nodsr"
        elseif !soulBonusEnabled
            return "6_devour_feat_unlock_nobonus"
        elseif !dragonSoulReviveEnabled
            return "6_devour_feat_unlock_nodsr"
        endif
        return "6_devour_feat_unlock"
    elseif unlockTier == 5
        return SwfNoBonus("5_platinum_feat_unlock", soulBonusEnabled)
    elseif unlockTier == 4
        return SwfNoBonus("4_ebon_feat_unlock", soulBonusEnabled)
    elseif unlockTier == 3
        return SwfNoBonus("3_gold_feat_unlock", soulBonusEnabled)
    endif
    return SwfNoBonus("2_silver_feat_unlock", soulBonusEnabled)
EndFunction

String Function ResolveDefiantFeatUnlockMenu(Bool soulFatigueEnabled) Global
    String base = "0_defiant_feat_unlock"
    if !soulFatigueEnabled
        base = base + "_nofatigue"
    endif
    return base
EndFunction

String Function ResolveDefiantTransitionMenu(Int curTier, Bool soulBonusEnabled, Bool soulFatigueEnabled) Global
    String base = "0_defiant_intro_transitioniron"
    if curTier == 6
        base = "0_defiant_intro_transitiondevour"
    elseif curTier == 5
        base = "0_defiant_intro_transitionplatinum"
    elseif curTier == 4
        base = "0_defiant_intro_transitionebon"
    elseif curTier == 3
        base = "0_defiant_intro_transitiongold"
    elseif curTier == 2
        base = "0_defiant_intro_transitionsilver"
    endif

    if !soulBonusEnabled
        base = base + "_nobonus"
    endif
    if !soulFatigueEnabled
        base = base + "_nofatigue"
    endif
    return base
EndFunction

String Function ResolveCHIMTransitionMenu(Int curTier) Global
    if curTier == 0
        return "9_chim_intro_transitiondefiant"
    elseif curTier == 1
        return "9_chim_intro_transitioniron"
    elseif curTier == 2
        return "9_chim_intro_transitionsilver"
    elseif curTier == 3
        return "9_chim_intro_transitiongold"
    elseif curTier == 4
        return "9_chim_intro_transitionebon"
    elseif curTier == 6
        return "9_chim_intro_transitiondevour"
    elseif curTier == 5
        return "9_chim_intro_transitionplatinum"
    endif
    return "9_chim_intro_transitioniron"
EndFunction

Bool Function IsLuckRollMenu(String menuName) Global
    return StringUtil.Find(menuName, "luck") != -1 && StringUtil.Find(menuName, "roll") != -1
EndFunction

String Function ResolveLuckThresholdNotification(Int tier) Global
    if tier == 1
        return IronSoulNative.TextGet("Notification.LuckThreshold1")
    elseif tier == 2
        return IronSoulNative.TextGet("Notification.LuckThreshold2")
    elseif tier == 3
        return IronSoulNative.TextGet("Notification.LuckThreshold3")
    endif
    return IronSoulNative.TextGet("Notification.LuckThresholdDefault")
EndFunction


; --- Load Notification Text ---
; ==============================

String Function BuildLoadStatsNotification(Int daysPassed, Int deaths, Int maxDeaths, Int anima, Int luck) Global
    String deathPair = deaths + " / " + maxDeaths
    return IronSoulNative.TextFormat4("Notification.LoadStats", "day", "" + daysPassed, "death_pair", deathPair, "anima", "" + anima, "luck", "" + luck)
EndFunction
