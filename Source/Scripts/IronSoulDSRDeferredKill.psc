Scriptname IronSoulDSRDeferredKill extends ActiveMagicEffect  

GlobalVariable Property IronSoul_DSR_Enabled Auto ; 1.0 = enabled, 0.0 = disabled (set by Iron Soul)

Bool Function _IsDSREnabled()
	if IronSoul_DSR_Enabled
		return (IronSoul_DSR_Enabled.GetValue() != 0.0)
	endif
	return True ; fail-open if property not filled
EndFunction

Event OnEffectStart(Actor Target, Actor Caster)
	;Debug.Notification("Start DeferredKill")
	if !_IsDSREnabled()
		return
	endif
	Target.StartDeferredKill()
	;Game.GetPlayer().StartDeferredKill()
Endevent