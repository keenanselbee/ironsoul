Scriptname IronSoulItemSunderheart extends ObjectReference

IronSoulController Property Controller Auto
MiscObject Property SunderheartBaseItem Auto
Int Property SunderheartType = 0 Auto
Int Property SunderheartTier = 0 Auto

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
    if Controller && Controller.Sunderhearts
        if SunderheartBaseItem
            Controller.Sunderhearts.TryUseSunderheart(Game.GetPlayer(), SunderheartBaseItem, SunderheartType, SunderheartTier)
        else
            Debug.MessageBox("Iron Soul Sunderheart item is not configured.")
        endif
    else
        Debug.MessageBox("Iron Soul Sunderhearts are not configured.")
    endif
EndFunction
