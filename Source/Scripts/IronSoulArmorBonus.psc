Scriptname IronSoulArmorBonus extends activemagiceffect  

Float Property ArmorBonus = 5.0 Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    if akTarget
        akTarget.ModActorValue("DamageResist", ArmorBonus)
    endif
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    if akTarget
        akTarget.ModActorValue("DamageResist", -ArmorBonus)
    endif
EndEvent
