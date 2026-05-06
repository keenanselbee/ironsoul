Scriptname IronSoulConsoleCommands Hidden

; ========================
; --- Console Commands ---
; ========================

; Console command callbacks for ConsoleUtil-Extended.
; https://www.nexusmods.com/skyrimspecialedition/mods/133569
; Operates on the current player's GUID-scoped Iron Soul keys.
;
; Console Command Masterlist (root: IronSoul, alias: is)
; - Help       (alias: h)    -> GetHelp(String topic = "")
;   Example: is help
;   Example: is h
;   Example: is help hidden
; - State      (alias: s)    -> GetIronSoulState() with preset
;   Example: is s
; - SetTier    (alias: st)   -> SetTier(Int tier, String forceMode = "")
;   Example: is st 4
;   Example: is st 4 f
; - ResetTier  (alias: rt)   -> ResetTier()
;   Example: is rt
; - Luck       (alias: l)    -> GetLuck()
;   Example: is l
; - SetLuck    (alias: sl)   -> SetLuck(Int luck)
;   Example: is sl 42
; - SetDeaths  (alias: sd)   -> SetDeaths(Int deaths)
;   Example: is sd 12
; - SetDragonSoulsState (alias: sds) -> SetDragonSoulsState(Int total)
;   Example: is sds 25
; - GetIni     (alias: gini) -> GetIni(String key, Int fallback = 0)
;   Example: is gini SoulBonus
; - SetIni     (alias: sini) -> SetIni(String key, Int value, String persistFlag = "t")
;   Example: is sini SoulBonus 0 t
; - ReloadIni  (alias: rini) -> ReloadIni()
;   Example: is rini
; NOTE:
; - Privileged write/set/reset/destructive commands require EnableDebug=1 in IronSoul.ini.


; ========================
; --- Helper & Parsing ---
; ========================

Int Function ClampTier(Int tierValue) Global
    if tierValue == 0 || tierValue == 9
        return tierValue
    elseif tierValue >= 1 && tierValue <= 6
        return tierValue
    endif
    return 1
EndFunction

Bool Function IsCanonicalTier(Int tierValue) Global
    if tierValue == 0 || tierValue == 9
        return True
    endif
    return tierValue >= 1 && tierValue <= 6
EndFunction

Bool Function IsNormalTier(Int tierValue) Global
    return tierValue >= 1 && tierValue <= 6
EndFunction

Int Function ClampPreset(Int presetValue) Global
    if presetValue >= 0 && presetValue <= 3
        return presetValue
    endif
    return 0
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

Int Function ParseForceMode(String forceMode) Global
    if forceMode == ""
        return 0
    endif

    if forceMode == "f" || forceMode == "F" || forceMode == "force" || forceMode == "Force" || forceMode == "FORCE"
        return 1
    endif

    return -1
EndFunction


; ===============================================
; --- Controller / GUID / Persistence Helpers ---
; ===============================================

IronSoulController Function ResolveControllerQuest() Global
    ; 0x000817 in Iron Soul - Permadeath Lite.esp (IronSoulControllerQuest)
    Quest q = Game.GetFormFromFile(0x00000817, "Iron Soul - Permadeath Lite.esp") as Quest
    if !q
        return None
    endif
    return q as IronSoulController
EndFunction

Bool Function IsDebugEnabled() Global
    return IronSoulNative.GetConfigInt("EnableDebug", 0) == 1
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
    if tierValue == 0
        return "Defiant"
    elseif tierValue == 1
        return "Iron"
    elseif tierValue == 2
        return "Silver"
    elseif tierValue == 3
        return "Gold"
    elseif tierValue == 4
        return "Ebon"
    elseif tierValue == 5
        return "Platinum"
    elseif tierValue == 6
        return "Devour"
    elseif tierValue == 9
        return "CHIM"
    endif
    return "Iron"
EndFunction

String Function PresetLabel(Int presetValue) Global
    if presetValue == 1
        return "Dreamer"
    elseif presetValue == 2
        return "Harbinger"
    elseif presetValue == 3
        return "Apocalypse"
    endif
    return "None"
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


; =============================
; --- State & Tier Commands ---
; =============================

String Function GetHelp(String helpTopic = "") Global
    if helpTopic == "h" || helpTopic == "H" || helpTopic == "hidden" || helpTopic == "Hidden" || helpTopic == "HIDDEN"
        return "Iron Soul hidden commands:\n" \
            + "rcd: reset current character data; EnableDebug required; double-confirm.\n" \
            + "pd: purge non-current character data; EnableDebug required; double-confirm."
    endif

    return "Iron Soul commands:\n" \
        + "s: state summary.\n" \
        + "st <tier> [f|force]: set tier; EnableDebug required.\n" \
        + "rt: reset tier; EnableDebug required.\n" \
        + "l: get current luck.\n" \
        + "sl <luck>: set luck; EnableDebug required.\n" \
        + "sd <deaths>: set deaths; EnableDebug required.\n" \
        + "sds <total>: set stored dragon soul total; EnableDebug required.\n" \
        + "gini <key> [fallback]: read INI.\n" \
        + "sini <key> <value> [persist]: set INI; EnableDebug required.\n" \
        + "rini: reload INI."
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

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif

    Int tierValue = ClampTier(ReadScopedInt(playerRef, "IS_2204", 1))
    Int presetValue = ClampPreset(ReadScopedInt(playerRef, "IS_6124", 0))
    Int deathValue = ClampDeaths(ReadScopedInt(playerRef, "IS_8155", 0))
    Int totalDeathValue = ClampDeaths(ReadScopedInt(playerRef, "IS_9132", 0))
    Int soulsTotal = ClampDeaths(ReadScopedInt(playerRef, "IS_9646", 0))
    String defiantState = "DefiantTrackedTier=inactive"
    Int defiantTrackedTier = 1
    if tierValue == 0
        defiantTrackedTier = controller.GetDefiantTrackedTier(playerRef, guid)
        defiantState = "DefiantTrackedTier=" + defiantTrackedTier + " (" + TierLabel(defiantTrackedTier) + ")"
    endif
    String soulBonusState = controller.GetAppliedSoulBonusSpellCompactLabel(playerRef)
    String soulFatigueState = controller.GetAppliedSoulFatigueSpellCompactLabel(playerRef)
    return "GUID=" + guid \
        + " Preset=" + presetValue + " (" + PresetLabel(presetValue) + ")" \
        + " Tier=" + tierValue + " (" + TierLabel(tierValue) + ")" \
        + " Deaths=" + deathValue \
        + " TotalDeaths=" + totalDeathValue \
        + " SoulsTotal=" + soulsTotal \
        + " SoulBonusSpell=" + soulBonusState \
        + " SoulFatigueSpell=" + soulFatigueState \
        + " " + defiantState
EndFunction

String Function SetTier(Int tierValue, String forceMode = "") Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in IronSoul.ini."
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

    Int parsedForce = ParseForceMode(forceMode)
    if parsedForce == -1
        return "Error: force flag must be empty, f, or force."
    endif

    if !IsCanonicalTier(tierValue)
        return "Error: tier must be one of 0, 1, 2, 3, 4, 5, 6, or 9."
    endif

    Int previousTier = ClampTier(ReadScopedInt(playerRef, "IS_2204", 1))
    Int clampedTier = tierValue
    if parsedForce == 1
        WriteScopedInt(playerRef, "IS_2719", 1)
    endif
    WriteScopedInt(playerRef, "IS_2204", clampedTier)

    if clampedTier == 9
        controller.SetCHIMEnteredByConsole(playerRef, guid, True)
    else
        controller.SetCHIMEnteredByConsole(playerRef, guid, False)
    endif

    if clampedTier == 0
        Int seedTier = previousTier
        if seedTier == 0
            seedTier = controller.GetDefiantTrackedTier(playerRef, guid)
        endif
        controller.InitializeDefiantState(playerRef, guid, seedTier)
        controller.SetDefiantEnteredByConsole(playerRef, guid, True)
    else
        controller.ClearDefiantState(playerRef, guid)
    endif

    controller.SyncLuckNotifiedTierToCurrent(playerRef, guid)
    controller.SyncSoulPresentationAndStats(playerRef, guid)

    ; Keep dynamic UI assets aligned with the new tier.
    controller.ApplyDynamicSplashForTier(playerRef, guid, clampedTier)
    IronSoulNative.ApplyDynamicLevelWidget(clampedTier)
    IronSoulNative.DataFlushIfDirty()

    Bool manualTierOverride = (ReadScopedInt(playerRef, "IS_2719", 0) == 1)
    String msg = "Tier set to " + clampedTier + " (" + TierLabel(clampedTier) + ")."
    if manualTierOverride
        if parsedForce == 1
            msg = msg + " Manual override is active until ResetTier or a progression transition reclaims tier control."
        else
            msg = msg + " Add f or force to is st to force manual override. Use is rt or ResetTier to enable normal functionality again. Manual override remains active until ResetTier or a progression transition reclaims tier control."
        endif
    elseif parsedForce == 0
        msg = msg + " Add f or force to is st to force manual override. Use is rt or ResetTier to enable normal functionality again."
    endif

    return msg
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

    Int luck = controller.GetLuckValue(playerRef, guid)
    if luck < 0
        luck = 0
    elseif luck > maxLuck
        luck = maxLuck
    endif

    return "Luck: " + luck
EndFunction

String Function SetLuck(Int luckValue) Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in IronSoul.ini."
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

    Int appliedLuck = controller.SetLuckValue(playerRef, guid, luckValue)
    if appliedLuck < 0
        return "Error: failed to set luck."
    endif

    IronSoulNative.DataFlushIfDirty()
    return "Luck set to " + appliedLuck + " (max " + maxLuck + ")."
EndFunction

String Function SetDeaths(Int deathsValue) Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in IronSoul.ini."
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

    Int previousTier = ClampTier(ReadScopedInt(playerRef, "IS_2204", 1))
    Int clampedDeaths = ClampDeaths(deathsValue)
    WriteScopedInt(playerRef, "IS_8155", clampedDeaths)
    SyncDeathsGlobal(clampedDeaths)
    SyncDeathActorValue(playerRef, clampedDeaths)
    controller.SyncSoulPresentationAndStats(playerRef, guid)
    controller.HandleProgressionRelevantChange(playerRef, guid)
    Int actualDeaths = ClampDeaths(ReadScopedInt(playerRef, "IS_8155", 0))
    IronSoulNative.DataFlushIfDirty()

    if actualDeaths == clampedDeaths
        return "Deaths set to " + actualDeaths + "."
    endif
    if previousTier == 0 && actualDeaths == 0
        return "Deaths set request " + clampedDeaths + " triggered Defiant restoration. Stored deaths are now 0."
    endif
    return "Deaths set request " + clampedDeaths + " resolved to stored value " + actualDeaths + "."
EndFunction

String Function SetDragonSoulsState(Int totalValue) Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in IronSoul.ini."
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

    Int clampedTotal = ClampDeaths(totalValue)
    Int liveSouls = playerRef.GetActorValue("DragonSouls") as Int
    liveSouls = ClampDeaths(liveSouls)

    ; Re-baseline the observed snapshot to current live souls so heartbeat sees no gain delta.
    WriteScopedInt(playerRef, "IS_9646", clampedTotal)
    WriteScopedInt(playerRef, "IS_7440", liveSouls)
    controller.HandleProgressionRelevantChange(playerRef, guid)
    IronSoulNative.DataFlushIfDirty()

    return "SoulsTotal set to " + clampedTotal + "."
EndFunction

String Function ResetTier() Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in IronSoul.ini."
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

    Int targetTier = ClampTier(controller.GetResetTargetTier(playerRef, guid))
    Int liveTier = ClampTier(ReadScopedInt(playerRef, "IS_2204", 1))
    if liveTier == 0 && controller.WasDefiantEnteredByConsole(playerRef, guid)
        targetTier = ClampTier(controller.GetDefiantTrackedTier(playerRef, guid))
    endif
    WriteScopedInt(playerRef, "IS_2719", 0)
    controller.SetCHIMEnteredByConsole(playerRef, guid, False)

    if targetTier == 0
        if liveTier != 0
            Int seedTier = liveTier
            if !IsNormalTier(seedTier)
                seedTier = controller.GetDefiantTrackedTier(playerRef, guid)
            endif
            controller.InitializeDefiantState(playerRef, guid, seedTier)
        endif
    else
        controller.ClearDefiantState(playerRef, guid)
    endif

    WriteScopedInt(playerRef, "IS_2204", targetTier)
    controller.SyncLuckNotifiedTierToCurrent(playerRef, guid)
    controller.SyncSoulPresentationAndStats(playerRef, guid)
    controller.ApplyDynamicSplashForTier(playerRef, guid, targetTier)
    IronSoulNative.ApplyDynamicLevelWidget(targetTier)
    IronSoulNative.DataFlushIfDirty()

    return "Tier reset to " + targetTier + " (" + TierLabel(targetTier) + "). Auto-upgrade restored."
EndFunction

String Function ResetCharacterData() Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in IronSoul.ini."
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

    if !controller.TryConsumeDestructiveCommandConfirmation("resetcharacterdata", guid)
        controller.ArmDestructiveCommandConfirmation("resetcharacterdata", guid, 10.0)
        return "This will reset Iron Soul tracked data for the current character only. Enter is resetcharacterdata or is rcd again within 10 seconds to confirm."
    endif

    if !controller.ResetCurrentCharacterData(playerRef, guid)
        return "Error: failed to reset Iron Soul tracked data for the current character."
    endif

    return "Current character Iron Soul data reset to fresh state. Boss completion flags may reapply later if this save already reports those quests complete."
EndFunction

String Function PurgeData() Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in IronSoul.ini."
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

    if !controller.TryConsumeDestructiveCommandConfirmation("purgedata", guid)
        controller.ArmDestructiveCommandConfirmation("purgedata", guid, 10.0)
        return "This will purge Iron Soul tracked data for all characters except the current character. Enter is purgedata or is pd again within 10 seconds to confirm."
    endif

    Int purgedCount = controller.PurgeHistoricalCharacterData(guid)
    String suffix = "s"
    if purgedCount == 1
        suffix = ""
    endif
    return "Purged Iron Soul data for " + purgedCount + " non-current character" + suffix + ". Current character data was not changed."
EndFunction


; =============================
; --- INI / Config Commands ---
; =============================

Int Function GetIni(String k, Int fallback = 0) Global
    if k == ""
        return fallback
    endif
    return IronSoulNative.GetConfigInt(k, fallback)
EndFunction

String Function SetIni(String k, Int value, String persistFlag = "t") Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in IronSoul.ini."
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

    IronSoulController controller = ResolveControllerQuest()
    if controller
        controller.LoadConfig()
        Actor playerRef = Game.GetPlayer()
        if playerRef
            String guid = ResolveGuid(playerRef)
            if guid != ""
                controller.ApplyCharacterPresetLock(playerRef, guid)
                controller.SyncSoulPresentationAndStats(playerRef, guid)
            endif
        endif
    endif

    String mode = "cache-only"
    if persistToIni
        mode = "persisted"
    endif

    if controller
        return "Set " + k + "=" + value + " (" + mode + "). Controller config cache refreshed."
    endif
    return "Set " + k + "=" + value + " (" + mode + "). Native cache refreshed, but controller was unavailable."
EndFunction

String Function ReloadIni() Global
    Bool ok = IronSoulNative.ReloadConfig()
    if !ok
        return "Error: failed to reload IronSoul.ini."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if controller
        controller.LoadConfig()
        Actor playerRef = Game.GetPlayer()
        if playerRef
            String guid = ResolveGuid(playerRef)
            if guid != ""
                controller.ApplyCharacterPresetLock(playerRef, guid)
                controller.SyncSoulPresentationAndStats(playerRef, guid)
            endif
        endif
        return "Reloaded IronSoul.ini into native and controller config caches."
    endif
    return "Reloaded IronSoul.ini into native config cache. Controller was unavailable."
EndFunction
