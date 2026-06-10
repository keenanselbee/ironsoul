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
FormList Property SunderheartTier1List Auto
FormList Property SunderheartTier2List Auto
FormList Property SunderheartTier3List Auto
FormList Property SunderheartTier4List Auto
FormList Property SunderheartTier5List Auto
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
String SUNDERHEART_CUSTOM_MENU = "CustomMenu"
String SUNDERHEART_CUSTOM_MENU_SWF = "ironsoul_messagebox"
String SUNDERHEART_CUSTOM_MENU_CONFIGURE = "_root.MessageMenu.IronSoulConfigure"
String SUNDERHEART_CUSTOM_MENU_CONFIGURE_WRAPPED = "_root.Menu_mc.MessageMenu.IronSoulConfigure"
String SUNDERHEART_CUSTOM_MENU_CONFIGURE_SERIALIZED = "_root.MessageMenu.IronSoulConfigureSerialized"
String SUNDERHEART_CUSTOM_MENU_CONFIGURE_SERIALIZED_WRAPPED = "_root.Menu_mc.MessageMenu.IronSoulConfigureSerialized"
String SUNDERHEART_CUSTOM_MENU_LOAD_EVENT = "IronSoul_MessageBox_Load"
String SUNDERHEART_CUSTOM_MENU_CONFIGURED_EVENT = "IronSoul_MessageBox_Configured"
String SUNDERHEART_CUSTOM_MENU_SELECT_EVENT = "IronSoul_MessageBox_Select"
String SUNDERHEART_CUSTOM_MENU_CANCEL_EVENT = "IronSoul_MessageBox_Cancel"
String SUNDERHEART_CUSTOM_MENU_DELIMITER = "{ISMB}"
String SUNDERHEART_INVENTORY_BRIDGE_SWF = "ironsoul_inventorybridge"
String SUNDERHEART_INVENTORY_BRIDGE_ROOT = "_root.ironsoul_inventorybridge.InventoryBridge_mc"
String SUNDERHEART_INVENTORY_BRIDGE_LOAD_EVENT = "IronSoul_InventoryBridge_Load"
String SUNDERHEART_INVENTORY_BRIDGE_SELECT_EVENT = "IronSoul_InventoryBridge_Select"
String SUNDERHEART_INVENTORY_BRIDGE_HOVER_EVENT = "IronSoul_InventoryBridge_Hover"
String SUNDERHEART_INVENTORY_BRIDGE_ERROR_EVENT = "IronSoul_InventoryBridge_Error"
String SUNDERHEART_INVENTORY_BRIDGE_DELIMITER = "{ISIB}"
Float SUNDERHEART_PRESENTATION_MAX_SECONDS = 6.5
Float SUNDERHEART_PRESENTATION_DISMISS_SECONDS = 2.7
Float SUNDERHEART_FOCUS_VOLUME_EPSILON = 0.01
Float SUNDERHEART_FOCUS_TIER1_VOLUME = 0.6
Float SUNDERHEART_FOCUS_TIER2_VOLUME = 0.7
Float SUNDERHEART_FOCUS_TIER3_VOLUME = 0.8
Float SUNDERHEART_FOCUS_TIER4_VOLUME = 0.9
Float SUNDERHEART_FOCUS_TIER5_VOLUME = 1.0
Float SUNDERHEART_CUSTOM_MENU_LOAD_TIMEOUT_SECONDS = 2.0
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
Bool _tonalInventoryBridgeActive = False
Bool _tonalInventoryBridgeLoaded = False
Bool _tonalInventoryBridgeFailed = False
Bool _tonalInventoryBridgeNoRows = False
Actor _pendingTonalPlayer = None
Form _pendingTonalSunderheartBaseItem = None
Int _pendingTonalSunderheartType = 0
Int _pendingTonalSunderheartTier = 0
Int _pendingTonalSessionToken = 0
Int _pendingTonalSelectedIndex = -1
Int _pendingTonalMaxTemper = 10
Int _sunderheartMenuBlockToken = 0
Bool _sunderheartUseFocusSFX = False
Float _sunderheartUseFocusVolume = 0.0
Bool _sunderheartActionChoiceFocusSFX = False
Float _sunderheartActionChoiceFocusVolume = 0.0
Bool _sunderheartInventoryHoverFocusSFX = False
Float _sunderheartInventoryHoverFocusVolume = 0.0
Bool _sunderheartInventoryHoverLastMatched = False
String _sunderheartInventoryHoverLastFormID = ""
Bool _sunderheartInventoryHoverSuppressed = False
String _sunderheartInventoryHoverSuppressedFormID = ""
Bool _sunderheartCustomMenuActive = False
Bool _sunderheartCustomMenuLoaded = False
Bool _sunderheartCustomMenuConfigured = False
Int _sunderheartCustomMenuConfiguredButtons = 0
Bool _sunderheartCustomMenuSelected = False
Bool _sunderheartCustomMenuCanceled = False
Int _sunderheartCustomMenuChoice = -1
Bool _sunderheartChoiceCancelActive = False
Bool _sunderheartChoiceCanceledByInput = False

Function ResetTransientState()
    EndSunderheartMenuBlock("reset")
    UnregisterForMenu(SUNDERHEART_INVENTORY_MENU)
    if _sunderheartCustomMenuActive
        UI.CloseCustomMenu()
    endif
    ClearSunderheartCustomMenuWait()
    EndSunderheartChoiceCancel()
    _sunderheartUseFocusSFX = False
    _sunderheartUseFocusVolume = 0.0
    _sunderheartActionChoiceFocusSFX = False
    _sunderheartActionChoiceFocusVolume = 0.0
    ClearSunderheartInventoryHoverSuppression()
    ClearSunderheartInventoryHover()
    IronSoulNative.SunderheartFocusStopImmediate()

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
    ClearSunderheartInventoryBridgeEvents()
    if !HasCoreRuntime()
        return
    endif

    RegisterForMenu(SUNDERHEART_INVENTORY_MENU)
    RegisterSunderheartInventoryBridgeEvents()
    ConfigureSunderheartFocusSFX()
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

    sessionToken = ValidateTonalEnhanceSessionInventoryRows(sessionToken, sunderheartType, sunderheartTier, maxTemper)
    return sessionToken
EndFunction

Int Function ValidateTonalEnhanceSessionInventoryRows(Int sessionToken, Int sunderheartType, Int sunderheartTier, Int maxTemper)
    if sessionToken <= 0
        return 0
    endif
    if !UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU)
        return sessionToken
    endif

    String serializedRows = IronSoulNative.SunderheartRefreshEnhanceSessionInventoryRows(sessionToken)
    if serializedRows == ""
        String resultText = GetSunderheartEnhanceResultText()
        IronSoulNative.SunderheartReleaseEnhanceSession(sessionToken)
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "ValidateTonalEnhanceSessionInventoryRows: Raw session built, but no eligible InventoryMenu rows found type=" + sunderheartType + " tier=" + sunderheartTier + " maxTemper=" + maxTemper + " result=" + resultText)
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "ValidateTonalEnhanceSessionInventoryRows: Enhance hidden due visible-row prescreen")
        return 0
    endif

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "ValidateTonalEnhanceSessionInventoryRows: Enhance available from visible InventoryMenu rows type=" + sunderheartType + " tier=" + sunderheartTier + " maxTemper=" + maxTemper)
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

    BeginSunderheartUseFocus(sunderheartTier)
    Int selectedAction = ShowSunderheartActionChoice(canAnima, canEnhance, canPurge, sunderheartTier)
    if selectedAction == SUNDERHEART_ACTION_ANIMA
        ReleasePreparedTonalEnhanceSession(enhanceSessionToken)
        Bool absorbed = TryAbsorbAnima(player, guid, sunderheartBaseItem, sunderheartType, sunderheartTier)
        if !absorbed
            EndSunderheartUseFocus(False)
        endif
        return absorbed
    elseif selectedAction == SUNDERHEART_ACTION_ENHANCE && canEnhance
        Int sessionToken = enhanceSessionToken
        enhanceSessionToken = 0
        Bool enhanced = TryEnhanceItem(player, sunderheartBaseItem, sunderheartType, sunderheartTier, sessionToken, enhanceMaxTemper)
        if !enhanced
            EndSunderheartUseFocus(False)
        endif
        return enhanced
    elseif selectedAction == SUNDERHEART_ACTION_PURGE
        ReleasePreparedTonalEnhanceSession(enhanceSessionToken)
        Bool purged = TryPurgeDeath(player, guid, sunderheartBaseItem, sunderheartType, sunderheartTier)
        if !purged
            EndSunderheartUseFocus(False)
        endif
        return purged
    endif

    ReleasePreparedTonalEnhanceSession(enhanceSessionToken)
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartSmartChoice: Sunderheart lowered")
    EndSunderheartUseFocus(False)
    return False
EndFunction

Int Function ShowSunderheartActionChoice(Bool canAnima, Bool canEnhance, Bool canPurge, Int sunderheartTier)
    Int optionCount = 0
    if canAnima
        optionCount += 1
    endif
    if canEnhance
        optionCount += 1
    endif
    if canPurge
        optionCount += 1
    endif

    if optionCount <= 0
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartActionChoice: no valid actions")
        return SUNDERHEART_ACTION_NONE
    endif

    String[] labels = Utility.CreateStringArray(optionCount)
    Int[] actions = Utility.CreateIntArray(optionCount)
    Int index = 0
    if canAnima
        labels[index] = "Absorb Anima"
        actions[index] = SUNDERHEART_ACTION_ANIMA
        index += 1
    endif
    if canEnhance
        labels[index] = "Enhance Item"
        actions[index] = SUNDERHEART_ACTION_ENHANCE
        index += 1
    endif
    if canPurge
        labels[index] = "Purge Death"
        actions[index] = SUNDERHEART_ACTION_PURGE
    endif

    _sunderheartActionChoiceFocusSFX = True
    _sunderheartActionChoiceFocusVolume = ResolveSunderheartFocusVolumeForTier(sunderheartTier)
    if ConfigureSunderheartFocusSFX()
        IronSoulNative.SunderheartFocusSetActionTarget(_sunderheartActionChoiceFocusVolume)
    endif
    Int choice = ShowSunderheartCustomMenu("The Sunderheart stirs.", labels, False, True)
    _sunderheartActionChoiceFocusSFX = False
    _sunderheartActionChoiceFocusVolume = 0.0
    IronSoulNative.SunderheartFocusClearActionTarget()
    if choice >= 0 && choice < optionCount
        return actions[choice]
    endif

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartActionChoice: custom menu canceled choice=" + choice)
    return SUNDERHEART_ACTION_NONE
EndFunction

Int Function ShowSunderheartCustomMenu(String messageText, String[] buttonLabels, Bool vertical, Bool cancellable)
    Int buttonCount = buttonLabels.Length
    if buttonCount <= 0
        return -1
    endif

    String payload = ""
    if cancellable
        payload = "true"
    else
        payload = "false"
    endif
    if vertical
        payload += SUNDERHEART_CUSTOM_MENU_DELIMITER + "true"
    else
        payload += SUNDERHEART_CUSTOM_MENU_DELIMITER + "false"
    endif
    payload += SUNDERHEART_CUSTOM_MENU_DELIMITER + messageText

    Int i = 0
    while i < buttonCount
        payload += SUNDERHEART_CUSTOM_MENU_DELIMITER + buttonLabels[i]
        i += 1
    endwhile

    UI.CloseCustomMenu()
    BeginSunderheartCustomMenuWait()
    UI.OpenCustomMenu(SUNDERHEART_CUSTOM_MENU_SWF, 0)
    UI.InvokeString(SUNDERHEART_CUSTOM_MENU, SUNDERHEART_CUSTOM_MENU_CONFIGURE_SERIALIZED, payload)
    UI.InvokeString(SUNDERHEART_CUSTOM_MENU, SUNDERHEART_CUSTOM_MENU_CONFIGURE_SERIALIZED_WRAPPED, payload)
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartCustomMenu: configure invoked swf=" + SUNDERHEART_CUSTOM_MENU_SWF + " buttons=" + buttonCount + " vertical=" + vertical + " cancellable=" + cancellable + " loaded=" + _sunderheartCustomMenuLoaded)

    Float waited = 0.0
    while UI.IsMenuOpen(SUNDERHEART_CUSTOM_MENU) && !_sunderheartCustomMenuConfigured && !_sunderheartCustomMenuCanceled && waited < 0.5
        Utility.WaitMenuMode(0.05)
        waited += 0.05
    endwhile

    if !_sunderheartCustomMenuConfigured && UI.IsMenuOpen(SUNDERHEART_CUSTOM_MENU) && !_sunderheartCustomMenuCanceled
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartCustomMenu: configured event not received buttons=" + buttonCount)
    endif

    while UI.IsMenuOpen(SUNDERHEART_CUSTOM_MENU) && !_sunderheartCustomMenuSelected && !_sunderheartCustomMenuCanceled
        Utility.WaitMenuMode(0.1)
    endwhile

    Int choice = _sunderheartCustomMenuChoice
    Bool selected = _sunderheartCustomMenuSelected
    Bool canceled = _sunderheartCustomMenuCanceled
    UI.CloseCustomMenu()
    ClearSunderheartCustomMenuWait()

    if !selected || canceled || choice < 0 || choice >= buttonCount
        return -1
    endif
    return choice
EndFunction

Function BeginSunderheartCustomMenuWait()
    ClearSunderheartCustomMenuWait()
    _sunderheartCustomMenuActive = True
    _sunderheartCustomMenuLoaded = False
    _sunderheartCustomMenuConfigured = False
    _sunderheartCustomMenuConfiguredButtons = 0
    _sunderheartCustomMenuSelected = False
    _sunderheartCustomMenuCanceled = False
    _sunderheartCustomMenuChoice = -1
    RegisterForModEvent(SUNDERHEART_CUSTOM_MENU_LOAD_EVENT, "OnIronSoul_MessageBox_Load")
    RegisterForModEvent(SUNDERHEART_CUSTOM_MENU_CONFIGURED_EVENT, "OnIronSoul_MessageBox_Configured")
    RegisterForModEvent(SUNDERHEART_CUSTOM_MENU_SELECT_EVENT, "OnIronSoul_MessageBox_Select")
    RegisterForModEvent(SUNDERHEART_CUSTOM_MENU_CANCEL_EVENT, "OnIronSoul_MessageBox_Cancel")
    RegisterForKey(SUNDERHEART_CANCEL_KEY_ESC)
    RegisterForKey(SUNDERHEART_CANCEL_KEY_TAB)
    RegisterForKey(SUNDERHEART_CANCEL_KEY_START)
    RegisterForKey(SUNDERHEART_CANCEL_KEY_BACK)
    RegisterForKey(SUNDERHEART_CANCEL_KEY_GAMEPAD_B)
EndFunction

Function ClearSunderheartCustomMenuWait()
    UnregisterForModEvent(SUNDERHEART_CUSTOM_MENU_LOAD_EVENT)
    UnregisterForModEvent(SUNDERHEART_CUSTOM_MENU_CONFIGURED_EVENT)
    UnregisterForModEvent(SUNDERHEART_CUSTOM_MENU_SELECT_EVENT)
    UnregisterForModEvent(SUNDERHEART_CUSTOM_MENU_CANCEL_EVENT)
    UnregisterForKey(SUNDERHEART_CANCEL_KEY_ESC)
    UnregisterForKey(SUNDERHEART_CANCEL_KEY_TAB)
    UnregisterForKey(SUNDERHEART_CANCEL_KEY_START)
    UnregisterForKey(SUNDERHEART_CANCEL_KEY_BACK)
    UnregisterForKey(SUNDERHEART_CANCEL_KEY_GAMEPAD_B)
    _sunderheartCustomMenuActive = False
    _sunderheartCustomMenuLoaded = False
    _sunderheartCustomMenuConfigured = False
    _sunderheartCustomMenuConfiguredButtons = 0
    _sunderheartCustomMenuSelected = False
    _sunderheartCustomMenuCanceled = False
    _sunderheartCustomMenuChoice = -1
EndFunction

Event OnIronSoul_MessageBox_Load(String eventName, String strArg, Float numArg, Form formArg)
    if !_sunderheartCustomMenuActive
        return
    endif

    _sunderheartCustomMenuLoaded = True
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnIronSoul_MessageBox_Load: custom menu loaded")
EndEvent

Event OnIronSoul_MessageBox_Configured(String eventName, String strArg, Float numArg, Form formArg)
    if !_sunderheartCustomMenuActive
        return
    endif

    _sunderheartCustomMenuConfigured = True
    _sunderheartCustomMenuConfiguredButtons = numArg as Int
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnIronSoul_MessageBox_Configured: custom menu buttons=" + _sunderheartCustomMenuConfiguredButtons)
EndEvent

Event OnIronSoul_MessageBox_Select(String eventName, String strArg, Float numArg, Form formArg)
    if !_sunderheartCustomMenuActive
        return
    endif

    _sunderheartCustomMenuChoice = numArg as Int
    _sunderheartCustomMenuSelected = True
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnIronSoul_MessageBox_Select: custom menu choice=" + _sunderheartCustomMenuChoice + " label=" + strArg)
    UI.CloseCustomMenu()
EndEvent

Event OnIronSoul_MessageBox_Cancel(String eventName, String strArg, Float numArg, Form formArg)
    if !_sunderheartCustomMenuActive
        return
    endif

    _sunderheartCustomMenuChoice = -1
    _sunderheartCustomMenuCanceled = True
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnIronSoul_MessageBox_Cancel: custom menu canceled")
    UI.CloseCustomMenu()
EndEvent

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
    if _sunderheartCustomMenuActive && IsSunderheartChoiceCancelKey(keyCode)
        _sunderheartCustomMenuChoice = -1
        _sunderheartCustomMenuCanceled = True
        UI.CloseCustomMenu()
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnKeyDown: custom Sunderheart menu cancel key=" + keyCode)
        return
    endif

    if !_sunderheartChoiceCancelActive || !IsSunderheartChoiceCancelKey(keyCode)
        return
    endif

    _sunderheartChoiceCanceledByInput = True
    Bool closed = IronSoulNative.CloseMenu(SUNDERHEART_MESSAGEBOX_MENU)
    Utility.WaitMenuMode(0.05)
    Bool stillOpen = UI.IsMenuOpen(SUNDERHEART_MESSAGEBOX_MENU)
    if stillOpen
        Bool retriedClose = IronSoulNative.CloseMenu(SUNDERHEART_MESSAGEBOX_MENU)
        closed = closed || retriedClose
    endif
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnKeyDown: Sunderheart choice cancel key=" + keyCode + " closeMessageBox=" + closed + " stillOpenAfterClose=" + stillOpen)
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
    _tonalInventoryBridgeActive = True
    _tonalInventoryBridgeLoaded = False
    _tonalInventoryBridgeFailed = False
    _tonalInventoryBridgeNoRows = False
    _pendingTonalSelectedIndex = -1
    RegisterSunderheartInventoryBridgeEvents()

    Bool inventoryWasOpen = UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU)
    if !inventoryWasOpen && !IronSoulNative.OpenMenu(SUNDERHEART_INVENTORY_MENU)
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "ShowSunderheartEnhanceList: InventoryMenu could not be queued")
        ClearSunderheartInventoryBridgeWait()
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
        ClearSunderheartInventoryBridgeWait()
        Debug.MessageBox("The Sunderheart selection menu is not available.")
        return -1
    endif

    InjectSunderheartInventoryBridge()

    waited = 0.0
    while UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU) && !_tonalInventoryBridgeLoaded && !_tonalInventoryBridgeFailed && waited < 2.0
        Utility.WaitMenuMode(0.1)
        waited += 0.1
    endwhile

    if !_tonalInventoryBridgeLoaded || _tonalInventoryBridgeFailed
        Bool noEligibleRows = _tonalInventoryBridgeNoRows
        if noEligibleRows
            LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartEnhanceList: Iron Soul inventory bridge found no eligible rows session=" + sessionToken)
        else
            LogSunderhearts(IronSoulConfig.LOG_ERR(), "ShowSunderheartEnhanceList: Iron Soul inventory bridge failed to load session=" + sessionToken + " loaded=" + _tonalInventoryBridgeLoaded + " failed=" + _tonalInventoryBridgeFailed)
        endif
        if !inventoryWasOpen
            IronSoulNative.CloseMenu(SUNDERHEART_INVENTORY_MENU)
        endif
        ClearSunderheartInventoryBridgeWait()
        if !noEligibleRows
            Debug.MessageBox("The Sunderheart selection menu is not available.")
        endif
        return -1
    endif

    while UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU) && _pendingTonalSelectedIndex < 0 && !_tonalInventoryBridgeFailed
        Utility.WaitMenuMode(0.1)
    endwhile

    ClearSunderheartInventoryBridgeWait()
    return _pendingTonalSelectedIndex
EndFunction

Function InjectSunderheartInventoryBridge()
    String[] args = new String[2]
    args[0] = SUNDERHEART_INVENTORY_BRIDGE_SWF
    args[1] = Utility.RandomInt(1000, 10000)
    UI.InvokeStringA(SUNDERHEART_INVENTORY_MENU, "_root.createEmptyMovieClip", args)
    UI.InvokeString(SUNDERHEART_INVENTORY_MENU, "_root." + SUNDERHEART_INVENTORY_BRIDGE_SWF + ".loadMovie", SUNDERHEART_INVENTORY_BRIDGE_SWF + ".swf")
EndFunction

Function RegisterSunderheartInventoryBridgeEvents()
    UnregisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_LOAD_EVENT)
    UnregisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_SELECT_EVENT)
    UnregisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_HOVER_EVENT)
    UnregisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_ERROR_EVENT)
    RegisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_LOAD_EVENT, "OnIronSoul_InventoryBridge_Load")
    RegisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_SELECT_EVENT, "OnIronSoul_InventoryBridge_Select")
    RegisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_HOVER_EVENT, "OnIronSoul_InventoryBridge_Hover")
    RegisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_ERROR_EVENT, "OnIronSoul_InventoryBridge_Error")
EndFunction

Function ClearSunderheartInventoryBridgeEvents()
    UnregisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_LOAD_EVENT)
    UnregisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_SELECT_EVENT)
    UnregisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_HOVER_EVENT)
    UnregisterForModEvent(SUNDERHEART_INVENTORY_BRIDGE_ERROR_EVENT)
EndFunction

Function ClearSunderheartInventoryBridgeWait()
    _tonalInventoryBridgeActive = False
    _tonalInventoryBridgeLoaded = False
    _tonalInventoryBridgeFailed = False
    _tonalInventoryBridgeNoRows = False
EndFunction

Event OnIronSoul_InventoryBridge_Load(String eventName, String strArg, Float numArg, Form formArg)
    if !_tonalInventoryBridgeActive
        ConfigureSunderheartInventoryBridgeHover()
        return
    endif

    String serializedRows = IronSoulNative.SunderheartRefreshEnhanceSessionInventoryRows(_pendingTonalSessionToken)
    if serializedRows == ""
        String resultText = GetSunderheartEnhanceResultText()
        _tonalInventoryBridgeFailed = True
        _tonalInventoryBridgeNoRows = True
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnIronSoul_InventoryBridge_Load: No eligible InventoryMenu rows session=" + _pendingTonalSessionToken + " result=" + resultText)
        Debug.Notification("The Sunderheart finds no eligible weapon or armor to strengthen.")
        IronSoulNative.CloseMenu(SUNDERHEART_INVENTORY_MENU)
        return
    endif

    UI.InvokeString(SUNDERHEART_INVENTORY_MENU, SUNDERHEART_INVENTORY_BRIDGE_ROOT + ".setAllowedRows", serializedRows)
    _tonalInventoryBridgeLoaded = True
EndEvent

Function ConfigureSunderheartInventoryBridgeHover()
    if !UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU)
        return
    endif

    UI.InvokeString(SUNDERHEART_INVENTORY_MENU, SUNDERHEART_INVENTORY_BRIDGE_ROOT + ".enableHover", "")
EndFunction

Event OnIronSoul_InventoryBridge_Select(String eventName, String strArg, Float numArg, Form formArg)
    if !_tonalInventoryBridgeActive
        return
    endif

    _pendingTonalSelectedIndex = numArg as Int
    IronSoulNative.CloseMenu(SUNDERHEART_INVENTORY_MENU)
EndEvent

Event OnIronSoul_InventoryBridge_Hover(String eventName, String strArg, Float numArg, Form formArg)
    HandleSunderheartInventoryBridgeHover(strArg)
EndEvent

Event OnIronSoul_InventoryBridge_Error(String eventName, String strArg, Float numArg, Form formArg)
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnIronSoul_InventoryBridge_Error: reason=" + strArg)
    if !_tonalInventoryBridgeActive
        ClearSunderheartInventoryHoverSuppression()
        ClearSunderheartInventoryHover()
        IronSoulNative.SunderheartFocusClearHoverTarget()
    else
        _tonalInventoryBridgeFailed = True
    endif
EndEvent

Function HandleSunderheartInventoryBridgeHover(String payload)
    Int delimLen = StringUtil.GetLength(SUNDERHEART_INVENTORY_BRIDGE_DELIMITER)
    Int firstDelim = StringUtil.Find(payload, SUNDERHEART_INVENTORY_BRIDGE_DELIMITER)
    if firstDelim < 0
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "HandleSunderheartInventoryBridgeHover: malformed payload=" + payload)
        ClearSunderheartInventoryHoverSuppression()
        ClearSunderheartInventoryHover()
        IronSoulNative.SunderheartFocusClearHoverTarget()
        return
    endif

    Int formStart = firstDelim + delimLen
    Int secondDelim = StringUtil.Find(payload, SUNDERHEART_INVENTORY_BRIDGE_DELIMITER, formStart)
    if secondDelim < 0
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "HandleSunderheartInventoryBridgeHover: incomplete payload=" + payload)
        ClearSunderheartInventoryHoverSuppression()
        ClearSunderheartInventoryHover()
        IronSoulNative.SunderheartFocusClearHoverTarget()
        return
    endif

    String reason = StringUtil.Substring(payload, 0, firstDelim)
    String formIDText = StringUtil.Substring(payload, formStart, secondDelim - formStart)
    String selectedIndexText = StringUtil.Substring(payload, secondDelim + delimLen)
    Bool noSelection = formIDText == "" || formIDText == "0" || selectedIndexText == "-1"
    if _sunderheartInventoryHoverSuppressed
        if noSelection || formIDText != _sunderheartInventoryHoverSuppressedFormID
            ClearSunderheartInventoryHoverSuppression()
        else
            return
        endif
    endif

    Bool matched = False
    Float focusVolume = 0.0
    if !noSelection
        Form selectedForm = IronSoulNative.FormIDStringToForm(formIDText)
        focusVolume = ResolveSunderheartFocusVolumeForForm(selectedForm)
        matched = focusVolume > 0.0
    endif

    if matched != _sunderheartInventoryHoverLastMatched || formIDText != _sunderheartInventoryHoverLastFormID || !SunderheartFloatNearlyEqual(focusVolume, _sunderheartInventoryHoverFocusVolume)
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "HandleSunderheartInventoryBridgeHover: reason=" + reason + " form=" + formIDText + " index=" + selectedIndexText + " matched=" + matched + " volume=" + focusVolume)
    endif

    _sunderheartInventoryHoverFocusSFX = matched
    _sunderheartInventoryHoverFocusVolume = focusVolume
    _sunderheartInventoryHoverLastMatched = matched
    _sunderheartInventoryHoverLastFormID = formIDText
    if matched && ConfigureSunderheartFocusSFX()
        IronSoulNative.SunderheartFocusSetHoverTarget(focusVolume)
    elseif CanPlaySunderheartFocusSFX()
        IronSoulNative.SunderheartFocusSetHoverTarget(0.0)
    else
        IronSoulNative.SunderheartFocusStopImmediate()
    endif
EndFunction

Function SuppressSunderheartInventoryHover()
    if _sunderheartInventoryHoverLastFormID != ""
        _sunderheartInventoryHoverSuppressed = True
        _sunderheartInventoryHoverSuppressedFormID = _sunderheartInventoryHoverLastFormID
        LogSunderhearts(IronSoulConfig.LOG_DBG(), "SuppressSunderheartInventoryHover: form=" + _sunderheartInventoryHoverSuppressedFormID, True)
    else
        ClearSunderheartInventoryHoverSuppression()
    endif
    ClearSunderheartInventoryHover()
    IronSoulNative.SunderheartFocusClearHoverTarget()
EndFunction

Function ClearSunderheartInventoryHoverSuppression()
    if _sunderheartInventoryHoverSuppressed
        LogSunderhearts(IronSoulConfig.LOG_DBG(), "ClearSunderheartInventoryHoverSuppression: form=" + _sunderheartInventoryHoverSuppressedFormID, True)
    endif
    _sunderheartInventoryHoverSuppressed = False
    _sunderheartInventoryHoverSuppressedFormID = ""
EndFunction

Function ClearSunderheartInventoryHover()
    if _sunderheartInventoryHoverFocusSFX || _sunderheartInventoryHoverLastMatched || _sunderheartInventoryHoverLastFormID != ""
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "ClearSunderheartInventoryHover: cleared form=" + _sunderheartInventoryHoverLastFormID)
    endif
    _sunderheartInventoryHoverFocusSFX = False
    _sunderheartInventoryHoverFocusVolume = 0.0
    _sunderheartInventoryHoverLastMatched = False
    _sunderheartInventoryHoverLastFormID = ""
EndFunction

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
    ClearSunderheartInventoryBridgeWait()

    if _pendingTonalSessionToken > 0
        IronSoulNative.SunderheartReleaseEnhanceSession(_pendingTonalSessionToken)
    endif

    _tonalSelectionActive = False
    _tonalInventoryBridgeActive = False
    _tonalInventoryBridgeLoaded = False
    _tonalInventoryBridgeFailed = False
    _tonalInventoryBridgeNoRows = False
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
        EndSunderheartUseFocus(False)
        EndSunderheartMenuBlock("sunderheart-presentation-skipped")
        return
    endif
    if Controller && Controller.Config && !Controller.Config.IsSunderheartMessageEnabled()
        BeginSunderheartPresentationFocusHandoff()
        PlaySunderheartSFX(player)
        EndSunderheartMenuBlock("sunderheart-presentation-complete")
        return
    endif
    if menuName == ""
        EndSunderheartUseFocus(False)
        EndSunderheartMenuBlock("sunderheart-presentation-skipped")
        return
    endif

    Int cursorToken = IronSoulNative.BeginCursorSuppress()
    Controller.Presentation.FadeMusicForTransitionSequence()
    UI.CloseCustomMenu()
    IronSoulNative.RefreshCursorSuppress()
    BeginSunderheartPresentationFocusHandoff()
    PlaySunderheartSFX(player)
    UI.OpenCustomMenu(menuName, 0)
    IronSoulNative.RefreshCursorSuppress()
    ; PlaySunderheartSFX(player)
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
        RegisterSunderheartInventoryBridgeEvents()
        ClearSunderheartInventoryHoverSuppression()
        ClearSunderheartInventoryHover()
        ConfigureSunderheartFocusSFX()
        InjectSunderheartInventoryBridge()
    endif
EndEvent

Event OnMenuClose(String menuName)
    if menuName == SUNDERHEART_INVENTORY_MENU
        ClearSunderheartInventoryHoverSuppression()
        ClearSunderheartInventoryHover()
        IronSoulNative.SunderheartFocusClearHoverTarget()
    endif
EndEvent

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
    if !SFXSunderheartFocusLoop
        return False
    endif
    return Game.GetPlayer() != None
EndFunction

Bool Function ConfigureSunderheartFocusSFX()
    if !CanPlaySunderheartFocusSFX()
        IronSoulNative.SunderheartFocusStopImmediate()
        return False
    endif
    return IronSoulNative.SunderheartFocusConfigure(SFXSunderheartFocusLoop)
EndFunction

Function BeginSunderheartUseFocus(Int sunderheartTier)
    Float focusVolume = ResolveSunderheartFocusVolumeForTier(sunderheartTier)
    _sunderheartUseFocusSFX = focusVolume > 0.0
    _sunderheartUseFocusVolume = focusVolume
    LogSunderhearts(IronSoulConfig.LOG_DBG(), "BeginSunderheartUseFocus: tier=" + sunderheartTier + " volume=" + focusVolume, True)
    if _sunderheartUseFocusSFX && ConfigureSunderheartFocusSFX()
        IronSoulNative.SunderheartFocusSetUseTarget(focusVolume)
    else
        IronSoulNative.SunderheartFocusClearUseTarget(False)
    endif
EndFunction

Function EndSunderheartUseFocus(Bool immediate = False)
    if _sunderheartUseFocusSFX || _sunderheartActionChoiceFocusSFX || _sunderheartInventoryHoverFocusSFX
        LogSunderhearts(IronSoulConfig.LOG_DBG(), "EndSunderheartUseFocus: immediate=" + immediate + " useVolume=" + _sunderheartUseFocusVolume, True)
    endif

    _sunderheartUseFocusSFX = False
    _sunderheartUseFocusVolume = 0.0
    _sunderheartActionChoiceFocusSFX = False
    _sunderheartActionChoiceFocusVolume = 0.0

    if immediate
        ClearSunderheartInventoryHoverSuppression()
        ClearSunderheartInventoryHover()
        IronSoulNative.SunderheartFocusClearActionTarget()
        IronSoulNative.SunderheartFocusClearUseTarget(True)
    else
        SuppressSunderheartInventoryHover()
        IronSoulNative.SunderheartFocusClearActionTarget()
        IronSoulNative.SunderheartFocusClearUseTarget(False)
    endif
EndFunction

Function BeginSunderheartPresentationFocusHandoff()
    if _sunderheartUseFocusSFX || _sunderheartActionChoiceFocusSFX || _sunderheartInventoryHoverFocusSFX
        LogSunderhearts(IronSoulConfig.LOG_DBG(), "BeginSunderheartPresentationFocusHandoff: useVolume=" + _sunderheartUseFocusVolume, True)
    endif

    _sunderheartUseFocusSFX = False
    _sunderheartUseFocusVolume = 0.0
    _sunderheartActionChoiceFocusSFX = False
    _sunderheartActionChoiceFocusVolume = 0.0
    SuppressSunderheartInventoryHover()
    IronSoulNative.SunderheartFocusPresentationHandoff()
EndFunction

Float Function ResolveSunderheartFocusVolumeForTier(Int sunderheartTier)
    if sunderheartTier >= 5
        return SUNDERHEART_FOCUS_TIER5_VOLUME
    elseif sunderheartTier == 4
        return SUNDERHEART_FOCUS_TIER4_VOLUME
    elseif sunderheartTier == 3
        return SUNDERHEART_FOCUS_TIER3_VOLUME
    elseif sunderheartTier == 2
        return SUNDERHEART_FOCUS_TIER2_VOLUME
    elseif sunderheartTier == 1
        return SUNDERHEART_FOCUS_TIER1_VOLUME
    endif
    return 0.0
EndFunction

Float Function ResolveSunderheartFocusVolumeForForm(Form selectedForm)
    if !selectedForm || selectedForm == SunderheartSpent
        return 0.0
    endif
    if SunderheartTier5List && SunderheartTier5List.HasForm(selectedForm)
        return SUNDERHEART_FOCUS_TIER5_VOLUME
    elseif SunderheartTier4List && SunderheartTier4List.HasForm(selectedForm)
        return SUNDERHEART_FOCUS_TIER4_VOLUME
    elseif SunderheartTier3List && SunderheartTier3List.HasForm(selectedForm)
        return SUNDERHEART_FOCUS_TIER3_VOLUME
    elseif SunderheartTier2List && SunderheartTier2List.HasForm(selectedForm)
        return SUNDERHEART_FOCUS_TIER2_VOLUME
    elseif SunderheartTier1List && SunderheartTier1List.HasForm(selectedForm)
        return SUNDERHEART_FOCUS_TIER1_VOLUME
    endif
    return 0.0
EndFunction

Bool Function SunderheartFloatNearlyEqual(Float left, Float right)
    Float diff = left - right
    if diff < 0.0
        diff = 0.0 - diff
    endif
    return diff <= SUNDERHEART_FOCUS_VOLUME_EPSILON
EndFunction

Float Function ClampSunderheartFocusVolume(Float volume)
    if volume < 0.0
        return 0.0
    elseif volume > 1.0
        return 1.0
    endif
    return volume
EndFunction
