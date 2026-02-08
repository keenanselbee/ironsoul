Scriptname IronSoulDSROnDying extends ActiveMagicEffect

Spell Property RestoreSpell Auto
Spell Property DisSpell Auto
Bool Property bDispel = True Auto

Float Property time1 = 6.0 Auto ; Time delay of revive
Float Property time2 = 3.0 Auto ; Time delay of restore full health, magicka and stamina
Float Property time3 = 1.0 Auto ; Time delay of getup after revive spell cast
Float Property time4 = 3.0 Auto ; Time of Ghost status remains after get up
Float Property time5 = 3.0 Auto ; Time of revive spell remains after Ghost status has ended
FormList Property BeastList Auto
Globalvariable Property IronSoul_DSR_IsDead Auto
GlobalVariable Property IronSoul_DSR_Enabled Auto ; 1.0 = enabled, 0.0 = disabled (set by Controller)

IronSoulController Property Controller Auto ; Iron Soul controller (for tier/Defiant menu resolution)

Function Trace(Int level, String msg)
	if Controller
	    Controller.LogMsg(level, "[DSR] " + msg)
	else
	    ; Fallback if Controller missing (should never happen in your setup)
	    Debug.Trace("[IronSoul] [DSR] " + msg)
	endif
EndFunction

Bool Function IsDSREnabled()
	if IronSoul_DSR_Enabled
		return (IronSoul_DSR_Enabled.GetValue() != 0.0)
	endif
	return True ; fail-open if property not filled
EndFunction

String Function ResolveDSRMenuName(Actor player)
	; If the Controller is present, trust its resolution fully.
	; An empty string means "do not show a DSR message" (e.g., DisableDragonSoulReviveMessage=1).
	if Controller
	    return Controller.ResolveDragonSoulReviveMenu(player)
	endif
	; Fallback only if Controller/property isn't filled.
	return "1irondragonsoulrevive"
EndFunction

Function ShowDSRMenu(String menuName, Actor player)
	if menuName == ""
	    Trace(Controller.LOG_INFO(), "ShowDSRMenu: menuName empty (message suppressed).")
	    return
	endif
	if !UI.IsMenuOpen(menuName)
	    Trace(Controller.LOG_INFO(), "Opening DSR menu: " + menuName)
	    if Controller
	        Trace(Controller.LOG_DBG(), "Playing DSR SFX: SFXDragonSoulRevive")
	        Controller.PlaySFX(Controller.SFXDragonSoulRevive, player)
	    else
	        Trace(Controller.LOG_ERR(), "Controller missing; cannot play DSR SFX.")
	    endif
	    UI.OpenCustomMenu(menuName, 0)
	    Utility.WaitMenuMode(4.0)
	    UI.CloseCustomMenu()
	endif
EndFunction

Bool Property bPlaysound = True Auto ;Play Sound or not
sound property NPCDragonDeathSequenceWind Auto
sound property NPCDragonDeathSequenceExplosion Auto

Bool Property bPlayVisualEffect = True Auto ;Play VisualEffect or not
VisualEffect Property AbsorbEffect Auto
VisualEffect Property AbsorbEffectTarget Auto
Float Property Playtime = 8.0 Auto ; How long AbsorbEffect plays

Activator Property Marker Auto

WorldSpace Property DLC2ApocryphaWorld Auto
Quest Property DLC2MQ06 Auto

Objectreference MarkerRef

Event OnEffectStart(Actor Target, Actor Caster)

	Trace(Controller.LOG_INFO(), "OnEffectStart: Target=" + Target + " Caster=" + Caster)

	;Debug.Notification("Start OnDying")
	; If Iron Soul disables Dragon Soul Revive, exit immediately and allow normal death.
	if !IsDSREnabled()
	    Target.EndDeferredKill()
	    return
	endif
	if bDispel
	    DisSpell.Cast(Target, Target)
	endif
	;if Target.IsEssential() || (Target.GetWorldSpace() == DLC2ApocryphaWorld && !(DLC2MQ06.GetStage()>=400 && DLC2MQ06.GetStage()<500))
	if Target.IsEssential()

	    Trace(Controller.LOG_INFO(), "Target is Essential: running essential path (deferred kill cycle).")

	    ;Debug.Notification("IsEssential")
	    ;Target.DamageAV("Health", 1000)
	    Target.EndDeferredKill()
	    ;game.EnablePlayerControls()
	    Utility.Wait(time1)

	    Trace(Controller.LOG_DBG(), "Revive delay elapsed (time1=" + time1 + "). Checking dragon soul/race gates...")
	    ;Target.RestoreAV("Health", Target.GetAVMax("Health")-Target.GetAV("Health"))
	    Target.StartDeferredKill()

	else

	    IronSoul_DSR_IsDead.SetValue(1)
	    Target.SetGhost(true)
	    Target.PushActorAway(Target, 0.1)
	    Target.SetAV("Paralysis", 1.0)
	    Target.RestoreAV("Health", -(Target.GetAV("Health")+100))

	    Utility.Wait(time1)

	    if  !(BeastList.hasform(Target.GetRace())) && (Target.GetAV("DragonSouls") >= 1)
	        Trace(Controller.LOG_INFO(), "DSR eligible: consuming 1 DragonSoul and showing DSR UI (if enabled).")
	        ;Debug.Notification("Cast Spell")

	        Target.DamageAV("DragonSouls", 1.0)
	        ; Contextual Dragon Soul Revive menu (tier/Defiant) – shown for 4 seconds.
	        String menuName = ResolveDSRMenuName(Target)
	        Trace(Controller.LOG_DBG(), "Resolved DSR menuName=\"" + menuName + "\"")
	        ShowDSRMenu(menuName, Target)
	        Target.AddSpell(RestoreSpell,false)
	        IronSoul_DSR_IsDead.SetValue(0)


	        if bPlayVisualEffect
	            MarkerRef = Target.PlaceAtMe(Marker)
	            MarkerRef.MoveTo(Target)
	            AbsorbEffect.Play(MarkerRef, Playtime, Target)
	            AbsorbEffectTarget.Play(Target, Playtime, MarkerRef)
	        endif

	        if bPlaysound
	            NPCDragonDeathSequenceWind.play(Target)
	            NPCDragonDeathSequenceExplosion.play(Target)
	        endif

	        Utility.Wait(time2)

	        Target.RestoreAV("Stamina", Target.GetAVMax("Stamina"))
	        Target.RestoreAV("Magicka", Target.GetAVMax("Magicka"))
	        Target.RestoreAV("Health", Target.GetAVMax("Health")-Target.GetAV("Health"))


	    else
	        ;Debug.Notification("DO not Cast")
	        Target.EndDeferredKill()

	    endif
	endif

Endevent

Event OnEffectFinish(Actor Target, Actor Caster)

	Trace(Controller.LOG_INFO(), "OnEffectFinish: Target=" + Target + " Caster=" + Caster)

	;Debug.Notification("Finish OnDying")

	; If disabled, do minimal cleanup and exit (avoid long waits).
	if !IsDSREnabled()
	    Target.SetAV("Paralysis", 0.0)
	    Target.SetGhost(false)
	    Target.RemoveSpell(RestoreSpell)
	    if (MarkerRef != none)
	        MarkerRef.disable()
	        MarkerRef.delete()
	    endif
	    return
	endif

	Utility.Wait(time3)
	Target.SetAV("Paralysis", 0.0)
	Utility.Wait(time4)
	Target.SetGhost(false)
	Utility.Wait(time5)
	Target.RemoveSpell(RestoreSpell)

	if (MarkerRef != none)
	    MarkerRef.disable()
	    MarkerRef.delete()
	endif

Endevent
