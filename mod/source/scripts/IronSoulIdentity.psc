Scriptname IronSoulIdentity extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()
; LogIdentity()
; IsPlaceholderName()
; IsTestCharacterName()
; IsCurrentCharacterTest()
; IsPrisonerNameAt()
; IsCharEither()

; --- Identity Runtime ---
; ------------------------
; ResetTransientState()
; StartBootstrap()
; IsBootstrapActive()
; ConsumeBootstrapTry()
; AllowPlaceholderGuidMintAfterBootstrapTimeout()
; CompleteBootstrap()
; GetCachedGuid()
; GetStoredGuid()
; GetKnownGuidNoMint()
; ApplyLoadedSnapshotIfReady()
; GetTickGuid()

; --- Identity Persistence ---
; ----------------------------
; EnsureGuid()
; CommitGuid()
; EnsureGuidMarker()
; EnsureGuidInIndex()
; GetGuidIndex()
; KeepOnlyGuidInIndex()
; MarkTestCharacterGuid()
; IsHistoricalTestCharacterGuid()
; DeleteIdentitySnapshotKeys()
; DeleteTestCharacterMarker()
; DeleteGuidMarker()
; WriteIdentitySnapshotStatic()
; WriteIdentitySnapshotLastSeen()
; HandleNewTestCharacterGuid()

; --- Identity Recovery ---
; -------------------------
; TryRestoreGuidMissingCosave()
; TryRestoreGuidTamperedCosave()


; --- Wired Dependencies & Runtime State ---
; ==========================================

IronSoulController Property Controller Auto

; Identity is stored in native SKSE serialization for the current save.
String Property testCharacterMarker = "I.T" AutoReadOnly

; Pipe-delimited global GUID index used only for rare co-save recovery.
String Property _guidIndexKey = "G.U.INDEX" Auto Hidden

; Recovery tolerances
Int Property _idLevelTolerance = 2 Auto Hidden ; +/- level match window
Int Property _idDayTolerance   = 3 Auto Hidden ; +/- day match window

Bool _bootstrapActive = False
Int _bootstrapTriesLeft = 0
Bool _placeholderGuidMintAllowed = False
Float _bootstrapStartedAt = 0.0

String _tickGuid = ""
Bool _tickGuidValid = False
Bool _guidTamperMintNotified = False ; one-shot per session warning when tamper fallback mints a new GUID
Float _guidMintRetryAt = 0.0 ; transient backoff after mint failure to avoid repeated retries


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config
        return False
    endif
    return True
EndFunction

Function LogIdentity(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("Identity", level, msg, suppressNotify)
        return
    endif

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [Identity] " + msg)
EndFunction

Bool Function IsPlaceholderName(String playerName)
    return playerName == "Prisoner" || playerName == "Player"
EndFunction

Bool Function IsTestCharacterName(String playerName)
    Int nameLen = StringUtil.GetLength(playerName)
    if nameLen < 8
        return False
    endif

    Int i = 0
    while i <= nameLen - 8
        if IsPrisonerNameAt(playerName, i)
            return True
        endif
        i += 1
    endwhile

    return False
EndFunction

Bool Function IsCurrentCharacterTest(Actor player)
    if !player
        return False
    endif
    if !HasCoreRuntime()
        return False
    endif
    if !Controller.Config.IsPrisonerTestCharactersEnabled()
        return False
    endif

    return IsTestCharacterName(IronSoulNative.GetPlayerName())
EndFunction

Bool Function IsPrisonerNameAt(String playerName, Int offset)
    return IsCharEither(StringUtil.GetNthChar(playerName, offset), "p", "P") \
        && IsCharEither(StringUtil.GetNthChar(playerName, offset + 1), "r", "R") \
        && IsCharEither(StringUtil.GetNthChar(playerName, offset + 2), "i", "I") \
        && IsCharEither(StringUtil.GetNthChar(playerName, offset + 3), "s", "S") \
        && IsCharEither(StringUtil.GetNthChar(playerName, offset + 4), "o", "O") \
        && IsCharEither(StringUtil.GetNthChar(playerName, offset + 5), "n", "N") \
        && IsCharEither(StringUtil.GetNthChar(playerName, offset + 6), "e", "E") \
        && IsCharEither(StringUtil.GetNthChar(playerName, offset + 7), "r", "R")
EndFunction

Bool Function IsCharEither(String value, String lowerValue, String upperValue)
    return value == lowerValue || value == upperValue
EndFunction


; --- Identity Runtime ---
; ========================

Function ResetTransientState()
    _bootstrapActive = False
    _bootstrapTriesLeft = 0
    _placeholderGuidMintAllowed = False
    _bootstrapStartedAt = 0.0

    _tickGuid = ""
    _tickGuidValid = False
    _guidTamperMintNotified = False
    _guidMintRetryAt = 0.0
EndFunction

Function StartBootstrap(Int tries = 10)
    if tries < 1
        tries = 1
    endif

    _bootstrapActive = True
    _bootstrapTriesLeft = tries
    _placeholderGuidMintAllowed = False
    _bootstrapStartedAt = Utility.GetCurrentRealTime()
EndFunction

Bool Function IsBootstrapActive()
    return _bootstrapActive
EndFunction

Int Function ConsumeBootstrapTry()
    if _bootstrapTriesLeft > 0
        _bootstrapTriesLeft -= 1
    endif
    return _bootstrapTriesLeft
EndFunction

Function AllowPlaceholderGuidMintAfterBootstrapTimeout()
    if !_placeholderGuidMintAllowed
        LogIdentity(IronSoulConfig.LOG_INFO(), "AllowPlaceholderGuidMintAfterBootstrapTimeout: placeholder-name GUID minting is now allowed")
    endif
    _placeholderGuidMintAllowed = True
EndFunction

Function CompleteBootstrap(Bool clearIntroTiming = True)
    _bootstrapActive = False
    _bootstrapTriesLeft = 0
    if clearIntroTiming
        _bootstrapStartedAt = 0.0
    endif
EndFunction

String Function GetCachedGuid()
    if _tickGuidValid
        return _tickGuid
    endif
    return ""
EndFunction

String Function GetStoredGuid(Actor player)
    if !player
        return ""
    endif
    return IronSoulNative.IdentityGetCurrentGuid()
EndFunction

String Function GetKnownGuidNoMint(Actor player)
    if _tickGuidValid
        return _tickGuid
    endif
    return GetStoredGuid(player)
EndFunction

Function ApplyLoadedSnapshotIfReady(Actor player, String guid)
    if !player || guid == ""
        return
    endif

    String payload = IronSoulNative.IdentityApplyLoadedSnapshot(guid)
    if StringUtil.Substring(payload, 0, 3) != "ok|"
        return
    endif

    LogIdentity(IronSoulConfig.LOG_INFO(), "ApplyLoadedSnapshotIfReady: applied native current-character snapshot " + payload, True)
    if Controller && Controller.Globals
        Controller.Globals.SyncAll(player, guid)
    endif
    if Controller && Controller.Tiers
        Controller.Tiers.HandleProgressionRelevantChange(player, guid)
    endif
    if Controller && Controller.Effects
        Controller.Effects.SyncSoulPresentationAndStats(player, guid)
    endif
    IronSoulNative.DataFlushIfDirty()
EndFunction

String Function GetTickGuid(Actor player)
    ; Returns the cached GUID. If not cached, compute lazily and cache only when non-empty.
    if _tickGuidValid
        if Controller && Controller.Presentation
            Controller.Presentation.MarkPendingIronIntroShown(player, _tickGuid)
        endif
        return _tickGuid
    endif

    String g = EnsureGuid(player)
    if g != ""
        _tickGuid = g
        _tickGuidValid = True
        ApplyLoadedSnapshotIfReady(player, g)
        if Controller && Controller.Presentation
            Controller.Presentation.MarkPendingIronIntroShown(player, g)
        endif
        return g
    endif

    ; Not ready yet
    return ""
EndFunction


; --- Identity Persistence ---
; ============================

; Plugin provides:
;   - GenerateGuidUnique(playerName) -> collision-safe GUID minting + marker claim
;   - Native current-save GUID serialization and vital-value recovery snapshot
;   - Binary DataStore (MainData + MirrorData) with self-heal + save-callback/explicit flush behavior
;
; Identity responsibilities:
;   - Write GUID once to native current-save identity when identity is ready
;   - Maintain Identity Snapshot in MainData for recovery:
;       I.N = Name
;       I.R = RaceFormID
;       I.L = Level
;       I.D = LastSeenGameDay
;   - Ensure collision marker exists for recovered GUIDs

String Function EnsureGuid(Actor player)
    ; Authoritative identity: native current-save GUID. MainData stores per-GUID data only.
    if !HasCoreRuntime() || !player
        return ""
    endif

    ; 1) Co-save authoritative fast path.
    String guid = GetStoredGuid(player)
    if guid != ""
        Int lvlNow = player.GetLevel()
        if lvlNow <= 1
            ; New game exception: trust co-save identity directly.
            EnsureGuidMarker(guid)
            return guid
        endif

        if !IronSoulNative.DataStoreReady()
            ; Avoid trust decisions from potentially uninitialized MainData.
            LogIdentity(IronSoulConfig.LOG_INFO(), "EnsureGuid: co-save GUID present but MainData not ready; deferring trust decision")
            return ""
        endif

        String idx = IronSoulNative.DataGetString(_guidIndexKey, "")
        if idx == ""
            ; Empty index exception: cannot prove co-save is wrong.
            EnsureGuidMarker(guid)
            return guid
        endif

        ; Known GUID in marker/index: trust and heal marker/index.
        if IronSoulNative.DataGetInt("G.U." + guid, 0) != 0
            EnsureGuidInIndex(guid)
            return guid
        endif

        String hay = "|" + idx + "|"
        String needle = "|" + guid + "|"
        if StringUtil.Find(hay, needle) != -1
            EnsureGuidMarker(guid)
            return guid
        endif

        ; Unknown co-save GUID at level > 1 with non-empty index is suspicious.
        ; Do not bless here. Attempt tamper recovery/mint once identity is ready (works for load and bootstrap retries).
        String tamperName = IronSoulNative.GetPlayerName()
        if tamperName == ""
            LogIdentity(IronSoulConfig.LOG_INFO(), "EnsureGuid: co-save GUID not trusted; identity name not ready yet")
            return ""
        endif

        String tamperResolved = TryRestoreGuidTamperedCosave(player, tamperName, guid)
        if tamperResolved != ""
            return tamperResolved
        endif

        LogIdentity(IronSoulConfig.LOG_INFO(), "EnsureGuid: co-save GUID is not trusted by MainData; recovery unresolved")
        return ""
    endif

    ; 2) Identity must be ready (RaceMenu / very early loads can return empty).
    String pn = IronSoulNative.GetPlayerName()
    if pn == ""
        return ""
    endif

    ; Don't mint identity while still in chargen.
    if Utility.IsInMenuMode()
        return ""
    endif

    ; Delay placeholder-name minting until bootstrap has actually timed out outside menu mode.
    if IsPlaceholderName(pn)
        if !_placeholderGuidMintAllowed
            LogIdentity(IronSoulConfig.LOG_INFO(), "EnsureGuid: delaying placeholder name (" + pn + ") until bootstrap timeout")
            return ""
        endif
        LogIdentity(IronSoulConfig.LOG_INFO(), "EnsureGuid: placeholder name allowed after bootstrap timeout (" + pn + ")")
    endif

    if !IronSoulNative.DataStoreReady()
        ; Do not run MainData-based restore/mint while datastore is still initializing.
        LogIdentity(IronSoulConfig.LOG_INFO(), "EnsureGuid: MainData not ready; deferring GUID restore/mint")
        return ""
    endif

    ; 3) Rare recovery path: attempt to restore GUID from identity snapshots (only if beyond level 1 and co-save is missing).
    guid = TryRestoreGuidMissingCosave(player, pn)
    if guid != ""
        return guid
    endif

    ; 4) Mint a new GUID (collision-safe) and commit to co-save.
    guid = IronSoulNative.GenerateGuidUnique(pn)
    if guid == ""
        return ""
    endif

    CommitGuid(player, guid, pn)
    HandleNewTestCharacterGuid(guid, pn)

    LogIdentity(IronSoulConfig.LOG_INFO(), "EnsureGuid: GUID FINALIZED (" + guid + ", name=" + pn + ")")

    _bootstrapStartedAt = 0.0

    if Controller && Controller.Effects
        Controller.Effects.SyncSoulPresentationAndStats(player, guid)
    endif

    return guid
EndFunction

Function CommitGuid(Actor player, String guid, String playerName)
    if !player || guid == ""
        return
    endif

    if !IronSoulNative.IdentitySetCurrentGuid(guid)
        LogIdentity(IronSoulConfig.LOG_ERR(), "CommitGuid: native current-save GUID rejected '" + guid + "'")
        return
    endif
    EnsureGuidMarker(guid)

    if playerName != ""
        WriteIdentitySnapshotStatic(guid, player, playerName)
    endif
    WriteIdentitySnapshotLastSeen(guid, player)

    ; Flush ASAP to avoid re-minting or re-restoring on crash.
    IronSoulNative.DataFlushIfDirty()
EndFunction

Function EnsureGuidMarker(String guid)
    if guid == ""
        return
    endif

    IronSoulNative.DataSetIntIfChanged("G.U." + guid, 1)
    EnsureGuidInIndex(guid)
EndFunction

Function EnsureGuidInIndex(String guid)
    if guid == ""
        return
    endif

    String idx = IronSoulNative.DataGetString(_guidIndexKey, "")
    if idx == ""
        IronSoulNative.DataSetStringIfChanged(_guidIndexKey, guid)
        return
    endif

    String hay = "|" + idx + "|"
    String needle = "|" + guid + "|"
    if StringUtil.Find(hay, needle) != -1
        return
    endif

    IronSoulNative.DataSetStringIfChanged(_guidIndexKey, idx + "|" + guid)
EndFunction

String Function GetGuidIndex()
    return IronSoulNative.DataGetString(_guidIndexKey, "")
EndFunction

Function KeepOnlyGuidInIndex(String guid)
    if guid == ""
        return
    endif

    IronSoulNative.DataSetIntIfChanged("G.U." + guid, 1)
    IronSoulNative.DataSetStringIfChanged(_guidIndexKey, guid)
EndFunction

Function MarkTestCharacterGuid(String guid)
    if guid == ""
        return
    endif

    IronSoulNative.DataSetIntIfChanged(IronSoulPersistence.MakeKey(testCharacterMarker, guid), 1)
EndFunction

Bool Function IsHistoricalTestCharacterGuid(String guid)
    if guid == ""
        return False
    endif

    if IronSoulNative.DataGetInt(IronSoulPersistence.MakeKey(testCharacterMarker, guid), 0) == 1
        return True
    endif

    String savedName = IronSoulNative.DataGetString(IronSoulPersistence.MakeKey("I.N", guid), "")
    return IsTestCharacterName(savedName)
EndFunction

Function DeleteIdentitySnapshotKeys(String guid)
    if guid == ""
        return
    endif

    IronSoulNative.DataDeleteKey(IronSoulPersistence.MakeKey("I.N", guid))
    IronSoulNative.DataDeleteKey(IronSoulPersistence.MakeKey("I.R", guid))
    IronSoulNative.DataDeleteKey(IronSoulPersistence.MakeKey("I.L", guid))
    IronSoulNative.DataDeleteKey(IronSoulPersistence.MakeKey("I.D", guid))
EndFunction

Function DeleteTestCharacterMarker(String guid)
    if guid == ""
        return
    endif

    IronSoulNative.DataDeleteKey(IronSoulPersistence.MakeKey(testCharacterMarker, guid))
EndFunction

Function DeleteGuidMarker(String guid)
    if guid == ""
        return
    endif

    IronSoulNative.DataDeleteKey("G.U." + guid)
EndFunction

Function WriteIdentitySnapshotStatic(String guid, Actor player, String playerName)
    if guid == "" || !player || playerName == ""
        return
    endif

    if player.GetLevel() <= 1
        return
    endif

    Int raceId = 0
    Race raceNow = player.GetRace()
    if raceNow
        raceId = raceNow.GetFormID()
    endif

    IronSoulNative.DataSetStringIfChanged(IronSoulPersistence.MakeKey("I.N", guid), playerName)
    IronSoulNative.DataSetIntIfChanged(IronSoulPersistence.MakeKey("I.R", guid), raceId)
EndFunction

Function WriteIdentitySnapshotLastSeen(String guid, Actor player)
    if guid == "" || !player
        return
    endif

    Int levelNow = player.GetLevel()
    if levelNow <= 1
        return
    endif

    Int dayNow = Utility.GetCurrentGameTime() as Int
    IronSoulNative.DataSetIntIfChanged(IronSoulPersistence.MakeKey("I.L", guid), levelNow)
    IronSoulNative.DataSetIntIfChanged(IronSoulPersistence.MakeKey("I.D", guid), dayNow)
EndFunction

Function HandleNewTestCharacterGuid(String guid, String playerName)
    if guid == "" || playerName == ""
        return
    endif
    if !HasCoreRuntime()
        return
    endif
    if !Controller.Config.IsPrisonerTestCharactersEnabled()
        return
    endif
    if !IsTestCharacterName(playerName)
        return
    endif

    MarkTestCharacterGuid(guid)
    Int purgedCount = 0
    if Controller.Cleanup
        purgedCount = Controller.Cleanup.PurgeHistoricalTestCharacterData(guid)
    else
        IronSoulNative.DataFlushIfDirty()
    endif
    LogIdentity(IronSoulConfig.LOG_INFO(), "HandleNewTestCharacterGuid: marked Prisoner test GUID '" + guid + "' and purged " + purgedCount + " older test character GUID(s)")
EndFunction


; --- Identity Recovery ---
; =========================

String Function TryRestoreGuidMissingCosave(Actor player, String pn)
    ; Co-save deletion protection (rare path).
    ; NEVER restore unless the player is beyond level 1 (new games naturally start at level 1).
    ; Requires identity-ready (pn != "").
    ;
    ; Recovery signals (4 total):
    ;      1) Name match (I.N:<guid>)
    ;      2) RaceFormID match (I.R:<guid>)
    ;      3) Level within +/- _idLevelTolerance of last-seen level (I.L:<guid>)
    ;      4) Game day within +/- _idDayTolerance of last-seen day (I.D:<guid>)
    ;
    ; Auto-restore policy (hardened to avoid cross-profile mis-association):
    ;  - Candidate must be UNIQUE best (best score must be strictly above runner-up).
    ;  - Accept 4/4 directly.
    ;  - Accept 3/4 only when both strong anchors match (Name + Race) AND
    ;    runner-up score is <= 1 (clear separation from other historical GUIDs).
    if !player || pn == ""
        return ""
    endif

    Int lvlNow = player.GetLevel()
    if lvlNow <= 1
        return ""
    endif

    ; Enumerate known GUIDs from the global index maintained under G.U.INDEX.
    String idx = IronSoulNative.DataGetString(_guidIndexKey, "")
    if idx == ""
        return ""
    endif

    ; Current identity fields
    Int ridNow = 0
    Race rNow = player.GetRace()
    if rNow
        ridNow = rNow.GetFormID()
    endif
    Int dayNow = Utility.GetCurrentGameTime() as Int

    String bestGuid = ""
    Int bestMatches = 0
    Int bestDayDelta = 999999
    Int bestLvlDelta = 999999
    Int secondBestMatches = 0
    Bool bestNameMatch = False
    Bool bestRaceMatch = False

    Int i = 0
    Int len = StringUtil.GetLength(idx)
    While i < len
        Int j = StringUtil.Find(idx, "|", i)
        String cand = ""
        if j == -1
            cand = StringUtil.Substring(idx, i)
            i = len
        else
            cand = StringUtil.Substring(idx, i, j - i)
            i = j + 1
        endif

        if cand == ""
            ; Skip empty token.
        else
            ; Snapshot reads (per GUID)
            String nSaved = IronSoulNative.DataGetString(IronSoulPersistence.MakeKey("I.N", cand), "")
            Int rSaved = IronSoulNative.DataGetInt(IronSoulPersistence.MakeKey("I.R", cand), -1)
            Int lSaved = IronSoulNative.DataGetInt(IronSoulPersistence.MakeKey("I.L", cand), -1)
            Int tSaved = IronSoulNative.DataGetInt(IronSoulPersistence.MakeKey("I.D", cand), -1)

            Int matches = 0
            Bool nameMatch = False
            Bool raceMatch = False

            ; 1) Name
            if nSaved != "" && pn == nSaved
                matches += 1
                nameMatch = True
            endif

            ; 2) Race
            if rSaved >= 0 && ridNow == rSaved
                matches += 1
                raceMatch = True
            endif

            ; 3) Level proximity
            Int dL = 999999
            if lSaved >= 0
                dL = lvlNow - lSaved
                if dL < 0
                    dL = -dL
                endif
                if dL <= _idLevelTolerance
                    matches += 1
                endif
            endif

            ; 4) Day proximity
            Int dT = 999999
            if tSaved >= 0
                dT = dayNow - tSaved
                if dT < 0
                    dT = -dT
                endif
                if dT <= _idDayTolerance
                    matches += 1
                endif
            endif

            ; Keep the best candidate. Ties: prefer closer day, then closer level.
            Bool takesBest = False
            if matches > bestMatches
                takesBest = True
            elseif matches == bestMatches && matches > 0
                if dT < bestDayDelta || (dT == bestDayDelta && dL < bestLvlDelta)
                    takesBest = True
                endif
            endif

            if takesBest
                if bestMatches > secondBestMatches
                    secondBestMatches = bestMatches
                endif
                bestGuid = cand
                bestMatches = matches
                bestDayDelta = dT
                bestLvlDelta = dL
                bestNameMatch = nameMatch
                bestRaceMatch = raceMatch
            else
                if matches > secondBestMatches
                    secondBestMatches = matches
                endif
            endif
        endif
    EndWhile

    Bool strongUnique = False
    if bestGuid != "" && bestMatches > secondBestMatches
        if bestMatches >= 4
            strongUnique = True
        elseif bestMatches == 3 && bestNameMatch && bestRaceMatch && secondBestMatches <= 1
            strongUnique = True
        endif
    endif

    if !strongUnique
        return ""
    endif

    ; Restore authoritative GUID back to co-save directly (do NOT use Persist helpers).
    CommitGuid(player, bestGuid, pn)
    LogIdentity(IronSoulConfig.LOG_INFO(), "TryRestoreGuidMissingCosave: restored missing co-save GUID '" + bestGuid + "' (" + bestMatches + "/4, runnerUp=" + secondBestMatches + ")")
    return bestGuid
EndFunction

String Function TryRestoreGuidTamperedCosave(Actor player, String pn, String cosaveGuid)
    ; Co-save tamper/corruption protection (rare path).
    ;
    ; Scenario:
    ;  - Co-save GUID exists, but MainData suggests a different historical GUID set (G.U.INDEX),
    ;    and the co-save GUID is NOT present in MainData (no marker + not in index).
    ;
    ; Policy:
    ;  - Prefer co-save if MainData index is empty (MainData likely wiped / fresh install).
    ;  - Never attempt restore at level 1 (new games).
    ;  - Only overwrite co-save when recovery returns a strong, unique winner
    ;    (same hardened rule used by missing co-save recovery).
    ;
    ; Returns:
    ;  - The GUID you should treat as authoritative for this session.
    ; Side effects:
    ;  - If a strong match is found, overwrites co-save to the recovered GUID and refreshes marker/index/snapshots.
    ;  - If strict recovery is inconclusive, mints a new GUID with marker/index/snapshots to keep gameplay non-blocking.

    if !HasCoreRuntime() || !player
        return ""
    endif

    if cosaveGuid == ""
        return ""
    endif

    ; If identity isn't ready yet, do nothing.
    if pn == ""
        return ""
    endif

    ; Keep placeholder-name mint policy consistent with EnsureGuid().
    if IsPlaceholderName(pn)
        if !_placeholderGuidMintAllowed
            LogIdentity(IronSoulConfig.LOG_INFO(), "TryRestoreGuidTamperedCosave: delaying suspicious GUID resolution for placeholder name (" + pn + ") until bootstrap timeout")
            return ""
        endif
        LogIdentity(IronSoulConfig.LOG_INFO(), "TryRestoreGuidTamperedCosave: placeholder-name suspicious GUID resolution allowed after bootstrap timeout (" + pn + ")")
    endif

    Int lvlNow = player.GetLevel()
    if lvlNow <= 1
        ; New games naturally start at level 1. Do not "recover".
        EnsureGuidMarker(cosaveGuid)
        return cosaveGuid
    endif

    if !IronSoulNative.DataStoreReady()
        LogIdentity(IronSoulConfig.LOG_INFO(), "TryRestoreGuidTamperedCosave: MainData not ready; deferring suspicious GUID resolution")
        return ""
    endif

    ; If MainData has no index, we cannot prove co-save is wrong. Prefer co-save and heal MainData.
    String idx = IronSoulNative.DataGetString(_guidIndexKey, "")
    if idx == ""
        EnsureGuidMarker(cosaveGuid)
        return cosaveGuid
    endif

    ; If MainData already knows this GUID, accept it and heal marker/index.
    if IronSoulNative.DataGetInt("G.U." + cosaveGuid, 0) != 0
        EnsureGuidInIndex(cosaveGuid)
        return cosaveGuid
    endif

    ; Index containment check (delimiter-safe).
    String hay = "|" + idx + "|"
    String needle = "|" + cosaveGuid + "|"
    if StringUtil.Find(hay, needle) != -1
        EnsureGuidMarker(cosaveGuid)
        return cosaveGuid
    endif

    ; At this point, co-save GUID exists but is unknown to MainData -> suspicious.
    ; Try to recover the most likely historical GUID via identity snapshots.

    ; Current identity fields
    Int ridNow = 0
    Race rNow = player.GetRace()
    if rNow
        ridNow = rNow.GetFormID()
    endif
    Int dayNow = Utility.GetCurrentGameTime() as Int

    String bestGuid = ""
    Int bestMatches = 0
    Int bestDayDelta = 999999
    Int bestLvlDelta = 999999
    Int secondBestMatches = 0
    Bool bestNameMatch = False
    Bool bestRaceMatch = False

    Int i = 0
    Int len = StringUtil.GetLength(idx)
    While i < len
        Int j = StringUtil.Find(idx, "|", i)
        String cand = ""
        if j == -1
            cand = StringUtil.Substring(idx, i)
            i = len
        else
            cand = StringUtil.Substring(idx, i, j - i)
            i = j + 1
        endif

        if cand == ""
            ; Skip empty token.
        elseif cand == cosaveGuid
            ; Skip: co-save GUID is explicitly *not* trusted here.
        else
            ; Snapshot reads (per GUID)
            String nSaved = IronSoulNative.DataGetString(IronSoulPersistence.MakeKey("I.N", cand), "")
            Int rSaved = IronSoulNative.DataGetInt(IronSoulPersistence.MakeKey("I.R", cand), -1)
            Int lSaved = IronSoulNative.DataGetInt(IronSoulPersistence.MakeKey("I.L", cand), -1)
            Int tSaved = IronSoulNative.DataGetInt(IronSoulPersistence.MakeKey("I.D", cand), -1)

            Int matches = 0
            Bool nameMatch = False
            Bool raceMatch = False

            ; 1) Name
            if nSaved != "" && pn == nSaved
                matches += 1
                nameMatch = True
            endif

            ; 2) Race
            if rSaved >= 0 && ridNow == rSaved
                matches += 1
                raceMatch = True
            endif

            ; 3) Level proximity
            Int dL = 999999
            if lSaved >= 0
                dL = lvlNow - lSaved
                if dL < 0
                    dL = -dL
                endif
                if dL <= _idLevelTolerance
                    matches += 1
                endif
            endif

            ; 4) Day proximity
            Int dT = 999999
            if tSaved >= 0
                dT = dayNow - tSaved
                if dT < 0
                    dT = -dT
                endif
                if dT <= _idDayTolerance
                    matches += 1
                endif
            endif

            ; Keep the best candidate. Ties: prefer closer day, then closer level.
            Bool takesBest = False
            if matches > bestMatches
                takesBest = True
            elseif matches == bestMatches && matches > 0
                if dT < bestDayDelta || (dT == bestDayDelta && dL < bestLvlDelta)
                    takesBest = True
                endif
            endif

            if takesBest
                if bestMatches > secondBestMatches
                    secondBestMatches = bestMatches
                endif
                bestGuid = cand
                bestMatches = matches
                bestDayDelta = dT
                bestLvlDelta = dL
                bestNameMatch = nameMatch
                bestRaceMatch = raceMatch
            else
                if matches > secondBestMatches
                    secondBestMatches = matches
                endif
            endif
        endif
    EndWhile

    ; Require a strong, unambiguous winner to overwrite co-save.
    Bool strongUnique = False
    if bestGuid != "" && bestMatches > secondBestMatches
        if bestMatches >= 4
            strongUnique = True
        elseif bestMatches == 3 && bestNameMatch && bestRaceMatch && secondBestMatches <= 1
            strongUnique = True
        endif
    endif

    if !strongUnique
        ; Inconclusive: do not trust suspicious co-save GUID. Mint a new GUID to keep runtime non-blocking.
        Float nowRT = Utility.GetCurrentRealTime()
        if nowRT < _guidMintRetryAt
            return ""
        endif

        String newGuid = IronSoulNative.GenerateGuidUnique(pn)
        if newGuid == ""
            _guidMintRetryAt = nowRT + 10.0
            LogIdentity(IronSoulConfig.LOG_ERR(), "TryRestoreGuidTamperedCosave: suspicious co-save GUID '" + cosaveGuid + "' had no strong unique match and mint failed; backoff 10s before retry")
            return ""
        endif

        _guidMintRetryAt = 0.0
        CommitGuid(player, newGuid, pn)
        HandleNewTestCharacterGuid(newGuid, pn)

        LogIdentity(IronSoulConfig.LOG_ERR(), "TryRestoreGuidTamperedCosave: suspicious co-save GUID '" + cosaveGuid + "' had no strong unique match; minted new GUID '" + newGuid + "'")
        if !_guidTamperMintNotified
            _guidTamperMintNotified = True
            Debug.Notification(IronSoulNative.TextGet("Notification.IdentityNew"))
        endif

        return newGuid
    endif

    ; Restore authoritative GUID back to co-save directly (do NOT use Persist helpers).
    CommitGuid(player, bestGuid, pn)

    LogIdentity(IronSoulConfig.LOG_INFO(), "TryRestoreGuidTamperedCosave: GUID tamper recovery: co-save '" + cosaveGuid + "' -> restored '" + bestGuid + "' (" + bestMatches + "/4, runnerUp=" + secondBestMatches + ")")

    return bestGuid
EndFunction
