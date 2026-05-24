Scriptname IronSoulGlobals extends Quest

; --- Public Compatibility Globals ---
; ====================================
;
; These globals are read-only compatibility mirrors for other mods.
; Iron Soul is the only writer. Other mods may read them but should not
; change them. These globals are not authoritative game state.
;
; Most mirrors expose direct values such as current deaths, soul tier, luck, and
; effective max lives. Status mirrors use small integer states:
; IronSoul_RespawnStatus: 0 unavailable, 1 runtime available.
; IronSoul_DraugnarokStatus: 0 inactive, 1 dormant, 2 active or forced.
; IronSoul_ModDisabled: 0 enabled, 1 disabled by Iron Soul safety checks or uninstall.
; IronSoul_DifficultyPreset stores the native INI preset ordinal.
;
; Developer lookup snippets. Game.GetFormFromFile expects plugin-local FormIDs,
; so use these IDs without the current load-order byte:
; Game.GetFormFromFile(0x0000026E, "Iron Soul - Dead God's Dream.esp") as GlobalVariable ; IronSoul_DeathCount
; Game.GetFormFromFile(0x0000026F, "Iron Soul - Dead God's Dream.esp") as GlobalVariable ; IronSoul_TotalDeathCount
; Game.GetFormFromFile(0x00000270, "Iron Soul - Dead God's Dream.esp") as GlobalVariable ; IronSoul_SoulTier
; Game.GetFormFromFile(0x00000271, "Iron Soul - Dead God's Dream.esp") as GlobalVariable ; IronSoul_EffectiveMaxLives
; Game.GetFormFromFile(0x00000272, "Iron Soul - Dead God's Dream.esp") as GlobalVariable ; IronSoul_Luck
; Game.GetFormFromFile(0x00000273, "Iron Soul - Dead God's Dream.esp") as GlobalVariable ; IronSoul_LuckMax
; Game.GetFormFromFile(0x00000274, "Iron Soul - Dead God's Dream.esp") as GlobalVariable ; IronSoul_DifficultyPreset
; Game.GetFormFromFile(0x00000275, "Iron Soul - Dead God's Dream.esp") as GlobalVariable ; IronSoul_RespawnStatus
; Game.GetFormFromFile(0x00000276, "Iron Soul - Dead God's Dream.esp") as GlobalVariable ; IronSoul_DraugnarokStatus
; Game.GetFormFromFile(0x00000B12, "Iron Soul - Dead God's Dream.esp") as GlobalVariable ; IronSoul_ModDisabled

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()

; --- Public Global Sync ---
; --------------------------
; SyncAll()
; SyncDeath()
; SyncTier()
; SyncLuck()
; SyncLuckValues()
; SyncDifficultyPreset()
; SyncIntegrationStatus()
; SyncModState()
; ResetGlobals()

; --- Global Helpers ---
; ----------------------
; ResolveDraugnarokStatus()
; SetGlobalInt()


; --- Wired Dependencies ---
; ==========================

IronSoulController Property Controller Auto

GlobalVariable Property IronSoul_DeathCount Auto
GlobalVariable Property IronSoul_TotalDeathCount Auto
GlobalVariable Property IronSoul_SoulTier Auto
GlobalVariable Property IronSoul_EffectiveMaxLives Auto
GlobalVariable Property IronSoul_Luck Auto
GlobalVariable Property IronSoul_LuckMax Auto
GlobalVariable Property IronSoul_DifficultyPreset Auto
GlobalVariable Property IronSoul_RespawnStatus Auto
GlobalVariable Property IronSoul_DraugnarokStatus Auto
GlobalVariable Property IronSoul_ModDisabled Auto


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Persistence || !Controller.Death
        return False
    endif
    if !Controller.Tiers || !Controller.Luck || !Controller.Respawn
        return False
    endif
    return True
EndFunction


; --- Public Global Sync ---
; ==========================

Function SyncAll(Actor player, String guid)
    SyncDeath(player, guid)
    SyncTier(player, guid)
    SyncLuck(player, guid)
    SyncDifficultyPreset()
    SyncIntegrationStatus(player)
    SyncModState()
EndFunction

Function SyncDeath(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        SetGlobalInt(IronSoul_DeathCount, 0)
        SetGlobalInt(IronSoul_TotalDeathCount, 0)
        return
    endif

    if Controller.Death
        SetGlobalInt(IronSoul_DeathCount, Controller.Death.GetCurrentDeathCount(player, guid))
        SetGlobalInt(IronSoul_TotalDeathCount, Controller.Death.GetTotalDeaths(player, guid))
    endif
EndFunction

Function SyncTier(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        SetGlobalInt(IronSoul_SoulTier, 0)
        SetGlobalInt(IronSoul_EffectiveMaxLives, 0)
        return
    endif

    if Controller.Tiers
        SetGlobalInt(IronSoul_SoulTier, Controller.Tiers.GetCurrentTier(player, guid))
        SetGlobalInt(IronSoul_EffectiveMaxLives, Controller.Tiers.GetGlobalEffectiveMaxLives(player, guid))
    endif
EndFunction

Function SyncLuck(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        SyncLuckValues(0, 0)
        return
    endif

    if Controller.Luck
        SyncLuckValues(Controller.Luck.GetValue(player, guid), Controller.Luck.GetCurrentMax(player, guid))
    endif
EndFunction

Function SyncLuckValues(Int luckValue, Int maxLuckValue)
    SetGlobalInt(IronSoul_Luck, luckValue)
    SetGlobalInt(IronSoul_LuckMax, maxLuckValue)
EndFunction

Function SyncDifficultyPreset()
    if !IronSoulNative.IsAvailable()
        SetGlobalInt(IronSoul_DifficultyPreset, 0)
        return
    endif
    SetGlobalInt(IronSoul_DifficultyPreset, IronSoulNative.GetIronSoulPresetOrdinal())
EndFunction

Function SyncIntegrationStatus(Actor player)
    Int respawnEnabled = 0
    if Controller && Controller.Respawn && Controller.Respawn.IsRuntimeAvailable()
        respawnEnabled = 1
    endif
    SetGlobalInt(IronSoul_RespawnStatus, respawnEnabled)

    SetGlobalInt(IronSoul_DraugnarokStatus, ResolveDraugnarokStatus(player))
EndFunction

Function SyncModState()
    Int disabled = 0
    if Controller && Controller.IsModDisabled()
        disabled = 1
    endif
    SetGlobalInt(IronSoul_ModDisabled, disabled)
EndFunction

Function ResetGlobals()
    SetGlobalInt(IronSoul_DeathCount, 0)
    SetGlobalInt(IronSoul_TotalDeathCount, 0)
    SetGlobalInt(IronSoul_SoulTier, 0)
    SetGlobalInt(IronSoul_EffectiveMaxLives, 0)
    SetGlobalInt(IronSoul_Luck, 0)
    SetGlobalInt(IronSoul_LuckMax, 0)
    SetGlobalInt(IronSoul_DifficultyPreset, 0)
    SetGlobalInt(IronSoul_RespawnStatus, 0)
    SetGlobalInt(IronSoul_DraugnarokStatus, 0)
    SyncModState()
EndFunction

Int Function ResolveDraugnarokStatus(Actor player)
    if !HasCoreRuntime() || !IronSoulNative.IsAvailable()
        return 0
    endif

    _DS_DN_Draugnarok draugnarok = Controller.ResolveDraugnarokQuest()
    if !draugnarok
        return 0
    endif

    Int mode = 0
    if player && Controller.Persistence
        mode = Controller.Persistence.GetDraugnarokOverrideMode(player)
    endif

    Int threat = draugnarok.GetDraugrThreatLevel()
    if !draugnarok.IsDraugnarokSystemEnabled() || mode == 2 || threat < 0
        return 0
    endif

    if mode != 1
        if draugnarok.IsAlduinDefeated()
            return 0
        endif
        if !draugnarok.IsAlduinLooseForDraugnarok()
            return 1
        endif
    endif

    return 2
EndFunction

Function SetGlobalInt(GlobalVariable targetGlobal, Int value)
    if targetGlobal
        targetGlobal.SetValue(value as Float)
    endif
EndFunction
