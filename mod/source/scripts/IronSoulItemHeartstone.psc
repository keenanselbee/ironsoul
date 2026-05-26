Scriptname IronSoulItemHeartstone extends ObjectReference

IronSoulController Property Controller Auto
MiscObject Property HeartstoneBaseItem Auto
Int Property HeartstoneType = 0 Auto
Int Property HeartstoneTier = 0 Auto

Bool _handlingUse = False

Event OnEquipped(Actor akActor)
    if akActor != Game.GetPlayer()
        return
    endif
    if _handlingUse
        return
    endif

    _handlingUse = True
    HandleUse()
    Utility.WaitMenuMode(0.3)
    _handlingUse = False
EndEvent

Function HandleUse()
    if Controller && Controller.Heartstones
        if HeartstoneBaseItem
            Controller.Heartstones.TryUseHeartstone(Game.GetPlayer(), HeartstoneBaseItem, HeartstoneType, HeartstoneTier)
        else
            Debug.MessageBox("Iron Soul Heartstone item is not configured.")
        endif
    else
        Debug.MessageBox("Iron Soul Heartstones are not configured.")
    endif
EndFunction
