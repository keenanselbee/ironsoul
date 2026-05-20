Scriptname _DS_DN_ExhaustHandler extends Quest  

ReferenceAlias Property Alias_DraugrSpawn01 Auto
ReferenceAlias Property Alias_DraugrSpawn02 Auto
ReferenceAlias Property Alias_DraugrSpawn03 Auto
ReferenceAlias Property Alias_DraugrSpawn04 Auto
ReferenceAlias Property Alias_DraugrSpawn05 Auto
ReferenceAlias Property Alias_DraugrSpawn06 Auto
ReferenceAlias Property Alias_DraugrSpawn07 Auto
ReferenceAlias Property Alias_DraugrSpawn08 Auto
ReferenceAlias Property Alias_DraugrSpawn09 Auto

bool Property StopQuestWhenAliasesUnload = False auto

float Property StopQuestPollingFrequencey = 1.0 Auto

bool registeredForUpdate

int CountOfLoadedAliases


_DS_DN_Draugnarok Property dsDnok Auto


Function ReportDeath()

	If IsDraugrDead(Alias_DraugrSpawn01) && IsDraugrDead(Alias_DraugrSpawn02) && IsDraugrDead(Alias_DraugrSpawn03) && \
	   IsDraugrDead(Alias_DraugrSpawn04) && IsDraugrDead(Alias_DraugrSpawn05) && IsDraugrDead(Alias_DraugrSpawn06) && \
	   IsDraugrDead(Alias_DraugrSpawn07) && IsDraugrDead(Alias_DraugrSpawn08) && IsDraugrDead(Alias_DraugrSpawn09)
		dsDnok.ReportExhausted(GetName())
		Stop()
	EndIf

EndFunction

int Function ForceCleanupRaid()

	int cleanedCount = CleanupRaidAliases()
	If dsDnok
		dsDnok.ReportExhausted(GetName())
	EndIf
	Stop()
	Return cleanedCount

EndFunction

int Function CleanupRaidAliases()

	int cleanedCount = 0
	cleanedCount += ForceCleanupAlias(Alias_DraugrSpawn01)
	cleanedCount += ForceCleanupAlias(Alias_DraugrSpawn02)
	cleanedCount += ForceCleanupAlias(Alias_DraugrSpawn03)
	cleanedCount += ForceCleanupAlias(Alias_DraugrSpawn04)
	cleanedCount += ForceCleanupAlias(Alias_DraugrSpawn05)
	cleanedCount += ForceCleanupAlias(Alias_DraugrSpawn06)
	cleanedCount += ForceCleanupAlias(Alias_DraugrSpawn07)
	cleanedCount += ForceCleanupAlias(Alias_DraugrSpawn08)
	cleanedCount += ForceCleanupAlias(Alias_DraugrSpawn09)
	Return cleanedCount

EndFunction

int Function ForceCleanupAlias(ReferenceAlias akDraugr)

	If !akDraugr
		Return 0
	EndIf

	ObjectReference draugrRef = akDraugr.GetReference()
	If draugrRef
		draugrRef.DisableNoWait()
		draugrRef.Delete()
		Return 1
	EndIf
	Return 0

EndFunction

bool Function IsDraugrDead(ReferenceAlias akDraugr)
	Return akDraugr == None || akDraugr.GetActorReference() == None || akDraugr.GetActorReference().IsDead()
EndFunction


Event OnUpdateGameTime()
	Return
	
	If countOfLoadedAliases < 1
		dsDnok.ReportExhausted(GetName())
		Stop()
	EndIf
EndEvent


Function AliasLoadingOrUnloading(bool isLoading)
	
	If isLoading
		countOfLoadedAliases += 1
	Else
		countOfLoadedAliases -= 1
	EndIf

	RegisterForStopQuest()

EndFunction

Function RegisterForStopQuest()
	If registeredForUpdate == False && StopQuestPollingFrequencey
		;RegisterForUpdateGameTime(StopQuestPollingFrequencey) 
		registeredForUpdate = True
	endif
EndFunction
