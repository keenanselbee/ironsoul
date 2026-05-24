Scriptname IronSoulPlayerAlias extends ReferenceAlias

IronSoulController Property Controller Auto

Function LogPlayerAlias(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("PlayerAlias", level, msg, suppressNotify)
        return
    endif

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [" + levelText + "] [PlayerAlias] " + msg)
EndFunction

Event OnInit()
    LogPlayerAlias(IronSoulConfig.LOG_INFO(), "IronSoulPlayerAlias: OnInit event fired")
EndEvent

Event OnPlayerLoadGame()
    if Controller
        Controller.OnPlayerLoadGame(True)
    else
        LogPlayerAlias(IronSoulConfig.LOG_ERR(), "PlayerAlias OnPlayerLoadGame: Controller property is None (alias not wired?)")
    endif
EndEvent
