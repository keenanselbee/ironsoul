Scriptname IronSoulDragonSoulRevive extends Quest

; =========================
; --- Table of Contents ---
; =========================

; --- Component Helpers ---
; -------------------------
; HasCoreRuntime()
; HasPersistenceRuntime()
; ReleaseDeathLock()
; LogDragonSoulRevive()

; --- Dragon Soul Revive Runtime ---
; ----------------------------------
; ResetTransientState()
; IsAvailable()
; HandleRevive()
; SyncLimitState()
; ResolveMenu()
; RemoveTrackedData()

; --- Dragon Soul Revive Helpers ---
; ----------------------------------
; RefreshRollingLimitUses()
; RecordLimitUse()
; ShaderParticleIntro()
; ShaderParticleOutro()
; PlayDragonSoulReviveSFX()
; RestoreVitals()
; CanAttemptRevive()
; IsBlockedByRollingLimit()
; ResolveDSRMenuFromFacts()
; ShouldSpendDragonSoul()


; --- Wired Dependencies & Runtime State ---
; ==========================================

IronSoulController Property Controller Auto

String Property dsrLimitLastSec   = "IS_8201" AutoReadOnly
String Property dsrLimitPlayedSec = "IS_8202" AutoReadOnly
String Property dsrLimitUse1      = "IS_8203" AutoReadOnly
String Property dsrLimitUse2      = "IS_8204" AutoReadOnly
String Property dsrLimitUse3      = "IS_8205" AutoReadOnly

Spell Property RestoreSpell Auto
Spell Property DisSpell Auto
Bool Property bDispel = True Auto
; Iron Soul-owned wind SFX for Cinematic Dragon Soul Absorb compatibility.
Sound Property SFXDragonSoulReviveWind Auto
Sound Property NPCDragonDeathSequenceExplosion Auto
VisualEffect Property AbsorbEffect Auto
VisualEffect Property AbsorbEffectTarget Auto
Activator Property Marker Auto

ImageSpaceModifier Property IntroFX Auto
ImageSpaceModifier Property StaticFX Auto
ImageSpaceModifier Property OutroFX Auto
ShaderParticleGeometry Property PSGD Auto

Sound Property SFXDragonSoulReviveCast1 Auto
Sound Property SFXDragonSoulReviveCast2 Auto
Sound Property SFXDragonSoulReviveCast3 Auto
Sound Property SFXDragonSoulReviveCast4 Auto
Sound Property SFXDragonSoulRevive1 Auto
Sound Property SFXDragonSoulRevive2 Auto
Sound Property SFXDragonSoulRevive3 Auto
Sound Property SFXDragonSoulRevive4 Auto

ObjectReference MarkerRef
Bool _imageSpaceIsFinishing = False


; --- Component Helpers ---
; =========================

Bool Function HasCoreRuntime()
    if !Controller
        return False
    endif
    if !Controller.Config || !Controller.Persistence
        return False
    endif
    return True
EndFunction

Bool Function HasPersistenceRuntime()
    if !Controller
        return False
    endif
    if !Controller.Persistence
        return False
    endif
    return True
EndFunction

Function ReleaseDeathLock()
    if Controller && Controller.Death
        Controller.Death.ClearDeathEventLock()
    endif
EndFunction

Function LogDragonSoulRevive(Int level, String msg, Bool suppressNotify = False)
    if Controller && Controller.Config
        Controller.Config.LogComponentMsg("DragonSoulRevive", level, msg, suppressNotify)
        return
    endif

    String levelText = "ERR"
    if level == IronSoulConfig.LOG_DBG()
        levelText = "DBG"
    elseif level == IronSoulConfig.LOG_INFO()
        levelText = "INFO"
    endif
    Debug.Trace("[IronSoul] [" + levelText + "] [DragonSoulRevive] " + msg)
EndFunction


; --- Dragon Soul Revive Runtime ---
; ==================================

Function ResetTransientState()
    MarkerRef = None
    _imageSpaceIsFinishing = False
EndFunction

Bool Function IsAvailable(Actor player, String guid)
    if !HasCoreRuntime() || !player
        return False
    endif

    Int soulTier = 1
    if guid != ""
        if Controller.Tiers
            soulTier = Controller.Tiers.GetCurrentTier(player, guid)
        endif
    endif

    Float souls = player.GetAV("DragonSouls")
    if !CanAttemptRevive(player, Controller.Config.IsDragonSoulReviveEnabled(), Controller.Config.IsDragonSoulReviveTransformEnabled(), Controller.BeastList, soulTier, souls)
        return False
    endif

    if Controller.Config.GetDragonSoulReviveLimit() == 0 || guid == ""
        return True
    endif

    SyncLimitState(player, guid)
    Int playedNow = Controller.Persistence.GetGuidInt(player, guid, dsrLimitPlayedSec, 0)
    Int recentUses = RefreshRollingLimitUses(player, guid, playedNow)
    if IsBlockedByRollingLimit(Controller.Config.GetDragonSoulReviveLimit(), guid != "", recentUses)
        LogDragonSoulRevive(IronSoulConfig.LOG_DBG(), "IsDSRAvailable: blocked by rolling limit", True)
        return False
    endif

    return True
EndFunction

Function HandleRevive(Actor target, Actor caster, String guid)
    if !HasCoreRuntime() || !target
        ReleaseDeathLock()
        return
    endif

    IronSoulConfig config = Controller.Config
    IronSoulPersistence persistence = Controller.Persistence
    IronSoulDeath death = Controller.Death
    IronSoulTiers tiers = Controller.Tiers
    IronSoulUI presentation = Controller.Presentation
    Int reviveLimit = config.GetDragonSoulReviveLimit()

    if !death || !tiers || !presentation
        ReleaseDeathLock()
        return
    endif

    if !config.IsDragonSoulReviveEnabled()
        LogDragonSoulRevive(IronSoulConfig.LOG_DBG(), "HandleDragonSoulRevive: Skipped - Dragon Soul Revive is DISABLED")
        ReleaseDeathLock()
        return
    endif

    LogDragonSoulRevive(IronSoulConfig.LOG_INFO(), "HandleDragonSoulRevive: Target=" + target + " Caster=" + caster + " GUID=" + guid)

    Int menuBlockToken = IronSoulNative.BeginMenuBlock("dragon-soul-revive", False)

    Int soulTierDSR = 1
    if guid != ""
        soulTierDSR = tiers.GetCurrentTier(target, guid)
    endif

    ; Devour-tier DSR is free and does not spend a dragon soul.
    if ShouldSpendDragonSoul(soulTierDSR)
        target.DamageAV("DragonSouls", 1.0)
    endif

    if reviveLimit > 0 && guid != ""
        SyncLimitState(target, guid)
        Int dsrPlayedNow = persistence.GetGuidInt(target, guid, dsrLimitPlayedSec, 0)
        Int recentUsesBeforeRecord = RefreshRollingLimitUses(target, guid, dsrPlayedNow)
        if recentUsesBeforeRecord == (reviveLimit - 1)
            LogDragonSoulRevive(IronSoulConfig.LOG_DBG(), "HandleDragonSoulRevive: revive reached rolling cap limit=" + reviveLimit, True)
        endif
        RecordLimitUse(target, guid, dsrPlayedNow)
        IronSoulNative.DataFlushIfDirty()
    endif

    if bDispel
        if DisSpell
            DisSpell.Cast(target, target)
        else
            LogDragonSoulRevive(IronSoulConfig.LOG_ERR(), "HandleDragonSoulRevive: bDispel enabled but DisSpell is None; skipping dispel cast")
        endif
    endif

    Bool willShowIronIntro = presentation.ShouldShowIronIntro(target, guid)
    if willShowIronIntro
        Utility.Wait(1.0)
    endif

    Bool introShown = presentation.ShowIronIntro(target, guid)

    if Marker
        MarkerRef = target.PlaceAtMe(Marker)
        if MarkerRef
            MarkerRef.MoveTo(target)
        endif
        Utility.Wait(0.1)
    else
        MarkerRef = None
        LogDragonSoulRevive(IronSoulConfig.LOG_ERR(), "HandleDragonSoulRevive: Marker property is None; skipping absorb VFX anchor")
    endif

    if MarkerRef && MarkerRef.Is3DLoaded()
        if AbsorbEffect
            AbsorbEffect.Play(MarkerRef, 8.0, target)
        else
            LogDragonSoulRevive(IronSoulConfig.LOG_ERR(), "HandleDragonSoulRevive: AbsorbEffect is None; skipping source VFX")
        endif
        if AbsorbEffectTarget
            AbsorbEffectTarget.Play(target, 8.0, MarkerRef)
        else
            LogDragonSoulRevive(IronSoulConfig.LOG_ERR(), "HandleDragonSoulRevive: AbsorbEffectTarget is None; skipping target VFX")
        endif
    else
        LogDragonSoulRevive(IronSoulConfig.LOG_DBG(), "HandleDragonSoulRevive: MarkerRef has no 3D; skipping AbsorbEffect.Play")
    endif

    if SFXDragonSoulReviveWind
        SFXDragonSoulReviveWind.Play(target)
    else
        LogDragonSoulRevive(IronSoulConfig.LOG_ERR(), "HandleDragonSoulRevive: SFXDragonSoulReviveWind is None; skipping wind SFX")
    endif
    if NPCDragonDeathSequenceExplosion
        NPCDragonDeathSequenceExplosion.Play(target)
    else
        LogDragonSoulRevive(IronSoulConfig.LOG_ERR(), "HandleDragonSoulRevive: NPCDragonDeathSequenceExplosion is None; skipping explosion SFX")
    endif

    Utility.Wait(1.0)

    ShaderParticleIntro()

    if config.IsDragonSoulReviveMessageEnabled()
        PlayDragonSoulReviveSFX(IronSoulSFX.PickDragonSoulReviveCastSFX(SFXDragonSoulReviveCast1, SFXDragonSoulReviveCast2, SFXDragonSoulReviveCast3, SFXDragonSoulReviveCast4), target, True)
        presentation.OpenTimedMessageSWF(IronSoulUI.SwfNoBonus(ResolveMenu(target, guid), config.IsSoulBonusEnabled()), 3.0)
    elseif introShown
        presentation.RestoreMusic()
    endif

    PlayDragonSoulReviveSFX(IronSoulSFX.PickDragonSoulReviveSFX(SFXDragonSoulRevive1, SFXDragonSoulRevive2, SFXDragonSoulRevive3, SFXDragonSoulRevive4), target, False)

    ShaderParticleOutro()

    if RestoreSpell
        target.AddSpell(RestoreSpell, False)
    else
        LogDragonSoulRevive(IronSoulConfig.LOG_ERR(), "HandleDragonSoulRevive: RestoreSpell is None; skipping restore spell apply")
    endif

    RestoreVitals(target)

    LogDragonSoulRevive(IronSoulConfig.LOG_INFO(), "HandleDragonSoulRevive: Cleanup started")

    Int i = 0
    while i < 5
        Utility.Wait(1.0)
        RestoreVitals(target)
        i += 1
    endwhile

    if RestoreSpell
        target.RemoveSpell(RestoreSpell)
    endif

    if MarkerRef != None
        MarkerRef.Disable()
        MarkerRef.Delete()
        MarkerRef = None
    endif

    IronSoulNative.EndMenuBlock(menuBlockToken)
    ReleaseDeathLock()
    LogDragonSoulRevive(IronSoulConfig.LOG_DBG(), "HandleDragonSoulRevive: Cleanup finished")
EndFunction

Function SyncLimitState(Actor player, String guid)
    if !HasCoreRuntime() || !player || guid == "" || Controller.Config.GetDragonSoulReviveLimit() == 0
        return
    endif

    Int nowSec = Utility.GetCurrentRealTime() as Int
    Int lastSec = Controller.Persistence.GetGuidInt(player, guid, dsrLimitLastSec, 0)
    Int playedSec = Controller.Persistence.GetGuidInt(player, guid, dsrLimitPlayedSec, 0)

    if lastSec <= 0
        Controller.Persistence.SetGuidInt(player, guid, dsrLimitLastSec, nowSec, True)
        return
    endif

    Int delta = nowSec - lastSec
    if delta < 0
        delta = 0
    elseif delta > 60
        delta = 60
    endif

    if delta > 0
        playedSec += delta
        Controller.Persistence.SetGuidInt(player, guid, dsrLimitPlayedSec, playedSec, True)
    endif

    if nowSec != lastSec
        Controller.Persistence.SetGuidInt(player, guid, dsrLimitLastSec, nowSec, True)
    endif
EndFunction

String Function ResolveMenu(Actor player, String guid)
    if !player
        return ""
    endif

    if guid == ""
        return "1_iron_dragon_soul_revive"
    endif

    if !HasCoreRuntime() || !Controller.Config.IsDragonSoulReviveMessageEnabled()
        return ""
    endif

    Int soulTier = 1
    if Controller.Tiers
        soulTier = Controller.Tiers.GetCurrentTier(player, guid)
    endif
    Int recentUses = 0
    Int playedNow = Controller.Persistence.GetGuidInt(player, guid, dsrLimitPlayedSec, 0)
    if Controller.Config.GetDragonSoulReviveLimit() > 1
        recentUses = RefreshRollingLimitUses(player, guid, playedNow)
    endif

    return ResolveDSRMenuFromFacts(soulTier, Controller.Config.GetDragonSoulReviveLimit(), recentUses)
EndFunction

Function RemoveTrackedData(Actor player, String guid, Bool deleteMainData = True, Bool unsetCosave = False)
    if !HasPersistenceRuntime() || guid == ""
        return
    endif

    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, dsrLimitLastSec, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, dsrLimitPlayedSec, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, dsrLimitUse1, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, dsrLimitUse2, deleteMainData, unsetCosave)
    Controller.Persistence.RemoveGuidTrackedIntKey(player, guid, dsrLimitUse3, deleteMainData, unsetCosave)
EndFunction


; --- Dragon Soul Revive Helpers ---
; ==================================

Int Function RefreshRollingLimitUses(Actor player, String guid, Int playedNow)
    if !HasCoreRuntime() || !player || guid == ""
        return 0
    endif

    Int use1 = Controller.Persistence.GetGuidInt(player, guid, dsrLimitUse1, -1)
    Int use2 = Controller.Persistence.GetGuidInt(player, guid, dsrLimitUse2, -1)
    Int use3 = Controller.Persistence.GetGuidInt(player, guid, dsrLimitUse3, -1)

    Int next1 = -1
    Int next2 = -1
    Int next3 = -1
    Int kept = 0

    if use1 >= 0
        Int age1 = playedNow - use1
        if age1 >= 0 && age1 < 600
            kept += 1
            next1 = use1
        endif
    endif

    if use2 >= 0
        Int age2 = playedNow - use2
        if age2 >= 0 && age2 < 600
            kept += 1
            if kept == 1
                next1 = use2
            else
                next2 = use2
            endif
        endif
    endif

    if use3 >= 0
        Int age3 = playedNow - use3
        if age3 >= 0 && age3 < 600
            kept += 1
            if kept == 1
                next1 = use3
            elseif kept == 2
                next2 = use3
            else
                next3 = use3
            endif
        endif
    endif

    if use1 != next1
        Controller.Persistence.SetGuidInt(player, guid, dsrLimitUse1, next1, True)
    endif
    if use2 != next2
        Controller.Persistence.SetGuidInt(player, guid, dsrLimitUse2, next2, True)
    endif
    if use3 != next3
        Controller.Persistence.SetGuidInt(player, guid, dsrLimitUse3, next3, True)
    endif

    return kept
EndFunction

Function RecordLimitUse(Actor player, String guid, Int playedNow)
    if !HasCoreRuntime() || !player || guid == ""
        return
    endif

    Int use1 = Controller.Persistence.GetGuidInt(player, guid, dsrLimitUse1, -1)
    Int use2 = Controller.Persistence.GetGuidInt(player, guid, dsrLimitUse2, -1)
    Int use3 = Controller.Persistence.GetGuidInt(player, guid, dsrLimitUse3, -1)

    if use1 < 0
        use1 = playedNow
    elseif use2 < 0
        use2 = playedNow
    elseif use3 < 0
        use3 = playedNow
    else
        use1 = use2
        use2 = use3
        use3 = playedNow
    endif

    Controller.Persistence.SetGuidInt(player, guid, dsrLimitUse1, use1, True)
    Controller.Persistence.SetGuidInt(player, guid, dsrLimitUse2, use2, True)
    Controller.Persistence.SetGuidInt(player, guid, dsrLimitUse3, use3, True)
EndFunction

Function ShaderParticleIntro()
    _imageSpaceIsFinishing = False

    if IntroFX
        IntroFX.Apply()
    endif

    Utility.Wait(0.15)

    if !_imageSpaceIsFinishing && StaticFX
        StaticFX.Apply()
    endif

    if PSGD
        PSGD.Remove(0.1)
        PSGD.Apply(0.1)
    endif
EndFunction

Function ShaderParticleOutro()
    _imageSpaceIsFinishing = True

    if OutroFX
        OutroFX.Apply()
    endif

    if StaticFX
        StaticFX.Remove()
    endif

    if PSGD
        PSGD.Remove(0.1)
    endif
EndFunction

Function PlayDragonSoulReviveSFX(Sound sfx, Actor source, Bool castSFX)
    if !HasCoreRuntime()
        return
    endif
    if !IronSoulSFX.CanPlaySFX(Controller.Config.IsSFXEnabled(), Controller.Config.IsUninstallMode(), Controller.IsModDisabled())
        return
    endif
    if castSFX && !Controller.Config.IsDragonSoulReviveCastSFXEnabled()
        return
    endif
    if !castSFX && !Controller.Config.IsDragonSoulReviveSFXEnabled()
        return
    endif
    if !sfx || !source
        return
    endif
    sfx.Play(source)
EndFunction

Function RestoreVitals(Actor target)
    if !target
        return
    endif

    target.RestoreAV("Stamina", target.GetAVMax("Stamina"))
    target.RestoreAV("Magicka", target.GetAVMax("Magicka"))
    target.RestoreAV("Health", target.GetAVMax("Health") - target.GetAV("Health"))
EndFunction

Bool Function CanAttemptRevive(Actor player, Bool reviveEnabled, Bool transformEnabled, FormList beastList, Int soulTier, Float dragonSouls) Global
    if !player
        return False
    endif

    if !reviveEnabled
        return False
    endif

    if !transformEnabled && beastList && beastList.HasForm(player.GetRace())
        return False
    endif

    if player.IsBleedingOut()
        return False
    endif

    if player.IsEssential()
        return False
    endif

    if dragonSouls < 1.0 && ShouldSpendDragonSoul(soulTier)
        return False
    endif

    return True
EndFunction

Bool Function IsBlockedByRollingLimit(Int reviveLimit, Bool guidKnown, Int recentUses) Global
    return reviveLimit > 0 && guidKnown && recentUses >= reviveLimit
EndFunction

String Function ResolveDSRMenuFromFacts(Int soulTier, Int reviveLimit, Int recentUses) Global
    String baseMenu = IronSoulUI.TierMenuPrefix(soulTier) + "_dragon_soul_revive"
    if reviveLimit > 1 && recentUses >= reviveLimit
        return IronSoulUI.TierMenuPrefix(soulTier) + "_dragon_soul_revive_limit"
    endif
    return baseMenu
EndFunction

Bool Function ShouldSpendDragonSoul(Int soulTier) Global
    return soulTier != 6
EndFunction
