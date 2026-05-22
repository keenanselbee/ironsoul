Scriptname IronSoulEffects Hidden

; =========================
; --- Table of Contents ---
; =========================

; --- Soul Bonus Helpers ---
; --------------------------
; GetEffectiveSoulBonusTierFromFacts()
; GetNormalSoulBonusSpell()
; GetDefiantSoulBonusSpell()
; GetAppliedSoulBonusSpellLabel()
; GetAppliedSoulBonusSpellCompactLabel()

; --- Soul Fatigue Helpers ---
; ----------------------------
; NormalizeSoulFatigueSpellStage()
; GetDesiredSoulFatigueStageFromFacts()
; GetSoulFatigueSpellForStage()
; GetAppliedSoulFatigueSpellLabel()
; GetAppliedSoulFatigueSpellCompactLabel()


; --- Soul Bonus Helpers ---
; ==========================

Int Function GetEffectiveSoulBonusTierFromFacts(Int liveTier, Int defiantTrackedTier) Global
    if liveTier == 0
        return IronSoulTiers.NormalizeDefiantTrackedTier(defiantTrackedTier)
    elseif liveTier == 9
        return 9
    endif
    return IronSoulTiers.NormalizeDefiantTrackedTier(liveTier)
EndFunction

Spell Function GetNormalSoulBonusSpell(Int tier, Spell ironSpell, Spell silverSpell, Spell goldSpell, Spell ebonSpell, Spell platinumSpell, Spell devourSpell) Global
    if tier == 1
        return ironSpell
    elseif tier == 2
        return silverSpell
    elseif tier == 3
        return goldSpell
    elseif tier == 4
        return ebonSpell
    elseif tier == 5
        return platinumSpell
    elseif tier == 6
        return devourSpell
    endif
    return None
EndFunction

Spell Function GetDefiantSoulBonusSpell(Int tier, Spell ironSpell, Spell silverSpell, Spell goldSpell, Spell ebonSpell, Spell platinumSpell) Global
    if tier == 1
        return ironSpell
    elseif tier == 2
        return silverSpell
    elseif tier == 3
        return goldSpell
    elseif tier == 4
        return ebonSpell
    elseif tier == 5
        return platinumSpell
    endif
    return None
EndFunction

String Function GetAppliedSoulBonusSpellLabel(Actor player, Spell normalIron, Spell normalSilver, Spell normalGold, Spell normalEbon, Spell normalPlatinum, Spell normalDevour, Spell defiantIron, Spell defiantSilver, Spell defiantGold, Spell defiantEbon, Spell defiantPlatinum) Global
    if !player
        return "none"
    endif

    String appliedLabel = ""
    Int tier = 1
    while tier <= 6
        Spell normalSpell = GetNormalSoulBonusSpell(tier, normalIron, normalSilver, normalGold, normalEbon, normalPlatinum, normalDevour)
        if normalSpell && player.HasSpell(normalSpell)
            String label = "IronSoul_SoulBonus" + IronSoulTiers.GetSoulBonusOrdinal(tier) + IronSoulTiers.SoulTierLabel(tier)
            if appliedLabel != ""
                return "multiple"
            endif
            appliedLabel = label
        endif

        Spell defiantSpell = GetDefiantSoulBonusSpell(tier, defiantIron, defiantSilver, defiantGold, defiantEbon, defiantPlatinum)
        if defiantSpell && player.HasSpell(defiantSpell)
            String defiantLabel = "IronSoul_SoulBonus" + IronSoulTiers.GetSoulBonusOrdinal(tier) + IronSoulTiers.SoulTierLabel(tier) + "Defiant"
            if appliedLabel != ""
                return "multiple"
            endif
            appliedLabel = defiantLabel
        endif
        tier += 1
    endwhile

    if appliedLabel == ""
        return "none"
    endif
    return appliedLabel
EndFunction

String Function GetAppliedSoulBonusSpellCompactLabel(Actor player, Spell normalIron, Spell normalSilver, Spell normalGold, Spell normalEbon, Spell normalPlatinum, Spell normalDevour, Spell defiantIron, Spell defiantSilver, Spell defiantGold, Spell defiantEbon, Spell defiantPlatinum) Global
    if !player
        return "none"
    endif

    String appliedLabel = ""
    Int tier = 1
    while tier <= 6
        Spell normalSpell = GetNormalSoulBonusSpell(tier, normalIron, normalSilver, normalGold, normalEbon, normalPlatinum, normalDevour)
        if normalSpell && player.HasSpell(normalSpell)
            String label = IronSoulTiers.SoulTierLabel(tier)
            if appliedLabel != ""
                return "multiple"
            endif
            appliedLabel = label
        endif

        Spell defiantSpell = GetDefiantSoulBonusSpell(tier, defiantIron, defiantSilver, defiantGold, defiantEbon, defiantPlatinum)
        if defiantSpell && player.HasSpell(defiantSpell)
            String defiantLabel = "Defiant (" + IronSoulTiers.SoulTierLabel(tier) + ")"
            if appliedLabel != ""
                return "multiple"
            endif
            appliedLabel = defiantLabel
        endif
        tier += 1
    endwhile

    if appliedLabel == ""
        return "none"
    endif
    return appliedLabel
EndFunction


; --- Soul Fatigue Helpers ---
; ============================

Int Function NormalizeSoulFatigueSpellStage(Int deaths) Global
    if deaths < 10
        return 0
    elseif deaths > 20
        return 20
    endif
    return deaths
EndFunction

Int Function GetDesiredSoulFatigueStageFromFacts(Bool soulFatigueEnabled, Int liveTier, Int deaths) Global
    if !soulFatigueEnabled
        return 0
    endif
    if liveTier != 0
        return 0
    endif
    return NormalizeSoulFatigueSpellStage(deaths)
EndFunction

Spell Function GetSoulFatigueSpellForStage(Int fatigueStage, Spell fatigue10, Spell fatigue11, Spell fatigue12, Spell fatigue13, Spell fatigue14, Spell fatigue15, Spell fatigue16, Spell fatigue17, Spell fatigue18, Spell fatigue19, Spell fatigue20) Global
    if fatigueStage == 10
        return fatigue10
    elseif fatigueStage == 11
        return fatigue11
    elseif fatigueStage == 12
        return fatigue12
    elseif fatigueStage == 13
        return fatigue13
    elseif fatigueStage == 14
        return fatigue14
    elseif fatigueStage == 15
        return fatigue15
    elseif fatigueStage == 16
        return fatigue16
    elseif fatigueStage == 17
        return fatigue17
    elseif fatigueStage == 18
        return fatigue18
    elseif fatigueStage == 19
        return fatigue19
    elseif fatigueStage >= 20
        return fatigue20
    endif
    return None
EndFunction

String Function GetAppliedSoulFatigueSpellLabel(Actor player, Spell fatigue10, Spell fatigue11, Spell fatigue12, Spell fatigue13, Spell fatigue14, Spell fatigue15, Spell fatigue16, Spell fatigue17, Spell fatigue18, Spell fatigue19, Spell fatigue20) Global
    if !player
        return "none"
    endif

    String appliedLabel = ""
    Int fatigueStage = 10
    while fatigueStage <= 20
        Spell fatigueSpell = GetSoulFatigueSpellForStage(fatigueStage, fatigue10, fatigue11, fatigue12, fatigue13, fatigue14, fatigue15, fatigue16, fatigue17, fatigue18, fatigue19, fatigue20)
        if fatigueSpell && player.HasSpell(fatigueSpell)
            String label = "IronSoul_SoulFatigue" + fatigueStage
            if appliedLabel != ""
                return "multiple"
            endif
            appliedLabel = label
        endif
        fatigueStage += 1
    endwhile

    if appliedLabel == ""
        return "none"
    endif
    return appliedLabel
EndFunction

String Function GetAppliedSoulFatigueSpellCompactLabel(Actor player, Spell fatigue10, Spell fatigue11, Spell fatigue12, Spell fatigue13, Spell fatigue14, Spell fatigue15, Spell fatigue16, Spell fatigue17, Spell fatigue18, Spell fatigue19, Spell fatigue20) Global
    if !player
        return "none"
    endif

    String appliedLabel = ""
    Int fatigueStage = 10
    while fatigueStage <= 20
        Spell fatigueSpell = GetSoulFatigueSpellForStage(fatigueStage, fatigue10, fatigue11, fatigue12, fatigue13, fatigue14, fatigue15, fatigue16, fatigue17, fatigue18, fatigue19, fatigue20)
        if fatigueSpell && player.HasSpell(fatigueSpell)
            String label = fatigueStage + ""
            if appliedLabel != ""
                return "multiple"
            endif
            appliedLabel = label
        endif
        fatigueStage += 1
    endwhile

    if appliedLabel == ""
        return "none"
    endif
    return appliedLabel
EndFunction
