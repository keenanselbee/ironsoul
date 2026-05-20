Scriptname _DS_DN_Ref_DeathReport extends ReferenceAlias  

bool Property RegisterLoadingAndUnloading = False Auto

bool Property DisableOnUnload = False Auto

bool attached	;My cell has attached or I moved into an attached cell   (OR - rare/impossible: tried to detach before ever trying to attach)
bool detached	;My cell has detached or I moved into a detached cell   (OR - rare/impossible: tried to detach before ever trying to attach)


Event OnDeath(Actor akKiller)
	(GetOwningQuest() as _DS_DN_ExhaustHandler).ReportDeath()
EndEvent


Event OnCellAttach()
	TryToAttach()
EndEvent

Event OnAttachedToCell()
	TryToAttach()
EndEvent

Event OnCellDetach()
	TryToDetach()
EndEvent

Event OnDetachedFromCell()
	TryToDetach()
EndEvent


Event OnLoad()
	TryToAttach()
EndEvent

Event OnUnload()
	TryToDetach()
	
	if DisableOnUnload
		;GetReference().Disable()
	EndIf
	
EndEvent

;*** DON'T TRACE IN HERE BEFORE SETTING THE ATTACH/DETACHED VARS - for thread safety
Function TryToAttach()
	If attached || detached
		Return		
	Else
		Attached  = true
		If RegisterLoadingAndUnloading 
			(GetOwningQuest() as _DS_DN_ExhaustHandler).AliasLoadingOrUnloading(IsLoading = True)
		EndIf		
	EndIf
EndFunction

;*** DON'T TRACE IN HERE BEFORE SETTING THE ATTACH/DETACHED VARS - for thread safety
Function TryToDetach()
	If detached
		Return
	ElseIf attached
		Detached = True
		If RegisterLoadingAndUnloading
			(GetOwningQuest() as _DS_DN_ExhaustHandler).AliasLoadingOrUnloading(IsLoading = False)
		EndIf
	Else ; we haven’t attached or detached yet, so we didn’t really exist, do nothing and force ignoring everything else
		Detached = true
		Attached = true
		;*** tell quest to clean up if everyone else is gone – but do NOT decrement, because we never incremented
		(GetOwningQuest() as _DS_DN_ExhaustHandler).RegisterForStopQuest()
	Endif
EndFunction
