Scriptname IronSoulItemSunderheart extends ObjectReference

IronSoulController Property Controller Auto
MiscObject Property SunderheartBaseItem Auto
Int Property SunderheartType = 0 Auto
Int Property SunderheartTier = 0 Auto

Event OnEquipped(Actor akActor)
    if akActor != Game.GetPlayer()
        return
    endif
    if Controller && Controller.Sunderhearts
        if SunderheartBaseItem
            Controller.Sunderhearts.SubmitSunderheartUseIntent(Game.GetPlayer(), SunderheartBaseItem, SunderheartType, SunderheartTier, "item-equipped")
        else
            Debug.MessageBox("Iron Soul Sunderheart item is not configured.")
        endif
    else
        Debug.MessageBox("Iron Soul Sunderhearts are not configured.")
    endif
EndEvent
