Scriptname _DS_DN_Globals extends Quest


GlobalVariable Property _DS_Draugnarok__Disabled Auto
bool Property gDraugnarokDisabled Hidden
	Function Set(bool abValue)
		_DS_Draugnarok__Disabled.SetValueInt(abValue as int)
	EndFunction
	bool Function Get()
		Return _DS_Draugnarok__Disabled.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok__Stage Auto
int Property gDraugnarokStage Hidden
	Function Set(int aiValue)
		_DS_Draugnarok__Stage.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok__Stage.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_Accuracy Auto
int Property gAccuracy Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_Accuracy.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_Accuracy.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_CurrentWeather Auto
int Property gCurrentWeather Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_CurrentWeather.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_CurrentWeather.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_DeathLords Auto
bool Property gDeathLords Hidden
	Function Set(bool abValue)
		_DS_Draugnarok_DeathLords.SetValueInt(abValue as int)
	EndFunction
	bool Function Get()
		Return _DS_Draugnarok_DeathLords.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_Debug Auto
bool Property gDebug Hidden
	Function Set(bool abValue)
		_DS_Draugnarok_Debug.SetValueInt(abValue as int)
	EndFunction
	bool Function Get()
		Return _DS_Draugnarok_Debug.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_DemoMode Auto
bool Property gDemoMode Hidden
	Function Set(bool abValue)
		_DS_Draugnarok_DemoMode.SetValueInt(abValue as int)
	EndFunction
	bool Function Get()
		Return _DS_Draugnarok_DemoMode.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_Duration Auto
int Property gDuration Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_Duration.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_Duration.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_EnableRaidSizing Auto
bool Property gEnableRaidSizing Hidden
	Function Set(bool abValue)
		_DS_Draugnarok_EnableRaidSizing.SetValueInt(abValue as int)
	EndFunction
	bool Function Get()
		Return _DS_Draugnarok_EnableRaidSizing.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_Eternal Auto
bool Property gEternal Hidden
	Function Set(bool abValue)
		_DS_Draugnarok_Eternal.SetValueInt(abValue as int)
	EndFunction
	bool Function Get()
		Return _DS_Draugnarok_Eternal.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_Mayhem Auto
bool Property gMayhem Hidden
	Function Set(bool abValue)
		_DS_Draugnarok_Mayhem.SetValueInt(abValue as int)
	EndFunction
	bool Function Get()
		Return _DS_Draugnarok_Mayhem.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_PlayerInInterior Auto
bool Property gPlayerInInterior Hidden
	Function Set(bool abValue)
		_DS_Draugnarok_PlayerInInterior.SetValueInt(abValue as int)
	EndFunction
	bool Function Get()
		Return _DS_Draugnarok_PlayerInInterior.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_Radiance Auto
bool Property gRadiance Hidden
	Function Set(bool abValue)
		_DS_Draugnarok_Radiance.SetValueInt(abValue as int)
	EndFunction
	bool Function Get()
		Return _DS_Draugnarok_Radiance.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_RaidSize Auto
int Property gRaidSize Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_RaidSize.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_RaidSize.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_Rain Auto
float Property gRain Hidden
	Function Set(float afValue)
		_DS_Draugnarok_Rain.SetValue(afValue)
	EndFunction
	float Function Get()
		Return _DS_Draugnarok_Rain.GetValue()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_ShowQuest Auto
bool Property gShowQuest Hidden
	Function Set(bool abValue)
		_DS_Draugnarok_ShowQuest.SetValueInt(abValue as int)
	EndFunction
	bool Function Get()
		Return _DS_Draugnarok_ShowQuest.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_SpreadRate Auto
int Property gSpreadRate Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_SpreadRate.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_SpreadRate.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_TickCount Auto
int Property gTickCount Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_TickCount.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_TickCount.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_TicksTilStage20 Auto
int Property gTicksTilStage20 Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_TicksTilStage20.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_TicksTilStage20.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_TicksTilStage30 Auto
int Property gTicksTilStage30 Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_TicksTilStage30.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_TicksTilStage30.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_TicksTilStage40 Auto
int Property gTicksTilStage40 Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_TicksTilStage40.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_TicksTilStage40.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_Weather Auto
int Property gWeather Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_Weather.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_Weather.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_WeatherIsWeird Auto
bool Property gWeatherIsWeird Hidden
	Function Set(bool abValue)
		_DS_Draugnarok_WeatherIsWeird.SetValueInt(abValue as int)
	EndFunction
	bool Function Get()
		Return _DS_Draugnarok_WeatherIsWeird.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_WEChance Auto
int Property gWEChance Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_WEChance.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_WEChance.GetValueInt()
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_RoamingMobExtraChance Auto
int Property gRoamingMobExtraChance Hidden
	Function Set(int aiValue)
		If _DS_Draugnarok_RoamingMobExtraChance
			_DS_Draugnarok_RoamingMobExtraChance.SetValueInt(aiValue)
		EndIf
	EndFunction
	int Function Get()
		If _DS_Draugnarok_RoamingMobExtraChance
			Return _DS_Draugnarok_RoamingMobExtraChance.GetValueInt()
		EndIf
		Return 0
	EndFunction
EndProperty

GlobalVariable Property _DS_Draugnarok_WEChance_Road Auto
int Property gWEChance_Road Hidden
	Function Set(int aiValue)
		_DS_Draugnarok_WEChance_Road.SetValueInt(aiValue)
	EndFunction
	int Function Get()
		Return _DS_Draugnarok_WEChance_Road.GetValueInt()
	EndFunction
EndProperty

Function ResetToDefaults()

	_DS_Draugnarok__Stage.SetValue(0)
	_DS_Draugnarok_TickCount.SetValue(0)
	
	_DS_Draugnarok_EnableRaidSizing.SetValue(0)
	
	_DS_Draugnarok_CurrentWeather.SetValue(0)
	_DS_Draugnarok_PlayerInInterior.SetValue(0)
	
	_DS_Draugnarok_SpreadRate.SetValue(1)
	_DS_Draugnarok_Duration.SetValue(1)
	_DS_Draugnarok_RaidSize.SetValue(0)
	_DS_Draugnarok_Accuracy.SetValue(1)
	_DS_Draugnarok_Eternal.SetValue(0)
	_DS_Draugnarok_Radiance.SetValue(1)
	_DS_Draugnarok_Weather.SetValue(1)
	_DS_Draugnarok_WeatherIsWeird.SetValue(0)
	gRoamingMobExtraChance = 0
	
	_DS_Draugnarok_ShowQuest.SetValue(1)
	_DS_Draugnarok_DeathLords.SetValue(1)
	_DS_Draugnarok_Mayhem.SetValue(0)
	
	;_DS_Draugnarok_Debug.SetValue(0)

EndFunction
