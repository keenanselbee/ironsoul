Scriptname IronSoulConfig Hidden

; =========================
; --- Table of Contents ---
; =========================

; --- Config Helpers ---
; ----------------------
; ReadBool()
; ReadFeatureEnabled()
; ReadIntRange()
; NormalizeIronSoulPreset()
; ClampLuckLevel()
; GetPresetLuckLevel()
; GetEffectiveLuckLevel()
; ResolvePresetAssetId()

; --- Logging Constants ---
; -------------------------
; LOG_ERR()
; LOG_INFO()
; LOG_DBG()


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

Int Function NormalizeIronSoulPreset(Int presetId) Global
    if presetId >= 1 && presetId <= 3
        return presetId
    endif

    return 0
EndFunction

Int Function ClampLuckLevel(Int luckLevel) Global
    if luckLevel < 1
        return 1
    elseif luckLevel > 5
        return 5
    endif
    return luckLevel
EndFunction

Int Function GetPresetLuckLevel(Int presetId) Global
    presetId = NormalizeIronSoulPreset(presetId)
    if presetId == 1
        return 4
    elseif presetId == 2
        return 3
    elseif presetId == 3
        return 2
    endif
    return 5
EndFunction

Int Function GetEffectiveLuckLevel(Int presetId) Global
    presetId = NormalizeIronSoulPreset(presetId)
    if presetId == 0
        return ClampLuckLevel(IronSoulNative.GetConfigInt("LuckLevel", 5))
    endif

    Int luckLevel = GetPresetLuckLevel(presetId)
    if IronSoulNative.GetIronSoulPresetPlus() >= 2
        luckLevel -= 1
    endif
    return ClampLuckLevel(luckLevel)
EndFunction

Int Function ResolvePresetAssetId(Int presetId) Global
    return NormalizeIronSoulPreset(presetId)
EndFunction


; --- Logging Constants ---
; =========================

Int Function LOG_ERR() Global
    return 1
EndFunction

Int Function LOG_INFO() Global
    return 2
EndFunction

Int Function LOG_DBG() Global
    return 3
EndFunction
