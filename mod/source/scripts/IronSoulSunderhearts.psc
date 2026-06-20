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
String Property sunderheartsAbsorbedWorld = "SH.A.W" AutoReadOnly ; World successful Sunderheart use counter.
String Property sunderheartsCharacterTotal = "SH.C" AutoReadOnly ; Current-character successful Sunderheart use counter.
String Property sunderheartsUnlockedWorld = "SH.U.W" AutoReadOnly ; World distinct Sunderheart unlock counter.
String Property sunderheartCatalogUsedWorldPrefix = "SH.C." AutoReadOnly ; World boolean used catalog prefix.

Sound Property SFXSunderheartAbsorb Auto
Sound Property SFXSunderheartFocusLoop Auto

Int SUNDERHEART_TYPE_TONAL = 1
Int SUNDERHEART_EFFECT_TEMPER_GEAR = 1
Int SUNDERHEART_INVENTORY_MODE_REOPEN = 1
Int SUNDERHEART_INVENTORY_MODE_CLOSE = 2
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
Float SUNDERHEART_PRESENTATION_DISMISS_SECONDS = 2.9
Float SUNDERHEART_FOCUS_VOLUME_EPSILON = 0.01
Float SUNDERHEART_FOCUS_TIER1_VOLUME = 0.2
Float SUNDERHEART_FOCUS_TIER2_VOLUME = 0.4
Float SUNDERHEART_FOCUS_TIER3_VOLUME = 0.6
Float SUNDERHEART_FOCUS_TIER4_VOLUME = 0.8
Float SUNDERHEART_FOCUS_TIER5_VOLUME = 1.0
Float SUNDERHEART_CUSTOM_MENU_LOAD_TIMEOUT_SECONDS = 2.0
Float SUNDERHEART_CUSTOM_MENU_CLOSE_WAIT_SECONDS = 1.0
Float SUNDERHEART_CUSTOM_MENU_CANCEL_CLOSE_WAIT_SECONDS = 0.1
Float SUNDERHEART_USE_RELEASE_WAIT_SECONDS = 0.05
Float SUNDERHEART_USE_INTENT_CAPTURE_SECONDS = 0.75
Float SUNDERHEART_USE_INTENT_DISPATCH_SECONDS = 0.05
Float SUNDERHEART_USE_INTENT_STALE_SECONDS = 0.85
Float SUNDERHEART_HOVER_REFRESH_DELAY_SECONDS = 0.03
Float SUNDERHEART_USE_REENTRY_COOLDOWN_SECONDS = 0.75
Int TEMPER_GEAR_MAX_LEVEL = 10
Int TEMPER_GEAR_CONFIG_MAX_LEVEL = 100
Int ENHANCE_RESULT_ALREADY_CAPPED = 4
Int ENHANCE_RESULT_AMBIGUOUS_STACK = 10
Int SUNDERHEART_ACTION_NONE = 0
Int SUNDERHEART_ACTION_ANIMA = 1
Int SUNDERHEART_ACTION_ENHANCE = 2
Int SUNDERHEART_ACTION_PURGE = 3
Int SUNDERHEART_ACTION_TEXT_DEFAULT = 0
Int SUNDERHEART_ACTION_TEXT_NO_PURGE = 1
Int SUNDERHEART_ACTION_TEXT_NO_ITEM = 2
Int SUNDERHEART_ENHANCE_RESULT_CANCELED = 0
Int SUNDERHEART_ENHANCE_RESULT_SUCCESS = 1
Int SUNDERHEART_ENHANCE_RESULT_NO_ROWS = -2
Int SUNDERHEART_ENHANCE_RESULT_FAILED = -3
Int SUNDERHEART_PURGE_RESULT_SUCCESS = 1
Int SUNDERHEART_PURGE_RESULT_NO_DEATHS = -2
Int SUNDERHEART_PURGE_RESULT_FAILED = -3
Int SUNDERHEART_CANCEL_KEY_ESC = 1
Int SUNDERHEART_CANCEL_KEY_TAB = 15
Int SUNDERHEART_CANCEL_KEY_START = 270
Int SUNDERHEART_CANCEL_KEY_BACK = 271
Int SUNDERHEART_CANCEL_KEY_GAMEPAD_B = 277

Bool _handlingUse = False
Bool _enhanceSelectionActive = False
Bool _enhanceInventoryBridgeActive = False
Bool _enhanceInventoryBridgeLoaded = False
Bool _enhanceInventoryBridgeFailed = False
Bool _enhanceInventoryBridgeNoRows = False
Actor _pendingEnhancePlayer = None
Form _pendingEnhanceSunderheartBaseItem = None
Int _pendingEnhanceSunderheartType = 0
Int _pendingEnhanceSunderheartTier = 0
Int _pendingEnhanceEffectId = 0
Int _pendingEnhanceSessionToken = 0
Int _pendingEnhanceSelectedIndex = -1
Int _pendingEnhancePower = 0
Int _pendingEnhanceCap = 10
Int _sunderheartMenuBlockToken = 0
Bool _sunderheartUseFocusSFX = False
Float _sunderheartUseFocusVolume = 0.0
Bool _sunderheartActionChoiceFocusSFX = False
Float _sunderheartActionChoiceFocusVolume = 0.0
Bool _sunderheartInventoryHoverFocusSFX = False
Float _sunderheartInventoryHoverFocusVolume = 0.0
Bool _sunderheartInventoryHoverLastMatched = False
Form _sunderheartInventoryHoverLastForm = None
String _sunderheartInventoryHoverLastFormID = ""
Bool _sunderheartInventoryHoverSuppressed = False
Form _sunderheartInventoryHoverSuppressedForm = None
String _sunderheartInventoryHoverSuppressedFormID = ""
Int _sunderheartInventoryHoverRefreshToken = 0
Bool _sunderheartCustomMenuActive = False
Bool _sunderheartCustomMenuLoaded = False
Bool _sunderheartCustomMenuConfigured = False
Int _sunderheartCustomMenuConfiguredButtons = 0
Bool _sunderheartCustomMenuSelected = False
Bool _sunderheartCustomMenuCanceled = False
Int _sunderheartCustomMenuChoice = -1
Bool _sunderheartPresentationActive = False
Float _sunderheartUseBlockedUntil = 0.0
Bool _sunderheartUseIntentCaptureActive = False
Float _sunderheartUseIntentCaptureUntil = 0.0
Bool _openingSunderheartUseIntent = False
Bool _sunderheartUseIntentDispatchActive = False
Bool _pendingSunderheartUseIntent = False
Actor _pendingSunderheartUseIntentPlayer = None
Form _pendingSunderheartUseIntentBaseItem = None
Int _pendingSunderheartUseIntentType = 0
Int _pendingSunderheartUseIntentTier = 0
Float _pendingSunderheartUseIntentAt = 0.0
Float _pendingSunderheartUseIntentExpiresAt = 0.0
String _pendingSunderheartUseIntentSource = ""
String _pendingSunderheartUseIntentLastBlockReason = ""
Int _pendingSunderheartUseIntentGeneration = 0
Bool _sunderheartUseIntentIdentityBlockLogged = False

Function ResetTransientState()
    EndSunderheartMenuBlock("reset")
    UnregisterForMenu(SUNDERHEART_INVENTORY_MENU)
    if _sunderheartCustomMenuActive
        UI.CloseCustomMenu()
    endif
    ClearSunderheartCustomMenuWait()
    _sunderheartUseFocusSFX = False
    _sunderheartUseFocusVolume = 0.0
    _sunderheartActionChoiceFocusSFX = False
    _sunderheartActionChoiceFocusVolume = 0.0
    _sunderheartPresentationActive = False
    _sunderheartUseBlockedUntil = 0.0
    _sunderheartUseIntentCaptureActive = False
    _sunderheartUseIntentCaptureUntil = 0.0
    _openingSunderheartUseIntent = False
    _sunderheartUseIntentDispatchActive = False
    ClearPendingSunderheartUseIntent()
    IronSoulNative.SunderheartUseIntentClearCapture("reset")
    ClearSunderheartInventoryHoverSuppression()
    ClearSunderheartInventoryHover()
    IronSoulNative.SunderheartFocusStopImmediate()

    _handlingUse = False
    ClearEnhancementSelectionState()
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
    ConfigureSunderheartUseIntentCapture()
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

Bool Function CanWriteWorldProgression(Actor player)
    if player && Controller && Controller.Identity
        return !Controller.Identity.IsCurrentCharacterTest(player)
    endif
    return True
EndFunction

Int Function GetSunderheartsAbsorbedWorld(Actor player = None)
    if !Controller || !Controller.Persistence
        return 0
    endif
    if !CanWriteWorldProgression(player)
        return 0
    endif

    return Controller.Persistence.GetWorldInt(sunderheartsAbsorbedWorld, 0)
EndFunction

Bool Function SetSunderheartsAbsorbedWorld(Actor player, Int totalValue, Bool flushNow = False)
    if !Controller || !Controller.Persistence
        return False
    endif
    if !CanWriteWorldProgression(player)
        if Controller.Globals
            Controller.Globals.SyncSunderhearts(player)
        endif
        return True
    endif

    Int clampedTotal = totalValue
    if clampedTotal < 0
        clampedTotal = 0
    endif

    Controller.Persistence.SetWorldInt(sunderheartsAbsorbedWorld, clampedTotal, True)
    if Controller.Globals
        Controller.Globals.SyncSunderhearts(player)
    endif
    if flushNow
        IronSoulNative.DataFlushIfDirty()
    endif
    return True
EndFunction

Int Function IncrementSunderheartsAbsorbedWorld(Actor player, Int sunderheartType = 0, Int sunderheartTier = 0)
    if !CanWriteWorldProgression(player)
        return 0
    endif

    Int currentTotal = GetSunderheartsAbsorbedWorld(player)
    Int nextTotal = currentTotal + 1
    if !SetSunderheartsAbsorbedWorld(player, nextTotal, False)
        return currentTotal
    endif

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "IncrementSunderheartsAbsorbedWorld: WorldSunderheartsAbsorbed=" + nextTotal + " type=" + sunderheartType + " tier=" + sunderheartTier)
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

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "IncrementSunderheartsCharacterTotal: CharacterSunderheartsAbsorbed=" + nextTotal + " type=" + sunderheartType + " tier=" + sunderheartTier)
    return nextTotal
EndFunction

Int Function GetSunderheartsUnlocked(Actor player = None)
    if !Controller || !Controller.Persistence
        return 0
    endif
    if !CanWriteWorldProgression(player)
        return 0
    endif

    return Controller.Persistence.GetWorldInt(sunderheartsUnlockedWorld, 0)
EndFunction

Bool Function SetSunderheartsUnlocked(Actor player, Int unlockedValue, Bool flushNow = False)
    if !Controller || !Controller.Persistence
        return False
    endif
    if !CanWriteWorldProgression(player)
        return True
    endif

    Int clampedUnlocked = unlockedValue
    if clampedUnlocked < 0
        clampedUnlocked = 0
    endif

    Controller.Persistence.SetWorldInt(sunderheartsUnlockedWorld, clampedUnlocked, True)
    if flushNow
        IronSoulNative.DataFlushIfDirty()
    endif
    return True
EndFunction

Int Function IncrementSunderheartsUnlocked(Actor player, Int sunderheartType = 0, Int sunderheartTier = 0)
    if !CanWriteWorldProgression(player)
        return 0
    endif

    Int currentUnlocked = GetSunderheartsUnlocked(player)
    Int nextUnlocked = currentUnlocked + 1
    if !SetSunderheartsUnlocked(player, nextUnlocked, False)
        return currentUnlocked
    endif

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "IncrementSunderheartsUnlocked: World SunderheartsUnlocked=" + nextUnlocked + " type=" + sunderheartType + " tier=" + sunderheartTier)
    return nextUnlocked
EndFunction

String Function GetSunderheartUsedKey(Int sunderheartType, Int sunderheartTier)
    if sunderheartType <= 0 || sunderheartTier < 0
        return ""
    endif

    return sunderheartCatalogUsedWorldPrefix + sunderheartType + "." + sunderheartTier + ".W"
EndFunction

Bool Function HasUsedSunderheart(Int sunderheartType, Int sunderheartTier, Actor player = None)
    if !Controller || !Controller.Persistence
        return False
    endif
    if !CanWriteWorldProgression(player)
        return False
    endif

    String usedKey = GetSunderheartUsedKey(sunderheartType, sunderheartTier)
    if usedKey == ""
        return False
    endif

    return Controller.Persistence.GetWorldInt(usedKey, 0) == 1
EndFunction

Bool Function MarkSunderheartUsed(Int sunderheartType, Int sunderheartTier, Actor player = None)
    if !Controller || !Controller.Persistence
        return False
    endif
    if !CanWriteWorldProgression(player)
        return False
    endif

    String usedKey = GetSunderheartUsedKey(sunderheartType, sunderheartTier)
    if usedKey == ""
        return False
    endif

    if HasUsedSunderheart(sunderheartType, sunderheartTier, player)
        return False
    endif

    Controller.Persistence.SetWorldInt(usedKey, 1, True)
    return True
EndFunction

Bool Function RegisterSunderheartUsed(Actor player, Int sunderheartType = 0, Int sunderheartTier = 0)
    if !Controller || !Controller.Persistence
        return False
    endif

    Int nextTotal = IncrementSunderheartsAbsorbedWorld(player, sunderheartType, sunderheartTier)
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
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "RegisterSunderheartUsed: WorldSunderheartsAbsorbed=" + nextTotal + " CharacterSunderheartsAbsorbed=" + nextCharacterTotal + " WorldSunderheartsUnlocked=" + nextUnlocked + " usedKey=" + usedKey + " newUnlock=" + newUnlock)
    return True
EndFunction

Int Function ResetWorldSunderheartData(Actor player = None)
    if !Controller || !Controller.Persistence
        return -1
    endif
    if !CanWriteWorldProgression(player)
        if Controller.Globals
            Controller.Globals.SyncSunderhearts(player)
        endif
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "ResetWorldSunderheartData: skipped World reset for test character")
        return 0
    endif

    SetSunderheartsAbsorbedWorld(player, 0, False)
    SetSunderheartsUnlocked(player, 0, False)
    Int deletedCatalogKeys = Controller.Persistence.DeleteWorldKeysWithPrefix(sunderheartCatalogUsedWorldPrefix)
    if Controller.Globals
        Controller.Globals.SyncSunderhearts(player)
    endif
    IronSoulNative.DataFlushIfDirty()
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "ResetWorldSunderheartData: reset World SunderheartsAbsorbed=0 SunderheartsUnlocked=0 deletedCatalogKeys=" + deletedCatalogKeys)
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
        if mode == SUNDERHEART_INVENTORY_MODE_REOPEN || mode == SUNDERHEART_INVENTORY_MODE_CLOSE
            return mode
        endif
    endif
    return SUNDERHEART_INVENTORY_MODE_REOPEN
EndFunction

Bool Function ShouldCloseInventoryForSunderheartAction()
    Int mode = GetSunderheartInventoryMode()
    if mode == SUNDERHEART_INVENTORY_MODE_REOPEN || mode == SUNDERHEART_INVENTORY_MODE_CLOSE
        return True
    endif
    return False
EndFunction

Bool Function ShouldReopenInventoryAfterSunderheartAction(Bool enhanceAction)
    Int mode = GetSunderheartInventoryMode()
    if mode == SUNDERHEART_INVENTORY_MODE_REOPEN
        return True
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

Function WaitSunderheartMenuOrReal(Float seconds)
    if seconds <= 0.0
        return
    endif
    if UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU) || UI.IsMenuOpen(SUNDERHEART_CUSTOM_MENU) || UI.IsMenuOpen(SUNDERHEART_MESSAGEBOX_MENU)
        Utility.WaitMenuMode(seconds)
    else
        Utility.Wait(seconds)
    endif
EndFunction

Function CloseSunderheartCustomMenuAndWait(String reason = "", Float maxWait = 1.0)
    if !UI.IsMenuOpen(SUNDERHEART_CUSTOM_MENU)
        return
    endif

    UI.CloseCustomMenu()
    Float waited = 0.0
    while UI.IsMenuOpen(SUNDERHEART_CUSTOM_MENU) && waited < maxWait
        WaitSunderheartMenuOrReal(0.05)
        waited += 0.05
    endwhile

    if UI.IsMenuOpen(SUNDERHEART_CUSTOM_MENU)
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "CloseSunderheartCustomMenuAndWait: CustomMenu still open reason=" + reason + " waited=" + waited)
    elseif reason != ""
        LogSunderhearts(IronSoulConfig.LOG_DBG(), "CloseSunderheartCustomMenuAndWait: CustomMenu closed reason=" + reason + " waited=" + waited, True)
    endif
EndFunction

Function BlockSunderheartUseBriefly(Float seconds = 0.75)
    if seconds <= 0.0
        return
    endif

    Float untilTime = Utility.GetCurrentRealTime() + seconds
    if untilTime > _sunderheartUseBlockedUntil
        _sunderheartUseBlockedUntil = untilTime
    endif
EndFunction

Bool Function IsSunderheartUseBlocked()
    return GetSunderheartUseBlockReason() != ""
EndFunction

String Function GetSunderheartUseBlockReason()
    if _handlingUse
        return "handling-use"
    elseif _sunderheartPresentationActive
        return "presentation"
    elseif _sunderheartMenuBlockToken > 0
        return "menu-block"
    elseif _sunderheartCustomMenuActive
        return "custom-menu"
    elseif Utility.GetCurrentRealTime() < _sunderheartUseBlockedUntil && !_sunderheartUseIntentCaptureActive
        return "cooldown"
    endif
    return ""
EndFunction

Function ClearPendingSunderheartUseIntent()
    _pendingSunderheartUseIntentGeneration += 1
    _pendingSunderheartUseIntent = False
    _pendingSunderheartUseIntentPlayer = None
    _pendingSunderheartUseIntentBaseItem = None
    _pendingSunderheartUseIntentType = 0
    _pendingSunderheartUseIntentTier = 0
    _pendingSunderheartUseIntentAt = 0.0
    _pendingSunderheartUseIntentExpiresAt = 0.0
    _pendingSunderheartUseIntentSource = ""
    _pendingSunderheartUseIntentLastBlockReason = ""
    _sunderheartUseIntentIdentityBlockLogged = False
EndFunction

Function ClearSunderheartUseIntentState(String reason = "")
    Bool hadState = _sunderheartUseIntentCaptureActive || _pendingSunderheartUseIntent
    _sunderheartUseIntentCaptureActive = False
    _sunderheartUseIntentCaptureUntil = 0.0
    ClearPendingSunderheartUseIntent()
    IronSoulNative.SunderheartUseIntentClearCapture(reason)
    if hadState
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "SunderheartUseIntent: cleared reason=" + reason)
    endif
EndFunction

Function ConfigureSunderheartUseIntentCapture()
    IronSoulNative.SunderheartUseIntentConfigureInventoryForms(SunderheartTier1List, SunderheartTier2List, SunderheartTier3List, SunderheartTier4List, SunderheartTier5List, SunderheartSpent)
EndFunction

Function ClearSunderheartUseReplayState()
    ClearSunderheartUseIntentState("legacy-clear")
EndFunction

Bool Function IsSunderheartUseIntentTransientBlock(String blockReason)
    return blockReason == "handling-use" || blockReason == "cooldown" || blockReason == "menu-block" || blockReason == "enhance-active" || blockReason == "custom-menu" || blockReason == "identity"
EndFunction

Function LogSunderheartUseIntentIdentityBlock(Actor player)
    if _sunderheartUseIntentIdentityBlockLogged
        return
    endif

    _sunderheartUseIntentIdentityBlockLogged = True
    String playerName = IronSoulNative.GetPlayerName()
    Bool placeholderName = False
    Bool bootstrapActive = False
    if Controller && Controller.Identity
        placeholderName = Controller.Identity.IsPlaceholderName(playerName)
        bootstrapActive = Controller.Identity.IsBootstrapActive()
    endif
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "SunderheartUseIntent: blocked reason=identity playerName=" + playerName + " placeholder=" + placeholderName + " menuMode=" + Utility.IsInMenuMode() + " bootstrapActive=" + bootstrapActive)
EndFunction

String Function GetSunderheartUseIntentBlockReason(Actor player, Form sunderheartBaseItem)
    if !HasCoreRuntime()
        return "core"
    elseif !player || player != Game.GetPlayer()
        return "player"
    elseif !sunderheartBaseItem
        return "item"
    elseif _pendingSunderheartUseIntentExpiresAt > 0.0 && Utility.GetCurrentRealTime() > _pendingSunderheartUseIntentExpiresAt
        return "stale"
    elseif player.GetItemCount(sunderheartBaseItem) <= 0
        return "missing-item"
    elseif _handlingUse
        return "handling-use"
    elseif _sunderheartPresentationActive
        return "presentation"
    elseif _sunderheartMenuBlockToken > 0
        return "menu-block"
    elseif _enhanceSelectionActive || _enhanceInventoryBridgeActive
        return "enhance-active"
    elseif _sunderheartCustomMenuActive
        return "custom-menu"
    elseif Utility.GetCurrentRealTime() < _sunderheartUseBlockedUntil
        return "cooldown"
    endif
    if !Controller || !Controller.Identity || Controller.Identity.GetTickGuid(player) == ""
        LogSunderheartUseIntentIdentityBlock(player)
        return "identity"
    endif
    return ""
EndFunction

Function OpenSunderheartUseIntentCaptureWindow(String reason = "")
    Float now = Utility.GetCurrentRealTime()
    _sunderheartUseIntentCaptureActive = True
    _sunderheartUseIntentCaptureUntil = now + SUNDERHEART_USE_INTENT_CAPTURE_SECONDS
    ConfigureSunderheartUseIntentCapture()
    IronSoulNative.SunderheartUseIntentBeginCapture(SUNDERHEART_USE_INTENT_CAPTURE_SECONDS, reason)
    LogSunderhearts(IronSoulConfig.LOG_DBG(), "SunderheartUseIntent: capture-open reason=" + reason + " until=" + _sunderheartUseIntentCaptureUntil, True)
EndFunction

Function OpenSunderheartUseReplayWindow(Bool preserveQueuedUse = False)
    OpenSunderheartUseIntentCaptureWindow("legacy-replay-window")
EndFunction

Bool Function StoreSunderheartUseIntent(Actor player, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0, String source = "papyrus")
    if !HasCoreRuntime() || !player || player != Game.GetPlayer() || !sunderheartBaseItem
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "SunderheartUseIntent: dropped-hard-block reason=invalid source=" + source)
        return False
    endif

    if sunderheartTier <= 0
        sunderheartTier = ResolveSunderheartTierForForm(sunderheartBaseItem)
    endif
    if sunderheartType <= 0
        sunderheartType = ResolveSunderheartTypeForBaseForm(sunderheartBaseItem)
    endif
    if sunderheartType <= 0 || sunderheartTier <= 0
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "SunderheartUseIntent: dropped-hard-block reason=unresolved source=" + source + " type=" + sunderheartType + " tier=" + sunderheartTier)
        return False
    endif

    if _pendingSunderheartUseIntent
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "SunderheartUseIntent: superseded oldSource=" + _pendingSunderheartUseIntentSource + " newSource=" + source + " type=" + sunderheartType + " tier=" + sunderheartTier)
    endif

    Float now = Utility.GetCurrentRealTime()
    _pendingSunderheartUseIntent = True
    _pendingSunderheartUseIntentPlayer = player
    _pendingSunderheartUseIntentBaseItem = sunderheartBaseItem
    _pendingSunderheartUseIntentType = sunderheartType
    _pendingSunderheartUseIntentTier = sunderheartTier
    _pendingSunderheartUseIntentAt = now
    _pendingSunderheartUseIntentExpiresAt = now + SUNDERHEART_USE_INTENT_STALE_SECONDS
    _pendingSunderheartUseIntentSource = source
    _pendingSunderheartUseIntentLastBlockReason = ""
    _sunderheartUseIntentIdentityBlockLogged = False
    _pendingSunderheartUseIntentGeneration += 1
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "SunderheartUseIntent: queued source=" + source + " type=" + sunderheartType + " tier=" + sunderheartTier + " expiresAt=" + _pendingSunderheartUseIntentExpiresAt)
    return True
EndFunction

Bool Function SubmitSunderheartUseIntent(Actor player, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0, String source = "papyrus")
    if !StoreSunderheartUseIntent(player, sunderheartBaseItem, sunderheartType, sunderheartTier, source)
        return False
    endif

    RequestSunderheartUseIntentDispatch("submit")
    return True
EndFunction

Bool Function QueueSunderheartUseAfterCancel(Actor player, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0)
    return SubmitSunderheartUseIntent(player, sunderheartBaseItem, sunderheartType, sunderheartTier, "legacy-after-cancel")
EndFunction

Function RequestSunderheartUseIntentDispatch(String reason = "")
    if !_pendingSunderheartUseIntent && !_sunderheartUseIntentCaptureActive
        return
    endif
    if _sunderheartUseIntentDispatchActive
        LogSunderhearts(IronSoulConfig.LOG_DBG(), "SunderheartUseIntent: queued reason=" + reason + " dispatchActive=True generation=" + _pendingSunderheartUseIntentGeneration, True)
        return
    endif

    PumpSunderheartUseIntentDispatch(reason)
EndFunction

Function RequestQueuedSunderheartUseReplayDrain(String reason = "")
    RequestSunderheartUseIntentDispatch(reason)
EndFunction

Bool Function ClaimNativeSunderheartUseIntent()
    if !IronSoulNative.SunderheartUseIntentClaim()
        return False
    endif

    Form nativeBaseItem = IronSoulNative.SunderheartUseIntentClaimedBaseForm()
    Int nativeTier = IronSoulNative.SunderheartUseIntentClaimedTier()
    Float nativeAge = IronSoulNative.SunderheartUseIntentClaimedAgeSeconds()
    String nativeSource = IronSoulNative.SunderheartUseIntentClaimedSource()
    if nativeAge > SUNDERHEART_USE_INTENT_STALE_SECONDS
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "SunderheartUseIntent: dropped-stale source=native-" + nativeSource + " age=" + nativeAge)
        return False
    endif
    return StoreSunderheartUseIntent(Game.GetPlayer(), nativeBaseItem, ResolveSunderheartTypeForBaseForm(nativeBaseItem), nativeTier, "native-" + nativeSource)
EndFunction

Function DispatchSunderheartUseIntent()
    if !_pendingSunderheartUseIntent
        ClaimNativeSunderheartUseIntent()
    endif

    Float now = Utility.GetCurrentRealTime()
    if _sunderheartUseIntentCaptureActive && now > _sunderheartUseIntentCaptureUntil
        _sunderheartUseIntentCaptureActive = False
        _sunderheartUseIntentCaptureUntil = 0.0
        IronSoulNative.SunderheartUseIntentClearCapture("capture-expired")
    endif

    if !_pendingSunderheartUseIntent
        return
    endif

    Actor intentPlayer = _pendingSunderheartUseIntentPlayer
    Form intentBaseItem = _pendingSunderheartUseIntentBaseItem
    Int intentType = _pendingSunderheartUseIntentType
    Int intentTier = _pendingSunderheartUseIntentTier
    String intentSource = _pendingSunderheartUseIntentSource
    String blockReason = GetSunderheartUseIntentBlockReason(intentPlayer, intentBaseItem)

    if blockReason == ""
        ClearSunderheartUseIntentState("opened")
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "SunderheartUseIntent: opened source=" + intentSource + " type=" + intentType + " tier=" + intentTier)
        _openingSunderheartUseIntent = True
        TryUseSunderheart(intentPlayer, intentBaseItem, intentType, intentTier)
        _openingSunderheartUseIntent = False
    elseif blockReason == "stale"
        String staleReason = _pendingSunderheartUseIntentLastBlockReason
        if staleReason == ""
            staleReason = "stale"
        endif
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "SunderheartUseIntent: dropped-stale reason=" + staleReason + " source=" + intentSource + " type=" + intentType + " tier=" + intentTier)
        ClearSunderheartUseIntentState("dropped-stale")
    elseif IsSunderheartUseIntentTransientBlock(blockReason)
        if _pendingSunderheartUseIntentLastBlockReason != blockReason
            LogSunderhearts(IronSoulConfig.LOG_DBG(), "SunderheartUseIntent: queued source=" + intentSource + " reason=" + blockReason + " type=" + intentType + " tier=" + intentTier, True)
        endif
        _pendingSunderheartUseIntentLastBlockReason = blockReason
    else
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "SunderheartUseIntent: dropped-hard-block reason=" + blockReason + " source=" + intentSource + " type=" + intentType + " tier=" + intentTier)
        ClearSunderheartUseIntentState("dropped-hard-block")
    endif
EndFunction

Function PumpSunderheartUseIntentDispatch(String reason = "")
    if !_pendingSunderheartUseIntent && !_sunderheartUseIntentCaptureActive
        return
    endif
    if _sunderheartUseIntentDispatchActive
        LogSunderhearts(IronSoulConfig.LOG_DBG(), "SunderheartUseIntent: queued reason=" + reason + " dispatchActive=True generation=" + _pendingSunderheartUseIntentGeneration, True)
        return
    endif

    _sunderheartUseIntentDispatchActive = True
    LogSunderhearts(IronSoulConfig.LOG_DBG(), "SunderheartUseIntent: dispatch-pump reason=" + reason + " generation=" + _pendingSunderheartUseIntentGeneration, True)

    while _pendingSunderheartUseIntent || _sunderheartUseIntentCaptureActive
        DispatchSunderheartUseIntent()
        if !_pendingSunderheartUseIntent && !_sunderheartUseIntentCaptureActive
            _sunderheartUseIntentDispatchActive = False
            return
        endif

        Float activeUntil = 0.0
        if _pendingSunderheartUseIntent && _pendingSunderheartUseIntentExpiresAt > activeUntil
            activeUntil = _pendingSunderheartUseIntentExpiresAt
        endif
        if _sunderheartUseIntentCaptureActive && _sunderheartUseIntentCaptureUntil > activeUntil
            activeUntil = _sunderheartUseIntentCaptureUntil
        endif

        if activeUntil <= 0.0 || Utility.GetCurrentRealTime() >= activeUntil
            DispatchSunderheartUseIntent()
            if _pendingSunderheartUseIntent || _sunderheartUseIntentCaptureActive
                ClearSunderheartUseIntentState("pump-expired")
            endif
            _sunderheartUseIntentDispatchActive = False
            return
        endif

        WaitSunderheartMenuOrReal(SUNDERHEART_USE_INTENT_DISPATCH_SECONDS)
    endwhile

    _sunderheartUseIntentDispatchActive = False
EndFunction

Function DrainQueuedSunderheartUseReplay()
    PumpSunderheartUseIntentDispatch("legacy-drain")
EndFunction

Bool Function TryReplayQueuedSunderheartUse(Int expectedGeneration = 0)
    PumpSunderheartUseIntentDispatch("legacy-replay")
    return False
EndFunction

Bool Function ShouldIgnoreSunderheartInventoryHover()
    if _sunderheartUseFocusSFX || _sunderheartActionChoiceFocusSFX || _sunderheartCustomMenuActive || _enhanceSelectionActive || _sunderheartPresentationActive
        return True
    endif
    return False
EndFunction

String Function GetSunderheartEnhanceResultText()
    String resultText = IronSoulNative.SunderheartGetEnhanceResultText()
    if resultText == ""
        return IronSoulNative.TextGet("Sunderheart.EnhanceUnknownFailure")
    endif
    return resultText
EndFunction

Function NotifySunderheartEnhanceFailure(Bool applyFailure = False)
    Int result = IronSoulNative.SunderheartGetEnhanceResult()
    if result == ENHANCE_RESULT_ALREADY_CAPPED
        Debug.Notification(IronSoulNative.TextGet("Sunderheart.EnhanceAlreadyCapped"))
    elseif result == ENHANCE_RESULT_AMBIGUOUS_STACK
        Debug.Notification(IronSoulNative.TextGet("Sunderheart.EnhanceAmbiguousStack"))
    elseif applyFailure
        Debug.Notification(IronSoulNative.TextGet("Sunderheart.EnhanceApplyFailure"))
    else
        Debug.Notification(IronSoulNative.TextGet("Sunderheart.EnhanceFailure"))
    endif
EndFunction

Function NotifySunderheartSuccess(String msg)
    if msg == ""
        return
    endif
    if Controller && Controller.Config && !Controller.Config.IsSunderheartNotificationEnabled()
        return
    endif

    Debug.Notification(IronSoulNative.TextFormat2("Sunderheart.SuccessNotification", "message", msg, "total", "" + GetSunderheartsAbsorbedWorld(Game.GetPlayer())))
EndFunction

Bool Function TryUseSunderheart(Actor player, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0)
    Bool result = False

    if !HasCoreRuntime() || !player || !sunderheartBaseItem
        return False
    endif
    if player != Game.GetPlayer()
        return False
    endif
    String blockReason = GetSunderheartUseBlockReason()
    if blockReason != ""
        Bool queuedIntent = False
        if blockReason == "handling-use" || blockReason == "cooldown" || blockReason == "custom-menu"
            queuedIntent = SubmitSunderheartUseIntent(player, sunderheartBaseItem, sunderheartType, sunderheartTier, "try-use-blocked")
        endif
        LogSunderhearts(IronSoulConfig.LOG_DBG(), "TryUseSunderheart: blocked reason=" + blockReason + " queuedIntent=" + queuedIntent, True)
        return False
    endif
    if !_openingSunderheartUseIntent
        ClearSunderheartUseIntentState("direct-use")
    endif
    if player.GetItemCount(sunderheartBaseItem) <= 0
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "TryUseSunderheart: Player does not have the exact Sunderheart base form")
        ClearSunderheartUseIntentState("missing-item")
        Debug.MessageBox(IronSoulNative.TextGet("MessageBox.SunderheartMissingInventory"))
        return False
    endif

    _handlingUse = True

    String guid = Controller.Identity.GetTickGuid(player)
    if guid == ""
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "TryUseSunderheart: Could not resolve player GUID")
    else
        result = ShowSunderheartSmartChoice(player, guid, sunderheartBaseItem, sunderheartType, sunderheartTier)
    endif

    WaitSunderheartMenuOrReal(SUNDERHEART_USE_RELEASE_WAIT_SECONDS)
    _handlingUse = False
    PumpSunderheartUseIntentDispatch("handling-release")
    return result
EndFunction

Function ReleasePreparedEnhanceSession(Int sessionToken)
    if sessionToken > 0
        IronSoulNative.SunderheartReleaseEnhanceSession(sessionToken)
    endif
EndFunction

Bool Function ShowSunderheartSmartChoice(Actor player, String guid, Form sunderheartBaseItem, Int sunderheartType, Int sunderheartTier)
    BeginSunderheartUseFocus(sunderheartTier)
    Int selectorTextState = SUNDERHEART_ACTION_TEXT_DEFAULT
    while True
        Int selectedAction = ShowSunderheartActionChoice(sunderheartTier, selectorTextState)
        if selectedAction == SUNDERHEART_ACTION_ANIMA
            Bool absorbed = TryAbsorbAnima(player, guid, sunderheartBaseItem, sunderheartType, sunderheartTier)
            if !absorbed
                EndSunderheartUseFocus(False)
            endif
            return absorbed
        elseif selectedAction == SUNDERHEART_ACTION_ENHANCE
            Int enhanceResult = TryEnhanceItemResult(player, sunderheartBaseItem, sunderheartType, sunderheartTier, 0, 0)
            if enhanceResult == SUNDERHEART_ENHANCE_RESULT_SUCCESS
                return True
            elseif enhanceResult == SUNDERHEART_ENHANCE_RESULT_NO_ROWS
                selectorTextState = SUNDERHEART_ACTION_TEXT_NO_ITEM
                LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartSmartChoice: Reopening action menu after unavailable enhance target")
            elseif enhanceResult == SUNDERHEART_ENHANCE_RESULT_CANCELED
                EndSunderheartUseFocus(False, False, True)
                return False
            else
                EndSunderheartUseFocus(False)
                return False
            endif
        elseif selectedAction == SUNDERHEART_ACTION_PURGE
            Int purgeResult = TryPurgeDeathResult(player, guid, sunderheartBaseItem, sunderheartType, sunderheartTier)
            if purgeResult == SUNDERHEART_PURGE_RESULT_SUCCESS
                return True
            elseif purgeResult == SUNDERHEART_PURGE_RESULT_NO_DEATHS
                selectorTextState = SUNDERHEART_ACTION_TEXT_NO_PURGE
                LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartSmartChoice: Reopening action menu after unavailable purge")
            else
                EndSunderheartUseFocus(False)
                return False
            endif
        else
            LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartSmartChoice: Sunderheart lowered")
            EndSunderheartUseFocus(False, False, True)
            return False
        endif
    endwhile

    EndSunderheartUseFocus(False)
    return False
EndFunction

String Function GetSunderheartActionMessageText(Int selectorTextState)
    String newline = StringUtil.AsChar(10)
    String prefix = IronSoulNative.TextGet("Sunderheart.ActionIntroLine1") + newline + IronSoulNative.TextGet("Sunderheart.ActionIntroLine2") + newline + newline
    if selectorTextState == SUNDERHEART_ACTION_TEXT_NO_PURGE
        return prefix + IronSoulNative.TextGet("Sunderheart.ActionNoDeaths")
    elseif selectorTextState == SUNDERHEART_ACTION_TEXT_NO_ITEM
        return prefix + IronSoulNative.TextGet("Sunderheart.ActionNoItem")
    endif

    return prefix + IronSoulNative.TextGet("Sunderheart.ActionPrompt")
EndFunction

Int Function ShowSunderheartActionChoice(Int sunderheartTier, Int selectorTextState)
    Int optionCount = 3
    String[] labels = Utility.CreateStringArray(optionCount)
    Int[] actions = Utility.CreateIntArray(optionCount)
    labels[0] = IronSoulNative.TextGet("Sunderheart.ActionAbsorbAnima")
    actions[0] = SUNDERHEART_ACTION_ANIMA
    labels[1] = IronSoulNative.TextGet("Sunderheart.ActionEnhanceItem")
    actions[1] = SUNDERHEART_ACTION_ENHANCE
    labels[2] = IronSoulNative.TextGet("Sunderheart.ActionPurgeDeath")
    actions[2] = SUNDERHEART_ACTION_PURGE

    _sunderheartActionChoiceFocusSFX = True
    _sunderheartActionChoiceFocusVolume = ResolveSunderheartFocusVolumeForTier(sunderheartTier)
    if ConfigureSunderheartFocusSFX()
        IronSoulNative.SunderheartFocusSetActionTarget(_sunderheartActionChoiceFocusVolume)
    endif
    Int choice = ShowSunderheartCustomMenu(GetSunderheartActionMessageText(selectorTextState), labels, False, True)
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

    CloseSunderheartCustomMenuAndWait("action-menu-open", SUNDERHEART_CUSTOM_MENU_CLOSE_WAIT_SECONDS)
    BeginSunderheartCustomMenuWait()
    UI.OpenCustomMenu(SUNDERHEART_CUSTOM_MENU_SWF, 0)
    UI.InvokeString(SUNDERHEART_CUSTOM_MENU, SUNDERHEART_CUSTOM_MENU_CONFIGURE_SERIALIZED, payload)
    UI.InvokeString(SUNDERHEART_CUSTOM_MENU, SUNDERHEART_CUSTOM_MENU_CONFIGURE_SERIALIZED_WRAPPED, payload)
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartCustomMenu: configure invoked swf=" + SUNDERHEART_CUSTOM_MENU_SWF + " buttons=" + buttonCount + " vertical=" + vertical + " cancellable=" + cancellable + " loaded=" + _sunderheartCustomMenuLoaded)

    Float waited = 0.0
    while UI.IsMenuOpen(SUNDERHEART_CUSTOM_MENU) && !_sunderheartCustomMenuConfigured && !_sunderheartCustomMenuCanceled && waited < 0.5
        WaitSunderheartMenuOrReal(0.05)
        waited += 0.05
    endwhile

    if !_sunderheartCustomMenuConfigured && UI.IsMenuOpen(SUNDERHEART_CUSTOM_MENU) && !_sunderheartCustomMenuCanceled
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartCustomMenu: configured event not received buttons=" + buttonCount)
    endif

    while UI.IsMenuOpen(SUNDERHEART_CUSTOM_MENU) && !_sunderheartCustomMenuSelected && !_sunderheartCustomMenuCanceled
        WaitSunderheartMenuOrReal(0.1)
    endwhile

    Int choice = _sunderheartCustomMenuChoice
    Bool selected = _sunderheartCustomMenuSelected
    Bool canceled = _sunderheartCustomMenuCanceled
    Float closeWait = SUNDERHEART_CUSTOM_MENU_CLOSE_WAIT_SECONDS
    if canceled
        closeWait = SUNDERHEART_CUSTOM_MENU_CANCEL_CLOSE_WAIT_SECONDS
        OpenSunderheartUseIntentCaptureWindow("action-menu-cancel")
    endif
    CloseSunderheartCustomMenuAndWait("action-menu-close", closeWait)
    ClearSunderheartCustomMenuWait()
    if canceled
        PumpSunderheartUseIntentDispatch("action-menu-cancel-release")
    endif

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

    ClearSunderheartUseIntentState("action-selected")
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
    OpenSunderheartUseIntentCaptureWindow("action-menu-cancel-event")
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnIronSoul_MessageBox_Cancel: custom menu canceled")
    UI.CloseCustomMenu()
EndEvent

Bool Function IsSunderheartChoiceCancelKey(Int keyCode)
    return keyCode == SUNDERHEART_CANCEL_KEY_ESC || keyCode == SUNDERHEART_CANCEL_KEY_TAB || keyCode == SUNDERHEART_CANCEL_KEY_START || keyCode == SUNDERHEART_CANCEL_KEY_BACK || keyCode == SUNDERHEART_CANCEL_KEY_GAMEPAD_B
EndFunction

Event OnKeyDown(Int keyCode)
    if _sunderheartCustomMenuActive && IsSunderheartChoiceCancelKey(keyCode)
        _sunderheartCustomMenuChoice = -1
        _sunderheartCustomMenuCanceled = True
        OpenSunderheartUseIntentCaptureWindow("action-menu-cancel-key")
        UI.CloseCustomMenu()
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnKeyDown: custom Sunderheart menu cancel key=" + keyCode)
        return
    endif
EndEvent

Bool Function TryEnhanceItem(Actor player, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0, Int preparedSessionToken = 0, Int preparedEffectCap = 0)
    return TryEnhanceItemResult(player, sunderheartBaseItem, sunderheartType, sunderheartTier, preparedSessionToken, preparedEffectCap) == SUNDERHEART_ENHANCE_RESULT_SUCCESS
EndFunction

Int Function TryEnhanceItemResult(Actor player, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0, Int preparedSessionToken = 0, Int preparedEffectCap = 0)
    Int effectId = GetEnhanceEffectForSunderheartType(sunderheartType)
    if effectId > 0
        return TryEnhanceItemWithEffectResult(player, sunderheartBaseItem, effectId, sunderheartType, sunderheartTier, preparedSessionToken, preparedEffectCap)
    endif

    ReleasePreparedEnhanceSession(preparedSessionToken)
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceItem: Enhancement has no configured effect type=" + sunderheartType + " tier=" + sunderheartTier)
    return SUNDERHEART_ENHANCE_RESULT_NO_ROWS
EndFunction

Bool Function TryEnhanceItemWithEffect(Actor player, Form sunderheartBaseItem, Int effectId, Int sunderheartType = 0, Int sunderheartTier = 0, Int preparedSessionToken = 0, Int preparedEffectCap = 0)
    return TryEnhanceItemWithEffectResult(player, sunderheartBaseItem, effectId, sunderheartType, sunderheartTier, preparedSessionToken, preparedEffectCap) == SUNDERHEART_ENHANCE_RESULT_SUCCESS
EndFunction

Int Function TryEnhanceItemWithEffectResult(Actor player, Form sunderheartBaseItem, Int effectId, Int sunderheartType = 0, Int sunderheartTier = 0, Int preparedSessionToken = 0, Int preparedEffectCap = 0)
    if !HasCoreRuntime() || !player || !sunderheartBaseItem
        ReleasePreparedEnhanceSession(preparedSessionToken)
        return SUNDERHEART_ENHANCE_RESULT_FAILED
    endif
    if player.GetItemCount(sunderheartBaseItem) <= 0
        ReleasePreparedEnhanceSession(preparedSessionToken)
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "TryEnhanceItemWithEffect: Player does not have the exact Sunderheart base form")
        Debug.MessageBox(IronSoulNative.TextGet("MessageBox.SunderheartMissingInventory"))
        return SUNDERHEART_ENHANCE_RESULT_FAILED
    endif

    Int effectPower = ResolveEnhancePowerForEffect(effectId, sunderheartTier)
    Int effectCap = preparedEffectCap
    if effectCap <= 0
        effectCap = ResolveEnhanceCapForEffect(effectId)
    endif
    if effectPower <= 0 || effectCap <= 0
        ReleasePreparedEnhanceSession(preparedSessionToken)
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceItemWithEffect: Enhancement effect unavailable type=" + sunderheartType + " tier=" + sunderheartTier + " effect=" + effectId + " power=" + effectPower + " cap=" + effectCap)
        return SUNDERHEART_ENHANCE_RESULT_NO_ROWS
    endif
    Int sessionToken = preparedSessionToken
    if sessionToken <= 0
        sessionToken = IronSoulNative.SunderheartBuildEnhanceSession(effectId, effectPower, effectCap)
    endif
    if sessionToken <= 0
        String buildFailureText = GetSunderheartEnhanceResultText()
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceItemWithEffect: No enhancement options type=" + sunderheartType + " tier=" + sunderheartTier + " effect=" + effectId + " power=" + effectPower + " cap=" + effectCap + " result=" + buildFailureText)
        return SUNDERHEART_ENHANCE_RESULT_NO_ROWS
    endif

    if !StartEnhancementSelectionState(player, sunderheartBaseItem, sunderheartType, sunderheartTier, effectId, sessionToken, effectPower, effectCap)
        IronSoulNative.SunderheartReleaseEnhanceSession(sessionToken)
        return SUNDERHEART_ENHANCE_RESULT_FAILED
    endif

    Int selectedIndex = ShowSunderheartEnhanceList(sessionToken)
    if selectedIndex == SUNDERHEART_ENHANCE_RESULT_NO_ROWS
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceItemWithEffect: Enhancement selector found no eligible rows type=" + sunderheartType + " tier=" + sunderheartTier + " effect=" + effectId)
        ClearEnhancementSelectionState()
        return SUNDERHEART_ENHANCE_RESULT_NO_ROWS
    elseif selectedIndex == SUNDERHEART_ENHANCE_RESULT_FAILED
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceItemWithEffect: Enhancement selector failed type=" + sunderheartType + " tier=" + sunderheartTier + " effect=" + effectId)
        ClearEnhancementSelectionState()
        return SUNDERHEART_ENHANCE_RESULT_FAILED
    elseif selectedIndex < 0
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceItemWithEffect: Enhancement selection canceled type=" + sunderheartType + " tier=" + sunderheartTier + " effect=" + effectId)
        ClearEnhancementSelectionState()
        OpenSunderheartUseIntentCaptureWindow("enhance-selection-cancel")
        PumpSunderheartUseIntentDispatch("enhance-selection-cancel-release")
        return SUNDERHEART_ENHANCE_RESULT_CANCELED
    endif

    _pendingEnhanceSelectedIndex = selectedIndex
    if CompleteItemEnhancement()
        return SUNDERHEART_ENHANCE_RESULT_SUCCESS
    endif
    return SUNDERHEART_ENHANCE_RESULT_FAILED
EndFunction

Bool Function StartEnhancementSelectionState(Actor player, Form sunderheartBaseItem, Int sunderheartType, Int sunderheartTier, Int effectId, Int sessionToken, Int effectPower, Int effectCap)
    ClearEnhancementSelectionState()

    _enhanceSelectionActive = True
    _pendingEnhancePlayer = player
    _pendingEnhanceSunderheartBaseItem = sunderheartBaseItem
    _pendingEnhanceSunderheartType = sunderheartType
    _pendingEnhanceSunderheartTier = sunderheartTier
    _pendingEnhanceEffectId = effectId
    _pendingEnhanceSessionToken = sessionToken
    _pendingEnhanceSelectedIndex = -1
    _pendingEnhancePower = effectPower
    _pendingEnhanceCap = effectCap

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "StartEnhancementSelectionState: Started filtered item selection type=" + sunderheartType + " tier=" + sunderheartTier + " effect=" + effectId + " power=" + effectPower + " cap=" + effectCap + " session=" + sessionToken)
    return True
EndFunction

Int Function ShowSunderheartEnhanceList(Int sessionToken)
    _enhanceInventoryBridgeActive = True
    _enhanceInventoryBridgeLoaded = False
    _enhanceInventoryBridgeFailed = False
    _enhanceInventoryBridgeNoRows = False
    _pendingEnhanceSelectedIndex = -1
    RegisterSunderheartInventoryBridgeEvents()

    Bool inventoryWasOpen = UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU)
    if !inventoryWasOpen && !IronSoulNative.OpenMenu(SUNDERHEART_INVENTORY_MENU)
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "ShowSunderheartEnhanceList: InventoryMenu could not be queued")
        ClearSunderheartInventoryBridgeWait()
        Debug.MessageBox(IronSoulNative.TextGet("MessageBox.SunderheartSelectionUnavailable"))
        return SUNDERHEART_ENHANCE_RESULT_FAILED
    endif

    Float waited = 0.0
    while !UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU) && waited < 2.0
        Utility.WaitMenuMode(0.1)
        waited += 0.1
    endwhile

    if !UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU)
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "ShowSunderheartEnhanceList: InventoryMenu did not open")
        ClearSunderheartInventoryBridgeWait()
        Debug.MessageBox(IronSoulNative.TextGet("MessageBox.SunderheartSelectionUnavailable"))
        return SUNDERHEART_ENHANCE_RESULT_FAILED
    endif

    InjectSunderheartInventoryBridge()

    waited = 0.0
    while UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU) && !_enhanceInventoryBridgeLoaded && !_enhanceInventoryBridgeFailed && waited < 2.0
        Utility.WaitMenuMode(0.1)
        waited += 0.1
    endwhile

    if !_enhanceInventoryBridgeLoaded || _enhanceInventoryBridgeFailed
        Bool noEligibleRows = _enhanceInventoryBridgeNoRows
        if noEligibleRows
            LogSunderhearts(IronSoulConfig.LOG_INFO(), "ShowSunderheartEnhanceList: Iron Soul inventory bridge found no eligible rows session=" + sessionToken)
        else
            LogSunderhearts(IronSoulConfig.LOG_ERR(), "ShowSunderheartEnhanceList: Iron Soul inventory bridge failed to load session=" + sessionToken + " loaded=" + _enhanceInventoryBridgeLoaded + " failed=" + _enhanceInventoryBridgeFailed)
        endif
        if !inventoryWasOpen
            IronSoulNative.CloseMenu(SUNDERHEART_INVENTORY_MENU)
        endif
        ClearSunderheartInventoryBridgeWait()
        if !noEligibleRows
            Debug.MessageBox(IronSoulNative.TextGet("MessageBox.SunderheartSelectionUnavailable"))
            return SUNDERHEART_ENHANCE_RESULT_FAILED
        endif
        return SUNDERHEART_ENHANCE_RESULT_NO_ROWS
    endif

    while UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU) && _pendingEnhanceSelectedIndex < 0 && !_enhanceInventoryBridgeFailed
        Utility.WaitMenuMode(0.1)
    endwhile

    ClearSunderheartInventoryBridgeWait()
    return _pendingEnhanceSelectedIndex
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
    _enhanceInventoryBridgeActive = False
    _enhanceInventoryBridgeLoaded = False
    _enhanceInventoryBridgeFailed = False
    _enhanceInventoryBridgeNoRows = False
EndFunction

Event OnIronSoul_InventoryBridge_Load(String eventName, String strArg, Float numArg, Form formArg)
    if !_enhanceInventoryBridgeActive
        ConfigureSunderheartInventoryBridgeHover()
        return
    endif

    String serializedRows = IronSoulNative.SunderheartRefreshEnhanceSessionInventoryRows(_pendingEnhanceSessionToken)
    if serializedRows == ""
        String resultText = GetSunderheartEnhanceResultText()
        _enhanceInventoryBridgeFailed = True
        _enhanceInventoryBridgeNoRows = True
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnIronSoul_InventoryBridge_Load: No eligible InventoryMenu rows session=" + _pendingEnhanceSessionToken + " result=" + resultText)
        IronSoulNative.CloseMenu(SUNDERHEART_INVENTORY_MENU)
        return
    endif

    UI.InvokeString(SUNDERHEART_INVENTORY_MENU, SUNDERHEART_INVENTORY_BRIDGE_ROOT + ".setAllowedRows", serializedRows)
    _enhanceInventoryBridgeLoaded = True
EndEvent

Function ConfigureSunderheartInventoryBridgeHover()
    if !UI.IsMenuOpen(SUNDERHEART_INVENTORY_MENU)
        return
    endif

    UI.InvokeString(SUNDERHEART_INVENTORY_MENU, SUNDERHEART_INVENTORY_BRIDGE_ROOT + ".enableHover", "")
EndFunction

Event OnIronSoul_InventoryBridge_Select(String eventName, String strArg, Float numArg, Form formArg)
    if !_enhanceInventoryBridgeActive
        return
    endif

    _pendingEnhanceSelectedIndex = numArg as Int
    IronSoulNative.CloseMenu(SUNDERHEART_INVENTORY_MENU)
EndEvent

Event OnIronSoul_InventoryBridge_Hover(String eventName, String strArg, Float numArg, Form formArg)
    ; Native owns Sunderheart focus hover now; the bridge remains for select/error events.
EndEvent

Event OnIronSoul_InventoryBridge_Error(String eventName, String strArg, Float numArg, Form formArg)
    LogSunderhearts(IronSoulConfig.LOG_INFO(), "OnIronSoul_InventoryBridge_Error: reason=" + strArg)
    if !_enhanceInventoryBridgeActive
        ClearSunderheartInventoryHoverSuppression()
        ClearSunderheartInventoryHover()
        IronSoulNative.SunderheartFocusClearHoverTarget()
    else
        _enhanceInventoryBridgeFailed = True
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

    Form payloadForm = None
    Float payloadFocusVolume = 0.0
    Bool payloadMatched = False
    if !noSelection
        payloadForm = IronSoulNative.FormIDStringToForm(formIDText)
        payloadFocusVolume = ResolveSunderheartFocusVolumeForForm(payloadForm)
        payloadMatched = payloadFocusVolume > 0.0
    endif

    if _sunderheartInventoryHoverSuppressed
        if noSelection || payloadForm != _sunderheartInventoryHoverSuppressedForm
            ClearSunderheartInventoryHoverSuppression()
        else
            return
        endif
    endif

    if noSelection || !payloadMatched
        ClearSunderheartInventoryHoverSuppression()
        ClearSunderheartInventoryHover()
        IronSoulNative.SunderheartFocusClearHoverTarget()
    endif

    if ShouldIgnoreSunderheartInventoryHover()
        return
    endif

    QueueSunderheartInventoryHoverRefresh(reason)
EndFunction

Function QueueSunderheartInventoryHoverRefresh(String reason)
    _sunderheartInventoryHoverRefreshToken += 1
    Int token = _sunderheartInventoryHoverRefreshToken
    WaitSunderheartMenuOrReal(SUNDERHEART_HOVER_REFRESH_DELAY_SECONDS)
    if token != _sunderheartInventoryHoverRefreshToken
        return
    endif
    RefreshSunderheartInventoryHoverFromCurrentSelection(reason, token)
EndFunction

Function RefreshSunderheartInventoryHoverFromCurrentSelection(String reason, Int token)
    if token != _sunderheartInventoryHoverRefreshToken
        return
    endif
    if ShouldIgnoreSunderheartInventoryHover()
        return
    endif

    Form selectedForm = IronSoulNative.InventorySelectedItemForm()
    Float focusVolume = ResolveSunderheartFocusVolumeForForm(selectedForm)
    Bool matched = focusVolume > 0.0
    String formIDText = GetSunderheartHoverFormIDText(selectedForm)

    if _sunderheartInventoryHoverSuppressed
        if !selectedForm || selectedForm != _sunderheartInventoryHoverSuppressedForm
            ClearSunderheartInventoryHoverSuppression()
        else
            return
        endif
    endif

    if matched != _sunderheartInventoryHoverLastMatched || selectedForm != _sunderheartInventoryHoverLastForm || !SunderheartFloatNearlyEqual(focusVolume, _sunderheartInventoryHoverFocusVolume)
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "RefreshSunderheartInventoryHover: reason=" + reason + " form=" + formIDText + " matched=" + matched + " volume=" + focusVolume)
    endif

    _sunderheartInventoryHoverFocusSFX = matched
    _sunderheartInventoryHoverFocusVolume = focusVolume
    _sunderheartInventoryHoverLastMatched = matched
    _sunderheartInventoryHoverLastForm = selectedForm
    _sunderheartInventoryHoverLastFormID = formIDText
    if matched && ConfigureSunderheartFocusSFX()
        IronSoulNative.SunderheartFocusSetHoverTarget(focusVolume)
    elseif CanPlaySunderheartFocusSFX()
        IronSoulNative.SunderheartFocusClearHoverTarget()
    else
        IronSoulNative.SunderheartFocusStopImmediate()
    endif
EndFunction

String Function GetSunderheartHoverFormIDText(Form selectedForm)
    if selectedForm
        return "" + selectedForm.GetFormID()
    endif
    return "0"
EndFunction

Function SuppressSunderheartInventoryHover()
    _sunderheartInventoryHoverSuppressed = True
    _sunderheartInventoryHoverSuppressedForm = None
    _sunderheartInventoryHoverSuppressedFormID = "native"
    LogSunderhearts(IronSoulConfig.LOG_DBG(), "SuppressSunderheartInventoryHover: native", True)
    ClearSunderheartInventoryHover()
    IronSoulNative.SunderheartFocusSuppressInventoryHover("papyrus-suppress")
EndFunction

Function ClearSunderheartInventoryHoverSuppression()
    if _sunderheartInventoryHoverSuppressed
        LogSunderhearts(IronSoulConfig.LOG_DBG(), "ClearSunderheartInventoryHoverSuppression: form=" + _sunderheartInventoryHoverSuppressedFormID, True)
    endif
    _sunderheartInventoryHoverSuppressed = False
    _sunderheartInventoryHoverSuppressedForm = None
    _sunderheartInventoryHoverSuppressedFormID = ""
    IronSoulNative.SunderheartFocusClearInventoryHoverSuppression("papyrus-clear")
EndFunction

Function ClearSunderheartInventoryHover()
    _sunderheartInventoryHoverRefreshToken += 1
    if _sunderheartInventoryHoverFocusSFX || _sunderheartInventoryHoverLastMatched || _sunderheartInventoryHoverLastFormID != ""
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "ClearSunderheartInventoryHover: cleared form=" + _sunderheartInventoryHoverLastFormID)
    endif
    _sunderheartInventoryHoverFocusSFX = False
    _sunderheartInventoryHoverFocusVolume = 0.0
    _sunderheartInventoryHoverLastMatched = False
    _sunderheartInventoryHoverLastForm = None
    _sunderheartInventoryHoverLastFormID = ""
EndFunction

Bool Function CompleteItemEnhancement()
    Actor player = _pendingEnhancePlayer
    Form sunderheartBaseItem = _pendingEnhanceSunderheartBaseItem
    Int sunderheartType = _pendingEnhanceSunderheartType
    Int sunderheartTier = _pendingEnhanceSunderheartTier
    Int effectId = _pendingEnhanceEffectId
    Int sessionToken = _pendingEnhanceSessionToken
    Int selectedIndex = _pendingEnhanceSelectedIndex
    Int effectPower = _pendingEnhancePower
    Int effectCap = _pendingEnhanceCap

    if !player || !sunderheartBaseItem || sessionToken <= 0 || selectedIndex < 0
        ClearEnhancementSelectionState()
        return False
    endif

    if player.GetItemCount(sunderheartBaseItem) <= 0
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "CompleteItemEnhancement: Player no longer has exact Sunderheart base form")
        Debug.MessageBox(IronSoulNative.TextGet("MessageBox.SunderheartMissingInventory"))
        ClearEnhancementSelectionState()
        return False
    endif

    Bool enhanced = IronSoulNative.SunderheartApplyEnhanceSessionInventoryRow(sessionToken, selectedIndex)
    if !enhanced
        String resultText = GetSunderheartEnhanceResultText()
        NotifySunderheartEnhanceFailure(True)
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "CompleteItemEnhancement: Native enhancement apply failed type=" + sunderheartType + " tier=" + sunderheartTier + " effect=" + effectId + " result=" + resultText)
        _pendingEnhanceSessionToken = 0
        ClearEnhancementSelectionState()
        return False
    endif
    _pendingEnhanceSessionToken = 0
    String enhanceResultText = GetSunderheartEnhanceResultText()

    BeginSunderheartMenuBlock()
    CloseInventoryForSunderheartAction()
    PlaySunderheartPresentation(player, SUNDERHEART_ITEM_ENHANCED_MENU)
    player.RemoveItem(sunderheartBaseItem, 1, True)
    AwardHeartglass(player, sunderheartType, sunderheartTier)
    RegisterSunderheartUsed(player, sunderheartType, sunderheartTier)
    NotifySunderheartSuccess(IronSoulNative.TextFormat1("Sunderheart.SuccessEnhance", "result", enhanceResultText))

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "CompleteItemEnhancement: Enhanced selected inventory item type=" + sunderheartType + " tier=" + sunderheartTier + " effect=" + effectId + " power=" + effectPower + " cap=" + effectCap + " result=" + enhanceResultText)
    ClearEnhancementSelectionState()
    ReopenInventoryAfterSunderheartAction(True)
    return True
EndFunction

Int Function GetEnhanceEffectForSunderheartType(Int sunderheartType)
    if sunderheartType == SUNDERHEART_TYPE_TONAL
        return SUNDERHEART_EFFECT_TEMPER_GEAR
    endif
    return 0
EndFunction

Int Function ResolveEnhancePowerForEffect(Int effectId, Int sunderheartTier)
    if effectId == SUNDERHEART_EFFECT_TEMPER_GEAR
        return ResolveTemperGearAddLevels(sunderheartTier)
    endif
    return 0
EndFunction

Int Function ResolveEnhanceCapForEffect(Int effectId)
    if effectId == SUNDERHEART_EFFECT_TEMPER_GEAR
        return GetTemperGearMaxLevel()
    endif
    return 0
EndFunction

Int Function GetTemperGearMaxLevel()
    if Controller && Controller.Config
        Int maxTemper = Controller.Config.GetSunderheartTonalMaxTemper()
        if maxTemper >= 1 && maxTemper <= TEMPER_GEAR_CONFIG_MAX_LEVEL
            return maxTemper
        endif
    endif
    return TEMPER_GEAR_MAX_LEVEL
EndFunction

Int Function ResolveTemperGearAddLevels(Int sunderheartTier)
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

Function ClearEnhancementSelectionState()
    ClearSunderheartInventoryBridgeWait()

    if _pendingEnhanceSessionToken > 0
        IronSoulNative.SunderheartReleaseEnhanceSession(_pendingEnhanceSessionToken)
    endif

    _enhanceSelectionActive = False
    _enhanceInventoryBridgeActive = False
    _enhanceInventoryBridgeLoaded = False
    _enhanceInventoryBridgeFailed = False
    _enhanceInventoryBridgeNoRows = False
    _pendingEnhancePlayer = None
    _pendingEnhanceSunderheartBaseItem = None
    _pendingEnhanceSunderheartType = 0
    _pendingEnhanceSunderheartTier = 0
    _pendingEnhanceEffectId = 0
    _pendingEnhanceSessionToken = 0
    _pendingEnhanceSelectedIndex = -1
    _pendingEnhancePower = 0
    _pendingEnhanceCap = TEMPER_GEAR_MAX_LEVEL
EndFunction

Bool Function TryAbsorbAnima(Actor player, String guid, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0)
    if !HasCoreRuntime() || !player || guid == "" || !sunderheartBaseItem
        return False
    endif

    Int tier = Controller.Tiers.GetCurrentTier(player, guid)
    Int itemCount = player.GetItemCount(sunderheartBaseItem)
    if itemCount <= 0
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "TryAbsorbAnima: Player does not have the exact Sunderheart base form")
        Debug.MessageBox(IronSoulNative.TextGet("MessageBox.SunderheartMissingInventory"))
        return False
    endif

    BeginSunderheartMenuBlock()
    player.RemoveItem(sunderheartBaseItem, 1, True)

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryAbsorbAnima: Absorbed Anima using exact Sunderheart type=" + sunderheartType + " tier=" + sunderheartTier + " liveTier=" + tier)

    CloseInventoryForSunderheartAction()
    PlaySunderheartPresentation(player, SUNDERHEART_ANIMA_ABSORBED_MENU)
    AwardHeartglass(player, sunderheartType, sunderheartTier)
    RegisterSunderheartUsed(player, sunderheartType, sunderheartTier)
    NotifySunderheartSuccess(IronSoulNative.TextGet("Sunderheart.SuccessAbsorbAnima"))
    ReopenInventoryAfterSunderheartAction(False)
    return True
EndFunction

Bool Function TryPurgeDeath(Actor player, String guid, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0)
    return TryPurgeDeathResult(player, guid, sunderheartBaseItem, sunderheartType, sunderheartTier) == SUNDERHEART_PURGE_RESULT_SUCCESS
EndFunction

Int Function TryPurgeDeathResult(Actor player, String guid, Form sunderheartBaseItem, Int sunderheartType = 0, Int sunderheartTier = 0)
    if !HasCoreRuntime() || !player || guid == "" || !sunderheartBaseItem
        return SUNDERHEART_PURGE_RESULT_FAILED
    endif

    Int deathsBeforePurge = Controller.Death.GetCurrentDeathCount(player, guid)
    if deathsBeforePurge <= 0
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: No current deaths to purge")
        return SUNDERHEART_PURGE_RESULT_NO_DEATHS
    endif

    Int itemCount = player.GetItemCount(sunderheartBaseItem)
    if itemCount <= 0
        LogSunderhearts(IronSoulConfig.LOG_ERR(), "TryPurgeDeath: Player does not have the exact Sunderheart base form")
        Debug.MessageBox(IronSoulNative.TextGet("MessageBox.SunderheartMissingInventory"))
        return SUNDERHEART_PURGE_RESULT_FAILED
    endif

    BeginSunderheartMenuBlock()
    Int deathsAfterPurge = deathsBeforePurge - 1
    Int tierBeforePurge = Controller.Tiers.GetCurrentTier(player, guid)
    Bool defiantRestoreHandoff = (tierBeforePurge == Controller.Tiers.TIER_DEFIANT && deathsAfterPurge < Controller.Tiers.IRON_SOUL_MAX_LIVES)
    Int defiantRestoreHandoffCursorToken = 0
    if defiantRestoreHandoff
        defiantRestoreHandoffCursorToken = IronSoulNative.BeginCursorSuppress()
    endif

    player.RemoveItem(sunderheartBaseItem, 1, True)
    Controller.Death.SetCurrentDeathCount(player, guid, deathsAfterPurge)

    LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: Purged one death using exact Sunderheart type=" + sunderheartType + " tier=" + sunderheartTier + " deaths=" + deathsBeforePurge + "->" + deathsAfterPurge)

    IronSoulNative.DataFlushIfDirty()

    CloseInventoryForSunderheartAction()
    PlaySunderheartPresentation(player, SUNDERHEART_DEATH_PURGED_MENU, !defiantRestoreHandoff)
    AwardHeartglass(player, sunderheartType, sunderheartTier)
    RegisterSunderheartUsed(player, sunderheartType, sunderheartTier)
    if defiantRestoreHandoff
        UI.CloseCustomMenu()
        IronSoulNative.PrimeCursorSuppress()
        IronSoulNative.RefreshCursorSuppress()
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: Defiant restore handoff started after Sunderheart menu")
    endif
    Bool restoredFromDefiant = Controller.Tiers.TryRestoreFromDefiant(player, guid)
    if defiantRestoreHandoffCursorToken > 0
        IronSoulNative.EndCursorSuppress(defiantRestoreHandoffCursorToken)
    endif
    if defiantRestoreHandoff && !restoredFromDefiant
        Controller.Presentation.RestoreMusic()
        LogSunderhearts(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: Defiant restore handoff fell through; restored music")
    endif
    NotifySunderheartSuccess(IronSoulNative.TextFormat2("Sunderheart.SuccessPurgeDeath", "before", "" + deathsBeforePurge, "after", "" + deathsAfterPurge))
    if !restoredFromDefiant
        ReopenInventoryAfterSunderheartAction(False)
    endif
    return SUNDERHEART_PURGE_RESULT_SUCCESS
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

Function PlaySunderheartPresentation(Actor player, String menuName, Bool restoreMusicAfter = True)
    ClearSunderheartUseIntentState("presentation")
    if !player
        EndSunderheartUseFocus(False)
        EndSunderheartMenuBlock("sunderheart-presentation-skipped")
        BlockSunderheartUseBriefly(SUNDERHEART_USE_REENTRY_COOLDOWN_SECONDS)
        return
    endif
    if Controller && Controller.Config && !Controller.Config.IsSunderheartMenuEnabled()
        _sunderheartPresentationActive = True
        BeginSunderheartPresentationFocusHandoff()
        PlaySunderheartSFX(player)
        EndSunderheartMenuBlock("sunderheart-presentation-complete")
        _sunderheartPresentationActive = False
        BlockSunderheartUseBriefly(SUNDERHEART_USE_REENTRY_COOLDOWN_SECONDS)
        return
    endif
    if menuName == ""
        EndSunderheartUseFocus(False)
        EndSunderheartMenuBlock("sunderheart-presentation-skipped")
        BlockSunderheartUseBriefly(SUNDERHEART_USE_REENTRY_COOLDOWN_SECONDS)
        return
    endif

    _sunderheartPresentationActive = True
    Int cursorToken = IronSoulNative.BeginCursorSuppress()
    Controller.Presentation.FadeMusicForTransitionSequence()
    CloseSunderheartCustomMenuAndWait("presentation-open", SUNDERHEART_CUSTOM_MENU_CLOSE_WAIT_SECONDS)
    IronSoulNative.RefreshCursorSuppress()
    BeginSunderheartPresentationFocusHandoff()
    PlaySunderheartSFX(player)
    UI.OpenCustomMenu(menuName, 0)
    IronSoulNative.RefreshCursorSuppress()
    ; PlaySunderheartSFX(player)
    Controller.Presentation.WaitKeyDismissMenu(SUNDERHEART_PRESENTATION_MAX_SECONDS, SUNDERHEART_PRESENTATION_DISMISS_SECONDS)
    IronSoulNative.EndCursorSuppress(cursorToken)
    if restoreMusicAfter
        Controller.Presentation.RestoreMusic()
    endif
    EndSunderheartMenuBlock("sunderheart-presentation-complete")
    _sunderheartPresentationActive = False
    BlockSunderheartUseBriefly(SUNDERHEART_USE_REENTRY_COOLDOWN_SECONDS)
EndFunction

Function PlaySunderheartSFX(Actor player)
    if !player || !SFXSunderheartAbsorb
        return
    endif
    if !Controller || !Controller.Config
        return
    endif
    if IronSoulSFX.CanPlaySFX(Controller.Config.IsSFXEnabled(), Controller.Config.IsUninstallMode(), Controller.IsModDisabled()) && Controller.Config.IsSunderheartAbsorbSFXEnabled()
        IronSoulNative.AudioPlay(SFXSunderheartAbsorb, player, 1.0, "sunderheart-absorb-sfx")
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
        ClearSunderheartUseIntentState("inventory-close")
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
    ConfigureSunderheartUseIntentCapture()
    if !CanPlaySunderheartFocusSFX()
        IronSoulNative.SunderheartFocusStopImmediate()
        return False
    endif
    Bool configured = IronSoulNative.SunderheartFocusConfigure(SFXSunderheartFocusLoop)
    if configured
        IronSoulNative.SunderheartFocusConfigureInventoryHover(SunderheartTier1List, SunderheartTier2List, SunderheartTier3List, SunderheartTier4List, SunderheartTier5List, SunderheartSpent)
    endif
    return configured
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
    ClearSunderheartInventoryHoverSuppression()
EndFunction

Function EndSunderheartUseFocus(Bool immediate = False, Bool preserveHover = False, Bool cancelClear = False)
    if _sunderheartUseFocusSFX || _sunderheartActionChoiceFocusSFX || _sunderheartInventoryHoverFocusSFX
        LogSunderhearts(IronSoulConfig.LOG_DBG(), "EndSunderheartUseFocus: immediate=" + immediate + " preserveHover=" + preserveHover + " cancelClear=" + cancelClear + " useVolume=" + _sunderheartUseFocusVolume, True)
    endif

    _sunderheartUseFocusSFX = False
    _sunderheartUseFocusVolume = 0.0
    _sunderheartActionChoiceFocusSFX = False
    _sunderheartActionChoiceFocusVolume = 0.0

    if cancelClear
        preserveHover = False
    endif

    if immediate
        ClearSunderheartInventoryHoverSuppression()
        ClearSunderheartInventoryHover()
        IronSoulNative.SunderheartFocusClearActionTarget()
        IronSoulNative.SunderheartFocusClearUseTarget(True)
    else
        if preserveHover
            ClearSunderheartInventoryHoverSuppression()
        else
            SuppressSunderheartInventoryHover()
        endif
        if cancelClear
            IronSoulNative.SunderheartFocusClearCancelTargets()
        else
            IronSoulNative.SunderheartFocusClearActionTarget()
            IronSoulNative.SunderheartFocusClearUseTarget(False)
        endif
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
    Int tier = ResolveSunderheartTierForForm(selectedForm)
    return ResolveSunderheartFocusVolumeForTier(tier)
EndFunction

Int Function ResolveSunderheartTierForForm(Form selectedForm)
    if !selectedForm || selectedForm == SunderheartSpent
        return 0
    endif
    if SunderheartTier5List && SunderheartTier5List.HasForm(selectedForm)
        return 5
    elseif SunderheartTier4List && SunderheartTier4List.HasForm(selectedForm)
        return 4
    elseif SunderheartTier3List && SunderheartTier3List.HasForm(selectedForm)
        return 3
    elseif SunderheartTier2List && SunderheartTier2List.HasForm(selectedForm)
        return 2
    elseif SunderheartTier1List && SunderheartTier1List.HasForm(selectedForm)
        return 1
    endif
    return 0
EndFunction

Int Function ResolveSunderheartTypeForBaseForm(Form baseItem)
    if ResolveSunderheartTierForForm(baseItem) > 0
        return SUNDERHEART_TYPE_TONAL
    endif
    return 0
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
