Scriptname _DS_DN_LocHandler extends Quest

_DS_DN_Draugnarok Property dsDnok Auto


Event OnStoryChangeLocation(ObjectReference akActor, Location akOldLocation, Location akNewLocation)

	dsDnok.LocChange(akOldLocation, akNewLocation)

EndEvent
