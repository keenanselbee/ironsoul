Scriptname IronSoulItemHeartshard extends ObjectReference

IronSoulController Property Controller Auto
MiscObject Property HeartshardBaseItem Auto
Int Property HeartshardType = 0 Auto
Int Property HeartshardTier = 0 Auto

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
    if Controller && Controller.Heartshards
        if HeartshardBaseItem
            Controller.Heartshards.TryUseHeartshard(Game.GetPlayer(), HeartshardBaseItem, HeartshardType, HeartshardTier)
        else
            Debug.MessageBox("Iron Soul Heartshard item is not configured.")
        endif
    else
        Debug.MessageBox("Iron Soul Heartshards are not configured.")
    endif
EndFunction
