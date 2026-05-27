Scriptname IronSoulItemShardheart extends ObjectReference

IronSoulController Property Controller Auto
MiscObject Property ShardheartBaseItem Auto
Int Property ShardheartType = 0 Auto
Int Property ShardheartTier = 0 Auto

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
    if Controller && Controller.Shardhearts
        if ShardheartBaseItem
            Controller.Shardhearts.TryUseShardheart(Game.GetPlayer(), ShardheartBaseItem, ShardheartType, ShardheartTier)
        else
            Debug.MessageBox("Iron Soul Shardheart item is not configured.")
        endif
    else
        Debug.MessageBox("Iron Soul Shardhearts are not configured.")
    endif
EndFunction
