Scriptname IronSoulPersistence Hidden

; =========================
; --- Table of Contents ---
; =========================

; --- Key Helpers ---
; -------------------
; MakeKey()
; GetKey()

; --- Storage Helpers ---
; -----------------------
; PersistGetInt()
; PersistSetInt()
; RemoveGuidTrackedIntKey()
; DeleteGuidIdentitySnapshotKeys()


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


; --- Storage Helpers ---
; =======================

Int Function PersistGetInt(Actor player, String dataKey, Int fallback, Bool cosaveRecoveryBackupEnabled) Global
    if !player
        return fallback
    endif

    if dataKey == ""
        return fallback
    endif

    Int missingSentinel = -2147483647
    Int direct = IronSoulNative.DataGetInt(dataKey, missingSentinel)
    if direct != missingSentinel
        return direct
    endif

    if cosaveRecoveryBackupEnabled && StorageUtil.HasIntValue(player, dataKey)
        Int v = StorageUtil.GetIntValue(player, dataKey, fallback)
        IronSoulNative.DataSetIntIfChanged(dataKey, v)
        return v
    endif
    return fallback
EndFunction

Function PersistSetInt(Actor player, String dataKey, Int value, Bool useIfChanged, Bool cosaveRecoveryBackupEnabled) Global
    if dataKey == ""
        return
    endif
    if useIfChanged
        IronSoulNative.DataSetIntIfChanged(dataKey, value)
    else
        IronSoulNative.DataSetInt(dataKey, value)
    endif
    if player && cosaveRecoveryBackupEnabled
        if !StorageUtil.HasIntValue(player, dataKey)
            StorageUtil.SetIntValue(player, dataKey, value)
        else
            Int cur = StorageUtil.GetIntValue(player, dataKey)
            if cur != value
                StorageUtil.SetIntValue(player, dataKey, value)
            endif
        endif
    endif
EndFunction

Function RemoveGuidTrackedIntKey(Actor player, String guid, String keyBase, Bool deleteMainData, Bool unsetCosave, Bool cosaveRecoveryBackupEnabled) Global
    String dataKey = GetKey(keyBase, guid)
    if dataKey == ""
        return
    endif

    if deleteMainData
        IronSoulNative.DataDeleteKey(dataKey)
    endif

    if unsetCosave && player && cosaveRecoveryBackupEnabled
        StorageUtil.UnsetIntValue(player, dataKey)
    endif
EndFunction

Function DeleteGuidIdentitySnapshotKeys(String guid) Global
    if guid == ""
        return
    endif

    IronSoulNative.DataDeleteKey(MakeKey("I.N", guid))
    IronSoulNative.DataDeleteKey(MakeKey("I.R", guid))
    IronSoulNative.DataDeleteKey(MakeKey("I.L", guid))
    IronSoulNative.DataDeleteKey(MakeKey("I.D", guid))
EndFunction
