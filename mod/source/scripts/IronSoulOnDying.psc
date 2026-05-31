Scriptname IronSoulOnDying extends ActiveMagicEffect

IronSoulController Property Controller Auto

Function LogOnDying(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("OnDying", level, msg, suppressNotify)
        return
    endif

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [OnDying] " + msg)
EndFunction

; Trigger contract (configured on the magic effect in plugin data):
; - Fires when player health is <= 0
Event OnEffectStart(Actor Target, Actor Caster)

    Actor player = Game.GetPlayer()

    if Target != player
        LogOnDying(IronSoulConfig.LOG_DBG(), "IronSoulOnDying: Target is not player; exiting")
        return
    endif

    if Controller && Controller.Death
        Controller.Death.HandlePlayerDying(Target, Caster)
    endif

EndEvent
