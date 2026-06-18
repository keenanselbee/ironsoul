Scriptname IronSoulJournal extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()
; HasPersistenceRuntime()
; LogJournal()
; CanLogNativeForGuid()
; FinishNativeJournalWrite()

; --- Journal Runtime ---
; -----------------------
; RemoveTrackedData()
; LogEvent()
; LogEventForGuid()
; LogExternalEvent()
; EnsureOpenerLogged()
; EnsureStartDay()
; LogCHIMRealized()
; LogDefeatOutcomeForGuid()
; LogDefeatLuckOutcomeForGuid()
; LogTrueDeathOutcomeForGuid()
; LogDefiantFatigueOutcomeForGuid()
; LogLuckOutcomeForGuid()
; LogDragonSoulAbsorbedForGuid()
; LogSoulFeatForGuid()
; LogDefiantSoulFeatForGuid()
; LogDefiantRestoreForGuid()
; LogDefiantAwakenedForGuid()
; LogCHIMRealizedForGuid()

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

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [Journal] " + msg)
EndFunction

Bool Function CanLogNativeForGuid(Actor player, String guid, String context)
    if !HasCoreRuntime()
        return False
    endif
    if !Controller.Config.IsCharacterJournalEnabled()
        LogJournal(IronSoulConfig.LOG_DBG(), context + ": Skipped (CharacterJournal=0)")
        return False
    endif
    if !player
        LogJournal(IronSoulConfig.LOG_ERR(), context + ": Skipped (Player is None)")
        return False
    endif
    if guid == ""
        LogJournal(IronSoulConfig.LOG_DBG(), context + ": skipped (GUID empty). Name='" + IronSoulNative.GetPlayerName() + "' MenuMode=" + Utility.IsInMenuMode())
        return False
    endif
    return True
EndFunction

Bool Function FinishNativeJournalWrite(String context, Bool success)
    if !success
        LogJournal(IronSoulConfig.LOG_ERR(), context + ": native write failed")
    endif
    return success
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
    LogJournal(IronSoulConfig.LOG_DBG(), "JournalLogEvent: WRITE event -> " + eventText)
    if !IronSoulNative.JournalLogEvent(eventText, startDay, nowDay)
        LogJournal(IronSoulConfig.LOG_ERR(), "JournalLogEvent: native write failed")
    endif
EndFunction

Function LogExternalEvent(String source, String eventText)
    if eventText == ""
        return
    endif
    if source == ""
        source = IronSoulNative.TextGet("Journal.ExternalSourceDefault")
    endif
    LogEvent(IronSoulNative.TextFormat2("Journal.ExternalEvent", "source", source, "event", eventText))
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

    if IronSoulNative.JournalLogEvent(IronSoulNative.TextGet("Journal.Opener"), 0, 0)
        LogJournal(IronSoulConfig.LOG_INFO(), "JournalEnsureOpenerLogged: Logged journal opener (one-shot)")
        Controller.Persistence.SetGuidInt(player, guid, journalOpenerLogged, 1, True)
    else
        LogJournal(IronSoulConfig.LOG_ERR(), "JournalEnsureOpenerLogged: native write failed")
    endif
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

    if !Controller.Config.IsCharacterJournalEnabled()
        Controller.Persistence.SetGuidInt(player, guid, journalCHIMLogged, 1, True)
        return
    endif

    if LogCHIMRealizedForGuid(player, guid)
        Controller.Persistence.SetGuidInt(player, guid, journalCHIMLogged, 1, True)
    endif
EndFunction

Bool Function LogDefeatOutcomeForGuid(Actor player, String guid, Int deathsNow, Int maxLives)
    String context = "JournalLogDefeatOutcome"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefeatOutcome(deathsNow, maxLives, startDay, nowDay))
EndFunction

Bool Function LogDefeatLuckOutcomeForGuid(Actor player, String guid, Int deathsNow, Int maxLives, Int roll, Int luck)
    String context = "JournalLogDefeatLuckOutcome"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefeatLuckOutcome(deathsNow, maxLives, roll, luck, startDay, nowDay))
EndFunction

Bool Function LogTrueDeathOutcomeForGuid(Actor player, String guid, Int deathsNow, Int maxLives)
    String context = "JournalLogTrueDeathOutcome"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogTrueDeathOutcome(deathsNow, maxLives, startDay, nowDay))
EndFunction

Bool Function LogDefiantFatigueOutcomeForGuid(Actor player, String guid, Int deathsNow, Int maxLives, Bool terminal)
    String context = "JournalLogDefiantFatigueOutcome"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefiantFatigueOutcome(deathsNow, maxLives, terminal, startDay, nowDay))
EndFunction

Bool Function LogLuckOutcomeForGuid(Actor player, String guid, Int luck, Int roll, Int maxLuck)
    String context = "JournalLogLuckOutcome"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogLuckOutcome(luck, roll, maxLuck, startDay, nowDay))
EndFunction

Bool Function LogDragonSoulAbsorbedForGuid(Actor player, String guid, Int total)
    String context = "JournalLogDragonSoulAbsorbed"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDragonSoulAbsorbed(total, startDay, nowDay))
EndFunction

Bool Function LogSoulFeatForGuid(Actor player, String guid, Int soulTier, Int totalDeaths, Bool molagKilled, Bool miraakKilled, Bool alduinKilled, Bool harkonKilled)
    String context = "JournalLogSoulFeat"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogSoulFeat(soulTier, totalDeaths, molagKilled, miraakKilled, alduinKilled, harkonKilled, startDay, nowDay))
EndFunction

Bool Function LogDefiantSoulFeatForGuid(Actor player, String guid, Int totalDeaths)
    String context = "JournalLogDefiantSoulFeat"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefiantSoulFeat(totalDeaths, startDay, nowDay))
EndFunction

Bool Function LogDefiantRestoreForGuid(Actor player, String guid, Int targetTier, Int totalDeaths, Bool molagKilled, Bool miraakKilled, Bool alduinKilled, Bool harkonKilled)
    String context = "JournalLogDefiantRestore"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefiantRestore(targetTier, totalDeaths, molagKilled, miraakKilled, alduinKilled, harkonKilled, startDay, nowDay))
EndFunction

Bool Function LogDefiantAwakenedForGuid(Actor player, String guid)
    String context = "JournalLogDefiantAwakened"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefiantAwakened(startDay, nowDay))
EndFunction

Bool Function LogCHIMRealizedForGuid(Actor player, String guid)
    String context = "JournalLogCHIMRealized"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogCHIMRealized(startDay, nowDay))
EndFunction
