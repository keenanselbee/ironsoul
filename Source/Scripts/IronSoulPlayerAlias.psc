Scriptname IronSoulPlayerAlias extends ReferenceAlias

IronSoulController Property Controller Auto

Event OnPlayerLoadGame()
	if Controller
		Controller.GameReloaded(True)
	endif
EndEvent

Event OnDying(Actor akKiller)
	if Controller
		Controller.HandlePlayerDying(akKiller)
	endif
EndEvent
