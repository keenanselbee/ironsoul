;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname _DS_DN_QF_GateCrashers_Riften Extends Quest Hidden

;BEGIN ALIAS PROPERTY DraugrSpawn04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn09
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn09 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn08
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn08 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY SpawnMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SpawnMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY GateRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_GateRef Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn06
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn06 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY GateToUnlockRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_GateToUnlockRef Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn07
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn07 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn05 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn03 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
dsDnok.GateReport(GetName(), Alias_GateRef.GetReference(), Alias_SpawnMarker.GetReference())
Alias_GateToUnlockRef.GetRef().Lock(False)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

_DS_DN_Draugnarok Property dsDnok Auto
