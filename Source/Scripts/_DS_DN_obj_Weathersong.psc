Scriptname _DS_DN_obj_Weathersong extends ObjectReference  

_DS_DN_Draugnarok Property dsDnok Auto


Event OnEquipped(Actor akActor)

	Debug.MessageBox( "Weather: " + Weather.GetCurrentWeather() )
;	dsDnok.TestMultiRaid()

EndEvent

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)

	If (!akNewContainer)
		dsDnok.FigureWeather(None, True)
		Game.GetPlayer().AddItem(self)
	EndIf
	
EndEvent
