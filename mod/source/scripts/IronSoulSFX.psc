Scriptname IronSoulSFX extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()

; --- Component Runtime ---
; -------------------------
; Play()
; PlayInstance()
; FadeOutInstance()
; PickHeavyBreathingForPlayer()
; CanPlayConfiguredSFX()
; IsOwnedSFXEnabled()

; --- Playback Policy ---
; -----------------------
; CanPlaySFX()
; IsSFXCategoryEnabled()

; --- SFX Selection ---
; ---------------------
; PickHeavyBreathingSFX()
; PickRandomSFX4()
; PickDragonSoulReviveCastSFX()
; PickDragonSoulReviveSFX()


; --- Wired Dependencies & Runtime State ---
; ==========================================

IronSoulController Property Controller Auto
SoundCategory Property AudioCategoryIronSoul Auto

; This component owns shared UI, death, respawn, luck, and heavy-breathing
; sounds. Tier and Dragon Soul Revive sounds stay with their owning components.
Sound Property SFXIronIntro Auto
Sound Property SFXIronIntroPrisoner Auto
Sound Property SFXDeath Auto
Sound Property SFXFarsight Auto
Sound Property SFXPermadeath Auto
Sound Property SFXRespawn Auto
Sound Property SFXLuckFailure Auto
Sound Property SFXLuckSuccess Auto
Sound Property SFXHeavyBreathing0 Auto ; MaleKhajiit
Sound Property SFXHeavyBreathing1 Auto ; MaleOrc
Sound Property SFXHeavyBreathing2 Auto ; MaleEvenToned
Sound Property SFXHeavyBreathing3 Auto ; MaleElfHaughty
Sound Property SFXHeavyBreathing4 Auto ; MaleArgonian
Sound Property SFXHeavyBreathing5 Auto ; FemaleOrc
Sound Property SFXHeavyBreathing6 Auto ; FemaleEvenToned
Sound Property SFXHeavyBreathing7 Auto ; FemaleKhajiit
Sound Property SFXHeavyBreathing8 Auto ; FemaleElfHaughty
Sound Property SFXHeavyBreathing9 Auto ; FemaleArgonian


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config
        return False
    endif
    return True
EndFunction


; --- Component Runtime ---
; =========================

Function Play(Sound sfx, Actor source)
    if !CanPlayConfiguredSFX(sfx, source)
        return
    endif
    IronSoulNative.AudioPlay(sfx, source, 1.0, "shared-sfx")
EndFunction

Int Function PlayInstance(Sound sfx, Actor source)
    if !CanPlayConfiguredSFX(sfx, source)
        return -1
    endif
    return IronSoulNative.AudioPlayTracked(sfx, source, 1.0, "shared-sfx-tracked")
EndFunction

Function FadeOutInstance(Int instanceId, Float seconds = 1.0)
    if instanceId < 0
        return
    endif
    if seconds <= 0.0
        IronSoulNative.AudioStopTracked(instanceId, "shared-sfx-stop")
        return
    endif

    IronSoulNative.AudioFadeOutTracked(instanceId, seconds, "shared-sfx-fade")
EndFunction

Sound Function PickHeavyBreathingForPlayer(Actor player)
    return PickHeavyBreathingSFX(player, SFXHeavyBreathing0, SFXHeavyBreathing1, SFXHeavyBreathing2, SFXHeavyBreathing3, SFXHeavyBreathing4, SFXHeavyBreathing5, SFXHeavyBreathing6, SFXHeavyBreathing7, SFXHeavyBreathing8, SFXHeavyBreathing9)
EndFunction

Bool Function CanPlayConfiguredSFX(Sound sfx, Actor source)
    if !HasCoreRuntime()
        return False
    endif
    if !CanPlaySFX(Controller.Config.IsSFXEnabled(), Controller.Config.IsUninstallMode(), Controller.IsModDisabled())
        return False
    endif
    if !sfx || !source
        return False
    endif
    return IsOwnedSFXEnabled(sfx)
EndFunction

Bool Function IsOwnedSFXEnabled(Sound sfx)
    if !sfx
        return False
    endif

    if sfx == SFXIronIntro || sfx == SFXIronIntroPrisoner
        return Controller.Config.IsIronIntroSFXEnabled()
    elseif sfx == SFXDeath
        return Controller.Config.IsDeathSFXEnabled()
    elseif sfx == SFXFarsight
        return Controller.Config.IsFarsightSFXEnabled()
    elseif sfx == SFXPermadeath
        return Controller.Config.IsPermadeathSFXEnabled()
    elseif sfx == SFXRespawn
        return Controller.Config.IsRespawnSFXEnabled()
    elseif sfx == SFXLuckFailure || sfx == SFXLuckSuccess
        return Controller.Config.IsLuckOutcomeSFXEnabled()
    elseif sfx == SFXHeavyBreathing0 || sfx == SFXHeavyBreathing1 || sfx == SFXHeavyBreathing2 || sfx == SFXHeavyBreathing3 || sfx == SFXHeavyBreathing4 || sfx == SFXHeavyBreathing5 || sfx == SFXHeavyBreathing6 || sfx == SFXHeavyBreathing7 || sfx == SFXHeavyBreathing8 || sfx == SFXHeavyBreathing9
        return Controller.Config.IsRespawnHeavyBreathingSFXEnabled()
    endif
    return False
EndFunction

Bool Function CanPlaySFX(Bool sfxEnabled, Bool uninstallMode, Bool modDisabled) Global
    if !sfxEnabled
        return False
    endif
    if uninstallMode
        return False
    endif
    if modDisabled
        return False
    endif
    return True
EndFunction

Bool Function IsSFXCategoryEnabled(Sound sfx, Sound ironIntro, Sound ironIntroPrisoner, Sound death, Sound permadeath, Sound respawn, Sound defiantTransition, Sound chimTransition, Sound defiantReset, Sound deathsPurged, Sound dsrCast1, Sound dsrCast2, Sound dsrCast3, Sound dsrCast4, Sound dsr1, Sound dsr2, Sound dsr3, Sound dsr4, Sound featSilver, Sound featGold, Sound featEbon, Sound featPlatinum, Sound featDevour, Sound featDefiant, Sound luckFailure, Sound luckSuccess, Sound heavy0, Sound heavy1, Sound heavy2, Sound heavy3, Sound heavy4, Sound heavy5, Sound heavy6, Sound heavy7, Sound heavy8, Sound heavy9, Bool ironIntroEnabled, Bool deathEnabled, Bool permadeathEnabled, Bool respawnEnabled, Bool defiantTransitionEnabled, Bool chimTransitionEnabled, Bool defiantResetEnabled, Bool deathsPurgedEnabled, Bool dsrCastEnabled, Bool dsrEnabled, Bool featEnabled, Bool luckOutcomeEnabled, Bool heavyBreathingEnabled) Global
    if !sfx
        return False
    endif

    if sfx == ironIntro || sfx == ironIntroPrisoner
        return ironIntroEnabled
    elseif sfx == death
        return deathEnabled
    elseif sfx == permadeath
        return permadeathEnabled
    elseif sfx == respawn
        return respawnEnabled
    elseif sfx == defiantTransition
        return defiantTransitionEnabled
    elseif sfx == chimTransition
        return chimTransitionEnabled
    elseif sfx == defiantReset
        return defiantResetEnabled
    elseif sfx == deathsPurged
        return deathsPurgedEnabled
    elseif sfx == dsrCast1 || sfx == dsrCast2 || sfx == dsrCast3 || sfx == dsrCast4
        return dsrCastEnabled
    elseif sfx == dsr1 || sfx == dsr2 || sfx == dsr3 || sfx == dsr4
        return dsrEnabled
    elseif sfx == featSilver || sfx == featGold || sfx == featEbon || sfx == featPlatinum || sfx == featDevour || sfx == featDefiant
        return featEnabled
    elseif sfx == luckFailure || sfx == luckSuccess
        return luckOutcomeEnabled
    elseif sfx == heavy0 || sfx == heavy1 || sfx == heavy2 || sfx == heavy3 || sfx == heavy4 || sfx == heavy5 || sfx == heavy6 || sfx == heavy7 || sfx == heavy8 || sfx == heavy9
        return heavyBreathingEnabled
    endif

    return False
EndFunction


; --- SFX Selection ---
; =====================

Sound Function PickHeavyBreathingSFX(Actor player, Sound heavy0, Sound heavy1, Sound heavy2, Sound heavy3, Sound heavy4, Sound heavy5, Sound heavy6, Sound heavy7, Sound heavy8, Sound heavy9) Global
    Int sex = 0
    Int raceId = 0
    ActorBase baseRef = None
    Race raceNow = None
    Sound picked = None

    if player
        baseRef = player.GetActorBase()
        raceNow = player.GetRace()
    endif
    if baseRef
        sex = baseRef.GetSex()
    endif
    if raceNow
        raceId = raceNow.GetFormID()
    endif

    if raceId == 0x00013747 ; OrcRace
        if sex == 1
            picked = heavy5
        else
            picked = heavy1
        endif
    elseif raceId == 0x00013745 ; KhajiitRace
        if sex == 1
            picked = heavy7
        else
            picked = heavy0
        endif
    elseif raceId == 0x00013740 ; ArgonianRace
        if sex == 1
            picked = heavy9
        else
            picked = heavy4
        endif
    elseif raceId == 0x00013742 || raceId == 0x00013743 || raceId == 0x00013749 ; Dark/High/Wood Elf
        if sex == 1
            picked = heavy8
        else
            picked = heavy3
        endif
    else
        if sex == 1
            picked = heavy6
        else
            picked = heavy2
        endif
    endif

    if picked
        return picked
    endif

    if heavy0
        return heavy0
    elseif heavy1
        return heavy1
    elseif heavy2
        return heavy2
    elseif heavy3
        return heavy3
    elseif heavy4
        return heavy4
    elseif heavy5
        return heavy5
    elseif heavy6
        return heavy6
    elseif heavy7
        return heavy7
    elseif heavy8
        return heavy8
    endif
    return heavy9
EndFunction

Sound Function PickRandomSFX4(Sound sfx1, Sound sfx2, Sound sfx3, Sound sfx4) Global
    Int r = Utility.RandomInt(1, 4)
    Sound picked = None

    if r == 1 && sfx1
        picked = sfx1
    elseif r == 2 && sfx2
        picked = sfx2
    elseif r == 3 && sfx3
        picked = sfx3
    elseif r == 4 && sfx4
        picked = sfx4
    endif

    if !picked
        if sfx1
            picked = sfx1
        elseif sfx2
            picked = sfx2
        elseif sfx3
            picked = sfx3
        elseif sfx4
            picked = sfx4
        endif
    endif

    return picked
EndFunction

Sound Function PickDragonSoulReviveCastSFX(Sound cast1, Sound cast2, Sound cast3, Sound cast4) Global
    return PickRandomSFX4(cast1, cast2, cast3, cast4)
EndFunction

Sound Function PickDragonSoulReviveSFX(Sound revive1, Sound revive2, Sound revive3, Sound revive4) Global
    return PickRandomSFX4(revive1, revive2, revive3, revive4)
EndFunction
