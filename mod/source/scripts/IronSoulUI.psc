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
; RegisterMusicVolumeCacheMenus()
; ScheduleLoadMessage()
; ClearDelayedIronIntro()
; ScheduleIronIntroAfterGuidFinalize()
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
; OnMusicFadeComplete()

; --- Menu Naming ---
; -------------------
; TierMenuPrefix()
; SwfNoBonus()
; ResolveDeathMessageMenu()
; ResolvePermadeathMenu()
; ResolveRespawnMenu()
; ResolveSoulFeatUnlockMenuFromFacts()
; ResolveDefiantFeatUnlockMenu()
; ResolveDefiantTransitionMenu()
; ResolveCHIMTransitionMenu()
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

Bool _pendingLoadMessage = False
Float _loadMessageAt = 0.0
Float _pendingLoadMessageStartedAt = 0.0

Bool _pendingIronIntro = False
String _pendingIronIntroGuid = ""
Float _ironIntroAt = 0.0

Float TRANSITION_SFX_FADE_SECONDS = 1.0

Float _cachedMenuMusicVolume = 1.0
Bool _menuMusicVolumeCached = False
String _menuMusicVolumeCacheReason = ""
Bool _musicFadeActive = False
Bool _menuMusicVolumeRefreshPending = False


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
    UnregisterForAllKeys()

    _pendingLoadMessage = False
    _loadMessageAt = 0.0
    _pendingLoadMessageStartedAt = 0.0

    ClearDelayedIronIntro()
EndFunction

Function RegisterMusicFadeBridge()
    UnregisterForModEvent("IronSoul_MusicFadeSetVolume")
    UnregisterForModEvent("IronSoul_MusicFadeComplete")
    RegisterForModEvent("IronSoul_MusicFadeComplete", "OnMusicFadeComplete")
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
EndFunction

Function ScheduleIronIntroAfterGuidFinalize(Actor player, String guid, Float delaySeconds = 10.0)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    if delaySeconds < 0.0
        delaySeconds = 0.0
    endif

    if !ShouldShowIronIntro(player, guid)
        ClearDelayedIronIntro()
        return
    endif

    _pendingIronIntro = True
    _pendingIronIntroGuid = guid
    _ironIntroAt = Utility.GetCurrentRealTime() + delaySeconds

    LogUI(IronSoulConfig.LOG_INFO(), "ScheduleIronIntroAfterGuidFinalize: delayed intro pending for GUID=" + guid + " delay=" + delaySeconds + "s")

    if Controller
        Controller.QueueUpdate(delaySeconds)
    endif
EndFunction

Bool Function RequiresFastPolling(Float watchdogSeconds)
    Float nowRT = Utility.GetCurrentRealTime()
    Bool ironIntroDue = _pendingIronIntro && nowRT >= _ironIntroAt

    if !_pendingLoadMessage
        _pendingLoadMessageStartedAt = 0.0
        return ironIntroDue
    endif

    Float elapsed = nowRT - _pendingLoadMessageStartedAt
    if watchdogSeconds > 0.0 && _pendingLoadMessageStartedAt > 0.0 && elapsed > watchdogSeconds
        _pendingLoadMessage = False
        _pendingLoadMessageStartedAt = 0.0
        LogUI(IronSoulConfig.LOG_INFO(), "RequiresFastPolling: cleared pending load message after " + elapsed + "s")
        return ironIntroDue
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

    if Utility.GetCurrentRealTime() < _ironIntroAt
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

    String guid = Controller.Identity.GetTickGuid(player)
    if guid == ""
        return
    endif

    if guid != _pendingIronIntroGuid
        LogUI(IronSoulConfig.LOG_INFO(), "HandleDelayedIronIntro: cleared pending intro after GUID changed from " + _pendingIronIntroGuid + " to " + guid)
        ClearDelayedIronIntro()
        return
    endif

    if !ShouldShowIronIntro(player, guid)
        LogUI(IronSoulConfig.LOG_INFO(), "HandleDelayedIronIntro: cleared pending intro because it is no longer eligible")
        ClearDelayedIronIntro()
        return
    endif

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

Function OpenTimedMessageSWF_KeyDismiss(String menuName, Float maxDuration = 6.0, Float minDismissSeconds = 6.0, Bool restoreMusic = True)
    if menuName == ""
        return
    endif

    FadeMusicForTransitionSequence()
    OpenKeyDismissMenu(menuName, maxDuration, minDismissSeconds)

    if restoreMusic
        RestoreMusic()
    endif
EndFunction

Function OpenTimedMessageSWF_KeyDismissTrackedSFX(String menuName, Float maxDuration = 6.0, Float minDismissSeconds = 6.0, Bool restoreMusic = True, Int sfxInstance = -1, Float sfxStartedAt = 0.0, Float sfxSeconds = 0.0)
    if menuName == ""
        return
    endif

    FadeMusicForTransitionSequence()
    Bool dismissedByKey = OpenKeyDismissMenu(menuName, maxDuration, minDismissSeconds)

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

Function OpenTimedMessageSWF_KeyDismissIronIntro(String menuName, Float maxDuration = 6.0, Float minDismissSeconds = 6.0, Sound sfx = None, Actor player = None)
    if menuName == ""
        return
    endif

    PlayPresentationSFX(sfx, player)
    FadeMusicForTransitionSequence()
    OpenKeyDismissMenu(menuName, maxDuration, minDismissSeconds)
EndFunction

Bool Function OpenKeyDismissMenu(String menuName, Float maxDuration = 6.0, Float minDismissSeconds = 6.0)
    if menuName == ""
        return False
    endif

    if maxDuration <= 0.0
        maxDuration = 0.1
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

    if minDismissSeconds > 0.0
        Utility.WaitMenuMode(minDismissSeconds)
    endif

    Float remaining = maxDuration - minDismissSeconds
    if remaining > 0.0
        _keyDismissPressed = False
        _keyDismissActive  = True
        RegisterForAllKeys()

        while remaining > 0.0 && !_keyDismissPressed
            Utility.WaitMenuMode(0.10)
            remaining -= 0.10
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

Bool Function ShouldShowIronIntro(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return False
    endif

    if !Controller.Config.IsIronSoulIntroEnabled()
        return False
    endif

    Int liveTier = Controller.Tiers.GetCurrentTier(player, guid)
    if liveTier != Controller.Tiers.TIER_IRON
        return False
    endif

    if !Controller.Persistence || Controller.Persistence.IsIronIntroShown(player, guid)
        return False
    endif

    return True
EndFunction

Bool Function ShowIronIntro(Actor player, String guid)
    if !ShouldShowIronIntro(player, guid)
        return False
    endif

    OpenTimedMessageSWF_KeyDismissIronIntro(SwfNoBonus("1_iron_intro", Controller.Config.IsSoulBonusEnabled()), 30.0, 14.5, Controller.SFX.SFXIronIntro, player)
    RestoreMusic()
    Controller.Persistence.MarkIronIntroShown(player, guid)
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
    if _musicFadeActive != nativeFadeActive
        Bool previousFadeActive = _musicFadeActive
        _musicFadeActive = nativeFadeActive
        LogUI(IronSoulConfig.LOG_INFO(), "Music volume cache synchronized fade state: reason=" + refreshReason \
            + " previous=" + previousFadeActive \
            + " native=" + nativeFadeActive, True)
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
    IronSoulNative.MusicFadeIn(AudioCategoryMUS, seconds, menuMusicVol)
EndFunction

Event OnKeyDown(Int keyCode)
    if !_keyDismissActive
        return
    endif
    _keyDismissPressed = True
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

Event OnMusicFadeComplete(String eventName, String strArg, Float numArg, Form sender)
    SoundCategory cat = sender as SoundCategory
    if !cat
        return
    endif

    _musicFadeActive = IronSoulNative.MusicFadeIsActive()

    LogUI(IronSoulConfig.LOG_DBG(), "Music fade complete: phase=" + strArg \
        + " final=" + numArg \
        + " active=" + _musicFadeActive \
        + " pendingMenuRefresh=" + _menuMusicVolumeRefreshPending, True)

    if strArg == "in" && !_musicFadeActive && _menuMusicVolumeRefreshPending
        RefreshConfiguredMusicVolumeCache("pending-menu-close-after-fade")
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

String Function ResolveDeathMessageMenu(Int soulTier, Int deathsNow) Global
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

String Function ResolveSoulFeatUnlockMenuFromFacts(Int soulTier, Bool soulBonusEnabled, Bool dragonSoulReviveEnabled, Int platinumVariant, Int ebonVariant) Global
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
        String menuP = "5_platinum_feat_unlock_miraak"
        if platinumVariant == 1
            menuP = "5_platinum_feat_unlock_molagbal"
        endif
        return SwfNoBonus(menuP, soulBonusEnabled)
    elseif unlockTier == 4
        String menuE = "4_ebon_feat_unlock_harkon"
        if ebonVariant == 1
            menuE = "4_ebon_feat_unlock_alduin"
        endif
        return SwfNoBonus(menuE, soulBonusEnabled)
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

String Function ResolveLuckThresholdNotification(Int tier) Global
    if tier == 1
        return "Your luck is returning."
    elseif tier == 2
        return "Your luck has improved."
    elseif tier == 3
        return "The odds favor you."
    endif
    return "You're feeling lucky."
EndFunction


; --- Load Notification Text ---
; ==============================

String Function BuildLoadStatsNotification(Int daysPassed, Int deaths, Int maxDeaths, Int anima, Int luck) Global
    return "Day " + daysPassed + " | Deaths: " + deaths + " / " + maxDeaths + " | Anima: " + anima + " | Luck: " + luck
EndFunction
