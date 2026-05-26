Scriptname SKI_WidgetBase extends Quest

Bool Property Ready = False Auto
String Property HUD_MENU = "HUD Menu" AutoReadOnly
String Property WidgetRoot = "" Auto

String Function GetWidgetSource()
    return ""
EndFunction

String Function GetWidgetType()
    return ""
EndFunction

Event OnWidgetReset()
EndEvent
