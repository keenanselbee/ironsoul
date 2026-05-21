;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname _DS_DN_QF_Ambushers01 Extends Quest Hidden

;BEGIN ALIAS PROPERTY SpawnMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SpawnMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY AmbushLocationRef
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_AmbushLocationRef Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY AmbushDestinationRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_AmbushDestinationRef Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY PlayerRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PlayerRef Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn07
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn07 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn08
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn08 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn05 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn09
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn09 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn06
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn06 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
DeleteWhenAbleAllRefs()

dsDnok.ReportExhausted(GetName())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
dsDnok.AmbushReport(GetName(), Alias_AmbushLocationRef.GetLocation())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Function DeleteWhenAbleAllRefs()
	DeleteIfAble(Alias_DraugrSpawn01.GetReference())
	DeleteIfAble(Alias_DraugrSpawn02.GetReference())
	DeleteIfAble(Alias_DraugrSpawn03.GetReference())
	DeleteIfAble(Alias_DraugrSpawn04.GetReference())
	DeleteIfAble(Alias_DraugrSpawn05.GetReference())
	DeleteIfAble(Alias_DraugrSpawn06.GetReference())
	DeleteIfAble(Alias_DraugrSpawn07.GetReference())
	DeleteIfAble(Alias_DraugrSpawn08.GetReference())
	DeleteIfAble(Alias_DraugrSpawn09.GetReference())
EndFunction

Function DeleteIfAble(ObjectReference akRef)
	If akRef != None
		akRef.DeleteWhenAble()
	EndIf
EndFunction

_DS_DN_Draugnarok Property dsDnok Auto
