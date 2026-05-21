;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname _DS_DN_QF_DeathSquad_Mine Extends Quest Hidden

;BEGIN ALIAS PROPERTY SpawnMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SpawnMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY TravelDestinationRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_TravelDestinationRef Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY TravelDestinationLocation
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_TravelDestinationLocation Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn02 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
dsDnok.SquadReport(dsDnok.SQUAD_MINE, GetName(), Alias_TravelDestinationLocation.GetLocation(), Alias_TravelDestinationRef.GetActorRef(), Alias_SpawnMarker.GetReference())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

_DS_DN_Draugnarok Property dsDnok Auto
