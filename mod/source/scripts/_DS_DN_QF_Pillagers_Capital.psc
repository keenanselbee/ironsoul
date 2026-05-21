;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname _DS_DN_QF_Pillagers_Capital Extends Quest Hidden

;BEGIN ALIAS PROPERTY DraugrSpawn03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY VictimRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_VictimRef Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DraugrSpawn02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DraugrSpawn02 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
dsDnok.PillageReport(GetName(), Alias_VictimRef.GetActorRef())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

_DS_DN_Draugnarok Property dsDnok Auto
