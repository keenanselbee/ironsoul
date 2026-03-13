Scriptname IronSoulOnDying extends ActiveMagicEffect

IronSoulController Property Controller Auto

; Trigger contract (configured on the magic effect in plugin data):
; - Fires when player health is <= 0
Event OnEffectStart(Actor Target, Actor Caster)

	Actor player = Game.GetPlayer()

	if Target != player
		Debug.Trace("[IronSoul] IronSoulOnDying: Target is not player; exiting")
	    return
	endif

	if Controller
		Controller.HandlePlayerDying(Target, Caster)
	endif

EndEvent