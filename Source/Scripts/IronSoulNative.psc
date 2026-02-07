Scriptname IronSoulNative Hidden

; =====================================================================================
; IronSoulNative.psc
;
; High-level native bridge for the Iron Soul SKSE plugin.
;
; This script intentionally contains NO gameplay logic.
; It exists solely to document and expose the persistence and logging services
; provided by the native SKSE plugin.
;
; -------------------------------------------------------------------------------------
; OVERVIEW
;
; The Iron Soul SKSE plugin owns ALL disk persistence and file I/O.
;
; The plugin provides:
;
;   1) Binary persistent storage (.dat)
;      - MainData  : Primary persistent store (preferred authority on load)
;      - MirrorData: Backup store used for recovery if MainData is missing/invalid
;
;   2) Atomic writes + integrity checking
;      - Writes are transactional (.tmp -> replace)
;      - Integrity hash is FNV-1a
;      - Corruption/tampering is detected and recovered automatically
;      - Safety caps are enforced on load to prevent pathological / malicious files:
;          - Max payload bytes : 1 MiB
;          - Max record count  : 50,000
;          - Max key bytes     : 256
;          - Max string bytes  : 16 KiB (per string value)
;        If a cap is hit, the file is rejected and the plugin will attempt recovery
;        from the other store. Cap hits are logged as warnings in IronSoul.log.
;
;   3) High-performance key/value access
;      - Flat string keys
;      - Int and String values only
;      - Optimized "set-if-changed" calls for hot paths
;
;   4) Controlled flush semantics
;      - Plugin flushes data automatically on save, on exit, and periodically every 30s for crash protection
;      - Papyrus may request an immediate flush for critical events
;
; -------------------------------------------------------------------------------------
; STORAGE MODEL (IMPORTANT)
;
; - All persistent state lives in the SKSE plugin's DataStore.
; - Data is written to:
;
;     MainData:
;       Data\SKSE\Plugins\IronSoul\CharacterData.dat
;
;     MirrorData:
;       Data\SKSE\Plugins\StorageUtilData\PapyrusUtil\Runtime\MD_5729.dat
;
; - Bidirectional self-heal:
;   If either MainData or MirrorData loads successfully while the other is
;   missing or invalid, the plugin treats the valid store as authoritative and
;   rebuilds the other from that snapshot (logging a warning).
;
; - Papyrus "co-save" storage (StorageUtil) is used ONLY for the authoritative GUID slot (IS_9975).
;   All other persisted state is stored in the plugin's MainData (GUID-scoped keys).
;
; -------------------------------------------------------------------------------------
; KEY SEMANTICS
;
; - Keys are flat strings (often suffixed with a per-character GUID).
; - The plugin does not interpret keys or enforce schema.
; - Authority policies and min/max logic remain in Papyrus.
;
; GUID-related keys (controller-owned schema):
;
;   Co-save (authoritative):
;     - IS_9975                  (string)  -- stored ONLY in the co-save via StorageUtil (authoritative GUID)
;
;   MainData (GUID-scoped; stored as <KEY>:<GUID> using MakeKey(KEY, guid)):
;     - I.N:<GUID>               (string)  -- Identity.Name
;     - I.R:<GUID>               (int)     -- Identity.RaceFormID
;     - I.L:<GUID>               (int)     -- Identity.Level (last seen level)
;     - I.D:<GUID>               (int)     -- Identity.GameDay (last seen in-game day)
;
;   MainData (global; NOT GUID-scoped):
;     - G.U.<GUID> = 1           (int)     -- collision index (GUID is already claimed)
;     - G.U.INDEX                (string)  -- GUID list for recovery enumeration (e.g. "A1234|B5678|...")
;
; Policy:
;   - ALL persistent keys in MainData SHOULD be GUID-scoped except those under the "G.U." namespace.
;
; -------------------------------------------------------------------------------------
; DO NOT:
; - Perform file I/O in Papyrus
; - Attempt to mirror or duplicate disk state
; - Assume ordering or iteration over keys
;
; =====================================================================================


; =====================================================================================
; JOURNAL LOGGING
; =====================================================================================
;
; Appends a single journal line to the Iron Soul character journal log.
; The SKSE plugin prepends the player name automatically.
;
; Log file:
;   Data\SKSE\Plugins\IronSoulCharacterJournal.log
;
; Example:
;   IronSoulNative.LogJournalEntry("Day 5: Defeated. Deaths: 5 / 10.")
;
Function LogJournalEntry(String msg) Global Native


; =====================================================================================
; CONFIG ACCESS
; =====================================================================================
;
; Reads integer configuration values from:
;   Data\SKSE\Plugins\IronSoul.ini
;
; Configuration is read-only from Papyrus.
;
Int Function GetConfigInt(String key, Int fallback = 0) Global Native


; =====================================================================================
; IDENTITY / GUID UTILITIES
; =====================================================================================
;
; Returns the current player name.
;
; Notes:
; - Returns "" (empty) if the name is not yet available (very early new game / pre-RaceMenu).
; - The controller should treat empty as "not ready" and retry later.
;
String Function GetPlayerName() Global Native


; Generates a unique character GUID with collision protection.
;
; GUID format (v2):
;   <LETTER><####>
;   - LETTER: first letter of the character name (uppercase). If unavailable, falls back to 'P'.
;   - ####  : random 4-digit number from 1000 to 9999.
;
; Collision handling (no datastore enumeration):
;   The plugin claims GUIDs in a dedicated collision index inside MainData:
;     "G.U.<GUID>" = 1
;   GenerateGuidUnique() checks for that key and atomically claims it
;   (check+set under the datastore mutex) before returning.
;
; Retry / fallback behavior:
; - Tries up to 64 random 4-digit candidates.
; - Extremely unlikely fallback: widens to 6 digits (100000-999999) and tries up to 64 candidates.
; - Returns "" on unexpected failure to claim a GUID.
;
; Intended usage:
; - Called ONLY when the authoritative co-save GUID (IS_9975) is missing and identity is ready.
; - Controller writes the returned GUID once to the authoritative co-save slot (IS_9975).
; - GUID is NOT mirrored into MainData; MainData uses GUID-scoped keys for all other state.
;
; NOTE:
; If the controller obtains a GUID from any source OTHER than this function
; (e.g., restore/migration/recovery), it MUST ensure the marker exists:
;   DataSetInt("G.U." + guid, 1)
;
; Controller maintains a GUID index string for recovery enumeration:
;   DataSetStringIfChanged("G.U.INDEX", "<pipe-delimited GUID list>")
String Function GenerateGuidUnique(String playerName) Global Native


; =====================================================================================
; DATASTORE – READ ACCESS
; =====================================================================================
;
; Reads an integer value from MainData.
; If the key does not exist or is not an integer, returns the fallback.
;
Int Function DataGetInt(String key, Int fallback = 0) Global Native


; Reads a string value from MainData.
; If the key does not exist or is not a string, returns the fallback.
;
String Function DataGetString(String key, String fallback = "") Global Native


; Returns true if the key exists in MainData.
;
Bool Function DataHasKey(String key) Global Native


; =====================================================================================
; DATASTORE – WRITE ACCESS
; =====================================================================================
;
; Writes an integer value to MainData.
; This always marks the datastore dirty.
;
Function DataSetInt(String key, Int value) Global Native


; Writes a string value to MainData.
; This always marks the datastore dirty.
;
Function DataSetString(String key, String value) Global Native


; Writes an integer value ONLY if it differs from the existing value.
;
; Returns:
;   true  - value changed and datastore marked dirty
;   false - value was identical and no write occurred
;
; This SHOULD be used for hot paths.
;
Bool Function DataSetIntIfChanged(String key, Int value) Global Native


; Writes a string value ONLY if it differs from the existing value.
;
; Returns:
;   true  - value changed and datastore marked dirty
;   false - value was identical and no write occurred
;
; This SHOULD be used for hot paths.
;
Bool Function DataSetStringIfChanged(String key, String value) Global Native


; Deletes a key from MainData if it exists.
Function DataDeleteKey(String key) Global Native


; =====================================================================================
; DATASTORE – FLUSH CONTROL
; =====================================================================================
;
; Forces an immediate flush of MainData and MirrorData to disk.
;
; Normally unnecessary, as the plugin:
;   - flushes periodically
;   - flushes on save
;
; Intended for critical events (e.g. true death finalization).
;
Function DataFlushNow() Global Native
