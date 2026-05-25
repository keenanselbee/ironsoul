Scriptname IronSoulItemHeartstone extends ObjectReference

Message Property UseMessage Auto
Bool Property ShowPrototypeMessage = True Auto

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
    if UseMessage
        UseMessage.Show()
    elseif ShowPrototypeMessage
        Debug.MessageBox("Heartstone use detected.")
    endif
EndFunction
