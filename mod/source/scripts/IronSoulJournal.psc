Scriptname IronSoulJournal extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()
; HasPersistenceRuntime()
; LogJournal()

; --- Journal Runtime ---
; -----------------------
; RemoveTrackedData()
; LogEvent()
; LogEventForGuid()
; LogExternalEvent()
; EnsureOpenerLogged()
; EnsureStartDay()
; LogCHIMRealized()

; --- Journal Text Helpers ---
; ----------------------------
; AppendTotalDeaths()
; BuildDayLine()
; BuildExternalEventText()
; DefeatOutcomeText()
; DefeatLuckOutcomeText()
; TrueDeathOutcomeText()
; DefiantFatigueOutcomeText()
; JournalLuckOutcomeText()
; DeathCountText()
; PickDefeatFlavor()
; PickNormalDefeatFlavor()
; PickNearCapDefeatFlavor()


; --- Wired Dependencies & Persistence Keys ---
; =============================================

IronSoulController Property Controller Auto

String Property journalStartDay     = "IS_5341" AutoReadOnly
String Property journalOpenerLogged = "IS_2270" AutoReadOnly
String Property journalCHIMLogged   = "IS_1927" AutoReadOnly


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Identity || !Controller.Persistence
        return False
    endif
    return True
EndFunction

Bool Function HasPersistenceRuntime()
    if !Controller
        return False
    endif
    if !Controller.Persistence
        return False
    endif
    return True
EndFunction

Function LogJournal(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("Journal", level, msg, suppressNotify)
        return
    endif

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [" + levelText + "] [Journal] " + msg)
EndFunction


; --- Journal Runtime ---
; =======================

Function RemoveTrackedData(Actor player, String guid, Bool deleteMainData = True, Bool unsetCosave = False)
    if !HasPersistenceRuntime() || guid == ""
        return
    endif

    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, journalStartDay, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, journalOpenerLogged, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, journalCHIMLogged, deleteMainData, unsetCosave)
EndFunction

Function LogEvent(String eventText)
    ; Papyrus sends only "Day X: <Event text>"; the native logger adds character context.
    if !HasCoreRuntime()
        return
    endif
    if !Controller.Config.IsCharacterJournalEnabled()
        LogJournal(IronSoulConfig.LOG_DBG(), "JournalLogEvent: Skipped (CharacterJournal=0)")
        return
    endif
    if eventText == ""
        LogJournal(IronSoulConfig.LOG_DBG(), "JournalLogEvent: Skipped (Empty eventText)")
        return
    endif

    Actor player = Game.GetPlayer()
    if !player
        LogJournal(IronSoulConfig.LOG_ERR(), "JournalLogEvent: Skipped (Player is None)")
        return
    endif

    String guid = Controller.Identity.GetTickGuid(player)
    if guid == ""
        String pn = IronSoulNative.GetPlayerName()
        LogJournal(IronSoulConfig.LOG_DBG(), "JournalLogEvent: skipped (GUID empty). Name='" + pn + "' MenuMode=" + Utility.IsInMenuMode())
        return
    endif

    LogEventForGuid(player, guid, eventText)
EndFunction

Function LogEventForGuid(Actor player, String guid, String eventText)
    ; Fast path for internal callers that already resolved player identity.
    if !HasCoreRuntime()
        return
    endif
    if !Controller.Config.IsCharacterJournalEnabled()
        LogJournal(IronSoulConfig.LOG_DBG(), "JournalLogEvent: Skipped (CharacterJournal=0)")
        return
    endif
    if eventText == ""
        LogJournal(IronSoulConfig.LOG_DBG(), "JournalLogEvent: Skipped (Empty eventText)")
        return
    endif
    if !player
        LogJournal(IronSoulConfig.LOG_ERR(), "JournalLogEvent: Skipped (Player is None)")
        return
    endif
    if guid == ""
        LogJournal(IronSoulConfig.LOG_DBG(), "JournalLogEvent: skipped (GUID empty). Name='" + IronSoulNative.GetPlayerName() + "' MenuMode=" + Utility.IsInMenuMode())
        return
    endif

    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)

    Int nowDay = Utility.GetCurrentGameTime() as Int
    String line = BuildDayLine(eventText, startDay, nowDay)
    LogJournal(IronSoulConfig.LOG_DBG(), "JournalLogEvent: WRITE -> " + line)
    IronSoulNative.LogJournalEntry(line)
EndFunction

Function LogExternalEvent(String source, String eventText)
    String externalEvent = BuildExternalEventText(source, eventText)
    if externalEvent != ""
        LogEvent(externalEvent)
    endif
EndFunction

Function EnsureOpenerLogged(Actor player, String guid)
    ; Writes the Day 1 opener once per GUID.
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    Int logged = Controller.Persistence.GetGuidInt(player, guid, journalOpenerLogged, 0)
    if logged == 1
        return
    endif

    IronSoulNative.LogJournalEntry("Day 1: Iron Soul awakened.")
    LogJournal(IronSoulConfig.LOG_INFO(), "JournalEnsureOpenerLogged: Logged journal opener (one-shot)")
    Controller.Persistence.SetGuidInt(player, guid, journalOpenerLogged, 1, True)
EndFunction

Int Function EnsureStartDay(Actor player, String guid)
    ; Stores absolute game-day integer once; BuildDayLine converts it to Day X.
    if !HasCoreRuntime() || !Controller.Config.IsCharacterJournalEnabled()
        return -1
    endif
    if !player || guid == ""
        return -1
    endif

    Int startDay = Controller.Persistence.GetGuidInt(player, guid, journalStartDay, -1)
    if startDay == -1
        Int nowDay = Utility.GetCurrentGameTime() as Int
        Controller.Persistence.SetGuidInt(player, guid, journalStartDay, nowDay, True)
        startDay = nowDay
    endif
    return startDay
EndFunction

Function LogCHIMRealized(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    Int chimLogged = Controller.Persistence.GetGuidInt(player, guid, journalCHIMLogged, 0)
    if chimLogged == 1
        return
    endif

    if Controller.Config.IsCharacterJournalEnabled()
        LogEventForGuid(player, guid, "CHIM realized: Death is merely an illusion, a cycle to be broken. Dream Soul awakened.")
    endif
    Controller.Persistence.SetGuidInt(player, guid, journalCHIMLogged, 1, True)
EndFunction


; --- Journal Text Helpers ---
; ============================

String Function AppendTotalDeaths(String baseText, Int totalDeaths) Global
    if baseText == ""
        return ""
    endif
    return baseText + " Total Deaths: " + totalDeaths + "."
EndFunction

String Function BuildDayLine(String eventText, Int startDay, Int nowDay) Global
    if eventText == ""
        return ""
    endif

    Int dayIdx = 1
    if startDay != -1
        dayIdx = (nowDay - startDay) + 1
    endif
    if dayIdx < 1
        dayIdx = 1
    endif
    return "Day " + dayIdx + ": " + eventText
EndFunction

String Function BuildExternalEventText(String source, String eventText) Global
    if eventText == ""
        return ""
    endif
    if source == ""
        source = "External"
    endif
    return source + ": " + eventText
EndFunction

String Function DefeatOutcomeText(Int deathsNow, Int maxLives) Global
    return "Defeat. " + DeathCountText(deathsNow, maxLives) + " " + PickDefeatFlavor(deathsNow, maxLives)
EndFunction

String Function DefeatLuckOutcomeText(Int deathsPred, Int maxLives, Int roll, Int luck) Global
    return DefeatOutcomeText(deathsPred, maxLives) + " Roll: " + roll + ". Luck: " + luck + "."
EndFunction

String Function TrueDeathOutcomeText(Int deathsNow, Int maxLives) Global
    return "True Death. " + DeathCountText(deathsNow, maxLives) + " Sovngarde claims the fallen dead."
EndFunction

String Function DefiantFatigueOutcomeText(Int deathsNow, Int maxLives, Bool terminal) Global
    if terminal
        return "True Death. " + DeathCountText(deathsNow, maxLives) + " Soul fatigue overwhelms the body."
    endif
    return "Defeat. " + DeathCountText(deathsNow, maxLives) + " Soul fatigue overwhelms the body."
EndFunction

String Function JournalLuckOutcomeText(Int luck, Int roll, Int maxLuck) Global
    Int tier = IronSoulLuck.LuckTier(luck, maxLuck)
    if tier >= 4
        return "Fate cheated. Roll: " + roll + ". Luck: " + luck + "."
    elseif tier == 3
        return "Death denied. Roll: " + roll + ". Luck: " + luck + "."
    elseif tier == 2
        return "Fortune favors the bold. Roll: " + roll + ". Luck: " + luck + "."
    elseif tier == 1
        return "Narrowly escaped death. Roll: " + roll + ". Luck: " + luck + "."
    endif
    return "Barely clung to life. Roll: " + roll + ". Luck: " + luck + "."
EndFunction

String Function DeathCountText(Int deathsNow, Int maxLives) Global
    if maxLives <= 0 || maxLives >= 2000000000
        return "Death " + deathsNow + "."
    endif
    return "Death " + deathsNow + " of " + maxLives + "."
EndFunction

String Function PickDefeatFlavor(Int deathsNow, Int maxLives) Global
    if maxLives > 0 && maxLives < 2000000000 && deathsNow >= (maxLives - 1)
        return PickNearCapDefeatFlavor()
    endif
    return PickNormalDefeatFlavor()
EndFunction

String Function PickNormalDefeatFlavor() Global
    Int pick = Utility.RandomInt(1, 12)
    if pick == 1
        return "The body falls; the soul remembers."
    elseif pick == 2
        return "Another mark is carved into the cycle."
    elseif pick == 3
        return "The world goes quiet, but the tally remains."
    elseif pick == 4
        return "The breath fails. The debt remains."
    elseif pick == 5
        return "Steel, spell, and fate all find their due."
    elseif pick == 6
        return "The soul is dragged back from the edge, diminished."
    elseif pick == 7
        return "A life is spent. The ledger grows heavier."
    elseif pick == 8
        return "The dream tightens around the wound."
    elseif pick == 9
        return "The fallen dead are counted, not yet claimed."
    elseif pick == 10
        return "The road continues, but something was left behind."
    elseif pick == 11
        return "The soul staggers onward through the dark."
    endif
    return "One more death is written into the iron."
EndFunction

String Function PickNearCapDefeatFlavor() Global
    Int pick = Utility.RandomInt(1, 4)
    if pick == 1
        return "The last mercy grows thin."
    elseif pick == 2
        return "Sovngarde waits close enough to hear."
    elseif pick == 3
        return "The next death may be the final word."
    endif
    return "The soul stands at the edge of the hall."
EndFunction
