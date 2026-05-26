Scriptname IronSoulHeartstones extends Quest

; Heartstones
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
; of Bthanchend. Thendas describes a red stone suspended in a Dwemer receiving
; frame, warm though the chamber was cold, and sounding faintly when touched.
; The instrument around it had been ruined, as though by a single pressure from
; within rather than by age, looters, or war.
;
; During the survey, a brass armature collapsed and slew one of Thendas's
; companions. The account insists upon the freshness of the death: the blood had
; not darkened, the eyes had not clouded, and the body still gave up heat. When
; the red stone was dislodged from its frame and fell against the corpse, it
; flared once, bright enough to stain the chamber walls. Its color then vanished
; into the dead flesh as if drawn through a wound. The stone fell clear and cold
; to the floor. The dead mer convulsed, drew breath, and rose.
;
; This was no lingering twitch. Thendas reports that the revived surveyor stood,
; recognized his companions, and answered to his name. He remained alive for
; nearly an hour, though greatly weakened and troubled by the sound of "a red
; bell beneath the world." Thereafter he suffered a second collapse and could
; not be recalled. Thendas later describes the spent stone as clear, cold, and
; without sound.
;
; Temple commentators dismiss the account as grief, vapor, or Dwemer poisoning.
; I am less certain. A fraud would have given us a clean miracle. Thendas gives
; us an accident, a ruined instrument, a temporary restoration, and a corpse
; that had only just begun to leave itself.
;
; If the account is not wholly false, then the stone did not act as a soul gem.
; It did not claim the animus as property, nor draw it away for expenditure.
; Rather, it appears to have interrupted departure at the narrowest point: after
; bodily death, but before the soul's relation to the body had fully failed. The
; result was not necromancy, for the body was not animated by an exterior will.
; It was the same mer, returned briefly to the same flesh.
;
; This suggests that the object was not a vessel in the usual sense, but a point
; of sympathy between mortal dissolution and some older injury in the world. The
; Dwemer frame may not have created the stone. It may only have received it, or
; taught common matter to answer a pressure already present.
;
; I therefore propose the term heartstone for such an artifact: not because it
; is a literal heart, nor because it is broken from any known relic, but because
; it behaves as a heart behaves at the instant before stillness. It holds. It
; refuses. It remembers the body.
;
; The analogy to the sigil stone is tempting but imperfect. A sigil stone
; impresses an exterior will upon a prepared morpholith, making a gate where no
; gate should be. A heartstone, if such things exist, would be its mortal
; contrary: not a door opened outward, but a door prevented from closing.
;
; What pressure could produce such a thing? Here one must speak carefully. The
; disturbance at Red Mountain, the vanished Dwemer, and the old stories of the
; Missing God all occupy the same forbidden neighborhood of thought. It may be
; that, when a divine wound was struck like a bell, certain prepared places
; heard the note. Bthanchend may have been one such place.
;
; If so, the heartstone is not a fragment in the vulgar sense. It is an event
; made mineral. A red witness to the proposition that death, like Mundus itself,
; was never perfectly finished.

IronSoulController Property Controller Auto
MiscObject Property HeartstoneSpent Auto

; Expected MESG EditorIDs:
; - IronSoul_HeartstoneMsg: Enhance Item, Purge Death, Lower Heartstone.
; - IronSoul_HeartstoneEnhanceOnlyMsg: Enhance Item, Lower Heartstone.
; - IronSoul_HeartstonePurgeOnlyMsg: Purge Death, Lower Heartstone.
; - IronSoul_HeartstoneUnavailableMsg: Lower Heartstone.
Message Property HeartstoneMsg Auto
Message Property HeartstoneEnhanceOnlyMsg Auto
Message Property HeartstonePurgeOnlyMsg Auto
Message Property HeartstoneUnavailableMsg Auto
Sound Property SFXHeartstoneAbsorb Auto

Int HEARTSTONE_TYPE_TONAL = 1
Int HEARTSTONE_EFFECT_TONAL = 1
Int HEARTSTONE_INVENTORY_MODE_LEGACY = 0
Int HEARTSTONE_INVENTORY_MODE_REOPEN = 1
Int HEARTSTONE_INVENTORY_MODE_CLOSE = 2
Int HEARTSTONE_INVENTORY_MODE_MIXED = 3
String HEARTSTONE_ITEM_ENHANCED_MENU = "heartstoneitemenhanced"
String HEARTSTONE_DEATH_PURGED_MENU = "heartstonedeathpurged"
String HEARTSTONE_INVENTORY_MENU = "InventoryMenu"
String HEARTSTONE_ITEM_SELECT_SWF = "ironsoul_itemselect"
String HEARTSTONE_ITEM_SELECT_ROOT = "_root.ironsoul_itemselect.ItemSelect_mc"
String HEARTSTONE_ITEM_SELECT_LOAD_EVENT = "IronSoul_ItemSelect_Load"
String HEARTSTONE_ITEM_SELECT_SELECT_EVENT = "IronSoul_ItemSelect_Select"
Float HEARTSTONE_PRESENTATION_MAX_SECONDS = 8.0
Float HEARTSTONE_PRESENTATION_DISMISS_SECONDS = 2.0
Int TONAL_TEMPER_MAX_LEVEL = 10
Int TONAL_TEMPER_CONFIG_MAX_LEVEL = 100
Int TONAL_RESULT_ALREADY_CAPPED = 4
Int TONAL_RESULT_AMBIGUOUS_STACK = 10

Bool _handlingUse = False
Bool _tonalSelectionActive = False
Bool _tonalItemSelectActive = False
Bool _tonalItemSelectLoaded = False
Bool _tonalItemSelectFailed = False
Bool _tonalItemSelectNoRows = False
Actor _pendingTonalPlayer = None
Form _pendingTonalHeartstoneBaseItem = None
Int _pendingTonalHeartstoneType = 0
Int _pendingTonalHeartstoneTier = 0
Int _pendingTonalSessionToken = 0
Int _pendingTonalSelectedIndex = -1
Int _pendingTonalMaxTemper = 10

Function ResetTransientState()
    _handlingUse = False
    ClearTonalEnhancementState()
EndFunction

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Identity || !Controller.Death || !Controller.Tiers || !Controller.Presentation
        return False
    endif
    return True
EndFunction

Function LogHeartstones(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("Heartstones", level, msg, suppressNotify)
        return
    endif

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [" + levelText + "] [Heartstones] " + msg)
EndFunction

Int Function GetHeartstoneInventoryMode()
    if Controller && Controller.Config
        Int mode = Controller.Config.GetHeartstoneInventoryMode()
        if mode >= HEARTSTONE_INVENTORY_MODE_LEGACY && mode <= HEARTSTONE_INVENTORY_MODE_MIXED
            return mode
        endif
    endif
    return HEARTSTONE_INVENTORY_MODE_REOPEN
EndFunction

Bool Function ShouldCloseInventoryForHeartstoneAction()
    Int mode = GetHeartstoneInventoryMode()
    if mode == HEARTSTONE_INVENTORY_MODE_REOPEN || mode == HEARTSTONE_INVENTORY_MODE_CLOSE || mode == HEARTSTONE_INVENTORY_MODE_MIXED
        return True
    endif
    return False
EndFunction

Bool Function ShouldReopenInventoryAfterHeartstoneAction(Bool enhanceAction)
    Int mode = GetHeartstoneInventoryMode()
    if mode == HEARTSTONE_INVENTORY_MODE_REOPEN
        return True
    elseif mode == HEARTSTONE_INVENTORY_MODE_MIXED
        return enhanceAction
    endif
    return False
EndFunction

Function CloseInventoryForHeartstoneAction()
    if !ShouldCloseInventoryForHeartstoneAction()
        return
    endif
    if !UI.IsMenuOpen(HEARTSTONE_INVENTORY_MENU)
        return
    endif

    UI.InvokeString("HUD Menu", "_global.skse.CloseMenu", HEARTSTONE_INVENTORY_MENU)
    Utility.WaitMenuMode(0.2)
EndFunction

Function ReopenInventoryAfterHeartstoneAction(Bool enhanceAction)
    if !ShouldReopenInventoryAfterHeartstoneAction(enhanceAction)
        return
    endif
    if UI.IsMenuOpen(HEARTSTONE_INVENTORY_MENU)
        return
    endif

    UI.InvokeString("HUD Menu", "_global.skse.OpenMenu", HEARTSTONE_INVENTORY_MENU)
    Utility.WaitMenuMode(0.1)
EndFunction

String Function GetHeartstoneEnhanceResultText()
    String resultText = IronSoulNative.HeartstoneGetEnhanceResultText()
    if resultText == ""
        return "Unknown Heartstone enhancement failure"
    endif
    return resultText
EndFunction

Function NotifyHeartstoneEnhanceFailure(Bool applyFailure = False)
    Int result = IronSoulNative.HeartstoneGetEnhanceResult()
    if result == TONAL_RESULT_ALREADY_CAPPED
        Debug.Notification("The Heartstone cannot strengthen that item further.")
    elseif result == TONAL_RESULT_AMBIGUOUS_STACK
        Debug.Notification("The Heartstone cannot choose between matching items.")
    elseif applyFailure
        Debug.Notification("The Heartstone failed to strengthen that item.")
    else
        Debug.Notification("The Heartstone cannot strengthen that item.")
    endif
EndFunction

Function NotifyHeartstoneSuccess(String msg)
    if msg == ""
        return
    endif
    if Controller && Controller.Config && !Controller.Config.IsHeartstoneNotificationEnabled()
        return
    endif

    Debug.Notification(msg)
EndFunction

Bool Function TryUseHeartstone(Actor player, Form heartstoneBaseItem, Int heartstoneType = 0, Int heartstoneTier = 0)
    Bool result = False

    if !HasCoreRuntime() || !player || !heartstoneBaseItem
        return False
    endif
    if player != Game.GetPlayer()
        return False
    endif
    if _handlingUse
        return False
    endif

    _handlingUse = True

    String guid = Controller.Identity.GetTickGuid(player)
    if guid == ""
        LogHeartstones(IronSoulConfig.LOG_ERR(), "TryUseHeartstone: Could not resolve player GUID")
    else
        Int deaths = Controller.Death.GetCurrentDeathCount(player, guid)
        if deaths > 0
            result = ShowUseChoice(player, guid, heartstoneBaseItem, heartstoneType, heartstoneTier)
        else
            result = ShowEnhanceOnlyChoice(player, heartstoneBaseItem, heartstoneType, heartstoneTier)
        endif
    endif

    Utility.WaitMenuMode(0.2)
    _handlingUse = False
    return result
EndFunction

Bool Function ShowUseChoice(Actor player, String guid, Form heartstoneBaseItem, Int heartstoneType = 0, Int heartstoneTier = 0)
    if HeartstoneMsg
        Int choice = HeartstoneMsg.Show()
        if choice == 0
            return TryEnhanceItem(player, heartstoneBaseItem, heartstoneType, heartstoneTier)
        elseif choice == 1
            return TryPurgeDeath(player, guid, heartstoneBaseItem, heartstoneType, heartstoneTier)
        endif

        LogHeartstones(IronSoulConfig.LOG_INFO(), "ShowUseChoice: Heartstone lowered")
        return False
    endif

    if HeartstonePurgeOnlyMsg
        return ShowPurgeOnlyChoice(player, guid, heartstoneBaseItem, heartstoneType, heartstoneTier)
    endif
    if HeartstoneEnhanceOnlyMsg
        return ShowEnhanceOnlyChoice(player, heartstoneBaseItem, heartstoneType, heartstoneTier)
    endif

    Debug.MessageBox("Heartstone choices are not configured.")
    return False
EndFunction

Bool Function ShowEnhanceOnlyChoice(Actor player, Form heartstoneBaseItem, Int heartstoneType = 0, Int heartstoneTier = 0)
    if HeartstoneEnhanceOnlyMsg
        Int choice = HeartstoneEnhanceOnlyMsg.Show()
        if choice == 0
            return TryEnhanceItem(player, heartstoneBaseItem, heartstoneType, heartstoneTier)
        endif

        LogHeartstones(IronSoulConfig.LOG_INFO(), "ShowEnhanceOnlyChoice: Heartstone lowered")
        return False
    endif

    return ShowEnhanceUnavailable(player, heartstoneType, heartstoneTier)
EndFunction

Bool Function ShowPurgeOnlyChoice(Actor player, String guid, Form heartstoneBaseItem, Int heartstoneType = 0, Int heartstoneTier = 0)
    if HeartstonePurgeOnlyMsg
        Int choice = HeartstonePurgeOnlyMsg.Show()
        if choice == 0
            return TryPurgeDeath(player, guid, heartstoneBaseItem, heartstoneType, heartstoneTier)
        endif

        LogHeartstones(IronSoulConfig.LOG_INFO(), "ShowPurgeOnlyChoice: Heartstone lowered")
        return False
    endif

    Debug.MessageBox("Heartstone purge choices are not configured.")
    return False
EndFunction

Bool Function TryEnhanceItem(Actor player, Form heartstoneBaseItem, Int heartstoneType = 0, Int heartstoneTier = 0)
    if heartstoneType == HEARTSTONE_TYPE_TONAL
        return TryEnhanceTonalItem(player, heartstoneBaseItem, heartstoneType, heartstoneTier)
    endif

    LogHeartstones(IronSoulConfig.LOG_INFO(), "TryEnhanceItem: Enhancement unavailable type=" + heartstoneType + " tier=" + heartstoneTier)
    return ShowEnhanceUnavailable(player, heartstoneType, heartstoneTier)
EndFunction

Bool Function TryEnhanceTonalItem(Actor player, Form heartstoneBaseItem, Int heartstoneType = 0, Int heartstoneTier = 0)
    if !HasCoreRuntime() || !player || !heartstoneBaseItem
        return False
    endif
    if player.GetItemCount(heartstoneBaseItem) <= 0
        LogHeartstones(IronSoulConfig.LOG_ERR(), "TryEnhanceTonalItem: Player does not have the exact Tonal Heartstone base form")
        Debug.MessageBox("The Heartstone is no longer in your inventory.")
        return False
    endif

    Int addLevels = ResolveTonalAddLevels(heartstoneTier)
    Int maxTemper = GetTonalMaxTemperLevel()
    Int sessionToken = IronSoulNative.HeartstoneBuildEnhanceSession(HEARTSTONE_EFFECT_TONAL, addLevels, maxTemper)
    if sessionToken <= 0
        String buildFailureText = GetHeartstoneEnhanceResultText()
        Debug.Notification("The Heartstone finds no eligible weapon or armor to strengthen.")
        LogHeartstones(IronSoulConfig.LOG_INFO(), "TryEnhanceTonalItem: No Tonal enhancement options type=" + heartstoneType + " tier=" + heartstoneTier + " maxTemper=" + maxTemper + " result=" + buildFailureText)
        return False
    endif

    if !StartTonalEnhancementState(player, heartstoneBaseItem, heartstoneType, heartstoneTier, sessionToken, maxTemper)
        IronSoulNative.HeartstoneReleaseEnhanceSession(sessionToken)
        return False
    endif

    Int selectedIndex = ShowHeartstoneEnhanceList(sessionToken)
    if selectedIndex < 0
        LogHeartstones(IronSoulConfig.LOG_INFO(), "TryEnhanceTonalItem: Tonal enhancement selection canceled type=" + heartstoneType + " tier=" + heartstoneTier)
        ClearTonalEnhancementState()
        return False
    endif

    _pendingTonalSelectedIndex = selectedIndex
    return CompleteTonalEnhancement()
EndFunction

Bool Function StartTonalEnhancementState(Actor player, Form heartstoneBaseItem, Int heartstoneType, Int heartstoneTier, Int sessionToken, Int maxTemper)
    ClearTonalEnhancementState()

    _tonalSelectionActive = True
    _pendingTonalPlayer = player
    _pendingTonalHeartstoneBaseItem = heartstoneBaseItem
    _pendingTonalHeartstoneType = heartstoneType
    _pendingTonalHeartstoneTier = heartstoneTier
    _pendingTonalSessionToken = sessionToken
    _pendingTonalSelectedIndex = -1
    _pendingTonalMaxTemper = maxTemper

    LogHeartstones(IronSoulConfig.LOG_INFO(), "StartTonalEnhancementState: Started Tonal filtered item selection tier=" + heartstoneTier + " maxTemper=" + maxTemper + " session=" + sessionToken)
    return True
EndFunction

Int Function ShowHeartstoneEnhanceList(Int sessionToken)
    Int optionCount = IronSoulNative.HeartstoneGetEnhanceSessionOptionCount(sessionToken)
    if optionCount <= 0
        return -1
    endif

    _tonalItemSelectActive = True
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
    _pendingTonalSelectedIndex = -1
    RegisterForModEvent(HEARTSTONE_ITEM_SELECT_LOAD_EVENT, "OnIronSoul_ItemSelect_Load")
    RegisterForModEvent(HEARTSTONE_ITEM_SELECT_SELECT_EVENT, "OnIronSoul_ItemSelect_Select")

    Bool inventoryWasOpen = UI.IsMenuOpen(HEARTSTONE_INVENTORY_MENU)
    if !inventoryWasOpen && !IronSoulNative.OpenMenu(HEARTSTONE_INVENTORY_MENU)
        LogHeartstones(IronSoulConfig.LOG_ERR(), "ShowHeartstoneEnhanceList: InventoryMenu could not be queued")
        ClearHeartstoneItemSelectWait()
        Debug.MessageBox("The Heartstone selection menu is not available.")
        return -1
    endif

    Float waited = 0.0
    while !UI.IsMenuOpen(HEARTSTONE_INVENTORY_MENU) && waited < 2.0
        Utility.WaitMenuMode(0.1)
        waited += 0.1
    endwhile

    if !UI.IsMenuOpen(HEARTSTONE_INVENTORY_MENU)
        LogHeartstones(IronSoulConfig.LOG_ERR(), "ShowHeartstoneEnhanceList: InventoryMenu did not open")
        ClearHeartstoneItemSelectWait()
        Debug.MessageBox("The Heartstone selection menu is not available.")
        return -1
    endif

    InjectHeartstoneItemSelect()

    waited = 0.0
    while UI.IsMenuOpen(HEARTSTONE_INVENTORY_MENU) && !_tonalItemSelectLoaded && !_tonalItemSelectFailed && waited < 2.0
        Utility.WaitMenuMode(0.1)
        waited += 0.1
    endwhile

    if !_tonalItemSelectLoaded || _tonalItemSelectFailed
        Bool noEligibleRows = _tonalItemSelectNoRows
        if noEligibleRows
            LogHeartstones(IronSoulConfig.LOG_INFO(), "ShowHeartstoneEnhanceList: Iron Soul item select found no eligible rows session=" + sessionToken)
        else
            LogHeartstones(IronSoulConfig.LOG_ERR(), "ShowHeartstoneEnhanceList: Iron Soul item select failed to load session=" + sessionToken + " loaded=" + _tonalItemSelectLoaded + " failed=" + _tonalItemSelectFailed)
        endif
        if !inventoryWasOpen
            IronSoulNative.CloseMenu(HEARTSTONE_INVENTORY_MENU)
        endif
        ClearHeartstoneItemSelectWait()
        if !noEligibleRows
            Debug.MessageBox("The Heartstone selection menu is not available.")
        endif
        return -1
    endif

    while UI.IsMenuOpen(HEARTSTONE_INVENTORY_MENU) && _pendingTonalSelectedIndex < 0 && !_tonalItemSelectFailed
        Utility.WaitMenuMode(0.1)
    endwhile

    ClearHeartstoneItemSelectWait()
    return _pendingTonalSelectedIndex
EndFunction

Function InjectHeartstoneItemSelect()
    String[] args = new String[2]
    args[0] = HEARTSTONE_ITEM_SELECT_SWF
    args[1] = Utility.RandomInt(1000, 10000)
    UI.InvokeStringA(HEARTSTONE_INVENTORY_MENU, "_root.createEmptyMovieClip", args)
    UI.InvokeString(HEARTSTONE_INVENTORY_MENU, "_root." + HEARTSTONE_ITEM_SELECT_SWF + ".loadMovie", HEARTSTONE_ITEM_SELECT_SWF + ".swf")
EndFunction

Function ClearHeartstoneItemSelectWait()
    UnregisterForModEvent(HEARTSTONE_ITEM_SELECT_LOAD_EVENT)
    UnregisterForModEvent(HEARTSTONE_ITEM_SELECT_SELECT_EVENT)
    _tonalItemSelectActive = False
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
EndFunction

Event OnIronSoul_ItemSelect_Load(String eventName, String strArg, Float numArg, Form formArg)
    if !_tonalItemSelectActive
        return
    endif

    String serializedRows = IronSoulNative.HeartstoneRefreshEnhanceSessionInventoryRows(_pendingTonalSessionToken)
    if serializedRows == ""
        String resultText = GetHeartstoneEnhanceResultText()
        _tonalItemSelectFailed = True
        _tonalItemSelectNoRows = True
        LogHeartstones(IronSoulConfig.LOG_INFO(), "OnIronSoul_ItemSelect_Load: No eligible InventoryMenu rows session=" + _pendingTonalSessionToken + " result=" + resultText)
        Debug.Notification("The Heartstone finds no eligible weapon or armor to strengthen.")
        IronSoulNative.CloseMenu(HEARTSTONE_INVENTORY_MENU)
        return
    endif

    UI.InvokeString(HEARTSTONE_INVENTORY_MENU, HEARTSTONE_ITEM_SELECT_ROOT + ".setAllowedRows", serializedRows)
    _tonalItemSelectLoaded = True
EndEvent

Event OnIronSoul_ItemSelect_Select(String eventName, String strArg, Float numArg, Form formArg)
    if !_tonalItemSelectActive
        return
    endif

    _pendingTonalSelectedIndex = numArg as Int
    IronSoulNative.CloseMenu(HEARTSTONE_INVENTORY_MENU)
EndEvent

Bool Function CompleteTonalEnhancement()
    Actor player = _pendingTonalPlayer
    Form heartstoneBaseItem = _pendingTonalHeartstoneBaseItem
    Int heartstoneType = _pendingTonalHeartstoneType
    Int heartstoneTier = _pendingTonalHeartstoneTier
    Int sessionToken = _pendingTonalSessionToken
    Int selectedIndex = _pendingTonalSelectedIndex
    Int maxTemper = _pendingTonalMaxTemper
    Int addLevels = ResolveTonalAddLevels(heartstoneTier)

    if !player || !heartstoneBaseItem || sessionToken <= 0 || selectedIndex < 0
        ClearTonalEnhancementState()
        return False
    endif

    if player.GetItemCount(heartstoneBaseItem) <= 0
        LogHeartstones(IronSoulConfig.LOG_ERR(), "CompleteTonalEnhancement: Player no longer has exact Tonal Heartstone base form")
        Debug.MessageBox("The Heartstone is no longer in your inventory.")
        ClearTonalEnhancementState()
        return False
    endif

    Bool enhanced = IronSoulNative.HeartstoneApplyEnhanceSessionInventoryRow(sessionToken, selectedIndex)
    if !enhanced
        String resultText = GetHeartstoneEnhanceResultText()
        NotifyHeartstoneEnhanceFailure(True)
        LogHeartstones(IronSoulConfig.LOG_ERR(), "CompleteTonalEnhancement: Native Tonal apply failed type=" + heartstoneType + " tier=" + heartstoneTier + " result=" + resultText)
        _pendingTonalSessionToken = 0
        ClearTonalEnhancementState()
        return False
    endif
    _pendingTonalSessionToken = 0
    String enhanceResultText = GetHeartstoneEnhanceResultText()

    CloseInventoryForHeartstoneAction()
    PlayItemEnhancedPresentation(player)
    player.RemoveItem(heartstoneBaseItem, 1, True)
    AwardHeartglass(player, heartstoneType, heartstoneTier)
    NotifyHeartstoneSuccess("Tonal Heartstone strengthened " + enhanceResultText)

    LogHeartstones(IronSoulConfig.LOG_INFO(), "CompleteTonalEnhancement: Enhanced selected inventory item with Tonal Heartstone type=" + heartstoneType + " tier=" + heartstoneTier + " addLevels=" + addLevels + " maxLevel=" + maxTemper + " result=" + enhanceResultText)
    ClearTonalEnhancementState()
    ReopenInventoryAfterHeartstoneAction(True)
    return True
EndFunction

Int Function GetTonalMaxTemperLevel()
    if Controller && Controller.Config
        Int maxTemper = Controller.Config.GetHeartstoneTonalMaxTemper()
        if maxTemper >= 1 && maxTemper <= TONAL_TEMPER_CONFIG_MAX_LEVEL
            return maxTemper
        endif
    endif
    return TONAL_TEMPER_MAX_LEVEL
EndFunction

Int Function ResolveTonalAddLevels(Int heartstoneTier)
    if heartstoneTier <= 1
        return 1
    elseif heartstoneTier == 2
        return 2
    elseif heartstoneTier == 3
        return 3
    elseif heartstoneTier == 4
        return 4
    endif
    return 5
EndFunction

Function ClearTonalEnhancementState()
    UnregisterForModEvent(HEARTSTONE_ITEM_SELECT_LOAD_EVENT)
    UnregisterForModEvent(HEARTSTONE_ITEM_SELECT_SELECT_EVENT)

    if _pendingTonalSessionToken > 0
        IronSoulNative.HeartstoneReleaseEnhanceSession(_pendingTonalSessionToken)
    endif

    _tonalSelectionActive = False
    _tonalItemSelectActive = False
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
    _pendingTonalPlayer = None
    _pendingTonalHeartstoneBaseItem = None
    _pendingTonalHeartstoneType = 0
    _pendingTonalHeartstoneTier = 0
    _pendingTonalSessionToken = 0
    _pendingTonalSelectedIndex = -1
    _pendingTonalMaxTemper = TONAL_TEMPER_MAX_LEVEL
EndFunction

Bool Function ShowEnhanceUnavailable(Actor player, Int heartstoneType = 0, Int heartstoneTier = 0)
    if HeartstoneUnavailableMsg
        HeartstoneUnavailableMsg.Show()
    else
        Debug.MessageBox("Heartstone item enhancement is not implemented yet.")
    endif

    LogHeartstones(IronSoulConfig.LOG_INFO(), "ShowEnhanceUnavailable: Enhancement unavailable shown type=" + heartstoneType + " tier=" + heartstoneTier)
    return False
EndFunction

Bool Function TryPurgeDeath(Actor player, String guid, Form heartstoneBaseItem, Int heartstoneType = 0, Int heartstoneTier = 0)
    if !HasCoreRuntime() || !player || guid == "" || !heartstoneBaseItem
        return False
    endif

    Int deathsBeforePurge = Controller.Death.GetCurrentDeathCount(player, guid)
    if deathsBeforePurge <= 0
        LogHeartstones(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: No current deaths to purge")
        return False
    endif

    Int itemCount = player.GetItemCount(heartstoneBaseItem)
    if itemCount <= 0
        LogHeartstones(IronSoulConfig.LOG_ERR(), "TryPurgeDeath: Player does not have the exact Heartstone base form")
        Debug.MessageBox("The Heartstone is no longer in your inventory.")
        return False
    endif

    Int deathsAfterPurge = deathsBeforePurge - 1
    player.RemoveItem(heartstoneBaseItem, 1, True)
    Controller.Death.SetCurrentDeathCount(player, guid, deathsAfterPurge)

    LogHeartstones(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: Purged one death using exact Heartstone type=" + heartstoneType + " tier=" + heartstoneTier + " deaths=" + deathsBeforePurge + "->" + deathsAfterPurge)

    IronSoulNative.DataFlushIfDirty()

    CloseInventoryForHeartstoneAction()
    PlayDeathPurgedPresentation(player)
    AwardHeartglass(player, heartstoneType, heartstoneTier)
    Controller.Tiers.TryRestoreFromDefiant(player, guid)
    NotifyHeartstoneSuccess("The Heartstone purges one death. Deaths: " + deathsBeforePurge + " -> " + deathsAfterPurge)
    ReopenInventoryAfterHeartstoneAction(False)
    return True
EndFunction

Function AwardHeartglass(Actor player, Int heartstoneType = 0, Int heartstoneTier = 0)
    if !player
        return
    endif
    if !HeartstoneSpent
        LogHeartstones(IronSoulConfig.LOG_ERR(), "AwardHeartglass: HeartstoneSpent property is not wired")
        return
    endif

    player.AddItem(HeartstoneSpent, 1, False)
    LogHeartstones(IronSoulConfig.LOG_INFO(), "AwardHeartglass: Awarded Heartglass for spent Heartstone type=" + heartstoneType + " tier=" + heartstoneTier)
EndFunction

Function PlayDeathPurgedPresentation(Actor player)
    PlayHeartstonePresentation(player, HEARTSTONE_DEATH_PURGED_MENU)
EndFunction

Function PlayItemEnhancedPresentation(Actor player)
    PlayHeartstonePresentation(player, HEARTSTONE_ITEM_ENHANCED_MENU)
EndFunction

Function PlayHeartstonePresentation(Actor player, String menuName)
    if !player
        return
    endif
    if Controller && Controller.Config && !Controller.Config.IsHeartstoneMessageEnabled()
        PlayHeartstoneSFX(player)
        return
    endif
    if menuName == ""
        return
    endif

    Controller.Presentation.FadeMusicForTransitionSequence()
    UI.CloseCustomMenu()
    UI.OpenCustomMenu(menuName, 0)
    PlayHeartstoneSFX(player)
    Controller.Presentation.WaitKeyDismissMenu(HEARTSTONE_PRESENTATION_MAX_SECONDS, HEARTSTONE_PRESENTATION_DISMISS_SECONDS)
    Controller.Presentation.RestoreMusic()
EndFunction

Function PlayHeartstoneSFX(Actor player)
    if !player || !SFXHeartstoneAbsorb
        return
    endif
    if !Controller || !Controller.Config
        return
    endif
    if IronSoulSFX.CanPlaySFX(Controller.Config.IsSFXEnabled(), Controller.Config.IsUninstallMode(), Controller.IsModDisabled()) && Controller.Config.IsHeartstoneAbsorbSFXEnabled()
        SFXHeartstoneAbsorb.Play(player)
    endif
EndFunction
