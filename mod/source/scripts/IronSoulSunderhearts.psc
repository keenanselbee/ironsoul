Scriptname IronSoulSunderhearts extends Quest

; Sunderhearts
; by Camilonwe of Alinor
; A Discourse On A Curious Exception To The Finality Of Death
;
; Transmortal restoration of quickened entities after corporeal cessation is
; not possible through ordinary soul media. A soul gem may seize the animus,
; but only as a prison or fuel; it does not preserve the relation between the
; soul and its lawful body. Without such relation, any attempted restoration
; results in mere necromancy, daedric imitation, or spiritual dispersal.
;
; Yet there exist reports, rare and ill-attested, of deaths that did not
; complete themselves. In these accounts the soul is neither captured nor
; released, but suspended for some brief interval in which it remains answerable
; to its name, its flesh, and the place of its dying. Such cases are generally
; dismissed as priestly fraud, ancestor-echo, or the delirium of mourners. This
; is often wise. It is not always sufficient.
;
; The most troublesome notice occurs in the Account of Llervu Thendas, a Dunmer
; antiquarian attached to an early Temple survey of the abandoned tonal chamber
; of Bthanchend. Thendas describes a red sphere suspended in a Dwemer receiving
; frame, warm though the chamber was cold, and sounding faintly when touched.
; The instrument around it had been ruined, as though by a single pressure from
; within rather than by age, looters, or war.
;
; During the survey, a brass armature collapsed and slew one of Thendas's
; companions. The account insists upon the freshness of the death: the blood had
; not darkened, the eyes had not clouded, and the body still gave up heat. When
; the red sphere was dislodged from its frame and fell against the corpse, it
; flared once, bright enough to stain the chamber walls. Its color then vanished
; into the dead flesh as if drawn through a wound. The orb fell dull and cold
; to the floor. The dead mer convulsed, drew breath, and rose.
;
; This was no lingering twitch. Thendas reports that the revived surveyor stood,
; recognized his companions, and answered to his name. He remained alive for
; nearly an hour, though greatly weakened and troubled by the sound of "a red
; bell beneath the world." Thereafter he suffered a second collapse and could
; not be recalled. Thendas says the spent orb resembled ebony made glass-pure,
; with none of ebony's black weight or volcanic memory. It gave no sound.
;
; Temple commentators dismiss the account as grief, vapor, or Dwemer poisoning.
; I am less certain. A fraud would have given us a clean miracle. Thendas gives
; us an accident, a ruined instrument, a temporary restoration, and a corpse
; that had only just begun to leave itself.
;
; If the account is not wholly false, then the sphere did not act as a soul gem.
; It did not claim the animus as property, nor draw it away for expenditure.
; Rather, it appears to have interrupted departure at the narrowest point: after
; bodily death, but before the soul's relation to the body had fully failed. The
; result was not necromancy, for the body was not animated by an exterior will.
; It was the same mer, returned briefly to the same flesh.
;
; This suggests that the object was not a vessel in the usual sense, but a point
; of sympathy between mortal dissolution and some older injury in the world. The
; Dwemer frame may not have created the orb. It may only have received it, or
; taught common matter to answer a pressure already present.
;
; Here Thendas's strangest detail becomes difficult to ignore. Ebony is no
; innocent comparison in a Dunmer account. It is the black glass of Red Mountain,
; named in old Temple habit beside the Heart, the Dwemer, and the first wound of
; the world. If the spent orb resembled ebony with its mineral weight refined
; away, then perhaps the likeness was not poetic at all.
;
; I therefore use the term sunderheart with some reluctance. It is not meant to
; certify that the orb is a literal fragment of any relic a miner could have held.
; It is meant to name a suspicion: that some force once bound to the Heart
; beneath Red Mountain was scattered, refracted, or made local by the disaster
; there. If this is so, these orbs are not fragments in the vulgar sense. They
; are splinters of consequence, small mineral survivals of a pressure that
; should have ended where it began.
;
; The analogy to the sigil stone is tempting but imperfect. Such a sigil
; impresses an exterior will upon a prepared morpholith, making a gate where no
; gate should be. A sunderheart, if such things exist, would be its mortal
; contrary: not a door opened outward, but a door prevented from closing.
;
; What pressure could produce such a thing? Here one must speak carefully. The
; disturbance at Red Mountain, the vanished Dwemer, and the old stories of the
; Missing God all occupy the same forbidden neighborhood of thought. To place
; the orb there is not to prove its parentage. It is only to admit that no
; lesser explanation fits comfortably.
;
; If the Heart was once struck like a bell, perhaps certain prepared places did
; not merely hear the note. Perhaps they kept it. Bthanchend may have been one
; such place.
;
; If so, the sunderheart is not a fragment in the vulgar sense. It is an event
; made mineral. A red witness to the proposition that death, like Mundus itself,
; was never perfectly finished.

IronSoulController Property Controller Auto
MiscObject Property SunderheartSpent Auto
String Property sunderheartsTotal = "SH.T" AutoReadOnly ; Shared successful Sunderheart use counter.
String Property sunderheartsCharacterTotal = "SH.C" AutoReadOnly ; Current-character successful Sunderheart use counter.
String Property sunderheartsUnlockedTotal = "SH.U" AutoReadOnly ; Shared distinct Sunderheart unlock counter.
String Property sunderheartUsedPrefix = "SH.U." AutoReadOnly ; Shared boolean used catalog prefix.

; Expected MESG EditorIDs:
; - IronSoul_SunderheartMsg: Absorb Anima, Enhance Item, Purge Death.
; - IronSoul_SunderheartAnimaEnhanceMsg: Absorb Anima, Enhance Item.
; - IronSoul_SunderheartAnimaPurgeMsg: Absorb Anima, Purge Death.
; - IronSoul_SunderheartEnhancePurgeMsg: Enhance Item, Purge Death.
; - IronSoul_SunderheartAnimaOnlyMsg: Absorb Anima.
; - IronSoul_SunderheartEnhanceOnlyMsg: Enhance Item.
; - IronSoul_SunderheartPurgeOnlyMsg: Purge Death.
; - IronSoul_SunderheartUnavailableMsg: No available action acknowledgment.
Message Property SunderheartMsg Auto
Message Property SunderheartAnimaEnhanceMsg Auto
Message Property SunderheartAnimaPurgeMsg Auto
Message Property SunderheartEnhancePurgeMsg Auto
Message Property SunderheartAnimaOnlyMsg Auto
Message Property SunderheartEnhanceOnlyMsg Auto
Message Property SunderheartPurgeOnlyMsg Auto
Message Property SunderheartUnavailableMsg Auto
Sound Property SFXSunderheartAbsorb Auto
Sound Property SFXSunderheartFocusLoop Auto

Int SUNDERHEART_TYPE_TONAL = 1
Int SUNDERHEART_EFFECT_TONAL = 1
Int SUNDERHEART_INVENTORY_MODE_LEGACY = 0
Int SUNDERHEART_INVENTORY_MODE_REOPEN = 1
Int SUNDERHEART_INVENTORY_MODE_CLOSE = 2
Int SUNDERHEART_INVENTORY_MODE_MIXED = 3
String SUNDERHEART_ITEM_ENHANCED_MENU = "sunderheart_item_enhanced"
String SUNDERHEART_DEATH_PURGED_MENU = "sunderheart_death_purged"
String SUNDERHEART_ANIMA_ABSORBED_MENU = "sunderheart_anima_absorbed"
String SUNDERHEART_INVENTORY_MENU = "InventoryMenu"
String SUNDERHEART_MESSAGEBOX_MENU = "MessageBoxMenu"
String SUNDERHEART_ITEM_SELECT_SWF = "ironsoul_itemselect"
String SUNDERHEART_ITEM_SELECT_ROOT = "_root.ironsoul_itemselect.ItemSelect_mc"
String SUNDERHEART_ITEM_SELECT_LOAD_EVENT = "IronSoul_ItemSelect_Load"
String SUNDERHEART_ITEM_SELECT_SELECT_EVENT = "IronSoul_ItemSelect_Select"
String SUNDERHEART_FOCUS_EDITOR_ID_PREFIX = "IronSoul_Sunderheart"
String SUNDERHEART_FOCUS_EXCLUDED_EDITOR_ID = "IronSoul_SunderheartSpent"
Float SUNDERHEART_PRESENTATION_MAX_SECONDS = 5.5
Float SUNDERHEART_PRESENTATION_DISMISS_SECONDS = 2.0
Float SUNDERHEART_FOCUS_POLL_SECONDS = 0.25
Float SUNDERHEART_FOCUS_FALLBACK_REPLAY_SECONDS = 2.0
Int TONAL_TEMPER_MAX_LEVEL = 10
Int TONAL_TEMPER_CONFIG_MAX_LEVEL = 100
Int TONAL_RESULT_ALREADY_CAPPED = 4
Int TONAL_RESULT_AMBIGUOUS_STACK = 10
Int SUNDERHEART_ACTION_NONE = 0
Int SUNDERHEART_ACTION_ANIMA = 1
Int SUNDERHEART_ACTION_ENHANCE = 2
Int SUNDERHEART_ACTION_PURGE = 3
Int SUNDERHEART_CANCEL_KEY_ESC = 1
Int SUNDERHEART_CANCEL_KEY_TAB = 15
Int SUNDERHEART_CANCEL_KEY_START = 270
Int SUNDERHEART_CANCEL_KEY_BACK = 271
Int SUNDERHEART_CANCEL_KEY_GAMEPAD_B = 277

Bool _handlingUse = False
Bool _tonalSelectionActive = False
Bool _tonalItemSelectActive = False
Bool _tonalItemSelectLoaded = False
Bool _tonalItemSelectFailed = False
Bool _tonalItemSelectNoRows = False
Actor _pendingTonalPlayer = None
Form _pendingTonalSunderheartBaseItem = None
Int _pendingTonalSunderheartType = 0
Int _pendingTonalSunderheartTier = 0
Int _pendingTonalSessionToken = 0
Int _pendingTonalSelectedIndex = -1
Int _pendingTonalMaxTemper = 10
Int _sunderheartMenuBlockToken = 0
Bool _sunderheartFocusPolling = False
Int _sunderheartFocusSFXInstance = -1
Float _sunderheartFocusSFXStartedAt = 0.0
Bool _sunderheartChoiceCancelActive = False
Bool _sunderheartChoiceCanceledByInput = False

Function ResetTransientState()
    EndSunderheartMenuBlock("reset")
    UnregisterForMenu(SUNDERHEART_INVENTORY_MENU)
    EndSunderheartChoiceCancel()
    _sunderheartFocusPolling = False
    StopSunderheartFocusSFX()

    _handlingUse = False
    ClearTonalEnhancementState()
    _sunderheartMenuBlockToken = 0
EndFunction

Function RemoveTrackedData(Actor player, String guid, Bool deleteMainData = True, Bool unsetCosave = False)
    if !Controller || !Controller.Persistence || guid == ""
        return
    endif

    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, sunderheartsCharacterTotal, deleteMainData, unsetCosave)
EndFunction

Function RegisterInventoryFocusSFX()
    UnregisterForMenu(SUNDERHEART_INVENTORY_MENU)
    if !HasCoreRuntime()
        return
    endif

    RegisterForMenu(SUNDERHEART_INVENTORY_MENU)
EndFunction

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Identity || !Controller.Persistence || !Controller.Death
        return False
    endif
    if !Controller.Tiers || !Controller.Presentation
        return False
    endif
    return True
EndFunction

Bool Function CanWriteSharedProgression(Actor player)
    if player && Controller && Controller.Identity
        return !Controller.Identity.IsCurrentCharacterTest(player)
    endif
    return True
EndFunction

Int Function GetSunderheartsTotal(Actor player = None)
    if !Controller || !Controller.Persistence
        return 0
    endif
    if !CanWriteSharedProgression(player)
        return 0
    endif

    return Controller.Persistence.GetSharedInt(sunderheartsTotal, 0)
EndFunction

Bool Function SetSunderheartsTotal(Actor player, Int totalValue, Bool flushNow = False)
    if !Controller || !Controller.Persistence
        return False
    endif
    if !CanWriteSharedProgression(player)
        if Controller.Globals
            Controller.Globals.SyncSunderhearts(player)
        endif
        return True
    endif

    Int clampedTotal = totalValue
    if clampedTotal < 0
        clampedTotal = 0
    endif

    Controller.Persistence.SetSharedInt(sunderheartsTotal, clampedTotal, True)
    if Controller.Globals
        Controller.Globals.SyncSunderhearts(player)
    endif
    if flushNow
        IronSoulNative.DataFlushIfDirty()
    endif
    return True
EndFunction

Int Function IncrementSunderheartsTotal(Actor player, Int sunderheartType = 0, Int sunderheartTier = 0)
    if !CanWriteSharedProgression(player)
        return 0
    endif

    Int currentTotal = GetSunderheartsTotal(player)
    Int nextTotal = currentTotal + 1
    if !SetSunderheartsTotal(player, nextTotal, False)
        return currentTotal
    endif

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "IncrementSunderheartsTotal: Shared SunderheartsTotal=" + nextTotal + " type=" + sunderheartType + " tier=" + sunderheartTier)
    return nextTotal
EndFunction

Int Function GetSunderheartsCharacterTotal(Actor player, String guid)
    if !Controller || !Controller.Persistence || !player || guid == ""
        return 0
    endif

    return Controller.Persistence.GetGuidInt(player, guid, sunderheartsCharacterTotal, 0)
EndFunction

Bool Function SetSunderheartsCharacterTotal(Actor player, String guid, Int totalValue, Bool flushNow = False)
    if !Controller || !Controller.Persistence || !player || guid == ""
        return False
    endif

    Int clampedTotal = totalValue
    if clampedTotal < 0
        clampedTotal = 0
    endif

    Controller.Persistence.SetGuidInt(player, guid, sunderheartsCharacterTotal, clampedTotal, True)
    if Controller.Globals
        Controller.Globals.SyncSunderhearts(player, guid)
    endif
    if flushNow
        IronSoulNative.DataFlushIfDirty()
    endif
    return True
EndFunction

Int Function IncrementSunderheartsCharacterTotal(Actor player, String guid, Int sunderheartType = 0, Int sunderheartTier = 0)
    Int currentTotal = GetSunderheartsCharacterTotal(player, guid)
    Int nextTotal = currentTotal + 1
    if !SetSunderheartsCharacterTotal(player, guid, nextTotal, False)
        return currentTotal
    endif

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "IncrementSunderheartsCharacterTotal: Character SunderheartsTotal=" + nextTotal + " type=" + sunderheartType + " tier=" + sunderheartTier)
    return nextTotal
EndFunction

Int Function GetSunderheartsUnlocked(Actor player = None)
    if !Controller || !Controller.Persistence
        return 0
    endif
    if !CanWriteSharedProgression(player)
        return 0
    endif

    return Controller.Persistence.GetSharedInt(sunderheartsUnlockedTotal, 0)
EndFunction

Bool Function SetSunderheartsUnlocked(Actor player, Int unlockedValue, Bool flushNow = False)
    if !Controller || !Controller.Persistence
        return False
    endif
    if !CanWriteSharedProgression(player)
        return True
    endif

    Int clampedUnlocked = unlockedValue
    if clampedUnlocked < 0
        clampedUnlocked = 0
    endif

    Controller.Persistence.SetSharedInt(sunderheartsUnlockedTotal, clampedUnlocked, True)
    if flushNow
        IronSoulNative.DataFlushIfDirty()
    endif
    return True
EndFunction

Int Function IncrementSunderheartsUnlocked(Actor player, Int sunderheartType = 0, Int sunderheartTier = 0)
    if !CanWriteSharedProgression(player)
        return 0
    endif

    Int currentUnlocked = GetSunderheartsUnlocked(player)
    Int nextUnlocked = currentUnlocked + 1
    if !SetSunderheartsUnlocked(player, nextUnlocked, False)
        return currentUnlocked
    endif

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "IncrementSunderheartsUnlocked: Shared SunderheartsUnlocked=" + nextUnlocked + " type=" + sunderheartType + " tier=" + sunderheartTier)
    return nextUnlocked
EndFunction

String Function GetSunderheartUsedKey(Int sunderheartType, Int sunderheartTier)
    if sunderheartType <= 0 || sunderheartTier < 0
        return ""
    endif

    return sunderheartUsedPrefix + sunderheartType + "." + sunderheartTier
EndFunction

Bool Function HasUsedSunderheart(Int sunderheartType, Int sunderheartTier, Actor player = None)
    if !Controller || !Controller.Persistence
        return False
    endif
    if !CanWriteSharedProgression(player)
        return False
    endif

    String usedKey = GetSunderheartUsedKey(sunderheartType, sunderheartTier)
    if usedKey == ""
        return False
    endif

    return Controller.Persistence.GetSharedInt(usedKey, 0) == 1
EndFunction

Bool Function MarkSunderheartUsed(Int sunderheartType, Int sunderheartTier, Actor player = None)
    if !Controller || !Controller.Persistence
        return False
    endif
    if !CanWriteSharedProgression(player)
        return False
    endif

    String usedKey = GetSunderheartUsedKey(sunderheartType, sunderheartTier)
    if usedKey == ""
        return False
    endif

    if HasUsedSunderheart(sunderheartType, sunderheartTier, player)
        return False
    endif

    Controller.Persistence.SetSharedInt(usedKey, 1, True)
    return True
EndFunction

Bool Function RegisterSunderheartUsed(Actor player, Int sunderheartType = 0, Int sunderheartTier = 0)
    if !Controller || !Controller.Persistence
        return False
    endif

    Int nextTotal = IncrementSunderheartsTotal(player, sunderheartType, sunderheartTier)
    String guid = ""
    if Controller.Identity
        guid = Controller.Identity.GetTickGuid(player)
    endif
    Int nextCharacterTotal = GetSunderheartsCharacterTotal(player, guid)
    if guid != ""
        nextCharacterTotal = IncrementSunderheartsCharacterTotal(player, guid, sunderheartType, sunderheartTier)
    endif

    String usedKey = GetSunderheartUsedKey(sunderheartType, sunderheartTier)
    Bool newUnlock = False
    Int nextUnlocked = GetSunderheartsUnlocked(player)
    if usedKey != ""
        newUnlock = MarkSunderheartUsed(sunderheartType, sunderheartTier, player)
        if newUnlock
            nextUnlocked = IncrementSunderheartsUnlocked(player, sunderheartType, sunderheartTier)
        endif
    endif

    IronSoulNative.DataFlushIfDirty()
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "RegisterSunderheartUsed: SunderheartsAbsorbed=" + nextTotal + " CharacterSunderheartsAbsorbed=" + nextCharacterTotal + " SunderheartsUnlocked=" + nextUnlocked + " usedKey=" + usedKey + " newUnlock=" + newUnlock)
    return True
EndFunction

Int Function ResetSharedSunderheartData(Actor player = None)
    if !Controller || !Controller.Persistence
        return -1
    endif
    if !CanWriteSharedProgression(player)
        if Controller.Globals
            Controller.Globals.SyncSunderhearts(player)
        endif
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "ResetSharedSunderheartData: skipped shared reset for test character")
        return 0
    endif

    SetSunderheartsTotal(player, 0, False)
    SetSunderheartsUnlocked(player, 0, False)
    Int deletedCatalogKeys = Controller.Persistence.DeleteSharedKeysWithPrefix(sunderheartUsedPrefix)
    if Controller.Globals
        Controller.Globals.SyncSunderhearts(player)
    endif
    IronSoulNative.DataFlushIfDirty()
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "ResetSharedSunderheartData: reset SunderheartsAbsorbed=0 SunderheartsUnlocked=0 deletedCatalogKeys=" + deletedCatalogKeys)
    return deletedCatalogKeys
EndFunction

Function LogSunderhearts(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("Sunderhearts", level, msg, suppressNotify)
        return
    endif

    Debug.Trace("[IronSoul] [" + IronSoulConfig.LogLevelTag(level) + "] [Sunderhearts] " + msg)
EndFunction

Function BeginSunderheartMenuBlock()
    if _sunderheartMenuBlockToken > 0
        return
    endif

    _sunderheartMenuBlockToken = IronSoulNative.BeginMenuBlock("sunderheart-action", False)
    if _sunderheartMenuBlockToken > 0
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "BeginSunderheartMenuBlock: token=" + _sunderheartMenuBlockToken)
    endif
EndFunction

Function EndSunderheartMenuBlock(String reason = "")
    Int token = _sunderheartMenuBlockToken
    _sunderheartMenuBlockToken = 0
    if token <= 0
        return
    endif

    IronSoulNative.EndMenuBlock(token)
    if reason != ""
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "EndSunderheartMenuBlock: reason=" + reason + " token=" + token)
    endif
EndFunction

Int Function GetSunderheartInventoryMode()
    if Controller && Controller.Config
        Int mode = Controller.Config.GetSunderheartInventoryMode()
        if mode >= SUNDERHEART_INVENTORY_MODE_LEGACY && mode <= SUNDERHEART_INVENTORY_MODE_MIXED
            return mode
        endif
    endif
    return SUNDERHEART_INVENTORY_MODE_REOPEN
EndFunction

Bool Function ShouldCloseInventoryForSunderheartAction()
    Int mode = GetSunderheartInventoryMode()
    if mode == SUNDERHEART_INVENTORY_MODE_REOPEN || mode == SUNDERHEART_INVENTORY_MODE_CLOSE || mode == SUNDERHEART_INVENTORY_MODE_MIXED
        return True
    endif
    return False
EndFunction

Bool Function ShouldReopenInventoryAfterSunderheartAction(Bool enhanceAction)
    Int mode = GetSunderheartInventoryMode()
    if mode == SUNDERHEART_INVENTORY_MODE_REOPEN
        return True
    elseif mode == SUNDERHEART_INVENTORY_MODE_MIXED
        return enhanceAction
    endif
    return False
EndFunction

Function CloseInventoryForSunderheartAction()
    if !ShouldCloseInventoryForSunderheartAction()
        return
    endif
    if !UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU)
        return
    endif

    UI.InvokeString("HUD Menu", "_global.skse.CloseMenu", SUNDERHEART_INVENTORY_MENU)
    Utility.WaitMenuMode(0.2)
EndFunction

Function ReopenInventoryAfterSunderheartAction(Bool enhanceAction)
    if !ShouldReopenInventoryAfterSunderheartAction(enhanceAction)
        return
    endif
    if UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU)
        return
    endif

    UI.InvokeString("HUD Menu", "_global.skse.OpenMenu", SUNDERHEART_INVENTORY_MENU)
    Utility.WaitMenuMode(0.1)
EndFunction

String Function GetSunderheartEnhanceResultText()
    String resultText = IronSoulNative.SunderheartGetEnhanceResultText()
    if resultText == ""
        return "Unknown Sunderheart enhancement failure"
    endif
    return resultText
EndFunction

Function NotifySunderheartEnhanceFailure(Bool applyFailure = False)
    Int result = IronSoulNative.SunderheartGetEnhanceResult()
    if result == TONAL_RESULT_ALREADY_CAPPED
        Debug.Notification("The Sunderheart cannot strengthen that item further.")
    elseif result == TONAL_RESULT_AMBIGUOUS_STACK
        Debug.Notification("The Sunderheart cannot choose between matching items.")
    elseif applyFailure
        Debug.Notification("The Sunderheart failed to strengthen that item.")
    else
        Debug.Notification("The Sunderheart cannot strengthen that item.")
    endif
EndFunction

Function NotifySunderheartSuccess(String msg)
    if msg == ""
        return
    endif
    if Controller && Controller.Config && !Controller.Config.IsSunderheartNotificationEnabled()
        return
    endif

    Debug.Notification(msg + ". Sunderhearts Absorbed: " + GetSunderheartsTotal(Game.GetPlayer()))
EndFunction

Bool Function TryUseSunderheart(Actor player, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0)
    Bool result = False

    if !HasCoreRuntime() || !player || !sunderheartBaseItem
        return False
    endif
    if player != Game.GetPlayer()
        return False
    endif
    if _handlingUse
        return False
    endif
    if player.GetItemCount(sunderheartBaseItem) <= 0
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "TryUseSunderheart: Player does not have the exact Sunderheart base form")
        Debug.MessageBox("The Sunderheart is no longer in your inventory.")
        return False
    endif

    _handlingUse = True

    String guid = Controller.Identity.GetTickGuid(player)
    if guid == ""
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "TryUseSunderheart: Could not resolve player GUID")
    else
        Int deaths = Controller.Death.GetCurrentDeathCount(player, guid)
        Int tier = Controller.Tiers.GetCurrentTier(player, guid)
        Int maxTemper = GetTonalMaxTemperLevel()
        Int enhanceSessionToken = PrepareTonalEnhanceSession(player, sunderheartBaseItem, sunderheartType, sunderheartTier, maxTemper)

        Bool canAnima = IronSoulTiers.IsNormalSoulTier(tier)
        Bool canPurge = deaths > 0
        Bool canEnhance = enhanceSessionToken > 0

        result = ShowSunderheartSmartChoice(player, guid, sunderheartBaseItem, sunderheartType, sunderheartTier, canAnima, canEnhance, canPurge, enhanceSessionToken, maxTemper)
    endif

    Utility.WaitMenuMode(0.2)
    _handlingUse = False
    return result
EndFunction

Int Function PrepareTonalEnhanceSession(Actor player, Form sunderheartBaseItem, Int sunderheartType, Int sunderheartTier, Int maxTemper)
    if sunderheartType != SUNDERHEART_TYPE_TONAL || !player || !sunderheartBaseItem
        return 0
    endif
    if player.GetItemCount(sunderheartBaseItem) <= 0
        return 0
    endif

    Int addLevels = ResolveTonalAddLevels(sunderheartTier)
    Int sessionToken = IronSoulNative.SunderheartBuildEnhanceSession(SUNDERHEART_EFFECT_TONAL, addLevels, maxTemper)
    if sessionToken <= 0
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "PrepareTonalEnhanceSession: No Tonal enhancement options type=" + sunderheartType + " tier=" + sunderheartTier + " maxTemper=" + maxTemper + " result=" + GetSunderheartEnhanceResultText())
        return 0
    endif

    Int optionCount = IronSoulNative.SunderheartGetEnhanceSessionOptionCount(sessionToken)
    if optionCount <= 0
        IronSoulNative.SunderheartReleaseEnhanceSession(sessionToken)
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "PrepareTonalEnhanceSession: Built empty Tonal enhancement session type=" + sunderheartType + " tier=" + sunderheartTier + " maxTemper=" + maxTemper)
        return 0
    endif

    return sessionToken
EndFunction

Function ReleasePreparedTonalEnhanceSession(Int sessionToken)
    if sessionToken > 0
        IronSoulNative.SunderheartReleaseEnhanceSession(sessionToken)
    endif
EndFunction

Bool Function ShowSunderheartSmartChoice(Actor player, String guid, Form sunderheartBaseItem, Int sunderheartType, Int sunderheartTier, Bool canAnima, Bool canEnhance, Bool canPurge, Int enhanceSessionToken, Int enhanceMaxTemper)
    if !canAnima && !canEnhance && !canPurge
        ReleasePreparedTonalEnhanceSession(enhanceSessionToken)
        return ShowSunderheartUnavailable(player, sunderheartType, sunderheartTier)
    endif

    Int selectedAction = ShowSunderheartActionChoice(canAnima, canEnhance, canPurge)
    if selectedAction == SUNDERHEART_ACTION_ANIMA
        ReleasePreparedTonalEnhanceSession(enhanceSessionToken)
        return TryAbsorbAnima(player, guid, sunderheartBaseItem, sunderheartType, sunderheartTier)
    elseif selectedAction == SUNDERHEART_ACTION_ENHANCE && canEnhance
        Int sessionToken = enhanceSessionToken
        enhanceSessionToken = 0
        return TryEnhanceItem(player, sunderheartBaseItem, sunderheartType, sunderheartTier, sessionToken, enhanceMaxTemper)
    elseif selectedAction == SUNDERHEART_ACTION_PURGE
        ReleasePreparedTonalEnhanceSession(enhanceSessionToken)
        return TryPurgeDeath(player, guid, sunderheartBaseItem, sunderheartType, sunderheartTier)
    endif

    ReleasePreparedTonalEnhanceSession(enhanceSessionToken)
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartSmartChoice: Sunderheart lowered")
    return False
EndFunction

Int Function ShowSunderheartActionChoice(Bool canAnima, Bool canEnhance, Bool canPurge)
    Message choiceMessage = None
    Int action0 = SUNDERHEART_ACTION_NONE
    Int action1 = SUNDERHEART_ACTION_NONE
    Int action2 = SUNDERHEART_ACTION_NONE
    Int maxChoice = -1

    if canAnima && canEnhance && canPurge
        choiceMessage = SunderheartMsg
        action0 = SUNDERHEART_ACTION_ANIMA
        action1 = SUNDERHEART_ACTION_ENHANCE
        action2 = SUNDERHEART_ACTION_PURGE
        maxChoice = 2
    elseif canAnima && canEnhance
        choiceMessage = SunderheartAnimaEnhanceMsg
        action0 = SUNDERHEART_ACTION_ANIMA
        action1 = SUNDERHEART_ACTION_ENHANCE
        maxChoice = 1
    elseif canAnima && canPurge
        choiceMessage = SunderheartAnimaPurgeMsg
        action0 = SUNDERHEART_ACTION_ANIMA
        action1 = SUNDERHEART_ACTION_PURGE
        maxChoice = 1
    elseif canEnhance && canPurge
        choiceMessage = SunderheartEnhancePurgeMsg
        action0 = SUNDERHEART_ACTION_ENHANCE
        action1 = SUNDERHEART_ACTION_PURGE
        maxChoice = 1
    elseif canAnima
        choiceMessage = SunderheartAnimaOnlyMsg
        action0 = SUNDERHEART_ACTION_ANIMA
        maxChoice = 0
    elseif canEnhance
        choiceMessage = SunderheartEnhanceOnlyMsg
        action0 = SUNDERHEART_ACTION_ENHANCE
        maxChoice = 0
    elseif canPurge
        choiceMessage = SunderheartPurgeOnlyMsg
        action0 = SUNDERHEART_ACTION_PURGE
        maxChoice = 0
    endif

    if !choiceMessage
        Debug.MessageBox("Sunderheart choices are not configured.")
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "ShowSunderheartActionChoice: Message property missing canAnima=" + canAnima + " canEnhance=" + canEnhance + " canPurge=" + canPurge)
        return SUNDERHEART_ACTION_NONE
    endif

    Int choice = ShowCancelableSunderheartMessage(choiceMessage, maxChoice)
    if choice == 0
        return action0
    elseif choice == 1
        return action1
    elseif choice == 2
        return action2
    endif

    return SUNDERHEART_ACTION_NONE
EndFunction

Int Function ShowCancelableSunderheartMessage(Message choiceMessage, Int maxChoice)
    if !choiceMessage
        return -1
    endif

    BeginSunderheartChoiceCancel()
    Int choice = choiceMessage.Show()
    Bool canceledByInput = _sunderheartChoiceCanceledByInput
    EndSunderheartChoiceCancel()

    if canceledByInput || choice < 0 || choice > maxChoice
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowCancelableSunderheartMessage: Sunderheart lowered choice=" + choice + " canceledByInput=" + canceledByInput)
        return -1
    endif

    return choice
EndFunction

Function BeginSunderheartChoiceCancel()
    _sunderheartChoiceCanceledByInput = False
    _sunderheartChoiceCancelActive = True
    RegisterForKey(SUNDERHEART_CANCEL_KEY_ESC)
    RegisterForKey(SUNDERHEART_CANCEL_KEY_TAB)
    RegisterForKey(SUNDERHEART_CANCEL_KEY_START)
    RegisterForKey(SUNDERHEART_CANCEL_KEY_BACK)
    RegisterForKey(SUNDERHEART_CANCEL_KEY_GAMEPAD_B)
EndFunction

Function EndSunderheartChoiceCancel()
    UnregisterForKey(SUNDERHEART_CANCEL_KEY_ESC)
    UnregisterForKey(SUNDERHEART_CANCEL_KEY_TAB)
    UnregisterForKey(SUNDERHEART_CANCEL_KEY_START)
    UnregisterForKey(SUNDERHEART_CANCEL_KEY_BACK)
    UnregisterForKey(SUNDERHEART_CANCEL_KEY_GAMEPAD_B)
    _sunderheartChoiceCancelActive = False
    _sunderheartChoiceCanceledByInput = False
EndFunction

Bool Function IsSunderheartChoiceCancelKey(Int keyCode)
    return keyCode == SUNDERHEART_CANCEL_KEY_ESC || keyCode == SUNDERHEART_CANCEL_KEY_TAB || keyCode == SUNDERHEART_CANCEL_KEY_START || keyCode == SUNDERHEART_CANCEL_KEY_BACK || keyCode == SUNDERHEART_CANCEL_KEY_GAMEPAD_B
EndFunction

Event OnKeyDown(Int keyCode)
    if !_sunderheartChoiceCancelActive || !IsSunderheartChoiceCancelKey(keyCode)
        return
    endif

    _sunderheartChoiceCanceledByInput = True
    IronSoulNative.CloseMenu(SUNDERHEART_MESSAGEBOX_MENU)
EndEvent

Bool Function ShowSunderheartUnavailable(Actor player, Int sunderheartType = 0, Int sunderheartTier = 0)
    if SunderheartUnavailableMsg
        SunderheartUnavailableMsg.Show()
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartUnavailable: No available action type=" + sunderheartType + " tier=" + sunderheartTier)
        return False
    endif

    Debug.MessageBox("The Sunderheart offers no usable path.")
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartUnavailable: No available action type=" + sunderheartType + " tier=" + sunderheartTier)
    return False
EndFunction

Bool Function TryEnhanceItem(Actor player, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0, Int preparedSessionToken = 0, Int preparedMaxTemper = 0)
    if sunderheartType == SUNDERHEART_TYPE_TONAL
        return TryEnhanceTonalItem(player, sunderheartBaseItem, sunderheartType, sunderheartTier, preparedSessionToken, preparedMaxTemper)
    endif

    ReleasePreparedTonalEnhanceSession(preparedSessionToken)
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceItem: Enhancement unavailable type=" + sunderheartType + " tier=" + sunderheartTier)
    return ShowEnhanceUnavailable(player, sunderheartType, sunderheartTier)
EndFunction

Bool Function TryEnhanceTonalItem(Actor player, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0, Int preparedSessionToken = 0, Int preparedMaxTemper = 0)
    if !HasCoreRuntime() || !player || !sunderheartBaseItem
        ReleasePreparedTonalEnhanceSession(preparedSessionToken)
        return False
    endif
    if player.GetItemCount(sunderheartBaseItem) <= 0
        ReleasePreparedTonalEnhanceSession(preparedSessionToken)
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "TryEnhanceTonalItem: Player does not have the exact Tonal Sunderheart base form")
        Debug.MessageBox("The Sunderheart is no longer in your inventory.")
        return False
    endif

    Int addLevels = ResolveTonalAddLevels(sunderheartTier)
    Int maxTemper = preparedMaxTemper
    if maxTemper <= 0
        maxTemper = GetTonalMaxTemperLevel()
    endif
    Int sessionToken = preparedSessionToken
    if sessionToken <= 0
        sessionToken = IronSoulNative.SunderheartBuildEnhanceSession(SUNDERHEART_EFFECT_TONAL, addLevels, maxTemper)
    endif
    if sessionToken <= 0
        String buildFailureText = GetSunderheartEnhanceResultText()
        Debug.Notification("The Sunderheart finds no eligible weapon or armor to strengthen.")
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceTonalItem: No Tonal enhancement options type=" + sunderheartType + " tier=" + sunderheartTier + " maxTemper=" + maxTemper + " result=" + buildFailureText)
        return False
    endif

    if !StartTonalEnhancementState(player, sunderheartBaseItem, sunderheartType, sunderheartTier, sessionToken, maxTemper)
        IronSoulNative.SunderheartReleaseEnhanceSession(sessionToken)
        return False
    endif

    Int selectedIndex = ShowSunderheartEnhanceList(sessionToken)
    if selectedIndex < 0
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceTonalItem: Tonal enhancement selection canceled type=" + sunderheartType + " tier=" + sunderheartTier)
        ClearTonalEnhancementState()
        return False
    endif

    _pendingTonalSelectedIndex = selectedIndex
    return CompleteTonalEnhancement()
EndFunction

Bool Function StartTonalEnhancementState(Actor player, Form sunderheartBaseItem, Int sunderheartType, Int sunderheartTier, Int sessionToken, Int maxTemper)
    ClearTonalEnhancementState()

    _tonalSelectionActive = True
    _pendingTonalPlayer = player
    _pendingTonalSunderheartBaseItem = sunderheartBaseItem
    _pendingTonalSunderheartType = sunderheartType
    _pendingTonalSunderheartTier = sunderheartTier
    _pendingTonalSessionToken = sessionToken
    _pendingTonalSelectedIndex = -1
    _pendingTonalMaxTemper = maxTemper

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "StartTonalEnhancementState: Started Tonal filtered item selection tier=" + sunderheartTier + " maxTemper=" + maxTemper + " session=" + sessionToken)
    return True
EndFunction

Int Function ShowSunderheartEnhanceList(Int sessionToken)
    Int optionCount = IronSoulNative.SunderheartGetEnhanceSessionOptionCount(sessionToken)
    if optionCount <= 0
        return -1
    endif

    _tonalItemSelectActive = True
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
    _pendingTonalSelectedIndex = -1
    RegisterForModEvent(SUNDERHEART_ITEM_SELECT_LOAD_EVENT, "OnIronSoul_ItemSelect_Load")
    RegisterForModEvent(SUNDERHEART_ITEM_SELECT_SELECT_EVENT, "OnIronSoul_ItemSelect_Select")

    Bool inventoryWasOpen = UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU)
    if !inventoryWasOpen && !IronSoulNative.OpenMenu(SUNDERHEART_INVENTORY_MENU)
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "ShowSunderheartEnhanceList: InventoryMenu could not be queued")
        ClearSunderheartItemSelectWait()
        Debug.MessageBox("The Sunderheart selection menu is not available.")
        return -1
    endif

    Float waited = 0.0
    while !UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU) && waited < 2.0
        Utility.WaitMenuMode(0.1)
        waited += 0.1
    endwhile

    if !UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU)
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "ShowSunderheartEnhanceList: InventoryMenu did not open")
        ClearSunderheartItemSelectWait()
        Debug.MessageBox("The Sunderheart selection menu is not available.")
        return -1
    endif

    InjectSunderheartItemSelect()

    waited = 0.0
    while UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU) && !_tonalItemSelectLoaded && !_tonalItemSelectFailed && waited < 2.0
        Utility.WaitMenuMode(0.1)
        waited += 0.1
    endwhile

    if !_tonalItemSelectLoaded || _tonalItemSelectFailed
        Bool noEligibleRows = _tonalItemSelectNoRows
        if noEligibleRows
            LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartEnhanceList: Iron Soul item select found no eligible rows session=" + sessionToken)
        else
            LogSunderhearts(IronSoulConfig.LOG_ERR(), "ShowSunderheartEnhanceList: Iron Soul item select failed to load session=" + sessionToken + " loaded=" + _tonalItemSelectLoaded + " failed=" + _tonalItemSelectFailed)
        endif
        if !inventoryWasOpen
            IronSoulNative.CloseMenu(SUNDERHEART_INVENTORY_MENU)
        endif
        ClearSunderheartItemSelectWait()
        if !noEligibleRows
            Debug.MessageBox("The Sunderheart selection menu is not available.")
        endif
        return -1
    endif

    while UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU) && _pendingTonalSelectedIndex < 0 && !_tonalItemSelectFailed
        Utility.WaitMenuMode(0.1)
    endwhile

    ClearSunderheartItemSelectWait()
    return _pendingTonalSelectedIndex
EndFunction

Function InjectSunderheartItemSelect()
    String[] args = new String[2]
    args[0] = SUNDERHEART_ITEM_SELECT_SWF
    args[1] = Utility.RandomInt(1000, 10000)
    UI.InvokeStringA(SUNDERHEART_INVENTORY_MENU, "_root.createEmptyMovieClip", args)
    UI.InvokeString(SUNDERHEART_INVENTORY_MENU, "_root." + SUNDERHEART_ITEM_SELECT_SWF + ".loadMovie", SUNDERHEART_ITEM_SELECT_SWF + ".swf")
EndFunction

Function ClearSunderheartItemSelectWait()
    UnregisterForModEvent(SUNDERHEART_ITEM_SELECT_LOAD_EVENT)
    UnregisterForModEvent(SUNDERHEART_ITEM_SELECT_SELECT_EVENT)
    _tonalItemSelectActive = False
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
EndFunction

Event OnIronSoul_ItemSelect_Load(String eventName, String strArg, Float numArg, Form formArg)
    if !_tonalItemSelectActive
        return
    endif

    String serializedRows = IronSoulNative.SunderheartRefreshEnhanceSessionInventoryRows(_pendingTonalSessionToken)
    if serializedRows == ""
        String resultText = GetSunderheartEnhanceResultText()
        _tonalItemSelectFailed = True
        _tonalItemSelectNoRows = True
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnIronSoul_ItemSelect_Load: No eligible InventoryMenu rows session=" + _pendingTonalSessionToken + " result=" + resultText)
        Debug.Notification("The Sunderheart finds no eligible weapon or armor to strengthen.")
        IronSoulNative.CloseMenu(SUNDERHEART_INVENTORY_MENU)
        return
    endif

    UI.InvokeString(SUNDERHEART_INVENTORY_MENU, SUNDERHEART_ITEM_SELECT_ROOT + ".setAllowedRows", serializedRows)
    _tonalItemSelectLoaded = True
EndEvent

Event OnIronSoul_ItemSelect_Select(String eventName, String strArg, Float numArg, Form formArg)
    if !_tonalItemSelectActive
        return
    endif

    _pendingTonalSelectedIndex = numArg as Int
    IronSoulNative.CloseMenu(SUNDERHEART_INVENTORY_MENU)
EndEvent

Bool Function CompleteTonalEnhancement()
    Actor player = _pendingTonalPlayer
    Form sunderheartBaseItem = _pendingTonalSunderheartBaseItem
    Int sunderheartType = _pendingTonalSunderheartType
    Int sunderheartTier = _pendingTonalSunderheartTier
    Int sessionToken = _pendingTonalSessionToken
    Int selectedIndex = _pendingTonalSelectedIndex
    Int maxTemper = _pendingTonalMaxTemper
    Int addLevels = ResolveTonalAddLevels(sunderheartTier)

    if !player || !sunderheartBaseItem || sessionToken <= 0 || selectedIndex < 0
        ClearTonalEnhancementState()
        return False
    endif

    if player.GetItemCount(sunderheartBaseItem) <= 0
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "CompleteTonalEnhancement: Player no longer has exact Tonal Sunderheart base form")
        Debug.MessageBox("The Sunderheart is no longer in your inventory.")
        ClearTonalEnhancementState()
        return False
    endif

    Bool enhanced = IronSoulNative.SunderheartApplyEnhanceSessionInventoryRow(sessionToken, selectedIndex)
    if !enhanced
        String resultText = GetSunderheartEnhanceResultText()
        NotifySunderheartEnhanceFailure(True)
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "CompleteTonalEnhancement: Native Tonal apply failed type=" + sunderheartType + " tier=" + sunderheartTier + " result=" + resultText)
        _pendingTonalSessionToken = 0
        ClearTonalEnhancementState()
        return False
    endif
    _pendingTonalSessionToken = 0
    String enhanceResultText = GetSunderheartEnhanceResultText()

    BeginSunderheartMenuBlock()
    CloseInventoryForSunderheartAction()
    PlaySunderheartPresentation(player, SUNDERHEART_ITEM_ENHANCED_MENU)
    player.RemoveItem(sunderheartBaseItem, 1, True)
    AwardHeartglass(player, sunderheartType, sunderheartTier)
    RegisterSunderheartUsed(player, sunderheartType, sunderheartTier)
    NotifySunderheartSuccess("Tonal Sunderheart strengthened " + enhanceResultText)

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "CompleteTonalEnhancement: Enhanced selected inventory item with Tonal Sunderheart type=" + sunderheartType + " tier=" + sunderheartTier + " addLevels=" + addLevels + " maxLevel=" + maxTemper + " result=" + enhanceResultText)
    ClearTonalEnhancementState()
    ReopenInventoryAfterSunderheartAction(True)
    return True
EndFunction

Int Function GetTonalMaxTemperLevel()
    if Controller && Controller.Config
        Int maxTemper = Controller.Config.GetSunderheartTonalMaxTemper()
        if maxTemper >= 1 && maxTemper <= TONAL_TEMPER_CONFIG_MAX_LEVEL
            return maxTemper
        endif
    endif
    return TONAL_TEMPER_MAX_LEVEL
EndFunction

Int Function ResolveTonalAddLevels(Int sunderheartTier)
    if sunderheartTier <= 1
        return 1
    elseif sunderheartTier == 2
        return 2
    elseif sunderheartTier == 3
        return 3
    elseif sunderheartTier == 4
        return 4
    endif
    return 5
EndFunction

Function ClearTonalEnhancementState()
    UnregisterForModEvent(SUNDERHEART_ITEM_SELECT_LOAD_EVENT)
    UnregisterForModEvent(SUNDERHEART_ITEM_SELECT_SELECT_EVENT)

    if _pendingTonalSessionToken > 0
        IronSoulNative.SunderheartReleaseEnhanceSession(_pendingTonalSessionToken)
    endif

    _tonalSelectionActive = False
    _tonalItemSelectActive = False
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
    _pendingTonalPlayer = None
    _pendingTonalSunderheartBaseItem = None
    _pendingTonalSunderheartType = 0
    _pendingTonalSunderheartTier = 0
    _pendingTonalSessionToken = 0
    _pendingTonalSelectedIndex = -1
    _pendingTonalMaxTemper = TONAL_TEMPER_MAX_LEVEL
EndFunction

Bool Function ShowEnhanceUnavailable(Actor player, Int sunderheartType = 0, Int sunderheartTier = 0)
    if SunderheartUnavailableMsg
        SunderheartUnavailableMsg.Show()
    else
        Debug.MessageBox("Sunderheart item enhancement is not implemented yet.")
    endif

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowEnhanceUnavailable: Enhancement unavailable shown type=" + sunderheartType + " tier=" + sunderheartTier)
    return False
EndFunction

Bool Function TryAbsorbAnima(Actor player, String guid, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0)
    if !HasCoreRuntime() || !player || guid == "" || !sunderheartBaseItem
        return False
    endif

    Int tier = Controller.Tiers.GetCurrentTier(player, guid)
    if !IronSoulTiers.IsNormalSoulTier(tier)
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryAbsorbAnima: Anima unavailable outside normal tiers type=" + sunderheartType + " tier=" + sunderheartTier + " liveTier=" + tier)
        return False
    endif

    Int itemCount = player.GetItemCount(sunderheartBaseItem)
    if itemCount <= 0
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "TryAbsorbAnima: Player does not have the exact Sunderheart base form")
        Debug.MessageBox("The Sunderheart is no longer in your inventory.")
        return False
    endif

    BeginSunderheartMenuBlock()
    player.RemoveItem(sunderheartBaseItem, 1, True)

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryAbsorbAnima: Absorbed Anima using exact Sunderheart type=" + sunderheartType + " tier=" + sunderheartTier + " liveTier=" + tier)

    CloseInventoryForSunderheartAction()
    PlaySunderheartPresentation(player, SUNDERHEART_ANIMA_ABSORBED_MENU)
    AwardHeartglass(player, sunderheartType, sunderheartTier)
    RegisterSunderheartUsed(player, sunderheartType, sunderheartTier)
    NotifySunderheartSuccess("The Sunderheart releases its Anima")
    ReopenInventoryAfterSunderheartAction(False)
    return True
EndFunction

Bool Function TryPurgeDeath(Actor player, String guid, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0)
    if !HasCoreRuntime() || !player || guid == "" || !sunderheartBaseItem
        return False
    endif

    Int deathsBeforePurge = Controller.Death.GetCurrentDeathCount(player, guid)
    if deathsBeforePurge <= 0
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: No current deaths to purge")
        return False
    endif

    Int itemCount = player.GetItemCount(sunderheartBaseItem)
    if itemCount <= 0
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "TryPurgeDeath: Player does not have the exact Sunderheart base form")
        Debug.MessageBox("The Sunderheart is no longer in your inventory.")
        return False
    endif

    BeginSunderheartMenuBlock()
    Int deathsAfterPurge = deathsBeforePurge - 1
    player.RemoveItem(sunderheartBaseItem, 1, True)
    Controller.Death.SetCurrentDeathCount(player, guid, deathsAfterPurge)

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: Purged one death using exact Sunderheart type=" + sunderheartType + " tier=" + sunderheartTier + " deaths=" + deathsBeforePurge + "->" + deathsAfterPurge)

    IronSoulNative.DataFlushIfDirty()

    CloseInventoryForSunderheartAction()
    PlaySunderheartPresentation(player, SUNDERHEART_DEATH_PURGED_MENU)
    AwardHeartglass(player, sunderheartType, sunderheartTier)
    RegisterSunderheartUsed(player, sunderheartType, sunderheartTier)
    Controller.Tiers.TryRestoreFromDefiant(player, guid)
    NotifySunderheartSuccess("The Sunderheart purges one death. Deaths: " + deathsBeforePurge + " -> " + deathsAfterPurge)
    ReopenInventoryAfterSunderheartAction(False)
    return True
EndFunction

Function AwardHeartglass(Actor player, Int sunderheartType = 0, Int sunderheartTier = 0)
    if !player
        return
    endif
    if !SunderheartSpent
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "AwardHeartglass: SunderheartSpent property is not wired")
        return
    endif

    player.AddItem(SunderheartSpent, 1, False)
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "AwardHeartglass: Awarded Heartglass for spent Sunderheart type=" + sunderheartType + " tier=" + sunderheartTier)
EndFunction

Function PlaySunderheartPresentation(Actor player, String menuName)
    if !player
        EndSunderheartMenuBlock("sunderheart-presentation-skipped")
        return
    endif
    if Controller && Controller.Config && !Controller.Config.IsSunderheartMessageEnabled()
        PlaySunderheartSFX(player)
        EndSunderheartMenuBlock("sunderheart-presentation-complete")
        return
    endif
    if menuName == ""
        EndSunderheartMenuBlock("sunderheart-presentation-skipped")
        return
    endif

    Int cursorToken = IronSoulNative.BeginCursorSuppress()
    Controller.Presentation.FadeMusicForTransitionSequence()
    UI.CloseCustomMenu()
    IronSoulNative.RefreshCursorSuppress()
    UI.OpenCustomMenu(menuName, 0)
    IronSoulNative.RefreshCursorSuppress()
    PlaySunderheartSFX(player)
    Controller.Presentation.WaitKeyDismissMenu(SUNDERHEART_PRESENTATION_MAX_SECONDS, SUNDERHEART_PRESENTATION_DISMISS_SECONDS)
    IronSoulNative.EndCursorSuppress(cursorToken)
    Controller.Presentation.RestoreMusic()
    EndSunderheartMenuBlock("sunderheart-presentation-complete")
EndFunction

Function PlaySunderheartSFX(Actor player)
    if !player || !SFXSunderheartAbsorb
        return
    endif
    if !Controller || !Controller.Config
        return
    endif
    if IronSoulSFX.CanPlaySFX(Controller.Config.IsSFXEnabled(), Controller.Config.IsUninstallMode(), Controller.IsModDisabled()) && Controller.Config.IsSunderheartAbsorbSFXEnabled()
        SFXSunderheartAbsorb.Play(player)
    endif
EndFunction

Event OnMenuOpen(String menuName)
    if menuName == SUNDERHEART_INVENTORY_MENU
        StartSunderheartFocusPolling()
    endif
EndEvent

Event OnMenuClose(String menuName)
    if menuName == SUNDERHEART_INVENTORY_MENU
        _sunderheartFocusPolling = False
        StopSunderheartFocusSFX()
    endif
EndEvent

Function StartSunderheartFocusPolling()
    if _sunderheartFocusPolling
        return
    endif

    _sunderheartFocusPolling = True
    while _sunderheartFocusPolling && UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU)
        UpdateSunderheartFocusSFX()
        Utility.WaitMenuMode(SUNDERHEART_FOCUS_POLL_SECONDS)
    endwhile
    _sunderheartFocusPolling = False
    StopSunderheartFocusSFX()
EndFunction

Function UpdateSunderheartFocusSFX()
    if !CanPlaySunderheartFocusSFX()
        StopSunderheartFocusSFX()
        return
    endif
    if IronSoulNative.InventorySelectedItemHasEditorIDPrefix(SUNDERHEART_FOCUS_EDITOR_ID_PREFIX) && !IronSoulNative.InventorySelectedItemHasEditorID(SUNDERHEART_FOCUS_EXCLUDED_EDITOR_ID)
        StartSunderheartFocusSFX()
    else
        StopSunderheartFocusSFX()
    endif
EndFunction

Bool Function CanPlaySunderheartFocusSFX()
    if !Controller || !Controller.Config
        return False
    endif
    if !IronSoulSFX.CanPlaySFX(Controller.Config.IsSFXEnabled(), Controller.Config.IsUninstallMode(), Controller.IsModDisabled())
        return False
    endif
    if !Controller.Config.IsSunderheartFocusSFXEnabled()
        return False
    endif
    if !ResolveSunderheartFocusSFX()
        return False
    endif
    return Game.GetPlayer() != None
EndFunction

Sound Function ResolveSunderheartFocusSFX()
    if SFXSunderheartFocusLoop
        return SFXSunderheartFocusLoop
    endif
    return SFXSunderheartAbsorb
EndFunction

Function StartSunderheartFocusSFX()
    Sound focusSFX = ResolveSunderheartFocusSFX()
    Actor player = Game.GetPlayer()
    if !focusSFX || !player
        return
    endif

    if SFXSunderheartFocusLoop
        if _sunderheartFocusSFXInstance < 0
            _sunderheartFocusSFXInstance = focusSFX.Play(player)
            _sunderheartFocusSFXStartedAt = Utility.GetCurrentRealTime()
        endif
        return
    endif

    Float nowRT = Utility.GetCurrentRealTime()
    if _sunderheartFocusSFXInstance >= 0 && nowRT - _sunderheartFocusSFXStartedAt < SUNDERHEART_FOCUS_FALLBACK_REPLAY_SECONDS
        return
    endif

    StopSunderheartFocusSFX()
    _sunderheartFocusSFXInstance = focusSFX.Play(player)
    _sunderheartFocusSFXStartedAt = nowRT
EndFunction

Function StopSunderheartFocusSFX()
    if _sunderheartFocusSFXInstance >= 0
        Sound.StopInstance(_sunderheartFocusSFXInstance)
    endif
    _sunderheartFocusSFXInstance = -1
    _sunderheartFocusSFXStartedAt = 0.0
EndFunction
