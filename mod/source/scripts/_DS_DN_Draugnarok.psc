Scriptname _DS_DN_Draugnarok extends Quest

_DS_DN_Globals Property dsGlobals Auto
IronSoulController Property IronSoul Auto

Actor Property PlayerRef Auto

GlobalVariable Property GlobalWE Auto
GlobalVariable Property GlobalWI Auto

FormList Property flAlwaysRainyLocs Auto
FormList Property flAlwaysSnowyLocs Auto

Quest[] Property DeathSquads_Small Auto
Quest[] Property DeathSquads_Services Auto
Quest[] Property DeathSquads_Medium Auto
Quest[] Property DeathSquads_Large Auto
Quest[] Property TownRaids Auto
Quest[] Property MinorCapitalRaids Auto
Quest[] Property CapitalRaids Auto
Quest[] Property GateCrashers Auto
Quest[] Property PillageSquads Auto
Quest[] Property RoamingMobs Auto
Quest[] Property AmbushSquads Auto
Quest[] Property WildernessEncounters Auto
Quest[] Property RoadEncounters Auto

Quest Property LocationHandler Auto
Quest Property MQ101 Auto
Quest Property MQ102 Auto
Quest Property MQ305 Auto

Keyword Property kwLocTypeInn Auto

Faction Property FactionDraugrTarget Auto
Spell Property SpellDraugrTarget Auto
MagicEffect Property MgefDraugrTarget Auto


bool Running						= False
bool DraugnarokInitialized		= False
bool PressureActivationJournaled	= False
bool ShutdownJournaled				= False
bool WaitingForAlduinLogged			= False
int LastLoggedThreatLevel			= -2
int TownRaidCountdown				= 0
int CapitalRaidCountdown			= 0
int MinorCapitalRaidCountdown		= 0
int RaidQueueIndex					= -1

Actor LastTarget_DSS
Actor LastTarget_DSV
Actor LastTarget_DSM
Actor LastTarget_DSL

Location LastTarget_Inn

Quest[] StaleRaidQuests
Float[] StaleRaidStartedAt
String[] RaidCooldownKeys
Float[] RaidCooldownStartedAt
Actor[] PillageFactionTargets
Float[] PillageFactionTargetMarkedAt
Int[] DelayedRaidWeatherTypes
String[] DelayedRaidWeatherNames
Location[] DelayedRaidWeatherLocations
ObjectReference[] DelayedRaidWeatherAnchors
ObjectReference[] DelayedRaidWeatherFallbackAnchors
Float[] DelayedRaidWeatherDueAt
Float DelayedRaidWeatherNextDueAt		= 0.0
string GateCapitalTargetPlace			= ""
int GateCapitalTargetPulsesRemaining	= 0
int GateCapitalTargetPressureCount		= 0
bool DraugnarokPulseRunning			= False
bool GateCapitalTargetSetDuringPulse	= False
bool ManualRaidDebugNotificationArmed	= False
int ManualRaidDebugNotificationRaidType	= 0
string ManualRaidDebugNotificationLabel	= ""
bool RaidChanceCalculationReady			= False
string CalculatedRaidChanceSummary		= ""
string CalculatedActiveCapitalTarget	= ""
int CalculatedRaidChanceWeight			= 0
int CalculatedAvailableWeight			= 0
int CalculatedAvailableSmallWeight		= 0
int CalculatedAvailableServiceWeight	= 0
int CalculatedAvailableTownWeight		= 0
int CalculatedAvailableMediumWeight		= 0
int CalculatedAvailablePillageWeight	= 0
int CalculatedAvailableMinorCapitalWeight = 0
int CalculatedAvailableGateWeight		= 0
int CalculatedAvailableCapitalWeight	= 0
bool LastPulseRaidChanceReady			= False
string LastPulseRaidChanceSummary		= ""

int OVERRIDE_NONE						= 0
int OVERRIDE_FORCE_ON					= 1
int OVERRIDE_FORCE_OFF					= 2

int STAGE_DORMANT					= 0
int STAGE_STIRRING					= 10
int STAGE_ROADS					= 20
int STAGE_BARROWS					= 30
int STAGE_HOLDS					= 40
int STAGE_CITIES					= 50
int STAGE_FULL_PRESSURE			= 60
int STAGE_UNLEVELED_PRESSURE	= 99
int STAGE_ALDUIN_DEFEATED			= 100
int STAGE_OUTBREAK					= 10
int STAGE_INVASION					= 20
int STAGE_DRAUGNAROK				= 30
int STAGE_AFTERMATH					= 40

int ACCURACY_NONE					= 0
int ACCURACY_BROAD					= 1
int ACCURACY_LETHAL					= 2
int ACCURACY_SUPERLETHAL			= 3

float LITE_DORMANT_UPDATE_HOURS		= 1.0
int DRAUGNAROK_BASE_INTERVAL_MIN		= 1
int DRAUGNAROK_BASE_INTERVAL_DEFAULT	= 8
int DRAUGNAROK_BASE_INTERVAL_MAX		= 24
int DRAUGNAROK_JOURNAL_MODE_DEFAULT	= 1
int DRAUGNAROK_NOTIFICATION_MODE_DEFAULT	= 1
int DRAUGNAROK_FORCE_CLEANUP_INTERVALS_DEFAULT	= 6
int DRAUGNAROK_COOLDOWN_INTERVALS_DEFAULT	= 3
int DRAUGNAROK_GATE_PRESSURE_INTERVALS_DEFAULT	= 6
int DRAUGNAROK_INTERVAL_SETTING_MAX		= 90
int STALE_RAID_TRACKER_CAPACITY		= 128
int RAID_COOLDOWN_TRACKER_CAPACITY	= 128
int PILLAGE_TARGET_TRACKER_CAPACITY	= 64
int CAPITAL_RAID_ALIAS_SCAN_LIMIT	= 256
int DELAYED_RAID_WEATHER_QUEUE_CAPACITY	= 16
int DELAYED_RAID_WEATHER_MIN_DELAY_SECONDS	= 60
int DELAYED_RAID_WEATHER_MAX_DELAY_SECONDS	= 180
int WEIGHT_TOTAL						= 100000

int RAID_SMALL						= 1
int RAID_TOWN						= 2
int RAID_MEDIUM						= 3
int RAID_MINOR_CAPITAL				= 4
int RAID_GATE						= 5
int RAID_CAPITAL					= 6
int RAID_SERVICE					= 7
int RAID_PILLAGE					= 8
int RAID_ROAMING_MOB				= 9

int RAID_NOTIFICATION_LOW			= 1
int RAID_NOTIFICATION_MEDIUM		= 2
int RAID_NOTIFICATION_HIGH			= 3

int RAID_WEATHER_MODE_DEFAULT		= 1
int RAID_WEATHER_OFF				= 0
int RAID_WEATHER_SMART_NEARBY		= 1
int RAID_WEATHER_MAJOR_NEARBY		= 2
int RAID_WEATHER_ALL_NEARBY			= 3
int RAID_WEATHER_LEGACY_MAJOR_GLOBAL	= 4

string LOG_SOURCE					= "Draugnarok"
int LOG_ERR_LEVEL					= 1
int LOG_INFO_LEVEL					= 2
int LOG_DBG_LEVEL					= 3


; Small squads - 3 Draugr
int Property SQUAD_FARM				= 101 AutoReadOnly
int Property SQUAD_LUMBERMILL		= 102 AutoReadOnly
int Property SQUAD_INN				= 103 AutoReadOnly
int Property SQUAD_STORE			= 104 AutoReadOnly
int Property SQUAD_HOUSE			= 105 AutoReadOnly
int Property SQUAD_JAIL				= 106 AutoReadOnly
int Property SQUAD_MINE				= 107 AutoReadOnly
int Property SQUAD_INNKEEPER		= 121 AutoReadOnly
int Property SQUAD_BLACKSMITH		= 122 AutoReadOnly
int Property SQUAD_CARAVAN			= 123 AutoReadOnly

; Medium squads - 9 Draugr
int Property SQUAD_TOWN				= 201 AutoReadOnly
int Property SQUAD_BANDITCAMP		= 202 AutoReadOnly
int Property SQUAD_FORSWORNCAMP		= 203 AutoReadOnly
int Property SQUAD_GIANTCAMP		= 204 AutoReadOnly
int Property SQUAD_BARRACKS			= 205 AutoReadOnly
int Property SQUAD_MILITARYCAMP		= 206 AutoReadOnly

; Large squads - 18+ Draugr
int Property SQUAD_CASTLE			= 301 AutoReadOnly
int Property SQUAD_CITY				= 302 AutoReadOnly
int Property SQUAD_MILITARYFORT		= 303 AutoReadOnly

; Ambushes for Location Change events
int Property AMBUSH_INN				= 0 AutoReadOnly


; D: D: D:  STAGE MIGRATION  D: D: D: D: D: D: D: D: D: D: D: D: D: D: D: D: D:
;

Function StartEpoch()

	DoTrace("StartEpoch redirected to Iron Soul pressure loop.")
	InitDraugnarokDefaults()
	StartTicking()
	
EndFunction

Function PrepareInvasion()

	float t = Utility.GetCurrentGameTime()
	DoTrace("PrepareInvasion: " + t)
	;DoNotify("Invasion: " + t)
	
	DeployAllMinorCapitalRaids()
	
	FigureWeather()
	
	SetRadiance()
	UpdateWorldEncounterChances()

	StartTicking()
	
EndFunction

Function EndTheWorld()

	float t = Utility.GetCurrentGameTime()
	DoTrace("EndTheWorld: " + t)
	;DoNotify("End of the World: " + t)

	DeployAllCapitalRaids()
	
	FigureWeather()
	
	SetRadiance()
	UpdateWorldEncounterChances()

	StartTicking()
	
EndFunction

Function DoTheAftermath()

	float t = Utility.GetCurrentGameTime()
	DoTrace("DoTheAftermath: " + t)
	;DoNotify("Aftermath: " + t)
	
	; Weather stays gloomy... forever...
	; Radiance stays disabled... forever...

	FigureWeather()
	
	SetRadiance()
	UpdateWorldEncounterChances()

	StartTicking()
	
EndFunction

Function Shutdown()

	ShutdownDraugnarok()

EndFunction

Function ShutdownDraugnarok(bool abRestoreWorld = True, bool abAlduinDefeated = False, bool abStopManagedRaids = True)

	If abAlduinDefeated
		JournalShutdown()
		LogInfo("Alduin defeated; shutting down permanently.")
	Else
		LogInfo("Shutting down.")
	EndIf
	UnregisterForUpdate()
	UnregisterForUpdateGameTime()
	ClearDelayedRaidWeatherQueue()
	ClearWorldEncounterChances()
	CleanupPillageFactionTargets(True)
	If abStopManagedRaids
		StopManagedRaidQuests()
	EndIf
	Weather.ReleaseOverride()
	If abRestoreWorld
		GlobalWE.SetValueInt(1)
		GlobalWI.SetValueInt(1)
	EndIf
	dsGlobals.gWeather = 0
	dsGlobals.gRadiance = False
	dsGlobals.gDraugnarokDisabled = True

	If abAlduinDefeated
		SetStage(STAGE_ALDUIN_DEFEATED)
		DisplayDraugnarokObjective(STAGE_ALDUIN_DEFEATED)
	Else
		SetStage(STAGE_DORMANT)
		HideDraugnarokObjectives()
	EndIf
	
	Running = False
	DraugnarokInitialized = False
	
	Stop()

EndFunction

Function AddRaidShutdownCounts(int[] aiCounts, int aiStoppedCount = 0, int aiCleanedCount = 0)

	If !aiCounts || aiCounts.Length < 2
		Return
	EndIf

	aiCounts[0] = aiCounts[0] + aiStoppedCount
	aiCounts[1] = aiCounts[1] + aiCleanedCount

EndFunction

Function LogRaidCleanupResult(Quest q, int aiRaidType, string asReason, int aiCleanedCount, string asAction)

	string questName = "<missing>"
	If q
		questName = q.GetName()
	EndIf

	LogDebug("Raid cleanup: quest='" + questName + "' type='" + GetRaidTypeWeatherName(aiRaidType) + "' reason='" + asReason + "' cleanedActorAliases=" + aiCleanedCount + " action='" + asAction + "'.")

EndFunction

int Function StopQuestArray(Quest[] akArray, int[] aiShutdownCounts)

	If !akArray || akArray.Length < 1
		Return 0
	EndIf

	int stoppedCount = 0
	int i = akArray.Length
	While i
		i -= 1
		Quest q = akArray[i]
		If q && q.IsRunning()
			LogDebug("Stopping managed Draugnarok quest '" + q.GetName() + "'.")
			q.Stop()
			stoppedCount += 1
		EndIf
	EndWhile

	AddRaidShutdownCounts(aiShutdownCounts, stoppedCount, 0)
	Return stoppedCount

EndFunction

int Function StopMappedRaidArray(Quest[] akArray, int aiRaidType, int[] aiShutdownCounts)

	If !akArray || akArray.Length < 1
		Return 0
	EndIf

	int stoppedCount = 0
	int cleanedTotal = 0
	int i = akArray.Length
	While i
		i -= 1
		Quest q = akArray[i]
		If q && q.IsRunning()
			LogDebug("Cleaning and stopping mapped Draugnarok quest '" + q.GetName() + "'.")
			int cleanedCount = CleanupRunningRaidActors(q, aiRaidType)
			string stopAction = "stop requested"
			If cleanedCount < 0
				cleanedCount = 0
				stopAction = "stop requested after cleanup failure"
			EndIf
			LogRaidCleanupResult(q, aiRaidType, "managed shutdown", cleanedCount, stopAction)
			cleanedTotal += cleanedCount
			q.Stop()
			stoppedCount += 1
		EndIf
	EndWhile

	AddRaidShutdownCounts(aiShutdownCounts, stoppedCount, cleanedTotal)
	Return stoppedCount

EndFunction

Function StopManagedRaidQuests()

	int[] shutdownCounts = new Int[2]

	StopMappedRaidArray(DeathSquads_Small, RAID_SMALL, shutdownCounts)
	StopMappedRaidArray(DeathSquads_Services, RAID_SERVICE, shutdownCounts)
	StopMappedRaidArray(DeathSquads_Medium, RAID_MEDIUM, shutdownCounts)
	StopQuestArray(DeathSquads_Large, shutdownCounts)
	StopMappedRaidArray(TownRaids, RAID_TOWN, shutdownCounts)
	StopMappedRaidArray(MinorCapitalRaids, RAID_MINOR_CAPITAL, shutdownCounts)
	StopMappedRaidArray(CapitalRaids, RAID_CAPITAL, shutdownCounts)
	StopMappedRaidArray(GateCrashers, RAID_GATE, shutdownCounts)
	StopMappedRaidArray(PillageSquads, RAID_PILLAGE, shutdownCounts)
	StopQuestArray(RoamingMobs, shutdownCounts)
	StopQuestArray(AmbushSquads, shutdownCounts)
	StopQuestArray(WildernessEncounters, shutdownCounts)
	StopQuestArray(RoadEncounters, shutdownCounts)

	If LocationHandler && LocationHandler.IsRunning()
		LogDebug("Stopping Draugnarok location handler.")
		LocationHandler.Stop()
		AddRaidShutdownCounts(shutdownCounts, 1, 0)
	EndIf

	If shutdownCounts[0] > 0 || shutdownCounts[1] > 0
		LogInfo("Managed Draugnarok shutdown stopped " + shutdownCounts[0] + " quests and cleaned " + shutdownCounts[1] + " actor aliases.", True)
	Else
		LogDebug("Managed Draugnarok shutdown found no running managed quests.")
	EndIf

	ClearGateCapitalTarget()
	DraugnarokPulseRunning = False

EndFunction

int Function ClampDraugnarokOverrideMode(int aiMode)

	If aiMode < OVERRIDE_NONE || aiMode > OVERRIDE_FORCE_OFF
		Return OVERRIDE_NONE
	EndIf
	Return aiMode

EndFunction

int Function GetDraugnarokOverrideMode()

	If !IronSoul || !IronSoul.Persistence
		Return OVERRIDE_NONE
	EndIf
	Return ClampDraugnarokOverrideMode(IronSoul.Persistence.GetDraugnarokOverrideMode(PlayerRef))

EndFunction

string Function GetDraugnarokOverrideSummary(int aiMode)

	If aiMode == OVERRIDE_FORCE_ON
		Return "\nOverride: force on"
	ElseIf aiMode == OVERRIDE_FORCE_OFF
		Return "\nOverride: force off"
	EndIf
	Return ""

EndFunction

bool Function SetDraugnarokOverrideMode(int aiMode, bool abApplyNow = True)

	aiMode = ClampDraugnarokOverrideMode(aiMode)
	If !IronSoul || !IronSoul.Persistence
		LogError("Cannot set Draugnarok override: Iron Soul controller unavailable.")
		Return False
	EndIf
	If aiMode == OVERRIDE_FORCE_ON && !IsDraugnarokSystemEnabled()
		LogInfo("Cannot force Draugnarok on while DraugnarokSystem=0.", True)
		Return False
	EndIf
	If !IronSoul.Persistence.SetDraugnarokOverrideMode(PlayerRef, aiMode, True)
		LogError("Cannot set Draugnarok override: current character GUID unavailable.")
		Return False
	EndIf

	If abApplyNow
		ApplyDraugnarokOverrideMode(aiMode)
	EndIf
	Return True

EndFunction

Function ApplyDraugnarokOverrideMode(int aiMode)

	aiMode = ClampDraugnarokOverrideMode(aiMode)
	If aiMode == OVERRIDE_FORCE_OFF
		LogInfo("Draugnarok force-off override active.", True)
		ShutdownDraugnarok(True, False, True)
		Return
	ElseIf !IsDraugnarokSystemEnabled()
		LogInfo("DraugnarokSystem=0; Draugnarok remains disabled.", True)
		ShutdownDraugnarok(True, False, True)
		Return
	ElseIf aiMode == OVERRIDE_FORCE_ON
		ForceStartDraugnarok()
		Return
	EndIf

	ApplyNormalDraugnarokMode()

EndFunction

Function ForceStartDraugnarok()

	If !IsDraugnarokSystemEnabled()
		LogInfo("Cannot force-start Draugnarok while DraugnarokSystem=0.", True)
		ShutdownDraugnarok(True, False, True)
		Return
	EndIf

	dsGlobals.gDraugnarokDisabled = False
	If !IsRunning()
		If !Start()
			LogError("Failed to start Draugnarok quest for force-on override.")
		EndIf
	EndIf
	If !DraugnarokInitialized
		InitDraugnarokDefaults()
	EndIf
	Running = True
	WaitingForAlduinLogged = False
	UpdateDraugnarokQuestStage()
	RegisterForSingleUpdateGameTime(GetNextUpdateTime())
	StartTicking()
	LogInfo("Draugnarok force-on override active.", True)

EndFunction

Function ApplyNormalDraugnarokMode()

	If !IsDraugnarokSystemEnabled()
		ShutdownDraugnarok(True, False, True)
		Return
	EndIf

	If IsAlduinDefeated()
		ShutdownDraugnarok(True, True)
		Return
	EndIf

	dsGlobals.gDraugnarokDisabled = False
	If !IsRunning()
		If !Start()
			LogError("Failed to start Draugnarok quest after clearing override.")
		EndIf
	EndIf
	If !DraugnarokInitialized
		InitDraugnarokDefaults()
	EndIf
	Running = True
	If IsAlduinLooseForDraugnarok()
		RegisterForSingleUpdateGameTime(GetNextUpdateTime())
	Else
		RegisterForSingleUpdateGameTime(LITE_DORMANT_UPDATE_HOURS)
	EndIf
	StartTicking()
	LogInfo("Draugnarok override cleared; normal rules restored.", True)

EndFunction

; D: D: D:  HEARTBEAT TASKS  D: D: D: D: D: D: D: D: D: D: D: D: D: D: D: D: D:
;

Function StartTicking()

	If !Running
		RegisterForSingleUpdate(10.0)
	EndIf

EndFunction

Event OnInit()

	StartTicking()

EndEvent

Event OnUpdate()

	int overrideMode = GetDraugnarokOverrideMode()
	If overrideMode == OVERRIDE_FORCE_OFF
		ShutdownDraugnarok(True, False, True)
		Return
	EndIf
	If !IsDraugnarokSystemEnabled()
		ShutdownDraugnarok(True, False, True)
		Return
	EndIf

	; First OnUpdate call happens right when Draugnarok starts up...
	If !Running
		Running = True
		InitDraugnarokDefaults()
		If overrideMode != OVERRIDE_FORCE_ON && IsAlduinDefeated()
			ShutdownDraugnarok(True, True)
			Return
		EndIf
		If overrideMode == OVERRIDE_FORCE_ON || IsAlduinLooseForDraugnarok()
			RegisterForSingleUpdateGameTime(GetNextUpdateTime())
		Else
			RegisterForSingleUpdateGameTime(LITE_DORMANT_UPDATE_HOURS)
		EndIf
	
	; Regular OnUpdate happens every ~ 10 seconds to handle multi-deployments.
;	ElseIf DeployMultiRaid()
;		RegisterForSingleUpdate(10.0)
	
	EndIf

	ProcessDelayedRaidWeatherQueue()

EndEvent

Event OnUpdateGameTime()

	int overrideMode = GetDraugnarokOverrideMode()
	If overrideMode == OVERRIDE_FORCE_OFF
		ShutdownDraugnarok(True, False, True)
		Return
	EndIf
	If !IsDraugnarokSystemEnabled()
		ShutdownDraugnarok(True, False, True)
		Return
	EndIf

	If dsGlobals.gDraugnarokDisabled == True
		If overrideMode == OVERRIDE_FORCE_ON
			dsGlobals.gDraugnarokDisabled = False
		Else
			ShutdownDraugnarok()
			Return
		EndIf
	EndIf

	If !DraugnarokInitialized
		InitDraugnarokDefaults()
	EndIf

	If overrideMode != OVERRIDE_FORCE_ON && IsAlduinDefeated()
		UpdateDraugnarokQuestStage()
		ShutdownDraugnarok(True, True)
		Return
	EndIf

	If overrideMode != OVERRIDE_FORCE_ON && !IsAlduinLooseForDraugnarok()
		LogWaitingForAlduin()
		RegisterForSingleUpdateGameTime(LITE_DORMANT_UPDATE_HOURS)
		Return
	EndIf

	LogPressureActivated()
	UpdateDraugnarokQuestStage()
	LogDebug("Tick " + dsGlobals.gTickCount + "...")
	RunDraugnarokPulse()
	dsGlobals.gTickCount = dsGlobals.gTickCount + 1
	RegisterForSingleUpdateGameTime(GetNextUpdateTime())

EndEvent

float Function GetNextUpdateTime()

	Return GetDraugnarokBaseIntervalHours() as float

EndFunction

int Function GetDraugnarokBaseIntervalHours()

	If !IronSoulNative.IsAvailable()
		Return DRAUGNAROK_BASE_INTERVAL_DEFAULT
	EndIf

	int interval = IronSoulNative.GetConfigInt("DraugnarokBaseIntervalHours", DRAUGNAROK_BASE_INTERVAL_DEFAULT)
	If interval < DRAUGNAROK_BASE_INTERVAL_MIN
		Return DRAUGNAROK_BASE_INTERVAL_MIN
	ElseIf interval > DRAUGNAROK_BASE_INTERVAL_MAX
		Return DRAUGNAROK_BASE_INTERVAL_MAX
	EndIf
	Return interval

EndFunction

Function CheckProgress()

	If dsGlobals.gWeather > 0
		FigureWeather()
	EndIf
	
	LastTarget_Inn = None
	
	int Stage = FigureStage()
	
	If dsGlobals.gDemoMode == 1
		DoTrace("DemoMode: DEPLOY ALL THE THINGS!")
		DoNotify("DRAUGNAROK DEMO MODE ON -- DEPLOYING EVERYTHING")
		DeployEverything()
		DeployManyPillagers(20)
		Return
	EndIf
	
	If dsGlobals.gMayhem == True
		DoTrace("Mayhem: DEPLOY ALL THE THINGS!")
		DoNotify("MAYHEM!")
		DeployEverything()
		DeployManyPillagers(10)
		dsGlobals.gMayhem = False
		Return
	EndIf
	
	If Stage >= STAGE_AFTERMATH
		If Utility.RandomInt() > 90
			DeployAnySquad()
		Else
			DeploySmallSquad()
		EndIf
		Return
	EndIf
	
	; Note these are cummulative -->

	If Stage >= STAGE_OUTBREAK
		KillTarget(LastTarget_DSS)
		If DeploySmallSquad()
		ElseIf DeploySmallSquad()
		Else
			DeploySmallSquad(True)
		EndIf
		KillService()
		If TownRaidCountdown == -1
			TownRaidCountdown = 0
		ElseIf Utility.RandomInt() > 25
			DeployTownRaid()
		Else
			TownRaidCountdown += 1
		EndIf
	EndIf
	
	If Stage >= STAGE_INVASION
		KillTarget(LastTarget_DSM)
		If DeployMediumSquad()
		ElseIf DeployMediumSquad()
		Else
			DeployMediumSquad(True)
		EndIf
		DeployGateCrashers()
		If MinorCapitalRaidCountdown == -1
			MinorCapitalRaidCountdown = 0
		ElseIf Utility.RandomInt() > 50
			DeployMinorCapitalRaid()
		Else
			MinorCapitalRaidCountdown += 1
		EndIf
	EndIf
	
	If Stage >= STAGE_DRAUGNAROK
		DeployPillagers()
		If CapitalRaidCountdown == -1
			CapitalRaidCountdown = 0
		ElseIf Utility.RandomInt() > 75
			DeployCapitalRaid()
		Else
			CapitalRaidCountdown += 1
		EndIf
	EndIf

EndFunction

Function FigureWeather(Location akLoc = None, bool abForce = False, bool abForceOverride = True)

	int pattern = dsGlobals.gWeather
	int P_OFF = 0 ; Draugnarok does not control weather
	int P_DN  = 1 ; Use Draugnarok's hard-coded patterns
	int P_MOD = 2 ; Pass-through so a mod like CoT can suggest rain / snow (but this doesn't work very well right now)

	If pattern == P_OFF
		Weather.ReleaseOverride()
		Return
	EndIf
	
	; To keep weather from being too erratic there's only a 20% chance of change.
	; However, on a loc change where the old weather type no longer fits, do change.
	If !abForce && ( akLoc == None || dsGlobals.gWeatherIsWeird || Weather.FindWeather( dsGlobals.gCurrentWeather ) != None ) && Utility.RandomInt() > 20
		Return
	EndIf

	Weather[] weather_cloud		= new Weather[4]
	weather_cloud[0]			= Game.GetForm(0x000C821E) as Weather ; SkyrimFog
	weather_cloud[1]			= Game.GetForm(0x00012F89) as Weather ; SkyrimCloudy
	weather_cloud[2]			= Game.GetForm(0x000D299E) as Weather ; SkyrimOvercastWar
	weather_cloud[3]			= Game.GetForm(0x000D299E) as Weather ; SkyrimOvercastWar
	Weather[] weather_rainy		= new Weather[4]
	weather_rainy[0]			= Game.GetForm(0x000C8220) as Weather ; SkyrimStormRain
	weather_rainy[1]			= Game.GetForm(0x000C8220) as Weather ; SkyrimStormRain
	weather_rainy[2]			= Game.GetForm(0x000C821F) as Weather ; SkyrimOvercastRain
	weather_rainy[3]			= Game.GetForm(0x000D4886) as Weather ; FXMagicStormRain
	Weather[] weather_snowy		= new Weather[2]
	weather_snowy[0]			= Game.GetForm(0x0004D7FB) as Weather ; SkyrimOvercastSnow
	weather_snowy[1]			= Game.GetForm(0x000C8221) as Weather ; SkyrimStormSnow

	int W_CLEAR = 0
	int W_CLOUD = 1
	int W_RAINY = 2
	int W_SNOWY = 3
	
	int old_weather = dsGlobals.gCurrentWeather
	int new_weather = W_RAINY
	
	If Utility.RandomInt() > dsGlobals.gRain
		If pattern == P_MOD
			Weather.ReleaseOverride()
			Return
		Else
			new_weather = W_CLOUD
		EndIf
	
	ElseIf dsGlobals.gWeatherIsWeird
		If Utility.RandomInt() > 50
			new_weather = W_SNOWY
		EndIf
	
	ElseIf akLoc != None && flAlwaysRainyLocs.Find(akLoc) > -1
		new_weather = W_RAINY
	ElseIf akLoc != None && flAlwaysSnowyLocs.Find(akLoc) > -1
		new_weather = W_SNOWY
	ElseIf Weather.FindWeather(W_RAINY) == None
		new_weather = W_SNOWY
	
	EndIf
	
	int i
	Weather w
	
	If pattern == P_DN
		If new_weather == W_CLOUD
			i = Utility.RandomInt(0, weather_cloud.Length - 1)
			w = weather_cloud[i]
		ElseIf new_weather == W_SNOWY
			i = Utility.RandomInt(0, weather_snowy.Length - 1)
			w = weather_snowy[i]
		Else
			i = Utility.RandomInt(0, weather_rainy.Length - 1)
			w = weather_rainy[i]
		EndIf
	
	ElseIf pattern == P_MOD
		w = Weather.FindWeather(new_weather)
	
	EndIf
	
	If !w
		LogError("FigureWeather could not resolve weather type " + new_weather + " for pattern " + pattern + ".")
		Return
	EndIf

	dsGlobals.gCurrentWeather = new_weather
	
	If abForce && abForceOverride
		w.ForceActive(True)
	Else
		w.SetActive(True)
	EndIf

EndFunction

int Function FigureStage()

	int VarStage = dsGlobals.gDraugnarokStage
	int RealStage = GetStage()

	int Ticks = dsGlobals.gTickCount
	int TICKS_TIL_INVASION   = dsGlobals.gTicksTilStage20
	int TICKS_TIL_DRAUGNAROK = dsGlobals.gTicksTilStage30
	int TICKS_TIL_AFTERMATH  = dsGlobals.gTicksTilStage40
	
	; Startup
	If VarStage == 0
		ChangeStage(STAGE_OUTBREAK, 1)
		StartEpoch()
	
	; Progression
	ElseIf dsGlobals.gEternal == False && Ticks >= TICKS_TIL_AFTERMATH && RealStage < STAGE_AFTERMATH
		ChangeStage(STAGE_AFTERMATH, 4)
		DoTheAftermath()
	ElseIf Ticks >= TICKS_TIL_DRAUGNAROK && RealStage < STAGE_DRAUGNAROK
		ChangeStage(STAGE_DRAUGNAROK, 3)
		EndTheWorld()
	ElseIf Ticks >= TICKS_TIL_INVASION && RealStage < STAGE_INVASION
		ChangeStage(STAGE_INVASION, 2)
		PrepareInvasion()
		
	EndIf
	
	Return GetStage()

EndFunction

Function ChangeStage(int aiQStage, int aiGStage)
	SetStage(aiQStage)
	dsGlobals.gDraugnarokStage = aiGStage
	DisplayStage(aiQStage)
EndFunction

Function DisplayStage(int aiStage)

	DisplayDraugnarokObjective(aiStage)

EndFunction

Function HideDraugnarokObjectives()

	SetObjectiveDisplayed(STAGE_DORMANT, False)
	SetObjectiveDisplayed(STAGE_OUTBREAK, False)
	SetObjectiveDisplayed(STAGE_INVASION, False)
	SetObjectiveDisplayed(STAGE_DRAUGNAROK, False)
	SetObjectiveDisplayed(STAGE_AFTERMATH, False)
	SetObjectiveDisplayed(STAGE_CITIES, False)
	SetObjectiveDisplayed(STAGE_FULL_PRESSURE, False)
	SetObjectiveDisplayed(STAGE_UNLEVELED_PRESSURE, False)
	SetObjectiveDisplayed(STAGE_ALDUIN_DEFEATED, False)
	SetActive(False)

EndFunction

bool Function ShouldDisplayDraugnarokObjective(int aiStage)

	If aiStage < 0
		Return False
	EndIf
	If !IsDraugnarokVisibleQuestEnabled()
		Return False
	EndIf
	If GetDraugnarokOverrideMode() == OVERRIDE_FORCE_OFF
		Return False
	EndIf
	If !IsDraugnarokSystemEnabled()
		Return False
	EndIf
	If GetDraugrThreatLevel() < 0
		Return False
	EndIf
	Return True

EndFunction

Function DisplayDraugnarokObjective(int aiStage)

	HideDraugnarokObjectives()

	If aiStage == -1
		aiStage = GetStage()
	EndIf
	
	If ShouldDisplayDraugnarokObjective(aiStage)
		SetObjectiveDisplayed(aiStage, True, True)
		SetActive(True)
	EndIf

EndFunction

Function RefactorDuration()

	int Duration = dsGlobals.gDuration
	
	If Duration < 0 || Duration > 2
		Duration = 1
		dsGlobals.gDuration = 1
	EndIf
	
	; Ticks designed for multiples of 16 based on needs mods - sleeping every 16 hours.
	; Time doesn't pass (no ticks) during sleep and wait - OnUpdateGameTime() does not fire.
	
	float t20
	float t30
	float t40

	If Duration == 0		; Fleeting
		t20 = 16			; 1 day from Outbreak to Invasion
		t30 = 48			; 2 days from Invasion to Draugnarok [3 total]
		t40 = 80			; 2 days from Draugnarok to Aftermath [5 total]
	
	ElseIf Duration == 1	; Sustained
		t20 = 48			; 3 days from Outbreak to Invasion
		t30 = 112			; 4 days from Invasion to Draugnarok [7 total]
		t40 = 176			; 4 days from Draugnarok to Aftermath [11 total]
	
	ElseIf Duration == 2	; Protracted
		t20 = 112			; 7 days from Outbreak to Invasion
		t30 = 224			; 7 days from Invasion to Draugnarok [14 total]
		t40 = 336			; 7 days from Draugnarok to Aftermath [21 total]
	
	EndIf

	int r = dsGlobals.gSpreadRate
	float m = 1
	If r == 0
		m = 0.25
	ElseIf r == 2
		m = 2
	EndIf
	
	int rt20 = Math.Floor(t20 * m)
	int rt30 = Math.Floor(t30 * m)
	int rt40 = Math.Floor(t40 * m)
	
	dsGlobals.gTicksTilStage20 = rt20
	dsGlobals.gTicksTilStage30 = rt30
	dsGlobals.gTicksTilStage40 = rt40
	
	; Contraction, expansion
	int Ticks = dsGlobals.gTickCount
	int Stage = GetStage()
	If Ticks > rt20 && Stage < STAGE_INVASION
		dsGlobals.gTickCount = rt20
	ElseIf Ticks > rt30 && Stage < STAGE_DRAUGNAROK
		dsGlobals.gTickCount = rt30
	ElseIf Ticks > rt40 && Stage < STAGE_AFTERMATH
		dsGlobals.gTickCount = rt40
	ElseIf Ticks < rt40 && Stage >= STAGE_AFTERMATH
		dsGlobals.gTickCount = rt40
	ElseIf Ticks < rt30 && Stage >= STAGE_DRAUGNAROK
		dsGlobals.gTickCount = rt30
	ElseIf Ticks < rt20 && Stage >= STAGE_INVASION
		dsGlobals.gTickCount = rt20
	EndIf
	
EndFunction


; D: D: D:  QUESTFRAG HOOKS  D: D: D: D: D: D: D: D: D: D: D: D: D: D: D: D: D:
;

Function SquadReport(int aiSquad, string asName, Location akDestination, Actor akTarget = None, ObjectReference akFallbackAnchor = None)

	string s = "DeathSquad report: Group '" + asName + "'"
	If akDestination
		s +=  " to location '" + akDestination.GetName() + "'"
	EndIf
	If akTarget
		s += " targeting '" + akTarget.GetBaseObject().GetName() + "'"
	EndIf
	LogDebug(s)
	
	If aiSquad > 300
		LastTarget_DSL = akTarget
	ElseIf aiSquad > 200
		LastTarget_DSM = akTarget
	ElseIf aiSquad > 120
		LastTarget_DSV = akTarget
	ElseIf aiSquad > 100
		LastTarget_DSS = akTarget
	EndIf

	int raidType = GetSquadRaidType(aiSquad)
	If raidType > 0
		JournalRaidEvent(raidType, GetSquadJournalEntry(raidType, asName, akDestination, akTarget))
		NotifyRaidEvent(raidType, GetSquadNotificationEntry(raidType, asName, akDestination, akTarget), akFallbackAnchor)
		HandleRaidWeather(raidType, asName, akDestination, akTarget, akFallbackAnchor)
		If raidType == RAID_MEDIUM
			RecordRaidCooldown(raidType, asName)
		EndIf
	EndIf

EndFunction

Function UpdateDraugnarokQuestStage()

	int stage = GetDraugnarokQuestStage()
	If GetStage() != stage
		SetStage(stage)
		DisplayDraugnarokObjective(stage)
	ElseIf ShouldDisplayDraugnarokObjective(stage)
		If !IsObjectiveDisplayed(stage)
			DisplayDraugnarokObjective(stage)
		EndIf
	Else
		HideDraugnarokObjectives()
	EndIf

EndFunction

Function RaidReport(string asName, ObjectReference akAnchor = None, ObjectReference akFallbackAnchor = None)

	DoTrace("Raid report: '" + asName + "'")
	;DoNotify("Raid: '" + asName + "'")
	
	string placeName = GetRaidPlaceName(asName)
	If placeName == ""
		placeName = asName
	EndIf
	
	int raidType = RAID_CAPITAL
	If IsMinorCapitalPlace(placeName) || StringContains(asName, "MinorCapital") || StringContains(asName, "minor capital")
		raidType = RAID_MINOR_CAPITAL
	EndIf
	If raidType == RAID_MINOR_CAPITAL
		JournalRaidEvent(raidType, "Draugr assaulted " + placeName + ".")
		NotifyRaidEvent(raidType, "Draugr assault " + placeName, akFallbackAnchor)
	Else
		JournalRaidEvent(raidType, "Draugr besieged " + placeName + ".")
		NotifyRaidEvent(raidType, "Draugr besiege " + placeName, akFallbackAnchor)
	EndIf
	RecordRaidCooldown(raidType, placeName)
	HandleRaidWeather(raidType, asName, None, akAnchor, akFallbackAnchor)

EndFunction

Function PillageReport(string asName, Actor akVictim)

	If !akVictim
		LogError("Pillage report '" + asName + "' received a missing victim.")
		Return
	EndIf
	DoTrace("Pillage report: '" + asName + "' targeting '" + akVictim.GetBaseObject().GetName() + "'")
	;DoNotify("Pillaging: " + akVictim.GetBaseObject().GetName())
	
	string victimName = akVictim.GetBaseObject().GetName()
	If victimName == ""
		victimName = GetRaidPlaceName(asName)
	EndIf
	If victimName == ""
		victimName = asName
	EndIf
	JournalRaidEvent(RAID_PILLAGE, "Draugr pillagers hunted " + victimName + ".")
	NotifyRaidEvent(RAID_PILLAGE, "Draugr pillagers hunt " + victimName, akVictim, "VictimRef")
	HandleRaidWeather(RAID_PILLAGE, asName, akVictim.GetCurrentLocation(), akVictim)
	
	If akVictim.IsNearPlayer()
		ClearPillageFactionTarget(akVictim, "nearby pillage target uses spell")
		SpellDraugrTarget.Cast(akVictim)
	Else
		akVictim.AddToFaction(FactionDraugrTarget)
		TrackPillageFactionTarget(akVictim)
	EndIf

EndFunction

Function KillReport(ObjectReference akVictim, Location akLocation)

	; defunct

EndFunction

Function WEReport(string asName, ObjectReference akTrigger)
	DoTrace("WE report: '" + asName + "' triggered at WETrigger " + akTrigger)
	;DoNotify("WE: '" + asName + "' at " + akTrigger)
EndFunction

Function ReportRearming(string asName, ObjectReference akTrigger)
	DoTrace("WE rearming: '" + asName + "' with WETrigger " + akTrigger)
EndFunction

Function LocChange(Location akOldLocation, Location akNewLocation)

	;DoTrace("LocChange from '" + akOldLocation.GetName() + "' to '" + akNewLocation.GetName() + "'")
	
	bool interior = PlayerRef.IsInInterior()
	
	dsGlobals.gPlayerInInterior = interior
	
	LocationHandler.Stop()

EndFunction

Function GateReport(string asName, ObjectReference akAnchor = None, ObjectReference akFallbackAnchor = None)
	DoTrace("GateCrasher report: '" + asName + "'")
	;DoNotify("GateCrashers: '" + asName + "'")
	string placeName = GetRaidPlaceName(asName)
	If placeName == ""
		placeName = asName
	EndIf
	JournalRaidEvent(RAID_GATE, "Draugr battered " + placeName + "'s gate.")
	NotifyRaidEvent(RAID_GATE, "Draugr batter " + placeName + "'s gate", akFallbackAnchor)
	RecordRaidCooldown(RAID_GATE, placeName)
	SetGateCapitalTarget(placeName)
	HandleRaidWeather(RAID_GATE, asName, None, akAnchor, akFallbackAnchor)
EndFunction

Function TownReport(string asName, ObjectReference akAnchor = None, ObjectReference akFallbackAnchor = None)
	DoTrace("TownRaid report: '" + asName + "'")
	;DoNotify("TownRaid: '" + asName + "'")
	string placeName = GetRaidPlaceName(asName)
	If placeName == ""
		placeName = asName
	EndIf
	JournalRaidEvent(RAID_TOWN, "Draugr raided " + placeName + ".")
	NotifyRaidEvent(RAID_TOWN, "Draugr raid " + placeName, akFallbackAnchor)
	RecordRaidCooldown(RAID_TOWN, placeName)
	HandleRaidWeather(RAID_TOWN, asName, None, akAnchor, akFallbackAnchor)
EndFunction

Function ReportExhausted(string asName)
	DoTrace("Squad exhausted: '" + asName + "'")
	;DoNotify("Exhausted: '" + asName + "'")
EndFunction

Function MobReport(string asName, ObjectReference akAnchor = None, ObjectReference akFallbackAnchor = None)
	DoTrace("Mob report: '" + asName + "'")
	JournalRaidEvent(RAID_ROAMING_MOB, "A roaming draugr mob gathered.")
	NotifyRaidEvent(RAID_ROAMING_MOB, "A roaming draugr mob gathers", akAnchor)
	RecordRaidCooldown(RAID_ROAMING_MOB, asName)
	HandleRaidWeather(RAID_ROAMING_MOB, asName, None, akAnchor, akFallbackAnchor)
EndFunction

Function ReportDispersing(string asName)
	DoTrace("Mob dispersing: '" + asName + "'")
	;DoNotify("Mob dispersing: '" + asName + "'")
EndFunction

Function AmbushReport(string asName, Location akAmbushLocation)
	DoTrace("Ambush report: '" + asName + "' at location '" + akAmbushLocation.GetName() + "'")
	;DoNotify("Ambush at: " + akAmbushLocation.GetName())
EndFunction


; D: D: D:  DEPLOY FUNCTIONS  D: D: D: D: D: D: D: D: D: D: D: D: D: D: D: D: D:
;

Function DeployEverything()

	DeploySquadArray(DeathSquads_Small, True, RAID_SMALL)
	DeploySquadArray(DeathSquads_Medium, True, RAID_MEDIUM)
	;DeploySquadArray(DeathSquads_Large)
	DeploySquadArray(DeathSquads_Services, True, RAID_SERVICE)
	DeploySquadArray(PillageSquads, True, RAID_PILLAGE)
	DeployAllTownRaids()
	DeployAllMinorCapitalRaids()
	DeployGateCrashers()
	DeployAllCapitalRaids()
	
EndFunction

Function DeploySquadArray(Quest[] akArray, bool abReset = True, int aiRaidType = 0)
	int i = akArray.Length
	While (i)
		i -= 1
		DeploySquad(akArray[i], abReset, aiRaidType)
	EndWhile
EndFunction

bool Function DeployAnySquad(bool abReset = False)

	int roll = Utility.RandomInt()
	If roll < 50
		Return DeploySmallSquad(abReset)
	Else
		Return DeployMediumSquad(abReset)
	EndIf
	
EndFunction

bool Function DeploySmallSquad(bool abReset = False)
	Return DeployRandomFromArray(DeathSquads_Small, "small death squad", abReset, RAID_SMALL)
EndFunction

bool Function DeployMediumSquad(bool abReset = False)
	Return DeployRandomFromArray(DeathSquads_Medium, "medium death squad", abReset, RAID_MEDIUM)
EndFunction

bool Function DeployLargeSquad(bool abReset = False)
	Return DeployRandomFromArray(DeathSquads_Large, "large death squad", abReset)
EndFunction

Function DeployAllTownRaids()
	int i = TownRaids.Length
	While (i)
		i -= 1
		If TownRaids[i] != None
			DeploySquad(TownRaids[i], False, RAID_TOWN)
		EndIf
	EndWhile
	TownRaidCountdown = -1
EndFunction

Function DeployTownRaid()
	If TownRaidCountdown < 0 || TownRaidCountdown >= TownRaids.Length
		TownRaidCountdown = 0
	EndIf
	If TownRaids[TownRaidCountdown] != None
		DeploySquad(TownRaids[TownRaidCountdown], False, RAID_TOWN) ; No forced reset, must be exhausted first
	EndIf
	TownRaidCountdown += 1
EndFunction

Function DeployAllMinorCapitalRaids()
	int i = MinorCapitalRaids.Length
	While (i)
		i -= 1
		If MinorCapitalRaids[i] != None
			DeploySquad(MinorCapitalRaids[i], True, RAID_MINOR_CAPITAL)
		EndIf
	EndWhile
	MinorCapitalRaidCountdown = -1
EndFunction

Function DeployMinorCapitalRaid()
	If MinorCapitalRaidCountdown < 0 || MinorCapitalRaidCountdown >= MinorCapitalRaids.Length
		MinorCapitalRaidCountdown = 0
	EndIf
	If MinorCapitalRaids[MinorCapitalRaidCountdown] != None
		DeploySquad(MinorCapitalRaids[MinorCapitalRaidCountdown], False, RAID_MINOR_CAPITAL) ; No forced reset, must be exhausted first
	EndIf
	MinorCapitalRaidCountdown += 1
EndFunction

Function DeployGateCrashers()
	DeploySquadArray(GateCrashers, False, RAID_GATE)
EndFunction

Function DeployAllCapitalRaids()
	int i = CapitalRaids.Length
	While (i)
		i -= 1
		If CapitalRaids[i] != None
			DeploySquad(CapitalRaids[i], True, RAID_CAPITAL)
		EndIf
	EndWhile
	CapitalRaidCountdown = -1
EndFunction

Function DeployCapitalRaid()
	If CapitalRaidCountdown < 0 || CapitalRaidCountdown >= CapitalRaids.Length
		CapitalRaidCountdown = 0
	EndIf
	If CapitalRaids[CapitalRaidCountdown] != None
		DeploySquad(CapitalRaids[CapitalRaidCountdown], dsGlobals.gEternal, RAID_CAPITAL)
	EndIf
	CapitalRaidCountdown += 1
EndFunction

Function KillService()
	If dsGlobals.gAccuracy < ACCURACY_BROAD
		Return
	EndIf
	KillTarget(LastTarget_DSV)
	DeployRandomFromArray(DeathSquads_Services, "service death squad", True, RAID_SERVICE)
EndFunction

Function DeployManyPillagers(int aiHowMany)
	If dsGlobals.gAccuracy < ACCURACY_BROAD
		Return
	EndIf

	While (aiHowMany)
		aiHowMany -= 1
		DeployPillagers()
		Utility.Wait(10)
	EndWhile
	
EndFunction

bool Function DeployPillagers()
	If dsGlobals.gAccuracy < ACCURACY_BROAD
		Return True
	EndIf
	Return DeployRandomFromArray(PillageSquads, "pillage squad", True, RAID_PILLAGE)
EndFunction

bool Function DeployServiceRaid()
	Return DeployRandomEligibleFromArray(DeathSquads_Services, "service death squad", RAID_SERVICE, "", False)
EndFunction

bool Function DeployPillageRaid()
	Return DeployRandomEligibleFromArray(PillageSquads, "pillage squad", RAID_PILLAGE, "", False)
EndFunction

bool Function DeployRoamingMobRaid()
	UpdateRoamingMobExtraChance()
	Return DeployRandomEligibleFromArray(RoamingMobs, "roaming mob", RAID_ROAMING_MOB, "", False)
EndFunction

bool Function DeploySquad(Quest q, bool abReset, int aiRaidType = 0)

	If !q
		LogError("DeploySquad received a missing quest.")
		Return False
	EndIf

	bool wasRunning = q.IsRunning()
	If wasRunning
		If !abReset
			LogDebug("DeploySquad skipped running quest '" + q.GetName() + "'")
			Return False
		EndIf
		int cleanedCount = CleanupRunningRaidActors(q, aiRaidType)
		If cleanedCount < 0
			LogError("DeploySquad skipped reset for running quest '" + q.GetName() + "' because actor cleanup failed.")
			Return False
		EndIf
		LogRaidCleanupResult(q, aiRaidType, "explicit reset", cleanedCount, "stop/reset/start requested")
	EndIf

	LogDebug("DeploySquad is undertaking '" + q.GetName() + "'")
	q.Stop()
	q.Reset()
	bool started = q.Start()
	If !started
		;DoNotify("FAILED to start: " + q.GetName())
		LogError("DeploySquad failed to start '" + q.GetName() + "'.")
	Else
		RecordStaleRaidStarted(q, Utility.GetCurrentGameTime())
		; dsGlobals.gTickCount = dsGlobals.gTickCount + 1
	EndIf
	Return started

EndFunction

Function EnsureStaleRaidTracker()

	If !StaleRaidQuests || StaleRaidQuests.Length != STALE_RAID_TRACKER_CAPACITY
		StaleRaidQuests = new Quest[128]
		StaleRaidStartedAt = new Float[128]
	EndIf

EndFunction

int Function FindStaleRaidSlot(Quest q)

	If !q
		Return -1
	EndIf

	EnsureStaleRaidTracker()
	int i = 0
	While i < STALE_RAID_TRACKER_CAPACITY
		If StaleRaidQuests[i] == q
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1

EndFunction

int Function FindEmptyStaleRaidSlot()

	EnsureStaleRaidTracker()
	int i = 0
	While i < STALE_RAID_TRACKER_CAPACITY
		If !StaleRaidQuests[i]
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1

EndFunction

bool Function RecordStaleRaidStarted(Quest q, Float afStartedAt)

	If !q
		Return False
	EndIf

	int slot = FindStaleRaidSlot(q)
	If slot < 0
		slot = FindEmptyStaleRaidSlot()
	EndIf
	If slot < 0
		LogError("Stale raid tracker is full; could not track '" + q.GetName() + "'.")
		Return False
	EndIf

	StaleRaidQuests[slot] = q
	StaleRaidStartedAt[slot] = afStartedAt
	Return True

EndFunction

Function CleanupStaleDraugnarokRaids()

	CleanupStaleRaidArray(DeathSquads_Small, RAID_SMALL)
	CleanupStaleRaidArray(DeathSquads_Services, RAID_SERVICE)
	CleanupStaleRaidArray(TownRaids, RAID_TOWN)
	CleanupStaleRaidArray(DeathSquads_Medium, RAID_MEDIUM)
	CleanupStaleRaidArray(PillageSquads, RAID_PILLAGE)
	CleanupStaleRaidArray(GateCrashers, RAID_GATE)
	CleanupStaleRaidArray(MinorCapitalRaids, RAID_MINOR_CAPITAL)
	CleanupStaleRaidArray(CapitalRaids, RAID_CAPITAL)

EndFunction

Function CleanupStaleRaidArray(Quest[] akArray, int aiRaidType)

	If !akArray || akArray.Length < 1
		Return
	EndIf

	int cleanupIntervals = GetRaidForceCleanupIntervalsForType(aiRaidType)
	float cleanupHours = GetDraugnarokIntervalWindowHours(cleanupIntervals)
	If cleanupHours <= 0.0
		Return
	EndIf

	float now = Utility.GetCurrentGameTime()
	int i = 0
	While i < akArray.Length
		ForceCleanupStaleRaid(akArray[i], aiRaidType, now, cleanupHours, cleanupIntervals)
		i += 1
	EndWhile

EndFunction

bool Function ForceCleanupStaleRaid(Quest q, int aiRaidType, float afNow, float afCleanupHours, int aiCleanupIntervals)

	If !q || !q.IsRunning()
		Return False
	EndIf

	int slot = FindStaleRaidSlot(q)
	If slot < 0
		RecordStaleRaidStarted(q, afNow)
		Return False
	EndIf

	float startedAt = StaleRaidStartedAt[slot]
	If startedAt <= 0.0 || startedAt > afNow
		StaleRaidStartedAt[slot] = afNow
		Return False
	EndIf

	float ageHours = (afNow - startedAt) * 24.0
	If ageHours < afCleanupHours
		Return False
	EndIf

	If aiRaidType == RAID_CAPITAL
		LogInfo("Force cleaning stale Draugnarok raid '" + q.GetName() + "' after " + Math.Floor(ageHours) + " in-game hours (" + aiCleanupIntervals + " assault intervals).", True)
		int cleanedCount = ForceCleanupCapitalRaidActors(q)
		q.Stop()
		LogRaidCleanupResult(q, aiRaidType, "stale force cleanup", cleanedCount, "stop requested")
		Return True
	EndIf

	_DS_DN_ExhaustHandler exhaustHandler = q as _DS_DN_ExhaustHandler
	If !exhaustHandler
		LogError("Force cleanup skipped '" + q.GetName() + "': missing _DS_DN_ExhaustHandler.")
		Return False
	EndIf

	LogInfo("Force cleaning stale Draugnarok raid '" + q.GetName() + "' after " + Math.Floor(ageHours) + " in-game hours (" + aiCleanupIntervals + " assault intervals).", True)
	int cleanedCount = exhaustHandler.ForceCleanupRaid()
	LogRaidCleanupResult(q, aiRaidType, "stale force cleanup", cleanedCount, "stop requested")
	Return True

EndFunction

int Function CleanupRunningRaidActors(Quest q, int aiRaidType)

	If !q
		Return -1
	EndIf

	If aiRaidType == RAID_CAPITAL
		Return ForceCleanupCapitalRaidActors(q)
	EndIf

	_DS_DN_ExhaustHandler exhaustHandler = q as _DS_DN_ExhaustHandler
	If !exhaustHandler
		LogError("Raid actor cleanup skipped '" + q.GetName() + "': missing _DS_DN_ExhaustHandler.")
		Return -1
	EndIf

	Return exhaustHandler.CleanupRaidAliases()

EndFunction

int Function ForceCleanupCapitalRaidActors(Quest q)

	If !q
		Return 0
	EndIf

	int cleanedCount = 0
	int aliasIndex = 0
	While aliasIndex < CAPITAL_RAID_ALIAS_SCAN_LIMIT
		ReferenceAlias refAlias = q.GetAlias(aliasIndex) as ReferenceAlias
		If refAlias
			Actor raidActor = refAlias.GetActorReference()
			If raidActor && raidActor != PlayerRef
				raidActor.DisableNoWait()
				raidActor.Delete()
				cleanedCount += 1
			EndIf
		EndIf
		aliasIndex += 1
	EndWhile

	Return cleanedCount

EndFunction


; D: D: D:  MISC FUNCTIONS  D: D: D: D: D: D: D: D: D: D: D: D: D: D: D: D: D:
;

Function InitStuff()

	If IsRunning() && !Running
		StartTicking()
	EndIf

EndFunction

Function InitDraugnarokDefaults()

	dsGlobals.gDraugnarokDisabled = False
	dsGlobals.gDraugnarokStage = STAGE_DORMANT
	dsGlobals.gAccuracy = ACCURACY_NONE
	dsGlobals.gRadiance = False
	dsGlobals.gWeather = 0
	dsGlobals.gEternal = False
	dsGlobals.gMayhem = False
	dsGlobals.gTickCount = 0
	SetRadiance()
	UpdateWorldEncounterChances()
	DraugnarokInitialized = True
	UpdateDraugnarokQuestStage()
	LogInfo("Startup initialized.", True)

EndFunction

Function LogWaitingForAlduin()

	If WaitingForAlduinLogged
		Return
	EndIf
	WaitingForAlduinLogged = True
	LogInfo("Waiting for Alduin to be loose.", True)

EndFunction

Function LogPressureActivated()

	If PressureActivationJournaled
		Return
	EndIf
	PressureActivationJournaled = True
	LogInfo("Draugnarok system activated.")
	JournalMajorEvent("The dead stir across Skyrim.")

EndFunction

Function JournalShutdown()

	If ShutdownJournaled
		Return
	EndIf
	ShutdownJournaled = True
	JournalMajorEvent("Alduin has fallen. The dead grow quiet.")

EndFunction

bool Function IsAlduinDefeated()

	If MQ305 && MQ305.GetStage() >= 190
		Return True
	EndIf
	Return False

EndFunction

bool Function IsAlduinLooseForDraugnarok()

	If MQ101
		If MQ101.IsCompleted() || MQ101.GetStageDone(1000) || MQ101.GetStage() >= 1000
			Return True
		EndIf
	EndIf

	If MQ102
		If MQ102.IsCompleted() || MQ102.GetStage() > 0
			Return True
		EndIf
	EndIf

	Return False

EndFunction

int Function NormalizeIronSoulPresetOrdinal(int aiPresetOrdinal)

	If aiPresetOrdinal == 0
		Return 0
	ElseIf aiPresetOrdinal >= 1 && aiPresetOrdinal <= 3
		Return aiPresetOrdinal
	ElseIf aiPresetOrdinal >= 5 && aiPresetOrdinal <= 7
		Return aiPresetOrdinal
	ElseIf aiPresetOrdinal >= 9 && aiPresetOrdinal <= 11
		Return aiPresetOrdinal
	EndIf
	Return 0

EndFunction

int Function GetIronSoulPresetFamily(int aiPresetOrdinal)

	aiPresetOrdinal = NormalizeIronSoulPresetOrdinal(aiPresetOrdinal)
	If aiPresetOrdinal >= 1 && aiPresetOrdinal <= 3
		Return 1
	ElseIf aiPresetOrdinal >= 5 && aiPresetOrdinal <= 7
		Return 2
	ElseIf aiPresetOrdinal >= 9 && aiPresetOrdinal <= 11
		Return 3
	EndIf
	Return 0

EndFunction

int Function GetPresetOrdinalPlusRank(int aiPresetOrdinal)

	aiPresetOrdinal = NormalizeIronSoulPresetOrdinal(aiPresetOrdinal)
	If aiPresetOrdinal >= 1 && aiPresetOrdinal <= 3
		Return aiPresetOrdinal - 1
	ElseIf aiPresetOrdinal >= 5 && aiPresetOrdinal <= 7
		Return aiPresetOrdinal - 5
	ElseIf aiPresetOrdinal >= 9 && aiPresetOrdinal <= 11
		Return aiPresetOrdinal - 9
	EndIf
	Return 0

EndFunction

int Function GetPresetThreatFloor(int aiPresetOrdinal)

	int presetFamily = GetIronSoulPresetFamily(aiPresetOrdinal)
	If presetFamily == 1
		Return 2
	ElseIf presetFamily == 2
		Return 3
	ElseIf presetFamily == 3
		Return 4
	EndIf
	Return 1

EndFunction

int Function ClampConfiguredDraugrThreatLevel(int aiThreat)

	If aiThreat < 1
		Return 1
	ElseIf aiThreat > 5
		Return 5
	EndIf
	Return aiThreat

EndFunction

int Function GetEffectiveDraugrThreatLevel()

	int presetOrdinal = NormalizeIronSoulPresetOrdinal(IronSoulNative.GetIronSoulPresetOrdinal())
	If presetOrdinal == 0
		Return ClampConfiguredDraugrThreatLevel(IronSoulNative.GetConfigInt("DraugrThreatLevel", 2))
	EndIf

	int threat = GetPresetThreatFloor(presetOrdinal)
	If GetPresetOrdinalPlusRank(presetOrdinal) >= 2
		threat += 1
	EndIf
	Return ClampConfiguredDraugrThreatLevel(threat)

EndFunction

int Function GetDraugrThreatLevel()

	If !IsDraugnarokSystemEnabled()
		Return -1
	EndIf

	int overrideMode = GetDraugnarokOverrideMode()
	If overrideMode == OVERRIDE_FORCE_OFF
		Return -1
	EndIf

	Return GetEffectiveDraugrThreatLevel()

EndFunction

bool Function IsDraugnarokSystemEnabled()

	If !IronSoulNative.IsAvailable()
		Return False
	EndIf
	Return IsConfigEnabled("DraugnarokSystem", 1)

EndFunction

bool Function IsConfigEnabled(string asKey, int aiDefaultValue = 1)

	Return IronSoulNative.GetConfigInt(asKey, aiDefaultValue) != 0

EndFunction

bool Function IsDraugnarokVisibleQuestEnabled()

	Return IsConfigEnabled("DraugnarokVisibleQuest", 1)

EndFunction

int Function GetDraugnarokQuestStage()

	int overrideMode = GetDraugnarokOverrideMode()
	If overrideMode == OVERRIDE_FORCE_OFF
		Return STAGE_DORMANT
	EndIf
	If !IsDraugnarokSystemEnabled()
		Return STAGE_DORMANT
	EndIf

	int threat = GetDraugrThreatLevel()
	If threat < 0
		Return STAGE_DORMANT
	EndIf

	If overrideMode == OVERRIDE_FORCE_ON
		Return STAGE_STIRRING
	EndIf

	If IsAlduinDefeated()
		Return STAGE_ALDUIN_DEFEATED
	EndIf

	If !IsAlduinLooseForDraugnarok()
		Return STAGE_DORMANT
	EndIf

	If !IsConfigEnabled("DraugnarokLevelProgression", 1)
		Return STAGE_UNLEVELED_PRESSURE
	EndIf

	int level = GetPlayerLevel()
	If level < 10
		Return STAGE_STIRRING
	ElseIf level < 20
		Return STAGE_ROADS
	ElseIf level < 30
		Return STAGE_BARROWS
	ElseIf level < 40
		Return STAGE_HOLDS
	ElseIf level < 50
		Return STAGE_CITIES
	EndIf
	Return STAGE_FULL_PRESSURE

EndFunction

int Function GetDraugnarokWeatherMode()

	If !IronSoulNative.IsAvailable()
		Return RAID_WEATHER_MODE_DEFAULT
	EndIf

	int mode = IronSoulNative.GetConfigInt("DraugnarokWeatherMode", RAID_WEATHER_MODE_DEFAULT)
	If mode < RAID_WEATHER_OFF
		Return RAID_WEATHER_OFF
	ElseIf mode > RAID_WEATHER_LEGACY_MAJOR_GLOBAL
		Return RAID_WEATHER_LEGACY_MAJOR_GLOBAL
	EndIf
	Return mode

EndFunction

Function EnsureDelayedRaidWeatherQueue()

	If !DelayedRaidWeatherTypes || DelayedRaidWeatherTypes.Length != DELAYED_RAID_WEATHER_QUEUE_CAPACITY
		DelayedRaidWeatherTypes = new Int[16]
		DelayedRaidWeatherNames = new String[16]
		DelayedRaidWeatherLocations = new Location[16]
		DelayedRaidWeatherAnchors = new ObjectReference[16]
		DelayedRaidWeatherFallbackAnchors = new ObjectReference[16]
		DelayedRaidWeatherDueAt = new Float[16]
		DelayedRaidWeatherNextDueAt = 0.0
	EndIf

EndFunction

Function ClearDelayedRaidWeatherSlot(int aiSlot)

	If !DelayedRaidWeatherTypes || aiSlot < 0 || aiSlot >= DelayedRaidWeatherTypes.Length
		Return
	EndIf

	DelayedRaidWeatherTypes[aiSlot] = 0
	DelayedRaidWeatherNames[aiSlot] = ""
	DelayedRaidWeatherLocations[aiSlot] = None
	DelayedRaidWeatherAnchors[aiSlot] = None
	DelayedRaidWeatherFallbackAnchors[aiSlot] = None
	DelayedRaidWeatherDueAt[aiSlot] = 0.0

EndFunction

Function ClearDelayedRaidWeatherQueue()

	If !DelayedRaidWeatherTypes
		DelayedRaidWeatherNextDueAt = 0.0
		Return
	EndIf

	int i = 0
	While i < DelayedRaidWeatherTypes.Length
		ClearDelayedRaidWeatherSlot(i)
		i += 1
	EndWhile
	DelayedRaidWeatherNextDueAt = 0.0

EndFunction

int Function FindDelayedRaidWeatherSlot(int aiRaidType, string asName, Location akRaidLocation, ObjectReference akAnchor, ObjectReference akFallbackAnchor)

	EnsureDelayedRaidWeatherQueue()

	int emptySlot = -1
	int i = 0
	While i < DELAYED_RAID_WEATHER_QUEUE_CAPACITY
		If DelayedRaidWeatherDueAt[i] <= 0.0
			If emptySlot < 0
				emptySlot = i
			EndIf
		ElseIf DelayedRaidWeatherTypes[i] == aiRaidType && DelayedRaidWeatherNames[i] == asName && DelayedRaidWeatherLocations[i] == akRaidLocation && DelayedRaidWeatherAnchors[i] == akAnchor && DelayedRaidWeatherFallbackAnchors[i] == akFallbackAnchor
			Return i
		EndIf
		i += 1
	EndWhile
	Return emptySlot

EndFunction

Function ScheduleNextDelayedRaidWeatherUpdate()

	If !DelayedRaidWeatherDueAt
		DelayedRaidWeatherNextDueAt = 0.0
		Return
	EndIf

	float now = Utility.GetCurrentRealTime()
	float nextDueAt = 0.0
	int i = 0
	While i < DELAYED_RAID_WEATHER_QUEUE_CAPACITY
		If DelayedRaidWeatherDueAt[i] > 0.0 && (nextDueAt <= 0.0 || DelayedRaidWeatherDueAt[i] < nextDueAt)
			nextDueAt = DelayedRaidWeatherDueAt[i]
		EndIf
		i += 1
	EndWhile

	If nextDueAt <= 0.0
		DelayedRaidWeatherNextDueAt = 0.0
		Return
	EndIf

	If DelayedRaidWeatherNextDueAt > 0.0 && DelayedRaidWeatherNextDueAt <= nextDueAt && DelayedRaidWeatherNextDueAt > now
		Return
	EndIf

	float delaySeconds = nextDueAt - now
	If delaySeconds < 1.0
		delaySeconds = 1.0
	EndIf
	DelayedRaidWeatherNextDueAt = nextDueAt
	RegisterForSingleUpdate(delaySeconds)
	LogDebug("Scheduled delayed raid weather update in " + Math.Floor(delaySeconds) + " seconds.")

EndFunction

Function QueueDelayedRaidWeatherCheck(int aiRaidType, string asName, Location akRaidLocation = None, ObjectReference akAnchor = None, ObjectReference akFallbackAnchor = None)

	int slot = FindDelayedRaidWeatherSlot(aiRaidType, asName, akRaidLocation, akAnchor, akFallbackAnchor)
	If slot < 0
		LogDebug("Dropped delayed raid weather check for " + GetRaidTypeWeatherName(aiRaidType) + " '" + asName + "': queue full.")
		Return
	EndIf

	float delaySeconds = Utility.RandomInt(DELAYED_RAID_WEATHER_MIN_DELAY_SECONDS, DELAYED_RAID_WEATHER_MAX_DELAY_SECONDS) as float
	DelayedRaidWeatherTypes[slot] = aiRaidType
	DelayedRaidWeatherNames[slot] = asName
	DelayedRaidWeatherLocations[slot] = akRaidLocation
	DelayedRaidWeatherAnchors[slot] = akAnchor
	DelayedRaidWeatherFallbackAnchors[slot] = akFallbackAnchor
	DelayedRaidWeatherDueAt[slot] = Utility.GetCurrentRealTime() + delaySeconds
	LogDebug("Queued delayed raid weather check for " + GetRaidTypeWeatherName(aiRaidType) + " '" + asName + "' in " + Math.Floor(delaySeconds) + " seconds.")
	ScheduleNextDelayedRaidWeatherUpdate()

EndFunction

Function ProcessDelayedRaidWeatherQueue()

	If !DelayedRaidWeatherDueAt
		Return
	EndIf

	float now = Utility.GetCurrentRealTime()
	int i = 0
	While i < DELAYED_RAID_WEATHER_QUEUE_CAPACITY
		If DelayedRaidWeatherDueAt[i] > 0.0 && DelayedRaidWeatherDueAt[i] <= now
			int raidType = DelayedRaidWeatherTypes[i]
			string raidName = DelayedRaidWeatherNames[i]
			Location raidLocation = DelayedRaidWeatherLocations[i]
			ObjectReference anchorRef = DelayedRaidWeatherAnchors[i]
			ObjectReference fallbackRef = DelayedRaidWeatherFallbackAnchors[i]
			ClearDelayedRaidWeatherSlot(i)
			LogDebug("Running delayed raid weather check for " + GetRaidTypeWeatherName(raidType) + " '" + raidName + "'.")
			HandleRaidWeather(raidType, raidName, raidLocation, anchorRef, fallbackRef, False)
		EndIf
		i += 1
	EndWhile

	DelayedRaidWeatherNextDueAt = 0.0
	ScheduleNextDelayedRaidWeatherUpdate()

EndFunction

Function HandleRaidWeather(int aiRaidType, string asName = "", Location akRaidLocation = None, ObjectReference akAnchor = None, ObjectReference akFallbackAnchor = None, bool abAllowDelayedRetry = True)

	int mode = GetDraugnarokWeatherMode()
	string raidTypeName = GetRaidTypeWeatherName(aiRaidType)
	If mode == RAID_WEATHER_OFF
		LogDebug("Raid weather decision: mode=0/off raid=" + raidTypeName + " name='" + asName + "' result=skip reason=disabled")
		Return
	EndIf

	bool nearby = IsPlayerNearRaidWeatherTarget(aiRaidType, akRaidLocation, akAnchor, akFallbackAnchor)
	int chance = GetRaidWeatherChanceForMode(mode, aiRaidType, nearby)
	int roll = 0
	bool applyWeather = False
	If chance >= 100
		applyWeather = True
	ElseIf chance > 0
		roll = Utility.RandomInt(1, 100)
		applyWeather = roll <= chance
	EndIf

	LogRaidWeatherDecision(mode, aiRaidType, asName, nearby, chance, roll, applyWeather)
	If applyWeather
		ForceRaidWeather(raidTypeName + " '" + asName + "'")
	ElseIf !nearby && mode != RAID_WEATHER_LEGACY_MAJOR_GLOBAL
		If abAllowDelayedRetry
			int nearbyChance = GetRaidWeatherChanceForMode(mode, aiRaidType, True)
			If nearbyChance > 0
				QueueDelayedRaidWeatherCheck(aiRaidType, asName, akRaidLocation, akAnchor, akFallbackAnchor)
			Else
				LogDebug("Skipped delayed raid weather check for " + raidTypeName + " '" + asName + "': mode cannot apply to this raid type.")
			EndIf
		EndIf
		LogDebug("Skipped thematic weather for distant " + raidTypeName + " '" + asName + "'.")
	EndIf

EndFunction

int Function GetRaidWeatherChanceForMode(int aiMode, int aiRaidType, bool abNearby)

	If aiMode == RAID_WEATHER_LEGACY_MAJOR_GLOBAL
		If IsMajorRaidType(aiRaidType)
			Return 100
		EndIf
		Return 0
	EndIf

	If !abNearby
		Return 0
	EndIf

	If aiMode == RAID_WEATHER_ALL_NEARBY
		Return 100
	ElseIf aiMode == RAID_WEATHER_MAJOR_NEARBY
		If IsMajorRaidType(aiRaidType)
			Return 100
		EndIf
		Return 0
	ElseIf aiMode == RAID_WEATHER_SMART_NEARBY
		Return GetSmartRaidWeatherChance(aiRaidType)
	EndIf

	Return 0

EndFunction

int Function GetSmartRaidWeatherChance(int aiRaidType)

	If aiRaidType == RAID_CAPITAL
		Return 100
	ElseIf aiRaidType == RAID_MINOR_CAPITAL || aiRaidType == RAID_GATE
		Return 75
	ElseIf aiRaidType == RAID_TOWN || aiRaidType == RAID_MEDIUM || aiRaidType == RAID_PILLAGE
		Return 40
	ElseIf aiRaidType == RAID_SMALL || aiRaidType == RAID_SERVICE || aiRaidType == RAID_ROAMING_MOB
		Return 20
	EndIf
	Return 0

EndFunction

bool Function IsPlayerNearRaidWeatherTarget(int aiRaidType, Location akRaidLocation = None, ObjectReference akAnchor = None, ObjectReference akFallbackAnchor = None)

	If !PlayerRef
		LogDebug("Raid weather proximity: result=false reason=missing-player")
		Return False
	EndIf

	Location originalRaidLocation = akRaidLocation
	If !akRaidLocation && akAnchor
		akRaidLocation = akAnchor.GetCurrentLocation()
	EndIf
	If !akRaidLocation && akFallbackAnchor
		akRaidLocation = akFallbackAnchor.GetCurrentLocation()
	EndIf

	If akRaidLocation && PlayerRef.IsInLocation(akRaidLocation)
		LogDebug("Raid weather proximity: result=true method=location raidLocation='" + GetLocationLogName(akRaidLocation) + "' playerLocation='" + GetLocationLogName(PlayerRef.GetCurrentLocation()) + "' originalLocation='" + GetLocationLogName(originalRaidLocation) + "' anchor=" + GetRefLogName(akAnchor) + " fallback=" + GetRefLogName(akFallbackAnchor))
		Return True
	EndIf

	If IsRaidWeatherAnchorNearby(aiRaidType, akAnchor)
		LogDebug("Raid weather proximity: result=true method=anchor raidLocation='" + GetLocationLogName(akRaidLocation) + "' playerLocation='" + GetLocationLogName(PlayerRef.GetCurrentLocation()) + "' anchor=" + GetRefLogName(akAnchor) + " fallback=" + GetRefLogName(akFallbackAnchor))
		Return True
	EndIf

	bool fallbackNearby = IsRaidWeatherAnchorNearby(aiRaidType, akFallbackAnchor)
	LogDebug("Raid weather proximity: result=" + fallbackNearby + " method=fallback raidLocation='" + GetLocationLogName(akRaidLocation) + "' playerLocation='" + GetLocationLogName(PlayerRef.GetCurrentLocation()) + "' anchor=" + GetRefLogName(akAnchor) + " fallback=" + GetRefLogName(akFallbackAnchor))
	Return fallbackNearby

EndFunction

bool Function IsRaidWeatherAnchorNearby(int aiRaidType, ObjectReference akAnchor)

	If !PlayerRef || !akAnchor
		LogDebug("Raid weather anchor check: result=false reason=missing-ref anchor=" + GetRefLogName(akAnchor))
		Return False
	EndIf

	If PlayerRef.IsInInterior() || akAnchor.IsInInterior()
		If PlayerRef.GetParentCell() != akAnchor.GetParentCell()
			LogDebug("Raid weather anchor check: result=false reason=cell-mismatch anchor=" + GetRefLogName(akAnchor) + " playerCell=" + PlayerRef.GetParentCell() + " anchorCell=" + akAnchor.GetParentCell())
			Return False
		EndIf
	Else
		WorldSpace playerWorld = PlayerRef.GetWorldSpace()
		WorldSpace anchorWorld = akAnchor.GetWorldSpace()
		If playerWorld && anchorWorld && playerWorld != anchorWorld
			LogDebug("Raid weather anchor check: result=false reason=worldspace-mismatch anchor=" + GetRefLogName(akAnchor) + " playerWorld=" + playerWorld + " anchorWorld=" + anchorWorld)
			Return False
		EndIf
	EndIf

	float distance = PlayerRef.GetDistance(akAnchor)
	float radius = GetRaidWeatherRadius(aiRaidType)
	bool nearby = distance <= radius
	LogDebug("Raid weather anchor check: result=" + nearby + " anchor=" + GetRefLogName(akAnchor) + " distance=" + distance + " radius=" + radius)
	Return nearby

EndFunction

Function LogRaidWeatherDecision(int aiMode, int aiRaidType, string asName, bool abNearby, int aiChance, int aiRoll, bool abApplyWeather)

	string rollText = "n/a"
	If aiRoll > 0
		rollText = "" + aiRoll
	EndIf
	LogDebug("Raid weather decision: mode=" + aiMode + " raid=" + GetRaidTypeWeatherName(aiRaidType) + " name='" + asName + "' nearby=" + abNearby + " chance=" + aiChance + " roll=" + rollText + " result=" + abApplyWeather)

EndFunction

string Function GetLocationLogName(Location akLocation)

	If !akLocation
		Return "None"
	EndIf
	string locName = akLocation.GetName()
	If locName == ""
		Return "" + akLocation
	EndIf
	Return locName

EndFunction

string Function GetRefLogName(ObjectReference akRef)

	If !akRef
		Return "None"
	EndIf
	string refName = akRef.GetDisplayName()
	If refName == ""
		refName = akRef.GetName()
	EndIf
	If refName == ""
		Return "" + akRef
	EndIf
	Return refName + " [" + akRef + "]"

EndFunction

float Function GetRaidWeatherRadius(int aiRaidType)

	If aiRaidType == RAID_CAPITAL
		Return 24000.0
	ElseIf aiRaidType == RAID_MINOR_CAPITAL || aiRaidType == RAID_GATE
		Return 18000.0
	ElseIf aiRaidType == RAID_TOWN || aiRaidType == RAID_MEDIUM || aiRaidType == RAID_PILLAGE
		Return 12000.0
	EndIf
	Return 6000.0

EndFunction

string Function GetRaidTypeWeatherName(int aiRaidType)

	If aiRaidType == RAID_SMALL
		Return "small death squad"
	ElseIf aiRaidType == RAID_SERVICE
		Return "service death squad"
	ElseIf aiRaidType == RAID_TOWN
		Return "town raid"
	ElseIf aiRaidType == RAID_ROAMING_MOB
		Return "roaming mob"
	ElseIf aiRaidType == RAID_MEDIUM
		Return "medium death squad"
	ElseIf aiRaidType == RAID_PILLAGE
		Return "pillage squad"
	ElseIf aiRaidType == RAID_MINOR_CAPITAL
		Return "minor capital raid"
	ElseIf aiRaidType == RAID_GATE
		Return "gate crasher raid"
	ElseIf aiRaidType == RAID_CAPITAL
		Return "capital raid"
	EndIf
	Return "raid"

EndFunction

Function ClearWorldEncounterChances()

	dsGlobals.gWEChance = 0
	dsGlobals.gWEChance_Road = 0
	dsGlobals.gRoamingMobExtraChance = 0

EndFunction

Function UpdateWorldEncounterChances(int aiThreat = -1)

	If aiThreat < 0
		aiThreat = GetDraugrThreatLevel()
	EndIf

	If aiThreat < 0
		ClearWorldEncounterChances()
		Return
	EndIf

	If IsConfigEnabled("WildernessEncounters", 1)
		dsGlobals.gWEChance = GetWildernessEncounterChance(aiThreat)
	Else
		dsGlobals.gWEChance = 0
	EndIf

	If IsConfigEnabled("RoadEncounters", 1)
		dsGlobals.gWEChance_Road = GetRoadEncounterChance(aiThreat)
	Else
		dsGlobals.gWEChance_Road = 0
	EndIf
	UpdateRoamingMobExtraChance(aiThreat)

EndFunction

Function UpdateRoamingMobExtraChance(int aiThreat = -1)

	If aiThreat < 0
		aiThreat = GetDraugrThreatLevel()
	EndIf
	dsGlobals.gRoamingMobExtraChance = GetRoamingMobExtraChance(aiThreat)

EndFunction

int Function GetRoamingMobExtraChance(int aiThreat)

	If aiThreat < 0
		Return 0
	ElseIf aiThreat == 1
		Return 10
	ElseIf aiThreat == 2
		Return 25
	ElseIf aiThreat == 3
		Return 50
	ElseIf aiThreat == 4
		Return 65
	EndIf
	Return 80

EndFunction

int Function GetWildernessEncounterChance(int aiThreat)

	If aiThreat < 0
		Return 0
	ElseIf aiThreat == 1
		Return 0
	ElseIf aiThreat == 2
		Return 1
	ElseIf aiThreat == 3
		Return 2
	ElseIf aiThreat == 4
		Return 4
	EndIf
	Return 8

EndFunction

int Function GetRoadEncounterChance(int aiThreat)

	If aiThreat < 0
		Return 0
	ElseIf aiThreat == 1
		Return 1
	ElseIf aiThreat == 2
		Return 2
	ElseIf aiThreat == 3
		Return 4
	ElseIf aiThreat == 4
		Return 8
	EndIf
	Return 12

EndFunction

int Function GetDraugnarokJournalMode()

	If !IronSoulNative.IsAvailable()
		Return DRAUGNAROK_JOURNAL_MODE_DEFAULT
	EndIf

	int mode = IronSoulNative.GetConfigInt("DraugnarokJournalMode", DRAUGNAROK_JOURNAL_MODE_DEFAULT)
	If mode < 0
		Return 0
	ElseIf mode > 3
		Return 3
	EndIf
	Return mode

EndFunction

int Function GetDraugnarokNotificationMode()

	If !IronSoulNative.IsAvailable()
		Return DRAUGNAROK_NOTIFICATION_MODE_DEFAULT
	EndIf

	int mode = IronSoulNative.GetConfigInt("DraugnarokNotificationMode", DRAUGNAROK_NOTIFICATION_MODE_DEFAULT)
	If mode < 0
		Return 0
	ElseIf mode > 4
		Return 4
	EndIf
	Return mode

EndFunction

int Function GetDraugnarokForceCleanupIntervals()

	If !IronSoulNative.IsAvailable()
		Return DRAUGNAROK_FORCE_CLEANUP_INTERVALS_DEFAULT
	EndIf

	int intervals = IronSoulNative.GetConfigInt("DraugnarokForceCleanupIntervals", DRAUGNAROK_FORCE_CLEANUP_INTERVALS_DEFAULT)
	If intervals < 0
		Return 0
	ElseIf intervals > DRAUGNAROK_INTERVAL_SETTING_MAX
		Return DRAUGNAROK_INTERVAL_SETTING_MAX
	EndIf
	Return intervals

EndFunction

int Function GetDraugnarokCooldownIntervals()

	If !IronSoulNative.IsAvailable()
		Return DRAUGNAROK_COOLDOWN_INTERVALS_DEFAULT
	EndIf

	int intervals = IronSoulNative.GetConfigInt("DraugnarokCooldownIntervals", DRAUGNAROK_COOLDOWN_INTERVALS_DEFAULT)
	If intervals < 0
		Return 0
	ElseIf intervals > DRAUGNAROK_INTERVAL_SETTING_MAX
		Return DRAUGNAROK_INTERVAL_SETTING_MAX
	EndIf
	Return intervals

EndFunction

int Function GetDraugnarokGatePressureIntervals()

	If !IronSoulNative.IsAvailable()
		Return DRAUGNAROK_GATE_PRESSURE_INTERVALS_DEFAULT
	EndIf

	int intervals = IronSoulNative.GetConfigInt("DraugnarokGatePressureIntervals", DRAUGNAROK_GATE_PRESSURE_INTERVALS_DEFAULT)
	If intervals < 0
		Return 0
	ElseIf intervals > DRAUGNAROK_INTERVAL_SETTING_MAX
		Return DRAUGNAROK_INTERVAL_SETTING_MAX
	EndIf
	Return intervals

EndFunction

float Function GetDraugnarokIntervalWindowHours(int aiIntervals)

	If aiIntervals <= 0
		Return 0.0
	EndIf
	Return (aiIntervals as float) * (GetDraugnarokBaseIntervalHours() as float)

EndFunction

bool Function ShouldJournalRaidType(int aiRaidType)

	int mode = GetDraugnarokJournalMode()
	If mode <= 0
		Return False
	EndIf

	If mode >= 3
		Return aiRaidType == RAID_SMALL || aiRaidType == RAID_SERVICE || aiRaidType == RAID_TOWN || aiRaidType == RAID_ROAMING_MOB || aiRaidType == RAID_MEDIUM || aiRaidType == RAID_PILLAGE || aiRaidType == RAID_MINOR_CAPITAL || aiRaidType == RAID_GATE || aiRaidType == RAID_CAPITAL
	ElseIf mode == 2
		Return aiRaidType == RAID_MEDIUM || aiRaidType == RAID_PILLAGE || aiRaidType == RAID_MINOR_CAPITAL || aiRaidType == RAID_GATE || aiRaidType == RAID_CAPITAL
	EndIf
	Return aiRaidType == RAID_MINOR_CAPITAL || aiRaidType == RAID_GATE || aiRaidType == RAID_CAPITAL

EndFunction

int Function GetRaidNotificationSeverity(int aiRaidType)

	If aiRaidType == RAID_SMALL || aiRaidType == RAID_SERVICE || aiRaidType == RAID_TOWN || aiRaidType == RAID_ROAMING_MOB
		Return RAID_NOTIFICATION_LOW
	ElseIf aiRaidType == RAID_MEDIUM || aiRaidType == RAID_PILLAGE
		Return RAID_NOTIFICATION_MEDIUM
	ElseIf aiRaidType == RAID_MINOR_CAPITAL || aiRaidType == RAID_GATE || aiRaidType == RAID_CAPITAL
		Return RAID_NOTIFICATION_HIGH
	EndIf
	Return 0

EndFunction

string Function GetRaidSeverityNotificationText(int aiSeverity)

	If aiSeverity == RAID_NOTIFICATION_LOW
		Return "The dead stir..."
	ElseIf aiSeverity == RAID_NOTIFICATION_MEDIUM
		Return "The dead gather in force"
	ElseIf aiSeverity == RAID_NOTIFICATION_HIGH
		Return "The dead march on a hold"
	EndIf
	Return ""

EndFunction

bool Function IsMajorRaidType(int aiRaidType)

	Return aiRaidType == RAID_MINOR_CAPITAL || aiRaidType == RAID_GATE || aiRaidType == RAID_CAPITAL

EndFunction

string Function GetHexDigit(int aiValue)

	If aiValue == 1
		Return "1"
	ElseIf aiValue == 2
		Return "2"
	ElseIf aiValue == 3
		Return "3"
	ElseIf aiValue == 4
		Return "4"
	ElseIf aiValue == 5
		Return "5"
	ElseIf aiValue == 6
		Return "6"
	ElseIf aiValue == 7
		Return "7"
	ElseIf aiValue == 8
		Return "8"
	ElseIf aiValue == 9
		Return "9"
	ElseIf aiValue == 10
		Return "A"
	ElseIf aiValue == 11
		Return "B"
	ElseIf aiValue == 12
		Return "C"
	ElseIf aiValue == 13
		Return "D"
	ElseIf aiValue == 14
		Return "E"
	ElseIf aiValue == 15
		Return "F"
	EndIf
	Return "0"

EndFunction

string Function FormatFormID(int aiFormID)

	Return "0x" \
		+ GetHexDigit(Math.LogicalAnd(Math.RightShift(aiFormID, 28), 0xF)) \
		+ GetHexDigit(Math.LogicalAnd(Math.RightShift(aiFormID, 24), 0xF)) \
		+ GetHexDigit(Math.LogicalAnd(Math.RightShift(aiFormID, 20), 0xF)) \
		+ GetHexDigit(Math.LogicalAnd(Math.RightShift(aiFormID, 16), 0xF)) \
		+ GetHexDigit(Math.LogicalAnd(Math.RightShift(aiFormID, 12), 0xF)) \
		+ GetHexDigit(Math.LogicalAnd(Math.RightShift(aiFormID, 8), 0xF)) \
		+ GetHexDigit(Math.LogicalAnd(Math.RightShift(aiFormID, 4), 0xF)) \
		+ GetHexDigit(Math.LogicalAnd(aiFormID, 0xF))

EndFunction

string Function GetSpawnDebugName(ObjectReference akDebugAnchor)

	If !akDebugAnchor
		Return ""
	EndIf

	int localFormID = Math.LogicalAnd(akDebugAnchor.GetFormID(), 0x00FFFFFF)
	If localFormID == 0x001D9B
		Return "Spawn_South_Falkreath"
	ElseIf localFormID == 0x001D9C
		Return "Spawn_South_Helgen"
	ElseIf localFormID == 0x001D9D
		Return "Spawn_East_Windhelm"
	ElseIf localFormID == 0x05741F
		Return "Spawn_Southeast_Forelhost"
	ElseIf localFormID == 0x05C525
		Return "Spawn_Southwest_Hagrock"
	ElseIf localFormID == 0x061628
		Return "Spawn_Northwest_Pinefrost"
	ElseIf localFormID == 0x06672A
		Return "Spawn_Central_Labyrinthian"
	EndIf
	Return ""

EndFunction

string Function GetRaidDebugNotificationSuffix(ObjectReference akDebugAnchor = None, string asDebugLabel = "")

	If !akDebugAnchor
		If asDebugLabel != ""
			Return " [" + asDebugLabel + "]"
		EndIf
		Return ""
	EndIf

	string formIDText = FormatFormID(akDebugAnchor.GetFormID())
	If asDebugLabel != ""
		Return " [" + asDebugLabel + " " + formIDText + "]"
	EndIf

	string spawnName = GetSpawnDebugName(akDebugAnchor)
	If spawnName != ""
		Return " [" + spawnName + "]"
	EndIf
	Return " [UnknownSpawn " + formIDText + "]"

EndFunction

Function ArmManualRaidDebugNotification(int aiRaidType, string asRaidLabel = "")

	ManualRaidDebugNotificationArmed = True
	ManualRaidDebugNotificationRaidType = aiRaidType
	ManualRaidDebugNotificationLabel = asRaidLabel

EndFunction

Function ClearManualRaidDebugNotification()

	ManualRaidDebugNotificationArmed = False
	ManualRaidDebugNotificationRaidType = 0
	ManualRaidDebugNotificationLabel = ""

EndFunction

string Function GetManualRaidNotificationLabel(int aiRaidType, string asRaidLabel = "")

	If asRaidLabel != ""
		Return asRaidLabel
	EndIf
	Return GetRaidTypeWeatherName(aiRaidType)

EndFunction

Function NotifyManualRaidTriggerFailed(int aiRaidType, string asRaidLabel = "")

	Debug.Notification("Failed to trigger Draugnarok " + GetManualRaidNotificationLabel(aiRaidType, asRaidLabel) + ".")

EndFunction

Function NotifyRaidEvent(int aiRaidType, string asExplicitText, ObjectReference akDebugAnchor = None, string asDebugLabel = "")

	int mode = GetDraugnarokNotificationMode()
	If ManualRaidDebugNotificationArmed && ManualRaidDebugNotificationRaidType == aiRaidType
		mode = 4
		ClearManualRaidDebugNotification()
	EndIf
	If mode <= 0
		Return
	EndIf

	string notificationText = ""
	If mode >= 4
		notificationText = asExplicitText
		If notificationText != ""
			notificationText += GetRaidDebugNotificationSuffix(akDebugAnchor, asDebugLabel)
		EndIf
	ElseIf mode >= 3
		notificationText = asExplicitText
	ElseIf mode == 2
		notificationText = GetRaidSeverityNotificationText(GetRaidNotificationSeverity(aiRaidType))
	ElseIf IsMajorRaidType(aiRaidType)
		notificationText = asExplicitText
	Else
		notificationText = GetRaidSeverityNotificationText(GetRaidNotificationSeverity(aiRaidType))
	EndIf

	If notificationText != ""
		Debug.Notification(notificationText)
	EndIf

EndFunction

Function JournalRaidEvent(int aiRaidType, string asEventText)

	If asEventText == ""
		Return
	EndIf
	If ShouldJournalRaidType(aiRaidType)
		JournalMajorEvent(asEventText)
	EndIf

EndFunction

bool Function StringContains(string asHaystack, string asNeedle)

	If asHaystack == "" || asNeedle == ""
		Return False
	EndIf
	Return StringUtil.Find(asHaystack, asNeedle) != -1

EndFunction

string Function GetRaidPlaceName(string asName)

	If StringContains(asName, "Darkwater Crossing") || StringContains(asName, "DarkwaterCrossing")
		Return "Darkwater Crossing"
	ElseIf StringContains(asName, "Dragon Bridge") || StringContains(asName, "DragonBridge")
		Return "Dragon Bridge"
	ElseIf StringContains(asName, "Shor's Stone") || StringContains(asName, "ShorsStone") || StringContains(asName, "Shors")
		Return "Shor's Stone"
	ElseIf StringContains(asName, "Dawnstar")
		Return "Dawnstar"
	ElseIf StringContains(asName, "Falkreath")
		Return "Falkreath"
	ElseIf StringContains(asName, "Morthal")
		Return "Morthal"
	ElseIf StringContains(asName, "Markarth")
		Return "Markarth"
	ElseIf StringContains(asName, "Riften")
		Return "Riften"
	ElseIf StringContains(asName, "Solitude")
		Return "Solitude"
	ElseIf StringContains(asName, "Whiterun")
		Return "Whiterun"
	ElseIf StringContains(asName, "Windhelm")
		Return "Windhelm"
	ElseIf StringContains(asName, "Winterhold")
		Return "Winterhold"
	ElseIf StringContains(asName, "Ivarstead")
		Return "Ivarstead"
	ElseIf StringContains(asName, "Karthwasten")
		Return "Karthwasten"
	ElseIf StringContains(asName, "Kynesgrove")
		Return "Kynesgrove"
	ElseIf StringContains(asName, "Riverwood")
		Return "Riverwood"
	ElseIf StringContains(asName, "Rorikstead")
		Return "Rorikstead"
	EndIf
	Return ""

EndFunction

bool Function IsMinorCapitalPlace(string asPlaceName)

	Return asPlaceName == "Dawnstar" || asPlaceName == "Falkreath" || asPlaceName == "Morthal"

EndFunction

bool Function IsCapitalRaidPlace(string asPlaceName)

	Return asPlaceName == "Markarth" || asPlaceName == "Riften" || asPlaceName == "Solitude" || asPlaceName == "Whiterun" || asPlaceName == "Windhelm" || asPlaceName == "Winterhold"

EndFunction

int Function GetRaidCooldownIntervalMultiplier(int aiRaidType)

	If aiRaidType == RAID_SMALL || aiRaidType == RAID_SERVICE || aiRaidType == RAID_PILLAGE || aiRaidType == RAID_ROAMING_MOB
		Return 1
	ElseIf aiRaidType == RAID_TOWN || aiRaidType == RAID_GATE || aiRaidType == RAID_MEDIUM
		Return 2
	ElseIf aiRaidType == RAID_MINOR_CAPITAL || aiRaidType == RAID_CAPITAL
		Return 3
	EndIf
	Return 0

EndFunction

int Function GetRaidForceCleanupIntervalMultiplier(int aiRaidType)

	If aiRaidType == RAID_SMALL || aiRaidType == RAID_SERVICE || aiRaidType == RAID_PILLAGE
		Return 1
	ElseIf aiRaidType == RAID_TOWN || aiRaidType == RAID_GATE || aiRaidType == RAID_MEDIUM
		Return 2
	ElseIf aiRaidType == RAID_MINOR_CAPITAL || aiRaidType == RAID_CAPITAL
		Return 3
	EndIf
	Return 0

EndFunction

int Function GetRaidCooldownIntervalsForType(int aiRaidType)

	int baseIntervals = GetDraugnarokCooldownIntervals()
	int multiplier = GetRaidCooldownIntervalMultiplier(aiRaidType)
	If baseIntervals <= 0 || multiplier <= 0
		Return 0
	EndIf
	Return baseIntervals * multiplier

EndFunction

int Function GetRaidForceCleanupIntervalsForType(int aiRaidType)

	int baseIntervals = GetDraugnarokForceCleanupIntervals()
	int multiplier = GetRaidForceCleanupIntervalMultiplier(aiRaidType)
	If baseIntervals <= 0 || multiplier <= 0
		Return 0
	EndIf
	Return baseIntervals * multiplier

EndFunction

float Function GetRaidCooldownWindowHours(int aiRaidType)

	Return GetDraugnarokIntervalWindowHours(GetRaidCooldownIntervalsForType(aiRaidType))

EndFunction

float Function GetPillageFactionTargetWindowHours()

	float hours = GetRaidCooldownWindowHours(RAID_PILLAGE)
	If hours <= 0.0
		hours = GetDraugnarokBaseIntervalHours() as float
	EndIf
	If hours < 1.0
		Return 1.0
	EndIf
	Return hours

EndFunction

Function EnsurePillageFactionTargetTracker()

	If !PillageFactionTargets || PillageFactionTargets.Length != PILLAGE_TARGET_TRACKER_CAPACITY
		PillageFactionTargets = new Actor[64]
		PillageFactionTargetMarkedAt = new Float[64]
	EndIf

EndFunction

int Function FindPillageFactionTargetSlot(Actor akTarget)

	If !akTarget
		Return -1
	EndIf

	EnsurePillageFactionTargetTracker()
	int i = 0
	While i < PILLAGE_TARGET_TRACKER_CAPACITY
		If PillageFactionTargets[i] == akTarget
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1

EndFunction

int Function FindEmptyPillageFactionTargetSlot()

	EnsurePillageFactionTargetTracker()
	int i = 0
	While i < PILLAGE_TARGET_TRACKER_CAPACITY
		If !PillageFactionTargets[i]
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1

EndFunction

int Function FindOldestPillageFactionTargetSlot()

	EnsurePillageFactionTargetTracker()
	int oldestSlot = -1
	float oldestTime = 0.0
	int i = 0
	While i < PILLAGE_TARGET_TRACKER_CAPACITY
		If PillageFactionTargets[i] && (oldestSlot < 0 || PillageFactionTargetMarkedAt[i] < oldestTime)
			oldestSlot = i
			oldestTime = PillageFactionTargetMarkedAt[i]
		EndIf
		i += 1
	EndWhile
	Return oldestSlot

EndFunction

Function TrackPillageFactionTarget(Actor akTarget)

	If !akTarget
		Return
	EndIf

	EnsurePillageFactionTargetTracker()
	CleanupPillageFactionTargets(False)
	int slot = FindPillageFactionTargetSlot(akTarget)
	If slot < 0
		slot = FindEmptyPillageFactionTargetSlot()
	EndIf
	If slot < 0
		slot = FindOldestPillageFactionTargetSlot()
		If slot >= 0
			ClearPillageFactionTargetSlot(slot, "tracker full")
		EndIf
	EndIf
	If slot < 0
		LogError("Pillage target tracker is full; could not track faction cleanup for '" + akTarget.GetBaseObject().GetName() + "'.")
		Return
	EndIf

	PillageFactionTargets[slot] = akTarget
	PillageFactionTargetMarkedAt[slot] = Utility.GetCurrentGameTime()
	LogDebug("Tracked pillage target faction mark for '" + akTarget.GetBaseObject().GetName() + "' for up to " + GetPillageFactionTargetWindowHours() + " hours.")

EndFunction

Function ClearPillageFactionTarget(Actor akTarget, string asReason = "cleanup")

	int slot = FindPillageFactionTargetSlot(akTarget)
	If slot >= 0
		ClearPillageFactionTargetSlot(slot, asReason)
	EndIf

EndFunction

Function ClearPillageFactionTargetSlot(int aiSlot, string asReason = "cleanup")

	If aiSlot < 0 || aiSlot >= PILLAGE_TARGET_TRACKER_CAPACITY
		Return
	EndIf
	EnsurePillageFactionTargetTracker()

	Actor target = PillageFactionTargets[aiSlot]
	If target && FactionDraugrTarget && target.IsInFaction(FactionDraugrTarget)
		target.RemoveFromFaction(FactionDraugrTarget)
		LogDebug("Removed pillage target faction mark from '" + target.GetBaseObject().GetName() + "'. reason=" + asReason)
	EndIf
	PillageFactionTargets[aiSlot] = None
	PillageFactionTargetMarkedAt[aiSlot] = 0.0

EndFunction

Function CleanupPillageFactionTargets(bool abForce = False)

	EnsurePillageFactionTargetTracker()
	float now = Utility.GetCurrentGameTime()
	float windowDays = GetPillageFactionTargetWindowHours() / 24.0
	int i = 0
	While i < PILLAGE_TARGET_TRACKER_CAPACITY
		If PillageFactionTargets[i]
			If abForce || PillageFactionTargetMarkedAt[i] <= 0.0 || PillageFactionTargetMarkedAt[i] > now || (now - PillageFactionTargetMarkedAt[i]) >= windowDays
				ClearPillageFactionTargetSlot(i, "expired-or-forced")
			EndIf
		EndIf
		i += 1
	EndWhile

EndFunction

Function EnsureRaidCooldownTracker()

	If !RaidCooldownKeys || RaidCooldownKeys.Length != RAID_COOLDOWN_TRACKER_CAPACITY
		RaidCooldownKeys = new String[128]
		RaidCooldownStartedAt = new Float[128]
	EndIf

EndFunction

string Function GetRaidCooldownKey(int aiRaidType, string asTargetKey)

	If asTargetKey == ""
		Return ""
	EndIf
	Return "" + aiRaidType + "|" + asTargetKey

EndFunction

int Function FindRaidCooldownSlot(string asKey)

	If asKey == ""
		Return -1
	EndIf

	EnsureRaidCooldownTracker()
	int i = 0
	While i < RAID_COOLDOWN_TRACKER_CAPACITY
		If RaidCooldownKeys[i] == asKey
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1

EndFunction

int Function FindEmptyRaidCooldownSlot()

	EnsureRaidCooldownTracker()
	int i = 0
	While i < RAID_COOLDOWN_TRACKER_CAPACITY
		If RaidCooldownKeys[i] == ""
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1

EndFunction

bool Function RecordRaidCooldown(int aiRaidType, string asTargetKey)

	If GetRaidCooldownIntervalsForType(aiRaidType) <= 0 || asTargetKey == ""
		Return False
	EndIf

	string cooldownKey = GetRaidCooldownKey(aiRaidType, asTargetKey)
	int slot = FindRaidCooldownSlot(cooldownKey)
	If slot < 0
		slot = FindEmptyRaidCooldownSlot()
	EndIf
	If slot < 0
		LogError("Raid cooldown tracker is full; could not track '" + cooldownKey + "'.")
		Return False
	EndIf

	RaidCooldownKeys[slot] = cooldownKey
	RaidCooldownStartedAt[slot] = Utility.GetCurrentGameTime()
	LogDebug("Recorded raid cooldown " + cooldownKey + " for " + GetRaidCooldownIntervalsForType(aiRaidType) + " assault intervals.")
	Return True

EndFunction

bool Function IsRaidCooldownActive(int aiRaidType, string asTargetKey)

	float cooldownHours = GetRaidCooldownWindowHours(aiRaidType)
	If cooldownHours <= 0.0 || asTargetKey == ""
		Return False
	EndIf

	int slot = FindRaidCooldownSlot(GetRaidCooldownKey(aiRaidType, asTargetKey))
	If slot < 0
		Return False
	EndIf

	float now = Utility.GetCurrentGameTime()
	float startedAt = RaidCooldownStartedAt[slot]
	If startedAt <= 0.0 || startedAt > now
		RaidCooldownStartedAt[slot] = now
		Return True
	EndIf

	float ageHours = (now - startedAt) * 24.0
	Return ageHours < cooldownHours

EndFunction

string Function GetQuestCooldownTargetKey(Quest q, int aiRaidType)

	If !q
		Return ""
	EndIf

	string questName = q.GetName()
	If aiRaidType == RAID_MEDIUM || aiRaidType == RAID_ROAMING_MOB
		Return questName
	EndIf

	string placeName = GetRaidPlaceName(questName)
	If placeName != ""
		Return placeName
	EndIf
	Return questName

EndFunction

bool Function IsQuestBlockedByRaidCooldown(Quest q, int aiRaidType, string asGateCooldownBypassPlace = "")

	string targetKey = GetQuestCooldownTargetKey(q, aiRaidType)
	If targetKey == ""
		Return False
	EndIf

	If !(aiRaidType == RAID_GATE && asGateCooldownBypassPlace != "" && targetKey == asGateCooldownBypassPlace) && IsRaidCooldownActive(aiRaidType, targetKey)
		Return True
	EndIf

	If aiRaidType == RAID_GATE && IsRaidCooldownActive(RAID_CAPITAL, targetKey)
		Return True
	EndIf
	Return False

EndFunction

bool Function IsQuestEligibleForRaid(Quest q, int aiRaidType, string asRequiredPlace = "", bool abRecordObservation = True, string asGateCooldownBypassPlace = "")

	If !q
		Return False
	EndIf

	string targetKey = GetQuestCooldownTargetKey(q, aiRaidType)
	If asRequiredPlace != "" && targetKey != asRequiredPlace
		Return False
	EndIf

	If q.IsRunning()
		Return False
	EndIf

	Return !IsQuestBlockedByRaidCooldown(q, aiRaidType, asGateCooldownBypassPlace)

EndFunction

int Function CountEligibleRaidQuests(Quest[] akArray, int aiRaidType, string asRequiredPlace = "", bool abRecordObservation = True, string asGateCooldownBypassPlace = "")

	If !akArray || akArray.Length < 1
		Return 0
	EndIf

	int count = 0
	int i = 0
	While i < akArray.Length
		If IsQuestEligibleForRaid(akArray[i], aiRaidType, asRequiredPlace, abRecordObservation, asGateCooldownBypassPlace)
			count += 1
		EndIf
		i += 1
	EndWhile
	Return count

EndFunction

int Function CountPresentQuests(Quest[] akArray)

	If !akArray || akArray.Length < 1
		Return 0
	EndIf

	int count = 0
	int i = 0
	While i < akArray.Length
		If akArray[i]
			count += 1
		EndIf
		i += 1
	EndWhile
	Return count

EndFunction

Quest Function GetRandomPresentQuest(Quest[] akArray)

	int presentCount = CountPresentQuests(akArray)
	If presentCount < 1
		Return None
	EndIf

	int pick = Utility.RandomInt(1, presentCount)
	int seen = 0
	int i = 0
	While i < akArray.Length
		If akArray[i]
			seen += 1
			If seen == pick
				Return akArray[i]
			EndIf
		EndIf
		i += 1
	EndWhile
	Return None

EndFunction

int Function CountEligibleRaidQuestsExceptPlace(Quest[] akArray, int aiRaidType, string asExcludedPlace, bool abRecordObservation = True)

	If !akArray || akArray.Length < 1
		Return 0
	EndIf

	int count = 0
	int i = 0
	While i < akArray.Length
		If GetQuestCooldownTargetKey(akArray[i], aiRaidType) != asExcludedPlace && IsQuestEligibleForRaid(akArray[i], aiRaidType, "", abRecordObservation)
			count += 1
		EndIf
		i += 1
	EndWhile
	Return count

EndFunction

Quest Function GetRandomEligibleRaidQuest(Quest[] akArray, int aiRaidType, string asRequiredPlace = "", string asGateCooldownBypassPlace = "")

	int eligibleCount = CountEligibleRaidQuests(akArray, aiRaidType, asRequiredPlace, True, asGateCooldownBypassPlace)
	If eligibleCount < 1
		Return None
	EndIf

	int pick = Utility.RandomInt(1, eligibleCount)
	int seen = 0
	int i = 0
	While i < akArray.Length
		If IsQuestEligibleForRaid(akArray[i], aiRaidType, asRequiredPlace, True, asGateCooldownBypassPlace)
			seen += 1
			If seen == pick
				Return akArray[i]
			EndIf
		EndIf
		i += 1
	EndWhile
	Return None

EndFunction

Quest Function GetRandomEligibleRaidQuestExceptPlace(Quest[] akArray, int aiRaidType, string asExcludedPlace)

	int eligibleCount = CountEligibleRaidQuestsExceptPlace(akArray, aiRaidType, asExcludedPlace)
	If eligibleCount < 1
		Return None
	EndIf

	int pick = Utility.RandomInt(1, eligibleCount)
	int seen = 0
	int i = 0
	While i < akArray.Length
		If GetQuestCooldownTargetKey(akArray[i], aiRaidType) != asExcludedPlace && IsQuestEligibleForRaid(akArray[i], aiRaidType)
			seen += 1
			If seen == pick
				Return akArray[i]
			EndIf
		EndIf
		i += 1
	EndWhile
	Return None

EndFunction

bool Function DeployRandomEligibleFromArray(Quest[] akArray, string asCategory, int aiRaidType, string asRequiredPlace = "", bool abReset = False, string asGateCooldownBypassPlace = "")

	If !akArray || akArray.Length < 1
		LogError("Missing attack array for selected category: " + asCategory)
		Return False
	EndIf

	Quest q = GetRandomEligibleRaidQuest(akArray, aiRaidType, asRequiredPlace, asGateCooldownBypassPlace)
	If !q
		LogDebug("No eligible " + asCategory + " targets.")
		Return False
	EndIf

	LogDebug("Deploying eligible " + asCategory + " '" + q.GetName() + "'")
	Return DeploySquad(q, abReset, aiRaidType)

EndFunction

Function ClearGateCapitalTarget()

	GateCapitalTargetPlace = ""
	GateCapitalTargetPulsesRemaining = 0
	GateCapitalTargetPressureCount = 0
	GateCapitalTargetSetDuringPulse = False

EndFunction

bool Function IsGateTargetingEnabled()

	If !IronSoulNative.IsAvailable()
		Return False
	EndIf
	Return GetDraugnarokGatePressureIntervals() > 0 && IsRaidCategoryEnabled(RAID_GATE) && IsRaidCategoryEnabled(RAID_CAPITAL)

EndFunction

bool Function IsGateCapitalTargetActive()

	Return IsGateTargetingEnabled() && GateCapitalTargetPlace != "" && GateCapitalTargetPulsesRemaining > 0

EndFunction

string Function GetActiveGateCapitalTargetPlace()

	If IsGateCapitalTargetActive()
		Return GateCapitalTargetPlace
	EndIf
	Return ""

EndFunction

int Function GetGateCapitalTargetPressureCount()

	If !IsGateCapitalTargetActive()
		Return 0
	EndIf

	If GateCapitalTargetPressureCount < 1
		Return 1
	EndIf
	Return GateCapitalTargetPressureCount

EndFunction

int Function GetGateCapitalTargetCapitalMultiplier()

	If GetGateCapitalTargetPressureCount() >= 2
		Return 10
	ElseIf IsGateCapitalTargetActive()
		Return 2
	EndIf
	Return 1

EndFunction

Function SetGateCapitalTarget(string asPlaceName)

	int targetIntervals = GetDraugnarokGatePressureIntervals()
	If !IsGateTargetingEnabled()
		ClearGateCapitalTarget()
		Return
	EndIf

	If !IsCapitalRaidPlace(asPlaceName)
		Return
	EndIf

	If IsGateCapitalTargetActive() && GateCapitalTargetPlace == asPlaceName
		GateCapitalTargetPressureCount = GetGateCapitalTargetPressureCount() + 1
		If GateCapitalTargetPressureCount > 2
			GateCapitalTargetPressureCount = 2
		EndIf
	Else
		GateCapitalTargetPressureCount = 1
	EndIf

	GateCapitalTargetPlace = asPlaceName
	GateCapitalTargetPulsesRemaining = targetIntervals
	If DraugnarokPulseRunning
		GateCapitalTargetSetDuringPulse = True
	EndIf
	LogInfo("Gate breach targets " + asPlaceName + " for " + targetIntervals + " assault intervals; capital raid pressure x" + GetGateCapitalTargetCapitalMultiplier() + ".", True)

EndFunction

Function DecrementGateCapitalTargetPulse()

	If !IsGateCapitalTargetActive()
		Return
	EndIf

	GateCapitalTargetPulsesRemaining -= 1
	If GateCapitalTargetPulsesRemaining <= 0
		LogInfo("Gate breach target expired for " + GateCapitalTargetPlace + ".", True)
		GateCapitalTargetPlace = ""
		GateCapitalTargetPulsesRemaining = 0
		GateCapitalTargetPressureCount = 0
	EndIf

EndFunction

Function FinishDraugnarokPulse()

	If GateCapitalTargetSetDuringPulse
		GateCapitalTargetSetDuringPulse = False
	Else
		DecrementGateCapitalTargetPulse()
	EndIf
	DraugnarokPulseRunning = False

EndFunction

int Function GetAdjustedCapitalRaidWeight(int aiCapitalWeight)

	If aiCapitalWeight < 1 || !IsGateTargetingEnabled()
		Return aiCapitalWeight
	EndIf

	If IsGateCapitalTargetActive()
		Return aiCapitalWeight * GetGateCapitalTargetCapitalMultiplier()
	EndIf
	Return Math.Floor((aiCapitalWeight as float) / 2.0)

EndFunction

int Function CountEligibleGateCrashersForCurrentPressure(bool abRecordObservation = True)

	string activeTarget = GetActiveGateCapitalTargetPlace()
	If activeTarget == ""
		Return CountEligibleRaidQuests(GateCrashers, RAID_GATE, "", abRecordObservation)
	EndIf
	Return CountEligibleRaidQuests(GateCrashers, RAID_GATE, activeTarget, abRecordObservation, activeTarget) + CountEligibleRaidQuestsExceptPlace(GateCrashers, RAID_GATE, activeTarget, abRecordObservation)

EndFunction

bool Function DeployTargetBiasedGateCrashers()

	string activeTarget = GetActiveGateCapitalTargetPlace()
	If activeTarget == ""
		Return DeployRandomEligibleFromArray(GateCrashers, "gate crasher raid", RAID_GATE, "", False)
	EndIf

	int targetCount = CountEligibleRaidQuests(GateCrashers, RAID_GATE, activeTarget, True, activeTarget)
	int otherCount = CountEligibleRaidQuestsExceptPlace(GateCrashers, RAID_GATE, activeTarget)
	bool chooseTarget = Utility.RandomInt(0, 1) == 0

	If targetCount > 0 && (chooseTarget || otherCount < 1)
		LogDebug("Gate pressure selected active target '" + activeTarget + "'.")
		Return DeployRandomEligibleFromArray(GateCrashers, "gate crasher raid", RAID_GATE, activeTarget, False, activeTarget)
	EndIf

	If otherCount > 0
		Quest q = GetRandomEligibleRaidQuestExceptPlace(GateCrashers, RAID_GATE, activeTarget)
		If q
			LogDebug("Gate pressure selected other city '" + GetQuestCooldownTargetKey(q, RAID_GATE) + "'.")
			Return DeploySquad(q, False, RAID_GATE)
		EndIf
	EndIf

	If targetCount > 0
		LogDebug("Gate pressure fallback selected active target '" + activeTarget + "'.")
		Return DeployRandomEligibleFromArray(GateCrashers, "gate crasher raid", RAID_GATE, activeTarget, False, activeTarget)
	EndIf

	LogDebug("No eligible gate crasher raid targets.")
	Return False

EndFunction

int Function GetSquadRaidType(int aiSquad)

	If aiSquad > 300
		Return 0
	ElseIf aiSquad > 200
		Return RAID_MEDIUM
	ElseIf aiSquad > 120
		Return RAID_SERVICE
	ElseIf aiSquad > 100
		Return RAID_SMALL
	EndIf
	Return 0

EndFunction

string Function GetSquadSubjectName(string asName, Location akDestination, Actor akTarget = None)

	string targetName = ""
	If akTarget
		targetName = akTarget.GetBaseObject().GetName()
	EndIf

	string destinationName = ""
	If akDestination
		destinationName = akDestination.GetName()
	EndIf

	If targetName != "" && destinationName != ""
		Return targetName + " at " + destinationName
	ElseIf targetName != ""
		Return targetName
	ElseIf destinationName != ""
		Return destinationName
	EndIf

	string placeName = GetRaidPlaceName(asName)
	If placeName != ""
		Return placeName
	EndIf
	Return asName

EndFunction

string Function GetSquadJournalEntry(int aiRaidType, string asName, Location akDestination, Actor akTarget = None)

	string subjectName = GetSquadSubjectName(asName, akDestination, akTarget)
	If subjectName == ""
		Return ""
	EndIf

	If aiRaidType == RAID_SMALL
		Return "A draugr band struck " + subjectName + "."
	ElseIf aiRaidType == RAID_SERVICE
		Return "Draugr stalkers hunted " + subjectName + "."
	ElseIf aiRaidType == RAID_MEDIUM
		Return "A draugr death squad attacked " + subjectName + "."
	EndIf
	Return "Draugr attacked " + subjectName + "."

EndFunction

string Function GetSquadNotificationEntry(int aiRaidType, string asName, Location akDestination, Actor akTarget = None)

	string subjectName = GetSquadSubjectName(asName, akDestination, akTarget)
	If subjectName == ""
		Return ""
	EndIf

	If aiRaidType == RAID_SMALL
		Return "A draugr band strikes " + subjectName
	ElseIf aiRaidType == RAID_SERVICE
		Return "Draugr stalkers hunt " + subjectName
	ElseIf aiRaidType == RAID_MEDIUM
		Return "A draugr death squad attacks " + subjectName
	EndIf
	Return "Draugr attack " + subjectName

EndFunction

string Function GetRaidCategoryConfigKey(int aiRaidType)

	If aiRaidType == RAID_SMALL
		Return "RaidSmall"
	ElseIf aiRaidType == RAID_SERVICE
		Return "RaidService"
	ElseIf aiRaidType == RAID_TOWN
		Return "RaidTown"
	ElseIf aiRaidType == RAID_MEDIUM
		Return "RaidMedium"
	ElseIf aiRaidType == RAID_PILLAGE
		Return "RaidPillage"
	ElseIf aiRaidType == RAID_MINOR_CAPITAL
		Return "RaidMinorCapital"
	ElseIf aiRaidType == RAID_GATE
		Return "RaidGate"
	ElseIf aiRaidType == RAID_CAPITAL
		Return "RaidCapital"
	EndIf

	Return ""

EndFunction

bool Function IsRaidCategoryEnabled(int aiRaidType)

	string configKey = GetRaidCategoryConfigKey(aiRaidType)
	If configKey == ""
		Return True
	EndIf
	Return IsConfigEnabled(configKey, 1)

EndFunction

string Function AppendEnabledCategory(string asEnabled, string asName, int aiRaidType)

	If !IsRaidCategoryEnabled(aiRaidType)
		Return asEnabled
	EndIf

	If asEnabled == ""
		Return asName
	EndIf
	Return asEnabled + ", " + asName

EndFunction

string Function FormatWeightChanceValue(int aiWeight)

	If aiWeight < 0
		aiWeight = 0
	ElseIf aiWeight > WEIGHT_TOTAL
		aiWeight = WEIGHT_TOTAL
	EndIf

	int tenths = Math.Floor((aiWeight as float) / 100.0)
	int whole = Math.Floor((tenths as float) / 10.0)
	int fraction = tenths - (whole * 10)
	string fractionText = "" + fraction

	Return whole + "." + fractionText

EndFunction

string Function FormatRaidChance(int aiRaidChanceWeight, int aiEnabledRaidWeight, int aiEnabledAttackWeight)

	If aiRaidChanceWeight < 1 || aiEnabledRaidWeight < 1 || aiEnabledAttackWeight < 1
		Return FormatWeightChanceValue(0)
	EndIf

	int chanceWeight = Math.Floor((aiRaidChanceWeight as float) * (aiEnabledRaidWeight as float) / (aiEnabledAttackWeight as float))
	Return FormatWeightChanceValue(chanceWeight)

EndFunction

string Function GetAlduinQuestStageSummary()

	Return "MQ101=" + GetQuestStageLabel(MQ101) + " | MQ102=" + GetQuestStageLabel(MQ102) + " | MQ305=" + GetQuestStageLabel(MQ305)

EndFunction

string Function GetQuestStageLabel(Quest akQuest)

	If akQuest
		Return "" + akQuest.GetStage()
	EndIf
	Return "none"

EndFunction

string Function GetDraugnarokOverrideLabel(int aiMode)

	If aiMode == OVERRIDE_FORCE_ON
		Return "ForceOn"
	ElseIf aiMode == OVERRIDE_FORCE_OFF
		Return "ForceOff"
	EndIf
	Return ""

EndFunction

string Function GetDraugnarokJournalLabel(int aiQuestStage)

	If ShouldDisplayDraugnarokObjective(aiQuestStage)
		Return "Shown"
	EndIf
	Return "Hidden"

EndFunction

string Function GetDraugnarokStatusLabel(int aiOverrideMode, int aiThreat)

	If !IsDraugnarokSystemEnabled() || aiOverrideMode == OVERRIDE_FORCE_OFF || aiThreat < 0
		Return "Disabled"
	EndIf
	If aiOverrideMode != OVERRIDE_FORCE_ON
		If IsAlduinDefeated()
			Return "Disabled"
		EndIf
		If !IsAlduinLooseForDraugnarok()
			Return "Dormant"
		EndIf
	EndIf
	Return "Active"

EndFunction

string Function GetAlduinGateStatus(int aiOverrideMode)

	If !IsDraugnarokSystemEnabled()
		Return "Disabled"
	EndIf
	If IsAlduinDefeated()
		Return "Defeated"
	EndIf
	If aiOverrideMode == OVERRIDE_FORCE_ON
		Return "ForcedOpen"
	EndIf
	If IsAlduinLooseForDraugnarok()
		Return "Open"
	EndIf
	Return "Waiting"

EndFunction

string Function GetGateTargetSummary()

	Return "GateTarget | Place=" + GateCapitalTargetPlace + " | PulsesRemaining=" + GateCapitalTargetPulsesRemaining + " | CapitalMultiplier=" + GetGateCapitalTargetCapitalMultiplier()

EndFunction

Function ClearRaidChanceCalculation()

	RaidChanceCalculationReady = False
	CalculatedRaidChanceSummary = ""
	CalculatedActiveCapitalTarget = ""
	CalculatedRaidChanceWeight = 0
	CalculatedAvailableWeight = 0
	CalculatedAvailableSmallWeight = 0
	CalculatedAvailableServiceWeight = 0
	CalculatedAvailableTownWeight = 0
	CalculatedAvailableMediumWeight = 0
	CalculatedAvailablePillageWeight = 0
	CalculatedAvailableMinorCapitalWeight = 0
	CalculatedAvailableGateWeight = 0
	CalculatedAvailableCapitalWeight = 0

EndFunction

Function SetRaidChanceCalculation(int aiRaidChanceWeight, int aiAvailableWeight, int aiSmallWeight, int aiServiceWeight, int aiTownWeight, int aiMediumWeight, int aiPillageWeight, int aiMinorCapitalWeight, int aiGateWeight, int aiCapitalWeight, string asActiveCapitalTarget)

	CalculatedRaidChanceWeight = aiRaidChanceWeight
	CalculatedAvailableWeight = aiAvailableWeight
	CalculatedAvailableSmallWeight = aiSmallWeight
	CalculatedAvailableServiceWeight = aiServiceWeight
	CalculatedAvailableTownWeight = aiTownWeight
	CalculatedAvailableMediumWeight = aiMediumWeight
	CalculatedAvailablePillageWeight = aiPillageWeight
	CalculatedAvailableMinorCapitalWeight = aiMinorCapitalWeight
	CalculatedAvailableGateWeight = aiGateWeight
	CalculatedAvailableCapitalWeight = aiCapitalWeight
	CalculatedActiveCapitalTarget = asActiveCapitalTarget
	CalculatedRaidChanceSummary = "Raids | TotalChance=" + FormatWeightChanceValue(aiRaidChanceWeight) + " | Small=" + FormatRaidChance(aiRaidChanceWeight, aiSmallWeight, aiAvailableWeight) + " | Service=" + FormatRaidChance(aiRaidChanceWeight, aiServiceWeight, aiAvailableWeight) + " | Town=" + FormatRaidChance(aiRaidChanceWeight, aiTownWeight, aiAvailableWeight) + " | Medium=" + FormatRaidChance(aiRaidChanceWeight, aiMediumWeight, aiAvailableWeight)
	CalculatedRaidChanceSummary = CalculatedRaidChanceSummary + " | Pillage=" + FormatRaidChance(aiRaidChanceWeight, aiPillageWeight, aiAvailableWeight) + " | MinorCapital=" + FormatRaidChance(aiRaidChanceWeight, aiMinorCapitalWeight, aiAvailableWeight) + " | Gate=" + FormatRaidChance(aiRaidChanceWeight, aiGateWeight, aiAvailableWeight) + " | Capital=" + FormatRaidChance(aiRaidChanceWeight, aiCapitalWeight, aiAvailableWeight)
	RaidChanceCalculationReady = True

EndFunction

Function StoreLastPulseRaidChanceSummary()

	If RaidChanceCalculationReady && CalculatedRaidChanceSummary != ""
		LastPulseRaidChanceSummary = CalculatedRaidChanceSummary
		LastPulseRaidChanceReady = True
	EndIf

EndFunction

string Function GetLastPulseRaidChanceSummary()

	If LastPulseRaidChanceReady && LastPulseRaidChanceSummary != ""
		Return LastPulseRaidChanceSummary
	EndIf
	Return "Raids | Cache=Pending"

EndFunction

string Function GetCalculatedRaidChanceSummary()

	If RaidChanceCalculationReady && CalculatedRaidChanceSummary != ""
		Return CalculatedRaidChanceSummary
	EndIf
	Return "Raids | Cache=Pending"

EndFunction

bool Function CalculateRaidChanceForCurrentState(bool abRecordObservation = False)

	If !IronSoulNative.IsAvailable()
		ClearRaidChanceCalculation()
		Return False
	EndIf
	If !IsDraugnarokSystemEnabled()
		ClearRaidChanceCalculation()
		SetRaidChanceCalculation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, GetActiveGateCapitalTargetPlace())
		Return False
	EndIf
	Return CalculateRaidChance(GetDraugrThreatLevel(), abRecordObservation)

EndFunction

string Function GetCurrentRaidChanceSummary()

	CalculateRaidChanceForCurrentState(False)
	Return GetCalculatedRaidChanceSummary()

EndFunction

bool Function CalculateRaidChance(int aiThreat, bool abRecordObservation = True)

	ClearRaidChanceCalculation()

	string activeCapitalTarget = GetActiveGateCapitalTargetPlace()
	If aiThreat < 0
		SetRaidChanceCalculation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, activeCapitalTarget)
		Return False
	EndIf

	int level = GetPlayerLevel()
	int smallWeight = ScaleWeight(GetBaseAttackWeight(aiThreat, RAID_SMALL), GetEffectiveLevelMultiplier(aiThreat, level, RAID_SMALL))
	int serviceWeight = ScaleWeight(GetBaseAttackWeight(aiThreat, RAID_SERVICE), GetEffectiveLevelMultiplier(aiThreat, level, RAID_SERVICE))
	int townWeight = ScaleWeight(GetBaseAttackWeight(aiThreat, RAID_TOWN), GetEffectiveLevelMultiplier(aiThreat, level, RAID_TOWN))
	int mediumWeight = ScaleWeight(GetBaseAttackWeight(aiThreat, RAID_MEDIUM), GetEffectiveLevelMultiplier(aiThreat, level, RAID_MEDIUM))
	int pillageWeight = ScaleWeight(GetBaseAttackWeight(aiThreat, RAID_PILLAGE), GetEffectiveLevelMultiplier(aiThreat, level, RAID_PILLAGE))
	int minorCapitalWeight = ScaleWeight(GetBaseAttackWeight(aiThreat, RAID_MINOR_CAPITAL), GetEffectiveLevelMultiplier(aiThreat, level, RAID_MINOR_CAPITAL))
	int gateWeight = ScaleWeight(GetBaseAttackWeight(aiThreat, RAID_GATE), GetEffectiveLevelMultiplier(aiThreat, level, RAID_GATE))
	int capitalWeight = GetAdjustedCapitalRaidWeight(ScaleWeight(GetBaseAttackWeight(aiThreat, RAID_CAPITAL), GetEffectiveLevelMultiplier(aiThreat, level, RAID_CAPITAL)))
	int rawAttackWeight = smallWeight + serviceWeight + townWeight + mediumWeight + pillageWeight + minorCapitalWeight + gateWeight + capitalWeight
	If abRecordObservation
		LogDebug("Pulse weights level=" + level + " threat=" + aiThreat + " rawAttack=" + rawAttackWeight + " small=" + smallWeight + " service=" + serviceWeight + " town=" + townWeight + " medium=" + mediumWeight + " pillage=" + pillageWeight + " minorCapital=" + minorCapitalWeight + " gate=" + gateWeight + " capital=" + capitalWeight)
	EndIf
	If rawAttackWeight < 1
		If abRecordObservation
			LogDebug("No attack: total attack weight below 1.")
		EndIf
		SetRaidChanceCalculation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, activeCapitalTarget)
		Return False
	EndIf

	int configuredSmallWeight = smallWeight
	If !IsRaidCategoryEnabled(RAID_SMALL)
		configuredSmallWeight = 0
	EndIf
	int configuredServiceWeight = serviceWeight
	If !IsRaidCategoryEnabled(RAID_SERVICE)
		configuredServiceWeight = 0
	EndIf
	int configuredTownWeight = townWeight
	If !IsRaidCategoryEnabled(RAID_TOWN)
		configuredTownWeight = 0
	EndIf
	int configuredMediumWeight = mediumWeight
	If !IsRaidCategoryEnabled(RAID_MEDIUM)
		configuredMediumWeight = 0
	EndIf
	int configuredPillageWeight = pillageWeight
	If !IsRaidCategoryEnabled(RAID_PILLAGE)
		configuredPillageWeight = 0
	EndIf
	int configuredMinorCapitalWeight = minorCapitalWeight
	If !IsRaidCategoryEnabled(RAID_MINOR_CAPITAL)
		configuredMinorCapitalWeight = 0
	EndIf
	int configuredGateWeight = gateWeight
	If !IsRaidCategoryEnabled(RAID_GATE)
		configuredGateWeight = 0
	EndIf
	int configuredCapitalWeight = capitalWeight
	If !IsRaidCategoryEnabled(RAID_CAPITAL)
		configuredCapitalWeight = 0
	EndIf
	int configuredWeight = configuredSmallWeight + configuredServiceWeight + configuredTownWeight + configuredMediumWeight + configuredPillageWeight + configuredMinorCapitalWeight + configuredGateWeight + configuredCapitalWeight

	int availableSmallWeight = configuredSmallWeight
	If availableSmallWeight > 0 && CountEligibleRaidQuests(DeathSquads_Small, RAID_SMALL, "", abRecordObservation) < 1
		availableSmallWeight = 0
	EndIf
	int availableServiceWeight = configuredServiceWeight
	If availableServiceWeight > 0 && CountEligibleRaidQuests(DeathSquads_Services, RAID_SERVICE, "", abRecordObservation) < 1
		availableServiceWeight = 0
	EndIf
	int availableTownWeight = configuredTownWeight
	If availableTownWeight > 0 && CountEligibleRaidQuests(TownRaids, RAID_TOWN, "", abRecordObservation) < 1
		availableTownWeight = 0
	EndIf
	int availableMediumWeight = configuredMediumWeight
	If availableMediumWeight > 0 && CountEligibleRaidQuests(DeathSquads_Medium, RAID_MEDIUM, "", abRecordObservation) < 1
		availableMediumWeight = 0
	EndIf
	int availablePillageWeight = configuredPillageWeight
	If availablePillageWeight > 0 && CountEligibleRaidQuests(PillageSquads, RAID_PILLAGE, "", abRecordObservation) < 1
		availablePillageWeight = 0
	EndIf
	int availableMinorCapitalWeight = configuredMinorCapitalWeight
	If availableMinorCapitalWeight > 0 && CountEligibleRaidQuests(MinorCapitalRaids, RAID_MINOR_CAPITAL, "", abRecordObservation) < 1
		availableMinorCapitalWeight = 0
	EndIf
	int availableGateWeight = configuredGateWeight
	If availableGateWeight > 0 && CountEligibleGateCrashersForCurrentPressure(abRecordObservation) < 1
		availableGateWeight = 0
	EndIf
	int availableCapitalWeight = configuredCapitalWeight
	If availableCapitalWeight > 0 && CountEligibleRaidQuests(CapitalRaids, RAID_CAPITAL, activeCapitalTarget, abRecordObservation) < 1
		availableCapitalWeight = 0
	EndIf
	int availableWeight = availableSmallWeight + availableServiceWeight + availableTownWeight + availableMediumWeight + availablePillageWeight + availableMinorCapitalWeight + availableGateWeight + availableCapitalWeight

	If configuredWeight < 1 || availableWeight < 1
		If abRecordObservation
			LogDebug("No attack: configuredWeight=" + configuredWeight + " availableWeight=" + availableWeight)
		EndIf
		SetRaidChanceCalculation(0, availableWeight, availableSmallWeight, availableServiceWeight, availableTownWeight, availableMediumWeight, availablePillageWeight, availableMinorCapitalWeight, availableGateWeight, availableCapitalWeight, activeCapitalTarget)
		Return False
	EndIf

	int disabledWeight = rawAttackWeight - configuredWeight
	If disabledWeight < 0
		disabledWeight = 0
	EndIf
	int retainedDisabledWeight = Math.Floor((disabledWeight as float) / 2.0)
	int unavailableWeight = configuredWeight - availableWeight
	If unavailableWeight < 0
		unavailableWeight = 0
	EndIf
	int raidChanceWeight = configuredWeight + retainedDisabledWeight - unavailableWeight
	If raidChanceWeight < 0
		raidChanceWeight = 0
	ElseIf raidChanceWeight > WEIGHT_TOTAL
		raidChanceWeight = WEIGHT_TOTAL
	EndIf
	If abRecordObservation
		LogDebug("Pulse available weights configured=" + configuredWeight + " available=" + availableWeight + " disabled=" + disabledWeight + " retainedDisabled=" + retainedDisabledWeight + " unavailable=" + unavailableWeight + " raidChance=" + raidChanceWeight + " small=" + availableSmallWeight + " service=" + availableServiceWeight + " town=" + availableTownWeight + " medium=" + availableMediumWeight + " pillage=" + availablePillageWeight + " minorCapital=" + availableMinorCapitalWeight + " gate=" + availableGateWeight + " capital=" + availableCapitalWeight)
	EndIf

	SetRaidChanceCalculation(raidChanceWeight, availableWeight, availableSmallWeight, availableServiceWeight, availableTownWeight, availableMediumWeight, availablePillageWeight, availableMinorCapitalWeight, availableGateWeight, availableCapitalWeight, activeCapitalTarget)
	Return True

EndFunction

string Function GetDraugnarokStateSummary()

	If !IronSoulNative.IsAvailable()
		Return "Draugnarok | Journal=Hidden | Status=Disabled | Reason=NativeConfigUnavailable"
	EndIf

	int overrideMode = GetDraugnarokOverrideMode()
	bool systemEnabled = IsDraugnarokSystemEnabled()
	int presetOrdinal = NormalizeIronSoulPresetOrdinal(IronSoulNative.GetIronSoulPresetOrdinal())
	int threat = GetDraugrThreatLevel()
	int questStage = GetDraugnarokQuestStage()
	string statusLabel = GetDraugnarokStatusLabel(overrideMode, threat)
	string overrideLabel = GetDraugnarokOverrideLabel(overrideMode)
	string threatText = "" + threat
	If presetOrdinal != 0 && systemEnabled && threat >= 1 && GetPresetOrdinalPlusRank(presetOrdinal) >= 2
		threatText = threatText + "(" + presetOrdinal + ")"
	EndIf

	string summary = "Draugnarok | System=" + (systemEnabled as int) + " | Journal=" + GetDraugnarokJournalLabel(questStage) + " | Status=" + statusLabel
	If overrideLabel != ""
		summary = summary + " | Override=" + overrideLabel
	EndIf
	summary = summary + " | Threat=" + threatText + " | QuestStage=" + questStage

	If statusLabel != "Active"
		summary = summary + " | AlduinGate=" + GetAlduinGateStatus(overrideMode)
		summary = summary + " | " + GetAlduinQuestStageSummary()
		If IsGateCapitalTargetActive()
			summary = summary + "\n" + GetGateTargetSummary()
		EndIf
		Return summary
	EndIf

	int baseInterval = GetDraugnarokBaseIntervalHours()
	int forceCleanupIntervals = GetDraugnarokForceCleanupIntervals()
	int cooldownIntervals = GetDraugnarokCooldownIntervals()
	int gatePressureIntervals = GetDraugnarokGatePressureIntervals()
	summary = summary + " | BaseInterval=" + baseInterval + "h | ForceCleanup=" + forceCleanupIntervals + "i | Cooldown=" + cooldownIntervals + "i | GatePressure=" + gatePressureIntervals + "i"

	If IsGateCapitalTargetActive()
		summary = summary + "\n" + GetGateTargetSummary()
	EndIf

	summary = summary + "\n" + GetLastPulseRaidChanceSummary()
	Return summary

EndFunction

Function RunDraugnarokPulse()

	DraugnarokPulseRunning = False
	GateCapitalTargetSetDuringPulse = False
	CleanupPillageFactionTargets(False)

	int threat = GetDraugrThreatLevel()
	If !IsGateTargetingEnabled()
		ClearGateCapitalTarget()
	EndIf
	UpdateWorldEncounterChances(threat)
	If !IsDraugnarokSystemEnabled()
		If threat != LastLoggedThreatLevel
			LogInfo("DraugnarokSystem=0; Draugnarok system disabled.")
			LastLoggedThreatLevel = threat
		EndIf
		Return
	EndIf
	If threat < 0
		If threat != LastLoggedThreatLevel
			LogInfo("Draugnarok threat disabled.")
			LastLoggedThreatLevel = threat
		EndIf
		Return
	EndIf
	If threat != LastLoggedThreatLevel
		LogInfo("Threat level changed to " + threat + ".")
		LastLoggedThreatLevel = threat
	EndIf
	DraugnarokPulseRunning = True
	GateCapitalTargetSetDuringPulse = False
	CleanupStaleDraugnarokRaids()

	bool raidPoolReady = CalculateRaidChance(threat, True)
	StoreLastPulseRaidChanceSummary()
	If !raidPoolReady
		FinishDraugnarokPulse()
		Return
	EndIf

	int noAttackWeight = WEIGHT_TOTAL - CalculatedRaidChanceWeight
	If noAttackWeight < 0
		noAttackWeight = 0
	EndIf

	int roll = Utility.RandomInt(1, WEIGHT_TOTAL)
	If roll <= noAttackWeight
		LogDebug("No attack roll=" + roll + " threshold=" + noAttackWeight)
		FinishDraugnarokPulse()
		Return
	EndIf

	roll = Utility.RandomInt(1, CalculatedAvailableWeight)
	If roll <= CalculatedAvailableSmallWeight
		LogInfo("Selected attack category: small death squad.")
		DeployRandomEligibleFromArray(DeathSquads_Small, "small death squad", RAID_SMALL, "", False)
		FinishDraugnarokPulse()
		Return
	EndIf
	roll = roll - CalculatedAvailableSmallWeight

	If roll <= CalculatedAvailableServiceWeight
		LogInfo("Selected attack category: service death squad.")
		DeployServiceRaid()
		FinishDraugnarokPulse()
		Return
	EndIf
	roll = roll - CalculatedAvailableServiceWeight

	If roll <= CalculatedAvailableTownWeight
		LogInfo("Selected attack category: town raid.")
		DeployRandomEligibleFromArray(TownRaids, "town raid", RAID_TOWN, "", False)
		FinishDraugnarokPulse()
		Return
	EndIf
	roll = roll - CalculatedAvailableTownWeight

	If roll <= CalculatedAvailableMediumWeight
		LogInfo("Selected attack category: medium death squad.")
		DeployRandomEligibleFromArray(DeathSquads_Medium, "medium death squad", RAID_MEDIUM, "", False)
		FinishDraugnarokPulse()
		Return
	EndIf
	roll = roll - CalculatedAvailableMediumWeight

	If roll <= CalculatedAvailablePillageWeight
		LogInfo("Selected attack category: pillage squad.")
		DeployPillageRaid()
		FinishDraugnarokPulse()
		Return
	EndIf
	roll = roll - CalculatedAvailablePillageWeight

	If roll <= CalculatedAvailableMinorCapitalWeight
		LogInfo("Selected attack category: minor capital raid.")
		DeployRandomEligibleFromArray(MinorCapitalRaids, "minor capital raid", RAID_MINOR_CAPITAL, "", False)
		FinishDraugnarokPulse()
		Return
	EndIf
	roll = roll - CalculatedAvailableMinorCapitalWeight

	If roll <= CalculatedAvailableGateWeight
		LogInfo("Selected attack category: gate crasher raid.")
		DeployTargetBiasedGateCrashers()
		FinishDraugnarokPulse()
		Return
	EndIf
	roll = roll - CalculatedAvailableGateWeight

	If roll > CalculatedAvailableCapitalWeight
		LogError("Available attack roll fell through categories roll=" + roll + " availableTotal=" + CalculatedAvailableWeight)
		FinishDraugnarokPulse()
		Return
	EndIf
	LogInfo("Selected attack category: capital raid.")
	DeployRandomEligibleFromArray(CapitalRaids, "capital raid", RAID_CAPITAL, CalculatedActiveCapitalTarget, False)
	FinishDraugnarokPulse()

EndFunction

bool Function TriggerManualRaid(int aiRaidType, string asRaidLabel = "")

	If !IsDraugnarokSystemEnabled()
		LogInfo("Manual Draugnarok raid trigger blocked because DraugnarokSystem=0.", True)
		Return False
	EndIf

	ArmManualRaidDebugNotification(aiRaidType, asRaidLabel)
	bool started = False
	If aiRaidType == RAID_SMALL
		LogInfo("Manual raid trigger: small death squad.")
		started = DeployRandomFromArray(DeathSquads_Small, "manual small death squad", False, RAID_SMALL)
	ElseIf aiRaidType == RAID_SERVICE
		LogInfo("Manual raid trigger: service death squad.")
		started = DeployServiceRaid()
	ElseIf aiRaidType == RAID_TOWN
		LogInfo("Manual raid trigger: town raid.")
		started = DeployRandomFromArray(TownRaids, "manual town raid", False, RAID_TOWN)
	ElseIf aiRaidType == RAID_MEDIUM
		LogInfo("Manual raid trigger: medium death squad.")
		started = DeployRandomFromArray(DeathSquads_Medium, "manual medium death squad", False, RAID_MEDIUM)
	ElseIf aiRaidType == RAID_PILLAGE
		LogInfo("Manual raid trigger: pillage squad.")
		started = DeployPillageRaid()
	ElseIf aiRaidType == RAID_MINOR_CAPITAL
		LogInfo("Manual raid trigger: minor capital raid.")
		started = DeployRandomFromArray(MinorCapitalRaids, "manual minor capital raid", False, RAID_MINOR_CAPITAL)
	ElseIf aiRaidType == RAID_GATE
		LogInfo("Manual raid trigger: gate crasher raid.")
		started = DeployRandomFromArray(GateCrashers, "manual gate crasher raid", False, RAID_GATE)
	ElseIf aiRaidType == RAID_CAPITAL
		LogInfo("Manual raid trigger: capital raid.")
		started = DeployRandomFromArray(CapitalRaids, "manual capital raid", False, RAID_CAPITAL)
	Else
		LogError("Unknown manual raid type: " + aiRaidType)
	EndIf

	If !started
		ClearManualRaidDebugNotification()
		NotifyManualRaidTriggerFailed(aiRaidType, asRaidLabel)
	EndIf
	Return started

EndFunction

bool Function DeployRandomFromArray(Quest[] akArray, string asCategory, bool abReset = False, int aiRaidType = 0)

	Quest q = GetRandomPresentQuest(akArray)
	If !q
		LogError("Missing attack array for selected category: " + asCategory)
		Return False
	EndIf
	LogDebug("Deploying random " + asCategory + " '" + q.GetName() + "'")
	Return DeploySquad(q, abReset, aiRaidType)

EndFunction

Function ForceMajorRaidWeather()

	ForceRaidWeather("major raid")

EndFunction

Function ForceRaidWeather(string asReason = "raid")

	int oldPattern = dsGlobals.gWeather
	dsGlobals.gWeather = 1
	FigureWeather(None, True, False)
	dsGlobals.gWeather = oldPattern
	LogInfo("Applied thematic weather for " + asReason + ". oldWeatherMode=" + oldPattern, True)

EndFunction

int Function GetPlayerLevel()

	Actor player = PlayerRef
	If !player
		player = Game.GetPlayer()
	EndIf
	If player
		Return player.GetLevel()
	EndIf
	Return 1

EndFunction

int Function ScaleWeight(int aiBaseWeight, int aiMultiplier)

	Return Math.Floor((aiBaseWeight as float) * (aiMultiplier as float) / 1000.0)

EndFunction

int Function GetEffectiveLevelMultiplier(int aiThreat, int aiLevel, int aiRaidType)

	If !IsConfigEnabled("DraugnarokLevelProgression", 1)
		Return 1000
	EndIf

	int multiplier = GetLevelMultiplier(aiLevel, aiRaidType)
	If aiThreat == 5 && multiplier < 1000
		Return Math.Floor(((multiplier as float) + 1000.0) / 2.0)
	EndIf
	Return multiplier

EndFunction

int Function GetBaseAttackWeight(int aiThreat, int aiRaidType)

	If aiThreat == 1
		If aiRaidType == RAID_SMALL
			Return 33000
		ElseIf aiRaidType == RAID_SERVICE
			Return 4000
		ElseIf aiRaidType == RAID_TOWN
			Return 5000
		ElseIf aiRaidType == RAID_ROAMING_MOB
			Return 3000
		ElseIf aiRaidType == RAID_MEDIUM
			Return 3000
		ElseIf aiRaidType == RAID_PILLAGE
			Return 1500
		ElseIf aiRaidType == RAID_MINOR_CAPITAL
			Return 2000
		ElseIf aiRaidType == RAID_GATE
			Return 1000
		ElseIf aiRaidType == RAID_CAPITAL
			Return 500
		EndIf
	ElseIf aiThreat == 2
		If aiRaidType == RAID_SMALL
			Return 35000
		ElseIf aiRaidType == RAID_SERVICE
			Return 5000
		ElseIf aiRaidType == RAID_TOWN
			Return 7000
		ElseIf aiRaidType == RAID_ROAMING_MOB
			Return 6000
		ElseIf aiRaidType == RAID_MEDIUM
			Return 5000
		ElseIf aiRaidType == RAID_PILLAGE
			Return 2000
		ElseIf aiRaidType == RAID_MINOR_CAPITAL
			Return 3500
		ElseIf aiRaidType == RAID_GATE
			Return 1500
		ElseIf aiRaidType == RAID_CAPITAL
			Return 1000
		EndIf
	ElseIf aiThreat == 3
		If aiRaidType == RAID_SMALL
			Return 34000
		ElseIf aiRaidType == RAID_SERVICE
			Return 8000
		ElseIf aiRaidType == RAID_TOWN
			Return 8000
		ElseIf aiRaidType == RAID_ROAMING_MOB
			Return 8000
		ElseIf aiRaidType == RAID_MEDIUM
			Return 8000
		ElseIf aiRaidType == RAID_PILLAGE
			Return 5000
		ElseIf aiRaidType == RAID_MINOR_CAPITAL
			Return 3000
		ElseIf aiRaidType == RAID_GATE
			Return 2000
		ElseIf aiRaidType == RAID_CAPITAL
			Return 2000
		EndIf
	ElseIf aiThreat == 4
		If aiRaidType == RAID_SMALL
			Return 30000
		ElseIf aiRaidType == RAID_SERVICE
			Return 10000
		ElseIf aiRaidType == RAID_TOWN
			Return 11000
		ElseIf aiRaidType == RAID_ROAMING_MOB
			Return 10500
		ElseIf aiRaidType == RAID_MEDIUM
			Return 10000
		ElseIf aiRaidType == RAID_PILLAGE
			Return 8000
		ElseIf aiRaidType == RAID_MINOR_CAPITAL
			Return 5000
		ElseIf aiRaidType == RAID_GATE
			Return 3000
		ElseIf aiRaidType == RAID_CAPITAL
			Return 3000
		EndIf
	ElseIf aiThreat >= 5
		If aiRaidType == RAID_SMALL
			Return 24000
		ElseIf aiRaidType == RAID_SERVICE
			Return 10000
		ElseIf aiRaidType == RAID_TOWN
			Return 12000
		ElseIf aiRaidType == RAID_ROAMING_MOB
			Return 12000
		ElseIf aiRaidType == RAID_MEDIUM
			Return 12000
		ElseIf aiRaidType == RAID_PILLAGE
			Return 10000
		ElseIf aiRaidType == RAID_MINOR_CAPITAL
			Return 8000
		ElseIf aiRaidType == RAID_GATE
			Return 7000
		ElseIf aiRaidType == RAID_CAPITAL
			Return 7000
		EndIf
	EndIf

	Return 0

EndFunction

int Function GetLevelMultiplier(int aiLevel, int aiRaidType)

	If aiRaidType == RAID_SMALL
		Return 1000
	EndIf

	If aiLevel < 10
		If aiRaidType == RAID_SERVICE
			Return 600
		ElseIf aiRaidType == RAID_TOWN
			Return 500
		ElseIf aiRaidType == RAID_ROAMING_MOB
			Return 400
		ElseIf aiRaidType == RAID_MEDIUM
			Return 300
		ElseIf aiRaidType == RAID_PILLAGE
			Return 500
		ElseIf aiRaidType == RAID_MINOR_CAPITAL
			Return 75
		ElseIf aiRaidType == RAID_GATE
			Return 50
		ElseIf aiRaidType == RAID_CAPITAL
			Return 25
		EndIf
	ElseIf aiLevel < 20
		If aiRaidType == RAID_SERVICE
			Return 750
		ElseIf aiRaidType == RAID_TOWN
			Return 700
		ElseIf aiRaidType == RAID_ROAMING_MOB
			Return 600
		ElseIf aiRaidType == RAID_MEDIUM
			Return 500
		ElseIf aiRaidType == RAID_PILLAGE
			Return 650
		ElseIf aiRaidType == RAID_MINOR_CAPITAL
			Return 200
		ElseIf aiRaidType == RAID_GATE
			Return 125
		ElseIf aiRaidType == RAID_CAPITAL
			Return 75
		EndIf
	ElseIf aiLevel < 30
		If aiRaidType == RAID_SERVICE
			Return 900
		ElseIf aiRaidType == RAID_TOWN
			Return 900
		ElseIf aiRaidType == RAID_ROAMING_MOB
			Return 825
		ElseIf aiRaidType == RAID_MEDIUM
			Return 750
		ElseIf aiRaidType == RAID_PILLAGE
			Return 850
		ElseIf aiRaidType == RAID_MINOR_CAPITAL
			Return 450
		ElseIf aiRaidType == RAID_GATE
			Return 300
		ElseIf aiRaidType == RAID_CAPITAL
			Return 200
		EndIf
	ElseIf aiLevel < 40
		If aiRaidType == RAID_SERVICE
			Return 1000
		ElseIf aiRaidType == RAID_TOWN
			Return 1000
		ElseIf aiRaidType == RAID_ROAMING_MOB
			Return 950
		ElseIf aiRaidType == RAID_MEDIUM
			Return 900
		ElseIf aiRaidType == RAID_PILLAGE
			Return 1000
		ElseIf aiRaidType == RAID_MINOR_CAPITAL
			Return 700
		ElseIf aiRaidType == RAID_GATE
			Return 575
		ElseIf aiRaidType == RAID_CAPITAL
			Return 450
		EndIf
	ElseIf aiLevel < 50
		If aiRaidType == RAID_SERVICE
			Return 1000
		ElseIf aiRaidType == RAID_TOWN
			Return 1000
		ElseIf aiRaidType == RAID_ROAMING_MOB
			Return 1000
		ElseIf aiRaidType == RAID_MEDIUM
			Return 1000
		ElseIf aiRaidType == RAID_PILLAGE
			Return 1000
		ElseIf aiRaidType == RAID_MINOR_CAPITAL
			Return 900
		ElseIf aiRaidType == RAID_GATE
			Return 825
		ElseIf aiRaidType == RAID_CAPITAL
			Return 750
		EndIf
	EndIf

	Return 1000

EndFunction

Function SetRadiance()

	GlobalWE.SetValueInt(1)
	GlobalWI.SetValueInt(1)
	
EndFunction

Function KillTarget (Actor akTarget)
	If !akTarget || akTarget.IsNearPlayer() || dsGlobals.gAccuracy < ACCURACY_LETHAL
		Return
	EndIf
	
	DoTrace("Killing " + akTarget.GetBaseObject().GetName())
	If dsGlobals.gAccuracy == ACCURACY_SUPERLETHAL
		akTarget.KillEssential()
	Else
		akTarget.Kill()
	EndIf
	
EndFunction

Function DoTrace(string asMsg)
	LogDebug(asMsg)
EndFunction

Function DoNotify(string asMsg)
	LogInfo(asMsg)
EndFunction

Function LogError(String asMsg)
	If IronSoul && IronSoul.Config
		IronSoul.Config.LogExternalMsg("Draugnarok", LOG_ERR_LEVEL, asMsg, False)
	EndIf
EndFunction

Function LogInfo(String asMsg, Bool abSuppressNotify = False)
	If IronSoul && IronSoul.Config
		IronSoul.Config.LogExternalMsg("Draugnarok", LOG_INFO_LEVEL, asMsg, abSuppressNotify)
	EndIf
EndFunction

Function LogDebug(String asMsg, Bool abSuppressNotify = True)
	If IronSoul && IronSoul.Config
		IronSoul.Config.LogExternalMsg("Draugnarok", LOG_DBG_LEVEL, asMsg, abSuppressNotify)
	EndIf
EndFunction

Function JournalMajorEvent(String asEventText)
	If IronSoul && IronSoul.Journal
		IronSoul.Journal.LogExternalEvent("Draugnarok", asEventText)
	EndIf
EndFunction
