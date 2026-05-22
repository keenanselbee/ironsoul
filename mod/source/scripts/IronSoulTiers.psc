Scriptname IronSoulTiers Hidden

; =========================
; --- Table of Contents ---
; =========================

; --- Tier Policy Helpers ---
; ---------------------------
; IsCanonicalSoulTier()
; IsNormalSoulTier()
; GetSoulBonusOrdinal()
; NormalizeDefiantTrackedTier()
; GetMaxLuckForTierAtLevel()
; GetHighestEligibleNormalSoulTier()
; ResolveSoulTierTargetFromFacts()
; SoulTierLabel()

; --- Feat Journal Helpers ---
; ----------------------------
; ResolveSoulFeatUnlockJournalBase()
; ResolveDefiantResetJournalBase()


; --- Tier Policy Helpers ---
; ===========================

Bool Function IsCanonicalSoulTier(Int tier) Global
    if tier == 0 || tier == 9
        return True
    endif
    return tier >= 1 && tier <= 6
EndFunction

Bool Function IsNormalSoulTier(Int tier) Global
    return tier >= 1 && tier <= 6
EndFunction

Int Function GetSoulBonusOrdinal(Int tier) Global
    if !IsNormalSoulTier(tier)
        return 0
    endif
    return tier
EndFunction

Int Function NormalizeDefiantTrackedTier(Int tier) Global
    if tier < 1
        return 1
    elseif tier > 6
        return 6
    endif
    return tier
EndFunction

Int Function GetMaxLuckForTierAtLevel(Int tier, Int luckLevel) Global
    luckLevel = IronSoulConfig.ClampLuckLevel(luckLevel)
    if tier == 9
        return 100
    elseif tier == 0
        if luckLevel == 1
            return 25
        elseif luckLevel == 2
            return 30
        elseif luckLevel == 3
            return 35
        elseif luckLevel == 4
            return 40
        endif
        return 50
    elseif tier == 1
        if luckLevel == 1
            return 50
        elseif luckLevel == 2
            return 60
        elseif luckLevel == 3
            return 70
        elseif luckLevel == 4
            return 75
        endif
        return 80
    elseif tier == 2
        if luckLevel == 1
            return 55
        elseif luckLevel == 2
            return 65
        elseif luckLevel == 3
            return 75
        elseif luckLevel == 4
            return 80
        endif
        return 85
    elseif tier == 3
        if luckLevel == 1
            return 60
        elseif luckLevel == 2
            return 70
        elseif luckLevel == 3
            return 80
        elseif luckLevel == 4
            return 85
        endif
        return 90
    elseif tier == 4
        if luckLevel == 1
            return 65
        elseif luckLevel == 2
            return 75
        elseif luckLevel == 3
            return 85
        elseif luckLevel == 4
            return 90
        endif
        return 95
    elseif tier == 5
        if luckLevel == 1
            return 70
        elseif luckLevel == 2
            return 80
        elseif luckLevel == 3
            return 90
        elseif luckLevel == 4
            return 95
        endif
        return 99
    elseif tier == 6
        if luckLevel == 1
            return 75
        elseif luckLevel == 2
            return 85
        elseif luckLevel == 3
            return 95
        elseif luckLevel == 4
            return 99
        endif
        return 100
    endif
    return GetMaxLuckForTierAtLevel(1, luckLevel)
EndFunction

Int Function GetHighestEligibleNormalSoulTier(Int soulsObtained, Bool molagKilled, Bool miraakKilled, Bool alduinKilled, Bool harkonKilled) Global
    if soulsObtained >= 50
        return 6
    endif
    if molagKilled || miraakKilled
        return 5
    endif
    if alduinKilled || harkonKilled
        return 4
    endif
    if soulsObtained >= 20
        return 3
    elseif soulsObtained >= 10
        return 2
    endif
    return 1
EndFunction

Int Function ResolveSoulTierTargetFromFacts(Int resolveMode, Int deaths, Int liveTier, Int highestEligibleNormalTier, Int ironSoulMaxLives, Int defiantSoulMaxLives, Bool soulFeatsEnabled, Bool defiantSoulEnabled, Bool permadeathEnabled, Bool manualTierOverrideActive, Bool chimEnteredByConsole, Bool defiantFeatUnlocked) Global
    if resolveMode == 1
        if !soulFeatsEnabled
            return 1
        endif
        if deaths >= ironSoulMaxLives
            return 1
        endif
        return highestEligibleNormalTier

    elseif resolveMode == 2
        if liveTier == 6
            return 6
        elseif liveTier == 9 && !manualTierOverrideActive && !chimEnteredByConsole
            return 9
        elseif liveTier == 0
            return 0
        endif

        Bool defiantBlockedAtIronCap = False
        if defiantFeatUnlocked && deaths >= ironSoulMaxLives
            if defiantSoulEnabled
                if !permadeathEnabled && deaths >= defiantSoulMaxLives
                    return 9
                endif
                return 0
            endif
            defiantBlockedAtIronCap = True
        endif

        if !permadeathEnabled && liveTier != 6 && deaths >= ironSoulMaxLives && !defiantBlockedAtIronCap
            return 9
        endif

        return ResolveSoulTierTargetFromFacts(1, deaths, liveTier, highestEligibleNormalTier, ironSoulMaxLives, defiantSoulMaxLives, soulFeatsEnabled, defiantSoulEnabled, permadeathEnabled, manualTierOverrideActive, chimEnteredByConsole, defiantFeatUnlocked)

    elseif resolveMode == 3
        if liveTier == 6
            if !permadeathEnabled && deaths >= ironSoulMaxLives
                return 9
            endif
            return 6
        endif

        Bool chimActive = (liveTier == 9)
        Bool defiantActive = (liveTier == 0)

        if deaths == ironSoulMaxLives && !defiantActive && !chimActive
            if defiantFeatUnlocked
                if defiantSoulEnabled
                    return 0
                endif
                return liveTier
            endif
        endif

        if !permadeathEnabled && liveTier != 6 && !chimActive
            Bool defiantBlockedAtIronCapTD = False
            if !defiantActive && deaths == ironSoulMaxLives
                defiantBlockedAtIronCapTD = (defiantFeatUnlocked && !defiantSoulEnabled)
            endif
            Bool chimAtIronCap = (!defiantActive && deaths == ironSoulMaxLives && !defiantBlockedAtIronCapTD)
            Bool chimAtDefiantCap = (defiantActive && deaths == defiantSoulMaxLives)
            if chimAtIronCap || chimAtDefiantCap
                return 9
            endif
        endif

        return liveTier

    elseif resolveMode == 4
        if liveTier == 6
            if !permadeathEnabled && deaths >= ironSoulMaxLives
                return 9
            endif
            return 6
        endif

        Bool chimActiveLC = (liveTier == 9)
        Bool defiantActiveLC = (liveTier == 0)

        Bool defiantBlockedAtIronCapLC = False
        if !defiantActiveLC && !chimActiveLC && deaths >= ironSoulMaxLives
            if defiantFeatUnlocked
                if defiantSoulEnabled
                    return 0
                endif
                defiantBlockedAtIronCapLC = True
            endif
        endif

        if permadeathEnabled || chimActiveLC || liveTier == 6
            return liveTier
        endif

        if defiantActiveLC
            if deaths >= defiantSoulMaxLives
                return 9
            endif
            return liveTier
        endif

        if deaths < ironSoulMaxLives
            return liveTier
        endif

        if defiantBlockedAtIronCapLC
            return liveTier
        endif

        return 9
    endif

    return 1
EndFunction

String Function SoulTierLabel(Int tier) Global
    if tier == 0
        return "Defiant"
    elseif tier == 1
        return "Iron"
    elseif tier == 2
        return "Silver"
    elseif tier == 3
        return "Gold"
    elseif tier == 4
        return "Ebon"
    elseif tier == 5
        return "Platinum"
    elseif tier == 6
        return "Devour"
    elseif tier == 9
        return "CHIM"
    endif
    return "Iron"
EndFunction


; --- Feat Journal Helpers ---
; ============================

String Function ResolveSoulFeatUnlockJournalBase(Int soulTier, Bool molagKilled, Bool miraakKilled, Bool alduinKilled, Bool harkonKilled, Bool resetDeaths) Global
    String baseText = ""

    if soulTier == 6
        baseText = "Soul Feat achieved: Devour Soul awakened."
    elseif soulTier == 5
        if molagKilled
            baseText = "Molag Bal Defeated: Soul Feat achieved: Platinum Soul awakened."
        elseif miraakKilled
            baseText = "Miraak Defeated: Soul Feat achieved: Platinum Soul awakened."
        else
            baseText = "Soul Feat achieved: Platinum Soul awakened."
        endif
    elseif soulTier == 4
        if alduinKilled
            baseText = "Alduin Defeated: Soul Feat achieved: Ebon Soul awakened."
        elseif harkonKilled
            baseText = "Harkon Defeated: Soul Feat achieved: Ebon Soul awakened."
        else
            baseText = "Soul Feat achieved: Ebon Soul awakened."
        endif
    elseif soulTier == 3
        baseText = "Soul Feat achieved: Gilded Soul awakened."
    elseif soulTier == 2
        baseText = "Soul Feat achieved: Silver Soul awakened."
    endif

    if baseText == ""
        return ""
    endif
    if resetDeaths
        baseText = baseText + " Deaths purged."
    endif
    return baseText
EndFunction

String Function ResolveDefiantResetJournalBase(Int targetTier, Bool molagKilled, Bool miraakKilled, Bool alduinKilled, Bool harkonKilled) Global
    if targetTier < 2 || !IsNormalSoulTier(targetTier)
        return ""
    endif

    if targetTier == 6
        return "Defiant Soul ended. Deaths purged. Devour Soul claimed."
    elseif targetTier == 5
        if molagKilled
            return "Defiant Soul ended. Deaths purged. Molag Bal Defeated: Platinum Soul claimed."
        elseif miraakKilled
            return "Defiant Soul ended. Deaths purged. Miraak Defeated: Platinum Soul claimed."
        endif
        return "Defiant Soul ended. Deaths purged. Platinum Soul claimed."
    elseif targetTier == 4
        if alduinKilled
            return "Defiant Soul ended. Deaths purged. Alduin Defeated: Ebon Soul claimed."
        elseif harkonKilled
            return "Defiant Soul ended. Deaths purged. Harkon Defeated: Ebon Soul claimed."
        endif
        return "Defiant Soul ended. Deaths purged. Ebon Soul claimed."
    elseif targetTier == 3
        return "Defiant Soul ended. Deaths purged. Gilded Soul claimed."
    endif

    return "Defiant Soul ended. Deaths purged. Silver Soul claimed."
EndFunction
