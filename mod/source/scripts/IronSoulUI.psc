Scriptname IronSoulUI Hidden

; =========================
; --- Table of Contents ---
; =========================

; --- Menu Naming ---
; -------------------
; TierMenuPrefix()
; SwfNoBonus()
; ResolveDeathMessageMenu()
; ResolvePermadeathMenu()
; ResolveRespawnMenu()
; ResolveDefiantFeatUnlockMenu()
; ResolveDefiantIntroMenu()
; ResolveDefiantTransitionMenu()
; ResolveCHIMTransitionMenu()

; --- Flavor Text ---
; -------------------
; PickCHIMLine()
; PickTierLoadFlavor()
; PickLuckLoadFlavor()
; PickPostDeathLoadFlavor()


; --- Menu Naming ---
; ===================

String Function TierMenuPrefix(Int soulTier) Global
    if soulTier == 0
        return "0defiant"
    elseif soulTier == 1
        return "1iron"
    elseif soulTier == 2
        return "2silver"
    elseif soulTier == 3
        return "3gold"
    elseif soulTier == 4
        return "4ebon"
    elseif soulTier == 5
        return "5platinum"
    elseif soulTier == 6
        return "6devour"
    elseif soulTier == 9
        return "9chim"
    endif
    return "1iron"
EndFunction

String Function SwfNoBonus(String menuName, Bool soulBonusEnabled) Global
    if menuName == ""
        return ""
    endif
    if StringUtil.Find(menuName, "dragonsoulrevive") != -1
        return menuName
    endif
    if !soulBonusEnabled
        return menuName + "nobonus"
    endif
    return menuName
EndFunction

String Function ResolveDeathMessageMenu(Int soulTier, Int deathsNow) Global
    if soulTier == 6
        return "6devourdeath" + deathsNow
    endif
    if soulTier == 9
        return "9chimdeath" + Utility.RandomInt(1, 9)
    endif
    if soulTier == 0
        return "0defiantdeath" + deathsNow
    endif
    return TierMenuPrefix(soulTier) + "death" + deathsNow
EndFunction

String Function ResolvePermadeathMenu(Int soulTier) Global
    if soulTier == 6
        return "6devourpermadeath"
    endif
    if soulTier == 9
        return "9chimdeath"
    endif
    if soulTier == 0
        return "0defiantpermadeath"
    endif
    return TierMenuPrefix(soulTier) + "permadeath"
EndFunction

String Function ResolveRespawnMenu(Int soulTier) Global
    if soulTier == 9
        return "9chimrespawn"
    endif
    if soulTier == 0
        return "0defiantrespawn"
    endif
    return TierMenuPrefix(soulTier) + "respawn"
EndFunction

String Function ResolveDefiantFeatUnlockMenu(Bool soulFatigueEnabled) Global
    String base = "0defiantfeatunlock"
    if !soulFatigueEnabled
        base = base + "nofatigue"
    endif
    return base
EndFunction

String Function ResolveDefiantIntroMenu(Bool soulBonusEnabled, Bool soulFatigueEnabled, Bool deathResetEnabled) Global
    String base = "0defiantintro"
    if !soulBonusEnabled
        base = base + "nobonus"
    endif
    if !soulFatigueEnabled
        base = base + "nofatigue"
    endif
    if !deathResetEnabled
        base = base + "noreset"
    endif
    return base
EndFunction

String Function ResolveDefiantTransitionMenu(Int curTier) Global
    if curTier == 6
        return "0defiantdeath10platinum"
    elseif curTier == 5
        return "0defiantdeath10platinum"
    elseif curTier == 4
        return "0defiantdeath10ebon"
    elseif curTier == 3
        return "0defiantdeath10gold"
    elseif curTier == 2
        return "0defiantdeath10silver"
    endif
    return "0defiantdeath10iron"
EndFunction

String Function ResolveCHIMTransitionMenu(Int curTier) Global
    if curTier == 0
        return "9chimdeathdefiant"
    elseif curTier == 1
        return "9chimdeathiron"
    elseif curTier == 2
        return "9chimdeathsilver"
    elseif curTier == 3
        return "9chimdeathgold"
    elseif curTier == 4
        return "9chimdeathebon"
    elseif curTier == 6
        return "9chimdeathplatinum"
    elseif curTier == 5
        return "9chimdeathplatinum"
    endif
    return "9chimdeath"
EndFunction


; --- Flavor Text ---
; ===================

String Function PickCHIMLine(Int idx) Global
    if idx == 0
        return "The Godhead dreams on."
    elseif idx == 1
        return "You remain within the Dream."
    elseif idx == 2
        return "The Dream does not end here."
    elseif idx == 3
        return "Knowing the Dream, you persist."
    elseif idx == 4
        return "You refuse to wake."
    elseif idx == 5
        return "The cycle continues by your will."
    elseif idx == 6
        return "You perceive the Dream and remain."
    elseif idx == 7
        return "Existence endures within the Dream."
    elseif idx == 8
        return "The Dreamer stirs."
    endif
    return "You do not zero-sum."
EndFunction

String Function PickTierLoadFlavor(Int soulTier, Int deaths, Bool chimTier, Bool defiantTier) Global
    if chimTier
        return PickCHIMLine(Utility.RandomInt(0, 9))
    endif

    if defiantTier
        if deaths >= 17
            return "Your soul is wearing thin."
        endif
        return "Your Defiant Soul endures."
    endif

    if deaths <= 0
        if soulTier == 6
            return "Your Devour Soul knows no equal."
        elseif soulTier == 5
            return "Your Platinum Soul knows no equal"
        elseif soulTier == 4
            return "Your Ebon Soul defies fate."
        elseif soulTier == 3
            return "Your Gilded Soul is peerless."
        elseif soulTier == 2
            return "Your Silver Soul is peerless."
        endif
        return "Your Iron Soul is peerless."
    elseif deaths <= 3
        if soulTier == 6
            return "Your Devour Soul prevails."
        elseif soulTier == 5
            return "Your Platinum Soul prevails."
        elseif soulTier == 4
            return "Your Ebon Soul prevails."
        elseif soulTier == 3
            return "Your Gilded Soul prevails."
        elseif soulTier == 2
            return "Your Silver Soul prevails."
        endif
        return "Your Iron Soul prevails."
    elseif deaths <= 6
        if soulTier == 6
            return "Your Devour Soul rises stronger."
        elseif soulTier == 5
            return "Your Platinum Soul rises stronger."
        elseif soulTier == 4
            return "Your Ebon Soul rises stronger."
        elseif soulTier == 3
            return "Your Gilded Soul rises stronger."
        elseif soulTier == 2
            return "Your Silver Soul rises stronger."
        endif
        return "Your Iron Soul rises stronger."
    endif

    if soulTier == 6
        return "Your Devour Soul endures."
    elseif soulTier == 5
        return "Your Platinum Soul endures."
    elseif soulTier == 4
        return "Your Ebon Soul endures."
    elseif soulTier == 3
        return "Your Gilded Soul endures."
    elseif soulTier == 2
        return "Your Silver Soul endures."
    endif
    return "Your Iron Soul endures."
EndFunction

String Function PickLuckLoadFlavor(Int luck, Int maxLuck) Global
    Int r = Utility.RandomInt(0, 4)
    Int tier = IronSoulLuck.LuckTier(luck, maxLuck)

    if tier >= 3
        if r == 0
            return "Your confidence holds."
        elseif r == 1
            return "Your resolve carries you forward."
        elseif r == 2
            return "Your steps feel true."
        elseif r == 3
            return "The path ahead is clear."
        endif
        return "You move with purpose."
    elseif tier == 2
        if r == 0
            return "You feel steady again."
        elseif r == 1
            return "Your thoughts are clear."
        elseif r == 2
            return "You feel grounded."
        elseif r == 3
            return "Your footing is firm."
        endif
        return "You feel balanced once more."
    elseif tier == 1
        if r == 0
            return "You remain unsettled."
        elseif r == 1
            return "Unease lingers."
        elseif r == 2
            return "Caution tempers your steps."
        elseif r == 3
            return "You feel on edge."
        endif
        return "Doubt has not fully left you."
    endif

    if r == 0
        return "You are still shaken from your recent trial."
    elseif r == 1
        return "Your recent ordeal still weighs heavily on you."
    elseif r == 2
        return "Your breath has steadied, but not your thoughts."
    elseif r == 3
        return "You have not yet recovered from what nearly ended you."
    endif
    return "Your nerves have not fully settled."
EndFunction

String Function PickPostDeathLoadFlavor() Global
    Int r = Utility.RandomInt(0, 4)
    if r == 0
        return "The premonition of your death grips your soul."
    elseif r == 1
        return "You return shaken from a waking nightmare."
    elseif r == 2
        return "You see the fatal moment just before the blow lands."
    elseif r == 3
        return "The vision lingers, warning of what could be."
    endif
    return "You stand with foreknowledge you never wanted."
EndFunction
