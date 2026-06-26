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
; OnUpdateGameTime()
; StopDailyAnimaWatcher()
; ScheduleDailyAnimaWatcher()
; RefreshDailyAnimaWatcherForGuid()
; FlushDailyAnimaForGuid()
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
; NoteDailyAnimaAwardForGuid()
; LogAnimaAwardForGuid()
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
String Property journalAnimaDay     = "J.AD" AutoReadOnly
String Property dailyAnima          = "AN.D" AutoReadOnly
String Property journalAnimaPriority = "J.AP" AutoReadOnly
String Property journalAnimaDateDay = "J.DD" AutoReadOnly
String Property journalAnimaDateMonth = "J.DM" AutoReadOnly
String Property journalAnimaDateYear = "J.DY" AutoReadOnly

Int Property DAILY_ANIMA_PRIORITY_MINOR = 1 AutoReadOnly
Int Property DAILY_ANIMA_PRIORITY_STRONG = 2 AutoReadOnly
Int Property DAILY_ANIMA_PRIORITY_NAMED_UNDEAD = 3 AutoReadOnly
Int Property DAILY_ANIMA_PRIORITY_DRAGON = 4 AutoReadOnly
Int Property DAILY_ANIMA_PRIORITY_MAJOR = 5 AutoReadOnly
Int Property DAILY_ANIMA_PRIORITY_CAPSTONE = 6 AutoReadOnly

Float _dailyAnimaUpdateHours = 1.0
Bool _dailyAnimaWatcherArmed = False


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
    if Controller.Identity.IsCurrentCharacterTest(player)
        LogJournal(IronSoulConfig.LOG_DBG(), context + ": skipped (Prisoner test character)")
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
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, journalAnimaDay, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, dailyAnima, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, journalAnimaPriority, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, journalAnimaDateDay, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, journalAnimaDateMonth, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, journalAnimaDateYear, deleteMainData, unsetCosave)
EndFunction

Event OnUpdateGameTime()
    _dailyAnimaWatcherArmed = False
    if !HasCoreRuntime()
        StopDailyAnimaWatcher()
        return
    endif

    Bool characterJournalEnabled = Controller.Config.IsCharacterJournalEnabled()
    Actor player = Game.GetPlayer()
    if !player
        if characterJournalEnabled
            ScheduleDailyAnimaWatcher()
        else
            StopDailyAnimaWatcher()
        endif
        return
    endif

    String guid = Controller.Identity.GetTickGuid(player)
    if guid == ""
        if characterJournalEnabled
            ScheduleDailyAnimaWatcher()
        else
            StopDailyAnimaWatcher()
        endif
        return
    endif

    if !characterJournalEnabled
        FlushDailyAnimaForGuid(player, guid)
        StopDailyAnimaWatcher()
        return
    endif

    FlushDailyAnimaForGuid(player, guid)
    ScheduleDailyAnimaWatcher()
EndEvent

Function StopDailyAnimaWatcher()
    UnregisterForUpdateGameTime()
    _dailyAnimaWatcherArmed = False
EndFunction

Function ScheduleDailyAnimaWatcher()
    UnregisterForUpdateGameTime()
    RegisterForSingleUpdateGameTime(_dailyAnimaUpdateHours)
    _dailyAnimaWatcherArmed = True
EndFunction

Function RefreshDailyAnimaWatcherForGuid(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        StopDailyAnimaWatcher()
        return
    endif

    if !Controller.Config.IsCharacterJournalEnabled()
        FlushDailyAnimaForGuid(player, guid)
        StopDailyAnimaWatcher()
        return
    endif

    FlushDailyAnimaForGuid(player, guid)
    ScheduleDailyAnimaWatcher()
EndFunction

Bool Function FlushDailyAnimaForGuid(Actor player, String guid)
    String context = "JournalFlushDailyAnima"
    if !HasCoreRuntime() || !player || guid == ""
        return False
    endif
    if Controller.Identity.IsCurrentCharacterTest(player)
        return True
    endif

    Bool success = IronSoulNative.JournalFlushDailyAnima(guid)
    if !success && Controller.Config.IsCharacterJournalEnabled()
        LogJournal(IronSoulConfig.LOG_ERR(), context + ": native write failed")
    endif
    if success && Controller.Globals
        Controller.Globals.SyncAnima(player, guid)
    endif
    return success
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
    if Controller.Identity.IsCurrentCharacterTest(player)
        LogJournal(IronSoulConfig.LOG_DBG(), "JournalLogEvent: skipped (Prisoner test character)")
        return
    endif

    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)

    Int nowDay = Utility.GetCurrentGameTime() as Int
    LogJournal(IronSoulConfig.LOG_DBG(), "JournalLogEvent: WRITE event -> " + eventText)
    if !IronSoulNative.JournalLogEvent(guid, eventText, startDay, nowDay)
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

    if IronSoulNative.JournalLogEvent(guid, IronSoulNative.TextGet("Journal.Opener"), 0, 0)
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
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefeatOutcome(guid, deathsNow, maxLives, startDay, nowDay))
EndFunction

Bool Function LogDefeatLuckOutcomeForGuid(Actor player, String guid, Int deathsNow, Int maxLives, Int roll, Int luck)
    String context = "JournalLogDefeatLuckOutcome"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefeatLuckOutcome(guid, deathsNow, maxLives, roll, luck, startDay, nowDay))
EndFunction

Bool Function LogTrueDeathOutcomeForGuid(Actor player, String guid, Int deathsNow, Int maxLives)
    String context = "JournalLogTrueDeathOutcome"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogTrueDeathOutcome(guid, deathsNow, maxLives, startDay, nowDay))
EndFunction

Bool Function LogDefiantFatigueOutcomeForGuid(Actor player, String guid, Int deathsNow, Int maxLives, Bool terminal)
    String context = "JournalLogDefiantFatigueOutcome"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefiantFatigueOutcome(guid, deathsNow, maxLives, terminal, startDay, nowDay))
EndFunction

Bool Function LogLuckOutcomeForGuid(Actor player, String guid, Int luck, Int roll, Int maxLuck)
    String context = "JournalLogLuckOutcome"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogLuckOutcome(guid, luck, roll, maxLuck, startDay, nowDay))
EndFunction

Bool Function NoteDailyAnimaAwardForGuid(Actor player, String guid, String source, Int amount, Int priority)
    String context = "JournalNoteDailyAnimaAward"
    if !HasCoreRuntime() || !player || guid == ""
        return False
    endif
    if Controller.Identity.IsCurrentCharacterTest(player)
        return True
    endif

    Bool success = IronSoulNative.JournalNoteDailyAnimaAward(guid, source, amount, priority)
    if !success && Controller.Config.IsCharacterJournalEnabled()
        LogJournal(IronSoulConfig.LOG_ERR(), context + ": native write failed")
    endif
    if Controller.Config.IsCharacterJournalEnabled()
        ScheduleDailyAnimaWatcher()
    endif
    if success && Controller.Globals
        Controller.Globals.SyncAnima(player, guid)
    endif
    return success
EndFunction

Bool Function LogAnimaAwardForGuid(Actor player, String guid, String source, Int amount)
    String context = "JournalLogAnimaAward"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogAnimaAward(guid, source, amount, startDay, nowDay))
EndFunction

Bool Function LogSoulFeatForGuid(Actor player, String guid, Int soulTier, Int totalDeaths)
    String context = "JournalLogSoulFeat"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogSoulFeat(guid, soulTier, totalDeaths, startDay, nowDay))
EndFunction

Bool Function LogDefiantSoulFeatForGuid(Actor player, String guid, Int totalDeaths)
    String context = "JournalLogDefiantSoulFeat"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefiantSoulFeat(guid, totalDeaths, startDay, nowDay))
EndFunction

Bool Function LogDefiantRestoreForGuid(Actor player, String guid, Int targetTier, Int totalDeaths)
    String context = "JournalLogDefiantRestore"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefiantRestore(guid, targetTier, totalDeaths, startDay, nowDay))
EndFunction

Bool Function LogDefiantAwakenedForGuid(Actor player, String guid)
    String context = "JournalLogDefiantAwakened"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogDefiantAwakened(guid, startDay, nowDay))
EndFunction

Bool Function LogCHIMRealizedForGuid(Actor player, String guid)
    String context = "JournalLogCHIMRealized"
    if !CanLogNativeForGuid(player, guid, context)
        return False
    endif
    Int startDay = EnsureStartDay(player, guid)
    EnsureOpenerLogged(player, guid)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    return FinishNativeJournalWrite(context, IronSoulNative.JournalLogCHIMRealized(guid, startDay, nowDay))
EndFunction
