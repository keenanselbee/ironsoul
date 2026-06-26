Scriptname OghmaInfiniumScript extends ObjectReference

String Property oghmaReadWorldKey = "OG.R.W" AutoReadOnly

Function LogOghma(String msg)
    Debug.Trace("[IronSoul] [I] [Oghma] " + msg)
EndFunction

String Function BoolText(Bool value)
    if value
        return "TRUE"
    endif

    return "FALSE"
EndFunction

Function ReadOghmaInfinium(String source)
    GoToState("Reading")

    LogOghma(source + ": handling read; bookMenuBefore=" + BoolText(UI.IsMenuOpen("Book Menu")))

    IronSoulNative.DataSetIntIfChanged(oghmaReadWorldKey, 1)

    String guid = IronSoulNative.IdentityGetCurrentGuid()
    Bool refreshed = IronSoulNative.DynamicBookRefreshOghma(guid)
    LogOghma(source + ": refreshed Oghma text for GUID '" + guid + "' = " + BoolText(refreshed))

    IronSoulNative.DataFlushIfDirty()

    LogOghma(source + ": completed; bookMenuAfter=" + BoolText(UI.IsMenuOpen("Book Menu")))

    GoToState("")
EndFunction

Event OnEquipped(Actor reader)
    if reader != Game.GetPlayer()
        return
    endif

    ReadOghmaInfinium("OnEquipped")
EndEvent

Event OnActivate(ObjectReference reader)
    if reader != Game.GetPlayer() || IsActivationBlocked()
        return
    endif

    ReadOghmaInfinium("OnActivate")
EndEvent

State Reading
    Function ReadOghmaInfinium(String source)
    EndFunction
EndState
