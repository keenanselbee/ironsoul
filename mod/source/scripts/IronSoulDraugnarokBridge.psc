Scriptname IronSoulDraugnarokBridge Hidden

; =========================
; --- Table of Contents ---
; =========================

; --- Draugnarok Helpers ---
; --------------------------
; ClampDraugnarokOverrideMode()


; --- Draugnarok Helpers ---
; ==========================

Int Function ClampDraugnarokOverrideMode(Int mode) Global
    if mode < 0 || mode > 2
        return 0
    endif
    return mode
EndFunction
