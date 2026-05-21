;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname _DS_DN_QF_RoamingMob03 Extends Quest Hidden

;BEGIN ALIAS PROPERTY VictimRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_VictimRef Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Draugr1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Draugr2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Draugr9
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr9 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Draugr7
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr7 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Draugr4
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr4 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Draugr3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Draugr5
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr5 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Draugr8
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr8 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY SpawnMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SpawnMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Draugr6
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr6 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN AUTOCAST TYPE WEScript
Quest __temp = self as Quest
WEScript kmyQuest = __temp as WEScript
;END AUTOCAST
;BEGIN CODE
DeleteWhenAbleAllRefs()
dsDnok.ReportDispersing(GetName())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
dsDnok.MobReport(GetName(), Alias_SpawnMarker.GetReference())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Function DeleteWhenAbleAllRefs()
	DeleteIfAble(Alias_Draugr1.GetReference())
	DeleteIfAble(Alias_Draugr2.GetReference())
	DeleteIfAble(Alias_Draugr3.GetReference())
	DeleteIfAble(Alias_Draugr4.GetReference())
	DeleteIfAble(Alias_Draugr5.GetReference())
	DeleteIfAble(Alias_Draugr6.GetReference())
	DeleteIfAble(Alias_Draugr7.GetReference())
	DeleteIfAble(Alias_Draugr8.GetReference())
	DeleteIfAble(Alias_Draugr9.GetReference())
EndFunction

Function DeleteIfAble(ObjectReference akRef)
	If akRef != None
		akRef.DeleteWhenAble()
	EndIf
EndFunction

_DS_DN_Draugnarok Property dsDnok Auto
