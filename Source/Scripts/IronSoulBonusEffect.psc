Scriptname IronSoulBonusEffect extends ActiveMagicEffect

Float Property BonusAmount = 10.0 Auto

Float _appliedHealth = 0.0
Float _appliedMagicka = 0.0
Float _appliedStamina = 0.0

Float Function ClampNegativeDeltaToMin1(Actor a, String av, Float requestedDelta)
    if requestedDelta >= 0.0
        return requestedDelta
    endif

    Float maxNow = a.GetAVMax(av)
    Float minAllowedDelta = -(maxNow - 1.0)
    if minAllowedDelta > 0.0
        ; Already at/below floor due to external changes: do not reduce further.
        return 0.0
    endif

    if requestedDelta < minAllowedDelta
        return minAllowedDelta
    endif
    return requestedDelta
EndFunction

Event OnEffectStart(Actor akTarget, Actor akCaster)
    if !akTarget
        return
    endif

    Float effective = BonusAmount
    Int tier = 2
    Int deaths = 0

    ; Intention:
    ; - CHIM (0): no SoulBonus and no SoulFatigue.
    ; - Defiant (1): SoulFatigue path.
    ; - Iron+ (2..6): SoulBonus path.
    ; Defiant/death values are read from authoritative datastore keys.
    String guid = StorageUtil.GetStringValue(akTarget, "IS_9975", "")
    if guid != ""
        String tierKey = "IS_2204:" + guid
        if IronSoulNative.DataHasKey(tierKey)
            tier = IronSoulNative.DataGetInt(tierKey, 2)
        elseif StorageUtil.HasIntValue(akTarget, tierKey)
            tier = StorageUtil.GetIntValue(akTarget, tierKey, 2)
        endif

        if tier < 0
            tier = 0
        elseif tier > 6
            tier = 6
        endif

        if tier == 0
            ; CHIM tier: no SoulBonus and no SoulFatigue.
            effective = 0.0
        else
            if tier == 1
                Int disableSoulFatigue = IronSoulNative.GetConfigInt("DisableSoulFatigue", 0)
                if disableSoulFatigue == 0
                    ; Curve in Defiant mode:
                    ; death <=10 => 0, death 11 => -1, etc.
                    String deathKey = "IS_8155:" + guid
                    if IronSoulNative.DataHasKey(deathKey)
                        deaths = IronSoulNative.DataGetInt(deathKey, 0)
                    elseif StorageUtil.HasIntValue(akTarget, deathKey)
                        deaths = StorageUtil.GetIntValue(akTarget, deathKey, 0)
                    endif

                    if deaths <= 10
                        effective = 0.0
                    else
                        effective = 10.0 - (deaths as Float)
                    endif

                    ; Defiant fatigue should never become a positive stat bonus.
                    if effective > 0.0
                        effective = 0.0
                    endif
                else
                    ; Defiant active but fatigue disabled: no SoulBonus or fatigue modifier.
                    effective = 0.0
                endif
            endif
        endif
    endif

    _appliedHealth = ClampNegativeDeltaToMin1(akTarget, "Health", effective)
    _appliedMagicka = ClampNegativeDeltaToMin1(akTarget, "Magicka", effective)
    _appliedStamina = ClampNegativeDeltaToMin1(akTarget, "Stamina", effective)

    if _appliedHealth != 0.0 || _appliedMagicka != 0.0 || _appliedStamina != 0.0
        akTarget.ModAV("Health", _appliedHealth)
        akTarget.ModAV("Magicka", _appliedMagicka)
        akTarget.ModAV("Stamina", _appliedStamina)
    endif
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    if !akTarget
        return
    endif
    akTarget.ModAV("Health", -_appliedHealth)
    akTarget.ModAV("Magicka", -_appliedMagicka)
    akTarget.ModAV("Stamina", -_appliedStamina)
EndEvent
