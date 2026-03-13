Scriptname IronSoulPlayerAlias extends ReferenceAlias

IronSoulController Property Controller Auto

Event OnInit()
	if Controller
        Debug.Trace("[IronSoul] IronSoulPlayerAlias: OnInit event fired")
	endif
EndEvent

Event OnPlayerLoadGame()
    if Controller
        Controller.OnPlayerLoadGame(True)
    else
        Debug.Trace("[IronSoul] [ERR] PlayerAlias OnPlayerLoadGame: Controller property is None (alias not wired?)")
    endif
EndEvent