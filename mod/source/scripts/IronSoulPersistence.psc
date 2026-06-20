Scriptname IronSoulPersistence extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()

; --- Key Helpers ---
; -------------------
; MakeKey()
; GetKey()

; --- Raw Keyed Storage Helpers ---
; ---------------------------------
; GetInt()
; SetInt()
; GetWorldInt()
; SetWorldInt()
; DeleteWorldKeysWithPrefix()

; --- GUID-Scoped Storage Helpers ---
; -----------------------------------
; GetGuidInt()
; SetGuidInt()
; RemoveGuidTrackedIntKey()
; RemoveTrackedData()

; --- Current-Character Draugnarok Persistence ---
; -----------------------------------------------
; ClampDraugnarokOverrideMode()
; GetDraugnarokOverrideMode()
; SetDraugnarokOverrideMode()

; --- GUID-Scoped Iron Intro Persistence ---
; -----------------------------------------
; IsIronIntroShown()
; MarkIronIntroShown()


; --- Wired Dependencies & Key Constants ---
; ==========================================

IronSoulController Property Controller Auto

String Property draugnarokOverrideMode = "IS_7341" AutoReadOnly ; Per-character Draugnarok override: 0 none, 1 force on, 2 force off.
String Property ironIntroShown         = "IS_8597" AutoReadOnly

Int _missingIntSentinel = -2147483647 ; Reserved internal value for missing MainData int detection.


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Identity
        return False
    endif
    return True
EndFunction


; --- Key Helpers ---
; ===================

String Function MakeKey(String prefix, String guid) Global
    return prefix + ":" + guid
EndFunction

String Function GetKey(String baseKey, String charId) Global
    if baseKey == "" || charId == ""
        return ""
    endif
    return MakeKey(baseKey, charId)
EndFunction


; --- Raw Keyed Storage Helpers ---
; =================================

Int Function GetInt(Actor player, String dataKey, Int fallback)
    if !player
        return fallback
    endif

    if dataKey == ""
        return fallback
    endif

    Int direct = IronSoulNative.DataGetInt(dataKey, _missingIntSentinel)
    if direct != _missingIntSentinel
        return direct
    endif

    return fallback
EndFunction

Function SetInt(Actor player, String dataKey, Int value, Bool useIfChanged = True)
    if dataKey == ""
        return
    endif
    if useIfChanged
        IronSoulNative.DataSetIntIfChanged(dataKey, value)
    else
        IronSoulNative.DataSetInt(dataKey, value)
    endif
EndFunction

Int Function GetWorldInt(String dataKey, Int fallback)
    if dataKey == ""
        return fallback
    endif

    return IronSoulNative.DataGetInt(dataKey, fallback)
EndFunction

Function SetWorldInt(String dataKey, Int value, Bool useIfChanged = True)
    if dataKey == ""
        return
    endif

    if useIfChanged
        IronSoulNative.DataSetIntIfChanged(dataKey, value)
    else
        IronSoulNative.DataSetInt(dataKey, value)
    endif
EndFunction

Int Function DeleteWorldKeysWithPrefix(String prefix)
    if prefix == ""
        return 0
    endif

    return IronSoulNative.DataDeleteKeysWithPrefix(prefix)
EndFunction


; --- GUID-Scoped Storage Helpers ---
; ===================================

Int Function GetGuidInt(Actor player, String guid, String keyBase, Int fallback)
    return GetInt(player, GetKey(keyBase, guid), fallback)
EndFunction

Function SetGuidInt(Actor player, String guid, String keyBase, Int value, Bool useIfChanged = True)
    SetInt(player, GetKey(keyBase, guid), value, useIfChanged)
EndFunction

Function RemoveGuidTrackedIntKey(Actor player, String guid, String keyBase, Bool deleteMainData, Bool unsetCosave)
    String dataKey = GetKey(keyBase, guid)
    if dataKey == ""
        return
    endif

    if deleteMainData
        IronSoulNative.DataDeleteKey(dataKey)
    endif

EndFunction

Function RemoveTrackedData(Actor player, String guid, Bool deleteMainData = True, Bool unsetCosave = False)
    if guid == ""
        return
    endif

    RemoveGuidTrackedIntKey(player, guid, draugnarokOverrideMode, deleteMainData, unsetCosave)
    RemoveGuidTrackedIntKey(player, guid, ironIntroShown, deleteMainData, unsetCosave)
EndFunction


; --- Current-Character Draugnarok Persistence ---
; ===============================================

Int Function ClampDraugnarokOverrideMode(Int mode)
    if mode < 0 || mode > 2
        return 0
    endif
    return mode
EndFunction

Int Function GetDraugnarokOverrideMode(Actor player)
    if !HasCoreRuntime() || !player
        return 0
    endif

    String guid = Controller.Identity.GetKnownGuidNoMint(player)
    if guid == ""
        return 0
    endif

    return ClampDraugnarokOverrideMode(GetGuidInt(player, guid, draugnarokOverrideMode, 0))
EndFunction

Bool Function SetDraugnarokOverrideMode(Actor player, Int mode, Bool flushNow = True)
    if mode < 0 || mode > 2
        return False
    endif
    if !HasCoreRuntime() || !player
        return False
    endif

    String guid = Controller.Identity.GetTickGuid(player)
    if guid == ""
        return False
    endif

    SetGuidInt(player, guid, draugnarokOverrideMode, mode, True)
    if flushNow
        IronSoulNative.DataFlushIfDirty()
    endif
    return True
EndFunction


; --- GUID-Scoped Iron Intro Persistence ---
; =========================================

Bool Function IsIronIntroShown(Actor player, String guid)
    if !player || guid == ""
        return False
    endif

    return GetGuidInt(player, guid, ironIntroShown, 0) == 1
EndFunction

Function MarkIronIntroShown(Actor player, String guid)
    if !player || guid == ""
        return
    endif

    SetGuidInt(player, guid, ironIntroShown, 1, True)
EndFunction
