Scriptname IronSoulShardhearts extends Quest

; Shardhearts
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
; I therefore use the term shardheart with some reluctance. It is not meant to
; certify that the orb is a literal fragment of any relic a miner could have held.
; It is meant to name a suspicion: that some force once bound to the Heart
; beneath Red Mountain was scattered, refracted, or made local by the disaster
; there. If this is so, these orbs are not fragments in the vulgar sense. They
; are splinters of consequence, small mineral survivals of a pressure that
; should have ended where it began.
;
; The analogy to the Daedric sigil is tempting but imperfect. Such a sigil
; impresses an exterior will upon a prepared morpholith, making a gate where no
; gate should be. A shardheart, if such things exist, would be its mortal
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
; If so, the shardheart is not a fragment in the vulgar sense. It is an event
; made mineral. A red witness to the proposition that death, like Mundus itself,
; was never perfectly finished.

IronSoulController Property Controller Auto
MiscObject Property ShardheartSpent Auto
String Property shardheartsTotal = "IS_2740" AutoReadOnly ; Account-wide successful Shardheart use counter.
String Property shardheartUsedPrefix = "SH.U." AutoReadOnly ; Account-wide boolean used catalog prefix.

; Expected MESG EditorIDs:
; - IronSoul_ShardheartMsg: Enhance Item, Purge Death, Lower Shardheart.
; - IronSoul_ShardheartEnhanceOnlyMsg: Enhance Item, Lower Shardheart.
; - IronSoul_ShardheartPurgeOnlyMsg: Purge Death, Lower Shardheart.
; - IronSoul_ShardheartUnavailableMsg: Lower Shardheart.
Message Property ShardheartMsg Auto
Message Property ShardheartEnhanceOnlyMsg Auto
Message Property ShardheartPurgeOnlyMsg Auto
Message Property ShardheartUnavailableMsg Auto
Sound Property SFXShardheartAbsorb Auto

Int SHARDHEART_TYPE_TONAL = 1
Int SHARDHEART_EFFECT_TONAL = 1
Int SHARDHEART_INVENTORY_MODE_LEGACY = 0
Int SHARDHEART_INVENTORY_MODE_REOPEN = 1
Int SHARDHEART_INVENTORY_MODE_CLOSE = 2
Int SHARDHEART_INVENTORY_MODE_MIXED = 3
String SHARDHEART_ITEM_ENHANCED_MENU = "shardheartitemenhanced"
String SHARDHEART_DEATH_PURGED_MENU = "shardheartdeathpurged"
String SHARDHEART_INVENTORY_MENU = "InventoryMenu"
String SHARDHEART_ITEM_SELECT_SWF = "ironsoul_itemselect"
String SHARDHEART_ITEM_SELECT_ROOT = "_root.ironsoul_itemselect.ItemSelect_mc"
String SHARDHEART_ITEM_SELECT_LOAD_EVENT = "IronSoul_ItemSelect_Load"
String SHARDHEART_ITEM_SELECT_SELECT_EVENT = "IronSoul_ItemSelect_Select"
Float SHARDHEART_PRESENTATION_MAX_SECONDS = 8.0
Float SHARDHEART_PRESENTATION_DISMISS_SECONDS = 2.0
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
Form _pendingTonalShardheartBaseItem = None
Int _pendingTonalShardheartType = 0
Int _pendingTonalShardheartTier = 0
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
    if !Controller.Config || !Controller.Identity || !Controller.Persistence || !Controller.Death
        return False
    endif
    if !Controller.Tiers || !Controller.Presentation
        return False
    endif
    return True
EndFunction

Int Function GetShardheartsTotal(Actor player = None)
    if !Controller || !Controller.Persistence
        return 0
    endif

    return Controller.Persistence.GetInt(player, shardheartsTotal, 0)
EndFunction

Bool Function SetShardheartsTotal(Actor player, Int totalValue, Bool flushNow = False)
    if !Controller || !Controller.Persistence
        return False
    endif

    Int clampedTotal = totalValue
    if clampedTotal < 0
        clampedTotal = 0
    endif

    Controller.Persistence.SetInt(player, shardheartsTotal, clampedTotal, True)
    if Controller.Globals
        Controller.Globals.SyncShardhearts(player)
    endif
    if flushNow
        IronSoulNative.DataFlushIfDirty()
    endif
    return True
EndFunction

Int Function IncrementShardheartsTotal(Actor player, Int shardheartType = 0, Int shardheartTier = 0)
    Int currentTotal = GetShardheartsTotal(player)
    Int nextTotal = currentTotal + 1
    if !SetShardheartsTotal(player, nextTotal, False)
        return currentTotal
    endif

    LogShardhearts(IronSoulConfig.LOG_INFO(), "IncrementShardheartsTotal: Account-wide ShardheartsTotal=" + nextTotal + " type=" + shardheartType + " tier=" + shardheartTier)
    return nextTotal
EndFunction

String Function GetShardheartUsedKey(Int shardheartType, Int shardheartTier)
    if shardheartType <= 0 || shardheartTier < 0
        return ""
    endif

    return shardheartUsedPrefix + shardheartType + "." + shardheartTier
EndFunction

Bool Function HasUsedShardheart(Int shardheartType, Int shardheartTier, Actor player = None)
    if !Controller || !Controller.Persistence
        return False
    endif

    String usedKey = GetShardheartUsedKey(shardheartType, shardheartTier)
    if usedKey == ""
        return False
    endif

    return Controller.Persistence.GetInt(player, usedKey, 0) == 1
EndFunction

Bool Function MarkShardheartUsed(Int shardheartType, Int shardheartTier, Actor player = None)
    if !Controller || !Controller.Persistence
        return False
    endif

    String usedKey = GetShardheartUsedKey(shardheartType, shardheartTier)
    if usedKey == ""
        return False
    endif

    if HasUsedShardheart(shardheartType, shardheartTier, player)
        return True
    endif

    Controller.Persistence.SetInt(player, usedKey, 1, True)
    return True
EndFunction

Bool Function RegisterShardheartUsed(Actor player, Int shardheartType = 0, Int shardheartTier = 0)
    if !Controller || !Controller.Persistence
        return False
    endif

    Int nextTotal = IncrementShardheartsTotal(player, shardheartType, shardheartTier)
    String usedKey = GetShardheartUsedKey(shardheartType, shardheartTier)
    Bool catalogMarked = False
    if usedKey != ""
        catalogMarked = MarkShardheartUsed(shardheartType, shardheartTier, player)
    endif

    if Controller.Globals
        Controller.Globals.SyncShardhearts(player)
    endif
    IronSoulNative.DataFlushIfDirty()
    LogShardhearts(IronSoulConfig.LOG_INFO(), "RegisterShardheartUsed: ShardheartsTotal=" + nextTotal + " usedKey=" + usedKey + " catalogMarked=" + catalogMarked)
    return True
EndFunction

Function LogShardhearts(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("Shardhearts", level, msg, suppressNotify)
        return
    endif

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [" + levelText + "] [Shardhearts] " + msg)
EndFunction

Int Function GetShardheartInventoryMode()
    if Controller && Controller.Config
        Int mode = Controller.Config.GetShardheartInventoryMode()
        if mode >= SHARDHEART_INVENTORY_MODE_LEGACY && mode <= SHARDHEART_INVENTORY_MODE_MIXED
            return mode
        endif
    endif
    return SHARDHEART_INVENTORY_MODE_REOPEN
EndFunction

Bool Function ShouldCloseInventoryForShardheartAction()
    Int mode = GetShardheartInventoryMode()
    if mode == SHARDHEART_INVENTORY_MODE_REOPEN || mode == SHARDHEART_INVENTORY_MODE_CLOSE || mode == SHARDHEART_INVENTORY_MODE_MIXED
        return True
    endif
    return False
EndFunction

Bool Function ShouldReopenInventoryAfterShardheartAction(Bool enhanceAction)
    Int mode = GetShardheartInventoryMode()
    if mode == SHARDHEART_INVENTORY_MODE_REOPEN
        return True
    elseif mode == SHARDHEART_INVENTORY_MODE_MIXED
        return enhanceAction
    endif
    return False
EndFunction

Function CloseInventoryForShardheartAction()
    if !ShouldCloseInventoryForShardheartAction()
        return
    endif
    if !UI.IsMenuOpen(SHARDHEART_INVENTORY_MENU)
        return
    endif

    UI.InvokeString("HUD Menu", "_global.skse.CloseMenu", SHARDHEART_INVENTORY_MENU)
    Utility.WaitMenuMode(0.2)
EndFunction

Function ReopenInventoryAfterShardheartAction(Bool enhanceAction)
    if !ShouldReopenInventoryAfterShardheartAction(enhanceAction)
        return
    endif
    if UI.IsMenuOpen(SHARDHEART_INVENTORY_MENU)
        return
    endif

    UI.InvokeString("HUD Menu", "_global.skse.OpenMenu", SHARDHEART_INVENTORY_MENU)
    Utility.WaitMenuMode(0.1)
EndFunction

String Function GetShardheartEnhanceResultText()
    String resultText = IronSoulNative.ShardheartGetEnhanceResultText()
    if resultText == ""
        return "Unknown Shardheart enhancement failure"
    endif
    return resultText
EndFunction

Function NotifyShardheartEnhanceFailure(Bool applyFailure = False)
    Int result = IronSoulNative.ShardheartGetEnhanceResult()
    if result == TONAL_RESULT_ALREADY_CAPPED
        Debug.Notification("The Shardheart cannot strengthen that item further.")
    elseif result == TONAL_RESULT_AMBIGUOUS_STACK
        Debug.Notification("The Shardheart cannot choose between matching items.")
    elseif applyFailure
        Debug.Notification("The Shardheart failed to strengthen that item.")
    else
        Debug.Notification("The Shardheart cannot strengthen that item.")
    endif
EndFunction

Function NotifyShardheartSuccess(String msg)
    if msg == ""
        return
    endif
    if Controller && Controller.Config && !Controller.Config.IsShardheartNotificationEnabled()
        return
    endif

    Debug.Notification(msg)
EndFunction

Bool Function TryUseShardheart(Actor player, Form shardheartBaseItem, Int shardheartType = 0, Int shardheartTier = 0)
    Bool result = False

    if !HasCoreRuntime() || !player || !shardheartBaseItem
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
        LogShardhearts(IronSoulConfig.LOG_ERR(), "TryUseShardheart: Could not resolve player GUID")
    else
        Int deaths = Controller.Death.GetCurrentDeathCount(player, guid)
        if deaths > 0
            result = ShowUseChoice(player, guid, shardheartBaseItem, shardheartType, shardheartTier)
        else
            result = ShowEnhanceOnlyChoice(player, shardheartBaseItem, shardheartType, shardheartTier)
        endif
    endif

    Utility.WaitMenuMode(0.2)
    _handlingUse = False
    return result
EndFunction

Bool Function ShowUseChoice(Actor player, String guid, Form shardheartBaseItem, Int shardheartType = 0, Int shardheartTier = 0)
    if ShardheartMsg
        Int choice = ShardheartMsg.Show()
        if choice == 0
            return TryEnhanceItem(player, shardheartBaseItem, shardheartType, shardheartTier)
        elseif choice == 1
            return TryPurgeDeath(player, guid, shardheartBaseItem, shardheartType, shardheartTier)
        endif

        LogShardhearts(IronSoulConfig.LOG_INFO(), "ShowUseChoice: Shardheart lowered")
        return False
    endif

    if ShardheartPurgeOnlyMsg
        return ShowPurgeOnlyChoice(player, guid, shardheartBaseItem, shardheartType, shardheartTier)
    endif
    if ShardheartEnhanceOnlyMsg
        return ShowEnhanceOnlyChoice(player, shardheartBaseItem, shardheartType, shardheartTier)
    endif

    Debug.MessageBox("Shardheart choices are not configured.")
    return False
EndFunction

Bool Function ShowEnhanceOnlyChoice(Actor player, Form shardheartBaseItem, Int shardheartType = 0, Int shardheartTier = 0)
    if ShardheartEnhanceOnlyMsg
        Int choice = ShardheartEnhanceOnlyMsg.Show()
        if choice == 0
            return TryEnhanceItem(player, shardheartBaseItem, shardheartType, shardheartTier)
        endif

        LogShardhearts(IronSoulConfig.LOG_INFO(), "ShowEnhanceOnlyChoice: Shardheart lowered")
        return False
    endif

    return ShowEnhanceUnavailable(player, shardheartType, shardheartTier)
EndFunction

Bool Function ShowPurgeOnlyChoice(Actor player, String guid, Form shardheartBaseItem, Int shardheartType = 0, Int shardheartTier = 0)
    if ShardheartPurgeOnlyMsg
        Int choice = ShardheartPurgeOnlyMsg.Show()
        if choice == 0
            return TryPurgeDeath(player, guid, shardheartBaseItem, shardheartType, shardheartTier)
        endif

        LogShardhearts(IronSoulConfig.LOG_INFO(), "ShowPurgeOnlyChoice: Shardheart lowered")
        return False
    endif

    Debug.MessageBox("Shardheart purge choices are not configured.")
    return False
EndFunction

Bool Function TryEnhanceItem(Actor player, Form shardheartBaseItem, Int shardheartType = 0, Int shardheartTier = 0)
    if shardheartType == SHARDHEART_TYPE_TONAL
        return TryEnhanceTonalItem(player, shardheartBaseItem, shardheartType, shardheartTier)
    endif

    LogShardhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceItem: Enhancement unavailable type=" + shardheartType + " tier=" + shardheartTier)
    return ShowEnhanceUnavailable(player, shardheartType, shardheartTier)
EndFunction

Bool Function TryEnhanceTonalItem(Actor player, Form shardheartBaseItem, Int shardheartType = 0, Int shardheartTier = 0)
    if !HasCoreRuntime() || !player || !shardheartBaseItem
        return False
    endif
    if player.GetItemCount(shardheartBaseItem) <= 0
        LogShardhearts(IronSoulConfig.LOG_ERR(), "TryEnhanceTonalItem: Player does not have the exact Tonal Shardheart base form")
        Debug.MessageBox("The Shardheart is no longer in your inventory.")
        return False
    endif

    Int addLevels = ResolveTonalAddLevels(shardheartTier)
    Int maxTemper = GetTonalMaxTemperLevel()
    Int sessionToken = IronSoulNative.ShardheartBuildEnhanceSession(SHARDHEART_EFFECT_TONAL, addLevels, maxTemper)
    if sessionToken <= 0
        String buildFailureText = GetShardheartEnhanceResultText()
        Debug.Notification("The Shardheart finds no eligible weapon or armor to strengthen.")
        LogShardhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceTonalItem: No Tonal enhancement options type=" + shardheartType + " tier=" + shardheartTier + " maxTemper=" + maxTemper + " result=" + buildFailureText)
        return False
    endif

    if !StartTonalEnhancementState(player, shardheartBaseItem, shardheartType, shardheartTier, sessionToken, maxTemper)
        IronSoulNative.ShardheartReleaseEnhanceSession(sessionToken)
        return False
    endif

    Int selectedIndex = ShowShardheartEnhanceList(sessionToken)
    if selectedIndex < 0
        LogShardhearts(IronSoulConfig.LOG_INFO(), "TryEnhanceTonalItem: Tonal enhancement selection canceled type=" + shardheartType + " tier=" + shardheartTier)
        ClearTonalEnhancementState()
        return False
    endif

    _pendingTonalSelectedIndex = selectedIndex
    return CompleteTonalEnhancement()
EndFunction

Bool Function StartTonalEnhancementState(Actor player, Form shardheartBaseItem, Int shardheartType, Int shardheartTier, Int sessionToken, Int maxTemper)
    ClearTonalEnhancementState()

    _tonalSelectionActive = True
    _pendingTonalPlayer = player
    _pendingTonalShardheartBaseItem = shardheartBaseItem
    _pendingTonalShardheartType = shardheartType
    _pendingTonalShardheartTier = shardheartTier
    _pendingTonalSessionToken = sessionToken
    _pendingTonalSelectedIndex = -1
    _pendingTonalMaxTemper = maxTemper

    LogShardhearts(IronSoulConfig.LOG_INFO(), "StartTonalEnhancementState: Started Tonal filtered item selection tier=" + shardheartTier + " maxTemper=" + maxTemper + " session=" + sessionToken)
    return True
EndFunction

Int Function ShowShardheartEnhanceList(Int sessionToken)
    Int optionCount = IronSoulNative.ShardheartGetEnhanceSessionOptionCount(sessionToken)
    if optionCount <= 0
        return -1
    endif

    _tonalItemSelectActive = True
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
    _pendingTonalSelectedIndex = -1
    RegisterForModEvent(SHARDHEART_ITEM_SELECT_LOAD_EVENT, "OnIronSoul_ItemSelect_Load")
    RegisterForModEvent(SHARDHEART_ITEM_SELECT_SELECT_EVENT, "OnIronSoul_ItemSelect_Select")

    Bool inventoryWasOpen = UI.IsMenuOpen(SHARDHEART_INVENTORY_MENU)
    if !inventoryWasOpen && !IronSoulNative.OpenMenu(SHARDHEART_INVENTORY_MENU)
        LogShardhearts(IronSoulConfig.LOG_ERR(), "ShowShardheartEnhanceList: InventoryMenu could not be queued")
        ClearShardheartItemSelectWait()
        Debug.MessageBox("The Shardheart selection menu is not available.")
        return -1
    endif

    Float waited = 0.0
    while !UI.IsMenuOpen(SHARDHEART_INVENTORY_MENU) && waited < 2.0
        Utility.WaitMenuMode(0.1)
        waited += 0.1
    endwhile

    if !UI.IsMenuOpen(SHARDHEART_INVENTORY_MENU)
        LogShardhearts(IronSoulConfig.LOG_ERR(), "ShowShardheartEnhanceList: InventoryMenu did not open")
        ClearShardheartItemSelectWait()
        Debug.MessageBox("The Shardheart selection menu is not available.")
        return -1
    endif

    InjectShardheartItemSelect()

    waited = 0.0
    while UI.IsMenuOpen(SHARDHEART_INVENTORY_MENU) && !_tonalItemSelectLoaded && !_tonalItemSelectFailed && waited < 2.0
        Utility.WaitMenuMode(0.1)
        waited += 0.1
    endwhile

    if !_tonalItemSelectLoaded || _tonalItemSelectFailed
        Bool noEligibleRows = _tonalItemSelectNoRows
        if noEligibleRows
            LogShardhearts(IronSoulConfig.LOG_INFO(), "ShowShardheartEnhanceList: Iron Soul item select found no eligible rows session=" + sessionToken)
        else
            LogShardhearts(IronSoulConfig.LOG_ERR(), "ShowShardheartEnhanceList: Iron Soul item select failed to load session=" + sessionToken + " loaded=" + _tonalItemSelectLoaded + " failed=" + _tonalItemSelectFailed)
        endif
        if !inventoryWasOpen
            IronSoulNative.CloseMenu(SHARDHEART_INVENTORY_MENU)
        endif
        ClearShardheartItemSelectWait()
        if !noEligibleRows
            Debug.MessageBox("The Shardheart selection menu is not available.")
        endif
        return -1
    endif

    while UI.IsMenuOpen(SHARDHEART_INVENTORY_MENU) && _pendingTonalSelectedIndex < 0 && !_tonalItemSelectFailed
        Utility.WaitMenuMode(0.1)
    endwhile

    ClearShardheartItemSelectWait()
    return _pendingTonalSelectedIndex
EndFunction

Function InjectShardheartItemSelect()
    String[] args = new String[2]
    args[0] = SHARDHEART_ITEM_SELECT_SWF
    args[1] = Utility.RandomInt(1000, 10000)
    UI.InvokeStringA(SHARDHEART_INVENTORY_MENU, "_root.createEmptyMovieClip", args)
    UI.InvokeString(SHARDHEART_INVENTORY_MENU, "_root." + SHARDHEART_ITEM_SELECT_SWF + ".loadMovie", SHARDHEART_ITEM_SELECT_SWF + ".swf")
EndFunction

Function ClearShardheartItemSelectWait()
    UnregisterForModEvent(SHARDHEART_ITEM_SELECT_LOAD_EVENT)
    UnregisterForModEvent(SHARDHEART_ITEM_SELECT_SELECT_EVENT)
    _tonalItemSelectActive = False
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
EndFunction

Event OnIronSoul_ItemSelect_Load(String eventName, String strArg, Float numArg, Form formArg)
    if !_tonalItemSelectActive
        return
    endif

    String serializedRows = IronSoulNative.ShardheartRefreshEnhanceSessionInventoryRows(_pendingTonalSessionToken)
    if serializedRows == ""
        String resultText = GetShardheartEnhanceResultText()
        _tonalItemSelectFailed = True
        _tonalItemSelectNoRows = True
        LogShardhearts(IronSoulConfig.LOG_INFO(), "OnIronSoul_ItemSelect_Load: No eligible InventoryMenu rows session=" + _pendingTonalSessionToken + " result=" + resultText)
        Debug.Notification("The Shardheart finds no eligible weapon or armor to strengthen.")
        IronSoulNative.CloseMenu(SHARDHEART_INVENTORY_MENU)
        return
    endif

    UI.InvokeString(SHARDHEART_INVENTORY_MENU, SHARDHEART_ITEM_SELECT_ROOT + ".setAllowedRows", serializedRows)
    _tonalItemSelectLoaded = True
EndEvent

Event OnIronSoul_ItemSelect_Select(String eventName, String strArg, Float numArg, Form formArg)
    if !_tonalItemSelectActive
        return
    endif

    _pendingTonalSelectedIndex = numArg as Int
    IronSoulNative.CloseMenu(SHARDHEART_INVENTORY_MENU)
EndEvent

Bool Function CompleteTonalEnhancement()
    Actor player = _pendingTonalPlayer
    Form shardheartBaseItem = _pendingTonalShardheartBaseItem
    Int shardheartType = _pendingTonalShardheartType
    Int shardheartTier = _pendingTonalShardheartTier
    Int sessionToken = _pendingTonalSessionToken
    Int selectedIndex = _pendingTonalSelectedIndex
    Int maxTemper = _pendingTonalMaxTemper
    Int addLevels = ResolveTonalAddLevels(shardheartTier)

    if !player || !shardheartBaseItem || sessionToken <= 0 || selectedIndex < 0
        ClearTonalEnhancementState()
        return False
    endif

    if player.GetItemCount(shardheartBaseItem) <= 0
        LogShardhearts(IronSoulConfig.LOG_ERR(), "CompleteTonalEnhancement: Player no longer has exact Tonal Shardheart base form")
        Debug.MessageBox("The Shardheart is no longer in your inventory.")
        ClearTonalEnhancementState()
        return False
    endif

    Bool enhanced = IronSoulNative.ShardheartApplyEnhanceSessionInventoryRow(sessionToken, selectedIndex)
    if !enhanced
        String resultText = GetShardheartEnhanceResultText()
        NotifyShardheartEnhanceFailure(True)
        LogShardhearts(IronSoulConfig.LOG_ERR(), "CompleteTonalEnhancement: Native Tonal apply failed type=" + shardheartType + " tier=" + shardheartTier + " result=" + resultText)
        _pendingTonalSessionToken = 0
        ClearTonalEnhancementState()
        return False
    endif
    _pendingTonalSessionToken = 0
    String enhanceResultText = GetShardheartEnhanceResultText()

    CloseInventoryForShardheartAction()
    PlayItemEnhancedPresentation(player)
    player.RemoveItem(shardheartBaseItem, 1, True)
    AwardHeartglass(player, shardheartType, shardheartTier)
    RegisterShardheartUsed(player, shardheartType, shardheartTier)
    NotifyShardheartSuccess("Tonal Shardheart strengthened " + enhanceResultText)

    LogShardhearts(IronSoulConfig.LOG_INFO(), "CompleteTonalEnhancement: Enhanced selected inventory item with Tonal Shardheart type=" + shardheartType + " tier=" + shardheartTier + " addLevels=" + addLevels + " maxLevel=" + maxTemper + " result=" + enhanceResultText)
    ClearTonalEnhancementState()
    ReopenInventoryAfterShardheartAction(True)
    return True
EndFunction

Int Function GetTonalMaxTemperLevel()
    if Controller && Controller.Config
        Int maxTemper = Controller.Config.GetShardheartTonalMaxTemper()
        if maxTemper >= 1 && maxTemper <= TONAL_TEMPER_CONFIG_MAX_LEVEL
            return maxTemper
        endif
    endif
    return TONAL_TEMPER_MAX_LEVEL
EndFunction

Int Function ResolveTonalAddLevels(Int shardheartTier)
    if shardheartTier <= 1
        return 1
    elseif shardheartTier == 2
        return 2
    elseif shardheartTier == 3
        return 3
    elseif shardheartTier == 4
        return 4
    endif
    return 5
EndFunction

Function ClearTonalEnhancementState()
    UnregisterForModEvent(SHARDHEART_ITEM_SELECT_LOAD_EVENT)
    UnregisterForModEvent(SHARDHEART_ITEM_SELECT_SELECT_EVENT)

    if _pendingTonalSessionToken > 0
        IronSoulNative.ShardheartReleaseEnhanceSession(_pendingTonalSessionToken)
    endif

    _tonalSelectionActive = False
    _tonalItemSelectActive = False
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
    _pendingTonalPlayer = None
    _pendingTonalShardheartBaseItem = None
    _pendingTonalShardheartType = 0
    _pendingTonalShardheartTier = 0
    _pendingTonalSessionToken = 0
    _pendingTonalSelectedIndex = -1
    _pendingTonalMaxTemper = TONAL_TEMPER_MAX_LEVEL
EndFunction

Bool Function ShowEnhanceUnavailable(Actor player, Int shardheartType = 0, Int shardheartTier = 0)
    if ShardheartUnavailableMsg
        ShardheartUnavailableMsg.Show()
    else
        Debug.MessageBox("Shardheart item enhancement is not implemented yet.")
    endif

    LogShardhearts(IronSoulConfig.LOG_INFO(), "ShowEnhanceUnavailable: Enhancement unavailable shown type=" + shardheartType + " tier=" + shardheartTier)
    return False
EndFunction

Bool Function TryPurgeDeath(Actor player, String guid, Form shardheartBaseItem, Int shardheartType = 0, Int shardheartTier = 0)
    if !HasCoreRuntime() || !player || guid == "" || !shardheartBaseItem
        return False
    endif

    Int deathsBeforePurge = Controller.Death.GetCurrentDeathCount(player, guid)
    if deathsBeforePurge <= 0
        LogShardhearts(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: No current deaths to purge")
        return False
    endif

    Int itemCount = player.GetItemCount(shardheartBaseItem)
    if itemCount <= 0
        LogShardhearts(IronSoulConfig.LOG_ERR(), "TryPurgeDeath: Player does not have the exact Shardheart base form")
        Debug.MessageBox("The Shardheart is no longer in your inventory.")
        return False
    endif

    Int deathsAfterPurge = deathsBeforePurge - 1
    player.RemoveItem(shardheartBaseItem, 1, True)
    Controller.Death.SetCurrentDeathCount(player, guid, deathsAfterPurge)

    LogShardhearts(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: Purged one death using exact Shardheart type=" + shardheartType + " tier=" + shardheartTier + " deaths=" + deathsBeforePurge + "->" + deathsAfterPurge)

    IronSoulNative.DataFlushIfDirty()

    CloseInventoryForShardheartAction()
    PlayDeathPurgedPresentation(player)
    AwardHeartglass(player, shardheartType, shardheartTier)
    RegisterShardheartUsed(player, shardheartType, shardheartTier)
    Controller.Tiers.TryRestoreFromDefiant(player, guid)
    NotifyShardheartSuccess("The Shardheart purges one death. Deaths: " + deathsBeforePurge + " -> " + deathsAfterPurge)
    ReopenInventoryAfterShardheartAction(False)
    return True
EndFunction

Function AwardHeartglass(Actor player, Int shardheartType = 0, Int shardheartTier = 0)
    if !player
        return
    endif
    if !ShardheartSpent
        LogShardhearts(IronSoulConfig.LOG_ERR(), "AwardHeartglass: ShardheartSpent property is not wired")
        return
    endif

    player.AddItem(ShardheartSpent, 1, False)
    LogShardhearts(IronSoulConfig.LOG_INFO(), "AwardHeartglass: Awarded Heartglass for spent Shardheart type=" + shardheartType + " tier=" + shardheartTier)
EndFunction

Function PlayDeathPurgedPresentation(Actor player)
    PlayShardheartPresentation(player, SHARDHEART_DEATH_PURGED_MENU)
EndFunction

Function PlayItemEnhancedPresentation(Actor player)
    PlayShardheartPresentation(player, SHARDHEART_ITEM_ENHANCED_MENU)
EndFunction

Function PlayShardheartPresentation(Actor player, String menuName)
    if !player
        return
    endif
    if Controller && Controller.Config && !Controller.Config.IsShardheartMessageEnabled()
        PlayShardheartSFX(player)
        return
    endif
    if menuName == ""
        return
    endif

    Controller.Presentation.FadeMusicForTransitionSequence()
    UI.CloseCustomMenu()
    UI.OpenCustomMenu(menuName, 0)
    PlayShardheartSFX(player)
    Controller.Presentation.WaitKeyDismissMenu(SHARDHEART_PRESENTATION_MAX_SECONDS, SHARDHEART_PRESENTATION_DISMISS_SECONDS)
    Controller.Presentation.RestoreMusic()
EndFunction

Function PlayShardheartSFX(Actor player)
    if !player || !SFXShardheartAbsorb
        return
    endif
    if !Controller || !Controller.Config
        return
    endif
    if IronSoulSFX.CanPlaySFX(Controller.Config.IsSFXEnabled(), Controller.Config.IsUninstallMode(), Controller.IsModDisabled()) && Controller.Config.IsShardheartAbsorbSFXEnabled()
        SFXShardheartAbsorb.Play(player)
    endif
EndFunction
