Scriptname IronSoulLuck Hidden

; =========================
; --- Table of Contents ---
; =========================

; --- Luck Math Helpers ---
; -------------------------
; PercentThresholdCeil()
; ComputeLuckRollD20()
; LuckTier()

; --- Luck Persistence Encoding ---
; -------------------------------
; DecodePlayed()
; EncodePlayed()


; --- Luck Math Helpers ---
; =========================

Int Function PercentThresholdCeil(Int maxLuck, Int pct) Global
    if maxLuck <= 0
        return 0
    endif
    if pct <= 0
        return 0
    elseif pct >= 100
        return maxLuck
    endif
    Int scaled = maxLuck * pct
    return (scaled + 99) / 100
EndFunction

Int Function ComputeLuckRollD20(Int luck, Int roll100) Global
    if luck < 0
        luck = 0
    elseif luck > 100
        luck = 100
    endif

    if roll100 < 1
        roll100 = 1
    elseif roll100 > 100
        roll100 = 100
    endif

    Int delta = luck - roll100
    Int roll20 = ((delta + 100) / 10) + 1
    if roll20 < 1
        roll20 = 1
    elseif roll20 > 20
        roll20 = 20
    endif
    return roll20
EndFunction

Int Function LuckTier(Int luck, Int maxLuck) Global
    if maxLuck <= 0
        return 0
    endif
    if luck < 0
        luck = 0
    elseif luck > maxLuck
        luck = maxLuck
    endif
    if luck >= maxLuck
        return 4
    elseif luck >= PercentThresholdCeil(maxLuck, 75)
        return 3
    elseif luck >= PercentThresholdCeil(maxLuck, 50)
        return 2
    elseif luck >= PercentThresholdCeil(maxLuck, 25)
        return 1
    endif
    return 0
EndFunction


; --- Luck Persistence Encoding ---
; =================================

Int Function DecodePlayed(Int token) Global
    if token < 8192
        return token
    endif
    return token - ((token / 8192) * 8192)
EndFunction

Int Function EncodePlayed(Int nowSec, Int playedSec) Global
    if playedSec < 0
        playedSec = 0

    elseif playedSec > 8191
        playedSec = 8191
    endif
    Int epochMod = 262144
    Int chunks = nowSec / epochMod
    Int trimmedNow = nowSec - (chunks * epochMod)
    return (trimmedNow * 8192) + playedSec
EndFunction
