Scriptname IronSoulHeartstones extends Quest

Import b612

; Compile note: Tonal Heartstone enhancement uses B612's classic
; b612_ItemSelect API. Full B612 bundles the matching runtime PEX, but its
; source package may only include a deprecated placeholder for this script, so
; the reference source may need the older compilable b612_ItemSelect source.

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
String HEARTSTONE_ITEM_SELECTION_STATE = "HeartstoneItemSelection"
String HEARTSTONE_ITEM_ENHANCED_MENU = "heartstoneitemenhanced"
String HEARTSTONE_DEATH_PURGED_MENU = "heartstonedeathpurged"
Float HEARTSTONE_PRESENTATION_MAX_SECONDS = 8.0
Float HEARTSTONE_PRESENTATION_DISMISS_SECONDS = 4.2
Float TONAL_ITEM_CAPTURE_TIMEOUT_SECONDS = 3.0

Bool _handlingUse = False
Bool _tonalSelectionActive = False
Bool _tonalSelectionMade = False
Bool _tonalItemCaptured = False
Actor _pendingTonalPlayer = None
Form _pendingTonalHeartstoneBaseItem = None
Int _pendingTonalHeartstoneType = 0
Int _pendingTonalHeartstoneTier = 0
ObjectReference _pendingTonalItemRef = None
b612_ItemSelect _tonalItemSelect = None

Function ResetTransientState()
    _handlingUse = False
    ClearTonalEnhancementState(False)
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

    b612_ItemSelect itemSelect = b612.GetItemSelect()
    if !itemSelect
        LogHeartstones(IronSoulConfig.LOG_ERR(), "TryEnhanceTonalItem: B612 item select is not available")
        Debug.MessageBox("B612 item selection is not available.")
        return False
    endif

    if !StartTonalEnhancementState(player, heartstoneBaseItem, heartstoneType, heartstoneTier, itemSelect)
        return False
    endif

    RegisterForModEvent("b612_ItemSelect_Select", "Onb612_ItemSelect_Select")
    Int selectedIndex = itemSelect.Show(0, False, "VendorItemWeapon,VendorItemArmor")
    UnregisterForModEvent("b612_ItemSelect_Select")

    Bool itemSelected = _tonalSelectionMade || selectedIndex >= 0
    Bool itemCaptured = False
    if itemSelected
        itemCaptured = WaitForTonalSelectedItem()
    endif

    StopHeartstoneItemSelectionListener()

    if !itemSelected
        LogHeartstones(IronSoulConfig.LOG_INFO(), "TryEnhanceTonalItem: Tonal enhancement selection canceled type=" + heartstoneType + " tier=" + heartstoneTier)
        ClearTonalEnhancementState(False)
        return False
    endif
    if !itemCaptured || !_pendingTonalItemRef
        LogHeartstones(IronSoulConfig.LOG_ERR(), "TryEnhanceTonalItem: Selected item was not captured type=" + heartstoneType + " tier=" + heartstoneTier)
        ClearTonalEnhancementState(False)
        return False
    endif

    return CompleteTonalEnhancement()
EndFunction

Bool Function StartTonalEnhancementState(Actor player, Form heartstoneBaseItem, Int heartstoneType, Int heartstoneTier, b612_ItemSelect itemSelect)
    ClearTonalEnhancementState(False)

    IronSoulPlayerAlias playerAlias = ResolvePlayerAlias()
    if !playerAlias
        LogHeartstones(IronSoulConfig.LOG_ERR(), "StartTonalEnhancementState: Player alias is not available")
        return False
    endif

    _tonalSelectionActive = True
    _tonalSelectionMade = False
    _tonalItemCaptured = False
    _pendingTonalPlayer = player
    _pendingTonalHeartstoneBaseItem = heartstoneBaseItem
    _pendingTonalHeartstoneType = heartstoneType
    _pendingTonalHeartstoneTier = heartstoneTier
    _pendingTonalItemRef = None
    _tonalItemSelect = itemSelect

    playerAlias.GoToState(HEARTSTONE_ITEM_SELECTION_STATE)
    LogHeartstones(IronSoulConfig.LOG_INFO(), "StartTonalEnhancementState: Started Tonal item selection tier=" + heartstoneTier)
    return True
EndFunction

Function HandleHeartstoneSelectedItem(ObjectReference selectedItemRef)
    if !_tonalSelectionActive || !_tonalSelectionMade
        return
    endif
    if _tonalItemCaptured
        return
    endif
    if !selectedItemRef
        return
    endif

    _pendingTonalItemRef = selectedItemRef
    _tonalItemCaptured = True
    LogHeartstones(IronSoulConfig.LOG_INFO(), "HandleHeartstoneSelectedItem: Captured selected Tonal item ref")
EndFunction

Event Onb612_ItemSelect_Select(String eventName, String strArg, Float numArg, Form formArg)
    if !_tonalSelectionActive
        return
    endif
    if _tonalSelectionMade
        return
    endif

    _tonalSelectionMade = True
    if _tonalItemSelect
        _tonalItemSelect.DropItem(1)
        Utility.WaitMenuMode(0.1)
        _tonalItemSelect.CloseMenu("InventoryMenu")
    else
        LogHeartstones(IronSoulConfig.LOG_ERR(), "Onb612_ItemSelect_Select: B612 item select reference is missing")
    endif
EndEvent

Bool Function WaitForTonalSelectedItem()
    Float remaining = TONAL_ITEM_CAPTURE_TIMEOUT_SECONDS
    while remaining > 0.0 && !_tonalItemCaptured
        Utility.Wait(0.1)
        remaining -= 0.1
    endwhile
    return _tonalItemCaptured
EndFunction

Bool Function CompleteTonalEnhancement()
    Actor player = _pendingTonalPlayer
    Form heartstoneBaseItem = _pendingTonalHeartstoneBaseItem
    Int heartstoneType = _pendingTonalHeartstoneType
    Int heartstoneTier = _pendingTonalHeartstoneTier
    ObjectReference selectedItemRef = _pendingTonalItemRef

    if !player || !heartstoneBaseItem || !selectedItemRef
        ClearTonalEnhancementState(True)
        return False
    endif

    Float targetTemper = GetTonalTemperTarget(heartstoneTier)
    String itemType = ResolveTonalItemType(selectedItemRef)
    if itemType == ""
        Debug.Notification("The Heartstone cannot strengthen that item.")
        LogHeartstones(IronSoulConfig.LOG_INFO(), "CompleteTonalEnhancement: Selected item was not weapon or armor type=" + heartstoneType + " tier=" + heartstoneTier)
        ClearTonalEnhancementState(True)
        return False
    endif

    Float currentTemper = selectedItemRef.GetItemHealthPercent()
    if !CanEnhanceTonalItem(selectedItemRef, targetTemper)
        Debug.Notification("The Heartstone cannot strengthen that item further.")
        LogHeartstones(IronSoulConfig.LOG_INFO(), "CompleteTonalEnhancement: Selected " + itemType + " already meets Tonal target tier=" + heartstoneTier + " current=" + currentTemper + " target=" + targetTemper)
        ClearTonalEnhancementState(True)
        return False
    endif
    if player.GetItemCount(heartstoneBaseItem) <= 0
        LogHeartstones(IronSoulConfig.LOG_ERR(), "CompleteTonalEnhancement: Player no longer has exact Tonal Heartstone base form")
        Debug.MessageBox("The Heartstone is no longer in your inventory.")
        ClearTonalEnhancementState(True)
        return False
    endif

    PlayItemEnhancedPresentation(player)

    Bool enhanced = False
    if itemType == "weapon"
        enhanced = ApplyTonalWeaponEnhancement(selectedItemRef, targetTemper)
    elseif itemType == "armor"
        enhanced = ApplyTonalArmorEnhancement(selectedItemRef, targetTemper)
    endif

    if !enhanced
        Debug.Notification("The Heartstone cannot strengthen that item further.")
        LogHeartstones(IronSoulConfig.LOG_INFO(), "CompleteTonalEnhancement: Selected " + itemType + " could not be enhanced after presentation tier=" + heartstoneTier + " target=" + targetTemper)
        ClearTonalEnhancementState(True)
        return False
    endif

    player.AddItem(selectedItemRef, 1, True)
    player.RemoveItem(heartstoneBaseItem, 1, True)
    AwardHeartglass(player, heartstoneType, heartstoneTier)

    LogHeartstones(IronSoulConfig.LOG_INFO(), "CompleteTonalEnhancement: Enhanced " + itemType + " with Tonal Heartstone type=" + heartstoneType + " tier=" + heartstoneTier + " current=" + currentTemper + " target=" + targetTemper)
    ClearTonalEnhancementState(False)
    return True
EndFunction

String Function ResolveTonalItemType(ObjectReference selectedItemRef)
    if !selectedItemRef
        return ""
    endif

    Form selectedBase = selectedItemRef.GetBaseObject()
    if selectedBase as Weapon
        return "weapon"
    elseif selectedBase as Armor
        return "armor"
    endif
    return ""
EndFunction

Bool Function CanEnhanceTonalItem(ObjectReference selectedItemRef, Float targetTemper)
    if !selectedItemRef || targetTemper < 1.1
        return False
    endif
    if selectedItemRef.GetItemHealthPercent() >= targetTemper
        return False
    endif
    return True
EndFunction

Bool Function ApplyTonalWeaponEnhancement(ObjectReference selectedItemRef, Float targetTemper)
    if !CanEnhanceTonalItem(selectedItemRef, targetTemper)
        return False
    endif
    selectedItemRef.SetItemHealthPercent(targetTemper)
    return True
EndFunction

Bool Function ApplyTonalArmorEnhancement(ObjectReference selectedItemRef, Float targetTemper)
    if !CanEnhanceTonalItem(selectedItemRef, targetTemper)
        return False
    endif
    selectedItemRef.SetItemHealthPercent(targetTemper)
    return True
EndFunction

Float Function GetTonalTemperTarget(Int heartstoneTier)
    if heartstoneTier <= 1
        return 1.2
    elseif heartstoneTier == 2
        return 1.3
    elseif heartstoneTier == 3
        return 1.4
    elseif heartstoneTier == 4
        return 1.5
    endif
    return 1.6
EndFunction

IronSoulPlayerAlias Function ResolvePlayerAlias()
    return GetAlias(0) as IronSoulPlayerAlias
EndFunction

Function StopHeartstoneItemSelectionListener()
    IronSoulPlayerAlias playerAlias = ResolvePlayerAlias()
    if playerAlias
        playerAlias.GoToState("")
    endif
EndFunction

Function ClearTonalEnhancementState(Bool returnSelectedItem = False)
    UnregisterForModEvent("b612_ItemSelect_Select")
    StopHeartstoneItemSelectionListener()

    if returnSelectedItem && _pendingTonalPlayer && _pendingTonalItemRef
        _pendingTonalPlayer.AddItem(_pendingTonalItemRef, 1, True)
    endif

    _tonalSelectionActive = False
    _tonalSelectionMade = False
    _tonalItemCaptured = False
    _pendingTonalPlayer = None
    _pendingTonalHeartstoneBaseItem = None
    _pendingTonalHeartstoneType = 0
    _pendingTonalHeartstoneTier = 0
    _pendingTonalItemRef = None
    _tonalItemSelect = None
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

    player.RemoveItem(heartstoneBaseItem, 1, True)
    Controller.Death.SetCurrentDeathCount(player, guid, deathsBeforePurge - 1)

    LogHeartstones(IronSoulConfig.LOG_INFO(), "TryPurgeDeath: Purged one death using exact Heartstone type=" + heartstoneType + " tier=" + heartstoneTier + " deaths=" + deathsBeforePurge + "->" + (deathsBeforePurge - 1))

    IronSoulNative.DataFlushIfDirty()

    PlayDeathPurgedPresentation(player)
    AwardHeartglass(player, heartstoneType, heartstoneTier)
    Controller.Tiers.TryRestoreFromDefiant(player, guid)
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
