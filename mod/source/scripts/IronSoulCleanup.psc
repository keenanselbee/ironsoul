Scriptname IronSoulCleanup extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Destructive Confirmation ---
; --------------------------------
; ClearDestructiveCommandConfirmation()
; ArmDestructiveCommandConfirmation()
; TryConsumeDestructiveCommandConfirmation()

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()

; --- Cleanup Orchestration ---
; -----------------------------
; RemoveGuidTrackedData()
; ResetCurrentCharacterData()
; PurgeHistoricalCharacterData()

; --- Safe Uninstall ---
; ----------------------
; HandleUninstallMode()
; ReenableAfterUninstall()


; --- Wired Dependencies & Runtime State ---
; ==========================================

IronSoulController Property Controller Auto

String _pendingDestructiveActionId = ""
String _pendingDestructiveGuid = ""
Float _pendingDestructiveConfirmExpiresAt = 0.0
Bool _uninstallNotified = False


; --- Destructive Confirmation ---
; ================================

Function ClearDestructiveCommandConfirmation()
    _pendingDestructiveActionId = ""
    _pendingDestructiveGuid = ""
    _pendingDestructiveConfirmExpiresAt = 0.0
EndFunction

Function ArmDestructiveCommandConfirmation(String actionId, String guid, Float windowSeconds = 10.0)
    if actionId == "" || guid == ""
        ClearDestructiveCommandConfirmation()
        return
    endif

    if windowSeconds <= 0.0
        windowSeconds = 10.0
    endif

    _pendingDestructiveActionId = actionId
    _pendingDestructiveGuid = guid
    _pendingDestructiveConfirmExpiresAt = Utility.GetCurrentRealTime() + windowSeconds
EndFunction

Bool Function TryConsumeDestructiveCommandConfirmation(String actionId, String guid)
    if actionId == "" || guid == ""
        return False
    endif

    if _pendingDestructiveActionId == "" || _pendingDestructiveGuid == ""
        return False
    endif

    if Utility.GetCurrentRealTime() > _pendingDestructiveConfirmExpiresAt
        ClearDestructiveCommandConfirmation()
        return False
    endif

    if _pendingDestructiveActionId != actionId || _pendingDestructiveGuid != guid
        return False
    endif

    ClearDestructiveCommandConfirmation()
    return True
EndFunction


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Identity || !Controller.Persistence
        return False
    endif
    if !Controller.Death || !Controller.Tiers || !Controller.Respawn
        return False
    endif
    return True
EndFunction


; --- Cleanup Orchestration ---
; =============================

Function RemoveGuidTrackedData(Actor player, String guid, Bool deleteMainData = True, Bool unsetCosave = False)
    if !Controller || guid == ""
        return
    endif

    if Controller.Persistence
        Controller.Persistence.RemoveTrackedData(player, guid, deleteMainData, unsetCosave)
    endif
    if Controller.Death
        Controller.Death.RemoveTrackedData(player, guid, deleteMainData, unsetCosave)
    endif
    if Controller.Luck
        Controller.Luck.RemoveTrackedData(player, guid, deleteMainData, unsetCosave)
    endif
    if Controller.Tiers
        Controller.Tiers.RemoveTrackedData(player, guid, deleteMainData, unsetCosave)
    endif
    if Controller.Sunderhearts
        Controller.Sunderhearts.RemoveTrackedData(player, guid, deleteMainData, unsetCosave)
    endif
    if Controller.DragonSoulRevive
        Controller.DragonSoulRevive.RemoveTrackedData(player, guid, deleteMainData, unsetCosave)
    endif
    if Controller.Journal
        Controller.Journal.RemoveTrackedData(player, guid, deleteMainData, unsetCosave)
    endif
EndFunction

Bool Function ResetCurrentCharacterData(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == ""
        return False
    endif

    ; Stop runtime.
    Controller.StopRuntimeUpdates()
    Controller.ResetTransientState()
    if Controller.Effects
        Controller.Effects.ClearSoulPresentationSpells(player)
    endif

    ; Clear character state.
    RemoveGuidTrackedData(player, guid, True, True)
    Controller.Identity.DeleteIdentitySnapshotKeys(guid)

    ; Rebuild fresh Iron baseline.
    Controller.Identity.EnsureGuidMarker(guid)
    Controller.Tiers.SetCurrentTier(player, guid, Controller.Tiers.TIER_IRON, False)
    Controller.Tiers.ClearDefiantState(player, guid)
    Controller.Death.ResetCurrentCharacterCounts(player, guid)
    Controller.Tiers.RebaselineDragonSoulsLastSeen(player, guid)

    ; Resume runtime if enabled.
    if !Controller.Config.IsUninstallMode() && !Controller.IsModDisabled()
        if Controller.Death
            Controller.Death.RestoreOnDyingHook(player)
        endif
        if Controller.Effects
            Controller.Effects.SyncSoulPresentationAndStats(player, guid)
        endif
        Controller.Respawn.RefreshRuntime()
        Controller.Respawn.UpdatePlayerProtectionState(player)
        Controller.QueueUpdate(Controller.FastPollSeconds)
    endif
    if Controller.Globals
        Controller.Globals.SyncAll(player, guid)
    endif

    IronSoulNative.DataFlushIfDirty()
    return True
EndFunction

Int Function PurgeHistoricalCharacterData(String currentGuid)
    if !Controller || currentGuid == ""
        return 0
    endif

    String idx = Controller.Identity.GetGuidIndex()
    if idx == ""
        Controller.Identity.KeepOnlyGuidInIndex(currentGuid)
        IronSoulNative.DataFlushIfDirty()
        return 0
    endif

    Int purgedCount = 0
    String seen = "|" + currentGuid + "|"
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

        if cand != ""
            String needle = "|" + cand + "|"
            if StringUtil.Find(seen, needle) == -1
                seen = seen + cand + "|"
                RemoveGuidTrackedData(None, cand, True, False)
                Controller.Identity.DeleteIdentitySnapshotKeys(cand)
                Controller.Identity.DeleteGuidMarker(cand)
                purgedCount += 1
            endif
        endif
    endwhile

    Controller.Identity.KeepOnlyGuidInIndex(currentGuid)
    IronSoulNative.DataFlushIfDirty()
    return purgedCount
EndFunction


; --- Safe Uninstall ---
; ======================

Function HandleUninstallMode(Actor player)
    if !Controller || !player
        return
    endif

    IronSoulNative.StopHealthMonitor()

    ; Clear transient runtime jobs/caches so nothing continues in background.
    Controller.ResetTransientState()

    ; Ensure no per-tick loop remains active while disabled.
    Controller.StopRuntimeUpdates()

    if Controller.Persistence
        Controller.Persistence.SetDraugnarokOverrideMode(player, 2, True)
    endif
    _DS_DN_Draugnarok draugnarok = Controller.ResolveDraugnarokQuest()
    if draugnarok
        draugnarok.ApplyDraugnarokOverrideMode(2)
    endif

    ; Strip Soul Bonus / Soul Fatigue spells and OnDying hook immediately.
    if Controller.Effects
        Controller.Effects.ClearSoulPresentationSpells(player)
    endif
    if Controller.Death
        Controller.Death.RemoveOnDyingHook(player)
    endif

    ; Normalize player state in-place.
    player.EndDeferredKill()
    player.GetActorBase().SetEssential(False)
    player.SetGhost(False)
    player.SetAV("Paralysis", 0.0)
    player.RestoreAV("Health", 1000.0)

    Controller.SetModDisabled(True)
    if Controller.Globals
        Controller.Globals.SyncIntegrationStatus(player)
    endif

    if !_uninstallNotified
        _uninstallNotified = True
        Debug.MessageBox("Iron Soul has been safely disabled.\nYou may now uninstall the mod, or leave it installed in its disabled state.")
    endif
EndFunction

Function ReenableAfterUninstall(Actor player)
    if !HasCoreRuntime() || !player
        return
    endif

    Controller.SetModDisabled(False)
    _uninstallNotified = False

    ; Reset transient jobs/caches so nothing resumes half-armed.
    Controller.ResetTransientState()
    Controller.Respawn.RefreshRuntime()

    if Controller.Persistence
        Controller.Persistence.SetDraugnarokOverrideMode(player, 0, True)
    endif
    _DS_DN_Draugnarok draugnarok = Controller.ResolveDraugnarokQuest()
    if draugnarok
        draugnarok.ApplyDraugnarokOverrideMode(0)
    endif

    ; Restore OnDying Spell.
    if Controller.Death
        Controller.Death.RestoreOnDyingHook(player)
    endif

    String guid = Controller.Identity.GetStoredGuid(player)
    if guid != ""
        if Controller.Effects
            Controller.Effects.SyncSoulPresentationAndStats(player, guid)
        endif
    endif

    ; Kick the controller back into normal cadence.
    Controller.QueueUpdate(Controller.FastPollSeconds)
    if Controller.Globals
        Controller.Globals.SyncIntegrationStatus(player)
        if guid != ""
            Controller.Globals.SyncAll(player, guid)
        else
            Controller.Globals.SyncModState()
        endif
    endif
EndFunction
