Scriptname _DS_DN_KillHandler extends Quest  

_DS_DN_Draugnarok Property dsDnok Auto


Event OnStoryKillActor(ObjectReference akVictim, ObjectReference akKiller, Location akLocation, Int aiCrimeStatus, Int aiRelationshipRank)

	dsDnok.KillReport(akVictim, akLocation)

EndEvent
