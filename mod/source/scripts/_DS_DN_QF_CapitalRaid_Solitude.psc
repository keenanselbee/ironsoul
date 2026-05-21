;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname _DS_DN_QF_CapitalRaid_Solitude Extends Quest Hidden

;BEGIN ALIAS PROPERTY DraugrSpawn05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn05 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn09
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn09 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn20
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn20 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn13
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn13 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrDeathLordCastle
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrDeathLordCastle Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn17
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn17 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn16
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn16 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY SpawnMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SpawnMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn30
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn30 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn14
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn14 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn15
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn15 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn19
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn19 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn23
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn23 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn07
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn07 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn18
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn18 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn28
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn28 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY TravelDestinationCityRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_TravelDestinationCityRef Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn25
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn25 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY TravelDestinationCastleRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_TravelDestinationCastleRef Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn06
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn06 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn10
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn10 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn12
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn12 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn24
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn24 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn11
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn11 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn08
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn08 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrDeathLordCity
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrDeathLordCity Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn21
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn21 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn22
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn22 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn26
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn26 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn27
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn27 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn29
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn29 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
dsDnok.RaidReport(GetName(), Alias_TravelDestinationCityRef.GetReference(), Alias_SpawnMarker.GetReference())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

_DS_DN_Draugnarok Property dsDnok Auto
