Scriptname IronSoulController extends Quest
;                                                                         +.-=:::#                                                                         
;                                                                        %%-+#+*+%                                                                         
;                                                                     *#@%#**##**%@%%%%                                                                    
;                                                             ##*#%#%%%%#%*++%#==%%#%%%%%###%##                                                            
;                                                       @%###%##%##*#*##%%+++%%=+=%*###***###*##%%%%#                                                      
;                                                +++@%%%%%%####****+#****%-+=##=--#+*#**++*#*#%%%##%%%%%#*#                                                
;                                             #+#***@%%###%##%%%%#*#**###*--+*#--:#++*+==+#%#%*#####%%@@####+@                                             
;                                       %%*%##%=++**@@%##*%#******+@**+*%:--%+++..-++++=%=+++**#%#***%%@##***@%%#*##                                       
;                                    #%%*##*%%@+****@%%#+%*#**++-+=@==*+*:::#==%:..=---==-=*+++**%**###@**#**%%%+##*@@#@                                   
;                               #****+##@*=-+@@+****@%%#*+%#**+=+=+#==:*-.::*--#-.:-..=-#:-:=+++#@=***#@**#*+%@+:--@#**#*#**                               
;                           #****+*=*=-+%%...@@=--=+@%##***++=+++#*=-:=-...*-:.=+...:....++=-+==+#*+*#%@**-=-@%...%#-+=*=++*****                           
;                        %**##*+=*=--:==%@==-%@+##**@%%@##++**%*+=+=:++-.:+=....+=...-.:.--=#*+=-+*#%%*@***++@@::+@#:-::.:+-=+#**##                        
;                     %%%#**#=-===++++##%@%%*@@%%%%%@%##@%**##+++=++#=-=-=*:.....+=.::=+=:-=*****%#+##*%%%###@@*%%@%#*====-:-:-#**#%%%                     
;                   +#***+=-:.+=*#**###%%@@@@@%#@@%@%###%#+##*+*+*#++*===*=--:...:*=.-+-+++=+=-+#++*###%@%@%%@@%@@@%%####***=+..-=+##**+                   
;                 +*#+++::.+-+**#%%#%%%@%@@%%@#%#@@@%%%%##%###%#====++=%*====-:--:=*#-=--=-=#%######%%@%@@@%%%@@@@@@@@#%#%%##+=-=.:-*+****                 
;               #***+==+..-**#%%%%@@@@@@@@@@@@%%%%@@%%###++=+*+*+:+++%%*-+++--==---=+#%---:++++*==+***%%@@@%#%@@@@@@@@@@@@%%%#*#*:..++-=*#+*               
;              +##*+--=:=**#%@@@@@@%%@@@@@@@@%@@@@@@%%%#####%##**+%#=+=++=+**--+*==***=-*#=+****++*+##@@@@@@@@%@@@@@@@@%%@@@@@%@#**+:-==**#*=              
;            =*###+--*=**#%@%@@%%%@  @@@@@@@@@@@@@@@@##%####*+==++===+++*++*+-+++*+**+=::=+++==*##%%###@@@@@@@@@@@@@@@   @%%%@@%@%%#+=*=-+*##*+            
;           #%###*:.:=+#%%@%@#%     @@@%#*@@@@@@@@%*%#@@@@@@@@@@@@@@#==+*##*#-++*=+++=-#%@@@@@@@@@@@@@#%#%@@@@@@@@#%%@%      %%@%@%%%++-.-**####           
;          %%%##*=.-**#%%%%#       #%#***@@@%@@%@%%#=+@@%@@@@@@@@@@@@@%+##*++-=+++**+@@@@@@@@@@@@@%%@%*-%%@@#@%@@@@+**%#@       %%%%%%*#=.-*#%##           
;          %%%##*==+*#####        #%#+++@@@@@#@%%%%#*#*@%#%@@@@@@@@@@@@@#+***--==++#@@@@@@@@@@@@@%*%%+#*#%@%@@%@@@@@++*%%%        #%%#%#+--*#%%%%          
;         %%%%#*-+++#%*##      -: ##+*-@@%@@@#@@%%@*##*=+#%#@@@@@@@@%#@@+#*#+:-==+++@@#%@@@@@@@@*##+=+##*%@%@%%@@@%@%+##%# .=      %##%%*+==+#%%##         
;         %%%#*-:-+*#*##       #-=##+++@%%@@@##%%##%#%%%#*=-***#**#####+%%%*=:-==*##+*#**+#***+=:-+**%#*#%#@%#%@@@%%@==*##-=%       *##%#+-:-*%%%#         
;         %%%%*=:-=*#%#        #@#--++#%%%#@@%#@@%#%%%%####*+-==:=*=-=+*%%+**:===+%%*+==*#.:===+**%%#%#%%%%@@%%@%%%%%*++-=#@#        ###*+--=#%%%@         
;          %%%%#*==+#%#         @@@@*+-=+#%@@%#@@#@@@@@%#%**#*#**=@%#**#%*@%*:-+%@*%***#%#+.%**+*#%#%@@@@@@@%#@@@%%+=:=*@@%%         #%#*+++*#%%%          
;          @%%%%#+:-+##          %%#+=@@@%%%@%#@@@%@@%%##%%*+**#+-%@@%#*#*@@@*#@@%*#-*%@@**=#*+=*%@#%@@@@%@%%%@@@%%@@@*#%%#          ##+=-+##%%%#          
;           ##@%%%*==*#*       . #%*+-#%%%%@#%%@%@*%@%%@***###%*:++@%@%*+*+++##-=+++##@%@=**+*%%#%%#@@%@%*%%@#%%@@%%%%++### :       *#+==#%%%%%#           
;            ##%@%%%*==+++++++++ **+++##%%%@##@@%@%*@%%@#####%%%-++@%#**:+*.*%#-.+-.**#@@=++#%@*###*@%@@+%@%@@#%@@%%%#+++** *++*++++++=+#%%@%#%            
;              %#%@%%%#++=-+*%#  +*+*+=#%%%@@@@%%##**@%#%###*#%*#++@@@+%#*%*=+*-*%++%*@@%+=%#%**####%%@+###%%@@@@%%%#-+++*%  #%*=--=+*#%%@%%%              
;                 %%%%@@@@%#%     +#+=:+#%%@@@%%@*##+#@%@%###+%#*++@@%#%+-+::=.:-#-+%#@@*=%*#%**##%@@@##%*#@%%@@%%%%+-=+%*     #%%%%%%%%%%                 
;                                 *#*+=:##%@@@@#@@%*%+%@%%%%%*%###=@%@@@@@@@@@@@@@@@@@@@=+%##%#%%%%%@#=##%%%%@@@%%%+-=*#*#                                 
;                                  *#*=+-#%%%%@@#%%#**+%@@@@#*####=*@%@+@+@@@@@@@@#%**@@-+**####%@#@#*%%##%%@@%%%%+++*#**                                  
;                                   *#%#=..*%%@@@#*#%*#+#@@@@@#%%%*=@%%#%-*+-#=-*:=**#@%+*#####%@%%*+***##%@@@%%=.:##%#+                                   
;                                    #+==-%#%%%%@@@#*##*%@%%%%@#%@#=@@%@*#*=###+-++%@@@%=%##%#%%%#@%%*##%@@@@@%%*#-=+#*                                    
;                                   =****+#+=#%%%@@@@@#*%@@@#+*%%#%+%@%%##++*-+-+*+*##@#+@%%%%%%%%@%#%%@@@@@%%+:+#+***+=                                   
;                                     +###++-.:...*%@@@@%@@%%%#%@%#*#@@#*++=.:..-:-+*@@+#%#***#%%@@%@@@@%+::-=-=+*#*+*                                     
;                                      *####=*=+=@%%@@@@@@@%#***+%%#*@@@@%#*=====*%@@@@=%%#*+*%#%@@@@%%%%%@---+-***+                                       
;                                        *#%%%++*%#=%%@@@@@@@@*+*##%=@@@@@@@@@@@@@@@@@%=%#***#@@@@@@%@%#=*%==*###*=                                        
;                                          *%%%%###%#-#%@@@@@@@@%#%%=#@@@@@@@@@@@@@@@@*****@@@@@@%%%%*-###=%%%##*                                          
;                                            *##%%%%=---:-%%@@@@@@@*#-@%@@@@@-*@@@%%%@=*#@@@@@@%%@.--:.=#%%##**                                            
;                                              *##%#%%%#+@++=#:-%@@@@%@%%@%#:=*=#%%%%%%@@@@#::*=++@-#%#%%%%%                                               
;                                                 *###%%%%%%@#++=--=*##*=:-+==*++=-=++++=-=++=#@*%%%%%%#*                                                  
;                                                     +*##%@@@@@*#+=-=++***==-**+**+++=-=*##@@@%@%##+                                                      
;                                                          ##%%#%#%@@@%#*#*#*=*%##@*#@@@@%%%%%#+                                                           
;                                                               %%%%@@@@@%@%##%%%%@@@%%%%#                                                                 
;                                                                     @@@%@@@#%@@@@@@                                                                      
;                                                                        @@%@%@@%%                                                                         
;                                                                           %##%                                                                           
;
;                                                                             
;                    +++++ ++++++++++         ++++++      ++++++     +++++           ++++++         ++++++     +++++     +++++++++                        
;                     ++++ ++++++++++++     +++++++++++    ++++++     ++++         ++++++++++    ++++++++++++   ++++     ++++ ++++                        
;                     ++++ ++++    ++++   ++++++  +++++++  +++++++    ++++        +++++   +++  +++++++  ++++++  ++++     ++++ ++++                        
;                     ++++ +++++   ++++  +++++      +++++  ++++++++   ++++         +++++       +++++      +++++ ++++     ++++ ++++                        
;                     ++++ ++++ +++++++  +++++       +++++ ++++ +++++ ++++          ++++++++  +++++       +++++ ++++     ++++ ++++                        
;                     ++++ ++++++++++    +++++       ++++  ++++  +++++++++            +++++++  ++++       +++++ ++++     ++++ ++++                        
;                     ++++ +++++++++++    +++++     +++++  ++++   ++++++++        +++    +++++ +++++     +++++  ++++     ++++ ++++                        
;                     ++++ +++++  +++++    +++++++++++++   ++++    +++++++        ++++++++++++  ++++++++++++++  ++++++++++++  +++++   ++                  
;                    +++++ +++++   ++++++   ++++++++++    ++++++     +++++         ++++++++++     ++++++++++      +++++++++  +++++++++++                  
;
;
;                                                                  Developed by Redaxiom.
;                                                                                                                                       
              
; =================
; Table of Contents
; =================

; --- Config (INI via SKSE plugin) + Logging ---
; ----------------------------------------------
; ReadBool()
; ReadIntRange()
; LoadConfig()
; LOG_ERR()
; LOG_INFO()
; LOG_DBG()
; LogMsg()
; LogMsgSnapshot()
; LogSystemSnapshot()

; --- Persistence (MainData + Co-save) ---
; ----------------------------------------
; GetMaxLuckForTier()
; GetCurrentMaxLuck()
; PercentThresholdCeil()
; SyncLuckNotifiedTierToCurrent()
; MakeKey()
; GetKey()
; PersistGetInt()
; PersistSetInt()
; SyncDeathAV()

; --- Lifecycle & Runtime ---
; ---------------------------
; OnInit()
; StartBootstrap()
; OnPlayerLoadGame()
; OnUpdate()
; OnUpdateHeartbeat()
; BootstrapTick()
; TickLuckRegen()
; QueueUpdate()
; RescheduleIfJobsRemain()
; ScheduleLoadMessage()
; ResetTransientState()

; --- Death Handling ---
; ----------------------
; HandlePlayerDying()
; UpdatePlayerProtectionState()
; TrueDeathAndQuit()
; IncrementTrueDeath()
; FinalizeAndQuit()
; FinalizeAndQuitMainMenu()
; GetEffectiveMaxLives()

; --- Dragon Soul Revive ---
; --------------------------
; HandleDragonSoulRevive()
; ShaderParticleIntro()
; ShaderParticleOutro()
; SyncDSRLimitState()
; CompactDSRLimitUses()
; RecordDSRLimitUse()
; IsDSRAvailable()

; --- Respawn Integration ---
; ---------------------------
; HandleRespawn()
; ResolveRespawnQuest()
; IsRespawnEnabled()
; HandleDisableRespawn()

; --- Luck + Cooldown (Respawn Resolution) ---
; --------------------------------------------
; ComputeLuckRollD20()
; PerformLuckRoll()
; LuckCooldownEnsureLoaded()
; LuckCooldownMarkDirty()
; LuckCooldownPersistIfDue()
; LuckCooldownForcePersistNow()
; IsLuckActive()
; IsCooldownModeActive()
; IsCooldownReady()
; ResetCooldown()
; TickCooldownRegen()
; GetLuckValue()
; SetLuckValue()
; ResetLuck()
; LuckTier()
; DecodePlayed()
; EncodePlayed()

; --- Character Journal ---
; -------------------------
; JournalEnsureOpenerLogged()
; JournalLogEvent()
; JournalLogLuckOutcome()
; JournalLuckOutcomeText()
; JournalEnsureStartDay()

; --- Identity & GUID ---
; -----------------------
; EnsureGuid()
; GetTickGuid()
; EnsureGuidMarker()
; EnsureGuidInIndex()
; WriteIdentitySnapshotStatic()
; WriteIdentitySnapshotLastSeen()
; TryRestoreGuidMissingCosave()
; TryRestoreGuidTamperedCosave()

; --- Feats & Unlocks ---
; -----------------------
; TryScheduleFeats()
; HandleFeats()
; MaybePlayLuckImprovedAfterTierUnlock()
; TierMenuPrefix()
; IsMiraakDefeated()
; IsAlduinDefeated()
; IsHarkonDefeated()
; IsMolagBalDefeatedVigilant()

; --- Soul Bonus ---
; ------------------
; GetSoulBonusSpellByTier()
; RemoveSoulBonusAll()
; SyncSoulBonusAbility()

; --- UI & Messaging ---
; ----------------------
; OpenTimedMessageSWF()
; OpenTimedMessageSWF_SFX()
; OpenTimedMessageSWF_KeyDismiss()
; OpenTimedMessageSWF_KeyDismiss_SFX()
; OpenTimedMessageSWF_KeyDismissIronIntro()
; ShowIronIntro()
; SwfNoBonus()
; HandleLoadNotification()
; PickCHIMCHIMLine()
; HandleRespawnMenu()
; ResolveDeathMessageMenu()
; ResolvePermadeathMenu()
; ResolveDSRMenu()
; ResolveRespawnMenu()
; PickLuckLoadFlavor()
; MaybeNotifyLuckThreshold()
; ResolveDefiantFeatUnlockMenu()
; ResolveDefiantIntroMenu()
; ResolveDefiantTransitionMenu()
; ResolveCHIMTransitionMenu()
; PromoteToCHIMTier()
; ShouldTriggerCHIMTransitionOnLoad()
; PlayCHIMTransitionMessageSequenceSWF()
; PlayDefiantTransitionMessageSequenceSWF()
; OnKeyDown()
; RegisterForAllKeys()
; UnregisterForAllKeys()

; --- Sound FX ---
; ----------------
; CanPlaySFX()
; IsSFXDisabledByCategory()
; PlaySFX()
; PickHeavyBreathingSFX()
; PickDragonSoulReviveCastSFX()
; PickDragonSoulReviveSFX()
; RegisterMusicFadeBridge()
; OnMusicFadeSetVolume()

; --- Uninstall / Cleanup ---
; ---------------------------
; HandleUninstallMode()
; ReenableAfterUninstall()


; ====================================
; --- Properties and Runtime State ---
; ====================================

; Game.GetFormFromFile(0x000B12, "Iron Soul - Permadeath Lite.esp")
GlobalVariable Property IronSoul_DeathCount Auto 

Spell Property IronSoulOnDyingSpell Auto

; Logging
Bool _logEnabled = False
Int  _logLevel = 2 ; 1=Errors, 2=Info, 3=Debug
Int  _enableLogNotifications = 0

; Key-dismissable custom menu support
Bool _keyDismissActive = False
Bool _keyDismissPressed = False

; Core toggles
Bool _disableRespawn = False
Bool _disableRespawnMessage = False
Bool _disableDeathMessage = False
Bool _disableDragonSoulRevive = False
Int  _dragonSoulReviveLimit = 3
Bool _disableDragonSoulReviveMessage = False
Bool _disableLuckSystem = False
Bool _disableCharacterJournalLog = False
Int  _luckRollMessageMode = 0
Bool _enableCharacterSheetCompatibility = False
Bool _disableIronSoulIntro = False
Bool _disableSFX = False
Bool _disableMusicFade = False
Bool _disableIronIntroSFX = False
Bool _disableDeathSFX = False
Bool _disablePermadeathSFX = False
Bool _disableRespawnSFX = False
Bool _disableDefiantTransitionSFX = False
Bool _disableDragonSoulReviveSFX = False
Bool _disableFeatUnlockSFX = False
Bool _disableLuckRollSFX = False
Bool _disableLuckOutcomeSFX = False
Bool _disableRespawnHeavyBreathingSFX = False

; Music fade
SoundCategory Property AudioCategoryMUS Auto

; Respawn
Quest _respawnQuest = None
Bool _respawnAvailable = False

; Brawl exception
Quest property brawlQuest auto

; Feats
Bool _disableDefiantFeat = False
Bool _disableSoulFeats = False
Bool _disableSoulBonus = False
Bool _disableSoulFatigue = False

; Anti-cheat: track Feats Dragon Souls via a guarded counter (blocks large console jumps).
Bool _disableDragonSoulAnticheat = False

; Luck / notifications
Bool _disableLuckCooldownReminderNotification = False
Int _loadNotificationMode = 0 ; 0=default,1=no flavor,2=only flavor,3=disabled
Float _luckTickAt = 0.0
Bool _suppressLuckNotify = True ; suppress luck threshold notifications until first Heartbeat

; Uninstall / disable mode
Bool _uninstallMode = False ; INI: UninstallMode=1 -> safe cleanup + disable
Bool _modDisabled = False
Bool _uninstallNotified = False

; Soul Bonus tier abilities (constant-effect Ability spells; applied/removed by script)
Spell Property SoulBonus0Defiant Auto
Spell Property SoulBonus1Iron Auto
Spell Property SoulBonus2Silver Auto
Spell Property SoulBonus3Gold Auto
Spell Property SoulBonus4Ebon Auto
Spell Property SoulBonus5Platinum Auto

; UI SFX
Sound Property SFXIronIntro Auto
Sound Property SFXDeath Auto
Sound Property SFXPermadeath Auto
Sound Property SFXRespawn Auto
Sound Property SFXDefiantTransition Auto
Sound Property SFXDragonSoulReviveCast1 Auto
Sound Property SFXDragonSoulReviveCast2 Auto
Sound Property SFXDragonSoulReviveCast3 Auto
Sound Property SFXDragonSoulReviveCast4 Auto
Sound Property SFXDragonSoulRevive1 Auto
Sound Property SFXDragonSoulRevive2 Auto
Sound Property SFXDragonSoulRevive3 Auto
Sound Property SFXDragonSoulRevive4 Auto
Sound Property SFXFeatSilver Auto
Sound Property SFXFeatGold Auto
Sound Property SFXFeatEbon Auto
Sound Property SFXFeatPlatinum Auto
Sound Property SFXFeatDefiant Auto
Sound Property SFXLuckRoll Auto
Sound Property SFXLuckFailure Auto
Sound Property SFXLuckSuccess Auto
Sound Property HeavyBreathingSFX0 Auto ; MaleKhajiit
Sound Property HeavyBreathingSFX1 Auto ; MaleOrc
Sound Property HeavyBreathingSFX2 Auto ; MaleEvenToned
Sound Property HeavyBreathingSFX3 Auto ; MaleElfHaughty
Sound Property HeavyBreathingSFX4 Auto ; MaleArgonian
Sound Property HeavyBreathingSFX5 Auto ; FemaleOrc
Sound Property HeavyBreathingSFX6 Auto ; FemaleEvenToned
Sound Property HeavyBreathingSFX7 Auto ; FemaleKhajiit
Sound Property HeavyBreathingSFX8 Auto ; FemaleElfHaughty
Sound Property HeavyBreathingSFX9 Auto ; FemaleArgonian

; Boss quest latches
Quest Property MQ305 Auto
Quest Property DLC1VQ08 Auto
Quest Property DLC2MQ06 Auto

; CHIM toggle (INI: 0/1)
Int _CHIM = 0

; Luck / Cooldown Persistence Gate
; Script ticks every second; persists at most once per gate unless forced.
Int _luckPersistGateSeconds = 60

String _luckCooldownGuid = ""
Int _luckCooldownLastSec = 0
Int _luckCooldownPlayedTok = 0
Int _luckCooldownNextPersistAt = 0
Bool _luckCooldownLoaded = False
Bool _luckCooldownDirty = False

; Last Luck roll inputs (for journaling on Luck-mode outcomes)
Int _lastLuckRoll = 0
Int _lastLuckValue = 0
Bool _lastLuckRollValid = False

; One-shot: suppress the generic "Defeated. Deaths: X / Y." journal line
; when we've already written a Luck-specific defeat line for this death.
Bool _suppressNextDefeatJournal = False

; Dragon Soul Revive
FormList Property BeastList Auto
Spell Property RestoreSpell Auto
Spell Property DisSpell Auto
Bool Property bDispel = True Auto
Sound property NPCDragonDeathSequenceWind Auto
Sound property NPCDragonDeathSequenceExplosion Auto
VisualEffect Property AbsorbEffect Auto
VisualEffect Property AbsorbEffectTarget Auto
Activator Property Marker Auto
Objectreference MarkerRef

; Dragon Soul Revive image-space FX
ImageSpaceModifier Property IntroFX Auto
ImageSpaceModifier Property StaticFX Auto
ImageSpaceModifier Property OutroFX Auto
ShaderParticleGeometry Property PSGD Auto
Bool _imageSpaceIsFinishing = False

; Tunables
Int Property IRON_SOUL_MAX_LIVES = 10 AutoReadOnly
Int Property DEFIANT_SOUL_MAX_LIVES = 100 AutoReadOnly
Int Property LUCK_REGEN_SECONDS = 3600 AutoReadOnly ; Luck 0->maxLuck duration (60 minutes)


; =======================================================
; --- Gameplay Config (INI via SKSE plugin) + Logging ---
; =======================================================

; Read INI overrides via SKSE plugin (all optional)- 
; Data\SKSE\Plugins\IronSoul.ini
; File: Data\SKSE\Plugins\IronSoul.ini
; Sections are organizational only.
Bool Function ReadBool(String configKey, Bool defaultValue)
    Int v = IronSoulNative.GetConfigInt(configKey, -1)
    if v == 0
        return False
    elseif v == 1
        return True
    endif
    return defaultValue
EndFunction

Int Function ReadIntRange(String configKey, Int defaultValue, Int minV, Int maxV)
    Int v = IronSoulNative.GetConfigInt(configKey, -1)
    if v >= minV && v <= maxV
        return v
    endif
    return defaultValue
EndFunction

Function LoadConfig()
    ; Defaults (script defaults)
    _logEnabled = False
    _logLevel = 2
    _enableLogNotifications = 0

    ; Messaging (SWF)
    _disableRespawnMessage = False
    _disableDragonSoulReviveMessage = False
    _disableIronSoulIntro = False

    ; Gameplay / integration
    _disableRespawn = False
    _disableDeathMessage = False
    _enableCharacterSheetCompatibility = False
    _disableDragonSoulRevive = False
    _dragonSoulReviveLimit = 3
    _disableSoulBonus = False
    _disableCharacterJournalLog = False
    _uninstallMode = False
    _CHIM = 0

    ; Luck / load notifications
    _disableLuckSystem = False
    _disableLuckCooldownReminderNotification = False
    _loadNotificationMode = 0
    _luckRollMessageMode = 0

    ; Feats
    _disableDefiantFeat = False
    _disableSoulFeats = False
    _disableSoulFatigue = False

    ; Additional toggles (ensure defaults reset on reload)
    _disableDragonSoulAnticheat = False
    _disableSFX = False
    _disableMusicFade = False
    _disableIronIntroSFX = False
    _disableDeathSFX = False
    _disablePermadeathSFX = False
    _disableRespawnSFX = False
    _disableDefiantTransitionSFX = False
    _disableDragonSoulReviveSFX = False
    _disableFeatUnlockSFX = False
    _disableLuckRollSFX = False
    _disableLuckOutcomeSFX = False
    _disableRespawnHeavyBreathingSFX = False

    ; Reads (INI via plugin)
    _logEnabled = ReadBool("EnableLogging", _logEnabled)
    _logLevel = ReadIntRange("LogLevel", _logLevel, 1, 3)
    _enableLogNotifications = ReadIntRange("EnableLogNotifications", _enableLogNotifications, 0, 1)

    _disableDeathMessage = ReadBool("DisableDeathMessage", _disableDeathMessage)
    _disableDragonSoulRevive = ReadBool("DisableDragonSoulRevive", _disableDragonSoulRevive)
    _dragonSoulReviveLimit = ReadIntRange("DragonSoulReviveLimit", _dragonSoulReviveLimit, 0, 3)
    _disableDragonSoulReviveMessage = ReadBool("DisableDragonSoulReviveMessage", _disableDragonSoulReviveMessage)
    _disableRespawn = ReadBool("DisableRespawn", _disableRespawn)
    _disableRespawnMessage = ReadBool("DisableRespawnMessage", _disableRespawnMessage)
    _disableIronSoulIntro = ReadBool("DisableIronSoulIntro", _disableIronSoulIntro)

    _disableSoulBonus = ReadBool("DisableSoulBonus", _disableSoulBonus)
    _disableCharacterJournalLog = ReadBool("DisableCharacterJournalLog", _disableCharacterJournalLog)
    _uninstallMode = ReadBool("UninstallMode", _uninstallMode)
    _enableCharacterSheetCompatibility = ReadBool("EnableCharacterSheetCompatibility", _enableCharacterSheetCompatibility)

    _CHIM = ReadIntRange("CHIM", _CHIM, 0, 1)

    _disableLuckSystem = ReadBool("DisableLuckSystem", _disableLuckSystem)
    _disableLuckCooldownReminderNotification = ReadBool("DisableLuckCooldownReminderNotification", _disableLuckCooldownReminderNotification)
    _loadNotificationMode = ReadIntRange("LoadNotificationMode", _loadNotificationMode, 0, 3)
    _luckRollMessageMode = ReadIntRange("LuckRollMessageMode", _luckRollMessageMode, 0, 2)

    _disableDefiantFeat = ReadBool("DisableDefiantFeat", _disableDefiantFeat)
    _disableSoulFeats = ReadBool("DisableSoulFeats", _disableSoulFeats)
    _disableSoulFatigue = ReadBool("DisableSoulFatigue", _disableSoulFatigue)

    _disableDragonSoulAnticheat = ReadBool("DisableDragonSoulAnticheat", _disableDragonSoulAnticheat)
    _disableSFX = ReadBool("DisableSFX", _disableSFX)
    _disableMusicFade = ReadBool("DisableMusicFade", _disableMusicFade)
    _disableIronIntroSFX = ReadBool("DisableIronIntroSFX", _disableIronIntroSFX)
    _disableDeathSFX = ReadBool("DisableDeathSFX", _disableDeathSFX)
    _disablePermadeathSFX = ReadBool("DisablePermadeathSFX", _disablePermadeathSFX)
    _disableRespawnSFX = ReadBool("DisableRespawnSFX", _disableRespawnSFX)
    _disableDefiantTransitionSFX = ReadBool("DisableDefiantTransitionSFX", _disableDefiantTransitionSFX)
    _disableDragonSoulReviveSFX = ReadBool("DisableDragonSoulReviveSFX", _disableDragonSoulReviveSFX)
    _disableFeatUnlockSFX = ReadBool("DisableFeatUnlockSFX", _disableFeatUnlockSFX)
    _disableLuckRollSFX = ReadBool("DisableLuckRollSFX", _disableLuckRollSFX)
    _disableLuckOutcomeSFX = ReadBool("DisableLuckOutcomeSFX", _disableLuckOutcomeSFX)
    _disableRespawnHeavyBreathingSFX = ReadBool("DisableRespawnHeavyBreathingSFX", _disableRespawnHeavyBreathingSFX)

    ResolveRespawnQuest()
EndFunction

Int Function LOG_ERR()
    return 1
EndFunction
Int Function LOG_INFO()
    return 2
EndFunction
Int Function LOG_DBG()
    return 3
EndFunction


Function LogMsg(Int level, String msg, Bool suppressNotify = False)
	if !_logEnabled
		return
	endif
	if level > _logLevel
		return
	endif

	if _enableLogNotifications == 1 && !suppressNotify
		Debug.Notification("[IS] " + msg)
	endif

    if level == LOG_DBG()
        Debug.Trace("[IronSoul]" + " [DBG] " + msg)
    elseif level == LOG_INFO()
        Debug.Trace("[IronSoul]" + " [INFO] " + msg)
    else
        Debug.Trace("[IronSoul]" + " [ERR] " + msg)
    endif
EndFunction

Function LogMsgSnapshot(Int level, String msg)
	if !_logEnabled
		return
	endif
	if level > _logLevel
		return
	endif

    Debug.Trace("[IronSoul]" + " [Snapshot] " + msg)
EndFunction

Function LogSystemSnapshot()

	if !_logEnabled
		return
	endif

	; --- SKSE / Datastore Integrity ---
	Bool skseOK = IronSoulNative.IsAvailable()
	Bool dsOK = False
	if skseOK
		dsOK = IronSoulNative.DataStoreReady()
	endif

	LogMsgSnapshot(LOG_INFO(), "SKSE: Available=" + skseOK \
		+ " DataStore=" + dsOK)

	; --- Quest Wiring ---
	if !MQ305
		LogMsgSnapshot(LOG_ERR(), "MISSING PROPERTY: MQ305 (Quest)")
	endif

	if !DLC1VQ08
		LogMsgSnapshot(LOG_ERR(), "MISSING PROPERTY: DLC1VQ08 (Quest)")
	endif

	if !DLC2MQ06
		LogMsgSnapshot(LOG_ERR(), "MISSING PROPERTY: DLC2MQ06 (Quest)")
	endif

	Bool hasRespawn = (_respawnQuest != None)
	Bool respawnRunning = (hasRespawn && _respawnQuest.IsRunning())

	if !hasRespawn
		LogMsgSnapshot(LOG_ERR(), "MISSING PROPERTY: RespawnQuest (_respawnQuest)")
	endif

	LogMsgSnapshot(LOG_INFO(), "Respawn: Present=" + hasRespawn \
		+ " Running=" + respawnRunning \
		+ " DisableRespawn=" + _disableRespawn)

	if hasRespawn && !_disableRespawn && !respawnRunning
		LogMsgSnapshot(LOG_ERR(), "WARNING: Respawn quest present but NOT running")
	endif

	; --- Core Config ---
	LogMsgSnapshot(LOG_INFO(), "Config: Logging=" + _logEnabled \
		+ " Level=" + _logLevel \
		+ " Notify=" + _enableLogNotifications \
		+ " CHIM=" + _CHIM \
		+ " UninstallMode=" + _uninstallMode \
		+ " ModDisabled=" + _modDisabled)

	; --- Systems ---
	LogMsgSnapshot(LOG_INFO(), "Systems: Luck=" + (!_disableLuckSystem) \
		+ " SoulBonus=" + (!_disableSoulBonus) \
		+ " SoulFeats=" + (!_disableSoulFeats) \
		+ " DragonSoulRevive=" + (!_disableDragonSoulRevive) \
		+ " DragonSoulReviveLimit=" + _dragonSoulReviveLimit)

	; --- Luck Persistence ---
	LogMsgSnapshot(LOG_INFO(), "Luck: Loaded=" + _luckCooldownLoaded \
		+ " Dirty=" + _luckCooldownDirty \
		+ " LastSec=" + _luckCooldownLastSec \
		+ " NextPersistAt=" + _luckCooldownNextPersistAt)

	; --- Player Snapshot ---
	Actor p = Game.GetPlayer()
	if p
		Int deaths = 0
		if IronSoul_DeathCount
			deaths = IronSoul_DeathCount.GetValue() as Int
		endif

		LogMsgSnapshot(LOG_INFO(), "Player: Level=" + p.GetLevel() \
			+ " Dead=" + p.IsDead() \
			+ " InCombat=" + p.IsInCombat() \
			+ " Deaths=" + deaths)

			if dsOK
	            String guid = GetTickGuid(p)
				Int tier = PersistGetInt(p, GetKey(soulTierIndex, guid), TIER_IRON)
				LogMsgSnapshot(LOG_INFO(), "SoulTier=" + tier)
			endif
		endif

EndFunction


; ========================================
; --- Persistence (MainData + Co-save) ---
; ========================================
;
; Model:
; - MainData (.dat via SKSE plugin) is authoritative.
; - Co-save (StorageUtil) is written as backup.
; - Reads check MainData first; missing keys fall back to co-save and heal MainData.
;
; Scope:
; - Controller invokes IronSoulNative.DataFlushIfDirty() at critical points and OnUpdateHeartbeat.
;
; GUID:
; - Raw GUID stored in player-scoped co-save slot only.
; - MainData stores G.U.* identity/claim records for validation, collision prevention,
;   and GUID recovery/re-association.
;
; IS_#### Persistence Scheme:
; Per-character keys use canonical form:
;     IS_####:<guid>
;
; Written to:
;   - MainData (authoritative)
;   - Co-save (backup)
;
; Notes:
; - Keys must be constructed via GetKey("IS_####", guid).
; - Helpers guard against empty/invalid GUIDs and safely no-op or return fallback values.
;
; Key Constants:
; Semantic names map to opaque IS_#### IDs.
; Stored form: IS_####:<guid>
; Built via: GetKey(KEY_..., guid)

; Identity (player-scoped co-save slot)
String Property characterGuid              = "IS_9975" AutoReadOnly

; Core lifecycle
String Property deathCount                 = "IS_8155" AutoReadOnly

; Luck / Cooldown timing
; NOTE: Luck mode and cooldown mode share the same timing keys below.
; Interpretation depends on DisableLuckSystem:
; - DisableLuckSystem=0: played time maps to Luck% (0..maxLuck)
; - DisableLuckSystem=1: played time maps to cooldown readiness (0..3600s)
String Property luckLastSec                = "IS_7314" AutoReadOnly ; Luck/Cooldown: last real-time second anchor
String Property luckPlayedToken            = "IS_7315" AutoReadOnly ; Luck/Cooldown: played-seconds token (encoded)
String Property luckNotifiedTier           = "IS_7316" AutoReadOnly ; Luck: last notified threshold tier

; Narrative / UI one-shots
String Property ironIntroShown             = "IS_8597" AutoReadOnly
String Property tierMsgShownSilver         = "IS_9921" AutoReadOnly
String Property tierMsgShownGold           = "IS_4797" AutoReadOnly
String Property tierMsgShownEbon           = "IS_4513" AutoReadOnly
String Property tierMsgShownPlatinum       = "IS_1155" AutoReadOnly

; Soul / feats
String Property soulTierIndex              = "IS_2204" AutoReadOnly
String Property ebonFeatVariant            = "IS_4520" AutoReadOnly
String Property platinumFeatVariant        = "IS_4779" AutoReadOnly
String Property dragonSoulsTotal           = "IS_9646" AutoReadOnly
String Property dragonSoulsLastSeen        = "IS_7440" AutoReadOnly
String Property dsrLimitLastSec            = "IS_8201" AutoReadOnly
String Property dsrLimitPlayedSec          = "IS_8202" AutoReadOnly
String Property dsrLimitUse1               = "IS_8203" AutoReadOnly
String Property dsrLimitUse2               = "IS_8204" AutoReadOnly
String Property dsrLimitUse3               = "IS_8205" AutoReadOnly

; Boss latches
String Property miraakKilled               = "IS_4911" AutoReadOnly
String Property alduinKilled               = "IS_9897" AutoReadOnly
String Property harkonKilled               = "IS_9808" AutoReadOnly
String Property molagBalKilled             = "IS_1627" AutoReadOnly

; Defiant
String Property defiantFeatUnlocked        = "IS_1989" AutoReadOnly

; Journal markers
String Property journalStartDay            = "IS_5341" AutoReadOnly
String Property journalOpenerLogged        = "IS_2270" AutoReadOnly
String Property journalCHIMLogged          = "IS_1927" AutoReadOnly

; Canonical soul tier/state:
; 0=CHIM, 1=Defiant, 2=Iron, 3=Silver, 4=Gold, 5=Ebon, 6=Platinum
Int TIER_CHIM = 0
Int TIER_DEFIANT = 1
Int TIER_IRON = 2
Int TIER_SILVER = 3
Int TIER_GOLD = 4
Int TIER_EBON = 5
Int TIER_PLATINUM = 6

Int Function GetMaxLuckForTier(Int tier)
    ; Luck cap by soul tier:
    ; CHIM=100, Defiant=75, Iron=80, Silver=85, Gold=90, Ebon=95, Platinum=99.
    if tier <= TIER_CHIM
        return 100
    elseif tier == TIER_DEFIANT
        return 75
    elseif tier == TIER_IRON
        return 80
    elseif tier == TIER_SILVER
        return 85
    elseif tier == TIER_GOLD
        return 90
    elseif tier == TIER_EBON
        return 95
    endif
    return 99 ; Platinum+
EndFunction

Int Function GetCurrentMaxLuck(Actor player, String guid)
    if !player || guid == ""
        return 100
    endif
    Int tierNow = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)
    return GetMaxLuckForTier(tierNow)
EndFunction

Int Function PercentThresholdCeil(Int maxLuck, Int pct)
    ; Integer ceiling of (maxLuck * pct / 100), clamped to [0..maxLuck].
    if maxLuck <= 0
        maxLuck = 1
    endif
    if pct <= 0
        return 0
    elseif pct >= 100
        return maxLuck
    endif
    Int scaled = maxLuck * pct
    return (scaled + 99) / 100
EndFunction

Function SyncLuckNotifiedTierToCurrent(Actor player, String guid)
    ; Recalibrates persisted notified-threshold tier after soul-tier changes.
    if !player || guid == ""
        return
    endif
    Int maxLuck = GetCurrentMaxLuck(player, guid)
    Int luckNow = GetLuckValue(player, guid)
    Int tierNow = LuckTier(luckNow, maxLuck)
    PersistSetInt(player, GetKey(luckNotifiedTier, guid), tierNow, True)
EndFunction

; MakeKey builds a storage key by concatenating a prefix
; and a GUID with a colon separator.
String Function MakeKey(String prefix, String guid)
    return prefix + ":" + guid
EndFunction

; GetKey is the canonical helper for per-character keys.
; Pass the base key (e.g., "IS_5262") and the character GUID.
; Example: GetKey("IS_5262", guid) -> "IS_5262:<guid>"
String Function GetKey(String baseKey, String charId)
    if baseKey == "" || charId == ""
        return ""
    endif
    return MakeKey(baseKey, charId)
EndFunction

Int Function PersistGetInt(Actor player, String dataKey, Int fallback)
    if !player
        return fallback
    endif

    if dataKey == ""
        return fallback
    endif
    ; Reserved internal sentinel for DataGetInt missing-key detection.
    ; Do not use this value as a real persisted gameplay value.
    Int missingSentinel = -2147483647
    Int direct = IronSoulNative.DataGetInt(dataKey, missingSentinel)
    if direct != missingSentinel
        return direct
    endif
    ; Only heal MainData from co-save if the value truly exists in co-save.
    if StorageUtil.HasIntValue(player, dataKey)
        Int v = StorageUtil.GetIntValue(player, dataKey, fallback)
        IronSoulNative.DataSetIntIfChanged(dataKey, v)
        return v
    endif
    return fallback
EndFunction

Function PersistSetInt(Actor player, String dataKey, Int value, Bool useIfChanged = True)
    if dataKey == ""
        return
    endif
    if useIfChanged
        IronSoulNative.DataSetIntIfChanged(dataKey, value)
    else
        IronSoulNative.DataSetInt(dataKey, value)
    endif
    if player
        ; Preserve co-save backup even for zero values: write when key is missing OR changed.
        if !StorageUtil.HasIntValue(player, dataKey)
            StorageUtil.SetIntValue(player, dataKey, value)
        else
            Int cur = StorageUtil.GetIntValue(player, dataKey)
            if cur != value
                StorageUtil.SetIntValue(player, dataKey, value)
            endif
        endif
    endif
EndFunction

Function SyncDeathAV(Actor player, int deaths)
    ; Mirror authoritative deaths into DEPRECATED05 so UI mods can read it (display-only; not an authority source).
    ; This synchronization is optional and controlled via the config key EnableCharacterSheetCompatibility.
    ; When disabled, this function returns immediately.
	if !player || deaths < 0
		return
	endif
    if !_enableCharacterSheetCompatibility
        ; Skip syncing character sheet actor value when disabled
        return
    endif

	Float cur = player.GetActorValue(_deathAVName)
	Float d = deaths as Float
	if cur != d
		player.SetActorValue(_deathAVName, d)
	endif
EndFunction


; ===========================
; --- Lifecycle & Runtime ---
; ===========================

; Runtime / Polling
Float Property StandardPollSeconds = 1.00 Auto ; Best-effort scheduler. Requested 1.0s, but under real VM load typically fires ~1.5-2.0s.
Float Property FastPollSeconds     = 0.20 Auto ; Best-effort fast mode. Requested 0.2s, but in practice usually ~0.4-0.6s.
Float Property PendingFastLoopWatchdogSeconds = 30.0 Auto ; clears stuck fast-loop jobs
Float _nextHeartbeatAt = 0.0
Float _dbgLastOnUpdateRealTime = 0.0
Float _dbgLastHeartbeatRealTime = 0.0

Bool _updateQueued = False
Float _updateQueuedDelay = 0.0
Bool _isQuitting = False

; Bootstrap
Bool _bootstrapActive = False
Int _bootstrapTriesLeft = 0

; GUID Tick State
String _tickGuid = ""
Bool _tickGuidValid = False
Bool _guidTamperMintNotified = False ; one-shot per session warning when tamper fallback mints a new GUID
Float _guidMintRetryAt = 0.0 ; transient backoff after mint failure to avoid repeated retries

; Death Resolution
Bool _deathEventLocked = False

; Pending Jobs / Timers
Bool _pendingDisableRespawn = False
Bool _pendingLoadMessage = False
Bool _respawnWindowArmed = False

Float _loadMessageAt = 0.0
Float _pendingDisableRespawnStartedAt = 0.0
Float _pendingLoadMessageStartedAt = 0.0

Int _soulBonusAppliedTier = -1

; Feats
Bool _pendingFeats = False

Float _featsAt = 0.0

; Respawn Messaging
Bool _pendingRespawnMenu = False
Bool _respawnMenuArmed = False
Float _respawnWarningAt = 0.0

; Permanent Death Counter AV (unused vanilla actor value; exposed for UI mods)
String _deathAVName = "DEPRECATED05"


Event OnInit()

    if !IronSoulNative.IsAvailable()
        _modDisabled = True
        Debug.MessageBox("Iron Soul has been disabled because the required SKSE plugin (IronSoul.dll) is missing.")
        return
    endif

    ResetTransientState()

    LoadConfig()
    RegisterMusicFadeBridge()
    IronSoulNative.StartHealthMonitor()

	; Update splash/lvlWidget for next game launch.
    IronSoulNative.ApplyDynamicSplash(TIER_IRON)
    IronSoulNative.ApplyDynamicLevelWidget(TIER_IRON)

    LogMsg(LOG_INFO(), "IronSoulController: OnInit event fired")

    StartBootstrap()

    Actor player = Game.GetPlayer()
    if !player
        LogMsg(LOG_ERR(), "OnInit: Game.GetPlayer() returned None; skipping OnDying/deferred-kill setup")
    else
        player.StartDeferredKill()
        LogMsg(LOG_INFO(), "OnInit: StartDeferredKill() called")
    endif

    QueueUpdate(StandardPollSeconds)

EndEvent

Function StartBootstrap()
    ; Kick off bootstrap sequence for GUID system.
    ; We retry until:
    ;  - Player reference exists, and
    ;  - EnsureGuid() can succeed (identity ready; player name available).

    _bootstrapActive = True
    _bootstrapTriesLeft = 10 
    _updateQueued = False

    QueueUpdate(1.0)
EndFunction

Function OnPlayerLoadGame(Bool isLoadGame)

    if !IronSoulNative.IsAvailable()
        _modDisabled = True
        Debug.MessageBox("Iron Soul has been disabled because the required SKSE plugin (IronSoul.dll) is missing.")
        return
    endif

    ResetTransientState()

    Actor player = Game.GetPlayer()
    if !player
        LogMsg(LOG_ERR(), "OnPlayerLoadGame: Player is None (Alias not filled yet?)")
        return
    endif

    ; Load config / log settings first.
    LoadConfig()

    ; While uninstall mode is active, run/continue uninstall cleanup flow.
    if _uninstallMode
        HandleUninstallMode(player)
        return
    endif
    ; If uninstall cleanup previously ran and uninstall mode is now OFF, re-enable runtime.
    ; Continue normal load init below so behavior is restored immediately this load.
    if _modDisabled
        ReenableAfterUninstall(player)
    endif

    RegisterMusicFadeBridge()
    IronSoulNative.StartHealthMonitor()
    ; Re-arm bootstrap on each load so placeholder-name GUID gating remains active until identity stabilizes.
    StartBootstrap()

    ; Identity bootstrap
    String name = IronSoulNative.GetPlayerName()

	String guid = EnsureGuid(player)
	GetTickGuid(player)
    
    LogMsg(LOG_INFO(), "OnPlayerLoadGame: Player=" + name + " GUID=" + guid)

	if guid == ""
		LogMsg(LOG_INFO(), "OnPlayerLoadGame: GUID not ready")
    else
        ; Initialize Dragon Soul baseline for this GUID if missing.
        Int _curSoulsLS = player.GetActorValue("DragonSouls") as Int
        Int _lastSoulsLS = PersistGetInt(player, GetKey(dragonSoulsLastSeen, guid), -1)
        if _lastSoulsLS == -1
            PersistSetInt(player, GetKey(dragonSoulsLastSeen, guid), _curSoulsLS, True)
        endif

        Int deathsNow = PersistGetInt(player, GetKey(deathCount, guid), 0)

        if _enableCharacterSheetCompatibility
            SyncDeathAV(player, deathsNow)
        endif

        ; Update Global Variable IronSoul_DeathCount with current character death count for other mods to read.
        if IronSoul_DeathCount
            IronSoul_DeathCount.SetValue(deathsNow)
        endif

        ; Determine essential state.
        UpdatePlayerProtectionState(player)
    endif

    if guid != "" && name != ""
        WriteIdentitySnapshotStatic(guid, player, name)
        WriteIdentitySnapshotLastSeen(guid, player)
        EnsureGuidMarker(guid)
    endif

	player.StartDeferredKill()

    ; Rare edge: identity not ready yet on this load tick.
    ; Defer GUID-dependent load work until a later update when EnsureGuid() can succeed.
    if guid == ""
        LogMsg(LOG_INFO(), "OnPlayerLoadGame: GUID not ready; deferring GUID-dependent load initialization")
        ScheduleLoadMessage(isLoadGame)
        return
    endif

	Int deaths     = PersistGetInt(player, GetKey(deathCount, guid), 0)
	Int soulTier   = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)

    ; Catch-up path: CHIM may be enabled after the threshold death happened in a prior session.
    ; This load-triggered transition does NOT quit to desktop.
    if ShouldTriggerCHIMTransitionOnLoad(player, guid, deaths, soulTier)
        LogMsg(LOG_INFO(), "OnPlayerLoadGame: CHIM transition triggered on load")
        PromoteToCHIMTier(player, guid)
        PlayCHIMTransitionMessageSequenceSWF(soulTier)
        soulTier = TIER_CHIM
    endif

    ScheduleLoadMessage(isLoadGame)
    SyncSoulBonusAbility(player, guid)

    IronSoulNative.ApplyDynamicSplash(soulTier)
	IronSoulNative.ApplyDynamicLevelWidget(soulTier)

	; Effective cap (CHIM tier is effectively unbounded).
	Int maxLives = GetEffectiveMaxLives(player, guid)
	if deaths >= maxLives
		OpenTimedMessageSWF_KeyDismiss_SFX(ResolvePermadeathMenu(soulTier), 55.0, 5.0, SFXPermadeath, player, False)
		FinalizeAndQuitMainMenu()
		return
	endif

    LogSystemSnapshot()

EndFunction

Event OnUpdate()
    ; DBG lightweight OnUpdate trace (with delta time)
    if _logEnabled && _logLevel >= LOG_DBG()
        Float nowRT = Utility.GetCurrentRealTime()
        Float dt = 0.0
        if _dbgLastOnUpdateRealTime > 0.0
            dt = nowRT - _dbgLastOnUpdateRealTime
        endif
        _dbgLastOnUpdateRealTime = nowRT
        LogMsg(LOG_DBG(), "OnUpdate: fired dt=" + dt \
            + " deathLocked=" + _deathEventLocked, True)
    endif
    _updateQueued = False
    _updateQueuedDelay = 0.0

    if _isQuitting
        return
    endif

    if _uninstallMode || _modDisabled
        return
    endif

    Actor player = Game.GetPlayer()

    ; Luck / Cooldown regen tick (menu-safe). Run early so menu time never advances.
    if _tickGuidValid
        if IsLuckActive()
            TickLuckRegen(player, _tickGuid)
        elseif IsCooldownModeActive()
            TickCooldownRegen(player, _tickGuid)
        endif
    endif

    ; Defer initialisation bootstrap if necessary
    if BootstrapTick()
        return
    endif

    ; Timed load-notification handler
    HandleLoadNotification(player)

    ; Low-frequency (5s) maintenance and progression integrity checks
    OnUpdateHeartbeat(player)

    ; Soul Feats message handling (unlock jobs are scheduled on heartbeat cadence)
    HandleFeats(player)

    ; Delayed respawn message
    HandleRespawnMenu(player)

    ; Respawn window disarm/monitor job
    if HandleDisableRespawn(player)
        return
    endif

    RescheduleIfJobsRemain()
EndEvent

Function OnUpdateHeartbeat(Actor player)

    if !player || player.IsDead() || player.IsBleedingOut()
        return
    endif

    if Utility.IsInMenuMode()
        return
    endif

    Float nowRT = Utility.GetCurrentRealTime()
    Int nowSec = nowRT as Int

    ; Run at low frequency (~5s) to avoid overhead.
    if _nextHeartbeatAt != 0.0 && nowRT < _nextHeartbeatAt
        return
    endif
    _nextHeartbeatAt = nowRT + 5.0

    ; DBG lightweight Heartbeat trace
    if _logEnabled && _logLevel >= LOG_DBG()
        Float dtHB = 0.0
        if _dbgLastHeartbeatRealTime > 0.0
            dtHB = nowRT - _dbgLastHeartbeatRealTime
        endif
        _dbgLastHeartbeatRealTime = nowRT
        LogMsg(LOG_DBG(), "Heartbeat: dt=" + dtHB \
            + " souls=" + (player.GetActorValue("DragonSouls") as Int) \
            + " essential=" + player.IsEssential() \
            + " deathLocked=" + _deathEventLocked, True)
    endif

    ; Use per-tick GUID cache
    String guid = ""
    if _tickGuidValid
        guid = _tickGuid
    else
        guid = GetTickGuid(player)
    endif

    if guid == ""
        return
    endif

    SyncDSRLimitState(player, guid)

    ; Refresh last-seen identity snapshot (I.L/I.D) on this low-frequency cadence.
    WriteIdentitySnapshotLastSeen(guid, player)

    if _enableCharacterSheetCompatibility
        Int deathsNow = PersistGetInt(player, GetKey(deathCount, guid), 0)
        SyncDeathAV(player, deathsNow)
    endif

    ; Dragon Soul tracking (lifetime total; anti-cheat aware)
    ;  - Sample DragonSouls once per heartbeat (~5s) and compute delta vs last snapshot.
    ;  - When Dragon Soul anti-cheat is ENABLED:
    ;       * Only accept deltas of 1..3 as legitimate gains (count + journal).
    ;       * Ignore big jumps (>3): do not count and do not journal.
    ;  - When Dragon Soul anti-cheat is DISABLED:
    ;       * Accept ALL positive deltas (count + journal), including big jumps.
    ;
    ; dragonSoulsTotal is a lifetime "souls gained" counter (spent souls still count).
    Int curSouls = player.GetActorValue("DragonSouls") as Int
    Int lastSouls = PersistGetInt(player, GetKey(dragonSoulsLastSeen, guid), -1)
    if lastSouls == -1
        ; First observation for this GUID: establish baseline so we can detect future deltas.
        PersistSetInt(player, GetKey(dragonSoulsLastSeen, guid), curSouls, True)
        return
    endif
    Int delta = curSouls - lastSouls

    ; Determine essential state.
    UpdatePlayerProtectionState(player)
    
    ; Decide how many souls we accept this tick under the current anti-cheat mode.
    Int accepted = 0
    if delta > 0
        if _disableDragonSoulAnticheat
            accepted = delta
        else
            if delta > 3
                Debug.Notification("[Iron Soul] Unusual Dragon Soul increase detected (D=" + delta + "); Dragon Soul Total not updated.")
            endif
            if delta <= 3
                accepted = delta
            endif
        endif
    endif

    if accepted > 0
        Int soulsTotal = PersistGetInt(player, GetKey(dragonSoulsTotal, guid), 0)
        soulsTotal = soulsTotal + accepted
        PersistSetInt(player, GetKey(dragonSoulsTotal, guid), soulsTotal, True)

        ; Trigger Feats evaluation soon (message boxes must be shown in a safe context).
        ; If all Feats are disabled via INI, we still track the counter but do not schedule messaging.
        if !_disableDefiantFeat || !_disableSoulFeats
            _pendingFeats = True
            if _featsAt < (nowRT + 4.0)
                _featsAt = nowRT + 4.0
            endif
        endif

        ; Journal: log accepted Dragon Soul gains, reflecting the lifetime total.
        Int j = 0
        while j < accepted
            Int totalAt = soulsTotal - (accepted - 1 - j)
            JournalLogEvent("Absorbed a Dragon's Soul. Dragon Souls Total: " + totalAt + ".")
            j += 1
        endwhile
    endif

    ; Always advance last-seen snapshot so we don't re-credit/log the same delta next tick.
    PersistSetInt(player, GetKey(dragonSoulsLastSeen, guid), curSouls, True)

    ; --- Boss defeat polls (Ebon / Platinum gating) ---
    ; Some boss defeats are only reliably detectable by quest stage progression (no stable actor OnDeath hook).
    ; To make Ebon/Platinum unlock feel near-immediate even when no Dragon Soul delta occurs, we poll the relevant
    ; quest states on this same low-frequency cadence (~5s) and latch per-character when detected.
    ;
    ; Performance notes:
    ;  - Only polls until a per-character latch flag is set, then becomes a cheap O(1) read.
    ;  - Each poll is guarded by the current Soul Feat so we don't keep checking after the tier is already earned.
    Int curTier = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)
    Int deaths  = PersistGetInt(player, GetKey(deathCount, guid), 0)

    if deaths < IRON_SOUL_MAX_LIVES && !_disableSoulFeats
        ; Platinum checks (Molag Bal has priority over Miraak for variant credit).
        if curTier < TIER_PLATINUM
            Int molagFlag = PersistGetInt(player, GetKey(molagBalKilled, guid), 0)
            if molagFlag != 1
                IsMolagBalDefeatedVigilant(player, guid)
            endif

            Int miraakFlag = PersistGetInt(player, GetKey(miraakKilled, guid), 0)
            if miraakFlag != 1
                IsMiraakDefeated(player, guid)
            endif
        endif

        ; Ebon checks (Alduin priority over Harkon for variant credit when both already true).
        if curTier < TIER_EBON
            Int alduinFlag = PersistGetInt(player, GetKey(alduinKilled, guid), 0)
            if alduinFlag != 1
                IsAlduinDefeated(player, guid)
            endif

            Int harkonFlag = PersistGetInt(player, GetKey(harkonKilled, guid), 0)
            if harkonFlag != 1
                IsHarkonDefeated(player, guid)
            endif
        endif
    endif
    ; Allow Luck notifications after first stable heartbeat
    if _suppressLuckNotify
        _suppressLuckNotify = False
    endif

    TryScheduleFeats(player)

    ; Datastore flush pacing (plugin no longer runs a background flush thread).
    ; Heartbeat runs ~every 5s, and this native call will flush to disk only if the
    ; datastore is dirty (i.e., a value actually changed via DataSet*IfChanged).
    IronSoulNative.DataFlushIfDirty()

EndFunction

Bool Function BootstrapTick()
    if !_bootstrapActive
        return False
    endif

    Actor p = Game.GetPlayer()
    if !p
        ; PAUSE retry consumption while player ref isn't available.
        LogMsg(LOG_INFO(), "BootstrapTick: Player is None; waiting for player ref")
        _updateQueued = False
        QueueUpdate(1.0)
        return True
    endif

    ; Do NOT consume retries while in UI/menu mode (e.g., long RaceMenu sessions).
    if Utility.IsInMenuMode()
        LogMsg(LOG_DBG(), "BootstrapTick: In menu mode; waiting")
        _updateQueued = False
        QueueUpdate(1.5)
        return True
    endif

    ; Acquire a GUID when identity is ready.
    String bguid = EnsureGuid(p)
    if bguid == ""
        ; Identity not ready yet (name not available). Keep bootstrapping.
        _bootstrapTriesLeft -= 1
        if _bootstrapTriesLeft <= 0
            _bootstrapActive = False
            LogMsg(LOG_ERR(), "BootstrapTick: Identity not ready after timeout; continuing normal polling")
            return False
        endif

        LogMsg(LOG_INFO(), "BootstrapTick: Identity not ready; retrying (" + _bootstrapTriesLeft + "s left)")
        _updateQueued = False
        QueueUpdate(1.0)
        return True
    endif

    _bootstrapActive = False
    LogMsg(LOG_INFO(), "BootstrapTick: GUID ready; bootstrap complete (" + bguid + ")")

    return False
EndFunction

Function TickLuckRegen(Actor player, String guid)
    ; Advances per-character Luck regeneration (0 -> maxLuck over LUCK_REGEN_SECONDS).
    ; Uses real-time seconds but does NOT advance while menus are open.
    ; Updates state every second in script variables; persists at most once per 60s (unless forced).
    if !player || guid == ""
        return
    endif
    if !IsLuckActive()
        return
    endif

    Float nowRT = Utility.GetCurrentRealTime()
    if nowRT < _luckTickAt
        _luckTickAt = nowRT
    endif
    if (nowRT - _luckTickAt) < 1.0
        return
    endif
    _luckTickAt = nowRT

    Int nowSec = nowRT as Int

    LuckCooldownEnsureLoaded(player, guid, nowSec)

    Int lastSec = _luckCooldownLastSec
    Int playedTok = _luckCooldownPlayedTok
    Int played = DecodePlayed(playedTok)

    ; Initialize on first run so Luck starts at tier max on a new game.
    if lastSec <= 0 || playedTok <= 0
        played = LUCK_REGEN_SECONDS
        _luckCooldownPlayedTok = EncodePlayed(nowSec, played)
        _luckCooldownLastSec = nowSec
        LuckCooldownMarkDirty()
        ; New game: suppress threshold reminder spam by marking max threshold as already notified.
        PersistSetInt(player, GetKey(luckNotifiedTier, guid), 4, True)
        LuckCooldownPersistIfDue(player, guid, nowSec, True)
        return
    endif

    ; Menus pause luck regen: update anchor without advancing played time.
    if Utility.IsInMenuMode()
        if nowSec != lastSec
            _luckCooldownLastSec = nowSec
            LuckCooldownMarkDirty()
        endif
        LuckCooldownPersistIfDue(player, guid, nowSec, False)
        return
    endif

    Int delta = nowSec - lastSec
    if delta < 0
        delta = 0
    elseif delta > 60
        delta = 60
    endif

    if delta > 0
        played += delta
        if played > LUCK_REGEN_SECONDS
            played = LUCK_REGEN_SECONDS
        endif
        _luckCooldownPlayedTok = EncodePlayed(nowSec, played)
        _luckCooldownLastSec = nowSec
        LuckCooldownMarkDirty()
    elseif nowSec != lastSec
        _luckCooldownLastSec = nowSec
        LuckCooldownMarkDirty()
    endif

    ; Persist at most once per 60s during normal regen.
    LuckCooldownPersistIfDue(player, guid, nowSec, False)

    Int maxLuck = GetCurrentMaxLuck(player, guid)
    Int luckNow = GetLuckValue(player, guid)
    MaybeNotifyLuckThreshold(player, guid, luckNow, maxLuck)
    if luckNow < maxLuck
        LogMsg(LOG_DBG(), "TickLuckRegen: Luck=" + luckNow + "/" + maxLuck + " (" + played + "/" + LUCK_REGEN_SECONDS + "s)", True)
    endif
EndFunction

Function QueueUpdate(Float afDelay)
	; Debounced single-update scheduler (soonest wins):
	; - Prevents RegisterForSingleUpdate spam
	; - Allows urgent jobs to "upgrade" a previously queued slower tick
	if afDelay < 0.0
		afDelay = 0.0
	endif
	if _updateQueued
		; If a tick is already queued, only reschedule if the new delay is sooner.
		if _updateQueuedDelay <= 0.0 || afDelay < _updateQueuedDelay
			LogMsg(LOG_DBG(), "QueueUpdate: upgrading queued delay from " + _updateQueuedDelay + " -> " + afDelay, True)
			_updateQueuedDelay = afDelay
			; Cancel prior schedule and re-register the sooner one.
			UnregisterForUpdate()
			RegisterForSingleUpdate(afDelay)
		else
			LogMsg(LOG_DBG(), "QueueUpdate: skipped; already queued sooner/equal. queued=" + _updateQueuedDelay + " req=" + afDelay, True)
		endif
		return
	endif
	_updateQueued = True
	_updateQueuedDelay = afDelay
	;LogMsg(LOG_DBG(), "QueueUpdate: scheduled. delay=" + afDelay, True)
	RegisterForSingleUpdate(afDelay)
EndFunction

Function RescheduleIfJobsRemain()
    ; Keep the update loop tight while any short-lived jobs are pending, or while the player is in bleedout (so we react quickly).
    ; Safety watchdog: if a fast-loop job gets stuck, clear it to avoid 0.20s polling forever.
    Float nowRT = Utility.GetCurrentRealTime()

    if _pendingDisableRespawn && _pendingDisableRespawnStartedAt > 0.0 && (nowRT - _pendingDisableRespawnStartedAt) > PendingFastLoopWatchdogSeconds
        _pendingDisableRespawn = False
        LogMsg(LOG_INFO(), "RescheduleIfJobsRemain: cleared _pendingDisableRespawn after " + (nowRT - _pendingDisableRespawnStartedAt) + "s")
    endif
    if _pendingLoadMessage && _pendingLoadMessageStartedAt > 0.0 && (nowRT - _pendingLoadMessageStartedAt) > PendingFastLoopWatchdogSeconds
        _pendingLoadMessage = False
        LogMsg(LOG_INFO(), "RescheduleIfJobsRemain: cleared _pendingLoadMessage after " + (nowRT - _pendingLoadMessageStartedAt) + "s")
    endif

    ; Reset start timers when jobs complete normally.
    if !_pendingDisableRespawn
        _pendingDisableRespawnStartedAt = 0.0
    endif
    if !_pendingLoadMessage
        _pendingLoadMessageStartedAt = 0.0
    endif

    if _pendingDisableRespawn || _pendingLoadMessage || _deathEventLocked
        QueueUpdate(FastPollSeconds)

    else
        QueueUpdate(StandardPollSeconds)
    endif
EndFunction

; Called from OnPlayerLoadGame() and is responsible only for arming the load-message job.
Function ScheduleLoadMessage(Bool isLoadGame)
    ; Load message: always schedule on load (not suppressed by other pending messages).
    if isLoadGame
        float nowRT = Utility.GetCurrentRealTime()
        _pendingLoadMessage = True

        if _pendingLoadMessageStartedAt <= 0.0
            _pendingLoadMessageStartedAt = nowRT
        endif
        _loadMessageAt = nowRT + 2.00

    else
        _pendingLoadMessage = False
    endif
    ; Ensure the update loop is rescheduled.
    _updateQueued = False
    QueueUpdate(StandardPollSeconds)
EndFunction

Function ResetTransientState()

    _pendingDisableRespawn = False
    _pendingLoadMessage = False
    _pendingFeats = False
    _respawnWindowArmed = False

    _featsAt = 0.0
    _loadMessageAt = 0.0

    ; Heartbeat / cadence timers are transient (GetCurrentRealTime can reset across reloads).
    _nextHeartbeatAt = 0.0
    _updateQueuedDelay = 0.0
    _dbgLastOnUpdateRealTime = 0.0
    _dbgLastHeartbeatRealTime = 0.0

    ; Pending job guard timers
    _pendingDisableRespawnStartedAt = 0.0
    _pendingLoadMessageStartedAt = 0.0

    ; Runtime scheduling state
    _updateQueued = False

    ; GUID cache is transient and must be recomputed after load/init edges.
    _tickGuid = ""
    _tickGuidValid = False
    _guidTamperMintNotified = False
    _guidMintRetryAt = 0.0

    ; Death state should not persist across reload/init edges.
    _deathEventLocked = False

    _pendingRespawnMenu = False
    _respawnMenuArmed = False

    ; Quit latch is transient.
    _isQuitting = False

    ; Luck/Cooldown session cache is transient; reset to avoid stale deltas across reloads.
    _luckCooldownLoaded = False
    _luckCooldownDirty = False
    _luckCooldownGuid = ""
    _luckCooldownLastSec = 0
    _luckCooldownPlayedTok = 0
    _luckCooldownNextPersistAt = 0

    ; Luck roll telemetry
    _lastLuckRoll = 0
    _lastLuckValue = 0
    _lastLuckRollValid = False
    _suppressNextDefeatJournal = False

    ; Luck tick anchor is transient (real-time based).
    _luckTickAt = 0.0

    ; Respawn warning/availability caches are transient.
    _respawnWarningAt = 0.0
    _respawnAvailable = False

    ; Reset Vigilant quest cache so Vigilant can be installed/updated between sessions.
    _vigilantMq08Cache = None
    _vigilantMq08Tried = False

    ; Bootstrap session flags should not persist across reload/init edges.
    _bootstrapActive = False
    _bootstrapTriesLeft = 0

    ; SoulBonus runtime applied-tier cache is transient.
    _soulBonusAppliedTier = -1

    ; Key-dismiss state.
    _keyDismissActive = False
    _keyDismissPressed = False

EndFunction


; ======================
; --- Death Handling ---
; ======================

; Single entry point for ALL death events (HP <= 0)
Function HandlePlayerDying(Actor player, Actor caster)

    if _deathEventLocked
        return
    endif

    if !player || _modDisabled || _uninstallMode
        return
    endif

    ; Brawl exception
    if brawlQuest
        if (brawlQuest.GetStage() > 0 && brawlQuest.GetStage() < 250)
            LogMsg(LOG_INFO(), "HandlePlayerDying: Brawl detected, returning")
            return
        endif
    endif

    String guid = GetTickGuid(player)
    if guid == ""
        LogMsg(LOG_INFO(), "HandlePlayerDying: GUID missing -> routing to TrueDeathAndQuit")
        TrueDeathAndQuit(player)
        return
    endif

    _deathEventLocked = True

    LogMsg(LOG_INFO(), "HandlePlayerDying: Routing death event")

    ; 1) Dragon Soul Revive (highest priority)
    ; DSR path is self-contained: HandleDragonSoulRevive clears
    ; _deathEventLocked on all terminal exits and at cleanup completion.
    if IsDSRAvailable(player, guid)
        LogMsg(LOG_INFO(), "HandlePlayerDying: Dragon Soul Revive")
        HandleDragonSoulRevive(player, caster, guid)
        return
    endif

    ; 2) Cooldown Mode (DisableLuckSystem != 0)
    if IsCooldownModeActive()
        LogMsg(LOG_INFO(), "HandlePlayerDying: Cooldown mode")

        if IsCooldownReady(player, guid)
            LogMsg(LOG_INFO(), "HandlePlayerDying: Cooldown not active -> Respawn")
            HandleRespawn(player, guid)
        else
            LogMsg(LOG_INFO(), "HandlePlayerDying: Cooldown active -> True Death")

            TrueDeathAndQuit(player)
        endif

        _deathEventLocked = False
        return
    endif

    ; 3) Luck Mode (DisableLuckSystem == 0)
    if IsLuckActive()
        LogMsg(LOG_INFO(), "HandlePlayerDying: Luck mode")

        Bool luckSaved = PerformLuckRoll(player, guid)

        if luckSaved
            ; Journal: luck-based survival line (tiered by luck value used for the roll)
            JournalLogLuckOutcome(True, player, guid)
            LogMsg(LOG_INFO(), "HandlePlayerDying: Luck SUCCESS -> Respawn")
            HandleRespawn(player, guid)
        else
            ; Journal: luck-based defeat line includes roll + luck (and predicted death count)
            JournalLogLuckOutcome(False, player, guid)
            LogMsg(LOG_INFO(), "HandlePlayerDying: Luck FAIL -> True Death")

            TrueDeathAndQuit(player)
        endif

        _deathEventLocked = False
        return
    endif

    ; 4) Final fallback - no DSR, no luck, no cooldown
    LogMsg(LOG_INFO(), "HandlePlayerDying: Fallback True Death")
    TrueDeathAndQuit(player)

    _deathEventLocked = False

EndFunction

; Ensures player protection state matches the respawn-window contract.
; Policy:
; - Respawn integration disabled: keep player NON-essential.
; - Respawn integration enabled but window disarmed: keep player NON-essential.
; - Respawn window armed: keep player essential so bleedout-based respawn can run.
Function UpdatePlayerProtectionState(Actor player)
    if !player
        LogMsg(LOG_ERR(), "UpdatePlayerProtectionState: Player is None; skipping")
        return
    endif

    ; Don't toggle protection while dead/bleeding out (avoid edge cases during death handling).
    if player.IsDead() || player.IsBleedingOut() || _deathEventLocked == TRUE
        return
    endif

    ; Outside Respawn integration, keep the player non-essential.
    if !IsRespawnEnabled()
        if player.IsEssential()
            player.GetActorBase().SetEssential(False)
            LogMsg(LOG_INFO(), "UpdatePlayerProtectionState: SetEssential(FALSE) reason=respawn_disabled")
        endif
        return
    endif

    ; Enter bleedout only during an explicitly armed respawn window.
    if _respawnWindowArmed
        if !player.IsEssential()
            player.GetActorBase().SetEssential(True)
            LogMsg(LOG_INFO(), "UpdatePlayerProtectionState: SetEssential(TRUE) reason=respawn_window_armed")
        endif
        return
    endif

    ; Respawn integration active, but not armed: remain non-essential to avoid unsolicited bleedout.
    if player.IsEssential()
        player.GetActorBase().SetEssential(False)
        LogMsg(LOG_INFO(), "UpdatePlayerProtectionState: SetEssential(FALSE) reason=respawn_window_disarmed")
    endif
EndFunction


Function TrueDeathAndQuit(Actor player)
	if !player
		return
	endif

	; Identity (GUID required)
	String guid = GetTickGuid(player)
	if guid == ""
		LogMsg(LOG_ERR(), "TrueDeathAndQuit: Missing GUID; exiting without logging state")
		Debug.MessageBox("Could not determine character identity. Exiting to prevent state corruption.")
		FinalizeAndQuit()
		return
	endif

	; Commit: death + cycle reset
	; Record the death in authoritative stores (MainData immediate flush with co-save backup).
	IncrementTrueDeath(player, guid)

	; Read deaths AFTER increment so first true death is deathsNow == 1.
	Int deathsNow = PersistGetInt(player, GetKey(deathCount, guid), 0)

	; Luck/Cooldown reset: true-death milestone should consume the current cycle.
	if IsLuckActive()
		ResetLuck(player, guid)
		LuckCooldownForcePersistNow(player, guid)
		LogMsg(LOG_INFO(), "TrueDeathAndQuit: ResetLuck()")
	elseif IsCooldownModeActive()
		ResetCooldown(player, guid)
		LuckCooldownForcePersistNow(player, guid)
		LogMsg(LOG_INFO(), "TrueDeathAndQuit: ResetCooldown()")
	endif

    ; Avoid double front-loading delay when luck roll UI already consumed time.
    if ((_luckRollMessageMode == 2) || _disableLuckSystem || !IsRespawnEnabled())
        Utility.Wait(1.0)
    endif

    player.GetActorBase().SetEssential(False)
    player.EndDeferredKill()

    Utility.Wait(0.05)

    if player.IsEssential()
        LogMsg(LOG_INFO(), "TrueDeathAndQuit: Player is essential; calling KillEssential()")
        player.KillEssential()
    else
        LogMsg(LOG_INFO(), "TrueDeathAndQuit: Calling Kill()")
        player.Kill()
    endif

    ;player.PushActorAway(player, 0.1)

	Utility.Wait(1.0)

    ShowIronIntro(player, guid)

    ;Utility.Wait(1.0)

	; Ensure the player is not essential (kept as-is)
	player.GetActorBase().SetEssential(False)

	; Cached state for tier-aware menus
	; Soul tier/state: 0=CHIM, 1=Defiant, 2=Iron, 3=Silver, 4=Gold, 5=Ebon, 6=Platinum
	Int soulTierTD = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)

	; Transition gating + CHIM/Defiant state.
	Int defFeat = 0
	if !_disableDefiantFeat
		defFeat = PersistGetInt(player, GetKey(defiantFeatUnlocked, guid), 0)
	endif
    Bool chimActive = (soulTierTD == TIER_CHIM)
    Bool defiantActive = (soulTierTD == TIER_DEFIANT)

	; Defiant transition sequence (10th death, feat earned, not yet activated).
	if deathsNow == IRON_SOUL_MAX_LIVES && defFeat == 1 && !defiantActive && !chimActive
		; Commit Defiant activation FIRST so quitting/crashing during the UI sequence cannot lose it.
		LogMsg(LOG_INFO(), "HandleTrueDeath: Defiant Soul ACTIVATED (one-shot latch)")
		PersistSetInt(player, GetKey(soulTierIndex, guid), TIER_DEFIANT, True)
        SyncLuckNotifiedTierToCurrent(player, guid)

        if AudioCategoryMUS && !_disableMusicFade
            Float menuMusicVol = Utility.GetINIFloat("fVal3:AudioMenu")
            if menuMusicVol < 0.0 || menuMusicVol > 1.0
                menuMusicVol = 1.0
            endif
            IronSoulNative.MusicFadeOut(AudioCategoryMUS, 2.0, menuMusicVol)
        endif

		; Update splash/lvlWidget for next game launch.
        IronSoulNative.ApplyDynamicSplash(TIER_DEFIANT)
        IronSoulNative.ApplyDynamicLevelWidget(TIER_DEFIANT)

		IronSoulNative.DataFlushIfDirty()

		; Journal: Defiant activation milestone.
		JournalLogEvent("You refuse Sovngarde and rise again. Defiant Soul awakened. Death limit is now 100.")

		PlayDefiantTransitionMessageSequenceSWF(soulTierTD, False)
		FinalizeAndQuit()
		return
	endif

    ; CHIM transition sequence (10th death without Defiant transition, or 100th death in Defiant).
    if _CHIM == 1 && !chimActive
        Bool chimAtIronCap = (!defiantActive && deathsNow == IRON_SOUL_MAX_LIVES)
        Bool chimAtDefiantCap = (defiantActive && deathsNow == DEFIANT_SOUL_MAX_LIVES)
        if chimAtIronCap || chimAtDefiantCap
            LogMsg(LOG_INFO(), "HandleTrueDeath: CHIM Soul ACTIVATED (one-shot latch)")
            if AudioCategoryMUS && !_disableMusicFade
                Float menuMusicVolCHIM = Utility.GetINIFloat("fVal3:AudioMenu")
                if menuMusicVolCHIM < 0.0 || menuMusicVolCHIM > 1.0
                    menuMusicVolCHIM = 1.0
                endif
                IronSoulNative.MusicFadeOut(AudioCategoryMUS, 2.0, menuMusicVolCHIM)
            endif
            PromoteToCHIMTier(player, guid)
            PlayCHIMTransitionMessageSequenceSWF(soulTierTD, False)
            FinalizeAndQuit()
            return
        endif
    endif

	; CHIM tier: every death uses the dedicated CHIM death menu and exits.
	if chimActive
        if !_disableCharacterJournalLog
            if _suppressNextDefeatJournal
                _suppressNextDefeatJournal = False
            else
                JournalLogEvent("Defeated. Deaths: " + deathsNow + " / ???.")
            endif
        endif
        if !_disableDeathMessage
            OpenTimedMessageSWF_SFX("0chimdeath", 6.0, SFXDeath, player, False)
        endif
        FinalizeAndQuit()
        return
	endif

	; Non-CHIM caps + messaging.
	Int hardCap = IRON_SOUL_MAX_LIVES
	if defiantActive
		hardCap = DEFIANT_SOUL_MAX_LIVES
	endif

	Bool quitToMainMenu = False

	; Journal: normal defeat (non-cap). Special cases are handled above.
	if !_disableCharacterJournalLog
		if _suppressNextDefeatJournal
			_suppressNextDefeatJournal = False
		elseif deathsNow != hardCap
			JournalLogEvent("Defeated. Deaths: " + deathsNow + " / " + hardCap + ".")
		endif
	endif

	if deathsNow == hardCap
		; True permadeath scenario:
		; - 10th death without Defiant/CHIM transition
		; - 100th death with Defiant active when CHIM transition is not taken
		JournalLogEvent("No strength remains to rise. Sovngarde claims the fallen. Deaths: " + deathsNow + " / " + hardCap + ".")
        OpenTimedMessageSWF_KeyDismiss_SFX(ResolvePermadeathMenu(soulTierTD), 55.0, 27.0, SFXPermadeath, player, False)
		quitToMainMenu = True
	else
		if !_disableDeathMessage
			OpenTimedMessageSWF_SFX(ResolveDeathMessageMenu(soulTierTD, deathsNow), 6.0, SFXDeath, player, False)
		endif
	endif

	if quitToMainMenu
		FinalizeAndQuitMainMenu()
	else
		FinalizeAndQuit()
	endif
EndFunction

Function IncrementTrueDeath(Actor player, String guid)
	if !player || guid == ""
		LogMsg(LOG_ERR(), "IncrementTrueDeath: Invalid args (player None or GUID empty); death count not incremented")
		return
	endif

	int deaths = PersistGetInt(player, GetKey(deathCount, guid), 0) + 1
	PersistSetInt(player, GetKey(deathCount, guid), deaths, True)

	LogMsg(LOG_INFO(), "IncrementTrueDeath: GUID=" + guid + " deaths=" + deaths)
    IronSoulNative.DataFlushIfDirty()
EndFunction

Function FinalizeAndQuit()
    ; Centralized quit path:
    ;  - Stops periodic updates
    ;  - Waits 1 second for UI stability, then quits
    if _isQuitting
        return
    endif

    _isQuitting = True
    _updateQueued = False
    IronSoulNative.StopHealthMonitor()
    ; Flush luck/cooldown timing cache (write-gated) before quitting.
    Actor p = Game.GetPlayer()
    if p && _luckCooldownLoaded && _luckCooldownDirty && _luckCooldownGuid != ""
        Int nowSec = Utility.GetCurrentRealTime() as Int
        LuckCooldownPersistIfDue(p, _luckCooldownGuid, nowSec, True)
    endif

    UnregisterForUpdate()

    Utility.Wait(1.0)
    Debug.QuitGame()
EndFunction

Function FinalizeAndQuitMainMenu()
    ; Centralized main menu quit path:
    ;  - Stops periodic updates
    ;  - Waits 1 second for UI stability, then quits
    if _isQuitting
        return
    endif

    _isQuitting = True
    _updateQueued = False
    IronSoulNative.StopHealthMonitor()
    ; Flush luck/cooldown timing cache (write-gated) before quitting.
    Actor p = Game.GetPlayer()
    if p && _luckCooldownLoaded && _luckCooldownDirty && _luckCooldownGuid != ""
        Int nowSec = Utility.GetCurrentRealTime() as Int
        LuckCooldownPersistIfDue(p, _luckCooldownGuid, nowSec, True)
    endif
    UnregisterForUpdate()

    Utility.Wait(1.0)
    Game.QuitToMainMenu()
EndFunction

; Returns the death cap used for load enforcement and notifications:
;  - Iron Soul: 10
;  - Defiant Soul: 100
;  - CHIM Soul: effectively unbounded
Int Function GetEffectiveMaxLives(Actor player, String guid)
    if !player || guid == ""
        return IRON_SOUL_MAX_LIVES
    endif
    Int tierNow = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)

    if tierNow == TIER_CHIM
        return 2147483647
    endif

    if tierNow == TIER_DEFIANT
        return DEFIANT_SOUL_MAX_LIVES
    endif

    return IRON_SOUL_MAX_LIVES
EndFunction


; ==========================
; --- Dragon Soul Revive ---
; ==========================

Function HandleDragonSoulRevive(Actor target, Actor caster, String guid)

    if !target
        _deathEventLocked = False
        return
    endif

    if _disableDragonSoulRevive
        LogMsg(LOG_DBG(), "HandleDragonSoulRevive: Skipped - Dragon Soul Revive is DISABLED")
        _deathEventLocked = False
        return
    endif

    LogMsg(LOG_INFO(), "HandleDragonSoulRevive: Target=" + Target + " Caster=" + Caster + " GUID=" + guid)

    Target.DamageAV("DragonSouls", 1.0)

    if _dragonSoulReviveLimit > 0 && guid != ""
        Int soulTierDSR = PersistGetInt(target, GetKey(soulTierIndex, guid), TIER_IRON)
        if soulTierDSR != TIER_CHIM
            SyncDSRLimitState(target, guid)
            Int dsrPlayedNow = PersistGetInt(target, GetKey(dsrLimitPlayedSec, guid), 0)
            Int recentUsesBeforeRecord = CompactDSRLimitUses(target, guid, dsrPlayedNow)
            if recentUsesBeforeRecord == (_dragonSoulReviveLimit - 1)
                LogMsg(LOG_DBG(), "HandleDragonSoulRevive: revive reached rolling cap limit=" + _dragonSoulReviveLimit, True)
            endif
            RecordDSRLimitUse(target, guid, dsrPlayedNow)
            IronSoulNative.DataFlushIfDirty()
        endif
    endif
    
    ;Utility.Wait(1.0)

	; Heal Spell
	if bDispel
        if DisSpell
	        DisSpell.Cast(Target, Target)
        else
            LogMsg(LOG_ERR(), "HandleDragonSoulRevive: bDispel enabled but DisSpell is None; skipping dispel cast")
        endif
	endif

    ;Target.GetActorBase().SetEssential(False)

	;Target.SetGhost(true)
	;Target.PushActorAway(Target, 0.1)
	;Target.SetAV("Paralysis", 1.0)
	;Target.RestoreAV("Health", -(Target.GetAV("Health")+100))

	;Utility.Wait(1.0)

    ;Target.SetAV("Paralysis", 0.0)

    Bool introShown = ShowIronIntro(target, guid)

    if Marker
	    MarkerRef = Target.PlaceAtMe(Marker)
        if MarkerRef
	        MarkerRef.MoveTo(Target)
        endif
        Utility.Wait(0.1)
    else
        MarkerRef = None
        LogMsg(LOG_ERR(), "HandleDragonSoulRevive: Marker property is None; skipping absorb VFX anchor")
    endif

    if MarkerRef && MarkerRef.Is3DLoaded()
        if AbsorbEffect
            AbsorbEffect.Play(MarkerRef, 8.0, Target)
        else
            LogMsg(LOG_ERR(), "HandleDragonSoulRevive: AbsorbEffect is None; skipping source VFX")
        endif
        if AbsorbEffectTarget
	        AbsorbEffectTarget.Play(Target, 8.0, MarkerRef)
        else
            LogMsg(LOG_ERR(), "HandleDragonSoulRevive: AbsorbEffectTarget is None; skipping target VFX")
        endif
    else
        LogMsg(LOG_DBG(), "HandleDragonSoulRevive: MarkerRef has no 3D; skipping AbsorbEffect.Play")
    endif

    if NPCDragonDeathSequenceWind
	    NPCDragonDeathSequenceWind.play(Target)
    else
        LogMsg(LOG_ERR(), "HandleDragonSoulRevive: NPCDragonDeathSequenceWind is None; skipping wind SFX")
    endif
    if NPCDragonDeathSequenceExplosion
	    NPCDragonDeathSequenceExplosion.play(Target)
    else
        LogMsg(LOG_ERR(), "HandleDragonSoulRevive: NPCDragonDeathSequenceExplosion is None; skipping explosion SFX")
    endif

    Utility.Wait(1)

    ShaderParticleIntro()

    ; Dragon Soul Revive message
    if !_disableDragonSoulReviveMessage
        OpenTimedMessageSWF_SFX(SwfNoBonus(ResolveDSRMenu(Target, guid)), 3.0, PickDragonSoulReviveCastSFX(), Target)
    elseif introShown && AudioCategoryMUS && !_disableMusicFade
        ; Intro variant intentionally leaves music faded; restore when no follow-up menu will do it.
        IronSoulNative.MusicFadeIn(AudioCategoryMUS, 2.0)
    endif

    PlaySFX(PickDragonSoulReviveSFX(), Target)

    ShaderParticleOutro()

    ;Utility.Wait(0.5)

    if RestoreSpell
	    Target.AddSpell(RestoreSpell, false)
    else
        LogMsg(LOG_ERR(), "HandleDragonSoulRevive: RestoreSpell is None; skipping restore spell apply")
    endif

	;Utility.Wait(3.0)

	Target.RestoreAV("Stamina", Target.GetAVMax("Stamina"))
	Target.RestoreAV("Magicka", Target.GetAVMax("Magicka"))
	Target.RestoreAV("Health", Target.GetAVMax("Health")-Target.GetAV("Health"))

    LogMsg(LOG_INFO(), "HandleDragonSoulRevive: Cleanup started")

	;Utility.Wait(1.0)
	;Target.SetAV("Paralysis", 0.0)
	;Utility.Wait(3.0)
	;Target.SetGhost(false)
    Utility.Wait(1)

	Target.RestoreAV("Stamina", Target.GetAVMax("Stamina"))
	Target.RestoreAV("Magicka", Target.GetAVMax("Magicka"))
	Target.RestoreAV("Health", Target.GetAVMax("Health")-Target.GetAV("Health"))

    Utility.Wait(1)

	Target.RestoreAV("Stamina", Target.GetAVMax("Stamina"))
	Target.RestoreAV("Magicka", Target.GetAVMax("Magicka"))
	Target.RestoreAV("Health", Target.GetAVMax("Health")-Target.GetAV("Health"))

    Utility.Wait(1)

	Target.RestoreAV("Stamina", Target.GetAVMax("Stamina"))
	Target.RestoreAV("Magicka", Target.GetAVMax("Magicka"))
	Target.RestoreAV("Health", Target.GetAVMax("Health")-Target.GetAV("Health"))

    Utility.Wait(1)

	Target.RestoreAV("Stamina", Target.GetAVMax("Stamina"))
	Target.RestoreAV("Magicka", Target.GetAVMax("Magicka"))
	Target.RestoreAV("Health", Target.GetAVMax("Health")-Target.GetAV("Health"))

    Utility.Wait(1)

	Target.RestoreAV("Stamina", Target.GetAVMax("Stamina"))
	Target.RestoreAV("Magicka", Target.GetAVMax("Magicka"))
	Target.RestoreAV("Health", Target.GetAVMax("Health")-Target.GetAV("Health"))

    if RestoreSpell
	    Target.RemoveSpell(RestoreSpell)
    endif

	if (MarkerRef != none)
	    MarkerRef.disable()
	    MarkerRef.delete()
	endif

    _deathEventLocked = False
    LogMsg(LOG_DBG(), "HandleDragonSoulRevive: Cleanup finished")

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

Function SyncDSRLimitState(Actor player, String guid)
    if !player || guid == "" || _dragonSoulReviveLimit == 0
        return
    endif

    Int soulTier = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)
    if soulTier == TIER_CHIM
        return
    endif

    Int nowSec = Utility.GetCurrentRealTime() as Int
    Int lastSec = PersistGetInt(player, GetKey(dsrLimitLastSec, guid), 0)
    Int playedSec = PersistGetInt(player, GetKey(dsrLimitPlayedSec, guid), 0)

    if lastSec <= 0
        PersistSetInt(player, GetKey(dsrLimitLastSec, guid), nowSec, True)
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
        PersistSetInt(player, GetKey(dsrLimitPlayedSec, guid), playedSec, True)
    endif

    if nowSec != lastSec
        PersistSetInt(player, GetKey(dsrLimitLastSec, guid), nowSec, True)
    endif
EndFunction

Int Function CompactDSRLimitUses(Actor player, String guid, Int playedNow)
    if !player || guid == ""
        return 0
    endif

    Int use1 = PersistGetInt(player, GetKey(dsrLimitUse1, guid), -1)
    Int use2 = PersistGetInt(player, GetKey(dsrLimitUse2, guid), -1)
    Int use3 = PersistGetInt(player, GetKey(dsrLimitUse3, guid), -1)

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
        PersistSetInt(player, GetKey(dsrLimitUse1, guid), next1, True)
    endif
    if use2 != next2
        PersistSetInt(player, GetKey(dsrLimitUse2, guid), next2, True)
    endif
    if use3 != next3
        PersistSetInt(player, GetKey(dsrLimitUse3, guid), next3, True)
    endif

    return kept
EndFunction

Function RecordDSRLimitUse(Actor player, String guid, Int playedNow)
    if !player || guid == ""
        return
    endif

    Int use1 = PersistGetInt(player, GetKey(dsrLimitUse1, guid), -1)
    Int use2 = PersistGetInt(player, GetKey(dsrLimitUse2, guid), -1)
    Int use3 = PersistGetInt(player, GetKey(dsrLimitUse3, guid), -1)

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

    PersistSetInt(player, GetKey(dsrLimitUse1, guid), use1, True)
    PersistSetInt(player, GetKey(dsrLimitUse2, guid), use2, True)
    PersistSetInt(player, GetKey(dsrLimitUse3, guid), use3, True)
EndFunction

Bool Function IsDSRAvailable(Actor player, String guid)
    if !player
        return False
    endif
    if _disableDragonSoulRevive
        return False
    endif
    if BeastList && BeastList.HasForm(player.GetRace())
        return False
    endif
    if player.IsBleedingOut()
        return False
    endif
    if player.IsEssential()
        return False
    endif
    Float souls = player.GetAV("DragonSouls")
    if souls < 1.0
        return False
    endif

    if _dragonSoulReviveLimit == 0 || guid == ""
        return True
    endif

    Int soulTier = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)
    if soulTier == TIER_CHIM
        return True
    endif

    SyncDSRLimitState(player, guid)
    Int playedNow = PersistGetInt(player, GetKey(dsrLimitPlayedSec, guid), 0)
    Int recentUses = CompactDSRLimitUses(player, guid, playedNow)
    if recentUses >= _dragonSoulReviveLimit
        LogMsg(LOG_DBG(), "IsDSRAvailable: blocked by rolling limit", True)
        return False
    endif

    return True
EndFunction


; ===========================
; --- Respawn Integration ---
; ===========================
;
; Respawn - Death Overhaul is an optional dependency.
; If Config.DisableRespawn=1 or the quest cannot be resolved via GetFormFromFile,
; Respawn integration is treated as disabled (fail-closed).
;

Function HandleRespawn(Actor player, String guid)

    if !player || guid == ""
        LogMsg(LOG_ERR(), "HandleRespawn: Invalid args (player None or GUID empty); aborting respawn handler")
        return
    endif
    if !IsRespawnEnabled()
        LogMsg(LOG_INFO(), "HandleRespawn: Respawn integration unavailable; routing to TrueDeathAndQuit")
        TrueDeathAndQuit(player)
        return
    endif

    ; Luck / Cooldown reset
    if IsLuckActive()
        ResetLuck(player, guid)
        LuckCooldownForcePersistNow(player, guid)
        LogMsg(LOG_INFO(), "HandleRespawn: Resetting luck")
    elseif IsCooldownModeActive()
        ResetCooldown(player, guid)
        LuckCooldownForcePersistNow(player, guid)
        LogMsg(LOG_INFO(), "HandleRespawn: Resetting cooldown")
    endif

    LogMsg(LOG_INFO(), "HandleRespawn: Begin respawn")

    ; Arm respawn window, then allow bleedout route.
    _respawnWindowArmed = True
    LogMsg(LOG_INFO(), "HandleRespawn: Armed respawn window")
    player.GetActorBase().SetEssential(True)
    player.EndDeferredKill()
    LogMsg(LOG_INFO(), "HandleRespawn: Armed respawn window + SetEssential(TRUE) + EndDeferredKill()")

    if AudioCategoryMUS && !_disableMusicFade && !_disableRespawnMessage
        Float menuMusicVol = Utility.GetINIFloat("fVal3:AudioMenu")
        if menuMusicVol < 0.0 || menuMusicVol > 1.0
            menuMusicVol = 1.0
        endif
        IronSoulNative.MusicFadeOut(AudioCategoryMUS, 2.0, menuMusicVol)
    endif

    Bool introShown = ShowIronIntro(player, guid)

    if introShown && AudioCategoryMUS && !_disableMusicFade && _disableRespawnMessage
        ; Respawn warning menu is disabled, so restore music here.
        IronSoulNative.MusicFadeIn(AudioCategoryMUS, 2.0)
    endif

    ; Arm Respawn Menu
    _pendingRespawnMenu = True
    _respawnMenuArmed = False

    ; Allow bleedout/respawn transition time to complete before post-check
    ; Heavy breathing SFX
    Sound heavyBreathingSFX = PickHeavyBreathingSFX(player)
    Int heavyBreathingRace = 0
    Int heavyBreathingSex = 0
    Race heavyBreathingRaceRef = player.GetRace()
    ActorBase heavyBreathingBase = player.GetActorBase()
    if heavyBreathingRaceRef
        heavyBreathingRace = heavyBreathingRaceRef.GetFormID()
    endif
    if heavyBreathingBase
        heavyBreathingSex = heavyBreathingBase.GetSex()
    endif
    LogMsg(LOG_INFO(), "HandleRespawn: HeavyBreathing race=" + heavyBreathingRace + " sex=" + heavyBreathingSex + " sfx=" + heavyBreathingSFX)
    Utility.Wait(1.0)
    PlaySFX(heavyBreathingSFX, player)
    Utility.Wait(8.0)

    ; Clear death lock
    _deathEventLocked = False

    ; Determine essential state.
    UpdatePlayerProtectionState(player)

    ; Re-latch deferred-kill if you want it always-on during gameplay.
    player.StartDeferredKill()
    LogMsg(LOG_INFO(), "HandleRespawn: StartDeferredKill()")

    LogMsg(LOG_INFO(), "HandleRespawn: Respawn finished")

    _pendingDisableRespawnStartedAt = Utility.GetCurrentRealTime()
    _pendingDisableRespawn = True

EndFunction

Function ResolveRespawnQuest()
    _respawnQuest = None
    _respawnAvailable = False

    if _disableRespawn
        return
    endif

    Form f = Game.GetFormFromFile(0x00000D61, "Respawn - Death Overhaul.esp")
    Quest q = f as Quest
    if q
        _respawnQuest = q
        _respawnAvailable = True
        LogMsg(LOG_INFO(), "ResolveRespawnQuest: Respawn quest resolved: running=" + q.IsRunning())

    else
        ; Fail-closed: if we cannot resolve the quest, do not attempt integration.
        _respawnAvailable = False
        LogMsg(LOG_INFO(), "ResolveRespawnQuest: Respawn quest not found; treating Respawn integration as disabled")
    endif
EndFunction

Bool Function IsRespawnEnabled()
    return (!_disableRespawn) && _respawnAvailable && (_respawnQuest != None) && _respawnQuest.IsRunning()
EndFunction

Bool Function HandleDisableRespawn(Actor player)
    if _pendingDisableRespawn
        Float nowRT = Utility.GetCurrentRealTime()
        if _pendingDisableRespawnStartedAt <= 0.0
            _pendingDisableRespawnStartedAt = nowRT
        elseif (nowRT - _pendingDisableRespawnStartedAt) > PendingFastLoopWatchdogSeconds
            LogMsg(LOG_INFO(), "HandleDisableRespawn: watchdog cleared pending disable-respawn after " + (nowRT - _pendingDisableRespawnStartedAt) + "s")
            LogMsg(LOG_INFO(), "HandleDisableRespawn: Calling TrueDeathAndQuit")
            _pendingDisableRespawn = False
            _pendingRespawnMenu = False
            _respawnMenuArmed = False
            _respawnWindowArmed = False
            LogMsg(LOG_INFO(), "HandleDisableRespawn: Disarmed respawn window reason=watchdog_timeout")
            TrueDeathAndQuit(player)
            return False
        endif
    endif

    if !IsRespawnEnabled()
        _pendingDisableRespawn = False
        _respawnWindowArmed = False
        LogMsg(LOG_INFO(), "HandleDisableRespawn: Disarmed respawn window reason=respawn_disabled")
        return False
    endif
    if _pendingDisableRespawn
        LogMsg(LOG_DBG(), "HandleDisableRespawn: pending disable respawn. dead=" + player.IsDead() + " bleed=" + player.IsBleedingOut())
        ; If the player is truly dead (death screen / reload), respawn did not complete; stop polling.
        if player.IsDead() && !player.IsBleedingOut()
            LogMsg(LOG_INFO(), "HandleDisableRespawn: Player is dead; clearing pending disable-respawn state")
            _pendingDisableRespawn = False
            _pendingRespawnMenu = False
            _respawnMenuArmed = False
            _respawnWindowArmed = False
            _deathEventLocked = False
            LogMsg(LOG_INFO(), "HandleDisableRespawn: Disarmed respawn window reason=player_dead_before_recovery")
            return False
        endif
        if !player.IsBleedingOut() && !player.IsDead()
            ; arm delayed warning AFTER respawn completes
            if _pendingRespawnMenu && !_respawnMenuArmed
                _respawnMenuArmed = True
                _respawnWarningAt = Utility.GetCurrentRealTime() + 1.0
            endif

            _pendingDisableRespawn = False
            _respawnWindowArmed = False
            _deathEventLocked = False
            LogMsg(LOG_INFO(), "HandleDisableRespawn: Disarmed respawn window reason=recovered_from_bleedout")
            UpdatePlayerProtectionState(player)
            return False

        else
            _updateQueued = False
            QueueUpdate(FastPollSeconds)
            return True
        endif
    endif
    return False
EndFunction


; ============================================
; --- Luck + Cooldown (Respawn Resolution) ---
; ============================================
;
; Luck is tied to Respawn integration. If Respawn is unavailable/disabled, Luck is treated as inactive.
; Luck mode (DisableLuckSystem=0): roll vs Luck%, then Luck resets to 0 on respawn/true death and regenerates over 60 minutes.
; Cooldown mode (DisableLuckSystem=1): no roll; respawn only when the 60-minute cooldown is ready.

Int Function ComputeLuckRollD20(Int luck, Int roll100)
    ; Maps luck (0..100, tier-capped at runtime) and roll100 (1..100) into a D20 display roll (1..20).
    ; Formula: roll20 = ((luck - roll100 + 100) / 10) + 1, clamped to [1..20].
    if luck < 0
        luck = 0
    elseif luck > 100
        luck = 100
    endif

    if roll100 < 1
        roll100 = 1
    elseif roll100 > 100
        roll100 = 100
    endif

    Int delta = luck - roll100 ; -100..99
    Int roll20 = ((delta + 100) / 10) + 1
    if roll20 < 1
        roll20 = 1
    elseif roll20 > 20
        roll20 = 20
    endif
    return roll20
EndFunction

Bool Function PerformLuckRoll(Actor player, String guid)
    ; PerformLuckRoll
    ; Luck mode: roll vs derived Luck% (0..maxLuck)
    ; Cooldown mode: no roll (returns False)
    ;
    ; Returns:
    ;   True  -> Luck success (router should respawn)
    ;   False -> Luck failed OR luck inactive OR cooldown mode

    if !player || guid == ""
        LogMsg(LOG_ERR(), "PerformLuckRoll: Invalid args (player None or GUID empty) -> FAIL")
        return False
    endif

    ; Luck is tied to Respawn integration.
    if !IsLuckActive()
        LogMsg(LOG_INFO(), "PerformLuckRoll: Inactive (Luck tied to Respawn; Respawn disabled/unavailable) -> FAIL")
        return False
    endif

    ; Cooldown mode: no roll.
    if IsCooldownModeActive()
        LogMsg(LOG_INFO(), "PerformLuckRoll: Cooldown mode active (DisableLuckSystem!=0) -> No roll")
        return False
    endif

    Utility.Wait(1.0)

    ; Ensure cached timing state is loaded so GetLuckValue uses accurate session values.
    Int nowSec = Utility.GetCurrentRealTime() as Int
    LuckCooldownEnsureLoaded(player, guid, nowSec)

    Int luck = GetLuckValue(player, guid) ; derived [0..maxLuck]
    if luck < 0
        luck = 0
    elseif luck > 100
        luck = 100
    endif

    ; Always roll for journaling/telemetry consistency (even when luck is 0).
    Int roll100 = Utility.RandomInt(1, 100)
    Bool success = (roll100 <= luck)
    Int roll20 = ComputeLuckRollD20(luck, roll100)

    ; If luck failed (including luck==0), consume/reset the current chance.
    if !success
        ResetLuck(player, guid)
        LuckCooldownForcePersistNow(player, guid)
    endif

    if _luckRollMessageMode == 0
        String rollMenu = "luckroll" + roll20
        String resultMenu = "luckdefeat" + roll20
        Sound resultSFX = SFXLuckFailure
        if roll20 >= 11
            resultMenu = "lucksurvival" + roll20
            resultSFX = SFXLuckSuccess
        endif

        UI.CloseCustomMenu()
        IronSoulNative.SuppressCursor(True)
        Utility.Wait(0.05)

        PlaySFX(SFXLuckRoll, player)

        ; Full roll animation menu (luckroll1..luckroll20) plays for 2.35s.
        UI.OpenCustomMenu(rollMenu, 0)
        ;IronSoulNative.SuppressCursor(True)
        Utility.WaitMenuMode(2.5)

        PlaySFX(resultSFX, player)
        UI.CloseCustomMenu()

        UI.OpenCustomMenu(resultMenu, 0)
        ;IronSoulNative.SuppressCursor(True)
        Utility.WaitMenuMode(1.5)
        UI.CloseCustomMenu()
        IronSoulNative.SuppressCursor(False)
    elseif _luckRollMessageMode == 1
        String resultMenuOnly = "luckdefeat" + roll20
        Sound resultSFXOnly = SFXLuckFailure
        if roll20 >= 11
            resultMenuOnly = "lucksurvival" + roll20
            resultSFXOnly = SFXLuckSuccess
        endif

        PlaySFX(resultSFXOnly, player)
        ;IronSoulNative.SuppressCursor(True)
        ;Utility.Wait(0.05)
        UI.OpenCustomMenu(resultMenuOnly, 0)
        ;IronSoulNative.SuppressCursor(True)
        Utility.WaitMenuMode(1.0)
        UI.CloseCustomMenu()
        ;IronSoulNative.SuppressCursor(False)
    endif

    ; Stash the last roll inputs for the death router (journal output).
    _lastLuckRollValid = True
    _lastLuckRoll = roll100
    _lastLuckValue = luck

    LogMsg(LOG_INFO(), "PerformLuckRoll: LuckRoll: roll100=" + roll100 + " vs luck=" + luck + " -> " + success)

    return success

EndFunction

Function LuckCooldownEnsureLoaded(Actor player, String guid, Int nowSec)
    ; Loads Luck/Cooldown state into script variables once per GUID per session.
    ; IMPORTANT: Regen ticks must use cached _luckCooldownLastSec/_luckCooldownPlayedTok so delta math remains correct while writes are gated.
    if !player || guid == ""
        return
    endif
    if !_luckCooldownLoaded || _luckCooldownGuid != guid
        _luckCooldownGuid = guid
        _luckCooldownLastSec = PersistGetInt(player, GetKey(luckLastSec, guid), 0)
        _luckCooldownPlayedTok = PersistGetInt(player, GetKey(luckPlayedToken, guid), 0)
        _luckCooldownNextPersistAt = nowSec + _luckPersistGateSeconds
        _luckCooldownLoaded = True
        _luckCooldownDirty = False
        LogMsg(LOG_DBG(), "LuckCooldownEnsureLoaded: Loaded state for GUID=" + guid + " (lastSec=" + _luckCooldownLastSec + ", playedTok=" + _luckCooldownPlayedTok + ")")
    endif
EndFunction

Function LuckCooldownMarkDirty()
    _luckCooldownDirty = True
EndFunction

Function LuckCooldownPersistIfDue(Actor player, String guid, Int nowSec, Bool force)
    ; Persists cached Luck/Cooldown timing keys (luckPlayedToken + luckLastSec) with a 60s gate.
    if !player || guid == ""
        return
    endif
    if !_luckCooldownLoaded || _luckCooldownGuid != guid
        return
    endif
    if !_luckCooldownDirty && !force
        return
    endif
    if !force && nowSec < _luckCooldownNextPersistAt
        return
    endif

    PersistSetInt(player, GetKey(luckPlayedToken, guid), _luckCooldownPlayedTok, True)
    PersistSetInt(player, GetKey(luckLastSec, guid), _luckCooldownLastSec, True)

    _luckCooldownDirty = False
    _luckCooldownNextPersistAt = nowSec + _luckPersistGateSeconds
EndFunction

Function LuckCooldownForcePersistNow(Actor player, String guid)
    Int nowSec = Utility.GetCurrentRealTime() as Int
    LuckCooldownPersistIfDue(player, guid, nowSec, True)
    IronSoulNative.DataFlushIfDirty()
EndFunction

Bool Function IsLuckActive()
    if _disableLuckSystem
        return False
    endif
    return IsRespawnEnabled()
EndFunction

Bool Function IsCooldownModeActive()
    ; Cooldown mode is used when DisableLuckSystem != 0.
    ; Respawn is only possible when the 60-minute cooldown has fully regenerated.
    return IsRespawnEnabled() && (_disableLuckSystem != 0)
EndFunction

Bool Function IsCooldownReady(Actor player, String guid)
    if !player || guid == ""
        return False
    endif
    if !IsCooldownModeActive()
        return False
    endif

    ; Prefer cached state (writes may be gated).
    if _luckCooldownLoaded && _luckCooldownGuid == guid
        Int playedTokC = _luckCooldownPlayedTok
        if playedTokC <= 0
            return True
        endif
        Int playedC = DecodePlayed(playedTokC)
        return (playedC >= LUCK_REGEN_SECONDS)
    endif

    Int playedTok = PersistGetInt(player, GetKey(luckPlayedToken, guid), 0)
    if playedTok <= 0
        ; New game/uninitialized: start as ready.
        return True
    endif

    Int played = DecodePlayed(playedTok)
    return (played >= LUCK_REGEN_SECONDS)
EndFunction

Function ResetCooldown(Actor player, String guid)
    ; Arms the cooldown at 0 seconds played (i.e., respawn unavailable until it regenerates).
    ; Edge event: force persist immediately.
    if !player || guid == ""
        return
    endif
    Int nowSec = (Utility.GetCurrentRealTime() as Int)

    ; Keep session state in script variables.
    _luckCooldownGuid = guid
    _luckCooldownLastSec = nowSec
    _luckCooldownPlayedTok = EncodePlayed(nowSec, 0)
    _luckCooldownLoaded = True
    _luckCooldownDirty = True
    _luckCooldownNextPersistAt = nowSec + _luckPersistGateSeconds

    LuckCooldownPersistIfDue(player, guid, nowSec, True)

    ; Match Luck mode behavior: new cooldown cycle should re-emit recovery threshold notifications.
    PersistSetInt(player, GetKey(luckNotifiedTier, guid), 0, True)
EndFunction

Function TickCooldownRegen(Actor player, String guid)
    ; Advances the 60-minute respawn cooldown (0 -> ready) while NOT in menus.
    ; Uses the same timing keys as Luck regen (luckLastSec + luckPlayedToken).
    ; Updates state every second in script variables; persists at most once per 60s (unless forced).
    if !player || guid == ""
        return
    endif
    if !IsCooldownModeActive()
        return
    endif

    Float nowRT = Utility.GetCurrentRealTime()
    if nowRT < _luckTickAt
        _luckTickAt = nowRT
    endif
    if (nowRT - _luckTickAt) < 1.0
        return
    endif
    _luckTickAt = nowRT

    Int nowSec = nowRT as Int

    LuckCooldownEnsureLoaded(player, guid, nowSec)

    Int lastSec = _luckCooldownLastSec
    Int playedTok = _luckCooldownPlayedTok
    Int played = DecodePlayed(playedTok)

    ; Initialize on first run so cooldown starts "ready" on a new game.
    if lastSec <= 0 || playedTok <= 0
        played = LUCK_REGEN_SECONDS
        _luckCooldownPlayedTok = EncodePlayed(nowSec, played)
        _luckCooldownLastSec = nowSec
        LuckCooldownMarkDirty()
        ; New game: suppress threshold reminder spam by marking max threshold as already notified.
        PersistSetInt(player, GetKey(luckNotifiedTier, guid), 4, True)
        LuckCooldownPersistIfDue(player, guid, nowSec, True)
        return
    endif

    ; Menus pause cooldown regen: update anchor without advancing played time.
    if Utility.IsInMenuMode()
        if nowSec != lastSec
            _luckCooldownLastSec = nowSec
            LuckCooldownMarkDirty()
        endif
        LuckCooldownPersistIfDue(player, guid, nowSec, False)
        return
    endif

    Int delta = nowSec - lastSec
    if delta < 0
        delta = 0
    elseif delta > 60
        delta = 60
    endif

    if delta > 0
        played += delta
        if played > LUCK_REGEN_SECONDS
            played = LUCK_REGEN_SECONDS
        endif
        _luckCooldownPlayedTok = EncodePlayed(nowSec, played)
        _luckCooldownLastSec = nowSec
        LuckCooldownMarkDirty()
    elseif nowSec != lastSec
        _luckCooldownLastSec = nowSec
        LuckCooldownMarkDirty()
    endif

    LuckCooldownPersistIfDue(player, guid, nowSec, False)
    Int maxLuck = GetCurrentMaxLuck(player, guid)
    Int luckNow = GetLuckValue(player, guid)
    MaybeNotifyLuckThreshold(player, guid, luckNow, maxLuck)
    LogMsg(LOG_DBG(), "TickCooldownRegen: Cooldown: " + played + " / " + LUCK_REGEN_SECONDS)
EndFunction

Int Function GetLuckValue(Actor player, String guid)
    ; Returns the current luck value in [0..maxLuck] for the active soul tier.
    ; NOTE: Timing keys may be write-gated; prefer cached state when available for accurate rolls/notifications.
    if !player || guid == ""
        return 100
    endif
    Int maxLuck = GetCurrentMaxLuck(player, guid)
    if !IsLuckActive() && !IsCooldownModeActive()
        return maxLuck
    endif

    Int playedTok = 0

    if _luckCooldownLoaded && _luckCooldownGuid == guid
        playedTok = _luckCooldownPlayedTok
    else
        playedTok = PersistGetInt(player, GetKey(luckPlayedToken, guid), 0)
    endif

    if playedTok == 0
        return maxLuck
    endif

    Int playedSec = DecodePlayed(playedTok)
    ; playedSec==0 means freshly reset -> luck 0. Negative is treated as invalid/uninitialized.
    if playedSec < 0
        return maxLuck
    endif
    if playedSec == 0
        return 0
    endif

    if LUCK_REGEN_SECONDS <= 0
        return maxLuck
    endif

    Int luck = (playedSec * maxLuck) / LUCK_REGEN_SECONDS
    if luck < 0
        luck = 0
    elseif luck > maxLuck
        luck = maxLuck
    endif
    return luck
EndFunction

Int Function SetLuckValue(Actor player, String guid, Int targetLuck)
    ; Sets luck to an explicit value [0..maxLuck] by updating shared Luck/Cooldown timing state.
    ; Uses a deterministic ceil mapping so GetLuckValue reads back the requested integer value.
    if !player || guid == ""
        return -1
    endif

    Int nowSec = Utility.GetCurrentRealTime() as Int
    LuckCooldownEnsureLoaded(player, guid, nowSec)

    Int maxLuck = GetCurrentMaxLuck(player, guid)
    if maxLuck < 1
        maxLuck = 1
    endif

    Int clampedLuck = targetLuck
    if clampedLuck < 0
        clampedLuck = 0
    elseif clampedLuck > maxLuck
        clampedLuck = maxLuck
    endif

    Int playedSec = 0
    if clampedLuck > 0
        playedSec = ((clampedLuck * LUCK_REGEN_SECONDS) + maxLuck - 1) / maxLuck
    endif
    if playedSec < 0
        playedSec = 0
    elseif playedSec > LUCK_REGEN_SECONDS
        playedSec = LUCK_REGEN_SECONDS
    endif

    _luckCooldownGuid = guid
    _luckCooldownLastSec = nowSec
    _luckCooldownPlayedTok = EncodePlayed(nowSec, playedSec)
    _luckCooldownLoaded = True
    _luckCooldownDirty = True
    _luckCooldownNextPersistAt = nowSec + _luckPersistGateSeconds

    LuckCooldownPersistIfDue(player, guid, nowSec, True)

    ; Match threshold-notification state to the newly applied luck value.
    Int tierNow = LuckTier(clampedLuck, maxLuck)
    PersistSetInt(player, GetKey(luckNotifiedTier, guid), tierNow, True)

    return clampedLuck
EndFunction

Function ResetLuck(Actor player, String guid)
    ; Sets luck to 0 and (re)arms the 60-minute regen timer (menu-paused).
    ; Edge event: force persist immediately.
    if !player || guid == ""
        return
    endif
    if !IsLuckActive()
        return
    endif
    Int nowSec = Utility.GetCurrentRealTime() as Int

    ; Keep session state in script variables.
    _luckCooldownGuid = guid
    _luckCooldownLastSec = nowSec
    _luckCooldownPlayedTok = EncodePlayed(nowSec, 0)
    _luckCooldownLoaded = True
    _luckCooldownDirty = True
    _luckCooldownNextPersistAt = nowSec + _luckPersistGateSeconds

    LuckCooldownPersistIfDue(player, guid, nowSec, True)

    LogMsg(LOG_INFO(), "ResetLuck: Luck set to 0; regen timer armed (played=0/" + LUCK_REGEN_SECONDS + "s)")

    ; Reset threshold notifications for this regen cycle.
    PersistSetInt(player, GetKey(luckNotifiedTier, guid), 0, True)
EndFunction

Int Function LuckTier(Int luck, Int maxLuck)
    ; 0:<25%, 1:>=25%, 2:>=50%, 3:>=75%, 4:maxLuck
    if maxLuck <= 0
        maxLuck = 1
    endif
    if luck < 0
        luck = 0
    elseif luck > maxLuck
        luck = maxLuck
    endif
    if luck >= maxLuck
        return 4
    elseif luck >= PercentThresholdCeil(maxLuck, 75)
        return 3
    elseif luck >= PercentThresholdCeil(maxLuck, 50)
        return 2
    elseif luck >= PercentThresholdCeil(maxLuck, 25)
        return 1
    endif
    return 0
EndFunction

Int Function DecodePlayed(Int token)
	; Legacy values (<8192) remain valid.
	if token < 8192
		return token
	endif
	return token - ((token / 8192) * 8192)
EndFunction

Int Function EncodePlayed(Int nowSec, Int playedSec)
    ; played stored in low 13 bits (0..8191), epoch in the high bits
    if playedSec < 0
        playedSec = 0

    elseif playedSec > 8191
        playedSec = 8191
    endif
    ; To prevent overflow when shifting real-time seconds, clamp the timestamp to a safe modulus.
    ; 8192 = 2^13; we restrict nowSec to 2^18 to guarantee (trimmedNow * 8192) < 2^31.
    Int epochMod = 262144 ; 2^18
    Int chunks = nowSec / epochMod
    Int trimmedNow = nowSec - (chunks * epochMod)
    return (trimmedNow * 8192) + playedSec
EndFunction


; =========================
; --- Character Journal ---
; =========================
;
; Controller forwards journal lines to the SKSE plugin, which appends
; them to:
;   Data\SKSE\Plugins\IronSoulCharacterJournal.log
;
; Line format:
;   <CharacterName> Day X: <Event text...>
;
; IMPORTANT:
; - Papyrus MUST pass only: "Day X: <Event text...>"
; - The SKSE plugin prepends: "<CharacterName> " automatically.
;
; Day numbering:
; - "Day X" is computed from the character's persisted journal start day (stored once per GUID).
; - Day 1 is the minimum (no Day 0).
;
; Opener:
; - "Day 1: Iron Soul awakens." is emitted once per GUID (persisted per-GUID latch).
; - _JournalLogEvent guarantees the opener prints before the first event line.

; Journal Opener (One-time Line)
Function JournalEnsureOpenerLogged(Actor player, String guid)
	; Writes the Day 1 opener once per GUID.
	if !player || guid == ""
		return
	endif
	Int logged = PersistGetInt(player, GetKey(journalOpenerLogged, guid), 0)
	if logged == 1
		return
	endif
	IronSoulNative.LogJournalEntry("Day 1: Iron Soul awakens.")
	LogMsg(LOG_INFO(), "JournalEnsureOpenerLogged: Logged journal opener (one-shot)")
	PersistSetInt(player, GetKey(journalOpenerLogged, guid), 1, True)
EndFunction

Function JournalLogEvent(String eventText)
	; Primary journal entry writer (SKSE-backed).
	; - Computes Day X from the persisted journal start day (stored once per GUID).
	; - Ensures the opener prints once per GUID before the first event line.
	; - Sends only: "Day X: <Event text...>" to IronSoulNative.LogJournalEntry().
	; - The SKSE plugin prepends "<CharacterName> " automatically.

    if _disableCharacterJournalLog
        LogMsg(LOG_DBG(), "JournalLogEvent: Skipped (DisableCharacterJournalLog=1)")
        return
    endif
    if eventText == ""
        LogMsg(LOG_DBG(), "JournalLogEvent: Skipped (Empty eventText)")
        return
    endif

    Actor player = Game.GetPlayer()
    if !player
        LogMsg(LOG_ERR(), "JournalLogEvent: Skipped (Player is None)")
        return
    endif

    String guid = GetTickGuid(player)
    if guid == ""
        String pn = ""
        pn = IronSoulNative.GetPlayerName()
        LogMsg(LOG_DBG(), "JournalLogEvent: skipped (GUID empty). Name='" + pn + "' MenuMode=" + Utility.IsInMenuMode())
        return
    endif

    Int startDay = JournalEnsureStartDay(player, guid)
    JournalEnsureOpenerLogged(player, guid)

    Int dayIdx = 1
    if startDay != -1
        Int nowDay = Utility.GetCurrentGameTime() as Int
        dayIdx = (nowDay - startDay) + 1
    endif
    if dayIdx < 1
        dayIdx = 1
    endif

    String line = "Day " + dayIdx + ": " + eventText
    LogMsg(LOG_DBG(), "JournalLogEvent: WRITE -> " + line)
    IronSoulNative.LogJournalEntry(line)
EndFunction

; Luck outcome journaling (Luck-mode only)
Function JournalLogLuckOutcome(Bool survived, Actor player, String guid)
    if _disableCharacterJournalLog
        return
    endif
    if !player || guid == ""
        return
    endif
    if !_lastLuckRollValid
        return
    endif

    Int roll = _lastLuckRoll
    Int luck = _lastLuckValue
    Int maxLuck = GetCurrentMaxLuck(player, guid)

    ; Consume the cached roll inputs (one-shot).
    _lastLuckRollValid = False

    if survived
        JournalLogEvent(JournalLuckOutcomeText(luck, roll, maxLuck))
        return
    endif

    ; Defeat line includes predicted death count (TrueDeathAndQuit increments after this).
    Int deathsPred = PersistGetInt(player, GetKey(deathCount, guid), 0) + 1
    Int cap = GetEffectiveMaxLives(player, guid)
    String capText = "" + cap
    if cap >= 2000000000
        capText = "???"
    endif

    JournalLogEvent("Defeated. Deaths: " + deathsPred + " / " + capText + ". Roll: " + roll + ". Luck: " + luck + ".")
    _suppressNextDefeatJournal = True
EndFunction

String Function JournalLuckOutcomeText(Int luck, Int roll, Int maxLuck)
    ; Luck tier text based on percentage of current max luck.
    Int tier = LuckTier(luck, maxLuck)
    if tier >= 4
        return "Fate cheated. Roll: " + roll + ". Luck: " + luck + "."
    elseif tier == 3
        return "Death denied. Roll: " + roll + ". Luck: " + luck + "."
    elseif tier == 2
        return "Fortune favors the bold. Roll: " + roll + ". Luck: " + luck + "."
    elseif tier == 1
        return "Narrowly escaped death. Roll: " + roll + ". Luck: " + luck + "."
    endif
    return "Barely clung to life. Roll: " + roll + ". Luck: " + luck + "."
EndFunction

Int Function JournalEnsureStartDay(Actor player, String guid)
	; Stores absolute game-day integer (Utility.GetCurrentGameTime() as Int) once.
	; Day index in journal = (nowDay - startDay) + 1.
	if _disableCharacterJournalLog
		return -1
	endif
	if !player || guid == ""
		return -1
	endif

	Int startDay = PersistGetInt(player, GetKey(journalStartDay, guid), -1)
	if startDay == -1
		Int nowDay = Utility.GetCurrentGameTime() as Int
		PersistSetInt(player, GetKey(journalStartDay, guid), nowDay, True)
		startDay = nowDay
	endif
	return startDay
EndFunction

; ======================
; -- Identity & GUID ---
; ======================
; IS_9975
; Primary Character GUID (authoritative co-save identity key).

; G.U.INDEX
; Pipe-delimited global GUID index used only for rare co-save recovery.
String Property _guidIndexKey = "G.U.INDEX" Auto Hidden

; ---------------------------------
; --- Plugin-backed GUID system ---
; ---------------------------------
; Plugin provides:
;   - GenerateGuidUnique(playerName) -> collision-safe GUID minting + marker claim
;   - Binary DataStore (MainData + MirrorData) with self-heal + save-callback/explicit flush behavior
;
; Controller responsibilities:
;   - Write GUID once to co-save when identity is ready
;   - Maintain Identity Snapshot in MainData for recovery:
;       I.N = Name
;       I.R = RaceFormID
;       I.L = Level
;       I.D = LastSeenGameDay
;   - Ensure collision marker exists for recovered GUIDs

; --- Recovery tolerances ---
Int Property _idLevelTolerance = 2 Auto Hidden ; +/- level match window
Int Property _idDayTolerance   = 3 Auto Hidden ; +/- day match window

String Function EnsureGuid(Actor player)
    ; Authoritative identity: co-save slot IS_9975. MainData stores per-GUID data only.
    if !player
        return ""
    endif

    ; 1) Co-save authoritative fast path.
    String guid = StorageUtil.GetStringValue(player, characterGuid, "")
    if guid != ""
        Int lvlNow = player.GetLevel()
        if lvlNow <= 1
            ; New game exception: trust co-save identity directly.
            EnsureGuidMarker(guid)
            return guid
        endif

        if !IronSoulNative.DataStoreReady()
            ; Avoid trust decisions from potentially uninitialized MainData.
            LogMsg(LOG_INFO(), "EnsureGuid: co-save GUID present but MainData not ready; deferring trust decision")
            return ""
        endif

        String idx = IronSoulNative.DataGetString(_guidIndexKey, "")
        if idx == ""
            ; Empty index exception: cannot prove co-save is wrong.
            EnsureGuidMarker(guid)
            return guid
        endif

        ; Known GUID in marker/index: trust and heal marker/index.
        if IronSoulNative.DataGetInt("G.U." + guid, 0) != 0
            EnsureGuidInIndex(guid)
            return guid
        endif

        String hay = "|" + idx + "|"
        String needle = "|" + guid + "|"
        if StringUtil.Find(hay, needle) != -1
            EnsureGuidMarker(guid)
            return guid
        endif

        ; Unknown co-save GUID at level > 1 with non-empty index is suspicious.
        ; Do not bless here. Attempt tamper recovery/mint once identity is ready (works for load and bootstrap retries).
        String tamperName = IronSoulNative.GetPlayerName()
        if tamperName == ""
            LogMsg(LOG_INFO(), "EnsureGuid: co-save GUID not trusted; identity name not ready yet")
            return ""
        endif

        String tamperResolved = TryRestoreGuidTamperedCosave(player, tamperName, guid)
        if tamperResolved != ""
            return tamperResolved
        endif

        LogMsg(LOG_INFO(), "EnsureGuid: co-save GUID is not trusted by MainData; recovery unresolved")
        return ""
    endif

    ; 2) Identity must be ready (RaceMenu / very early loads can return empty).
    String pn = IronSoulNative.GetPlayerName()
    if pn == ""
        return ""
    endif

    ; Don't mint identity while still in chargen.
    if Utility.IsInMenuMode()
        return ""
    endif

    ; Delay placeholder-name minting until bootstrap has progressed a bit.
    if pn == "Prisoner" || pn == "Player"
        if _bootstrapActive && _bootstrapTriesLeft > 5
            LogMsg(LOG_INFO(), "EnsureGuid: delaying placeholder name (" + pn + "), bootstrapTriesLeft=" + _bootstrapTriesLeft)
            return ""
        elseif _bootstrapActive
            LogMsg(LOG_INFO(), "EnsureGuid: placeholder name now allowed (" + pn + ")")
        endif
    endif

    if !IronSoulNative.DataStoreReady()
        ; Do not run MainData-based restore/mint while datastore is still initializing.
        LogMsg(LOG_INFO(), "EnsureGuid: MainData not ready; deferring GUID restore/mint")
        return ""
    endif

    ; 3) Rare recovery path: attempt to restore GUID from identity snapshots (only if beyond level 1 and co-save is missing).
    guid = TryRestoreGuidMissingCosave(player, pn)
    if guid != ""
        return guid
    endif

    ; 4) Mint a new GUID (collision-safe) and commit to co-save.
    guid = IronSoulNative.GenerateGuidUnique(pn)
    if guid == ""
        return ""
    endif

    StorageUtil.SetStringValue(player, characterGuid, guid)
    EnsureGuidMarker(guid)

    ; Flush ASAP to avoid re-minting on crash.
    IronSoulNative.DataFlushIfDirty()

    LogMsg(LOG_INFO(), "EnsureGuid: GUID FINALIZED (" + guid + ", name=" + pn + ")")

    SyncSoulBonusAbility(player, guid)

    return guid
EndFunction

String Function GetTickGuid(Actor player)
    ; Returns the cached GUID. If not cached, compute lazily and cache only when non-empty.
    if _tickGuidValid
        return _tickGuid
    endif

    String g = EnsureGuid(player)
    if g != ""
        _tickGuid = g
        _tickGuidValid = True
        return g
    endif

    ; Not ready yet
    return ""
EndFunction

Function EnsureGuidMarker(String guid)
	; Required whenever the GUID was obtained from any source OTHER than
	; IronSoulNative.GenerateGuidUnique(). Safe to call repeatedly.
	;
	; Also maintains a global GUID index (G.U.INDEX) used only for rare
	; co-save deletion recovery.
	if guid == ""
		return
	endif

	IronSoulNative.DataSetIntIfChanged("G.U." + guid, 1)
	EnsureGuidInIndex(guid)
EndFunction

Function EnsureGuidInIndex(String guid)
	; Maintains a pipe-delimited global index of known GUIDs in MainData.
	; Format: "guidA|guidB|guidC"
	if guid == ""
		return
	endif

	String idx = IronSoulNative.DataGetString(_guidIndexKey, "")
	; Fast path: empty index
	if idx == ""
		IronSoulNative.DataSetStringIfChanged(_guidIndexKey, guid)
		return
	endif

	; Containment check with delimiters to avoid substring false positives.
	String hay = "|" + idx + "|"
	String needle = "|" + guid + "|"
	if StringUtil.Find(hay, needle) != -1
		return
	endif

	IronSoulNative.DataSetStringIfChanged(_guidIndexKey, idx + "|" + guid)
EndFunction

Function WriteIdentitySnapshotStatic(String guid, Actor player, String pn)
	; Writes the static identity snapshot fields in MainData (idempotent).
	; Intended to run once per load/reload using an already-cached GUID.
	; Keys (per GUID, stored as "<prefix>:<guid>"):
	;  - I.N : Name
	;  - I.R : RaceFormID
	if guid == "" || !player || pn == ""
		return
	endif

	if player.GetLevel() <= 1
		return
	endif

	Int rid = 0
	Race r = player.GetRace()
	if r
		rid = r.GetFormID()
	endif

	IronSoulNative.DataSetStringIfChanged(MakeKey("I.N", guid), pn)
	IronSoulNative.DataSetIntIfChanged(MakeKey("I.R", guid), rid)
EndFunction

Function WriteIdentitySnapshotLastSeen(String guid, Actor player)
	; Writes the "last seen" identity snapshot fields in MainData (idempotent).
	; Intended to run periodically (~5s cadence) using an already-cached GUID.
	; Keys (per GUID, stored as "<prefix>:<guid>"):
	;  - I.L : Last saved level
	;  - I.D : Last seen game day
	if guid == "" || !player
		return
	endif

	Int lvl = player.GetLevel()
	if lvl <= 1
		return
	endif

	Int dayNow = Utility.GetCurrentGameTime() as Int

	IronSoulNative.DataSetIntIfChanged(MakeKey("I.L", guid), lvl)
	IronSoulNative.DataSetIntIfChanged(MakeKey("I.D", guid), dayNow)
EndFunction

String Function TryRestoreGuidMissingCosave(Actor player, String pn)
	; Co-save deletion protection (rare path).
	; NEVER restore unless the player is beyond level 1 (new games naturally start at level 1).
	; Requires identity-ready (pn != "").
	;
	; Recovery signals (4 total):
	;      1) Name match (I.N:<guid>)
	;      2) RaceFormID match (I.R:<guid>)
	;      3) Level within +/- _idLevelTolerance of last-seen level (I.L:<guid>)
	;      4) Game day within +/- _idDayTolerance of last-seen day (I.D:<guid>)
	;
	; Auto-restore policy (hardened to avoid cross-profile mis-association):
	;  - Candidate must be UNIQUE best (best score must be strictly above runner-up).
	;  - Accept 4/4 directly.
	;  - Accept 3/4 only when both strong anchors match (Name + Race) AND
	;    runner-up score is <= 1 (clear separation from other historical GUIDs).
	if !player || pn == ""
		return ""
	endif

	Int lvlNow = player.GetLevel()
	if lvlNow <= 1
		return ""
	endif

	; Enumerate known GUIDs from the global index maintained under G.U.INDEX.
	String idx = IronSoulNative.DataGetString(_guidIndexKey, "")
	if idx == ""
		return ""
	endif

	; Current identity fields
	Int ridNow = 0
	Race rNow = player.GetRace()
	if rNow
		ridNow = rNow.GetFormID()
	endif
	Int dayNow = Utility.GetCurrentGameTime() as Int

	String bestGuid = ""
	Int bestMatches = 0
	Int bestDayDelta = 999999
	Int bestLvlDelta = 999999
	Int secondBestMatches = 0
	Bool bestNameMatch = False
	Bool bestRaceMatch = False

	Int i = 0
	Int len = StringUtil.GetLength(idx)
	While i < len
		Int j = StringUtil.Find(idx, "|", i)
		String cand = ""
		if j == -1
			cand = StringUtil.Substring(idx, i)
			i = len
		else
			cand = StringUtil.Substring(idx, i, j - i)
			i = j + 1
		endif

		if cand == ""
			; Skip empty token.
		else

			; Snapshot reads (per GUID)
		String nSaved = IronSoulNative.DataGetString(MakeKey("I.N", cand), "")
		Int rSaved = IronSoulNative.DataGetInt(MakeKey("I.R", cand), -1)
		Int lSaved = IronSoulNative.DataGetInt(MakeKey("I.L", cand), -1)
		Int tSaved = IronSoulNative.DataGetInt(MakeKey("I.D", cand), -1)

		Int matches = 0
		Bool nameMatch = False
		Bool raceMatch = False

		; 1) Name
		if nSaved != "" && pn == nSaved
			matches += 1
			nameMatch = True
		endif

		; 2) Race
		if rSaved >= 0 && ridNow == rSaved
			matches += 1
			raceMatch = True
		endif

		; 3) Level proximity
		Int dL = 999999
		if lSaved >= 0
			dL = lvlNow - lSaved
			if dL < 0
				dL = -dL
			endif
			if dL <= _idLevelTolerance
				matches += 1
			endif
		endif

		; 4) Day proximity
		Int dT = 999999
		if tSaved >= 0
			dT = dayNow - tSaved
			if dT < 0
				dT = -dT
			endif
			if dT <= _idDayTolerance
				matches += 1
			endif
		endif

		; Keep the best candidate. Ties: prefer closer day, then closer level.
		Bool takesBest = False
		if matches > bestMatches
			takesBest = True
		elseif matches == bestMatches && matches > 0
			if dT < bestDayDelta || (dT == bestDayDelta && dL < bestLvlDelta)
				takesBest = True
			endif
		endif

		if takesBest
			if bestMatches > secondBestMatches
				secondBestMatches = bestMatches
			endif
			bestGuid = cand
			bestMatches = matches
			bestDayDelta = dT
			bestLvlDelta = dL
			bestNameMatch = nameMatch
			bestRaceMatch = raceMatch
		else
			if matches > secondBestMatches
				secondBestMatches = matches
			endif
		endif
		endif
	EndWhile

	Bool strongUnique = False
	if bestGuid != "" && bestMatches > secondBestMatches
		if bestMatches >= 4
			strongUnique = True
		elseif bestMatches == 3 && bestNameMatch && bestRaceMatch && secondBestMatches <= 1
			strongUnique = True
		endif
	endif

	if !strongUnique
		return ""
	endif

	; Restore authoritative GUID back to co-save directly (do NOT use Persist helpers).
	StorageUtil.SetStringValue(player, characterGuid, bestGuid)
	EnsureGuidMarker(bestGuid)
	IronSoulNative.DataFlushIfDirty()
	return bestGuid
EndFunction

String Function TryRestoreGuidTamperedCosave(Actor player, String pn, String cosaveGuid)
	; Co-save tamper/corruption protection (rare path).
	;
	; Scenario:
	;  - Co-save GUID exists, but MainData suggests a different historical GUID set (G.U.INDEX),
	;    and the co-save GUID is NOT present in MainData (no marker + not in index).
	;
	; Policy:
	;  - Prefer co-save if MainData index is empty (MainData likely wiped / fresh install).
	;  - Never attempt restore at level 1 (new games).
	;  - Only overwrite co-save when recovery returns a strong, unique winner
	;    (same hardened rule used by missing co-save recovery).
	;
	; Returns:
	;  - The GUID you should treat as authoritative for this session.
	; Side effects:
	;  - If a strong match is found, overwrites co-save to the recovered GUID and ensures marker/index.
	;  - If strict recovery is inconclusive, mints a new GUID to keep gameplay non-blocking.

	if !player
		return ""
	endif

	if cosaveGuid == ""
		return ""
	endif

	; If identity isn't ready yet, do nothing.
	if pn == ""
		return cosaveGuid
	endif

	; Keep placeholder-name mint policy consistent with EnsureGuid().
	if pn == "Prisoner" || pn == "Player"
		if _bootstrapActive && _bootstrapTriesLeft > 5
			LogMsg(LOG_INFO(), "TryRestoreGuidTamperedCosave: delaying suspicious GUID resolution for placeholder name (" + pn + "), bootstrapTriesLeft=" + _bootstrapTriesLeft)
			return ""
		endif
	endif

	Int lvlNow = player.GetLevel()
	if lvlNow <= 1
		; New games naturally start at level 1. Do not "recover".
		EnsureGuidMarker(cosaveGuid)
		return cosaveGuid
	endif

	if !IronSoulNative.DataStoreReady()
		LogMsg(LOG_INFO(), "TryRestoreGuidTamperedCosave: MainData not ready; deferring suspicious GUID resolution")
		return ""
	endif

	; If MainData has no index, we cannot prove co-save is wrong. Prefer co-save and heal MainData.
	String idx = IronSoulNative.DataGetString(_guidIndexKey, "")
	if idx == ""
		EnsureGuidMarker(cosaveGuid)
		return cosaveGuid
	endif

	; If MainData already knows this GUID, accept it and heal marker/index.
	if IronSoulNative.DataGetInt("G.U." + cosaveGuid, 0) != 0
		EnsureGuidInIndex(cosaveGuid)
		return cosaveGuid
	endif

	; Index containment check (delimiter-safe).
	String hay = "|" + idx + "|"
	String needle = "|" + cosaveGuid + "|"
	if StringUtil.Find(hay, needle) != -1
		EnsureGuidMarker(cosaveGuid)
		return cosaveGuid
	endif

	; At this point, co-save GUID exists but is unknown to MainData -> suspicious.
	; Try to recover the most likely historical GUID via identity snapshots.

	; Current identity fields
	Int ridNow = 0
	Race rNow = player.GetRace()
	if rNow
		ridNow = rNow.GetFormID()
	endif
	Int dayNow = Utility.GetCurrentGameTime() as Int

	String bestGuid = ""
	Int bestMatches = 0
	Int bestDayDelta = 999999
	Int bestLvlDelta = 999999
	Int secondBestMatches = 0
	Bool bestNameMatch = False
	Bool bestRaceMatch = False

	Int i = 0
	Int len = StringUtil.GetLength(idx)
	While i < len
		Int j = StringUtil.Find(idx, "|", i)
		String cand = ""
		if j == -1
			cand = StringUtil.Substring(idx, i)
			i = len
		else
			cand = StringUtil.Substring(idx, i, j - i)
			i = j + 1
		endif

		if cand == ""
			; Skip empty token.
		elseif cand == cosaveGuid
			; Skip: co-save GUID is explicitly *not* trusted here.
		else
			; Snapshot reads (per GUID)
			String nSaved = IronSoulNative.DataGetString(MakeKey("I.N", cand), "")
			Int rSaved = IronSoulNative.DataGetInt(MakeKey("I.R", cand), -1)
			Int lSaved = IronSoulNative.DataGetInt(MakeKey("I.L", cand), -1)
			Int tSaved = IronSoulNative.DataGetInt(MakeKey("I.D", cand), -1)

			Int matches = 0
			Bool nameMatch = False
			Bool raceMatch = False

			; 1) Name
			if nSaved != "" && pn == nSaved
				matches += 1
				nameMatch = True
			endif

			; 2) Race
			if rSaved >= 0 && ridNow == rSaved
				matches += 1
				raceMatch = True
			endif

			; 3) Level proximity
			Int dL = 999999
			if lSaved >= 0
				dL = lvlNow - lSaved
				if dL < 0
					dL = -dL
				endif
				if dL <= _idLevelTolerance
					matches += 1
				endif
			endif

			; 4) Day proximity
			Int dT = 999999
			if tSaved >= 0
				dT = dayNow - tSaved
				if dT < 0
					dT = -dT
				endif
				if dT <= _idDayTolerance
					matches += 1
				endif
			endif

			; Keep the best candidate. Ties: prefer closer day, then closer level.
			Bool takesBest = False
			if matches > bestMatches
				takesBest = True
			elseif matches == bestMatches && matches > 0
				if dT < bestDayDelta || (dT == bestDayDelta && dL < bestLvlDelta)
					takesBest = True
				endif
			endif

			if takesBest
				if bestMatches > secondBestMatches
					secondBestMatches = bestMatches
				endif
				bestGuid = cand
				bestMatches = matches
				bestDayDelta = dT
				bestLvlDelta = dL
				bestNameMatch = nameMatch
				bestRaceMatch = raceMatch
			else
				if matches > secondBestMatches
					secondBestMatches = matches
				endif
			endif
		endif
	EndWhile

	; Require a strong, unambiguous winner to overwrite co-save.
	Bool strongUnique = False
	if bestGuid != "" && bestMatches > secondBestMatches
		if bestMatches >= 4
			strongUnique = True
		elseif bestMatches == 3 && bestNameMatch && bestRaceMatch && secondBestMatches <= 1
			strongUnique = True
		endif
	endif

	if !strongUnique
		; Inconclusive: do not trust suspicious co-save GUID. Mint a new GUID to keep runtime non-blocking.
		Float nowRT = Utility.GetCurrentRealTime()
		if nowRT < _guidMintRetryAt
			return ""
		endif

		String newGuid = IronSoulNative.GenerateGuidUnique(pn)
		if newGuid == ""
			_guidMintRetryAt = nowRT + 10.0
			LogMsg(LOG_ERR(), "TryRestoreGuidTamperedCosave: suspicious co-save GUID '" + cosaveGuid + "' had no strong unique match and mint failed; backoff 10s before retry")
			return ""
		endif

		_guidMintRetryAt = 0.0
		StorageUtil.SetStringValue(player, characterGuid, newGuid)
		EnsureGuidMarker(newGuid)
		IronSoulNative.DataFlushIfDirty()

		LogMsg(LOG_ERR(), "TryRestoreGuidTamperedCosave: suspicious co-save GUID '" + cosaveGuid + "' had no strong unique match; minted new GUID '" + newGuid + "'")
		if !_guidTamperMintNotified
			_guidTamperMintNotified = True
			Debug.Notification("[Iron Soul] Character identity could not be safely verified. A new identity was created.")
		endif

		return newGuid
	endif

	; Restore authoritative GUID back to co-save directly (do NOT use Persist helpers).
	StorageUtil.SetStringValue(player, characterGuid, bestGuid)
	EnsureGuidMarker(bestGuid)

	; Flush ASAP so we don't bounce between GUIDs on crash / early exit.
	IronSoulNative.DataFlushIfDirty()

	LogMsg(LOG_INFO(), "TryRestoreGuidTamperedCosave: GUID tamper recovery: co-save '" + cosaveGuid + "' -> restored '" + bestGuid + "' (" + bestMatches + "/4, runnerUp=" + secondBestMatches + ")")

	return bestGuid
EndFunction


; ==================
; --- Soul Feats ---
; ==================
;
; Tier state: 0=CHIM, 1=Defiant, 2=Iron, 3=Silver, 4=Gold, 5=Ebon, 6=Platinum. Highest eligible tier always takes priority.
; This value is stored in MainData (authoritative) and backed up to co-save via an obfuscated key.
; Per-character unlocks based on confirmed Dragon Souls obtained or boss kills, and death count. Display one-time messages on unlock.
; Future: Soul Bonus tiers (Iron 5% / Silver 10% / Gold 15% / Ebon 20% / Platinum 30%) will be applied via a separate ability/effect system.
; Defiant activation is represented by tier 1.

Function TryScheduleFeats(Actor player)
    ; Schedules Feats evaluation when an unlock may be available.
    ; (Messages are shown by HandleFeats in a safe context; this function only arms the delayed check.)
    if !player
        return
    endif
    if _pendingFeats
        return
    endif

    String guid = GetTickGuid(player)
    if guid == ""
        return
    endif

    if Utility.IsInMenuMode() || player.IsDead() || player.IsBleedingOut()
        return
    endif

    Int deaths = PersistGetInt(player, GetKey(deathCount, guid), 0)
    Int soulsObtained = PersistGetInt(player, GetKey(dragonSoulsTotal, guid), 0)
    Int curTier = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)

    if curTier == TIER_CHIM || curTier == TIER_DEFIANT
        return
    endif

    Float nowRT = Utility.GetCurrentRealTime()

    ; Defiant Feat: 1 Dragon Soul obtained with under 10 deaths.
    if !_disableDefiantFeat
        Bool defiantEligible = (soulsObtained >= 1 && deaths < IRON_SOUL_MAX_LIVES)
        Int defFeat = PersistGetInt(player, GetKey(defiantFeatUnlocked, guid), 0)
        if defiantEligible && defFeat != 1
            _pendingFeats = True
            if _featsAt < (nowRT + 4.0)
                _featsAt = nowRT + 4.0
            endif
            return
        endif
    endif

    ; Soul Feats (prestige tiers; do not affect death lifecycle).
    ; Option A: grant only the highest eligible tier.
    if !_disableSoulFeats
        ; Under 10 deaths only.
        Int desiredTier = TIER_IRON
        if deaths < IRON_SOUL_MAX_LIVES
            ; Determine the highest eligible tier at this moment (tiers may upgrade upward over time; Silver -> Gold allowed).
            ; Evaluation priority: Platinum > Ebon > Gold > Silver.
            ; Platinum variant credit priority: Molag Bal (Vigilant) > Miraak (Dragonborn).
            Int molagFlag = PersistGetInt(player, GetKey(molagBalKilled, guid), 0)
            Int miraakFlag = PersistGetInt(player, GetKey(miraakKilled, guid), 0)
            Bool molagKilled = (molagFlag == 1)
            Bool miraakKilledBool = (miraakFlag == 1)
            if molagKilled || miraakKilledBool
                desiredTier = TIER_PLATINUM

            else
                Int alduinFlag = PersistGetInt(player, GetKey(alduinKilled, guid), 0)
                Int harkonFlag = PersistGetInt(player, GetKey(harkonKilled, guid), 0)
                Bool alduinKilledBool = (alduinFlag == 1)
                Bool harkonKilledBool = (harkonFlag == 1)
                if alduinKilledBool || harkonKilledBool
                    desiredTier = TIER_EBON

                elseif soulsObtained >= 20
                    desiredTier = TIER_GOLD

                elseif soulsObtained >= 10
                    desiredTier = TIER_SILVER
                endif
            endif
        endif

        if desiredTier > curTier
            _pendingFeats = True
            if _featsAt < (nowRT + 4.0)
                _featsAt = nowRT + 4.0
            endif
            return
        endif

        ; Also schedule one-time tier messages if a tier was previously earned but its message wasn't shown yet.
        if curTier == TIER_PLATINUM
            Int shownA = PersistGetInt(player, GetKey(tierMsgShownPlatinum, guid), 0)
            if shownA != 1
                _pendingFeats = True
                if _featsAt < (nowRT + 4.0)
                    _featsAt = nowRT + 4.0
                endif
                return
            endif

        elseif curTier == TIER_EBON
            Int shownP = PersistGetInt(player, GetKey(tierMsgShownEbon, guid), 0)
            if shownP != 1
                _pendingFeats = True
                if _featsAt < (nowRT + 4.0)
                    _featsAt = nowRT + 4.0
                endif
                return
            endif

        elseif curTier == TIER_GOLD
            Int shownG = PersistGetInt(player, GetKey(tierMsgShownGold, guid), 0)
            if shownG != 1
                _pendingFeats = True
                if _featsAt < (nowRT + 4.0)
                    _featsAt = nowRT + 4.0
                endif
                return
            endif

        elseif curTier == TIER_SILVER
            Int shownS = PersistGetInt(player, GetKey(tierMsgShownSilver, guid), 0)
            if shownS != 1
                _pendingFeats = True
                if _featsAt < (nowRT + 4.0)
                    _featsAt = nowRT + 4.0
                endif
                return
            endif
        endif
    endif
EndFunction

Function HandleFeats(Actor player)
    ; One-time Soul Feats messaging + tier state updates.
    if !_pendingFeats
        return
    endif

    Float nowRT = Utility.GetCurrentRealTime()
    if nowRT < _featsAt
        return
    endif

    ; If we can't safely show a message box right now, retry shortly.
    if Utility.IsInMenuMode() || !player || player.IsDead() || player.IsBleedingOut()
        _featsAt = nowRT + 1.0
        return
    endif

    String guid = GetTickGuid(player)
    if guid == ""
        ; GUID not ready yet (early-load edge case). Keep pending and retry shortly.
        _featsAt = nowRT + 1.0
        return
    endif

    _pendingFeats = False

    Int deaths = PersistGetInt(player, GetKey(deathCount, guid), 0)
    Int soulsObtained = PersistGetInt(player, GetKey(dragonSoulsTotal, guid), 0)
    Int curTier = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)

    if curTier == TIER_CHIM || curTier == TIER_DEFIANT
        return
    endif

    ; ---- Defiant Feat (eligibility only; activation occurs at the end of the 10th-death transition sequence) ----
    if !_disableDefiantFeat
        Bool defiantEligible = (soulsObtained >= 1 && deaths < IRON_SOUL_MAX_LIVES)
        Int defFeat = PersistGetInt(player, GetKey(defiantFeatUnlocked, guid), 0)
        if defiantEligible && defFeat != 1
            LogMsg(LOG_INFO(), "HandleFeats: Defiant Soul feat unlocked (eligibility met); showing unlock message")
            PersistSetInt(player, GetKey(defiantFeatUnlocked, guid), 1, True)
            IronSoulNative.DataFlushIfDirty()
            JournalLogEvent("Soul Feat Unlocked: Defiant Soul.")
            OpenTimedMessageSWF_KeyDismiss_SFX(ResolveDefiantFeatUnlockMenu(), 30.0, 8.0, SFXFeatDefiant, player)
            return
        endif
    endif

    ; ---- Soul Feats (prestige tiers; do not affect death lifecycle) ----
    ; Option A: grant only the highest eligible tier.
    if !_disableSoulFeats
        Int desiredTier = TIER_IRON
        if deaths < IRON_SOUL_MAX_LIVES
            ; Tier eligibility (highest wins): Platinum > Ebon > Gold > Silver.
            ; Platinum variant credit priority: Molag Bal (Vigilant) > Miraak (Dragonborn).
            Int molagFlag = PersistGetInt(player, GetKey(molagBalKilled, guid), 0)
            Int miraakFlag = PersistGetInt(player, GetKey(miraakKilled, guid), 0)
            Bool molagKilled = (molagFlag == 1)
            Bool miraakKilledBool = (miraakFlag == 1)
            if molagKilled || miraakKilledBool
                desiredTier = TIER_PLATINUM

            else
                Int alduinFlag = PersistGetInt(player, GetKey(alduinKilled, guid), 0)
                Int harkonFlag = PersistGetInt(player, GetKey(harkonKilled, guid), 0)
                Bool alduinKilledBool = (alduinFlag == 1)
                Bool harkonKilledBool = (harkonFlag == 1)
                if alduinKilledBool || harkonKilledBool
                    desiredTier = TIER_EBON

                elseif soulsObtained >= 20
                    desiredTier = TIER_GOLD

                elseif soulsObtained >= 10
                    desiredTier = TIER_SILVER
                endif
            endif
        endif

        if desiredTier > curTier
            PersistSetInt(player, GetKey(soulTierIndex, guid), desiredTier, True)
            SyncLuckNotifiedTierToCurrent(player, guid)
            IronSoulNative.DataFlushIfDirty()

		    ; Update splash/lvlWidget for next game launch.
            IronSoulNative.ApplyDynamicSplash(desiredTier)
            IronSoulNative.ApplyDynamicLevelWidget(desiredTier)

        if desiredTier == TIER_PLATINUM
            Int molagFlagJ = PersistGetInt(player, GetKey(molagBalKilled, guid), 0)
            Int miraakFlagJ = PersistGetInt(player, GetKey(miraakKilled, guid), 0)
            if molagFlagJ == 1
                JournalLogEvent("Molag Bal Defeated: Soul Feat Unlocked: Platinum Soul.")
            elseif miraakFlagJ == 1
                JournalLogEvent("Miraak Defeated: Soul Feat Unlocked: Platinum Soul.")
            else
                JournalLogEvent("Soul Feat Unlocked: Platinum Soul.")
            endif
        
        elseif desiredTier == TIER_EBON
            Int alduinFlagJ = PersistGetInt(player, GetKey(alduinKilled, guid), 0)
            Int harkonFlagJ = PersistGetInt(player, GetKey(harkonKilled, guid), 0)
            if alduinFlagJ == 1
                JournalLogEvent("Alduin Defeated: Soul Feat Unlocked: Ebon Soul.")
            elseif harkonFlagJ == 1
                JournalLogEvent("Harkon Defeated: Soul Feat Unlocked: Ebon Soul.")
            else
                JournalLogEvent("Soul Feat Unlocked: Ebon Soul.")
            endif
        
        elseif desiredTier == TIER_GOLD
            JournalLogEvent("Soul Feat Unlocked: Gilded Soul.")

        elseif desiredTier == TIER_SILVER
            JournalLogEvent("Soul Feat Unlocked: Silver Soul.")
        endif
            curTier = desiredTier
            ; SoulBonus sync only when tier changes
            SyncSoulBonusAbility(player, guid)
        endif

        ; One-time tier messages (separate from tier int so we never spam messages on load).
        if curTier == TIER_PLATINUM
            Int shownA = PersistGetInt(player, GetKey(tierMsgShownPlatinum, guid), 0)
            if shownA != 1
                LogMsg(LOG_INFO(), "HandleFeats: Showing Platinum Soul feat unlock message (one-shot); locking out lower-tier messages")
                ; Platinum locks out any lower-tier unlock messages that were never obtained.
                PersistSetInt(player, GetKey(tierMsgShownEbon, guid), 1, True)
                PersistSetInt(player, GetKey(tierMsgShownGold, guid), 1, True)
                PersistSetInt(player, GetKey(tierMsgShownSilver, guid), 1, True)

                PersistSetInt(player, GetKey(tierMsgShownPlatinum, guid), 1, True)

                ; Variant latch: 1=Molag Bal (Vigilant), 2=Miraak (Dragonborn). Molag Bal has priority.
                Int platVar = PersistGetInt(player, GetKey(platinumFeatVariant, guid), 0)
                if platVar == 0
                    Int molagFlagV = PersistGetInt(player, GetKey(molagBalKilled, guid), 0)
                    if molagFlagV == 1
                        platVar = 1
                    else
                        platVar = 2
                    endif
                    ; Mark dirty; flush is handled by the normal throttled flush in the update loop.
                    PersistSetInt(player, GetKey(platinumFeatVariant, guid), platVar, True)
                endif

                String menuP = "6platinumfeatunlockmiraak"
                if platVar == 1
                    menuP = "6platinumfeatunlockmolagbal"
                endif
                LogMsg(LOG_INFO(), "HandleFeats: Platinum variant=" + platVar + " menu=" + menuP)
                OpenTimedMessageSWF_KeyDismiss_SFX(SwfNoBonus(menuP), 30.0, 8.0, SFXFeatPlatinum, player)
                MaybePlayLuckImprovedAfterTierUnlock(player)
                return
            endif

        elseif curTier == TIER_EBON
            Int shownP = PersistGetInt(player, GetKey(tierMsgShownEbon, guid), 0)
            if shownP != 1
                LogMsg(LOG_INFO(), "HandleFeats: Showing Ebon Soul feat unlock message (one-shot); locking out Silver/Gold messages")
                ; Ebon locks out Silver/Gold unlock messages that were never obtained.
                PersistSetInt(player, GetKey(tierMsgShownGold, guid), 1, True)
                PersistSetInt(player, GetKey(tierMsgShownSilver, guid), 1, True)

                PersistSetInt(player, GetKey(tierMsgShownEbon, guid), 1, True)

                ; Variant latch: 1=Alduin, 2=Harkon. Alduin has priority when both are already true.
                Int ebonVar = PersistGetInt(player, GetKey(ebonFeatVariant, guid), 0)
                if ebonVar == 0
                    Int alduinFlagV = PersistGetInt(player, GetKey(alduinKilled, guid), 0)
                    if alduinFlagV == 1
                        ebonVar = 1
                    else
                        ebonVar = 2
                    endif
                    ; Mark dirty; flush is handled by the normal throttled flush in the update loop.
                    PersistSetInt(player, GetKey(ebonFeatVariant, guid), ebonVar, True)
                endif

                String menuE = "5ebonfeatunlockharkon"
                if ebonVar == 1
                    menuE = "5ebonfeatunlockalduin"
                endif
                LogMsg(LOG_INFO(), "HandleFeats: Ebon variant=" + ebonVar + " menu=" + menuE)
                OpenTimedMessageSWF_KeyDismiss_SFX(SwfNoBonus(menuE), 30.0, 8.0, SFXFeatEbon, player)
                MaybePlayLuckImprovedAfterTierUnlock(player)
                return
            endif

        elseif curTier == TIER_GOLD
            Int shownG = PersistGetInt(player, GetKey(tierMsgShownGold, guid), 0)
            if shownG != 1
                LogMsg(LOG_INFO(), "HandleFeats: Showing Gold Soul feat unlock message (one-shot)")
                PersistSetInt(player, GetKey(tierMsgShownGold, guid), 1, True)
                OpenTimedMessageSWF_KeyDismiss_SFX(SwfNoBonus("4goldfeatunlock"), 30.0, 8.0, SFXFeatGold, player)
                MaybePlayLuckImprovedAfterTierUnlock(player)
                return
            endif

        elseif curTier == TIER_SILVER
            Int shownS = PersistGetInt(player, GetKey(tierMsgShownSilver, guid), 0)
            if shownS != 1
                LogMsg(LOG_INFO(), "HandleFeats: Showing Silver Soul feat unlock message (one-shot)")
                PersistSetInt(player, GetKey(tierMsgShownSilver, guid), 1, True)
                OpenTimedMessageSWF_KeyDismiss_SFX(SwfNoBonus("3silverfeatunlock"), 30.0, 8.0, SFXFeatSilver, player)
                MaybePlayLuckImprovedAfterTierUnlock(player)
                return
            endif
        endif
    endif
EndFunction

Function MaybePlayLuckImprovedAfterTierUnlock(Actor player)
    ; Show luckimproved.swf only when feats + respawn + luck systems are active.
    if !player
        return
    endif
    if _disableSoulFeats
        return
    endif
    if !IsRespawnEnabled()
        return
    endif
    if !IsLuckActive()
        return
    endif

    ; Timing: after unlock menu closes -> wait 1s -> show for 3s.
    Utility.Wait(1.0)
    UI.CloseCustomMenu()
    UI.OpenCustomMenu("luckimproved", 0)
    PlaySFX(SFXLuckSuccess, player)
    Utility.WaitMenuMode(3.0)
    UI.CloseCustomMenu()
EndFunction

String Function TierMenuPrefix(Int soulTier)
    ; Tier state: 0=CHIM, 1=Defiant, 2=Iron, 3=Silver, 4=Gold, 5=Ebon, 6=Platinum
    if soulTier == TIER_CHIM
        return "0chim"

    elseif soulTier == TIER_DEFIANT
        return "1defiant"

    elseif soulTier == TIER_IRON
        return "2iron"

    elseif soulTier == TIER_SILVER
        return "3silver"

    elseif soulTier == TIER_GOLD
        return "4gold"

    elseif soulTier == TIER_EBON
        return "5ebon"

    elseif soulTier >= TIER_PLATINUM
        return "6platinum"
    endif
    ; Fallback
    return "2iron"
EndFunction

; Miraak defeated latch (Dragonborn DLC): used for the Platinum Soul feat unlock path.
; We treat stage 580 (death scene) OR stage 600 (left Apocrypha cleanup) as "Miraak defeated".
Bool Function IsMiraakDefeated(Actor player, String guid)
    ; Per-character, latched once true. Eligibility thresholds are applied by the caller.
    Int flag = PersistGetInt(player, GetKey(miraakKilled, guid), 0)
    if flag == 1
        return True
    endif

    if DLC2MQ06
        ; Stages 580/600 (and quest completion) are used as the authoritative "Miraak defeated" signals. Stages 580/600 occur later in the sequence.
        if DLC2MQ06.GetStageDone(580) || DLC2MQ06.GetStageDone(600) || DLC2MQ06.IsCompleted()
            LogMsg(LOG_INFO(), "miraakKilled: latched TRUE (one-shot)")
            PersistSetInt(player, GetKey(miraakKilled, guid), 1, True)
            ; If Miraak was just latched as defeated, schedule feats evaluation immediately.
            TryScheduleFeats(player)
            return True
        endif
    endif

    return False
EndFunction

; Alduin defeated latch (Main Quest): MQ305 stage 190 is set immediately when Alduin dies.
Bool Function IsAlduinDefeated(Actor player, String guid)
    ; Per-character, latched once true.
    Int flag = PersistGetInt(player, GetKey(alduinKilled, guid), 0)
    if flag == 1
        return True
    endif

    if MQ305
        ; MQ305 stage 190 is the "Alduin is dead" signal (fires immediately on death).
        if MQ305.GetStage() >= 190
            LogMsg(LOG_INFO(), "alduinKilled: latched TRUE (one-shot)")
            PersistSetInt(player, GetKey(alduinKilled, guid), 1, True)
            TryScheduleFeats(player)
            return True
        endif
    endif

    return False
EndFunction

Bool Function IsHarkonDefeated(Actor player, String guid)
    ; Per-character, latched once true.
    Int flag = PersistGetInt(player, GetKey(harkonKilled, guid), 0)
    if flag == 1
        return True
    endif

    if DLC1VQ08
        ; Stage 200 is the first authoritative quest-level "Harkon defeated" signal.
        if DLC1VQ08.GetStage() >= 200
            LogMsg(LOG_INFO(), "harkonKilled: latched TRUE (one-shot)")
            PersistSetInt(player, GetKey(harkonKilled, guid), 1, True)
            TryScheduleFeats(player)
            return True
        endif
    endif

    return False
EndFunction

; Vigilant (mod) Molag Bal defeated latch: Quest zzzAoMMq08 (FormID 0000EA8A in Vigilant.esm), stage 310.
Quest _vigilantMq08Cache = None
Bool _vigilantMq08Tried = False

Bool Function IsMolagBalDefeatedVigilant(Actor player, String guid)
    ; Safe when Vigilant isn't installed: GetFormFromFile returns None.
    Int flag = PersistGetInt(player, GetKey(molagBalKilled, guid), 0)
    if flag == 1
        return True
    endif

    if !_vigilantMq08Tried
        _vigilantMq08Tried = True
        _vigilantMq08Cache = Game.GetFormFromFile(0x0000EA8A, "Vigilant.esm") as Quest
    endif

    if _vigilantMq08Cache
        if _vigilantMq08Cache.GetStage() >= 310
            LogMsg(LOG_INFO(), "molagBalKilled: latched TRUE (one-shot)")
            PersistSetInt(player, GetKey(molagBalKilled, guid), 1, True)
            TryScheduleFeats(player)
            return True
        endif
    endif

    return False
EndFunction


; ==================
; --- Soul Bonus ---
; ==================

Spell Function GetSoulBonusSpellByTier(Int tier)
    if tier == TIER_CHIM
        return None
    elseif tier == TIER_DEFIANT
        if SoulBonus0Defiant
            return SoulBonus0Defiant
        endif
        return SoulBonus1Iron
    elseif tier == TIER_IRON
        return SoulBonus1Iron
    elseif tier == TIER_SILVER
        return SoulBonus2Silver
    elseif tier == TIER_GOLD
        return SoulBonus3Gold
    elseif tier == TIER_EBON
        return SoulBonus4Ebon
    elseif tier >= TIER_PLATINUM
        return SoulBonus5Platinum
    endif
    return None
EndFunction

Function RemoveSoulBonusAll(Actor player)
    if !player
        return
    endif
    if SoulBonus0Defiant && player.HasSpell(SoulBonus0Defiant)
        player.RemoveSpell(SoulBonus0Defiant)
    endif
    if SoulBonus1Iron && player.HasSpell(SoulBonus1Iron)
        player.RemoveSpell(SoulBonus1Iron)
    endif
    if SoulBonus2Silver && player.HasSpell(SoulBonus2Silver)
        player.RemoveSpell(SoulBonus2Silver)
    endif
    if SoulBonus3Gold && player.HasSpell(SoulBonus3Gold)
        player.RemoveSpell(SoulBonus3Gold)
    endif
    if SoulBonus4Ebon && player.HasSpell(SoulBonus4Ebon)
        player.RemoveSpell(SoulBonus4Ebon)
    endif
    if SoulBonus5Platinum && player.HasSpell(SoulBonus5Platinum)
        player.RemoveSpell(SoulBonus5Platinum)
    endif
EndFunction

Function SyncSoulBonusAbility(Actor player, String guid)
    ; Keep the SoulBonus tier Ability spell in sync with the character's current Soul Tier.
    ; Tier mapping: 0=CHIM, 1=Defiant, 2=Iron, 3=Silver, 4=Gold, 5=Ebon, 6=Platinum.

    if !player
        return
    endif

    ; Uninstall/disabled always strips SoulBonus immediately.
    if _uninstallMode || _modDisabled
        RemoveSoulBonusAll(player)
        _soulBonusAppliedTier = -1
        return
    endif

    ; If GUID is not ready yet, do nothing.
    if guid == ""
        return
    endif

    Int tier = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)

    if tier == TIER_CHIM
        RemoveSoulBonusAll(player)
        _soulBonusAppliedTier = -1
        return
    endif

    Bool defiantSB = (tier == TIER_DEFIANT)

    ; Defiant (tier 1) is gated by DisableSoulFatigue.
    if defiantSB && _disableSoulFatigue
        RemoveSoulBonusAll(player)
        _soulBonusAppliedTier = -1
        return
    endif

    ; Non-Defiant tiers are gated by DisableSoulBonus.
    if !defiantSB && _disableSoulBonus
        RemoveSoulBonusAll(player)
        _soulBonusAppliedTier = -1
        return
    endif

    LogMsg(LOG_DBG(), "SyncSoulBonusAbility: BEFORE | HP=" + player.GetAV("Health") \
        + " Mag=" + player.GetAV("Magicka") \
        + " Stam=" + player.GetAV("Stamina"))

    Spell desired = GetSoulBonusSpellByTier(tier)

    ; Build a small label for logging.
    String tierLabel = "Iron"
    if tier == TIER_CHIM
        tierLabel = "CHIM"
    elseif tier == TIER_DEFIANT
        tierLabel = "Defiant"
    elseif tier == TIER_SILVER
        tierLabel = "Silver"
    elseif tier == TIER_GOLD
        tierLabel = "Gold"
    elseif tier == TIER_EBON
        tierLabel = "Ebon"
    elseif tier == TIER_PLATINUM
        tierLabel = "Platinum"
    endif

    ; Intentional: debug-only pause to let AV changes settle before logging snapshots.
    if _logEnabled && _logLevel >= LOG_DBG()
        Utility.Wait(0.2) 
    endif

    ; Fast path: same tier as last time. If the spell was removed externally, reapply.
    if tier == _soulBonusAppliedTier
        if desired && !player.HasSpell(desired)
            player.AddSpell(desired, False)
            LogMsg(LOG_INFO(), "SyncSoulBonusAbility: SoulBonus re-applied (" + tierLabel + ", tier=" + tier + ")")
        endif
        return
    endif

    ; Tier changed: remove old and apply new.
    RemoveSoulBonusAll(player)
    if desired
        player.AddSpell(desired, False)
        LogMsg(LOG_INFO(), "SyncSoulBonusAbility: SoulBonus applied (" + tierLabel + ", tier=" + tier + ")")
    endif
    _soulBonusAppliedTier = tier

    ; Intentional: debug-only pause to let AV changes settle before logging snapshots.
    if _logEnabled && _logLevel >= LOG_DBG()
        Utility.Wait(0.2) 
    endif

    LogMsg(LOG_DBG(), "SyncSoulBonusAbility: AFTER  | HP=" + player.GetAV("Health") \
        + " Mag=" + player.GetAV("Magicka") \
        + " Stam=" + player.GetAV("Stamina"))
    
EndFunction


; ======================
; --- UI & Messaging ---
; ======================

Function OpenTimedMessageSWF(String menuName, Float duration = 6.0, Bool restoreMusic = True)
    if menuName == ""
        return
    endif

    ; Clamp duration so we never "hang" or no-op.
    if duration <= 0.0
        duration = 0.1
    endif

    if AudioCategoryMUS && !_disableMusicFade
        Float menuMusicVol = Utility.GetINIFloat("fVal3:AudioMenu")
        if menuMusicVol < 0.0 || menuMusicVol > 1.0
            menuMusicVol = 1.0
        endif
        IronSoulNative.MusicFadeOut(AudioCategoryMUS, 2.0, menuMusicVol)
    endif

    ; Aggressive policy: interrupt any existing custom menu to guarantee our timed message shows and closes deterministically.
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(menuName, 0)
    Utility.WaitMenuMode(duration)
    UI.CloseCustomMenu()
    if restoreMusic && AudioCategoryMUS && !_disableMusicFade
        IronSoulNative.MusicFadeIn(AudioCategoryMUS, 2.0)
    endif
EndFunction

Function OpenTimedMessageSWF_SFX(String swfName, Float seconds, Sound sfx, Actor player, Bool restoreMusic = True)
    PlaySFX(sfx, player)
    OpenTimedMessageSWF(swfName, seconds, restoreMusic)
EndFunction

; Opens a CustomMenu and keeps it up until:
;  - at least minDismissSeconds have elapsed, AND
;  - the player presses any key, OR maxDuration elapses.
Function OpenTimedMessageSWF_KeyDismiss(String menuName, Float maxDuration = 6.0, Float minDismissSeconds = 6.0, Bool restoreMusic = True)
    if menuName == ""
        return
    endif

    ; Clamp so we never hang or no-op.
    if maxDuration <= 0.0
        maxDuration = 0.1
    endif
    if minDismissSeconds < 0.0
        minDismissSeconds = 0.0
    endif
    if minDismissSeconds > maxDuration
        minDismissSeconds = maxDuration
    endif

    if AudioCategoryMUS && !_disableMusicFade
        Float menuMusicVol2 = Utility.GetINIFloat("fVal3:AudioMenu")
        if menuMusicVol2 < 0.0 || menuMusicVol2 > 1.0
            menuMusicVol2 = 1.0
        endif
        IronSoulNative.MusicFadeOut(AudioCategoryMUS, 2.0, menuMusicVol2)
    endif

    UI.CloseCustomMenu()

    _keyDismissPressed = False
    _keyDismissActive  = False

    UI.OpenCustomMenu(menuName, 0)

    ; Minimum on-screen time.
    if minDismissSeconds > 0.0
        Utility.WaitMenuMode(minDismissSeconds)
    endif

    ; Arm dismissal-on-key for the remainder window.
    Float remaining = maxDuration - minDismissSeconds
    if remaining > 0.0
        _keyDismissPressed = False
        _keyDismissActive  = True
        RegisterForAllKeys()

        ; Poll in short chunks so we can react quickly to keypress.
        while remaining > 0.0 && !_keyDismissPressed
            Utility.WaitMenuMode(0.10)
            remaining -= 0.10
        endwhile

        _keyDismissActive = False
        UnregisterForAllKeys()
    endif

    UI.CloseCustomMenu()

    if restoreMusic && AudioCategoryMUS && !_disableMusicFade
        IronSoulNative.MusicFadeIn(AudioCategoryMUS, 2.0)
    endif

EndFunction

Function OpenTimedMessageSWF_KeyDismiss_SFX(String swfName, Float maxSeconds, Float minDismissSeconds, Sound sfx, Actor player, Bool restoreMusic = True)
    PlaySFX(sfx, player)
    OpenTimedMessageSWF_KeyDismiss(swfName, maxSeconds, minDismissSeconds, restoreMusic)
EndFunction

; Special Variant for Iron Intro: Does not fade music back in.
Function OpenTimedMessageSWF_KeyDismissIronIntro(String menuName, Float maxDuration = 6.0, Float minDismissSeconds = 6.0, Sound sfx = None, Actor player = None)
    if menuName == ""
        return
    endif

    ; Optional SFX first (matches previous wrapper behavior)
    if sfx != None && player != None
        PlaySFX(sfx, player)
    endif

    ; Clamp so we never hang or no-op.
    if maxDuration <= 0.0
        maxDuration = 0.1
    endif
    if minDismissSeconds < 0.0
        minDismissSeconds = 0.0
    endif
    if minDismissSeconds > maxDuration
        minDismissSeconds = maxDuration
    endif

    if AudioCategoryMUS && !_disableMusicFade
        Float menuMusicVol2 = Utility.GetINIFloat("fVal3:AudioMenu")
        if menuMusicVol2 < 0.0 || menuMusicVol2 > 1.0
            menuMusicVol2 = 1.0
        endif
        IronSoulNative.MusicFadeOut(AudioCategoryMUS, 2.0, menuMusicVol2)
    endif

    UI.CloseCustomMenu()

    _keyDismissPressed = False
    _keyDismissActive  = False

    UI.OpenCustomMenu(menuName, 0)

    ; Minimum on-screen time.
    if minDismissSeconds > 0.0
        Utility.WaitMenuMode(minDismissSeconds)
    endif

    ; Arm dismissal-on-key for the remainder window.
    Float remaining = maxDuration - minDismissSeconds
    if remaining > 0.0
        _keyDismissPressed = False
        _keyDismissActive  = True
        RegisterForAllKeys()

        ; Poll in short chunks so we can react quickly to keypress.
        while remaining > 0.0 && !_keyDismissPressed
            Utility.WaitMenuMode(0.10)
            remaining -= 0.10
        endwhile

        _keyDismissActive = False
        UnregisterForAllKeys()
    endif

    UI.CloseCustomMenu()
EndFunction

Bool Function ShowIronIntro(Actor player, String guid)

    if !player || guid == ""
        return False
    endif

    if _disableIronSoulIntro
        return False
    endif

    Int shown = PersistGetInt(player, GetKey(ironIntroShown, guid), 0)
    if shown == 1
        return False
    endif

    OpenTimedMessageSWF_KeyDismissIronIntro(SwfNoBonus("2ironintro"), 30.0, 14.5, SFXIronIntro, player)
    PersistSetInt(player, GetKey(ironIntroShown, guid), 1, True)
    Utility.Wait(1.0)
    return True

EndFunction

; If Soul Bonus is disabled, use the "nobonus" SWF variants for specific menus.
String Function SwfNoBonus(String menuName)
    if menuName == ""
        return ""
    endif
    if StringUtil.Find(menuName, "dragonsoulrevive") != -1
        return menuName
    endif
    if _disableSoulBonus
        return menuName + "nobonus"
    endif
    return menuName
EndFunction

Function HandleLoadNotification(Actor player)
	; Job A: timed load-game job (runs every load).
	if !_pendingLoadMessage
		return
	endif

	if Utility.GetCurrentRealTime() < _loadMessageAt
		return
	endif

	if !player
		return
	endif

    String guid = GetTickGuid(player)
    if guid == ""
        ; GUID can be briefly unavailable right after load; keep the job armed and retry shortly.
        _loadMessageAt = Utility.GetCurrentRealTime() + 1.0
        return
    endif

    _pendingLoadMessage = False

	Int deaths     = PersistGetInt(player, GetKey(deathCount, guid), 0)
	Int soulTier   = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)
	Int daysPassed = Utility.GetCurrentGameTime() as Int
	Bool defiant = (soulTier == TIER_DEFIANT && deaths >= IRON_SOUL_MAX_LIVES && deaths < DEFIANT_SOUL_MAX_LIVES)
    Bool chimTier = (soulTier == TIER_CHIM)

	; LoadNotificationMode:
	;  0 = default (stats + flavor)
	;  1 = no flavor (stats only)
	;  2 = only flavor
	;  3 = disabled
	if _loadNotificationMode == 3
		return
	endif
	Bool showStats  = (_loadNotificationMode == 0 || _loadNotificationMode == 1)
	Bool showFlavor = (_loadNotificationMode == 0 || _loadNotificationMode == 2)

	Bool luckActive = IsLuckActive()
	Int luckVal = 100
    Int luckMax = 100
	if luckActive
        luckMax = GetCurrentMaxLuck(player, guid)
		luckVal = GetLuckValue(player, guid)
	endif

	if showStats
		if luckActive
			Debug.Notification("Deaths: " + deaths + " | Luck: " + luckVal + " | Days Passed: " + daysPassed)
		else
			Debug.Notification("Deaths: " + deaths + " | Days Passed: " + daysPassed)
		endif
	endif

	if !showFlavor
		return
	endif

	; If Luck is active and not full, replace the 2nd load notification with Luck flavor.
	; Luck at tier max uses the normal tier-dependent load notification.
	if luckActive && luckVal < luckMax
		Debug.Notification(PickLuckLoadFlavor(luckVal, luckMax))
		return
	endif

	; Priority: CHIM > Defiant > Soul Feat (death-band flavor)
	if chimTier
		; CHIM tier uses the CHIM/Godhead flavor pool.
		Int idx = Utility.RandomInt(0, 9)
		String line = PickCHIMCHIMLine(idx)
		if line != ""
			Debug.Notification(line)
		endif

	elseif defiant
		; After 75 deaths in Defiant mode, show a "rest" warning instead of the usual line.
		if deaths >= 75
			Debug.Notification("Your soul yearns for rest.")
		else
			Debug.Notification("Your Defiant Soul endures.")
		endif

	else
		; Death-band flavor (under 10 deaths):
		; 0: peerless
		; 1-3: prevails
		; 4-6: rises stronger
		; 7-9: endures

		if deaths <= 0
			if soulTier == TIER_PLATINUM
				Debug.Notification("Your Platinum Soul knows no equal")
			elseif soulTier == TIER_EBON
				Debug.Notification("Your Ebon Soul defies fate.")
			elseif soulTier == TIER_GOLD
				Debug.Notification("Your Gilded Soul is peerless.")
			elseif soulTier == TIER_SILVER
				Debug.Notification("Your Silver Soul is peerless.")
			else
				Debug.Notification("Your Iron Soul is peerless.")
			endif

		elseif deaths <= 3
			if soulTier == TIER_PLATINUM
				Debug.Notification("Your Platinum Soul prevails.")
			elseif soulTier == TIER_EBON
				Debug.Notification("Your Ebon Soul prevails.")
			elseif soulTier == TIER_GOLD
				Debug.Notification("Your Gilded Soul prevails.")
			elseif soulTier == TIER_SILVER
				Debug.Notification("Your Silver Soul prevails.")
			else
				Debug.Notification("Your Iron Soul prevails.")
			endif

		elseif deaths <= 6
			if soulTier == TIER_PLATINUM
				Debug.Notification("Your Platinum Soul rises stronger.")
			elseif soulTier == TIER_EBON
				Debug.Notification("Your Ebon Soul rises stronger.")
			elseif soulTier == TIER_GOLD
				Debug.Notification("Your Gilded Soul rises stronger.")
			elseif soulTier == TIER_SILVER
				Debug.Notification("Your Silver Soul rises stronger.")
			else
				Debug.Notification("Your Iron Soul rises stronger.")
			endif

		else
			if soulTier == TIER_PLATINUM
				Debug.Notification("Your Platinum Soul endures.")
			elseif soulTier == TIER_EBON
				Debug.Notification("Your Ebon Soul endures.")
			elseif soulTier == TIER_GOLD
				Debug.Notification("Your Gilded Soul endures.")
			elseif soulTier == TIER_SILVER
				Debug.Notification("Your Silver Soul endures.")
			else
				Debug.Notification("Your Iron Soul endures.")
			endif
		endif
	endif
EndFunction

String Function PickCHIMCHIMLine(Int idx)
    ; Keep lines ASCII-only for maximum compiler/font compatibility.
    if idx == 0
        return "The Godhead dreams on."

    elseif idx == 1
        return "You remain within the Dream."

    elseif idx == 2
        return "The Dream does not end here."

    elseif idx == 3
        return "Knowing the Dream, you persist."

    elseif idx == 4
        return "You refuse to wake."

    elseif idx == 5
        return "The cycle continues by your will."

    elseif idx == 6
        return "You perceive the Dream and remain."

    elseif idx == 7
        return "Existence endures within the Dream."

    elseif idx == 8
        return "The Dreamer stirs."

    else
        return "You do not zero-sum."
    endif
EndFunction

Function HandleRespawnMenu(Actor player)
    ; Job W: delayed free-respawn warning (after respawn completes)
    if !IsRespawnEnabled()
        _pendingRespawnMenu = False
        _respawnMenuArmed = False
        return
    endif

    if !_pendingRespawnMenu || !_respawnMenuArmed
        return
    endif

    if Utility.GetCurrentRealTime() < _respawnWarningAt
        return
    endif

    ; If we're in menu mode, defer showing the message (do NOT consume yet).
    if Utility.IsInMenuMode()
        return
    endif

    ; Now safe to consume the job (it won't get stuck in menus).
    _pendingRespawnMenu = False
    _respawnMenuArmed = False

    if player && !player.IsDead() && !_disableRespawnMessage
        String guid = GetTickGuid(player)
        if guid != ""
            Int soulTier = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)
            OpenTimedMessageSWF_SFX(ResolveRespawnMenu(soulTier), 6.0, SFXRespawn, player)
        endif
    endif
EndFunction

String Function ResolveDeathMessageMenu(Int soulTier, Int deathsNow)
    if soulTier == TIER_CHIM
        return "0chimdeath"
    endif
    if soulTier == TIER_DEFIANT
        return "1defiantdeath" + deathsNow
    endif
    return TierMenuPrefix(soulTier) + "death" + deathsNow
EndFunction

String Function ResolvePermadeathMenu(Int soulTier)
    if soulTier == TIER_CHIM
        return "0chimdeath"
    endif
    if soulTier == TIER_DEFIANT
        return "1defiantpermadeath"
    endif
    return TierMenuPrefix(soulTier) + "permadeath"
EndFunction

String Function ResolveDSRMenu(Actor player, String guid)
    if !player
        return ""
    endif

    if guid == ""
        return "2irondragonsoulrevive"
    endif

    ; Message globally disabled
    if _disableDragonSoulReviveMessage
        return ""
    endif

    ; Read persisted state
    Int soulTier = PersistGetInt(player, GetKey(soulTierIndex, guid), TIER_IRON)

    if soulTier == TIER_CHIM
        return "0chimdragonsoulrevive"
    endif

    String baseMenu = TierMenuPrefix(soulTier) + "dragonsoulrevive"

    if _dragonSoulReviveLimit <= 1
        return baseMenu
    endif

    ; HandleDragonSoulRevive records the current use before opening the menu.
    Int playedNow = PersistGetInt(player, GetKey(dsrLimitPlayedSec, guid), 0)
    Int recentUses = CompactDSRLimitUses(player, guid, playedNow)
    if recentUses >= _dragonSoulReviveLimit
        return TierMenuPrefix(soulTier) + "dragonsoulrevivelimit"
    endif

    return baseMenu
EndFunction

String Function ResolveRespawnMenu(Int soulTier)
    if soulTier == TIER_CHIM
        return "0chimrespawn"
    endif
    if soulTier == TIER_DEFIANT
        return "1defiantrespawn"
    endif
    return TierMenuPrefix(soulTier) + "respawn"
EndFunction

String Function PickLuckLoadFlavor(Int luck, Int maxLuck)
    ; Returns a flavor line for the 2nd load notification based on Luck% of tier max.
    Int r = Utility.RandomInt(0, 4)
    Int tier = LuckTier(luck, maxLuck)
    Int lowThreshold = PercentThresholdCeil(maxLuck, 10)

    if tier >= 3
        ; 75%-max (High)
        if r == 0
            return "Your confidence holds."
        elseif r == 1
            return "Your resolve carries you forward."
        elseif r == 2
            return "Your steps feel true."
        elseif r == 3
            return "The path ahead is clear."
        endif
        return "You move with purpose."

    elseif tier == 2
        ; 50%-74% (Stable)
        if r == 0
            return "You feel steady again."
        elseif r == 1
            return "Your thoughts are clear."
        elseif r == 2
            return "You feel grounded."
        elseif r == 3
            return "Your footing is firm."
        endif
        return "You feel balanced once more."

    elseif tier == 1
        ; 25%-49% (Medium)
        if r == 0
            return "You remain unsettled."
        elseif r == 1
            return "Unease lingers."
        elseif r == 2
            return "Caution tempers your steps."
        elseif r == 3
            return "You feel on edge."
        endif
        return "Doubt has not fully left you."

    elseif luck >= lowThreshold
        ; 10%-24% (Low)
        if r == 0
            return "You are still shaken from your recent trial."
        elseif r == 1
            return "Your recent ordeal still weighs heavily on you."
        elseif r == 2
            return "Your breath has steadied, but not your thoughts."
        elseif r == 3
            return "You have not yet recovered from what nearly ended you."
        endif
        return "Your nerves have not fully settled."
    endif

    ; Default: 0-9% (Very Low)
    if r == 0
        return "The premonition of your death grips your soul."
    elseif r == 1
        return "You return shaken from a waking nightmare."
    elseif r == 2
        return "You see the fatal moment just before the blow lands."
    elseif r == 3
        return "The vision lingers, warning of what could be."
    endif
    return "You stand with foreknowledge you never wanted."

EndFunction

Function MaybeNotifyLuckThreshold(Actor player, String guid, Int luck, Int maxLuck = -1)
    ; Do not notify during load stabilization
    if _suppressLuckNotify
        return
    endif

    ; Fires a one-time notification when luck reaches a new threshold:
    ; 25%, 50%, 75%, 100% of current tier max luck.
    if !player || guid == ""
        return
    endif
    ; Intentional: cooldown mode shares this notification path to surface respawn-readiness progress.
    if !IsLuckActive() && !IsCooldownModeActive()
        return
    endif
    if _disableLuckCooldownReminderNotification
        return
    endif

    if maxLuck <= 0
        maxLuck = GetCurrentMaxLuck(player, guid)
    endif
    Int tierNow = LuckTier(luck, maxLuck)
    if tierNow <= 0
        return
    endif

    Int tierPrev = PersistGetInt(player, GetKey(luckNotifiedTier, guid), 0)
    if tierNow <= tierPrev
        return
    endif

    PersistSetInt(player, GetKey(luckNotifiedTier, guid), tierNow, True)

    LogMsg(LOG_INFO(), "MaybeNotifyLuckThreshold: Luck threshold reached: tier " + tierPrev + " -> " + tierNow + " (luck=" + luck + "/" + maxLuck + ")")

    String msg = "You're feeling lucky."
    if tierNow == 1
        msg = "Your luck is returning."
    elseif tierNow == 2
        msg = "Your luck has improved."
    elseif tierNow == 3
        msg = "The odds favor you."
    endif
    Debug.Notification(msg)
EndFunction

; Defiant Soul unlock menu has 4 variants depending on Soul Feats and Soul Bonus settings.
; 1defiantfeatunlock                 : feats and soulbonus enabled
; 1defiantfeatunlocknobonusnofeats   : feats and soulbonus disabled
; 1defiantfeatunlocknofeats          : feats disabled
; 1defiantfeatunlocknobonus          : soulbonus disabled
String Function ResolveDefiantFeatUnlockMenu()
    String base = "1defiantfeatunlock"
    if _disableSoulFeats
        if _disableSoulBonus
            return base + "nobonusnofeats"
        endif
        return base + "nofeats"
    endif
    if _disableSoulBonus
        return base + "nobonus"
    endif
    return base
EndFunction

String Function ResolveDefiantIntroMenu()
    ; 4 Defiant intro variants:
    ; - 1defiantintro
    ; - 1defiantintronofatigue
    ; - 1defiantintronobonus
    ; - 1defiantintronobonusnofatigue
    if _disableSoulBonus
        if _disableSoulFatigue
            return "1defiantintronobonusnofatigue"
        endif
        return "1defiantintronobonus"
    endif
    if _disableSoulFatigue
        return "1defiantintronofatigue"
    endif
    return "1defiantintro"
EndFunction

String Function ResolveDefiantTransitionMenu(Int curTier)
    ; Contextual 10th-death Defiant transition message, based on highest unlocked Soul Feat.
    ; Tier state: 0=CHIM, 1=Defiant, 2=Iron, 3=Silver, 4=Gold, 5=Ebon, 6=Platinum.
    if curTier >= TIER_PLATINUM
        return "1defiantdeath10platinum"

    elseif curTier == TIER_EBON
        return "1defiantdeath10ebon"

    elseif curTier == TIER_GOLD
        return "1defiantdeath10gold"

    elseif curTier == TIER_SILVER
        return "1defiantdeath10silver"
    endif

    ; Fallback: Iron tier.
    return "1defiantdeath10iron"
EndFunction

String Function ResolveCHIMTransitionMenu(Int curTier)
    ; Contextual CHIM transition panel based on the pre-transition tier.
    if curTier == TIER_DEFIANT
        return "0chimdeathdefiant"

    elseif curTier == TIER_IRON
        return "0chimdeathiron"

    elseif curTier == TIER_SILVER
        return "0chimdeathsilver"

    elseif curTier == TIER_GOLD
        return "0chimdeathgold"

    elseif curTier == TIER_EBON
        return "0chimdeathebon"

    elseif curTier >= TIER_PLATINUM
        return "0chimdeathplatinum"
    endif

    return "0chimdeath"
EndFunction

Function PromoteToCHIMTier(Actor player, String guid)
    if !player || guid == ""
        return
    endif

    PersistSetInt(player, GetKey(soulTierIndex, guid), TIER_CHIM, True)
    SyncLuckNotifiedTierToCurrent(player, guid)

    ; Update splash/lvlWidget for next game launch.
    IronSoulNative.ApplyDynamicSplash(TIER_CHIM)
    IronSoulNative.ApplyDynamicLevelWidget(TIER_CHIM)

    Int chimLogged = PersistGetInt(player, GetKey(journalCHIMLogged, guid), 0)
    if chimLogged != 1
        if !_disableCharacterJournalLog
            JournalLogEvent("CHIM realized: Death is merely an illusion, a cycle to be broken. God Soul awakened.")
        endif
        PersistSetInt(player, GetKey(journalCHIMLogged, guid), 1, True)
    endif

    IronSoulNative.DataFlushIfDirty()
EndFunction

Bool Function ShouldTriggerCHIMTransitionOnLoad(Actor player, String guid, Int deathsNow, Int soulTier)
    if !player || guid == ""
        return False
    endif
    if _CHIM != 1
        return False
    endif
    if soulTier == TIER_CHIM
        return False
    endif

    ; Intentional: when DisableDefiantFeat=1, skip Defiant-cap CHIM gating and use Iron-cap CHIM logic below.
    if !_disableDefiantFeat && soulTier == TIER_DEFIANT
        return (deathsNow >= DEFIANT_SOUL_MAX_LIVES)
    endif

    ; Defiant takes priority at the Iron cap when unlocked.
    if !_disableDefiantFeat
        Int defFeat = PersistGetInt(player, GetKey(defiantFeatUnlocked, guid), 0)
        if defFeat == 1 && deathsNow >= IRON_SOUL_MAX_LIVES
            return False
        endif
    endif

    return (deathsNow >= IRON_SOUL_MAX_LIVES)
EndFunction

Function PlayCHIMTransitionMessageSequenceSWF(Int soulTierTD, Bool restoreMusicAfterIntro = True)
    String m0 = "1defianttransitionflash"
    String m1 = ResolvePermadeathMenu(soulTierTD)
    String m2 = ResolveCHIMTransitionMenu(soulTierTD)
    String m3 = "0chimintro"

    if m1 == "" || m2 == "" || m3 == ""
        LogMsg(LOG_ERR(), "PlayCHIMTransitionMessageSequenceSWF: One or more menus resolved empty")
        return
    endif

    Actor player = Game.GetPlayer()

    UI.CloseCustomMenu()

    PlaySFX(SFXDefiantTransition, player)

    UI.OpenCustomMenu(m1, 0)
    Utility.WaitMenuMode(4.0)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.25)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m1, 0)
    Utility.WaitMenuMode(3.35)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.25)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m2, 0)
    Utility.WaitMenuMode(3.35)
    UI.CloseCustomMenu()

    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.5)

    OpenTimedMessageSWF_KeyDismiss(m3, 60.0, 10.0, restoreMusicAfterIntro)
EndFunction

; Defiant transition sequence
Function PlayDefiantTransitionMessageSequenceSWF(Int soulTierTD, Bool restoreMusicAfterIntro = True)
    String m0 = "1defianttransitionflash"
    String m1 = ResolvePermadeathMenu(soulTierTD)
    String m2 = ResolveDefiantTransitionMenu(soulTierTD)
    String m3 = ResolveDefiantIntroMenu()

    if m1 == "" || m2 == "" || m3 == ""
        LogMsg(LOG_ERR(), "PlayDefiantTransitionMessageSequenceSWF: One or more menus resolved empty")
        return
    endif

    Actor player = Game.GetPlayer()

    ; Hard interrupt anything currently open
    UI.CloseCustomMenu()

    PlaySFX(SFXDefiantTransition, player)

    ; Show permadeath tier 1
    UI.OpenCustomMenu(m1, 0)
    Utility.WaitMenuMode(4.0)
    UI.CloseCustomMenu()

    ; Defiant transition flash
    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.25)
    UI.CloseCustomMenu()

    ; Show permadeath tier 2
    UI.OpenCustomMenu(m1, 0)
    Utility.WaitMenuMode(3.35)
    UI.CloseCustomMenu()

    ; Defiant transition flash
    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.25)
    UI.CloseCustomMenu()

    ; Defiant transition
    UI.OpenCustomMenu(m2, 0)
    Utility.WaitMenuMode(3.35)
    UI.CloseCustomMenu()

    ; Defiant transition flash
    UI.OpenCustomMenu(m0, 0)
    Utility.WaitMenuMode(0.5)
    ;UI.CloseCustomMenu()

    ; Defiant intro
    OpenTimedMessageSWF_KeyDismiss(m3, 60.0, 10.0, restoreMusicAfterIntro)
EndFunction

Event OnKeyDown(Int keyCode)
    if !_keyDismissActive
        return
    endif
    _keyDismissPressed = True
EndEvent

Function RegisterForAllKeys()
    ; Register only specific dismissal keys (keyboard + mouse + gamepad).
    RegisterForKey(1)   ; Esc
    RegisterForKey(28)  ; Enter
    RegisterForKey(57)  ; Space

    RegisterForKey(256) ; LeftMouseButton
    RegisterForKey(257) ; RightMouseButton

    RegisterForKey(270) ; Start
    RegisterForKey(271) ; Back
    RegisterForKey(276) ; GamepadA
    RegisterForKey(277) ; GamepadB
    RegisterForKey(278) ; GamepadX
    RegisterForKey(279) ; GamepadY
EndFunction

Function UnregisterForAllKeys()
    UnregisterForKey(1)   ; Esc
    UnregisterForKey(28)  ; Enter
    UnregisterForKey(57)  ; Space

    UnregisterForKey(256) ; LeftMouseButton
    UnregisterForKey(257) ; RightMouseButton

    UnregisterForKey(270) ; Start
    UnregisterForKey(271) ; Back
    UnregisterForKey(276) ; GamepadA
    UnregisterForKey(277) ; GamepadB
    UnregisterForKey(278) ; GamepadX
    UnregisterForKey(279) ; GamepadY
EndFunction


; ================
; --- Sound FX ---
; ================

Bool Function CanPlaySFX()
    if _disableSFX
        return False
    endif
    if _uninstallMode
        return False
    endif
    if _modDisabled
        return False
    endif
    return True
EndFunction

Bool Function IsSFXDisabledByCategory(Sound sfx)
    if !sfx
        return True
    endif

    if sfx == SFXIronIntro
        return _disableIronIntroSFX
    elseif sfx == SFXDeath
        return _disableDeathSFX
    elseif sfx == SFXPermadeath
        return _disablePermadeathSFX
    elseif sfx == SFXRespawn
        return _disableRespawnSFX
    elseif sfx == SFXDefiantTransition
        return _disableDefiantTransitionSFX
    elseif sfx == SFXDragonSoulRevive1 || sfx == SFXDragonSoulRevive2 || sfx == SFXDragonSoulRevive3 || sfx == SFXDragonSoulRevive4
        return _disableDragonSoulReviveSFX
    elseif sfx == SFXFeatSilver || sfx == SFXFeatGold || sfx == SFXFeatEbon || sfx == SFXFeatPlatinum || sfx == SFXFeatDefiant
        return _disableFeatUnlockSFX
    elseif sfx == SFXLuckRoll
        return _disableLuckRollSFX
    elseif sfx == SFXLuckFailure || sfx == SFXLuckSuccess
        return _disableLuckOutcomeSFX
    elseif sfx == HeavyBreathingSFX0 || sfx == HeavyBreathingSFX1 || sfx == HeavyBreathingSFX2 || sfx == HeavyBreathingSFX3 || sfx == HeavyBreathingSFX4 || sfx == HeavyBreathingSFX5 || sfx == HeavyBreathingSFX6 || sfx == HeavyBreathingSFX7 || sfx == HeavyBreathingSFX8 || sfx == HeavyBreathingSFX9
        return _disableRespawnHeavyBreathingSFX
    endif

    return False
EndFunction

Function PlaySFX(Sound sfx, Actor source)
    if !CanPlaySFX()
        return
    endif
    if !sfx || !source
        return
    endif
    if IsSFXDisabledByCategory(sfx)
        return
    endif
    sfx.Play(source)
EndFunction

Sound Function PickHeavyBreathingSFX(Actor player)
    ; Approximate player voice buckets using race + sex.
    ; Buckets are aligned to VoicesPlayer list order (0..9).
    Int sex = 0
    Int raceId = 0
    ActorBase baseRef = none
    Race raceNow = none
    Sound picked = none

    if player
        baseRef = player.GetActorBase()
        raceNow = player.GetRace()
    endif
    if baseRef
        sex = baseRef.GetSex()
    endif
    if raceNow
        raceId = raceNow.GetFormID()
    endif

    ; Female buckets first where needed.
    if raceId == 0x00013747 ; OrcRace
        if sex == 1
            picked = HeavyBreathingSFX5
        else
            picked = HeavyBreathingSFX1
        endif
    elseif raceId == 0x00013745 ; KhajiitRace
        if sex == 1
            picked = HeavyBreathingSFX7
        else
            picked = HeavyBreathingSFX0
        endif
    elseif raceId == 0x00013740 ; ArgonianRace
        if sex == 1
            picked = HeavyBreathingSFX9
        else
            picked = HeavyBreathingSFX4
        endif
    elseif raceId == 0x00013742 || raceId == 0x00013743 || raceId == 0x00013749 ; Dark/High/Wood Elf
        if sex == 1
            picked = HeavyBreathingSFX8
        else
            picked = HeavyBreathingSFX3
        endif
    else
        ; EvenToned approximation for Nord/Breton/Imperial/Redguard/unknown.
        if sex == 1
            picked = HeavyBreathingSFX6
        else
            picked = HeavyBreathingSFX2
        endif
    endif

    if picked
        return picked
    endif

    ; Fallback to first available heavy-breathing SFX.
    if HeavyBreathingSFX0
        return HeavyBreathingSFX0
    elseif HeavyBreathingSFX1
        return HeavyBreathingSFX1
    elseif HeavyBreathingSFX2
        return HeavyBreathingSFX2
    elseif HeavyBreathingSFX3
        return HeavyBreathingSFX3
    elseif HeavyBreathingSFX4
        return HeavyBreathingSFX4
    elseif HeavyBreathingSFX5
        return HeavyBreathingSFX5
    elseif HeavyBreathingSFX6
        return HeavyBreathingSFX6
    elseif HeavyBreathingSFX7
        return HeavyBreathingSFX7
    elseif HeavyBreathingSFX8
        return HeavyBreathingSFX8
    endif
    return HeavyBreathingSFX9
EndFunction

Sound Function PickDragonSoulReviveCastSFX()
    Int r = Utility.RandomInt(1, 4)
    Sound picked = none

    if r == 1 && SFXDragonSoulReviveCast1
        picked = SFXDragonSoulReviveCast1
    elseif r == 2 && SFXDragonSoulReviveCast2
        picked = SFXDragonSoulReviveCast2
    elseif r == 3 && SFXDragonSoulReviveCast3
        picked = SFXDragonSoulReviveCast3
    elseif r == 4 && SFXDragonSoulReviveCast4
        picked = SFXDragonSoulReviveCast4
    endif

    if !picked
        if SFXDragonSoulReviveCast1
            picked = SFXDragonSoulReviveCast1
        elseif SFXDragonSoulReviveCast2
            picked = SFXDragonSoulReviveCast2
        elseif SFXDragonSoulReviveCast3
            picked = SFXDragonSoulReviveCast3
        elseif SFXDragonSoulReviveCast4
            picked = SFXDragonSoulReviveCast4
        endif
    endif

    return picked
EndFunction

Sound Function PickDragonSoulReviveSFX()
    Int r = Utility.RandomInt(1, 4)
    Sound picked = none

    if r == 1 && SFXDragonSoulRevive1
        picked = SFXDragonSoulRevive1
    elseif r == 2 && SFXDragonSoulRevive2
        picked = SFXDragonSoulRevive2
    elseif r == 3 && SFXDragonSoulRevive3
        picked = SFXDragonSoulRevive3
    elseif r == 4 && SFXDragonSoulRevive4
        picked = SFXDragonSoulRevive4
    endif

    if !picked
        if SFXDragonSoulRevive1
            picked = SFXDragonSoulRevive1
        elseif SFXDragonSoulRevive2
            picked = SFXDragonSoulRevive2
        elseif SFXDragonSoulRevive3
            picked = SFXDragonSoulRevive3
        elseif SFXDragonSoulRevive4
            picked = SFXDragonSoulRevive4
        endif
    endif

    return picked
EndFunction

Function RegisterMusicFadeBridge()
    UnregisterForModEvent("IronSoul_MusicFadeSetVolume")
    RegisterForModEvent("IronSoul_MusicFadeSetVolume", "OnMusicFadeSetVolume")
EndFunction

Event OnMusicFadeSetVolume(String eventName, String strArg, Float numArg, Form sender)
    SoundCategory cat = sender as SoundCategory
    if !cat
        return
    endif

    Float v = numArg
    if v < 0.0
        v = 0.0
    elseif v > 1.0
        v = 1.0
    endif

    cat.SetVolume(v)
EndEvent


; ===========================
; --- Uninstall / Cleanup ---
; ===========================
;
; When UninstallMode=1 in config:
;  - Iron Soul is disabled on load.
;  - Cleanup runs in one pass from OnPlayerLoadGame.
;  - The controller remains inert while uninstall mode (or _modDisabled latch) is active.
Function HandleUninstallMode(Actor player)
    if !player
        return
    endif

    IronSoulNative.StopHealthMonitor()

    ; Clear transient runtime jobs/caches so nothing continues in background.
    ResetTransientState()

    ; Ensure no per-tick loop remains active while disabled.
    UnregisterForUpdate()

    ; Strip SoulBonus and OnDying hook immediately.
    RemoveSoulBonusAll(player)
    _soulBonusAppliedTier = -1
    if IronSoulOnDyingSpell && player.HasSpell(IronSoulOnDyingSpell)
        player.RemoveSpell(IronSoulOnDyingSpell)
    endif

    ; Normalize player state in-place.
    player.EndDeferredKill()
    player.GetActorBase().SetEssential(False)
    player.SetGhost(False)
    player.SetAV("Paralysis", 0.0)
    player.RestoreAV("Health", 1000.0)

    _modDisabled = True

    if !_uninstallNotified
        _uninstallNotified = True
        Debug.MessageBox("Iron Soul has been safely disabled.\nYou may now uninstall the mod, or leave it installed in its disabled state.")
    endif
EndFunction

Function ReenableAfterUninstall(Actor player)
    ; Re-enables Iron Soul after a prior uninstall/disable run in this save.
    ; Intended flow:
    ;  - User enabled UninstallMode, saved, then later disabled UninstallMode again.
    ;  - We restore the controller runtime so the mod can continue from existing persistence.
    if !player
        return
    endif

    ; Clear uninstall latch so gameplay logic runs again.
    _modDisabled = False
    _uninstallNotified = False

    ; Reset transient jobs/caches so nothing resumes half-armed.
    ResetTransientState()

    ; Restore OnDying Spell
    if IronSoulOnDyingSpell && !player.HasSpell(IronSoulOnDyingSpell)
        player.AddSpell(IronSoulOnDyingSpell, False)
    endif

    ; Kick the controller back into normal cadence.
    QueueUpdate(FastPollSeconds)
EndFunction
