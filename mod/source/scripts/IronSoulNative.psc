Scriptname IronSoulNative Hidden

; --- Native Bridge Contract ---
; ==============================

; Exposes Iron Soul SKSE plugin services to Papyrus. Contains no gameplay logic.
; Papyrus owns gameplay policy, schema, and limits; native owns the current-save GUID slot.
;
; Native services:
; - DataStore persistence and journal file writes.
; - INI config cache, validation, and optional INI persistence.
; - Text catalog lookup for Iron Soul-owned runtime strings.
; - GUID minting, dynamic asset swaps, cursor control, music fades, and slow motion.
;
; Storage contract:
; - MainData: Data\SKSE\plugins\ironsoul\ironsoul-main-data.dat
; - MirrorData: Data\SKSE\plugins\ironsoul\ironsoul-mirror-data.dat
; - MirrorData is used only when MirrorDataBackup=1.
; - Files are transactional, FNV-1a checked, size capped, and sequence numbered.
; - On load, the newest valid store wins; equal-sequence divergence prefers MainData.
; - Dirty data flushes on SKSE save callback, explicit DataFlushIfDirty(), or native runtime flush heartbeat.
; - SKSE serialization stores the current-save GUID and a compact recovery snapshot for vital current-character and World progression values.
;
; Key contract:
; - DataStore keys are flat strings with Int or String values.
; - Normal DataStore calls do not enforce gameplay schema.
; - MainData stores gameplay state; native SKSE serialization stores the current-save GUID authority.
; - GUID-scoped MainData keys use <KEY>:<GUID>; G.U.* keys are global identity indexes.

; =========================
; --- Table of Contents ---
; =========================

; --- Plugin Health / Availability ---
; ------------------------------------
; IsAvailable()
; DataStoreReady()

; --- Journal Logging ---
; -----------------------
; JournalLogEvent()
; JournalLogDefeatOutcome()
; JournalLogDefeatLuckOutcome()
; JournalLogTrueDeathOutcome()
; JournalLogDefiantFatigueOutcome()
; JournalLogLuckOutcome()
; JournalLogAnimaAward()
; JournalFlushDailyAnima()
; JournalNoteDailyAnimaAward()
; JournalLogSoulFeat()
; JournalLogDefiantSoulFeat()
; JournalLogDefiantRestore()
; JournalLogDefiantAwakened()
; JournalLogCHIMRealized()

; --- Config Access ---
; ---------------------
; GetConfigInt()
; GetIronSoulPresetOrdinal()
; SetEffectiveDisplayDifficulty()
; GetConfigKeyCanonical()
; GetConfigKeyDisplayName()
; GetConfigKeyFlags()
; GetConfigSetError()
; GetConfigSummary()
; SetConfigInt()
; SetConfigString()
; ReloadConfig()

; --- Text Catalog ---
; --------------------
; TextGet()
; TextFormat1()
; TextFormat2()
; TextFormat3()
; TextFormat4()

; --- Identity / GUID Utilities ---
; ---------------------------------
; GetPlayerName()
; GenerateGuidUnique()
; IdentityGetCurrentGuid()
; IdentitySetCurrentGuid()
; IdentityApplyLoadedSnapshot()
; IdentityGetLoadedSnapshot()

; --- Anima Progression ---
; -------------------------
; AnimaGetCharacter()
; AnimaGetWorld()
; SoulTierGetWorld()
; AnimaGetEligibleMilestone()
; AnimaGetRequiredForMilestone()
; AnimaAddCharacter()
; AnimaSetCharacter()
; AnimaSetWorld()
; SoulTierSetWorld()
; AnimaPollBossLatches()
; DeathSinkDrainAnimaAwards()
; SoulLevelGetSlainWorld()
; SoulLevelGetSlainCharacter()

; --- Dynamic UI ---
; ------------------
; ApplyDynamicSplash()
; ApplyDynamicLevelWidget()
; ApplyDynamicDraugrEyes()
; OpenMenu()
; CloseMenu()
; InventorySelectedItemHasEditorIDPrefix()
; InventorySelectedItemHasEditorID()

; --- Cursor Control ---
; ----------------------
; BeginCursorSuppress()
; EndCursorSuppress()
; PrimeCursorSuppress()
; RefreshCursorSuppress()

; --- Menu Blocking ---
; ---------------------
; BeginMenuBlock()
; EndMenuBlock()
; ClearMenuBlock()
; ClearMenuBlockPreserveLoad()
; EndLoadMenuBlock()

; --- Music Fade ---
; ------------------
; MusicFadeIsActive()
; MusicFadeRecoverAfterLoad()
; MusicFadeOut()
; MusicFadeIn()

; --- Native Audio ---
; --------------------
; AudioPlay()
; AudioPlayTracked()
; AudioFadeOutTracked()
; AudioStopTracked()
; AudioStopAllTracked()

; --- Sunderheart Focus Audio ---
; --------------------------------
; SunderheartFocusConfigure()
; SunderheartFocusConfigureInventoryHover()
; SunderheartUseIntentConfigureInventoryForms()
; SunderheartUseIntentBeginCapture()
; SunderheartUseIntentClearCapture()
; SunderheartUseIntentClaim()
; SunderheartUseIntentClaimedBaseForm()
; SunderheartUseIntentClaimedTier()
; SunderheartUseIntentClaimedAgeSeconds()
; SunderheartUseIntentClaimedSource()
; SunderheartFocusSetHoverTarget()
; SunderheartFocusClearHoverTarget()
; SunderheartFocusSuppressInventoryHover()
; SunderheartFocusClearInventoryHoverSuppression()
; SunderheartFocusSetActionTarget()
; SunderheartFocusClearActionTarget()
; SunderheartFocusSetUseTarget()
; SunderheartFocusClearUseTarget()
; SunderheartFocusPresentationHandoff()
; SunderheartFocusClearCancelTargets()
; SunderheartFocusStopImmediate()

; --- Health Monitoring ---
; -------------------------
; StartHealthMonitor()
; StopHealthMonitor()
; HoldDeathSlowMo()
; ReleaseDeathSlowMo()
; ReleaseDeathSlowMoWithHold()
; TransitionDeathSlowMoToHold()
; ClearDeathSlowMo()
; StartTimeMultiplierRamp()
; ClearTimeMultiplierRamp()
; TryStartFeatUnlockSlowMo()
; ReleaseFeatUnlockSlowMo()
; ClearFeatUnlockSlowMo()
; KillPlayerImmediate()

; --- Runtime Pulse ---
; ---------------------
; QueueRuntimeUpdate()
; CancelRuntimeUpdate()
; QueueFeatUnlockMenuAlarm()
; CancelFeatUnlockMenuAlarm()
; BeginRespawnStateMonitor()
; EndRespawnStateMonitor()
; GetActiveGameplaySeconds()
; GetWallClockSeconds()
; EnsureNewGameIntroClockStarted()
; GetNewGameIntroElapsedSeconds()
; QueueNewGameIntroAlarm()
; CancelNewGameIntroAlarm()
; QueueActiveGameplayAlarm()
; CancelActiveGameplayAlarm()
; BeginDragonSoulWatcher()
; EndDragonSoulWatcher()

; --- Sunderheart Enhancement ---
; ------------------------------
; SunderheartBuildEnhanceSession()
; SunderheartGetEnhanceSessionOptionCount()
; SunderheartGetEnhanceSessionOptionLabel()
; SunderheartRefreshEnhanceSessionInventoryRows()
; SunderheartApplyEnhanceSessionOption()
; SunderheartApplyEnhanceSessionInventoryRow()
; SunderheartReleaseEnhanceSession()
; SunderheartGetEnhanceResult()
; SunderheartGetEnhanceResultText()

; --- DataStore Read Access ---
; -----------------------------
; DataGetInt()
; DataGetString()
; DataHasKey()
; DataGetCharacterData()

; --- DataStore Write Access ---
; ------------------------------
; DataSetInt()
; DataSetString()
; DataSetIntIfChanged()
; DataSetIntChecked()
; DataSetStringIfChanged()
; DataSetStringChecked()
; DataDeleteKey()
; DataDeleteKeysWithPrefix()

; --- DataStore Health ---
; ------------------------
; DataStoreSizeWarningPending()
; DataStoreConsumeSizeWarning()
; CharacterDataPathWarningPending()
; CharacterDataPathConsumeWarning()

; --- DataStore Flush Control ---
; --------------------------------
; DataFlushIfDirty()


; --- PLUGIN HEALTH / AVAILABILITY ---
; ====================================

; Native registration and DataStore initialization probes.
; IsAvailable() only proves the plugin registered this script's natives.
; DataStoreReady() also proves native persistence initialized.
Bool Function IsAvailable() Global Native
Bool Function DataStoreReady() Global Native


; --- JOURNAL LOGGING ---
; =======================

; Builds "Day X: <event>", writes to the per-character Oghma journal source, and returns success.
Bool Function JournalLogEvent(String guid, String eventText, Int startDay, Int nowDay) Global Native

; Native one-shot journal event builders and appenders.
Bool Function JournalLogDefeatOutcome(String guid, Int deathsNow, Int maxLives, Int startDay, Int nowDay) Global Native
Bool Function JournalLogDefeatLuckOutcome(String guid, Int deathsNow, Int maxLives, Int roll, Int luck, Int startDay, Int nowDay) Global Native
Bool Function JournalLogTrueDeathOutcome(String guid, Int deathsNow, Int maxLives, Int startDay, Int nowDay) Global Native
Bool Function JournalLogDefiantFatigueOutcome(String guid, Int deathsNow, Int maxLives, Bool terminal, Int startDay, Int nowDay) Global Native
Bool Function JournalLogLuckOutcome(String guid, Int luck, Int roll, Int maxLuck, Int startDay, Int nowDay) Global Native
Bool Function JournalLogAnimaAward(String guid, String source, Int amount, Int startDay, Int nowDay) Global Native
Bool Function JournalFlushDailyAnima(String guid) Global Native
Bool Function JournalNoteDailyAnimaAward(String guid, String source, Int amount, Int priority) Global Native
Bool Function JournalLogSoulFeat(String guid, Int soulTier, Int totalDeaths, Int startDay, Int nowDay) Global Native
Bool Function JournalLogDefiantSoulFeat(String guid, Int totalDeaths, Int startDay, Int nowDay) Global Native
Bool Function JournalLogDefiantRestore(String guid, Int targetTier, Int totalDeaths, Int startDay, Int nowDay) Global Native
Bool Function JournalLogDefiantAwakened(String guid, Int startDay, Int nowDay) Global Native
Bool Function JournalLogCHIMRealized(String guid, Int startDay, Int nowDay) Global Native
Bool Function JournalRefreshBook(String currentGuid) Global Native
Bool Function DynamicBookRefreshOghma(String currentGuid) Global Native
Bool Function DynamicBookRefreshOpen(String bookId) Global Native
Bool Function JournalDeleteCharacter(String guid) Global Native


; --- CONFIG ACCESS ---
; =====================

; Reads and edits allowlisted config keys from ironsoul.ini.
; SetConfig* validates values; persistToIni=True requires an existing INI entry.
; IronSoulPreset accepts base-plus text, but reads return the flattened ordinal.
Int Function GetConfigInt(String key, Int fallback = 0) Global Native
Int Function GetIronSoulPresetOrdinal() Global Native
Bool Function SetEffectiveDisplayDifficulty(Int presetFamily, Int displayRank) Global Native
String Function GetConfigKeyCanonical(String key) Global Native
String Function GetConfigKeyDisplayName(String key) Global Native
Int Function GetConfigKeyFlags(String key) Global Native
String Function GetConfigSetError(String key, String value) Global Native
String Function GetConfigSummary() Global Native
Bool Function SetConfigInt(String key, Int value, Bool persistToIni = True) Global Native
Bool Function SetConfigString(String key, String value, Bool persistToIni = True) Global Native
Bool Function ReloadConfig() Global Native


; --- TEXT CATALOG ---
; ====================

; Looks up a text catalog value. Missing keys return a visible marker.
String Function TextGet(String key) Global Native

; Looks up a text catalog value and replaces {token} placeholders.
String Function TextFormat1(String key, String token1, String value1) Global Native
String Function TextFormat2(String key, String token1, String value1, String token2, String value2) Global Native
String Function TextFormat3(String key, String token1, String value1, String token2, String value2, String token3, String value3) Global Native
String Function TextFormat4(String key, String token1, String value1, String token2, String value2, String token3, String value3, String token4, String value4) Global Native


; --- IDENTITY / GUID UTILITIES ---
; =================================

; Returns "" until the player name is stable enough for identity setup.
String Function GetPlayerName() Global Native

; Returns <LETTER><####>, claiming G.U.<GUID> in MainData atomically.
; Retries 64 four-digit values, then 64 six-digit values, then returns "".
; Caller writes the GUID to native current-save identity and maintains G.U.INDEX.
; Recovered/imported GUIDs must also ensure G.U.<GUID> exists.
String Function GenerateGuidUnique(String playerName) Global Native

; Current-save GUID authority owned by native SKSE serialization.
String Function IdentityGetCurrentGuid() Global Native
Bool Function IdentitySetCurrentGuid(String guid) Global Native

; Snapshot payloads:
; ok|guid|mask|currentDeaths|lifetimeDeaths|characterAnima|dragonSoulsTotal|worldAnima|saveHighestUnlockedTier|worldDragonSoulsTotal|soulTier
; skip|reason, or error|reason.
String Function IdentityApplyLoadedSnapshot(String guid) Global Native
String Function IdentityGetLoadedSnapshot() Global Native


; --- ANIMA PROGRESSION ---
; =========================
;
; ST.W is the save highest unlocked tier, not the canonical live tier:
; 0=Iron/baseline, 1=Defiant, 2=Silver, 3=Gold, 4=Ebon, 5=Platinum, 6=Devour.
; CHIM is outside Anima progression and is never stored in ST.W.
Int Function AnimaGetCharacter(String guid) Global Native
Int Function AnimaGetWorld() Global Native
Int Function SoulTierGetWorld() Global Native
Int Function AnimaGetEligibleMilestone(String guid, Int characterDragonSouls, Int currentDeaths) Global Native
Int Function AnimaGetRequiredForMilestone(Int milestone) Global Native
String Function AnimaAddCharacter(String guid, Int amount, String source, Int characterDragonSouls, Int currentDeaths, Bool updateWorld = True) Global Native
String Function AnimaSetCharacter(String guid, Int value, Int characterDragonSouls, Int currentDeaths) Global Native
String Function AnimaSetWorld(Int value) Global Native
String Function SoulTierSetWorld(Int tier) Global Native

; Returns one or more Anima result payloads separated by newlines, skip|reason, or error|reason.
String Function AnimaPollBossLatches(String guid, Int characterDragonSouls, Int currentDeaths, Bool updateWorld = True) Global Native
String Function DeathSinkDrainAnimaAwards() Global Native
Int Function SoulLevelGetSlainWorld(Int tier) Global Native
Int Function SoulLevelGetSlainCharacter(String guid, Int tier) Global Native


; --- DYNAMIC UI ---
; ==================
;
; Splash and draugr eyes swap packaged assets; native stores no tier/preset state for them.
; Level widget art updates through the packaged lvlWidget.swf live Scaleform method.
; Level widget modes: 0=static Iron icon, 1=live tier icon.
; Tiers: 0 Defiant, 1 Iron, 2 Silver, 3 Gold, 4 Ebon, 5 Platinum, 6 Devour, 9 CHIM.
; Splash presets: 0 normal, 1/2/3 preset-prefixed; CHIM falls back for 2/3.
; Draugr eye presets: 0 ORIGINAL, 1 BLUE, 2 PURPLE, 3 RED.
; Non-Iron Soul splash/eye live files get numbered BACKUP copies before replacement.
; Missing splash/eye files skip only the affected asset; the level widget tier caches until lvlWidget opens.
Function ApplyDynamicSplash(Int tierId, Int presetId) Global Native
Function ApplyDynamicLevelWidget(Int tierId) Global Native
Function ApplyDynamicDraugrEyes(Int presetId) Global Native

; Queues a vanilla UI menu open/close request. Returns false when native UI queue is unavailable.
Bool Function OpenMenu(String menuName) Global Native
Bool Function CloseMenu(String menuName) Global Native

; Returns InventoryMenu's currently highlighted base item, or None when unavailable.
Form Function InventorySelectedItemForm() Global Native

; Returns true when InventoryMenu's highlighted row has a base item EditorID with the given prefix.
Bool Function InventorySelectedItemHasEditorIDPrefix(String editorIDPrefix) Global Native

; Returns true when InventoryMenu's highlighted row has a base item with the exact EditorID.
Bool Function InventorySelectedItemHasEditorID(String editorID) Global Native

; Resolves a hex or decimal FormID string to a live Form, or None when invalid/unloaded.
Form Function FormIDStringToForm(String formIDText) Global Native

; Resolves a hex or decimal FormID string and returns true when its EditorID has the given prefix.
Bool Function FormIDStringHasEditorIDPrefix(String formIDText, String editorIDPrefix) Global Native

; Resolves a hex or decimal FormID string and returns true when its EditorID is an exact match.
Bool Function FormIDStringHasEditorID(String formIDText, String editorID) Global Native


; --- CURSOR CONTROL ---
; =====================
;
; CursorHide=0 makes BeginCursorSuppress() return 0.
; Positive tokens hide/off-screen the cursor until each token is ended once.
Int Function BeginCursorSuppress() Global Native
Function EndCursorSuppress(Int token) Global Native
Function PrimeCursorSuppress() Global Native
Function RefreshCursorSuppress() Global Native


; --- MENU BLOCKING ---
; =====================
;
; Anticheat=0 makes BeginMenuBlock() return 0. EndMenuBlock(0) is safe.
Int Function BeginMenuBlock(String reason, Bool releaseOnMainMenu = False) Global Native
Function EndMenuBlock(Int token) Global Native
Function ClearMenuBlock() Global Native
Function ClearMenuBlockPreserveLoad() Global Native
Function EndLoadMenuBlock(String reason = "") Global Native


; --- MUSIC FADE ---
; ==================
;
; MusicFade=0 blocks new FadeOut sessions; FadeIn may still restore an already-active session.
; Load recovery bypasses MusicFade and immediately restores override/fallback volume when a fade crossed a load boundary.
Bool Function MusicFadeIsActive() Global Native
Bool Function MusicFadeRecoverAfterLoad(SoundCategory musicCategory, Float fallbackMenuVolume = 1.0, Bool savedFadeActive = False) Global Native
Function MusicFadeOut(SoundCategory musicCategory, Float seconds = 2.0, Float menuVolume = -1.0) Global Native
Function MusicFadeIn(SoundCategory musicCategory, Float seconds = 2.0, Float fallbackMenuVolume = -1.0) Global Native


; --- NATIVE AUDIO ---
; ====================

; Plays a Sound through the native descriptor path. Returns false when the descriptor cannot be built or played.
Bool Function AudioPlay(Sound sfx, ObjectReference source, Float volume = 1.0, String reason = "") Global Native

; Plays a Sound through the native descriptor path and stores a transient runtime handle. Returns -1 on failure.
Int Function AudioPlayTracked(Sound sfx, ObjectReference source, Float volume = 1.0, String reason = "") Global Native

; Fades and stops a tracked native audio token. Tokens are transient and are cleared across load/new-game boundaries.
Bool Function AudioFadeOutTracked(Int token, Float seconds = 1.0, String reason = "") Global Native
Bool Function AudioStopTracked(Int token, String reason = "") Global Native
Function AudioStopAllTracked(String reason = "") Global Native


; --- SUNDERHEART FOCUS AUDIO ---
; ===============================

; Configures the native focus loop sound. Returns false when the Sound property is not wired.
Bool Function SunderheartFocusConfigure(Sound focusLoop) Global Native

; Configures native InventoryMenu selected-row hover ownership for Sunderheart focus audio.
Bool Function SunderheartFocusConfigureInventoryHover(FormList tier1, FormList tier2, FormList tier3, FormList tier4, FormList tier5, Form spent) Global Native

; Configures native InventoryMenu selected-row Sunderheart use intent capture.
Bool Function SunderheartUseIntentConfigureInventoryForms(FormList tier1, FormList tier2, FormList tier3, FormList tier4, FormList tier5, Form spent) Global Native

; Starts/clears a short native input capture window for InventoryMenu Sunderheart use intents.
Function SunderheartUseIntentBeginCapture(Float seconds = 0.75, String reason = "") Global Native
Function SunderheartUseIntentClearCapture(String reason = "") Global Native

; Claims the latest native-captured Sunderheart use intent, then exposes its details through the readback functions.
Bool Function SunderheartUseIntentClaim() Global Native
Form Function SunderheartUseIntentClaimedBaseForm() Global Native
Int Function SunderheartUseIntentClaimedTier() Global Native
Float Function SunderheartUseIntentClaimedAgeSeconds() Global Native
String Function SunderheartUseIntentClaimedSource() Global Native

; Sets the debounced inventory-hover target volume. Passing 0.0 requests a debounced hover clear.
Function SunderheartFocusSetHoverTarget(Float volume) Global Native

; Immediately clears the inventory-hover target, for hard transitions such as menu close or cancel.
Function SunderheartFocusClearHoverTarget() Global Native

; Suppresses native hover for the currently selected InventoryMenu row until selection moves.
Function SunderheartFocusSuppressInventoryHover(String reason = "") Global Native

; Clears native InventoryMenu hover suppression.
Function SunderheartFocusClearInventoryHoverSuppression(String reason = "") Global Native

; Sets or clears the action-choice menu target.
Function SunderheartFocusSetActionTarget(Float volume) Global Native
Function SunderheartFocusClearActionTarget() Global Native

; Sets or clears the Sunderheart use-flow target. immediate=True stops all focus audio now.
Function SunderheartFocusSetUseTarget(Float volume) Global Native
Function SunderheartFocusClearUseTarget(Bool immediate = False) Global Native

; Clears all focus targets and begins the presentation/SFX handoff fade.
Function SunderheartFocusPresentationHandoff() Global Native

; Clears use/action targets after cancel while preserving hover focus.
Function SunderheartFocusClearCancelTargets() Global Native

; Immediately stops native focus audio and clears all native focus targets.
Function SunderheartFocusStopImmediate() Global Native


; --- HEALTH MONITORING ---
; =========================
;
; Starts/stops 0.2s native health polling for outcome-controlled slow motion.
; Does not dispatch death events to Papyrus.
Function StartHealthMonitor() Global Native
Function StopHealthMonitor() Global Native
Function HoldDeathSlowMo(String reason = "") Global Native
Function ReleaseDeathSlowMo(Float recoverySeconds = 1.0, Float delaySeconds = 0.0, String reason = "") Global Native
Function ReleaseDeathSlowMoWithHold(Float holdMultiplier = 0.5, Float holdSeconds = 5.0, Float recoverySeconds = 1.0, String reason = "") Global Native
Function TransitionDeathSlowMoToHold(Float holdMultiplier = 0.6, Float transitionSeconds = 1.0, String reason = "") Global Native
Function ClearDeathSlowMo(String reason = "") Global Native
Function StartTimeMultiplierRamp(Float fromMultiplier = 1.0, Float toMultiplier = 1.0, Float seconds = 0.0, String reason = "") Global Native
Function ClearTimeMultiplierRamp(String reason = "") Global Native
Bool Function TryStartFeatUnlockSlowMo(Float seconds = 0.75, String reason = "") Global Native
Function ReleaseFeatUnlockSlowMo(Float seconds = 2.0, String reason = "") Global Native
Function ClearFeatUnlockSlowMo(String reason = "") Global Native
Bool Function KillPlayerImmediate(Bool ragdollInstant = True, String reason = "") Global Native


; --- RUNTIME PULSE ---
; =====================
;
; Queues/cancels native timer wakeups that dispatch IronSoul_RuntimeUpdate.
Int Function QueueRuntimeUpdate(Float delaySeconds, String reason = "") Global Native
Function CancelRuntimeUpdate(Int token = 0, String reason = "") Global Native

; Queues/cancels the dedicated wall-clock feat unlock menu wakeup.
Int Function QueueFeatUnlockMenuAlarm(Float delaySeconds, String reason = "") Global Native
Function CancelFeatUnlockMenuAlarm(Int token = 0, String reason = "") Global Native

; Starts/stops a native monitor that wakes Papyrus when respawn recovery/death/watchdog state changes.
Int Function BeginRespawnStateMonitor(Float watchdogSeconds = 30.0, String reason = "") Global Native
Function EndRespawnStateMonitor(Int token = 0, String reason = "") Global Native

; Native active gameplay seconds count only while normal gameplay is running.
Int Function GetActiveGameplaySeconds() Global Native

; Native wall-clock seconds from the plugin process; unaffected by SGTM.
Float Function GetWallClockSeconds() Global Native

; Starts the native intro clock when Papyrus OnInit confirms a fresh game and native VM revert did not already start it.
Bool Function EnsureNewGameIntroClockStarted(String reason = "") Global Native

; Returns non-menu seconds since native fresh-game detection, or -1.0 when no intro clock is active.
Float Function GetNewGameIntroElapsedSeconds() Global Native

; Queues/cancels one-shot alarms tied to the native new-game intro active-gameplay clock.
Int Function QueueNewGameIntroAlarm(Float targetSeconds, String reason = "") Global Native
Function CancelNewGameIntroAlarm(Int token = 0, String reason = "") Global Native

; Queues/cancels one-shot active gameplay alarms that dispatch IronSoul_RuntimeUpdate.
Int Function QueueActiveGameplayAlarm(Int targetSecond, String reason = "") Global Native
Function CancelActiveGameplayAlarm(Int token = 0, String reason = "") Global Native

; Starts/stops native DragonSouls polling; Papyrus owns all accounting.
Int Function BeginDragonSoulWatcher(Int baselineDragonSouls = -1, Float pollSeconds = 0.5, String reason = "") Global Native
Function EndDragonSoulWatcher(Int token = 0, String reason = "") Global Native


; --- SUNDERHEART ENHANCEMENT ---
; ==============================

; Builds an Iron Soul-owned filtered enhancement session.
; effectId 1 is temper gear. Returns 0 when no valid session can be built.
Int Function SunderheartBuildEnhanceSession(Int effectId, Int power, Int cap) Global Native

; Returns the number of displayable options in a session.
Int Function SunderheartGetEnhanceSessionOptionCount(Int sessionToken) Global Native

; Returns one display label for an option index.
String Function SunderheartGetEnhanceSessionOptionLabel(Int sessionToken, Int optionIndex) Global Native

; Rebuilds the InventoryMenu row whitelist for a session and returns rowIndex_:_label entries.
String Function SunderheartRefreshEnhanceSessionInventoryRows(Int sessionToken) Global Native

; Applies and consumes one session option. False means SunderheartGetEnhanceResult* explains the failure.
Bool Function SunderheartApplyEnhanceSessionOption(Int sessionToken, Int optionIndex) Global Native

; Applies and consumes one visible InventoryMenu row from the latest row refresh.
Bool Function SunderheartApplyEnhanceSessionInventoryRow(Int sessionToken, Int rowIndex) Global Native

; Releases a session after cancel/failure. Safe to call for already-consumed tokens.
Function SunderheartReleaseEnhanceSession(Int sessionToken) Global Native

; Result code/text for the most recent Sunderheart enhancement native operation.
Int Function SunderheartGetEnhanceResult() Global Native
String Function SunderheartGetEnhanceResultText() Global Native

; --- DATASTORE - READ ACCESS ---
; ===============================

; Reads an Int from MainData, or fallback when missing/wrong type.
Int Function DataGetInt(String key, Int fallback = 0) Global Native

; Reads a String from MainData, or fallback when missing/wrong type.
String Function DataGetString(String key, String fallback = "") Global Native

; True when MainData contains the key.
Bool Function DataHasKey(String key) Global Native

; Friendly current-character dump for console/debug output.
; section="" dumps all; known sections include identity, world, core, luck,
; ui, soul, dsr, bosses, defiant, and journal.
String Function DataGetCharacterData(String guid, String section = "") Global Native


; --- DATASTORE - WRITE ACCESS ---
; ================================

; Writes an Int and marks MainData dirty if the key is valid.
Function DataSetInt(String key, Int value) Global Native

; Writes a String and marks MainData dirty if key/value are valid.
Function DataSetString(String key, String value) Global Native

; Hot-path Int write. True only when the stored value changed.
; False means unchanged or invalid key.
Bool Function DataSetIntIfChanged(String key, Int value) Global Native

; Console/debug Int write. True means the value is stored exactly.
Bool Function DataSetIntChecked(String key, Int value) Global Native

; Hot-path String write. True only when the stored value changed.
; False means unchanged, invalid key, or value too long.
Bool Function DataSetStringIfChanged(String key, String value) Global Native

; Console/debug String write. True means the value is stored exactly.
Bool Function DataSetStringChecked(String key, String value) Global Native

; Deletes a MainData key if it exists.
Function DataDeleteKey(String key) Global Native

; Deletes MainData keys whose names start with prefix. Returns deleted count.
Int Function DataDeleteKeysWithPrefix(String prefix) Global Native


; --- DATASTORE - HEALTH ---
; ==========================

; True once when native load detects a datastore approaching the hard cap.
Bool Function DataStoreSizeWarningPending() Global Native

; Consumes the pending datastore size warning so Papyrus can show it once.
Bool Function DataStoreConsumeSizeWarning() Global Native

; True once when native Auto storage falls back after detecting Hardlink Builder metadata.
Bool Function CharacterDataPathWarningPending() Global Native

; Consumes the pending CharacterDataPath warning so Papyrus can show it once.
Bool Function CharacterDataPathConsumeWarning() Global Native


; --- DATASTORE - FLUSH CONTROL ---
; =================================

; Flushes dirty MainData, and MirrorData when MirrorDataBackup=1.
Function DataFlushIfDirty() Global Native
