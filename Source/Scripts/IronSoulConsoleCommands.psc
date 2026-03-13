Scriptname IronSoulConsoleCommands Hidden

; Console command callbacks for ConsoleUtil-Extended.
; https://www.nexusmods.com/skyrimspecialedition/mods/133569
; Operates on the current player's GUID-scoped Iron Soul keys.
;
; Console Command Masterlist (root: IronSoul, alias: is)
; - GetState   (alias: gs)   -> GetIronSoulState()
;   Example: is gs
; - GetTier    (alias: gt)   -> GetTier()
;   Example: is gt
; - SetTier    (alias: st)   -> SetTier(Int tier)
;   Example: is st 4
; - GetDeaths  (alias: gd)   -> GetDeaths()
;   Example: is gd
; - Luck       (alias: l)    -> GetLuck()
;   Example: is l
; - SetLuck    (alias: sl)   -> SetLuck(Int luck)
;   Example: is sl 42
; - SetDeaths  (alias: sd)   -> SetDeaths(Int deaths)
;   Example: is sd 12
; - GetIni     (alias: gini) -> GetIni(String key, Int fallback = 0)
;   Example: is gini DisableSoulBonus
; - SetIni     (alias: sini) -> SetIni(String key, Int value, String persistFlag = "t")
;   Example: is sini DisableSoulBonus 1 t
; - ReloadIni  (alias: rini) -> ReloadIni()
;   Example: is rini
; NOTE:
; - Write/set commands require CHIM=1 in IronSoul.ini.

Int Function ClampTier(Int tierValue) Global
    if tierValue < 0
        return 0
    elseif tierValue > 6
        return 6
    endif
    return tierValue
EndFunction

Int Function ClampDeaths(Int deathValue) Global
    if deathValue < 0
        return 0
    endif
    return deathValue
EndFunction

Int Function ParsePersistFlag(String persistFlag) Global
    if persistFlag == ""
        return 1
    endif

    if persistFlag == "t" || persistFlag == "T" || persistFlag == "true" || persistFlag == "True" || persistFlag == "TRUE"
        return 1
    elseif persistFlag == "f" || persistFlag == "F" || persistFlag == "false" || persistFlag == "False" || persistFlag == "FALSE"
        return 0
    endif

    return -1
EndFunction

IronSoulController Function ResolveControllerQuest() Global
    ; 0x000817 in Iron Soul - Permadeath Lite.esp (IronSoulControllerQuest)
    Quest q = Game.GetFormFromFile(0x00000817, "Iron Soul - Permadeath Lite.esp") as Quest
    if !q
        return None
    endif
    return q as IronSoulController
EndFunction

Bool Function IsChimEnabled() Global
    return IronSoulNative.GetConfigInt("CHIM", 0) == 1
EndFunction

String Function MakeScopedKey(String baseKey, String guid) Global
    if baseKey == "" || guid == ""
        return ""
    endif
    return baseKey + ":" + guid
EndFunction

String Function ResolveGuid(Actor playerRef) Global
    if !playerRef
        return ""
    endif
    return StorageUtil.GetStringValue(playerRef, "IS_9975", "")
EndFunction

Int Function ReadScopedInt(Actor playerRef, String keyBase, Int fallback) Global
    String guid = ResolveGuid(playerRef)
    if guid == ""
        return fallback
    endif

    String scopedKey = MakeScopedKey(keyBase, guid)
    if scopedKey == ""
        return fallback
    endif

    if IronSoulNative.DataHasKey(scopedKey)
        return IronSoulNative.DataGetInt(scopedKey, fallback)
    endif

    if StorageUtil.HasIntValue(playerRef, scopedKey)
        Int v = StorageUtil.GetIntValue(playerRef, scopedKey, fallback)
        IronSoulNative.DataSetIntIfChanged(scopedKey, v)
        return v
    endif

    return fallback
EndFunction

Function WriteScopedInt(Actor playerRef, String keyBase, Int value) Global
    String guid = ResolveGuid(playerRef)
    if guid == ""
        return
    endif

    String scopedKey = MakeScopedKey(keyBase, guid)
    if scopedKey == ""
        return
    endif

    IronSoulNative.DataSetIntIfChanged(scopedKey, value)

    Int currentCosave = StorageUtil.GetIntValue(playerRef, scopedKey)
    if currentCosave != value
        StorageUtil.SetIntValue(playerRef, scopedKey, value)
    endif
EndFunction

String Function TierLabel(Int tierValue) Global
    if tierValue <= 0
        return "CHIM"
    elseif tierValue == 1
        return "Defiant"
    elseif tierValue == 2
        return "Iron"
    elseif tierValue == 3
        return "Silver"
    elseif tierValue == 4
        return "Gold"
    elseif tierValue == 5
        return "Ebon"
    endif
    return "Platinum"
EndFunction

Function SyncDeathsGlobal(Int deathsValue) Global
    ; 0x000B12 in Iron Soul - Permadeath Lite.esp (IronSoul_DeathCount global)
    GlobalVariable deathsGlobal = Game.GetFormFromFile(2834, "Iron Soul - Permadeath Lite.esp") as GlobalVariable
    if deathsGlobal
        deathsGlobal.SetValue(deathsValue as Float)
    endif
EndFunction

Function SyncDeathActorValue(Actor playerRef, Int deathsValue) Global
    Int charSheetCompat = IronSoulNative.GetConfigInt("EnableCharacterSheetCompatibility", 0)
    if charSheetCompat == 0 || !playerRef
        return
    endif

    Float current = playerRef.GetActorValue("DEPRECATED05")
    Float desired = deathsValue as Float
    if current != desired
        playerRef.SetActorValue("DEPRECATED05", desired)
    endif
EndFunction

String Function GetIronSoulState() Global
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    String guid = ResolveGuid(playerRef)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif

    Int tierValue = ClampTier(ReadScopedInt(playerRef, "IS_2204", 2))
    Int deathValue = ClampDeaths(ReadScopedInt(playerRef, "IS_8155", 0))
    return "GUID=" + guid + " Tier=" + tierValue + " (" + TierLabel(tierValue) + ") Deaths=" + deathValue
EndFunction

Int Function GetTier() Global
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return 2
    endif
    return ClampTier(ReadScopedInt(playerRef, "IS_2204", 2))
EndFunction

String Function SetTier(Int tierValue) Global
    if !IsChimEnabled()
        return "CHIM disabled. Set CHIM=1 in IronSoul.ini."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    String guid = ResolveGuid(playerRef)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif

    Int clampedTier = ClampTier(tierValue)
    WriteScopedInt(playerRef, "IS_2204", clampedTier)

    ; Keep dynamic UI assets aligned with the new tier.
    IronSoulNative.ApplyDynamicSplash(clampedTier)
    IronSoulNative.ApplyDynamicLevelWidget(clampedTier)
    IronSoulNative.DataFlushIfDirty()

    return "Tier set to " + clampedTier + " (" + TierLabel(clampedTier) + ")."
EndFunction

Int Function GetDeaths() Global
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return 0
    endif
    return ClampDeaths(ReadScopedInt(playerRef, "IS_8155", 0))
EndFunction

String Function GetLuck() Global
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    String guid = ResolveGuid(playerRef)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif

    ; Follow the same live path used by controller runtime logic.
    Int nowSec = Utility.GetCurrentRealTime() as Int
    controller.LuckCooldownEnsureLoaded(playerRef, guid, nowSec)

    Int maxLuck = controller.GetCurrentMaxLuck(playerRef, guid)
    if maxLuck < 1
        maxLuck = 1
    endif

    Int luck = controller.GetLuckValue(playerRef, guid)
    if luck < 0
        luck = 0
    elseif luck > maxLuck
        luck = maxLuck
    endif

    return "Luck: " + luck
EndFunction

String Function SetLuck(Int luckValue) Global
    if !IsChimEnabled()
        return "CHIM disabled. Set CHIM=1 in IronSoul.ini."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    String guid = ResolveGuid(playerRef)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif

    Int maxLuck = controller.GetCurrentMaxLuck(playerRef, guid)
    if maxLuck < 1
        maxLuck = 1
    endif

    Int appliedLuck = controller.SetLuckValue(playerRef, guid, luckValue)
    if appliedLuck < 0
        return "Error: failed to set luck."
    endif

    IronSoulNative.DataFlushIfDirty()
    return "Luck set to " + appliedLuck + " (max " + maxLuck + ")."
EndFunction

String Function SetDeaths(Int deathsValue) Global
    if !IsChimEnabled()
        return "CHIM disabled. Set CHIM=1 in IronSoul.ini."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    String guid = ResolveGuid(playerRef)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif

    Int clampedDeaths = ClampDeaths(deathsValue)
    WriteScopedInt(playerRef, "IS_8155", clampedDeaths)
    SyncDeathsGlobal(clampedDeaths)
    SyncDeathActorValue(playerRef, clampedDeaths)
    IronSoulNative.DataFlushIfDirty()

    return "Deaths set to " + clampedDeaths + "."
EndFunction

Int Function GetIni(String k, Int fallback = 0) Global
    if k == ""
        return fallback
    endif
    return IronSoulNative.GetConfigInt(k, fallback)
EndFunction

String Function SetIni(String k, Int value, String persistFlag = "t") Global
    if !IsChimEnabled()
        return "CHIM disabled. Set CHIM=1 in IronSoul.ini."
    endif

    if k == ""
        return "Error: config key cannot be empty."
    endif

    Int parsedPersist = ParsePersistFlag(persistFlag)
    if parsedPersist == -1
        return "Error: persist flag must be t/T/f/F/true/false."
    endif

    Bool persistToIni = (parsedPersist == 1)

    Bool ok = IronSoulNative.SetConfigInt(k, value, persistToIni)
    if !ok
        return "Error: failed to set INI key '" + k + "'."
    endif

    String mode = "cache-only"
    if persistToIni
        mode = "persisted"
    endif

    ; Note: controller runtime toggles are read during its LoadConfig() path.
    ; This command updates native config immediately, but controller-side cached
    ; flags generally apply on the next game load.
    return "Set " + k + "=" + value + " (" + mode + ")."
EndFunction

String Function ReloadIni() Global
    Bool ok = IronSoulNative.ReloadConfig()
    if !ok
        return "Error: failed to reload IronSoul.ini."
    endif
    return "Reloaded IronSoul.ini into native config cache."
EndFunction
