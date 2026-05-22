Scriptname IronSoulSFX Hidden

; =========================
; --- Table of Contents ---
; =========================

; --- Playback Policy ---
; -----------------------
; CanPlaySFX()
; IsSFXCategoryEnabled()

; --- SFX Selection ---
; ---------------------
; ResolveSoulFeatUnlockSFX()
; PickHeavyBreathingSFX()
; PickDragonSoulReviveCastSFX()
; PickDragonSoulReviveSFX()


; --- Playback Policy ---
; =======================

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

Bool Function IsSFXCategoryEnabled(Sound sfx, Sound ironIntro, Sound death, Sound permadeath, Sound respawn, Sound defiantTransition, Sound chimTransition, Sound defiantReset, Sound deathsPurged, Sound dsrCast1, Sound dsrCast2, Sound dsrCast3, Sound dsrCast4, Sound dsr1, Sound dsr2, Sound dsr3, Sound dsr4, Sound featSilver, Sound featGold, Sound featEbon, Sound featPlatinum, Sound featDevour, Sound featDefiant, Sound luckRoll, Sound luckFailure, Sound luckSuccess, Sound heavy0, Sound heavy1, Sound heavy2, Sound heavy3, Sound heavy4, Sound heavy5, Sound heavy6, Sound heavy7, Sound heavy8, Sound heavy9, Bool ironIntroEnabled, Bool deathEnabled, Bool permadeathEnabled, Bool respawnEnabled, Bool defiantTransitionEnabled, Bool chimTransitionEnabled, Bool defiantResetEnabled, Bool deathsPurgedEnabled, Bool dsrCastEnabled, Bool dsrEnabled, Bool featEnabled, Bool luckRollEnabled, Bool luckOutcomeEnabled, Bool heavyBreathingEnabled) Global
    if !sfx
        return False
    endif

    if sfx == ironIntro
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
    elseif sfx == luckRoll
        return luckRollEnabled
    elseif sfx == luckFailure || sfx == luckSuccess
        return luckOutcomeEnabled
    elseif sfx == heavy0 || sfx == heavy1 || sfx == heavy2 || sfx == heavy3 || sfx == heavy4 || sfx == heavy5 || sfx == heavy6 || sfx == heavy7 || sfx == heavy8 || sfx == heavy9
        return heavyBreathingEnabled
    endif

    return True
EndFunction


; --- SFX Selection ---
; =====================

Sound Function ResolveSoulFeatUnlockSFX(Int soulTier, Sound silverSFX, Sound goldSFX, Sound ebonSFX, Sound platinumSFX, Sound devourSFX) Global
    if soulTier == 6
        return devourSFX
    elseif soulTier == 5
        return platinumSFX
    elseif soulTier == 4
        return ebonSFX
    elseif soulTier == 3
        return goldSFX
    endif
    return silverSFX
EndFunction

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

    if raceId == 0x00013747
        if sex == 1
            picked = heavy5
        else
            picked = heavy1
        endif
    elseif raceId == 0x00013745
        if sex == 1
            picked = heavy7
        else
            picked = heavy0
        endif
    elseif raceId == 0x00013740
        if sex == 1
            picked = heavy9
        else
            picked = heavy4
        endif
    elseif raceId == 0x00013742 || raceId == 0x00013743 || raceId == 0x00013749
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

Sound Function PickDragonSoulReviveCastSFX(Sound cast1, Sound cast2, Sound cast3, Sound cast4) Global
    Int r = Utility.RandomInt(1, 4)
    Sound picked = None

    if r == 1 && cast1
        picked = cast1
    elseif r == 2 && cast2
        picked = cast2
    elseif r == 3 && cast3
        picked = cast3
    elseif r == 4 && cast4
        picked = cast4
    endif

    if !picked
        if cast1
            picked = cast1
        elseif cast2
            picked = cast2
        elseif cast3
            picked = cast3
        elseif cast4
            picked = cast4
        endif
    endif

    return picked
EndFunction

Sound Function PickDragonSoulReviveSFX(Sound revive1, Sound revive2, Sound revive3, Sound revive4) Global
    Int r = Utility.RandomInt(1, 4)
    Sound picked = None

    if r == 1 && revive1
        picked = revive1
    elseif r == 2 && revive2
        picked = revive2
    elseif r == 3 && revive3
        picked = revive3
    elseif r == 4 && revive4
        picked = revive4
    endif

    if !picked
        if revive1
            picked = revive1
        elseif revive2
            picked = revive2
        elseif revive3
            picked = revive3
        elseif revive4
            picked = revive4
        endif
    endif

    return picked
EndFunction
