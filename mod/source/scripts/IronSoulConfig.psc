Scriptname IronSoulConfig extends Quest

; --- Optional INI Settings ---
; =============================

; Central list of hidden optional INI settings. These settings may be omitted
; from the shipped INI when their default value is the desired public behavior.
; Add any key below to ironsoul.ini under the listed section to override it.
;
; [Sound] 
; CHIMTransitionSFX = 1
; DeathSFX = 1
; DefiantRestoreSFX = 1
; DefiantTransitionSFX = 1
; DragonSoulReviveCastSFX = 1
; DragonSoulReviveSFX = 1
; FeatUnlockSFX = 1
; HeartshardAbsorbSFX = 1
; IronIntroSFX = 1
; LuckOutcomeSFX = 1
; LuckRollSFX = 1
; PermadeathSFX = 1
; RespawnSFX = 1
; RespawnHeavyBreathingSFX = 1
; DeathSlowMoSFX = 1

; =========================
; --- Table of Contents ---
; =========================

; --- Config Loading & Preset Assets ---
; --------------------------------------
; ResetDefaults()
; ApplyPresetCoreSettings()
; LoadFromIni()
; ApplyDynamicPresetAssetsForTier()

; --- Loaded Config Queries ---
; -----------------------------
; IsLoggingEnabled()
; GetLogLevel()
; GetLogNotificationMode()
; IsRespawnEnabled()
; IsRespawnMessageEnabled()
; IsDeathMessageEnabled()
; IsDragonSoulReviveEnabled()
; IsDragonSoulReviveTransformEnabled()
; GetDragonSoulReviveLimit()
; IsDragonSoulReviveMessageEnabled()
; IsDragonSoulNotificationEnabled()
; IsCharacterJournalEnabled()
; GetLuckLevel()
; GetLuckRollMessageMode()
; IsCharacterSheetCompatibilityEnabled()
; IsCosaveRecoveryBackupEnabled()
; IsIronSoulIntroEnabled()
; GetIronSoulIntroDelaySeconds()
; IsHeartshardMessageEnabled()
; IsHeartshardNotificationEnabled()
; GetHeartshardInventoryMode()
; GetHeartshardTonalMaxTemper()
; IsSFXEnabled()
; IsMusicFadeEnabled()
; IsIronIntroSFXEnabled()
; IsDeathSFXEnabled()
; IsPermadeathSFXEnabled()
; IsRespawnSFXEnabled()
; IsDefiantTransitionSFXEnabled()
; IsCHIMTransitionSFXEnabled()
; IsDefiantRestoreSFXEnabled()
; IsHeartshardAbsorbSFXEnabled()
; IsDragonSoulReviveCastSFXEnabled()
; IsDragonSoulReviveSFXEnabled()
; IsFeatUnlockSFXEnabled()
; IsLuckRollSFXEnabled()
; IsLuckOutcomeSFXEnabled()
; IsRespawnHeavyBreathingSFXEnabled()
; IsDefiantSoulEnabled()
; IsSoulFeatsEnabled()
; IsSoulBonusEnabled()
; IsSoulFatigueEnabled()
; IsAnticheatEnabled()
; IsLuckReminderNotificationEnabled()
; IsLoadNotificationEnabled()
; IsUninstallMode()
; IsPermadeathEnabled()
; GetIronSoulPreset()
; SyncEffectiveDisplayDifficulty()

; --- Logging ---
; ---------------
; LogLevelTag()
; LogSourceTag()
; LogMsg()
; LogExternalMsg()
; LogComponentMsg()
; LogMsgSnapshot()
; LogComponentSnapshot()
; LogSnapshot()
; LOG_ERR()
; LOG_INFO()
; LOG_DBG()

; --- Config Helpers ---
; ----------------------
; ReadBool()
; ReadFeatureEnabled()
; ReadIntRange()
; NormalizeIronSoulPresetOrdinal()
; GetIronSoulPresetFamily()
; GetPresetOrdinalPlusRank()
; ClampDisplayDifficultyRank()
; GetEffectiveDisplayDifficultyRank()
; ClampLuckLevel()
; GetPresetLuckLevel()
; GetEffectiveLuckLevel()


; --- Loaded Config State ---
; ===========================

Bool _logEnabled = False
Int _logLevel = 2 ; 1=Errors, 2=Info, 3=Debug
Int _enableLogNotifications = 0

Bool _respawnEnabled = True
Bool _respawnMessageEnabled = True
Bool _deathMessageEnabled = True
Bool _dragonSoulReviveEnabled = True
Bool _dragonSoulReviveTransformEnabled = True
Int _dragonSoulReviveLimit = 3
Bool _dragonSoulReviveMessageEnabled = True
Bool _dragonSoulNotificationEnabled = True
Bool _characterJournalLogEnabled = True
Int _luckLevel = 5
Int _luckRollMessageMode = 1
Bool _enableCharacterSheetCompatibility = False
Bool _cosaveRecoveryBackupEnabled = True
Bool _ironSoulIntroEnabled = True
Int _ironSoulIntroDelaySeconds = 23
Bool _heartshardMessageEnabled = True
Bool _heartshardNotificationEnabled = True
Int _heartshardInventoryMode = 1 ; 0=legacy,1=reopen,2=close,3=mixed
Int _heartshardTonalMaxTemper = 10
Bool _sfxEnabled = True
Bool _musicFadeEnabled = True
Bool _ironIntroSFXEnabled = True
Bool _deathSFXEnabled = True
Bool _permadeathSFXEnabled = True
Bool _respawnSFXEnabled = True
Bool _defiantTransitionSFXEnabled = True
Bool _chimTransitionSFXEnabled = True
Bool _defiantRestoreSFXEnabled = True
Bool _heartshardAbsorbSFXEnabled = True
Bool _dragonSoulReviveCastSFXEnabled = True
Bool _dragonSoulReviveSFXEnabled = True
Bool _featUnlockSFXEnabled = True
Bool _luckRollSFXEnabled = True
Bool _luckOutcomeSFXEnabled = True
Bool _respawnHeavyBreathingSFXEnabled = True

Bool _defiantSoulEnabled = True
Bool _soulFeatsEnabled = True
Bool _soulBonusEnabled = True
Bool _soulFatigueEnabled = True
Bool _anticheatEnabled = True

Bool _luckReminderNotificationEnabled = True
Bool _loadNotificationEnabled = True

Bool _uninstallMode = False
Bool _permadeathEnabled = True
Int _ironSoulPresetOrdinal = 0


; --- Config Loading & Preset Assets ---
; ======================================

Function ResetDefaults()
    _logEnabled = False
    _logLevel = 2
    _enableLogNotifications = 0

    ; Messaging (SWF)
    _respawnMessageEnabled = True
    _dragonSoulReviveMessageEnabled = True
    _dragonSoulNotificationEnabled = True
    _ironSoulIntroEnabled = True
    _ironSoulIntroDelaySeconds = 23
    _heartshardMessageEnabled = True
    _heartshardNotificationEnabled = True
    _heartshardInventoryMode = 1
    _heartshardTonalMaxTemper = 10

    ; Gameplay / integration
    _respawnEnabled = True
    _deathMessageEnabled = True
    _enableCharacterSheetCompatibility = False
    _cosaveRecoveryBackupEnabled = True
    _dragonSoulReviveEnabled = True
    _dragonSoulReviveTransformEnabled = True
    _dragonSoulReviveLimit = 3
    _soulBonusEnabled = True
    _characterJournalLogEnabled = True
    _uninstallMode = False
    _permadeathEnabled = True
    _ironSoulPresetOrdinal = 0

    ; Luck / load notifications
    _luckReminderNotificationEnabled = True
    _luckLevel = 5
    _loadNotificationEnabled = True
    _luckRollMessageMode = 1

    ; Feats
    _defiantSoulEnabled = True
    _soulFeatsEnabled = True
    _soulFatigueEnabled = True

    ; Additional toggles (ensure defaults reset on reload)
    _anticheatEnabled = True
    _sfxEnabled = True
    _musicFadeEnabled = True
    _ironIntroSFXEnabled = True
    _deathSFXEnabled = True
    _permadeathSFXEnabled = True
    _respawnSFXEnabled = True
    _defiantTransitionSFXEnabled = True
    _chimTransitionSFXEnabled = True
    _defiantRestoreSFXEnabled = True
    _heartshardAbsorbSFXEnabled = True
    _dragonSoulReviveCastSFXEnabled = True
    _dragonSoulReviveSFXEnabled = True
    _featUnlockSFXEnabled = True
    _luckRollSFXEnabled = True
    _luckOutcomeSFXEnabled = True
    _respawnHeavyBreathingSFXEnabled = True
EndFunction

Function ApplyPresetCoreSettings(Bool iniPermadeath, Bool iniDefiantSoul)
    Int presetFamily = GetIronSoulPresetFamily(_ironSoulPresetOrdinal)
    if presetFamily == 1
        _permadeathEnabled = False
        _defiantSoulEnabled = True
    elseif presetFamily == 2
        _permadeathEnabled = True
        _defiantSoulEnabled = True
    elseif presetFamily == 3
        _permadeathEnabled = True
        _defiantSoulEnabled = False
    else
        _permadeathEnabled = iniPermadeath
        _defiantSoulEnabled = iniDefiantSoul
    endif
EndFunction

Function LoadFromIni()
    ResetDefaults()

    _ironSoulPresetOrdinal = NormalizeIronSoulPresetOrdinal(IronSoulNative.GetIronSoulPresetOrdinal())
    _luckLevel = GetEffectiveLuckLevel(_ironSoulPresetOrdinal)

    _logEnabled = ReadBool("EnableLogging", _logEnabled)
    _logLevel = ReadIntRange("LogLevel", _logLevel, 1, 3)
    _enableLogNotifications = ReadIntRange("EnableLogNotifications", _enableLogNotifications, 0, 1)

    _deathMessageEnabled = ReadFeatureEnabled("DeathMessage", True)
    _dragonSoulReviveEnabled = ReadFeatureEnabled("DragonSoulRevive", True)
    _dragonSoulReviveTransformEnabled = ReadFeatureEnabled("DragonSoulReviveTransform", True)
    _dragonSoulReviveLimit = ReadIntRange("DragonSoulReviveLimit", _dragonSoulReviveLimit, 0, 3)
    _dragonSoulReviveMessageEnabled = ReadFeatureEnabled("DragonSoulReviveMessage", True)
    _respawnEnabled = ReadFeatureEnabled("Respawn", True)
    _respawnMessageEnabled = ReadFeatureEnabled("RespawnMessage", True)
    _ironSoulIntroEnabled = ReadFeatureEnabled("IronSoulIntro", True)
    _ironSoulIntroDelaySeconds = ReadIntRange("IronSoulIntroDelaySeconds", _ironSoulIntroDelaySeconds, 0, 120)
    _heartshardMessageEnabled = ReadFeatureEnabled("HeartshardMessage", True)
    _heartshardNotificationEnabled = ReadFeatureEnabled("HeartshardNotification", True)
    _heartshardInventoryMode = ReadIntRange("HeartshardInventoryMode", _heartshardInventoryMode, 0, 3)
    _heartshardTonalMaxTemper = ReadIntRange("HeartshardTonalMaxTemper", _heartshardTonalMaxTemper, 1, 100)

    _soulBonusEnabled = ReadFeatureEnabled("SoulBonus", True)
    _characterJournalLogEnabled = ReadFeatureEnabled("CharacterJournal", True)
    _uninstallMode = ReadBool("UninstallMode", _uninstallMode)
    _enableCharacterSheetCompatibility = ReadBool("EnableCharacterSheetCompatibility", _enableCharacterSheetCompatibility)
    _cosaveRecoveryBackupEnabled = ReadFeatureEnabled("CosaveRecoveryBackup", True)

    Bool iniPermadeath = ReadFeatureEnabled("Permadeath", True)

    _luckReminderNotificationEnabled = ReadFeatureEnabled("LuckReminderNotification", True)
    _loadNotificationEnabled = ReadFeatureEnabled("LoadNotification", True)
    _luckRollMessageMode = ReadIntRange("LuckRollMessageMode", _luckRollMessageMode, 0, 2)

    Bool iniDefiantSoul = ReadFeatureEnabled("DefiantSoul", True)
    ApplyPresetCoreSettings(iniPermadeath, iniDefiantSoul)
    _soulFeatsEnabled = ReadFeatureEnabled("SoulFeats", True)
    _soulFatigueEnabled = ReadFeatureEnabled("SoulFatigue", True)

    _anticheatEnabled = ReadFeatureEnabled("Anticheat", True)
    _dragonSoulNotificationEnabled = ReadFeatureEnabled("DragonSoulNotification", True)
    _sfxEnabled = ReadFeatureEnabled("SFX", True)
    _musicFadeEnabled = ReadFeatureEnabled("MusicFade", True)
    _ironIntroSFXEnabled = ReadFeatureEnabled("IronIntroSFX", True)
    _deathSFXEnabled = ReadFeatureEnabled("DeathSFX", True)
    _permadeathSFXEnabled = ReadFeatureEnabled("PermadeathSFX", True)
    _respawnSFXEnabled = ReadFeatureEnabled("RespawnSFX", True)
    _defiantTransitionSFXEnabled = ReadFeatureEnabled("DefiantTransitionSFX", True)
    _chimTransitionSFXEnabled = ReadFeatureEnabled("CHIMTransitionSFX", True)
    _defiantRestoreSFXEnabled = ReadFeatureEnabled("DefiantRestoreSFX", True)
    _heartshardAbsorbSFXEnabled = ReadFeatureEnabled("HeartshardAbsorbSFX", True)
    _dragonSoulReviveCastSFXEnabled = ReadFeatureEnabled("DragonSoulReviveCastSFX", True)
    _dragonSoulReviveSFXEnabled = ReadFeatureEnabled("DragonSoulReviveSFX", True)
    _featUnlockSFXEnabled = ReadFeatureEnabled("FeatUnlockSFX", True)
    _luckRollSFXEnabled = ReadFeatureEnabled("LuckRollSFX", True)
    _luckOutcomeSFXEnabled = ReadFeatureEnabled("LuckOutcomeSFX", True)
    _respawnHeavyBreathingSFXEnabled = ReadFeatureEnabled("RespawnHeavyBreathingSFX", True)
EndFunction

Function ApplyDynamicPresetAssetsForTier(Int tierId)
    Int presetFamily = GetIronSoulPresetFamily(_ironSoulPresetOrdinal)
    IronSoulNative.ApplyDynamicSplash(tierId, presetFamily)
    IronSoulNative.ApplyDynamicDraugrEyes(presetFamily)
EndFunction


; --- Loaded Config Queries ---
; =============================

Bool Function IsLoggingEnabled()
    return _logEnabled
EndFunction

Int Function GetLogLevel()
    return _logLevel
EndFunction

Int Function GetLogNotificationMode()
    return _enableLogNotifications
EndFunction

Bool Function IsRespawnEnabled()
    return _respawnEnabled
EndFunction

Bool Function IsRespawnMessageEnabled()
    return _respawnMessageEnabled
EndFunction

Bool Function IsDeathMessageEnabled()
    return _deathMessageEnabled
EndFunction

Bool Function IsDragonSoulReviveEnabled()
    return _dragonSoulReviveEnabled
EndFunction

Bool Function IsDragonSoulReviveTransformEnabled()
    return _dragonSoulReviveTransformEnabled
EndFunction

Int Function GetDragonSoulReviveLimit()
    return _dragonSoulReviveLimit
EndFunction

Bool Function IsDragonSoulReviveMessageEnabled()
    return _dragonSoulReviveMessageEnabled
EndFunction

Bool Function IsDragonSoulNotificationEnabled()
    return _dragonSoulNotificationEnabled
EndFunction

Bool Function IsCharacterJournalEnabled()
    return _characterJournalLogEnabled
EndFunction

Int Function GetLuckLevel()
    return _luckLevel
EndFunction

Int Function GetLuckRollMessageMode()
    return _luckRollMessageMode
EndFunction

Bool Function IsCharacterSheetCompatibilityEnabled()
    return _enableCharacterSheetCompatibility
EndFunction

Bool Function IsCosaveRecoveryBackupEnabled()
    return _cosaveRecoveryBackupEnabled
EndFunction

Bool Function IsIronSoulIntroEnabled()
    return _ironSoulIntroEnabled
EndFunction

Int Function GetIronSoulIntroDelaySeconds()
    return _ironSoulIntroDelaySeconds
EndFunction

Bool Function IsHeartshardMessageEnabled()
    return _heartshardMessageEnabled
EndFunction

Bool Function IsHeartshardNotificationEnabled()
    return _heartshardNotificationEnabled
EndFunction

Int Function GetHeartshardInventoryMode()
    return _heartshardInventoryMode
EndFunction

Int Function GetHeartshardTonalMaxTemper()
    return _heartshardTonalMaxTemper
EndFunction

Bool Function IsSFXEnabled()
    return _sfxEnabled
EndFunction

Bool Function IsMusicFadeEnabled()
    return _musicFadeEnabled
EndFunction

Bool Function IsIronIntroSFXEnabled()
    return _ironIntroSFXEnabled
EndFunction

Bool Function IsDeathSFXEnabled()
    return _deathSFXEnabled
EndFunction

Bool Function IsPermadeathSFXEnabled()
    return _permadeathSFXEnabled
EndFunction

Bool Function IsRespawnSFXEnabled()
    return _respawnSFXEnabled
EndFunction

Bool Function IsDefiantTransitionSFXEnabled()
    return _defiantTransitionSFXEnabled
EndFunction

Bool Function IsCHIMTransitionSFXEnabled()
    return _chimTransitionSFXEnabled
EndFunction

Bool Function IsDefiantRestoreSFXEnabled()
    return _defiantRestoreSFXEnabled
EndFunction

Bool Function IsHeartshardAbsorbSFXEnabled()
    return _heartshardAbsorbSFXEnabled
EndFunction

Bool Function IsDragonSoulReviveCastSFXEnabled()
    return _dragonSoulReviveCastSFXEnabled
EndFunction

Bool Function IsDragonSoulReviveSFXEnabled()
    return _dragonSoulReviveSFXEnabled
EndFunction

Bool Function IsFeatUnlockSFXEnabled()
    return _featUnlockSFXEnabled
EndFunction

Bool Function IsLuckRollSFXEnabled()
    return _luckRollSFXEnabled
EndFunction

Bool Function IsLuckOutcomeSFXEnabled()
    return _luckOutcomeSFXEnabled
EndFunction

Bool Function IsRespawnHeavyBreathingSFXEnabled()
    return _respawnHeavyBreathingSFXEnabled
EndFunction

Bool Function IsDefiantSoulEnabled()
    return _defiantSoulEnabled
EndFunction

Bool Function IsSoulFeatsEnabled()
    return _soulFeatsEnabled
EndFunction

Bool Function IsSoulBonusEnabled()
    return _soulBonusEnabled
EndFunction

Bool Function IsSoulFatigueEnabled()
    return _soulFatigueEnabled
EndFunction

Bool Function IsAnticheatEnabled()
    return _anticheatEnabled
EndFunction

Bool Function IsLuckReminderNotificationEnabled()
    return _luckReminderNotificationEnabled
EndFunction

Bool Function IsLoadNotificationEnabled()
    return _loadNotificationEnabled
EndFunction

Bool Function IsUninstallMode()
    return _uninstallMode
EndFunction

Bool Function IsPermadeathEnabled()
    return _permadeathEnabled
EndFunction

Int Function GetIronSoulPreset()
    return _ironSoulPresetOrdinal
EndFunction

Function SyncEffectiveDisplayDifficulty(Bool respawnAvailable, Bool draugnarokEnabled)
    if !IronSoulNative.IsAvailable()
        return
    endif

    Int presetFamily = GetIronSoulPresetFamily(_ironSoulPresetOrdinal)
    Int displayRank = GetEffectiveDisplayDifficultyRank(_ironSoulPresetOrdinal, respawnAvailable, draugnarokEnabled)
    IronSoulNative.SetEffectiveDisplayDifficulty(presetFamily, displayRank)
EndFunction


; --- Logging ---
; ===============

Function LogMsg(Int level, String msg, Bool suppressNotify = False)
    if !_logEnabled
        return
    endif
    if level > _logLevel
        return
    endif

    if _enableLogNotifications == 1 && !suppressNotify
        Debug.Notification("[IS] " + msg)
    endif

    Debug.Trace("[IronSoul]" + " [" + LogLevelTag(level) + "] " + msg)
EndFunction

Function LogExternalMsg(String source, Int level, String msg, Bool suppressNotify = False)
    if msg == ""
        return
    endif

    LogMsg(level, "[" + LogSourceTag(source) + "] " + msg, suppressNotify)
EndFunction

Function LogComponentMsg(String source, Int level, String msg, Bool suppressNotify = False)
    if !_logEnabled
        return
    endif
    if level > _logLevel
        return
    endif

    source = LogSourceTag(source)

    if _enableLogNotifications == 1 && !suppressNotify
        Debug.Notification("[IS] " + msg)
    endif

    Debug.Trace("[IronSoul]" + " [" + LogLevelTag(level) + "] [" + source + "] " + msg)
EndFunction

Function LogMsgSnapshot(Int level, String msg)
    if !_logEnabled
        return
    endif
    if level > _logLevel
        return
    endif

    Debug.Trace("[IronSoul]" + " [" + LogLevelTag(level) + "] [Snapshot] " + msg)
EndFunction

Function LogComponentSnapshot(String source, Int level, String msg)
    if !_logEnabled
        return
    endif
    if level > _logLevel
        return
    endif

    Debug.Trace("[IronSoul]" + " [" + LogLevelTag(level) + "] [Snapshot] " + msg)
EndFunction

Function LogSnapshot()
    LogComponentSnapshot("Config", LOG_INFO(), "Config Core: Logging=" + _logEnabled \
        + " Level=" + _logLevel \
        + " Notify=" + _enableLogNotifications \
        + " Preset=" + _ironSoulPresetOrdinal \
        + " Permadeath=" + _permadeathEnabled \
        + " UninstallMode=" + _uninstallMode)

    LogComponentSnapshot("Config", LOG_INFO(), "Config Heartshards: HeartshardMessage=" + _heartshardMessageEnabled \
        + " HeartshardNotification=" + _heartshardNotificationEnabled \
        + " HeartshardInventoryMode=" + _heartshardInventoryMode \
        + " HeartshardTonalMaxTemper=" + _heartshardTonalMaxTemper)

    LogComponentSnapshot("Config", LOG_INFO(), "Config Systems: LuckLevel=" + _luckLevel \
        + " SoulBonus=" + _soulBonusEnabled \
        + " SoulFeats=" + _soulFeatsEnabled \
        + " DefiantSoul=" + _defiantSoulEnabled)

    LogComponentSnapshot("Config", LOG_INFO(), "Config DragonSoulRevive: DragonSoulRevive=" + _dragonSoulReviveEnabled \
        + " DragonSoulReviveTransform=" + _dragonSoulReviveTransformEnabled \
        + " DragonSoulNotify=" + _dragonSoulNotificationEnabled \
        + " DragonSoulReviveLimit=" + _dragonSoulReviveLimit)

    LogComponentSnapshot("Config", LOG_INFO(), "Config Sound Core: SFX=" + _sfxEnabled \
        + " MusicFade=" + _musicFadeEnabled \
        + " IronIntroSFX=" + _ironIntroSFXEnabled \
        + " DeathSFX=" + _deathSFXEnabled \
        + " PermadeathSFX=" + _permadeathSFXEnabled \
        + " RespawnSFX=" + _respawnSFXEnabled)

    LogComponentSnapshot("Config", LOG_INFO(), "Config Sound Transitions: DefiantTransitionSFX=" + _defiantTransitionSFXEnabled \
        + " CHIMTransitionSFX=" + _chimTransitionSFXEnabled \
        + " DefiantRestoreSFX=" + _defiantRestoreSFXEnabled)

    LogComponentSnapshot("Config", LOG_INFO(), "Config Sound Events: HeartshardAbsorbSFX=" + _heartshardAbsorbSFXEnabled \
        + " DragonSoulReviveCastSFX=" + _dragonSoulReviveCastSFXEnabled \
        + " DragonSoulReviveSFX=" + _dragonSoulReviveSFXEnabled \
        + " FeatUnlockSFX=" + _featUnlockSFXEnabled \
        + " LuckRollSFX=" + _luckRollSFXEnabled \
        + " LuckOutcomeSFX=" + _luckOutcomeSFXEnabled \
        + " RespawnHeavyBreathingSFX=" + _respawnHeavyBreathingSFXEnabled)
EndFunction

String Function LogLevelTag(Int level) Global
    if level == LOG_DBG()
        return "D"
    elseif level == LOG_INFO()
        return "I"
    endif
    return "E"
EndFunction

String Function LogSourceTag(String source) Global
    ; Papyrus folds equal string literals to one PEX table entry, so build display
    ; tags from fragments when a lowercase lookup key has different casing.
    if source == ""
        return "E" + "xternal"
    elseif source == "controller"
        return "C" + "ontroller"
    elseif source == "config"
        return "C" + "onfig"
    elseif source == "death"
        return "D" + "eath"
    elseif source == "dragonsoulrevive"
        return "D" + "ragonSoulRevive"
    elseif source == "draugnarok"
        return "D" + "raugnarok"
    elseif source == "effects"
        return "E" + "ffects"
    elseif source == "heartshards"
        return "H" + "eartshards"
    elseif source == "identity"
        return "I" + "dentity"
    elseif source == "journal"
        return "J" + "ournal"
    elseif source == "luck"
        return "L" + "uck"
    elseif source == "ondying"
        return "O" + "nDying"
    elseif source == "playeralias"
        return "P" + "layerAlias"
    elseif source == "respawn"
        return "R" + "espawn"
    elseif source == "tiers"
        return "T" + "iers"
    elseif source == "ui"
        return "U" + "I"
    endif
    return source
EndFunction

Int Function LOG_ERR() Global
    return 1
EndFunction

Int Function LOG_INFO() Global
    return 2
EndFunction

Int Function LOG_DBG() Global
    return 3
EndFunction


; --- Config Helpers ---
; ======================

Bool Function ReadBool(String configKey, Bool defaultValue) Global
    Int v = IronSoulNative.GetConfigInt(configKey, -1)
    if v == 0
        return False
    elseif v == 1
        return True
    endif
    return defaultValue
EndFunction

Bool Function ReadFeatureEnabled(String configKey, Bool defaultEnabled) Global
    return ReadBool(configKey, defaultEnabled)
EndFunction

Int Function ReadIntRange(String configKey, Int defaultValue, Int minV, Int maxV) Global
    Int v = IronSoulNative.GetConfigInt(configKey, -1)
    if v >= minV && v <= maxV
        return v
    endif
    return defaultValue
EndFunction

Int Function NormalizeIronSoulPresetOrdinal(Int presetOrdinal) Global
    if presetOrdinal == 0
        return 0
    elseif presetOrdinal >= 1 && presetOrdinal <= 3
        return presetOrdinal
    elseif presetOrdinal >= 5 && presetOrdinal <= 7
        return presetOrdinal
    elseif presetOrdinal >= 9 && presetOrdinal <= 11
        return presetOrdinal
    endif

    return 0
EndFunction

Int Function GetIronSoulPresetFamily(Int presetOrdinal) Global
    presetOrdinal = NormalizeIronSoulPresetOrdinal(presetOrdinal)
    if presetOrdinal >= 1 && presetOrdinal <= 3
        return 1
    elseif presetOrdinal >= 5 && presetOrdinal <= 7
        return 2
    elseif presetOrdinal >= 9 && presetOrdinal <= 11
        return 3
    endif
    return 0
EndFunction

Int Function GetPresetOrdinalPlusRank(Int presetOrdinal) Global
    presetOrdinal = NormalizeIronSoulPresetOrdinal(presetOrdinal)
    if presetOrdinal >= 1 && presetOrdinal <= 3
        return presetOrdinal - 1
    elseif presetOrdinal >= 5 && presetOrdinal <= 7
        return presetOrdinal - 5
    elseif presetOrdinal >= 9 && presetOrdinal <= 11
        return presetOrdinal - 9
    endif
    return 0
EndFunction

Int Function ClampDisplayDifficultyRank(Int displayRank) Global
    if displayRank < -1
        return -1
    elseif displayRank > 2
        return 2
    endif
    return displayRank
EndFunction

Int Function GetEffectiveDisplayDifficultyRank(Int presetOrdinal, Bool respawnAvailable, Bool draugnarokEnabled) Global
    presetOrdinal = NormalizeIronSoulPresetOrdinal(presetOrdinal)
    if presetOrdinal == 0
        return 0
    endif

    Int displayRank = GetPresetOrdinalPlusRank(presetOrdinal)
    if !respawnAvailable
        displayRank += 1
    endif
    if !draugnarokEnabled
        displayRank -= 1
    endif
    return ClampDisplayDifficultyRank(displayRank)
EndFunction

Int Function ClampLuckLevel(Int luckLevel) Global
    if luckLevel < 1
        return 1
    elseif luckLevel > 5
        return 5
    endif
    return luckLevel
EndFunction

Int Function GetPresetLuckLevel(Int presetOrdinal) Global
    Int presetFamily = GetIronSoulPresetFamily(presetOrdinal)
    if presetFamily == 1
        return 4
    elseif presetFamily == 2
        return 3
    elseif presetFamily == 3
        return 2
    endif
    return 5
EndFunction

Int Function GetEffectiveLuckLevel(Int presetOrdinal) Global
    presetOrdinal = NormalizeIronSoulPresetOrdinal(presetOrdinal)
    if presetOrdinal == 0
        return ClampLuckLevel(IronSoulNative.GetConfigInt("LuckLevel", 5))
    endif

    Int luckLevel = GetPresetLuckLevel(presetOrdinal)
    if GetPresetOrdinalPlusRank(presetOrdinal) >= 1
        luckLevel -= 1
    endif
    return ClampLuckLevel(luckLevel)
EndFunction
