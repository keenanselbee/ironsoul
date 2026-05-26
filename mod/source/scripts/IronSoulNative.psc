Scriptname IronSoulNative Hidden

; --- Native Bridge Contract ---
; ==============================

; Exposes Iron Soul SKSE plugin services to Papyrus. Contains no gameplay logic.
; Papyrus owns gameplay policy, schema, limits, and the authoritative GUID slot.
;
; Native services:
; - DataStore persistence and journal file writes.
; - INI config cache, validation, and optional INI persistence.
; - GUID minting, dynamic asset swaps, cursor control, music fades, and slow motion.
;
; Storage contract:
; - MainData: Data\SKSE\plugins\ironsoul-character-data.dat
; - MirrorData: Data\SKSE\plugins\ironsoul-character-mirror-data.dat
; - MirrorData is used only when MirrorDataBackup=1.
; - Files are transactional, FNV-1a checked, size capped, and sequence numbered.
; - On load, the newest valid store wins; equal-sequence divergence prefers MainData.
; - Dirty data flushes on SKSE save callback or explicit DataFlushIfDirty().
; - There is no periodic flush thread.
;
; Key contract:
; - DataStore keys are flat strings with Int or String values.
; - Normal DataStore calls do not enforce gameplay schema.
; - MainData stores gameplay state; StorageUtil stores IS_9975 as the GUID authority.
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
; LogJournalEntry()

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

; --- Identity / GUID Utilities ---
; ---------------------------------
; GetPlayerName()
; GenerateGuidUnique()

; --- Dynamic UI ---
; ------------------
; ApplyDynamicSplash()
; ApplyDynamicLevelWidget()
; ApplyDynamicDraugrEyes()
; OpenMenu()
; CloseMenu()

; --- Cursor Control ---
; ----------------------
; SuppressCursor()

; --- Music Fade ---
; ------------------
; MusicFadeOut()
; MusicFadeIn()

; --- Health Monitoring ---
; -------------------------
; StartHealthMonitor()
; StopHealthMonitor()

; --- Heartstone Enhancement ---
; ------------------------------
; HeartstoneBuildEnhanceSession()
; HeartstoneGetEnhanceSessionOptionCount()
; HeartstoneGetEnhanceSessionOptionLabel()
; HeartstoneRefreshEnhanceSessionInventoryRows()
; HeartstoneApplyEnhanceSessionOption()
; HeartstoneApplyEnhanceSessionInventoryRow()
; HeartstoneReleaseEnhanceSession()
; HeartstoneGetEnhanceResult()
; HeartstoneGetEnhanceResultText()

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

; Appends a character journal line. Native prefixes "Name [D/H/A++] | ".
; File: Data\SKSE\plugins\ironsoul-character-journal.log
Function LogJournalEntry(String msg) Global Native


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


; --- IDENTITY / GUID UTILITIES ---
; =================================

; Returns "" until the player name is stable enough for identity setup.
String Function GetPlayerName() Global Native

; Returns <LETTER><####>, claiming G.U.<GUID> in MainData atomically.
; Retries 64 four-digit values, then 64 six-digit values, then returns "".
; Caller writes the GUID to co-save IS_9975 and maintains G.U.INDEX.
; Recovered/imported GUIDs must also ensure G.U.<GUID> exists.
String Function GenerateGuidUnique(String playerName) Global Native


; --- DYNAMIC UI ---
; ==================
;
; Immediately swaps global packaged assets; native stores no tier/preset state.
; Modes: 0=restore backup, 1=dynamic, 2=static packaged source.
; Public INI validation currently allows only modes 0 and 1.
; Tiers: 0 Defiant, 1 Iron, 2 Silver, 3 Gold, 4 Ebon, 5 Platinum, 6 Devour, 9 CHIM.
; Splash presets: 0 normal, 1/2/3 preset-prefixed; CHIM falls back for 2/3.
; Draugr eye presets: 0 ORIGINAL, 1 BLUE, 2 PURPLE, 3 RED.
; Non-Iron Soul live files get numbered BACKUP copies before replacement.
; Missing files skip only the affected asset; UI caching may need reload/restart.
Function ApplyDynamicSplash(Int tierId, Int presetId) Global Native
Function ApplyDynamicLevelWidget(Int tierId) Global Native
Function ApplyDynamicDraugrEyes(Int presetId) Global Native

; Queues a vanilla UI menu open/close request. Returns false when native UI queue is unavailable.
Bool Function OpenMenu(String menuName) Global Native
Bool Function CloseMenu(String menuName) Global Native


; --- CURSOR CONTROL ---
; =====================
;
; CursorHide=0 no-ops. True advances move-right -> hide/off-screen.
; Later True calls reapply suppression; one False restores the saved state.
Function SuppressCursor(Bool suppress) Global Native


; --- MUSIC FADE ---
; ==================
;
; MusicFade=0 no-ops. FadeOut caches menuVolume as the FadeIn restore target.
Function MusicFadeOut(SoundCategory musicCategory, Float seconds = 2.0, Float menuVolume = -1.0) Global Native
Function MusicFadeIn(SoundCategory musicCategory, Float seconds = 2.0) Global Native


; --- HEALTH MONITORING ---
; =========================
;
; Starts/stops 0.1s native health polling for slow motion only.
; Does not dispatch death events to Papyrus.
Function StartHealthMonitor() Global Native
Function StopHealthMonitor() Global Native


; --- HEARTSTONE ENHANCEMENT ---
; ==============================

; Builds an Iron Soul-owned filtered enhancement session.
; effectId 1 is Tonal tempering. Returns 0 when no valid session can be built.
Int Function HeartstoneBuildEnhanceSession(Int effectId, Int power, Int cap) Global Native

; Returns the number of displayable options in a session.
Int Function HeartstoneGetEnhanceSessionOptionCount(Int sessionToken) Global Native

; Returns one display label for an option index.
String Function HeartstoneGetEnhanceSessionOptionLabel(Int sessionToken, Int optionIndex) Global Native

; Rebuilds the InventoryMenu row whitelist for a session and returns rowIndex_:_label entries.
String Function HeartstoneRefreshEnhanceSessionInventoryRows(Int sessionToken) Global Native

; Applies and consumes one session option. False means HeartstoneGetEnhanceResult* explains the failure.
Bool Function HeartstoneApplyEnhanceSessionOption(Int sessionToken, Int optionIndex) Global Native

; Applies and consumes one visible InventoryMenu row from the latest row refresh.
Bool Function HeartstoneApplyEnhanceSessionInventoryRow(Int sessionToken, Int rowIndex) Global Native

; Releases a session after cancel/failure. Safe to call for already-consumed tokens.
Function HeartstoneReleaseEnhanceSession(Int sessionToken) Global Native

; Result code/text for the most recent Heartstone enhancement native operation.
Int Function HeartstoneGetEnhanceResult() Global Native
String Function HeartstoneGetEnhanceResultText() Global Native

; --- DATASTORE - READ ACCESS ---
; ===============================

; Reads an Int from MainData, or fallback when missing/wrong type.
Int Function DataGetInt(String key, Int fallback = 0) Global Native

; Reads a String from MainData, or fallback when missing/wrong type.
String Function DataGetString(String key, String fallback = "") Global Native

; True when MainData contains the key.
Bool Function DataHasKey(String key) Global Native

; Friendly current-character dump for console/debug output.
; section="" dumps all; known sections include identity, core, luck, ui, soul,
; dsr, bosses, defiant, and journal.
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


; --- DATASTORE - FLUSH CONTROL ---
; =================================

; Flushes dirty MainData, and MirrorData when MirrorDataBackup=1.
Function DataFlushIfDirty() Global Native
