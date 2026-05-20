;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 9
Scriptname _DS_DN_QF_WE02 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Draugr1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY myHoldContested
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_myHoldContested Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY TRIGGER
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_TRIGGER Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY myHoldSons
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_myHoldSons Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Draugr2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY myHoldLocation
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_myHoldLocation Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Draugr3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Draugr3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY SoldierImperial3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SoldierImperial3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY TravelMarker2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_TravelMarker2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY SoldierImperial2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SoldierImperial2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY myHoldImperial
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_myHoldImperial Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY SoldierImperial1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SoldierImperial1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY TravelMarker1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_TravelMarker1 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
dsDnok.WEReport(GetName(), Alias_TRIGGER.GetRef())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN AUTOCAST TYPE WEScript
Quest __temp = self as Quest
WEScript kmyQuest = __temp as WEScript
;END AUTOCAST
;BEGIN CODE
(Alias_Trigger.GetReference() as WETriggerScript).ReArmTrigger()

alias_SoldierImperial1.GetReference().DeleteWhenAble()
alias_SoldierImperial2.GetReference().DeleteWhenAble()
alias_SoldierImperial3.GetReference().DeleteWhenAble()
alias_Draugr1.GetReference().DeleteWhenAble()
alias_Draugr2.GetReference().DeleteWhenAble()
alias_Draugr3.GetReference().DeleteWhenAble()

dsDnok.ReportRearming(GetName(), Alias_TRIGGER.GetRef())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

_DS_DN_Draugnarok Property dsDnok Auto
