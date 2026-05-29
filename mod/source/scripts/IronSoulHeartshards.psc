Scriptname IronSoulHeartshards extends Quest

; Heartshards
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
; I therefore use the term heartshard with some reluctance. It is not meant to
; certify that the orb is a literal fragment of any relic a miner could have held.
; It is meant to name a suspicion: that some force once bound to the Heart
; beneath Red Mountain was scattered, refracted, or made local by the disaster
; there. If this is so, these orbs are not fragments in the vulgar sense. They
; are splinters of consequence, small mineral survivals of a pressure that
; should have ended where it began.
;
; The analogy to the Daedric sigil is tempting but imperfect. Such a sigil
; impresses an exterior will upon a prepared morpholith, making a gate where no
; gate should be. A heartshard, if such things exist, would be its mortal
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
; If so, the heartshard is not a fragment in the vulgar sense. It is an event
; made mineral. A red witness to the proposition that death, like Mundus itself,
; was never perfectly finished.

IronSoulController Property Controller Auto
MiscObject Property HeartshardSpent Auto
String Property heartshardsTotal = "IS_2740" AutoReadOnly ; Account-wide successful Heartshard use counter.
String Property heartshardsUnlockedTotal = "IS_2741" AutoReadOnly ; Account-wide distinct Heartshard unlock counter.
String Property heartshardUsedPrefix = "HS.U." AutoReadOnly ; Account-wide boolean used catalog prefix.

; Expected MESG EditorIDs:
; - IronSoul_HeartshardMsg: Enhance Item, Purge Death, Lower Heartshard.
; - IronSoul_HeartshardEnhanceOnlyMsg: Enhance Item, Lower Heartshard.
; - IronSoul_HeartshardPurgeOnlyMsg: Purge Death, Lower Heartshard.
; - IronSoul_HeartshardUnavailableMsg: Lower Heartshard.
Message Property HeartshardMsg Auto
Message Property HeartshardEnhanceOnlyMsg Auto
Message Property HeartshardPurgeOnlyMsg Auto
Message Property HeartshardUnavailableMsg Auto
Sound Property SFXHeartshardAbsorb Auto

Int HEARTSHARD_TYPE_TONAL = 1
Int HEARTSHARD_EFFECT_TONAL = 1
Int HEARTSHARD_INVENTORY_MODE_LEGACY = 0
Int HEARTSHARD_INVENTORY_MODE_REOPEN = 1
Int HEARTSHARD_INVENTORY_MODE_CLOSE = 2
Int HEARTSHARD_INVENTORY_MODE_MIXED = 3
String HEARTSHARD_ITEM_ENHANCED_MENU = "heartshard_item_enhanced"
String HEARTSHARD_DEATH_PURGED_MENU = "heartshard_death_purged"
String HEARTSHARD_INVENTORY_MENU = "InventoryMenu"
String HEARTSHARD_ITEM_SELECT_SWF = "ironsoul_itemselect"
String HEARTSHARD_ITEM_SELECT_ROOT = "_root.ironsoul_itemselect.ItemSelect_mc"
String HEARTSHARD_ITEM_SELECT_LOAD_EVENT = "IronSoul_ItemSelect_Load"
String HEARTSHARD_ITEM_SELECT_SELECT_EVENT = "IronSoul_ItemSelect_Select"
Float HEARTSHARD_PRESENTATION_MAX_SECONDS = 5.5
Float HEARTSHARD_PRESENTATION_DISMISS_SECONDS = 2.0
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
Form _pendingTonalHeartshardBaseItem = None
Int _pendingTonalHeartshardType = 0
Int _pendingTonalHeartshardTier = 0
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

Int Function GetHeartshardsTotal(Actor player = None)
    if !Controller || !Controller.Persistence
        return 0
    endif

    return Controller.Persistence.GetAccountInt(heartshardsTotal, 0)
EndFunction

Bool Function SetHeartshardsTotal(Actor player, Int totalValue, Bool flushNow = False)
    if !Controller || !Controller.Persistence
        return False
    endif

    Int clampedTotal = totalValue
    if clampedTotal < 0
        clampedTotal = 0
    endif

    Controller.Persistence.SetAccountInt(heartshardsTotal, clampedTotal, True)
    if Controller.Globals
        Controller.Globals.SyncHeartshards(player)
    endif
    if flushNow
        IronSoulNative.DataFlushIfDirty()
    endif
    return True
EndFunction

Int Function IncrementHeartshardsTotal(Actor player, Int heartshardType = 0, Int heartshardTier = 0)
    Int currentTotal = GetHeartshardsTotal(player)
    Int nextTotal = currentTotal + 1
    if !SetHeartshardsTotal(player, nextTotal, False)
        return currentTotal
    endif

    LogHeartshards(IronSoulConfig.LOG_INFO(), "IncrementHeartshardsTotal: Account-wide HeartshardsTotal=" + nextTotal + " type=" + heartshardType + " tier=" + heartshardTier)
    return nextTotal
EndFunction

Int Function GetHeartshardsUnlocked(Actor player = None)
    if !Controller || !Controller.Persistence
        return 0
    endif

    return Controller.Persistence.GetAccountInt(heartshardsUnlockedTotal, 0)
EndFunction

Bool Function SetHeartshardsUnlocked(Actor player, Int unlockedValue, Bool flushNow = False)
    if !Controller || !Controller.Persistence
        return False
    endif

    Int clampedUnlocked = unlockedValue
    if clampedUnlocked < 0
        clampedUnlocked = 0
    endif

    Controller.Persistence.SetAccountInt(heartshardsUnlockedTotal, clampedUnlocked, True)
    if flushNow
        IronSoulNative.DataFlushIfDirty()
    endif
    return True
EndFunction

Int Function IncrementHeartshardsUnlocked(Actor player, Int heartshardType = 0, Int heartshardTier = 0)
    Int currentUnlocked = GetHeartshardsUnlocked(player)
    Int nextUnlocked = currentUnlocked + 1
    if !SetHeartshardsUnlocked(player, nextUnlocked, False)
        return currentUnlocked
    endif

    LogHeartshards(IronSoulConfig.LOG_INFO(), "IncrementHeartshardsUnlocked: Account-wide HeartshardsUnlocked=" + nextUnlocked + " type=" + heartshardType + " tier=" + heartshardTier)
    return nextUnlocked
EndFunction

String Function GetHeartshardUsedKey(Int heartshardType, Int heartshardTier)
    if heartshardType <= 0 || heartshardTier < 0
        return ""
    endif

    return heartshardUsedPrefix + heartshardType + "." + heartshardTier
EndFunction

Bool Function HasUsedHeartshard(Int heartshardType, Int heartshardTier, Actor player = None)
    if !Controller || !Controller.Persistence
        return False
    endif

    String usedKey = GetHeartshardUsedKey(heartshardType, heartshardTier)
    if usedKey == ""
        return False
    endif

    return Controller.Persistence.GetAccountInt(usedKey, 0) == 1
EndFunction

Bool Function MarkHeartshardUsed(Int heartshardType, Int heartshardTier, Actor player = None)
    if !Controller || !Controller.Persistence
        return False
    endif

    String usedKey = GetHeartshardUsedKey(heartshardType, heartshardTier)
    if usedKey == ""
        return False
    endif

    if HasUsedHeartshard(heartshardType, heartshardTier, player)
        return False
    endif

    Controller.Persistence.SetAccountInt(usedKey, 1, True)
    return True
EndFunction

Bool Function RegisterHeartshardUsed(Actor player, Int heartshardType = 0, Int heartshardTier = 0)
    if !Controller || !Controller.Persistence
        return False
    endif

    Int nextTotal = IncrementHeartshardsTotal(player, heartshardType, heartshardTier)
    String usedKey = GetHeartshardUsedKey(heartshardType, heartshardTier)
    Bool newUnlock = False
    Int nextUnlocked = GetHeartshardsUnlocked(player)
    if usedKey != ""
        newUnlock = MarkHeartshardUsed(heartshardType, heartshardTier, player)
        if newUnlock
            nextUnlocked = IncrementHeartshardsUnlocked(player, heartshardType, heartshardTier)
        endif
    endif

    if Controller.Globals
        Controller.Globals.SyncHeartshards(player)
    endif
    IronSoulNative.DataFlushIfDirty()
    LogHeartshards(IronSoulConfig.LOG_INFO(), "RegisterHeartshardUsed: HeartshardsAbsorbed=" + nextTotal + " HeartshardsUnlocked=" + nextUnlocked + " usedKey=" + usedKey + " newUnlock=" + newUnlock)
    return True
EndFunction

Int Function ResetAccountHeartshardData(Actor player = None)
    if !Controller || !Controller.Persistence
        return -1
    endif

    SetHeartshardsTotal(player, 0, False)
    SetHeartshardsUnlocked(player, 0, False)
    Int deletedCatalogKeys = Controller.Persistence.DeleteAccountKeysWithPrefix(heartshardUsedPrefix)
    if Controller.Globals
        Controller.Globals.SyncHeartshards(player)
    endif
    IronSoulNative.DataFlushIfDirty()
    LogHeartshards(IronSoulConfig.LOG_INFO(), "ResetAccountHeartshardData: reset HeartshardsAbsorbed=0 HeartshardsUnlocked=0 deletedCatalogKeys=" + deletedCatalogKeys)
    return deletedCatalogKeys
EndFunction

Function LogHeartshards(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("Heartshards", level, msg, suppressNotify)
        return
    endif

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [" + levelText + "] [Heartshards] " + msg)
EndFunction

Int Function GetHeartshardInventoryMode()
    if Controller && Controller.Config
        Int mode = Controller.Config.GetHeartshardInventoryMode()
        if mode >= HEARTSHARD_INVENTORY_MODE_LEGACY && mode <= HEARTSHARD_INVENTORY_MODE_MIXED
            return mode
        endif
    endif
    return HEARTSHARD_INVENTORY_MODE_REOPEN
EndFunction

Bool Function ShouldCloseInventoryForHeartshardAction()
    Int mode = GetHeartshardInventoryMode()
    if mode == HEARTSHARD_INVENTORY_MODE_REOPEN || mode == HEARTSHARD_INVENTORY_MODE_CLOSE || mode == HEARTSHARD_INVENTORY_MODE_MIXED
        return True
    endif
    return False
EndFunction

Bool Function ShouldReopenInventoryAfterHeartshardAction(Bool enhanceAction)
    Int mode = GetHeartshardInventoryMode()
    if mode == HEARTSHARD_INVENTORY_MODE_REOPEN
        return True
    elseif mode == HEARTSHARD_INVENTORY_MODE_MIXED
        return enhanceAction
    endif
    return False
EndFunction

Function CloseInventoryForHeartshardAction()
    if !ShouldCloseInventoryForHeartshardAction()
        return
    endif
    if !UI.IsMenuOpen(HEARTSHARD_INVENTORY_MENU)
        return
    endif

    UI.InvokeString("HUD Menu", "_global.skse.CloseMenu", HEARTSHARD_INVENTORY_MENU)
    Utility.WaitMenuMode(0.2)
EndFunction

Function ReopenInventoryAfterHeartshardAction(Bool enhanceAction)
    if !ShouldReopenInventoryAfterHeartshardAction(enhanceAction)
        return
    endif
    if UI.IsMenuOpen(HEARTSHARD_INVENTORY_MENU)
        return
    endif

    UI.InvokeString("HUD Menu", "_global.skse.OpenMenu", HEARTSHARD_INVENTORY_MENU)
    Utility.WaitMenuMode(0.1)
EndFunction

String Function GetHeartshardEnhanceResultText()
    String resultText = IronSoulNative.HeartshardGetEnhanceResultText()
    if resultText == ""
        return "Unknown Heartshard enhancement failure"
    endif
    return resultText
EndFunction

Function NotifyHeartshardEnhanceFailure(Bool applyFailure = False)
    Int result = IronSoulNative.HeartshardGetEnhanceResult()
    if result == TONAL_RESULT_ALREADY_CAPPED
        Debug.Notification("The Heartshard cannot strengthen that item further.")
    elseif result == TONAL_RESULT_AMBIGUOUS_STACK
        Debug.Notification("The Heartshard cannot choose between matching items.")
    elseif applyFailure
        Debug.Notification("The Heartshard failed to strengthen that item.")
    else
        Debug.Notification("The Heartshard cannot strengthen that item.")
    endif
EndFunction

Function NotifyHeartshardSuccess(String msg)
    if msg == ""
        return
    endif
    if Controller && Controller.Config && !Controller.Config.IsHeartshardNotificationEnabled()
        return
    endif

    Debug.Notification(msg + ". Heartshards Absorbed: " + GetHeartshardsTotal(Game.GetPlayer()))
EndFunction

Bool Function TryUseHeartshard(Actor player, Form heartshardBaseItem, Int heartshardType = 0, Int heartshardTier = 0)
    Bool result = False

    if !HasCoreRuntime() || !player || !heartshardBaseItem
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
        LogHeartshards(IronSoulConfig.LOG_ERR(), "TryUseHeartshard: Could not resolve player GUID")
    else
        Int deaths = Controller.Death.GetCurrentDeathCount(player, guid)
        if deaths > 0
            result = ShowUseChoice(player, guid, heartshardBaseItem, heartshardType, heartshardTier)
        else
            result = ShowEnhanceOnlyChoice(player, heartshardBaseItem, heartshardType, heartshardTier)
        endif
    endif

    Utility.WaitMenuMode(0.2)
    _handlingUse = False
    return result
EndFunction

Bool Function ShowUseChoice(Actor player, String guid, Form heartshardBaseItem, Int heartshardType = 0, Int heartshardTier = 0)
    if HeartshardMsg
        Int choice = HeartshardMsg.Show()
        if choice == 0
            return TryEnhanceItem(player, heartshardBaseItem, heartshardType, heartshardTier)
        elseif choice == 1
            return TryPurgeDeath(player, guid, heartshardBaseItem, heartshardType, heartshardTier)
        endif

        LogHeartshards(IronSoulConfig.LOG_INFO(), "ShowUseChoice: Heartshard lowered")
        return False
    endif

    if HeartshardPurgeOnlyMsg
        return ShowPurgeOnlyChoice(player, guid, heartshardBaseItem, heartshardType, heartshardTier)
    endif
    if HeartshardEnhanceOnlyMsg
        return ShowEnhanceOnlyChoice(player, heartshardBaseItem, heartshardType, heartshardTier)
    endif

    Debug.MessageBox("Heartshard choices are not configured.")
    return False
EndFunction

Bool Function ShowEnhanceOnlyChoice(Actor player, Form heartshardBaseItem, Int heartshardType = 0, Int heartshardTier = 0)
    if HeartshardEnhanceOnlyMsg
        Int choice = HeartshardEnhanceOnlyMsg.Show()
        if choice == 0
            return TryEnhanceItem(player, heartshardBaseItem, heartshardType, heartshardTier)
        endif

        LogHeartshards(IronSoulConfig.LOG_INFO(), "ShowEnhanceOnlyChoice: Heartshard lowered")
        return False
    endif

    return ShowEnhanceUnavailable(player, heartshardType, heartshardTier)
EndFunction

Bool Function ShowPurgeOnlyChoice(Actor player, String guid, Form heartshardBaseItem, Int heartshardType = 0, Int heartshardTier = 0)
    if HeartshardPurgeOnlyMsg
        Int choice = HeartshardPurgeOnlyMsg.Show()
        if choice == 0
            return TryPurgeDeath(player, guid, heartshardBaseItem, heartshardType, heartshardTier)
        endif

        LogHeartshards(IronSoulConfig.LOG_INFO(), "ShowPurgeOnlyChoice: Heartshard lowered")
        return False
    endif

    Debug.MessageBox("Heartshard purge choices are not configured.")
    return False
EndFunction

Bool Function TryEnhanceItem(Actor player, Form heartshardBaseItem, Int heartshardType = 0, Int heartshardTier = 0)
    if heartshardType == HEARTSHARD_TYPE_TONAL
        return TryEnhanceTonalItem(player, heartshardBaseItem, heartshardType, heartshardTier)
    endif

    LogHeartshards(IronSoulConfig.LOG_INFO(), "TryEnhanceItem: Enhancement unavailable type=" + heartshardType + " tier=" + heartshardTier)
    return ShowEnhanceUnavailable(player, heartshardType, heartshardTier)
EndFunction

Bool Function TryEnhanceTonalItem(Actor player, Form heartshardBaseItem, Int heartshardType = 0, Int heartshardTier = 0)
    if !HasCoreRuntime() || !player || !heartshardBaseItem
        return False
    endif
    if player.GetItemCount(heartshardBaseItem) <= 0
        LogHeartshards(IronSoulConfig.LOG_ERR(), "TryEnhanceTonalItem: Player does not have the exact Tonal Heartshard base form")
        Debug.MessageBox("The Heartshard is no longer in your inventory.")
        return False
    endif

    Int addLevels = ResolveTonalAddLevels(heartshardTier)
    Int maxTemper = GetTonalMaxTemperLevel()
    Int sessionToken = IronSoulNative.HeartshardBuildEnhanceSession(HEARTSHARD_EFFECT_TONAL, addLevels, maxTemper)
    if sessionToken <= 0
        String buildFailureText = GetHeartshardEnhanceResultText()
        Debug.Notification("The Heartshard finds no eligible weapon or armor to strengthen.")
        LogHeartshards(IronSoulConfig.LOG_INFO(), "TryEnhanceTonalItem: No Tonal enhancement options type=" + heartshardType + " tier=" + heartshardTier + " maxTemper=" + maxTemper + " result=" + buildFailureText)
        return False
    endif

    if !StartTonalEnhancementState(player, heartshardBaseItem, heartshardType, heartshardTier, sessionToken, maxTemper)
        IronSoulNative.HeartshardReleaseEnhanceSession(sessionToken)
        return False
    endif

    Int selectedIndex = ShowHeartshardEnhanceList(sessionToken)
    if selectedIndex < 0
        LogHeartshards(IronSoulConfig.LOG_INFO(), "TryEnhanceTonalItem: Tonal enhancement selection canceled type=" + heartshardType + " tier=" + heartshardTier)
        ClearTonalEnhancementState()
        return False
    endif

    _pendingTonalSelectedIndex = selectedIndex
    return CompleteTonalEnhancement()
EndFunction

Bool Function StartTonalEnhancementState(Actor player, Form heartshardBaseItem, Int heartshardType, Int heartshardTier, Int sessionToken, Int maxTemper)
    ClearTonalEnhancementState()

    _tonalSelectionActive = True
    _pendingTonalPlayer = player
    _pendingTonalHeartshardBaseItem = heartshardBaseItem
    _pendingTonalHeartshardType = heartshardType
    _pendingTonalHeartshardTier = heartshardTier
    _pendingTonalSessionToken = sessionToken
    _pendingTonalSelectedIndex = -1
    _pendingTonalMaxTemper = maxTemper

    LogHeartshards(IronSoulConfig.LOG_INFO(), "StartTonalEnhancementState: Started Tonal filtered item selection tier=" + heartshardTier + " maxTemper=" + maxTemper + " session=" + sessionToken)
    return True
EndFunction

Int Function ShowHeartshardEnhanceList(Int sessionToken)
    Int optionCount = IronSoulNative.HeartshardGetEnhanceSessionOptionCount(sessionToken)
    if optionCount <= 0
        return -1
    endif

    _tonalItemSelectActive = True
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
    _pendingTonalSelectedIndex = -1
    RegisterForModEvent(HEARTSHARD_ITEM_SELECT_LOAD_EVENT, "OnIronSoul_ItemSelect_Load")
    RegisterForModEvent(HEARTSHARD_ITEM_SELECT_SELECT_EVENT, "OnIronSoul_ItemSelect_Select")

    Bool inventoryWasOpen = UI.IsMenuOpen(HEARTSHARD_INVENTORY_MENU)
    if !inventoryWasOpen && !IronSoulNative.OpenMenu(HEARTSHARD_INVENTORY_MENU)
        LogHeartshards(IronSoulConfig.LOG_ERR(), "ShowHeartshardEnhanceList: InventoryMenu could not be queued")
        ClearHeartshardItemSelectWait()
        Debug.MessageBox("The Heartshard selection menu is not available.")
        return -1
    endif

    Float waited = 0.0
    while !UI.IsMenuOpen(HEARTSHARD_INVENTORY_MENU) && waited < 2.0
        Utility.WaitMenuMode(0.1)
        waited += 0.1
    endwhile

    if !UI.IsMenuOpen(HEARTSHARD_INVENTORY_MENU)
        LogHeartshards(IronSoulConfig.LOG_ERR(), "ShowHeartshardEnhanceList: InventoryMenu did not open")
        ClearHeartshardItemSelectWait()
        Debug.MessageBox("The Heartshard selection menu is not available.")
        return -1
    endif

    InjectHeartshardItemSelect()

    waited = 0.0
    while UI.IsMenuOpen(HEARTSHARD_INVENTORY_MENU) && !_tonalItemSelectLoaded && !_tonalItemSelectFailed && waited < 2.0
        Utility.WaitMenuMode(0.1)
        waited += 0.1
    endwhile

    if !_tonalItemSelectLoaded || _tonalItemSelectFailed
        Bool noEligibleRows = _tonalItemSelectNoRows
        if noEligibleRows
            LogHeartshards(IronSoulConfig.LOG_INFO(), "ShowHeartshardEnhanceList: Iron Soul item select found no eligible rows session=" + sessionToken)
        else
            LogHeartshards(IronSoulConfig.LOG_ERR(), "ShowHeartshardEnhanceList: Iron Soul item select failed to load session=" + sessionToken + " loaded=" + _tonalItemSelectLoaded + " failed=" + _tonalItemSelectFailed)
        endif
        if !inventoryWasOpen
            IronSoulNative.CloseMenu(HEARTSHARD_INVENTORY_MENU)
        endif
        ClearHeartshardItemSelectWait()
        if !noEligibleRows
            Debug.MessageBox("The Heartshard selection menu is not available.")
        endif
        return -1
    endif

    while UI.IsMenuOpen(HEARTSHARD_INVENTORY_MENU) && _pendingTonalSelectedIndex < 0 && !_tonalItemSelectFailed
        Utility.WaitMenuMode(0.1)
    endwhile

    ClearHeartshardItemSelectWait()
    return _pendingTonalSelectedIndex
EndFunction

Function InjectHeartshardItemSelect()
    String[] args = new String[2]
    args[0] = HEARTSHARD_ITEM_SELECT_SWF
    args[1] = Utility.RandomInt(1000, 10000)
    UI.InvokeStringA(HEARTSHARD_INVENTORY_MENU, "_root.createEmptyMovieClip", args)
    UI.InvokeString(HEARTSHARD_INVENTORY_MENU, "_root." + HEARTSHARD_ITEM_SELECT_SWF + ".loadMovie", HEARTSHARD_ITEM_SELECT_SWF + ".swf")
EndFunction

Function ClearHeartshardItemSelectWait()
    UnregisterForModEvent(HEARTSHARD_ITEM_SELECT_LOAD_EVENT)
    UnregisterForModEvent(HEARTSHARD_ITEM_SELECT_SELECT_EVENT)
    _tonalItemSelectActive = False
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
EndFunction

Event OnIronSoul_ItemSelect_Load(String eventName, String strArg, Float numArg, Form formArg)
    if !_tonalItemSelectActive
        return
    endif

    String serializedRows = IronSoulNative.HeartshardRefreshEnhanceSessionInventoryRows(_pendingTonalSessionToken)
    if serializedRows == ""
        String resultText = GetHeartshardEnhanceResultText()
        _tonalItemSelectFailed = True
        _tonalItemSelectNoRows = True
        LogHeartshards(IronSoulConfig.LOG_INFO(), "OnIronSoul_ItemSelect_Load: No eligible InventoryMenu rows session=" + _pendingTonalSessionToken + " result=" + resultText)
        Debug.Notification("The Heartshard finds no eligible weapon or armor to strengthen.")
        IronSoulNative.CloseMenu(HEARTSHARD_INVENTORY_MENU)
        return
    endif

    UI.InvokeString(HEARTSHARD_INVENTORY_MENU, HEARTSHARD_ITEM_SELECT_ROOT + ".setAllowedRows", serializedRows)
    _tonalItemSelectLoaded = True
EndEvent

Event OnIronSoul_ItemSelect_Select(String eventName, String strArg, Float numArg, Form formArg)
    if !_tonalItemSelectActive
        return
    endif

    _pendingTonalSelectedIndex = numArg as Int
    IronSoulNative.CloseMenu(HEARTSHARD_INVENTORY_MENU)
EndEvent

Bool Function CompleteTonalEnhancement()
    Actor player = _pendingTonalPlayer
    Form heartshardBaseItem = _pendingTonalHeartshardBaseItem
    Int heartshardType = _pendingTonalHeartshardType
    Int heartshardTier = _pendingTonalHeartshardTier
    Int sessionToken = _pendingTonalSessionToken
    Int selectedIndex = _pendingTonalSelectedIndex
    Int maxTemper = _pendingTonalMaxTemper
    Int addLevels = ResolveTonalAddLevels(heartshardTier)

    if !player || !heartshardBaseItem || sessionToken <= 0 || selectedIndex < 0
        ClearTonalEnhancementState()
        return False
    endif

    if player.GetItemCount(heartshardBaseItem) <= 0
        LogHeartshards(IronSoulConfig.LOG_ERR(), "CompleteTonalEnhancement: Player no longer has exact Tonal Heartshard base form")
        Debug.MessageBox("The Heartshard is no longer in your inventory.")
        ClearTonalEnhancementState()
        return False
    endif

    Bool enhanced = IronSoulNative.HeartshardApplyEnhanceSessionInventoryRow(sessionToken, selectedIndex)
    if !enhanced
        String resultText = GetHeartshardEnhanceResultText()
        NotifyHeartshardEnhanceFailure(True)
        LogHeartshards(IronSoulConfig.LOG_ERR(), "CompleteTonalEnhancement: Native Tonal apply failed type=" + heartshardType + " tier=" + heartshardTier + " result=" + resultText)
        _pendingTonalSessionToken = 0
        ClearTonalEnhancementState()
        return False
    endif
    _pendingTonalSessionToken = 0
    String enhanceResultText = GetHeartshardEnhanceResultText()

    CloseInventoryForHeartshardAction()
    PlayItemEnhancedPresentation(player)
    player.RemoveItem(heartshardBaseItem, 1, True)
    AwardHeartglass(player, heartshardType, heartshardTier)
    RegisterHeartshardUsed(player, heartshardType, heartshardTier)
    NotifyHeartshardSuccess("Tonal Heartshard strengthened " + enhanceResultText)

    LogHeartshards(IronSoulConfig.LOG_INFO(), "CompleteTonalEnhancement: Enhanced selected inventory item with Tonal Heartshard type=" + heartshardType + " tier=" + heartshardTier + " addLevels=" + addLevels + " maxLevel=" + maxTemper + " result=" + enhanceResultText)
    ClearTonalEnhancementState()
    ReopenInventoryAfterHeartshardAction(True)
    return True
EndFunction

Int Function GetTonalMaxTemperLevel()
    if Controller && Controller.Config
        Int maxTemper = Controller.Config.GetHeartshardTonalMaxTemper()
        if maxTemper >= 1 && maxTemper <= TONAL_TEMPER_CONFIG_MAX_LEVEL
            return maxTemper
        endif
    endif
    return TONAL_TEMPER_MAX_LEVEL
EndFunction

Int Function ResolveTonalAddLevels(Int heartshardTier)
    if heartshardTier <= 1
        return 1
    elseif heartshardTier == 2
        return 2
    elseif heartshardTier == 3
        return 3
    elseif heartshardTier == 4
        return 4
    endif
    return 5
EndFunction

Function ClearTonalEnhancementState()
    UnregisterForModEvent(HEARTSHARD_ITEM_SELECT_LOAD_EVENT)
    UnregisterForModEvent(HEARTSHARD_ITEM_SELECT_SELECT_EVENT)

    if _pendingTonalSessionToken > 0
        IronSoulNative.HeartshardReleaseEnhanceSession(_pendingTonalSessionToken)
    endif

    _tonalSelectionActive = False
    _tonalItemSelectActive = False
    _tonalItemSelectLoaded = False
    _tonalItemSelectFailed = False
    _tonalItemSelectNoRows = False
    _pendingTonalPlayer = None
    _pendingTonalHeartshardBaseItem = None
    _pendingTonalHeartshardType = 0
    _pendingTonalHeartshardTier = 0
    _pendingTonalSessionToken = 0
    _pendingTonalSelectedIndex = -1
    _pendingTonalMaxTemper = TONAL_TEMPER_MAX_LEVEL
EndFunction

Bool Function ShowEnhanceUnavailable(Actor player, Int heartshardType = 0, Int heartshardTier = 0)
    if HeartshardUnavailableMsg
        HeartshardUnavailableMsg.Show()
    else
        Debug.MessageBox("Heartshard item enhancement is not implemented yet.")
    endif

    LogHeartshards(IronSoulConfig.LOG_INFO(), "ShowEnhanceUnavailable: Enhancement unavailable shown type=" + heartshardType + " tier=" + heartshardTier)
    return False
EndFunction

Bool Function TryPurgeDeath(Actor player, String guid, Form heartshardBaseItem, Int heartshardType = 0, Int heartshardTier = 0)
    if !HasCoreRuntime() || !player || guid == "" || !heartshardBaseItem
        return False
    endif

    Int deathsBeforePurge = Controller.Death.GetCurrentDeathCount(player, guid)
    if deathsBeforePurge <= 0
        LogHeartshards(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: No current deaths to purge")
        return False
    endif

    Int itemCount = player.GetItemCount(heartshardBaseItem)
    if itemCount <= 0
        LogHeartshards(IronSoulConfig.LOG_ERR(), "TryPurgeDeath: Player does not have the exact Heartshard base form")
        Debug.MessageBox("The Heartshard is no longer in your inventory.")
        return False
    endif

    Int deathsAfterPurge = deathsBeforePurge - 1
    player.RemoveItem(heartshardBaseItem, 1, True)
    Controller.Death.SetCurrentDeathCount(player, guid, deathsAfterPurge)

    LogHeartshards(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: Purged one death using exact Heartshard type=" + heartshardType + " tier=" + heartshardTier + " deaths=" + deathsBeforePurge + "->" + deathsAfterPurge)

    IronSoulNative.DataFlushIfDirty()

    CloseInventoryForHeartshardAction()
    PlayDeathPurgedPresentation(player)
    AwardHeartglass(player, heartshardType, heartshardTier)
    RegisterHeartshardUsed(player, heartshardType, heartshardTier)
    Controller.Tiers.TryRestoreFromDefiant(player, guid)
    NotifyHeartshardSuccess("The Heartshard purges one death. Deaths: " + deathsBeforePurge + " -> " + deathsAfterPurge)
    ReopenInventoryAfterHeartshardAction(False)
    return True
EndFunction

Function AwardHeartglass(Actor player, Int heartshardType = 0, Int heartshardTier = 0)
    if !player
        return
    endif
    if !HeartshardSpent
        LogHeartshards(IronSoulConfig.LOG_ERR(), "AwardHeartglass: HeartshardSpent property is not wired")
        return
    endif

    player.AddItem(HeartshardSpent, 1, False)
    LogHeartshards(IronSoulConfig.LOG_INFO(), "AwardHeartglass: Awarded Heartglass for spent Heartshard type=" + heartshardType + " tier=" + heartshardTier)
EndFunction

Function PlayDeathPurgedPresentation(Actor player)
    PlayHeartshardPresentation(player, HEARTSHARD_DEATH_PURGED_MENU)
EndFunction

Function PlayItemEnhancedPresentation(Actor player)
    PlayHeartshardPresentation(player, HEARTSHARD_ITEM_ENHANCED_MENU)
EndFunction

Function PlayHeartshardPresentation(Actor player, String menuName)
    if !player
        return
    endif
    if Controller && Controller.Config && !Controller.Config.IsHeartshardMessageEnabled()
        PlayHeartshardSFX(player)
        return
    endif
    if menuName == ""
        return
    endif

    Controller.Presentation.FadeMusicForTransitionSequence()
    UI.CloseCustomMenu()
    UI.OpenCustomMenu(menuName, 0)
    PlayHeartshardSFX(player)
    Controller.Presentation.WaitKeyDismissMenu(HEARTSHARD_PRESENTATION_MAX_SECONDS, HEARTSHARD_PRESENTATION_DISMISS_SECONDS)
    Controller.Presentation.RestoreMusic()
EndFunction

Function PlayHeartshardSFX(Actor player)
    if !player || !SFXHeartshardAbsorb
        return
    endif
    if !Controller || !Controller.Config
        return
    endif
    if IronSoulSFX.CanPlaySFX(Controller.Config.IsSFXEnabled(), Controller.Config.IsUninstallMode(), Controller.IsModDisabled()) && Controller.Config.IsHeartshardAbsorbSFXEnabled()
        SFXHeartshardAbsorb.Play(player)
    endif
EndFunction
