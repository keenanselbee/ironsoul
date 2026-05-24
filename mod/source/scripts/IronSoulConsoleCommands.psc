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
;   Example: is help a
;   Example: is help hidden
; - State      (alias: s)    -> GetIronSoulState()
;   Example: is s
; - DraugnarokState (alias: d) -> DraugnarokState()
;   Example: is d
; - DraugnarokRaidChance (alias: rc) -> DraugnarokRaidChance()
;   Example: is rc
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
; - GetData    (alias: gdat) -> GetData(String section = "")
;   Example: is gdat
;   Example: is gdat soul
; - SetData    (alias: sdat) -> SetData(String key, String value)
;   Example: is sdat SoulTier 4
; - GetIni     (alias: gini) -> GetIni()
;   Example: is gini
; - SetIni     (alias: sini) -> SetIni(String key, String value, String persistFlag = "t")
;   Example: is sini SoulBonus 0 t
;   Preset-owned core keys, DraugrThreatLevel, and LuckLevel require IronSoulPreset=0. IronSoulPreset accepts values like 3++.
; - ReloadIni  (alias: rini) -> ReloadIni()
;   Example: is rini
; - DraugnarokForceOn (alias: don) -> DraugnarokForceOn()
; - DraugnarokForceOff (alias: doff) -> DraugnarokForceOff()
; - DraugnarokOverrideReset (alias: dreset) -> DraugnarokOverrideReset()
; - DraugnarokSmallRaid (alias: rsmall) -> DraugnarokSmallRaid()
;   Example: is rsmall
; - DraugnarokServiceRaid (alias: rservice) -> DraugnarokServiceRaid()
; - DraugnarokTownRaid (alias: rtown) -> DraugnarokTownRaid()
; - DraugnarokMediumRaid (alias: rmedium) -> DraugnarokMediumRaid()
; - DraugnarokPillageRaid (alias: rpillage) -> DraugnarokPillageRaid()
; - DraugnarokMinorCapitalRaid (alias: rminor) -> DraugnarokMinorCapitalRaid()
; - DraugnarokGateRaid (alias: rgate) -> DraugnarokGateRaid()
; - DraugnarokCapitalRaid (alias: rcapital) -> DraugnarokCapitalRaid()
; NOTE:
; - Privileged character state write/reset/destructive commands and manual raid triggers require EnableDebug=1 in ironsoul.ini.


; =========================
; --- Table of Contents ---
; =========================

; --- Helper & Parsing ---
; ------------------------
; ClampTier()
; IsCanonicalTier()
; IsNormalTier()
; ClampThreatLevel()
; ClampLuckLevel()
; ClampDeaths()
; ParsePersistFlag()
; ConfigFlagUninstallMode()
; ConfigFlagDraugnarokRefresh()
; HasConfigKeyFlag()
; ParseForceMode()

; --- Controller / GUID / Persistence Helpers ---
; -----------------------------------------------
; ResolveControllerQuest()
; ResolveDraugnarokQuest()
; IsDebugEnabled()
; IsCosaveRecoveryBackupEnabled()
; MakeScopedKey()
; ResolveGuid()
; ReadScopedInt()
; WriteScopedInt()
; WriteScopedIntChecked()
; IsDigitChar()
; IsStrictIntText()
; StartsWithText()
; StripCurrentGuidScope()
; NormalizeDataRawKey()
; ResolveKnownDataBase()
; KnownDataValueType()
; IsAllowedRawDataBase()
; ResolveDataTargetKey()
; TierLabel()
; DifficultyLabel()
; PresetPlusText()
; NormalizeIronSoulPresetOrdinal()
; GetIronSoulPresetFamily()
; GetPresetOrdinalPlusRank()
; NormalizeBoolInt()
; GetPresetThreatFloor()
; GetPresetLuckLevel()
; GetEffectivePermadeath()
; GetEffectiveDeathReset()
; GetEffectiveDefiantSoul()
; GetEffectiveDraugrThreatLevel()
; GetEffectiveLuckLevel()
; IronSoulPresetConfigText()
; NormalizeStateLabel()

; --- State & Tier Commands ---
; -----------------------------
; GetHelp()
; GetIronSoulState()
; SetTier()
; GetLuck()
; SetLuck()
; SetDeaths()
; SetDragonSoulsState()
; ResetTier()
; ResetCharacterData()
; PurgeData()
; GetData()
; SetData()
; TriggerDraugnarokRaid()
; DraugnarokState()
; DraugnarokRaidChance()
; SetDraugnarokOverride()
; DraugnarokForceOn()
; DraugnarokForceOff()
; DraugnarokOverrideReset()
; DraugnarokSmallRaid()
; DraugnarokServiceRaid()
; DraugnarokTownRaid()
; DraugnarokMediumRaid()
; DraugnarokPillageRaid()
; DraugnarokMinorCapitalRaid()
; DraugnarokGateRaid()
; DraugnarokCapitalRaid()

; --- INI / Config Commands ---
; -----------------------------
; GetIniValueLine()
; SafeUninstallGuidance()
; RefreshDraugnarokRuntime()
; GetIni()
; SetIni()
; ReloadIni()


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

Int Function ClampThreatLevel(Int threatValue) Global
    if threatValue < 1
        return 1
    elseif threatValue > 5
        return 5
    endif
    return threatValue
EndFunction

Int Function ClampLuckLevel(Int luckLevel) Global
    if luckLevel < 1
        return 1
    elseif luckLevel > 5
        return 5
    endif
    return luckLevel
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

Int Function ConfigFlagUninstallMode() Global
    return 16
EndFunction

Int Function ConfigFlagDraugnarokRefresh() Global
    return 32
EndFunction

Bool Function HasConfigKeyFlag(Int flags, Int flag) Global
    if flag <= 0
        return False
    endif

    Int quotient = flags / flag
    Int evenPart = (quotient / 2) * 2
    return quotient - evenPart == 1
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
    ; 0x000817 in Iron Soul - Dead God's Dream.esp (IronSoulControllerQuest)
    Quest q = Game.GetFormFromFile(0x00000817, "Iron Soul - Dead God's Dream.esp") as Quest
    if !q
        return None
    endif
    return q as IronSoulController
EndFunction

_DS_DN_Draugnarok Function ResolveDraugnarokQuest() Global
    ; 0x000D63 in Draugnarok.esp (_DS_Draugnarok_Main)
    Quest q = Game.GetFormFromFile(0x00000D63, "Draugnarok.esp") as Quest
    if !q
        q = Game.GetFormFromFile(0x00000D63, "Iron Soul - Dead God's Dream.esp") as Quest
    endif
    if !q
        return None
    endif
    return q as _DS_DN_Draugnarok
EndFunction

Bool Function IsDebugEnabled() Global
    return IronSoulNative.GetConfigInt("EnableDebug", 0) == 1
EndFunction

Bool Function IsCosaveRecoveryBackupEnabled() Global
    Int v = IronSoulNative.GetConfigInt("CosaveRecoveryBackup", -1)
    if v == 0
        return False
    endif
    return True
EndFunction

String Function MakeScopedKey(String baseKey, String guid) Global
    if baseKey == "" || guid == ""
        return ""
    endif
    return baseKey + ":" + guid
EndFunction

String Function ResolveGuid(Actor playerRef, IronSoulController controller = None) Global
    if !playerRef
        return ""
    endif
    if !controller
        controller = ResolveControllerQuest()
    endif
    if controller && controller.Identity
        return controller.Identity.GetTickGuid(playerRef)
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

    if IsCosaveRecoveryBackupEnabled() && StorageUtil.HasIntValue(playerRef, scopedKey)
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

    if IsCosaveRecoveryBackupEnabled()
        if !StorageUtil.HasIntValue(playerRef, scopedKey)
            StorageUtil.SetIntValue(playerRef, scopedKey, value)
        else
            Int currentCosave = StorageUtil.GetIntValue(playerRef, scopedKey)
            if currentCosave != value
                StorageUtil.SetIntValue(playerRef, scopedKey, value)
            endif
        endif
    endif
EndFunction

Bool Function WriteScopedIntChecked(Actor playerRef, String keyBase, Int value) Global
    String guid = ResolveGuid(playerRef)
    if guid == ""
        return False
    endif

    String scopedKey = MakeScopedKey(keyBase, guid)
    if scopedKey == ""
        return False
    endif

    if !IronSoulNative.DataSetIntChecked(scopedKey, value)
        return False
    endif

    if IsCosaveRecoveryBackupEnabled()
        if !StorageUtil.HasIntValue(playerRef, scopedKey)
            StorageUtil.SetIntValue(playerRef, scopedKey, value)
        else
            Int currentCosave = StorageUtil.GetIntValue(playerRef, scopedKey)
            if currentCosave != value
                StorageUtil.SetIntValue(playerRef, scopedKey, value)
            endif
        endif
    endif

    return True
EndFunction

Bool Function IsDigitChar(String c) Global
    return c == "0" || c == "1" || c == "2" || c == "3" || c == "4" || c == "5" || c == "6" || c == "7" || c == "8" || c == "9"
EndFunction

Bool Function IsStrictIntText(String value) Global
    Int len = StringUtil.GetLength(value)
    if len <= 0
        return False
    endif

    Int i = 0
    if StringUtil.GetNthChar(value, 0) == "-"
        if len == 1
            return False
        endif
        i = 1
    endif

    while i < len
        if !IsDigitChar(StringUtil.GetNthChar(value, i))
            return False
        endif
        i += 1
    endwhile

    return True
EndFunction

Bool Function StartsWithText(String value, String prefix) Global
    Int prefixLen = StringUtil.GetLength(prefix)
    if prefixLen <= 0
        return True
    endif
    if StringUtil.GetLength(value) < prefixLen
        return False
    endif
    return StringUtil.Substring(value, 0, prefixLen) == prefix
EndFunction

String Function StripCurrentGuidScope(String keyText, String guid) Global
    if StringUtil.Find(keyText, ":") == -1
        return keyText
    endif

    String suffix = ":" + guid
    Int suffixLen = StringUtil.GetLength(suffix)
    Int keyLen = StringUtil.GetLength(keyText)
    if keyLen > suffixLen && StringUtil.Substring(keyText, keyLen - suffixLen) == suffix
        return StringUtil.Substring(keyText, 0, keyLen - suffixLen)
    endif

    return "#FOREIGN_SCOPE#"
EndFunction

String Function NormalizeDataRawKey(String keyText, String guid) Global
    if keyText == "i.n" || keyText == "I.n" || keyText == "i.N"
        return "I.N"
    elseif keyText == "i.r" || keyText == "I.r" || keyText == "i.R"
        return "I.R"
    elseif keyText == "i.l" || keyText == "I.l" || keyText == "i.L"
        return "I.L"
    elseif keyText == "i.d" || keyText == "I.d" || keyText == "i.D"
        return "I.D"
    elseif keyText == "g.u.index" || keyText == "G.u.index" || keyText == "g.U.index" || keyText == "g.u.INDEX"
        return "G.U.INDEX"
    endif

    if StartsWithText(keyText, "g.u.")
        String guidPart = StringUtil.Substring(keyText, 4)
        if guidPart == guid
            return "G.U." + guid
        endif
        return keyText
    endif

    if StartsWithText(keyText, "is_") && StringUtil.GetLength(keyText) == 7
        Int i = 3
        while i < 7
            if !IsDigitChar(StringUtil.GetNthChar(keyText, i))
                return keyText
            endif
            i += 1
        endwhile
        return "IS_" + StringUtil.Substring(keyText, 3)
    endif

    return keyText
EndFunction

String Function ResolveKnownDataBase(String keyText, String guid) Global
    if keyText == "CharacterGuid" || keyText == "characterguid" || keyText == "IS_9975"
        return "CharacterGuid"
    elseif keyText == "GuidClaimed" || keyText == "guidclaimed" || keyText == ("G.U." + guid)
        return "G.U.CURRENT"
    elseif keyText == "GuidIndex" || keyText == "guidindex" || keyText == "G.U.INDEX"
        return "G.U.INDEX"
    elseif keyText == "IdentityName" || keyText == "identityname" || keyText == "I.N"
        return "I.N"
    elseif keyText == "IdentityRaceFormId" || keyText == "identityraceformid" || keyText == "I.R"
        return "I.R"
    elseif keyText == "IdentityLastSeenLevel" || keyText == "identitylastseenlevel" || keyText == "I.L"
        return "I.L"
    elseif keyText == "IdentityLastSeenGameDay" || keyText == "identitylastseengameday" || keyText == "I.D"
        return "I.D"
    elseif keyText == "CurrentDeaths" || keyText == "currentdeaths" || keyText == "IS_8155"
        return "IS_8155"
    elseif keyText == "LifetimeDeaths" || keyText == "lifetimedeaths" || keyText == "IS_9132"
        return "IS_9132"
    elseif keyText == "DraugnarokOverride" || keyText == "draugnarokoverride" || keyText == "IS_7341"
        return "IS_7341"
    elseif keyText == "LuckLastRealSecond" || keyText == "lucklastrealsecond" || keyText == "IS_7314"
        return "IS_7314"
    elseif keyText == "LuckPlayedToken" || keyText == "luckplayedtoken" || keyText == "IS_7315"
        return "IS_7315"
    elseif keyText == "LuckNotificationTier" || keyText == "lucknotificationtier" || keyText == "IS_7316"
        return "IS_7316"
    elseif keyText == "PostDeathLoadFlavorPending" || keyText == "postdeathloadflavorpending" || keyText == "IS_7317"
        return "IS_7317"
    elseif keyText == "IronIntroShown" || keyText == "ironintroshown" || keyText == "IS_8597"
        return "IS_8597"
    elseif keyText == "SilverFeatMessageShown" || keyText == "silverfeatmessageshown" || keyText == "IS_9921"
        return "IS_9921"
    elseif keyText == "GoldFeatMessageShown" || keyText == "goldfeatmessageshown" || keyText == "IS_4797"
        return "IS_4797"
    elseif keyText == "EbonFeatMessageShown" || keyText == "ebonfeatmessageshown" || keyText == "IS_4513"
        return "IS_4513"
    elseif keyText == "PlatinumFeatMessageShown" || keyText == "platinumfeatmessageshown" || keyText == "IS_1155"
        return "IS_1155"
    elseif keyText == "DevourFeatMessageShown" || keyText == "devourfeatmessageshown" || keyText == "IS_1156"
        return "IS_1156"
    elseif keyText == "SoulTier" || keyText == "soultier" || keyText == "IS_2204"
        return "IS_2204"
    elseif keyText == "ManualTierOverride" || keyText == "manualtieroverride" || keyText == "IS_2719"
        return "IS_2719"
    elseif keyText == "EbonFeatVariant" || keyText == "ebonfeatvariant" || keyText == "IS_4520"
        return "IS_4520"
    elseif keyText == "PlatinumFeatVariant" || keyText == "platinumfeatvariant" || keyText == "IS_4779"
        return "IS_4779"
    elseif keyText == "DragonSoulsStoredTotal" || keyText == "dragonsoulsstoredtotal" || keyText == "IS_9646"
        return "IS_9646"
    elseif keyText == "DragonSoulsLastSeenLive" || keyText == "dragonsoulslastseenlive" || keyText == "IS_7440"
        return "IS_7440"
    elseif keyText == "DragonSoulReviveLimitLastRealSecond" || keyText == "dragonsoulrevivelimitlastrealsecond" || keyText == "IS_8201"
        return "IS_8201"
    elseif keyText == "DragonSoulReviveLimitPlayedSeconds" || keyText == "dragonsoulrevivelimitplayedseconds" || keyText == "IS_8202"
        return "IS_8202"
    elseif keyText == "DragonSoulReviveRecentUse1" || keyText == "dragonsoulreviverecentuse1" || keyText == "IS_8203"
        return "IS_8203"
    elseif keyText == "DragonSoulReviveRecentUse2" || keyText == "dragonsoulreviverecentuse2" || keyText == "IS_8204"
        return "IS_8204"
    elseif keyText == "DragonSoulReviveRecentUse3" || keyText == "dragonsoulreviverecentuse3" || keyText == "IS_8205"
        return "IS_8205"
    elseif keyText == "MiraakKilled" || keyText == "miraakkilled" || keyText == "IS_4911"
        return "IS_4911"
    elseif keyText == "AlduinKilled" || keyText == "alduinkilled" || keyText == "IS_9897"
        return "IS_9897"
    elseif keyText == "HarkonKilled" || keyText == "harkonkilled" || keyText == "IS_9808"
        return "IS_9808"
    elseif keyText == "MolagBalKilled" || keyText == "molagbalkilled" || keyText == "IS_1627"
        return "IS_1627"
    elseif keyText == "DefiantFeatUnlocked" || keyText == "defiantfeatunlocked" || keyText == "IS_1989"
        return "IS_1989"
    elseif keyText == "DefiantStoredTier" || keyText == "defiantstoredtier" || keyText == "IS_9131"
        return "IS_9131"
    elseif keyText == "DefiantEnteredByConsole" || keyText == "defiantenteredbyconsole" || keyText == "IS_9136"
        return "IS_9136"
    elseif keyText == "CHIMEnteredByConsole" || keyText == "chimenteredbyconsole" || keyText == "IS_9137"
        return "IS_9137"
    elseif keyText == "JournalStartGameDay" || keyText == "journalstartgameday" || keyText == "IS_5341"
        return "IS_5341"
    elseif keyText == "JournalOpenerLogged" || keyText == "journalopenerlogged" || keyText == "IS_2270"
        return "IS_2270"
    elseif keyText == "JournalCHIMLogged" || keyText == "journalchimlogged" || keyText == "IS_1927"
        return "IS_1927"
    endif

    return ""
EndFunction

Int Function KnownDataValueType(String keyBase) Global
    if keyBase == "CharacterGuid" || keyBase == "I.N" || keyBase == "G.U.INDEX"
        return 2
    elseif keyBase == "G.U.CURRENT" || keyBase == "I.R" || keyBase == "I.L" || keyBase == "I.D" \
        || keyBase == "IS_8155" || keyBase == "IS_9132" || keyBase == "IS_7341" \
        || keyBase == "IS_7314" || keyBase == "IS_7315" || keyBase == "IS_7316" || keyBase == "IS_7317" \
        || keyBase == "IS_8597" || keyBase == "IS_9921" || keyBase == "IS_4797" || keyBase == "IS_4513" \
        || keyBase == "IS_1155" || keyBase == "IS_1156" || keyBase == "IS_2204" || keyBase == "IS_2719" \
        || keyBase == "IS_4520" || keyBase == "IS_4779" || keyBase == "IS_9646" || keyBase == "IS_7440" \
        || keyBase == "IS_8201" || keyBase == "IS_8202" || keyBase == "IS_8203" || keyBase == "IS_8204" \
        || keyBase == "IS_8205" || keyBase == "IS_4911" || keyBase == "IS_9897" || keyBase == "IS_9808" \
        || keyBase == "IS_1627" || keyBase == "IS_1989" || keyBase == "IS_9131" || keyBase == "IS_9136" \
        || keyBase == "IS_9137" || keyBase == "IS_5341" || keyBase == "IS_2270" || keyBase == "IS_1927"
        return 1
    endif

    return 0
EndFunction

Bool Function IsAllowedRawDataBase(String keyBase) Global
    if StartsWithText(keyBase, "G.U.")
        return False
    endif
    if StartsWithText(keyBase, "g.u.")
        return False
    endif
    return True
EndFunction

String Function ResolveDataTargetKey(String keyBase, String guid) Global
    if keyBase == "G.U.CURRENT"
        return "G.U." + guid
    elseif keyBase == "G.U.INDEX"
        return "G.U.INDEX"
    elseif keyBase == "CharacterGuid"
        return ""
    endif

    return MakeScopedKey(keyBase, guid)
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

String Function DifficultyLabel(Int presetOrdinal) Global
    presetOrdinal = NormalizeIronSoulPresetOrdinal(presetOrdinal)
    if presetOrdinal == 0
        return "Custom"
    endif

    Int presetFamily = GetIronSoulPresetFamily(presetOrdinal)
    String label = "Dreamer"
    if presetFamily == 2
        label = "Harbinger"
    elseif presetFamily == 3
        label = "Apocalypse"
    endif

    return label + PresetPlusText(presetOrdinal)
EndFunction

String Function PresetPlusText(Int presetOrdinal) Global
    Int plusCount = GetPresetOrdinalPlusRank(presetOrdinal)
    String text = ""
    while plusCount > 0
        text = text + "+"
        plusCount -= 1
    endwhile
    return text
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

Int Function NormalizeBoolInt(Int value, Int fallback) Global
    if value == 0 || value == 1
        return value
    endif
    return fallback
EndFunction

Int Function GetPresetThreatFloor(Int presetOrdinal) Global
    Int presetFamily = GetIronSoulPresetFamily(presetOrdinal)
    if presetFamily == 1
        return 2
    elseif presetFamily == 2
        return 3
    elseif presetFamily == 3
        return 4
    endif
    return 1
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

Int Function GetEffectivePermadeath(Int presetOrdinal) Global
    Int presetFamily = GetIronSoulPresetFamily(presetOrdinal)
    if presetFamily == 1
        return 0
    elseif presetFamily == 2 || presetFamily == 3
        return 1
    endif
    return NormalizeBoolInt(IronSoulNative.GetConfigInt("Permadeath", 1), 1)
EndFunction

Int Function GetEffectiveDeathReset(Int presetOrdinal) Global
    Int presetFamily = GetIronSoulPresetFamily(presetOrdinal)
    if presetFamily == 1 || presetFamily == 2
        return 1
    elseif presetFamily == 3
        return 0
    endif
    return NormalizeBoolInt(IronSoulNative.GetConfigInt("DeathReset", 1), 1)
EndFunction

Int Function GetEffectiveDefiantSoul(Int presetOrdinal) Global
    Int presetFamily = GetIronSoulPresetFamily(presetOrdinal)
    if presetFamily == 1 || presetFamily == 2
        return 1
    elseif presetFamily == 3
        return 0
    endif
    return NormalizeBoolInt(IronSoulNative.GetConfigInt("DefiantSoul", 1), 1)
EndFunction

Int Function GetEffectiveDraugrThreatLevel(Int presetOrdinal) Global
    presetOrdinal = NormalizeIronSoulPresetOrdinal(presetOrdinal)
    if presetOrdinal == 0
        return ClampThreatLevel(IronSoulNative.GetConfigInt("DraugrThreatLevel", 2))
    endif

    Int threatLevel = GetPresetThreatFloor(presetOrdinal)
    if IronSoulNative.GetConfigInt("DraugnarokSystem", 1) != 0 && GetPresetOrdinalPlusRank(presetOrdinal) >= 1
        threatLevel += 1
    endif
    return ClampThreatLevel(threatLevel)
EndFunction

Int Function GetEffectiveLuckLevel(Int presetOrdinal) Global
    presetOrdinal = NormalizeIronSoulPresetOrdinal(presetOrdinal)
    if presetOrdinal == 0
        return ClampLuckLevel(IronSoulNative.GetConfigInt("LuckLevel", 5))
    endif

    Int luckLevel = GetPresetLuckLevel(presetOrdinal)
    if GetPresetOrdinalPlusRank(presetOrdinal) >= 2
        luckLevel -= 1
    endif
    return ClampLuckLevel(luckLevel)
EndFunction

String Function IronSoulPresetConfigText(Int presetOrdinal) Global
    presetOrdinal = NormalizeIronSoulPresetOrdinal(presetOrdinal)
    Int presetFamily = GetIronSoulPresetFamily(presetOrdinal)
    String text = "" + presetFamily
    if presetFamily != 0
        text = text + PresetPlusText(presetOrdinal)
    endif
    return text
EndFunction

String Function NormalizeStateLabel(String value) Global
    if value == "" || value == "none" || value == "None" || value == "inactive"
        return "N/A"
    endif

    if value == "Defiant (Iron)"
        return "Defiant(Iron)"
    elseif value == "Defiant (Silver)"
        return "Defiant(Silver)"
    elseif value == "Defiant (Gold)"
        return "Defiant(Gold)"
    elseif value == "Defiant (Ebon)"
        return "Defiant(Ebon)"
    elseif value == "Defiant (Platinum)"
        return "Defiant(Platinum)"
    elseif value == "Defiant (Devour)"
        return "Defiant(Devour)"
    endif

    return value
EndFunction

; =============================
; --- State & Tier Commands ---
; =============================

String Function GetHelp(String helpTopic = "") Global
    if helpTopic == "h" || helpTopic == "H" || helpTopic == "hidden" || helpTopic == "Hidden" || helpTopic == "HIDDEN"
        return "Iron Soul hidden commands (EnableDebug required):\n" \
            + "rcd: reset current character data; double-confirm.\n" \
            + "pd: purge non-current character data; double-confirm.\n" \
            + "gdat [section]: get current character data; sections: identity, core, luck, ui, soul, dsr, bosses, defiant, journal.\n" \
            + "sdat <key> <value>: set current character data."
    endif

    if helpTopic == "a" || helpTopic == "A" || helpTopic == "advanced" || helpTopic == "Advanced" || helpTopic == "ADVANCED"
        return "Iron Soul advanced commands (EnableDebug required):\n" \
            + "st <tier> [f|force]: set tier.\n" \
            + "rt: reset tier.\n" \
            + "sl <luck>: set luck.\n" \
            + "sd <deaths>: set deaths.\n" \
            + "sds <total>: set dragon soul total.\n" \
            + "don/doff/dreset: force Draugnarok on, force off, or clear override.\n" \
            + "rsmall/rservice/rtown/rmedium/rpillage/rminor/rgate/rcapital: trigger Draugnarok raids."
    endif

    return "Iron Soul commands:\n" \
        + "s: Iron Soul state summary.\n" \
        + "l: get current luck.\n" \
        + "d: Draugnarok state summary.\n" \
        + "rc: calculate current Draugnarok raid chance.\n" \
        + "gini: list INI options and effective preset-owned core values.\n" \
        + "sini <key> <value> [t|f]: set INI; IronSoulPreset accepts 3++, Override-only keys require IronSoulPreset=0.\n" \
        + "rini: reload INI."
EndFunction

String Function GetIronSoulState() Global
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif
    String guid = ResolveGuid(playerRef, controller)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif

    if !controller.Tiers
        return "Error: IronSoulTiers is not wired."
    endif
    if !controller.Death
        return "Error: IronSoulDeath is not wired."
    endif
    if !controller.Effects
        return "Error: IronSoulEffects is not wired."
    endif

    Int tierValue = ClampTier(controller.Tiers.GetCurrentTier(playerRef, guid))
    Int difficultyValue = NormalizeIronSoulPresetOrdinal(IronSoulNative.GetIronSoulPresetOrdinal())
    Int deathValue = ClampDeaths(controller.Death.GetCurrentDeathCount(playerRef, guid))
    Int totalDeathValue = ClampDeaths(controller.Death.GetTotalDeaths(playerRef, guid))
    Int soulsTotal = ClampDeaths(controller.Tiers.GetDragonSoulsTotal(playerRef, guid))
    String soulBonusState = NormalizeStateLabel(controller.Effects.GetAppliedSoulBonusSpellCompactLabel(playerRef))
    String soulFatigueState = NormalizeStateLabel(controller.Effects.GetAppliedSoulFatigueSpellCompactLabel(playerRef))
    return "GUID=" + guid \
        + " | Difficulty=" + DifficultyLabel(difficultyValue) \
        + " | Tier=" + TierLabel(tierValue) + "(" + tierValue + ")" \
        + " | Deaths=" + deathValue \
        + " | TotalDeaths=" + totalDeathValue \
        + " | TotalDragonSouls=" + soulsTotal \
        + " | SoulBonus=" + soulBonusState \
        + " | SoulFatigue=" + soulFatigueState
EndFunction

String Function SetTier(Int tierValue, String forceMode = "") Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in ironsoul.ini."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif
    String guid = ResolveGuid(playerRef, controller)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif
    if !controller.Death
        return "Error: IronSoulDeath is not wired."
    endif
    if !controller.Tiers
        return "Error: IronSoulTiers is not wired."
    endif

    Int parsedForce = ParseForceMode(forceMode)
    if parsedForce == -1
        return "Error: force flag must be empty, f, or force."
    endif

    if !IsCanonicalTier(tierValue)
        return "Error: tier must be one of 0, 1, 2, 3, 4, 5, 6, or 9."
    endif

    return controller.Tiers.SetTierFromConsole(playerRef, guid, tierValue, parsedForce)
EndFunction

String Function GetLuck() Global
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif
    String guid = ResolveGuid(playerRef, controller)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif

    if !controller.Luck
        return "Error: IronSoulLuck is not wired."
    endif

    ; Follow the same live path used by runtime Luck logic.
    Int nowSec = Utility.GetCurrentRealTime() as Int
    controller.Luck.EnsureLoaded(playerRef, guid, nowSec)

    Int maxLuck = controller.Luck.GetCurrentMax(playerRef, guid)

    Int luck = controller.Luck.GetValue(playerRef, guid)
    if luck < 0
        luck = 0
    elseif luck > maxLuck
        luck = maxLuck
    endif

    return "Luck: " + luck
EndFunction

String Function SetLuck(Int luckValue) Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in ironsoul.ini."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif
    String guid = ResolveGuid(playerRef, controller)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif

    if !controller.Luck
        return "Error: IronSoulLuck is not wired."
    endif

    Int maxLuck = controller.Luck.GetCurrentMax(playerRef, guid)

    Int appliedLuck = controller.Luck.SetValue(playerRef, guid, luckValue)
    if appliedLuck < 0
        return "Error: failed to set luck."
    endif

    IronSoulNative.DataFlushIfDirty()
    return "Luck set to " + appliedLuck + " (max " + maxLuck + ")."
EndFunction

String Function SetDeaths(Int deathsValue) Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in ironsoul.ini."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif
    String guid = ResolveGuid(playerRef, controller)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif
    if !controller.Death
        return "Error: IronSoulDeath is not wired."
    endif
    if !controller.Tiers
        return "Error: IronSoulTiers is not wired."
    endif
    if !controller.Effects
        return "Error: IronSoulEffects is not wired."
    endif

    Int previousTier = ClampTier(controller.Tiers.GetCurrentTier(playerRef, guid))
    Int clampedDeaths = ClampDeaths(deathsValue)
    controller.Death.SetCurrentDeathCount(playerRef, guid, clampedDeaths)
    controller.Tiers.HandleProgressionRelevantChange(playerRef, guid)
    Int actualDeaths = ClampDeaths(controller.Death.GetCurrentDeathCount(playerRef, guid))
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
        return "Debug disabled. Set EnableDebug=1 in ironsoul.ini."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif
    String guid = ResolveGuid(playerRef, controller)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif
    if !controller.Tiers
        return "Error: IronSoulTiers is not wired."
    endif

    return controller.Tiers.SetDragonSoulsTotalFromConsole(playerRef, guid, totalValue)
EndFunction

String Function ResetTier() Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in ironsoul.ini."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif
    String guid = ResolveGuid(playerRef, controller)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif
    if !controller.Tiers
        return "Error: IronSoulTiers is not wired."
    endif

    return controller.Tiers.ResetTierFromConsole(playerRef, guid)
EndFunction

String Function ResetCharacterData() Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in ironsoul.ini."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif
    String guid = ResolveGuid(playerRef, controller)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif
    if !controller.Cleanup
        return "Error: IronSoulCleanup component is not available."
    endif

    if !controller.Cleanup.TryConsumeDestructiveCommandConfirmation("resetcharacterdata", guid)
        controller.Cleanup.ArmDestructiveCommandConfirmation("resetcharacterdata", guid, 10.0)
        return "This will reset Iron Soul tracked data for the current character only. Enter is resetcharacterdata or is rcd again within 10 seconds to confirm."
    endif

    if !controller.Cleanup.ResetCurrentCharacterData(playerRef, guid)
        return "Error: failed to reset Iron Soul tracked data for the current character."
    endif

    return "Current character Iron Soul data reset to fresh state. Boss completion flags may reapply later if this save already reports those quests complete."
EndFunction

String Function PurgeData() Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in ironsoul.ini."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    IronSoulController controller = ResolveControllerQuest()
    if !controller
        return "Error: IronSoulControllerQuest is not available."
    endif
    String guid = ResolveGuid(playerRef, controller)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif
    if !controller.Cleanup
        return "Error: IronSoulCleanup component is not available."
    endif

    if !controller.Cleanup.TryConsumeDestructiveCommandConfirmation("purgedata", guid)
        controller.Cleanup.ArmDestructiveCommandConfirmation("purgedata", guid, 10.0)
        return "This will purge Iron Soul tracked data for all characters except the current character. Enter is purgedata or is pd again within 10 seconds to confirm."
    endif

    Int purgedCount = controller.Cleanup.PurgeHistoricalCharacterData(guid)
    String suffix = "s"
    if purgedCount == 1
        suffix = ""
    endif
    return "Purged Iron Soul data for " + purgedCount + " non-current character" + suffix + ". Current character data was not changed."
EndFunction

String Function GetData(String section = "") Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in ironsoul.ini."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    String guid = ResolveGuid(playerRef)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif

    return IronSoulNative.DataGetCharacterData(guid, section)
EndFunction

String Function SetData(String k, String value) Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in ironsoul.ini."
    endif

    if k == ""
        return "Error: data key cannot be empty."
    endif

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Error: player reference is not available."
    endif

    String guid = ResolveGuid(playerRef)
    if guid == ""
        return "Error: character GUID is not initialized yet."
    endif

    String requestedBase = StripCurrentGuidScope(k, guid)
    if requestedBase == "#FOREIGN_SCOPE#"
        return "Error: scoped data key belongs to a different GUID."
    endif
    if requestedBase == ""
        return "Error: data key cannot be empty."
    endif

    requestedBase = NormalizeDataRawKey(requestedBase, guid)

    String keyBase = ResolveKnownDataBase(requestedBase, guid)
    if keyBase == ""
        keyBase = requestedBase
    endif

    if keyBase == "CharacterGuid" || keyBase == "IS_9975"
        return "Error: CharacterGuid is read-only; it is stored in the authoritative co-save identity slot."
    endif

    Int valueType = KnownDataValueType(keyBase)
    if valueType == 0 && !IsAllowedRawDataBase(keyBase)
        return "Error: unknown global data key '" + k + "'. Use a friendly key, current-character raw key, G.U.INDEX, or G.U.<currentGuid>."
    endif

    String targetKey = ResolveDataTargetKey(keyBase, guid)
    if targetKey == ""
        return "Error: failed to resolve data key '" + k + "'."
    endif

    if valueType == 1
        if !IsStrictIntText(value)
            return "Error: data key '" + k + "' requires an integer value."
        endif

        Int intValue = value as Int
        Bool intWriteOk = False
        if StartsWithText(keyBase, "IS_")
            intWriteOk = WriteScopedIntChecked(playerRef, keyBase, intValue)
        else
            intWriteOk = IronSoulNative.DataSetIntChecked(targetKey, intValue)
        endif
        if !intWriteOk
            return "Error: failed to write data key '" + targetKey + "'; MainData rejected the key or value."
        endif
        IronSoulNative.DataFlushIfDirty()
        return "Set " + targetKey + "=" + intValue + "."
    elseif valueType == 2
        if !IronSoulNative.DataSetStringChecked(targetKey, value)
            return "Error: failed to write data key '" + targetKey + "'; MainData rejected the key or value."
        endif
        IronSoulNative.DataFlushIfDirty()
        return "Set " + targetKey + "=\"" + value + "\"."
    endif

    if IsStrictIntText(value)
        Int inferredIntValue = value as Int
        Bool inferredIntWriteOk = False
        if StartsWithText(keyBase, "IS_")
            inferredIntWriteOk = WriteScopedIntChecked(playerRef, keyBase, inferredIntValue)
        else
            inferredIntWriteOk = IronSoulNative.DataSetIntChecked(targetKey, inferredIntValue)
        endif
        if !inferredIntWriteOk
            return "Error: failed to write data key '" + targetKey + "'; MainData rejected the key or value."
        endif
        IronSoulNative.DataFlushIfDirty()
        return "Set " + targetKey + "=" + inferredIntValue + "."
    endif

    if !IronSoulNative.DataSetStringChecked(targetKey, value)
        return "Error: failed to write data key '" + targetKey + "'; MainData rejected the key or value."
    endif
    IronSoulNative.DataFlushIfDirty()
    return "Set " + targetKey + "=\"" + value + "\"."
EndFunction

String Function TriggerDraugnarokRaid(Int raidType, String raidLabel) Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in ironsoul.ini."
    endif

    _DS_DN_Draugnarok draugnarok = ResolveDraugnarokQuest()
    if !draugnarok
        return "Error: Draugnarok quest is not available."
    endif

    if !draugnarok.IsDraugnarokSystemEnabled()
        return "DraugnarokSystem=0. Enable DraugnarokSystem before triggering manual raids."
    endif

    if draugnarok.TriggerManualRaid(raidType, raidLabel)
        return "Attempting to trigger Draugnarok " + raidLabel + "."
    endif
    return "Failed to trigger Draugnarok " + raidLabel + "."
EndFunction

String Function DraugnarokState() Global
    _DS_DN_Draugnarok draugnarok = ResolveDraugnarokQuest()
    if !draugnarok
        return "Error: Draugnarok quest is not available."
    endif

    return draugnarok.GetDraugnarokStateSummary()
EndFunction

String Function DraugnarokRaidChance() Global
    _DS_DN_Draugnarok draugnarok = ResolveDraugnarokQuest()
    if !draugnarok
        return "Error: Draugnarok quest is not available."
    endif

    return draugnarok.GetCurrentRaidChanceSummary()
EndFunction

String Function SetDraugnarokOverride(Int mode, String label) Global
    if !IsDebugEnabled()
        return "Debug disabled. Set EnableDebug=1 in ironsoul.ini."
    endif

    _DS_DN_Draugnarok draugnarok = ResolveDraugnarokQuest()
    if !draugnarok
        return "Error: Draugnarok quest is not available."
    endif

    if mode == 1 && !draugnarok.IsDraugnarokSystemEnabled()
        return "DraugnarokSystem=0. Enable DraugnarokSystem before forcing Draugnarok on."
    endif

    if draugnarok.SetDraugnarokOverrideMode(mode, True)
        if mode == 0 && !draugnarok.IsDraugnarokSystemEnabled()
            return "Draugnarok override: cleared. Normal rules restored, but DraugnarokSystem=0 keeps the system disabled."
        endif
        return "Draugnarok override: " + label + "."
    endif

    return "Error: failed to set Draugnarok override for the current character."
EndFunction

String Function DraugnarokForceOn() Global
    return SetDraugnarokOverride(1, "force on")
EndFunction

String Function DraugnarokForceOff() Global
    return SetDraugnarokOverride(2, "force off")
EndFunction

String Function DraugnarokOverrideReset() Global
    return SetDraugnarokOverride(0, "cleared")
EndFunction

String Function DraugnarokSmallRaid() Global
    return TriggerDraugnarokRaid(1, "small death squad")
EndFunction

String Function DraugnarokServiceRaid() Global
    return TriggerDraugnarokRaid(7, "service death squad")
EndFunction

String Function DraugnarokTownRaid() Global
    return TriggerDraugnarokRaid(2, "town raid")
EndFunction

String Function DraugnarokMediumRaid() Global
    return TriggerDraugnarokRaid(3, "medium death squad")
EndFunction

String Function DraugnarokPillageRaid() Global
    return TriggerDraugnarokRaid(8, "pillage squad")
EndFunction

String Function DraugnarokMinorCapitalRaid() Global
    return TriggerDraugnarokRaid(4, "minor capital raid")
EndFunction

String Function DraugnarokGateRaid() Global
    return TriggerDraugnarokRaid(5, "gate crasher raid")
EndFunction

String Function DraugnarokCapitalRaid() Global
    return TriggerDraugnarokRaid(6, "capital raid")
EndFunction

; =============================
; --- INI / Config Commands ---
; =============================

String Function GetIniValueLine(String k, Int fallback) Global
    return k + "=" + IronSoulNative.GetConfigInt(k, fallback)
EndFunction

String Function SafeUninstallGuidance(Bool persistToIni) Global
    if persistToIni
        return " Safe uninstall is armed for next load: save, reload, wait for the disabled message, then save again before removing the mod."
    endif
    return " Cache-only UninstallMode will not run the safe uninstall flow on next load unless it is persisted to ironsoul.ini."
EndFunction

String Function RefreshDraugnarokRuntime() Global
    _DS_DN_Draugnarok draugnarok = ResolveDraugnarokQuest()
    if !draugnarok
        return " Draugnarok runtime refresh skipped: quest unavailable."
    endif

    Int mode = draugnarok.GetDraugnarokOverrideMode()
    draugnarok.ApplyDraugnarokOverrideMode(mode)
    return " Draugnarok runtime refreshed."
EndFunction

String Function GetIni() Global
    return IronSoulNative.GetConfigSummary()
EndFunction

String Function SetIni(String k, String value, String persistFlag = "t") Global
    if k == ""
        return "Error: config key cannot be empty."
    endif

    Int parsedPersist = ParsePersistFlag(persistFlag)
    if parsedPersist == -1
        return "Error: persist flag must be t/T/f/F/true/false."
    endif

    Bool persistToIni = (parsedPersist == 1)

    String validationError = IronSoulNative.GetConfigSetError(k, value)
    if validationError != ""
        return validationError
    endif

    String canonicalKey = IronSoulNative.GetConfigKeyCanonical(k)
    if canonicalKey == ""
        return "Error: unknown INI key '" + k + "'."
    endif

    String displayName = IronSoulNative.GetConfigKeyDisplayName(k)
    if displayName == ""
        displayName = k
    endif

    Int keyFlags = IronSoulNative.GetConfigKeyFlags(k)
    Bool ok = IronSoulNative.SetConfigString(k, value, persistToIni)
    if !ok
        return "Error: failed to set INI key '" + displayName + "'."
    endif

    IronSoulController controller = ResolveControllerQuest()
    Bool configLoaded = False
    if controller
        configLoaded = controller.LoadConfig()
        if configLoaded
            Int soulTier = 1
            Actor playerRef = Game.GetPlayer()
            if playerRef
                String guid = ResolveGuid(playerRef, controller)
                if guid != ""
                    if controller.Effects
                        controller.Effects.SyncSoulPresentationAndStats(playerRef, guid)
                    endif
                    if controller.Luck
                        controller.Luck.SyncNotifiedTierToCurrent(playerRef, guid)
                    endif
                    if controller.Tiers
                        soulTier = ClampTier(controller.Tiers.GetCurrentTier(playerRef, guid))
                    endif
                    if controller.Globals
                        controller.Globals.SyncAll(playerRef, guid)
                    endif
                endif
            endif
            if controller.Config
                controller.Config.ApplyDynamicPresetAssetsForTier(soulTier)
            endif
            IronSoulNative.ApplyDynamicLevelWidget(soulTier)
        endif
    endif
    String mode = "cache-only"
    if persistToIni
        mode = "persisted"
    endif

    String result = "Set " + displayName + "=" + value + " (" + mode + ")."
    if configLoaded
        result = result + " Iron Soul config component refreshed."
    elseif controller
        result = result + " Native cache refreshed, but controller config refresh failed; check the Iron Soul log for the missing component."
    else
        result = result + " Native cache refreshed, but controller was unavailable."
    endif

    if HasConfigKeyFlag(keyFlags, ConfigFlagDraugnarokRefresh())
        result = result + RefreshDraugnarokRuntime()
    endif

    if HasConfigKeyFlag(keyFlags, ConfigFlagUninstallMode()) && IronSoulNative.GetConfigInt(canonicalKey, 0) == 1
        result = result + SafeUninstallGuidance(persistToIni)
    endif
    return result
EndFunction

String Function ReloadIni() Global
    Bool ok = IronSoulNative.ReloadConfig()
    if !ok
        return "Error: failed to reload ironsoul.ini."
    endif

    IronSoulController controller = ResolveControllerQuest()
    String result = ""
    if controller
        if controller.LoadConfig()
            Int soulTier = 1
            Actor playerRef = Game.GetPlayer()
            if playerRef
                String guid = ResolveGuid(playerRef, controller)
                if guid != ""
                    if controller.Effects
                        controller.Effects.SyncSoulPresentationAndStats(playerRef, guid)
                    endif
                    if controller.Luck
                        controller.Luck.SyncNotifiedTierToCurrent(playerRef, guid)
                    endif
                    if controller.Tiers
                        soulTier = ClampTier(controller.Tiers.GetCurrentTier(playerRef, guid))
                    endif
                    if controller.Globals
                        controller.Globals.SyncAll(playerRef, guid)
                    endif
                endif
            endif
            if controller.Config
                controller.Config.ApplyDynamicPresetAssetsForTier(soulTier)
            endif
            IronSoulNative.ApplyDynamicLevelWidget(soulTier)
            result = "Reloaded ironsoul.ini into native cache and Iron Soul config component."
        else
            result = "Reloaded ironsoul.ini into native config cache. Controller config refresh failed; check the Iron Soul log for the missing component."
        endif
    else
        result = "Reloaded ironsoul.ini into native config cache. Controller was unavailable."
    endif

    result = result + RefreshDraugnarokRuntime()
    if IronSoulNative.GetConfigInt("UninstallMode", 0) == 1
        result = result + SafeUninstallGuidance(True)
    endif
    return result
EndFunction
