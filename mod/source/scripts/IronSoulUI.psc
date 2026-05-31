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
; ScheduleLoadMessage()
; RequiresFastPolling()
; HandleLoadNotification()
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
; ResolveConfiguredMusicVolume()
; FadeMusicForTransitionSequence()
; RestoreMusic()
; OnKeyDown()
; RegisterForAllKeys()
; UnregisterForAllKeys()
; OnMusicFadeSetVolume()

; --- Menu Naming ---
; -------------------
; TierMenuPrefix()
; SwfNoBonus()
; ResolveDeathMessageMenu()
; ResolvePermadeathMenu()
; ResolveRespawnMenu()
; ResolveSoulFeatUnlockMenuFromFacts()
; ResolveDefiantFeatUnlockMenu()
; ResolveDefiantIntroMenu()
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

Float TRANSITION_SFX_FADE_SECONDS = 1.0


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
EndFunction

Function RegisterMusicFadeBridge()
    UnregisterForModEvent("IronSoul_MusicFadeSetVolume")
    RegisterForModEvent("IronSoul_MusicFadeSetVolume", "OnMusicFadeSetVolume")
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

Bool Function RequiresFastPolling(Float watchdogSeconds)
    if !_pendingLoadMessage
        _pendingLoadMessageStartedAt = 0.0
        return False
    endif

    Float nowRT = Utility.GetCurrentRealTime()
    Float elapsed = nowRT - _pendingLoadMessageStartedAt
    if watchdogSeconds > 0.0 && _pendingLoadMessageStartedAt > 0.0 && elapsed > watchdogSeconds
        _pendingLoadMessage = False
        _pendingLoadMessageStartedAt = 0.0
        LogUI(IronSoulConfig.LOG_INFO(), "RequiresFastPolling: cleared pending load message after " + elapsed + "s")
        return False
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
    UI.OpenCustomMenu(menuName, 0)
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

    UI.OpenCustomMenu(menuName, 0)

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
    Controller.Persistence.MarkIronIntroShown(player, guid)
    Utility.Wait(1.0)
    return True
EndFunction

Float Function ResolveConfiguredMusicVolume()
    Int i = 0
    while i < 8
        Int uid = Utility.GetINIInt("uID" + i + ":AudioMenu")
        if uid == 466532
            Float matchedVolume = Utility.GetINIFloat("fVal" + i + ":AudioMenu")
            if matchedVolume >= 0.0 && matchedVolume <= 1.0
                return matchedVolume
            endif
            return 1.0
        endif
        i += 1
    endwhile

    Float fallbackVolume = Utility.GetINIFloat("fVal3:AudioMenu")
    if fallbackVolume >= 0.0 && fallbackVolume <= 1.0
        return fallbackVolume
    endif
    return 1.0
EndFunction

Function FadeMusicForTransitionSequence()
    if !HasMusicRuntime()
        return
    endif

    Float menuMusicVol = ResolveConfiguredMusicVolume()
    IronSoulNative.MusicFadeOut(AudioCategoryMUS, 2.0, menuMusicVol)
EndFunction

Function RestoreMusic(Float seconds = 2.0)
    if !HasMusicRuntime()
        return
    endif

    if seconds <= 0.0
        seconds = 0.1
    endif
    IronSoulNative.MusicFadeIn(AudioCategoryMUS, seconds, ResolveConfiguredMusicVolume())
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

Event OnMusicFadeSetVolume(String eventName, String strArg, Float numArg, Form sender)
    SoundCategory cat = sender as SoundCategory
    if !cat
        return
    endif

    Float v = numArg
    if v < 0.0
        v = 0.0
    elseif v > 1.0
        v = 1.0
    endif

    cat.SetVolume(v)
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

String Function ResolveDefiantIntroMenu(Bool soulBonusEnabled, Bool soulFatigueEnabled) Global
    String base = "0_defiant_intro"
    if !soulBonusEnabled
        base = base + "_nobonus"
    endif
    if !soulFatigueEnabled
        base = base + "_nofatigue"
    endif
    return base
EndFunction

String Function ResolveDefiantTransitionMenu(Int curTier) Global
    if curTier == 6
        return "0_defiant_death_10_platinum"
    elseif curTier == 5
        return "0_defiant_death_10_platinum"
    elseif curTier == 4
        return "0_defiant_death_10_ebon"
    elseif curTier == 3
        return "0_defiant_death_10_gold"
    elseif curTier == 2
        return "0_defiant_death_10_silver"
    endif
    return "0_defiant_death_10_iron"
EndFunction

String Function ResolveCHIMTransitionMenu(Int curTier) Global
    if curTier == 0
        return "9_chim_death_defiant"
    elseif curTier == 1
        return "9_chim_death_iron"
    elseif curTier == 2
        return "9_chim_death_silver"
    elseif curTier == 3
        return "9_chim_death_gold"
    elseif curTier == 4
        return "9_chim_death_ebon"
    elseif curTier == 6
        return "9_chim_death_platinum"
    elseif curTier == 5
        return "9_chim_death_platinum"
    endif
    return "9_chim_death_" + Utility.RandomInt(1, 9)
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
