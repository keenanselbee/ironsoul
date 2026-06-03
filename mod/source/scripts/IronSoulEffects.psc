Scriptname IronSoulEffects extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()
; LogEffectsSnapshot()

; --- Component Runtime ---
; -------------------------
; HasPresentationRuntime()
; CanApplySoulPresentation()
; GetDefiantTrackedTierForLiveTier()
; GetDesiredSoulBonusSpellForFacts()
; GetDesiredSoulBonusSpell()
; SyncSoulBonusSpell()
; GetDesiredSoulFatigueStageForFacts()
; GetDesiredSoulFatigueSpellForFacts()
; GetDesiredSoulFatigueStage()
; GetDesiredSoulFatigueSpell()
; SyncSoulFatigueSpell()
; SyncSoulPresentationSpells()
; ClearSoulPresentationSpells()
; SyncSoulPresentationAndStats()
; GetAppliedSoulBonusSpellCompactLabel()
; GetAppliedSoulFatigueSpellCompactLabel()
; LogSnapshot()

; --- Soul Bonus Helpers ---
; --------------------------
; GetEffectiveSoulBonusTierFromFacts()
; GetNormalSoulBonusSpell()
; GetDefiantSoulBonusSpell()
; GetAppliedSoulBonusSpellLabelFromSpells()
; GetAppliedSoulBonusSpellCompactLabelFromSpells()
; SyncSoulBonusSpellFromSpells()

; --- Soul Fatigue Helpers ---
; ----------------------------
; NormalizeSoulFatigueSpellStage()
; GetDesiredSoulFatigueStageFromFacts()
; GetSoulFatigueSpellForStage()
; GetAppliedSoulFatigueSpellLabelFromSpells()
; GetAppliedSoulFatigueSpellCompactLabelFromSpells()
; SyncSoulFatigueSpellFromSpells()


; --- Wired Dependencies & Runtime State ---
; ==========================================

IronSoulController Property Controller Auto

Spell Property IronSoul_SoulBonus1Iron Auto
Spell Property IronSoul_SoulBonus2Silver Auto
Spell Property IronSoul_SoulBonus3Gold Auto
Spell Property IronSoul_SoulBonus4Ebon Auto
Spell Property IronSoul_SoulBonus5Platinum Auto
Spell Property IronSoul_SoulBonus6Devour Auto
Spell Property IronSoul_SoulBonus1IronDefiant Auto
Spell Property IronSoul_SoulBonus2SilverDefiant Auto
Spell Property IronSoul_SoulBonus3GoldDefiant Auto
Spell Property IronSoul_SoulBonus4EbonDefiant Auto
Spell Property IronSoul_SoulBonus5PlatinumDefiant Auto
Spell Property IronSoul_SoulFatigue10 Auto
Spell Property IronSoul_SoulFatigue11 Auto
Spell Property IronSoul_SoulFatigue12 Auto
Spell Property IronSoul_SoulFatigue13 Auto
Spell Property IronSoul_SoulFatigue14 Auto
Spell Property IronSoul_SoulFatigue15 Auto
Spell Property IronSoul_SoulFatigue16 Auto
Spell Property IronSoul_SoulFatigue17 Auto
Spell Property IronSoul_SoulFatigue18 Auto
Spell Property IronSoul_SoulFatigue19 Auto
Spell Property IronSoul_SoulFatigue20 Auto


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Tiers
        return False
    endif
    return True
EndFunction

Function LogEffectsSnapshot(Int level, String msg)
    if Controller && Controller.Config
        Controller.Config.LogComponentSnapshot("Effects", level, msg)
        return
    endif

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [Snapshot] " + msg)
EndFunction


; --- Component Runtime ---
; =========================

Bool Function HasPresentationRuntime(Bool requireDeath = False)
    if !HasCoreRuntime()
        return False
    endif
    if requireDeath && !Controller.Death
        return False
    endif
    return True
EndFunction

Bool Function CanApplySoulPresentation(Actor player, String guid, Bool requireDeath = False)
    if !player || guid == ""
        return False
    endif
    if !HasPresentationRuntime(requireDeath)
        return False
    endif
    if Controller.Config.IsUninstallMode() || Controller.IsModDisabled()
        return False
    endif
    return True
EndFunction

Int Function GetDefiantTrackedTierForLiveTier(Actor player, String guid, Int liveTier)
    if !HasPresentationRuntime(False) || !player || guid == ""
        return IronSoulTiers.NormalizeDefiantTrackedTier(liveTier)
    endif
    if liveTier == Controller.Tiers.TIER_DEFIANT
        return Controller.Tiers.GetDefiantTrackedTier(player, guid)
    endif
    return Controller.Tiers.TIER_IRON
EndFunction

Spell Function GetDesiredSoulBonusSpellForFacts(Bool soulBonusEnabled, Int liveTier, Int defiantTrackedTier)
    if !soulBonusEnabled
        return None
    endif

    Int bonusTier = GetEffectiveSoulBonusTierFromFacts(liveTier, defiantTrackedTier)
    if !IronSoulTiers.IsNormalSoulTier(bonusTier)
        return None
    endif

    if HasPresentationRuntime(False) && liveTier == Controller.Tiers.TIER_DEFIANT
        return GetDefiantSoulBonusSpell(bonusTier, IronSoul_SoulBonus1IronDefiant, IronSoul_SoulBonus2SilverDefiant, IronSoul_SoulBonus3GoldDefiant, IronSoul_SoulBonus4EbonDefiant, IronSoul_SoulBonus5PlatinumDefiant)
    endif
    return GetNormalSoulBonusSpell(bonusTier, IronSoul_SoulBonus1Iron, IronSoul_SoulBonus2Silver, IronSoul_SoulBonus3Gold, IronSoul_SoulBonus4Ebon, IronSoul_SoulBonus5Platinum, IronSoul_SoulBonus6Devour)
EndFunction

Spell Function GetDesiredSoulBonusSpell(Actor player, String guid)
    if !HasCoreRuntime()
        return None
    endif
    if !player || guid == "" || !Controller.Config.IsSoulBonusEnabled()
        return None
    endif

    Int liveTier = Controller.Tiers.GetCurrentTier(player, guid)
    Int defiantTrackedTier = GetDefiantTrackedTierForLiveTier(player, guid, liveTier)
    return GetDesiredSoulBonusSpellForFacts(Controller.Config.IsSoulBonusEnabled(), liveTier, defiantTrackedTier)
EndFunction

Function SyncSoulBonusSpell(Actor player, String guid)
    Spell desiredSpell = None
    if CanApplySoulPresentation(player, guid, False)
        Int liveTier = Controller.Tiers.GetCurrentTier(player, guid)
        Int defiantTrackedTier = GetDefiantTrackedTierForLiveTier(player, guid, liveTier)
        desiredSpell = GetDesiredSoulBonusSpellForFacts(Controller.Config.IsSoulBonusEnabled(), liveTier, defiantTrackedTier)
    endif

    SyncSoulBonusSpellFromSpells(player, desiredSpell, IronSoul_SoulBonus1Iron, IronSoul_SoulBonus2Silver, IronSoul_SoulBonus3Gold, IronSoul_SoulBonus4Ebon, IronSoul_SoulBonus5Platinum, IronSoul_SoulBonus6Devour, IronSoul_SoulBonus1IronDefiant, IronSoul_SoulBonus2SilverDefiant, IronSoul_SoulBonus3GoldDefiant, IronSoul_SoulBonus4EbonDefiant, IronSoul_SoulBonus5PlatinumDefiant)
EndFunction

Int Function GetDesiredSoulFatigueStageForFacts(Bool soulFatigueEnabled, Int liveTier, Int deaths)
    if !soulFatigueEnabled
        return 0
    endif
    if !HasPresentationRuntime(False)
        return GetDesiredSoulFatigueStageFromFacts(soulFatigueEnabled, liveTier, deaths)
    endif
    if liveTier != Controller.Tiers.TIER_DEFIANT
        return 0
    endif
    return NormalizeSoulFatigueSpellStage(deaths)
EndFunction

Spell Function GetDesiredSoulFatigueSpellForFacts(Bool soulFatigueEnabled, Int liveTier, Int deaths)
    Int fatigueStage = GetDesiredSoulFatigueStageForFacts(soulFatigueEnabled, liveTier, deaths)
    if fatigueStage <= 0
        return None
    endif
    return GetSoulFatigueSpellForStage(fatigueStage, IronSoul_SoulFatigue10, IronSoul_SoulFatigue11, IronSoul_SoulFatigue12, IronSoul_SoulFatigue13, IronSoul_SoulFatigue14, IronSoul_SoulFatigue15, IronSoul_SoulFatigue16, IronSoul_SoulFatigue17, IronSoul_SoulFatigue18, IronSoul_SoulFatigue19, IronSoul_SoulFatigue20)
EndFunction

Int Function GetDesiredSoulFatigueStage(Actor player, String guid)
    if !HasPresentationRuntime(True)
        return 0
    endif
    if !player || guid == ""
        return 0
    endif

    Int liveTier = Controller.Tiers.GetCurrentTier(player, guid)
    Int deaths = Controller.Death.GetCurrentDeathCount(player, guid)
    return GetDesiredSoulFatigueStageForFacts(Controller.Config.IsSoulFatigueEnabled(), liveTier, deaths)
EndFunction

Spell Function GetDesiredSoulFatigueSpell(Actor player, String guid)
    if !HasPresentationRuntime(True)
        return None
    endif
    if !player || guid == ""
        return None
    endif

    Int liveTier = Controller.Tiers.GetCurrentTier(player, guid)
    Int deaths = Controller.Death.GetCurrentDeathCount(player, guid)
    return GetDesiredSoulFatigueSpellForFacts(Controller.Config.IsSoulFatigueEnabled(), liveTier, deaths)
EndFunction

Function SyncSoulFatigueSpell(Actor player, String guid)
    Spell desiredSpell = None
    if CanApplySoulPresentation(player, guid, True)
        Int liveTier = Controller.Tiers.GetCurrentTier(player, guid)
        Int deaths = Controller.Death.GetCurrentDeathCount(player, guid)
        desiredSpell = GetDesiredSoulFatigueSpellForFacts(Controller.Config.IsSoulFatigueEnabled(), liveTier, deaths)
    endif

    SyncSoulFatigueSpellFromSpells(player, desiredSpell, IronSoul_SoulFatigue10, IronSoul_SoulFatigue11, IronSoul_SoulFatigue12, IronSoul_SoulFatigue13, IronSoul_SoulFatigue14, IronSoul_SoulFatigue15, IronSoul_SoulFatigue16, IronSoul_SoulFatigue17, IronSoul_SoulFatigue18, IronSoul_SoulFatigue19, IronSoul_SoulFatigue20)
EndFunction

Function SyncSoulPresentationSpells(Actor player, Spell desiredBonusSpell, Spell desiredFatigueSpell)
    SyncSoulBonusSpellFromSpells(player, desiredBonusSpell, IronSoul_SoulBonus1Iron, IronSoul_SoulBonus2Silver, IronSoul_SoulBonus3Gold, IronSoul_SoulBonus4Ebon, IronSoul_SoulBonus5Platinum, IronSoul_SoulBonus6Devour, IronSoul_SoulBonus1IronDefiant, IronSoul_SoulBonus2SilverDefiant, IronSoul_SoulBonus3GoldDefiant, IronSoul_SoulBonus4EbonDefiant, IronSoul_SoulBonus5PlatinumDefiant)
    SyncSoulFatigueSpellFromSpells(player, desiredFatigueSpell, IronSoul_SoulFatigue10, IronSoul_SoulFatigue11, IronSoul_SoulFatigue12, IronSoul_SoulFatigue13, IronSoul_SoulFatigue14, IronSoul_SoulFatigue15, IronSoul_SoulFatigue16, IronSoul_SoulFatigue17, IronSoul_SoulFatigue18, IronSoul_SoulFatigue19, IronSoul_SoulFatigue20)
EndFunction

Function ClearSoulPresentationSpells(Actor player)
    if !player
        return
    endif
    SyncSoulPresentationSpells(player, None, None)
EndFunction

Function SyncSoulPresentationAndStats(Actor player, String guid)
    Spell desiredBonusSpell = None
    Spell desiredFatigueSpell = None

    if CanApplySoulPresentation(player, guid, True)
        Bool soulBonusEnabled = Controller.Config.IsSoulBonusEnabled()
        Bool soulFatigueEnabled = Controller.Config.IsSoulFatigueEnabled()
        Int liveTier = Controller.Tiers.GetCurrentTier(player, guid)
        Int defiantTrackedTier = GetDefiantTrackedTierForLiveTier(player, guid, liveTier)
        Int deaths = Controller.Death.GetCurrentDeathCount(player, guid)

        desiredBonusSpell = GetDesiredSoulBonusSpellForFacts(soulBonusEnabled, liveTier, defiantTrackedTier)
        desiredFatigueSpell = GetDesiredSoulFatigueSpellForFacts(soulFatigueEnabled, liveTier, deaths)
    endif

    SyncSoulPresentationSpells(player, desiredBonusSpell, desiredFatigueSpell)
EndFunction

String Function GetAppliedSoulBonusSpellCompactLabel(Actor player)
    return GetAppliedSoulBonusSpellCompactLabelFromSpells(player, IronSoul_SoulBonus1Iron, IronSoul_SoulBonus2Silver, IronSoul_SoulBonus3Gold, IronSoul_SoulBonus4Ebon, IronSoul_SoulBonus5Platinum, IronSoul_SoulBonus6Devour, IronSoul_SoulBonus1IronDefiant, IronSoul_SoulBonus2SilverDefiant, IronSoul_SoulBonus3GoldDefiant, IronSoul_SoulBonus4EbonDefiant, IronSoul_SoulBonus5PlatinumDefiant)
EndFunction

String Function GetAppliedSoulFatigueSpellCompactLabel(Actor player)
    return GetAppliedSoulFatigueSpellCompactLabelFromSpells(player, IronSoul_SoulFatigue10, IronSoul_SoulFatigue11, IronSoul_SoulFatigue12, IronSoul_SoulFatigue13, IronSoul_SoulFatigue14, IronSoul_SoulFatigue15, IronSoul_SoulFatigue16, IronSoul_SoulFatigue17, IronSoul_SoulFatigue18, IronSoul_SoulFatigue19, IronSoul_SoulFatigue20)
EndFunction

Function LogSnapshot()
    if !HasCoreRuntime()
        return
    endif

    Actor player = Game.GetPlayer()
    if player
        String soulBonusState = GetAppliedSoulBonusSpellCompactLabel(player)
        String soulFatigueState = GetAppliedSoulFatigueSpellCompactLabel(player)
        LogEffectsSnapshot(IronSoulConfig.LOG_INFO(), "Effects: SoulBonus=" + soulBonusState + " SoulFatigue=" + soulFatigueState)
        if soulBonusState == "multiple" || soulFatigueState == "multiple"
            LogEffectsSnapshot(IronSoulConfig.LOG_ERR(), "Effects: Multiple presentation spells detected")
        endif
    endif
EndFunction


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

String Function GetAppliedSoulBonusSpellLabelFromSpells(Actor player, Spell normalIron, Spell normalSilver, Spell normalGold, Spell normalEbon, Spell normalPlatinum, Spell normalDevour, Spell defiantIron, Spell defiantSilver, Spell defiantGold, Spell defiantEbon, Spell defiantPlatinum) Global
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

String Function GetAppliedSoulBonusSpellCompactLabelFromSpells(Actor player, Spell normalIron, Spell normalSilver, Spell normalGold, Spell normalEbon, Spell normalPlatinum, Spell normalDevour, Spell defiantIron, Spell defiantSilver, Spell defiantGold, Spell defiantEbon, Spell defiantPlatinum) Global
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

Function SyncSoulBonusSpellFromSpells(Actor player, Spell desiredSpell, Spell normalIron, Spell normalSilver, Spell normalGold, Spell normalEbon, Spell normalPlatinum, Spell normalDevour, Spell defiantIron, Spell defiantSilver, Spell defiantGold, Spell defiantEbon, Spell defiantPlatinum) Global
    if !player
        return
    endif

    Int tier = 1
    while tier <= 6
        Spell normalSpell = GetNormalSoulBonusSpell(tier, normalIron, normalSilver, normalGold, normalEbon, normalPlatinum, normalDevour)
        if normalSpell && normalSpell != desiredSpell && player.HasSpell(normalSpell)
            player.RemoveSpell(normalSpell)
        endif

        Spell defiantSpell = GetDefiantSoulBonusSpell(tier, defiantIron, defiantSilver, defiantGold, defiantEbon, defiantPlatinum)
        if defiantSpell && defiantSpell != desiredSpell && player.HasSpell(defiantSpell)
            player.RemoveSpell(defiantSpell)
        endif
        tier += 1
    endwhile

    if desiredSpell && !player.HasSpell(desiredSpell)
        player.AddSpell(desiredSpell, False)
    endif
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

String Function GetAppliedSoulFatigueSpellLabelFromSpells(Actor player, Spell fatigue10, Spell fatigue11, Spell fatigue12, Spell fatigue13, Spell fatigue14, Spell fatigue15, Spell fatigue16, Spell fatigue17, Spell fatigue18, Spell fatigue19, Spell fatigue20) Global
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

String Function GetAppliedSoulFatigueSpellCompactLabelFromSpells(Actor player, Spell fatigue10, Spell fatigue11, Spell fatigue12, Spell fatigue13, Spell fatigue14, Spell fatigue15, Spell fatigue16, Spell fatigue17, Spell fatigue18, Spell fatigue19, Spell fatigue20) Global
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

Function SyncSoulFatigueSpellFromSpells(Actor player, Spell desiredSpell, Spell fatigue10, Spell fatigue11, Spell fatigue12, Spell fatigue13, Spell fatigue14, Spell fatigue15, Spell fatigue16, Spell fatigue17, Spell fatigue18, Spell fatigue19, Spell fatigue20) Global
    if !player
        return
    endif

    Int fatigueStage = 10
    while fatigueStage <= 20
        Spell fatigueSpell = GetSoulFatigueSpellForStage(fatigueStage, fatigue10, fatigue11, fatigue12, fatigue13, fatigue14, fatigue15, fatigue16, fatigue17, fatigue18, fatigue19, fatigue20)
        if fatigueSpell && fatigueSpell != desiredSpell && player.HasSpell(fatigueSpell)
            player.RemoveSpell(fatigueSpell)
        endif
        fatigueStage += 1
    endwhile

    if desiredSpell && !player.HasSpell(desiredSpell)
        player.AddSpell(desiredSpell, False)
    endif
EndFunction
