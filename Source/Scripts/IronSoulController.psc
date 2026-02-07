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
;                                                                   A mod by semisacred.
;
; TODO:
; Remove test getformfromfile                                                                                                                                                       
                                                                                            
; =================
; Table of Contents
; =================

; --- Config (INI via SKSE plugin) + Logging ---
; ----------------------------------------------
; LoadConfig()
; LOG_ERR()
; LOG_INFO()
; LOG_DBG()
; LogMsg()
; LogSystemSnapshot()

; --- Persistence (MainData + Co-save) ---
; ----------------------------------------
; MakeKey()
; GetKey()
; PersistGetInt()
; PersistSetInt()
; PersistGetString()
; PersistSetString()
; SyncDeathAV()

; --- Lifecycle & Runtime ---
; ---------------------------
; OnInit()
; StartBootstrap()
; GameReloaded()
; SyncDSROnLoad()
; OnUpdate()
; OnUpdateHeartbeat()
; BootstrapTick()
; TickLuckRegen()
; QueueUpdate()
; RescheduleIfJobsRemain()
; ScheduleLoadMessage()

; --- Death Handling ---
; ----------------------
; HandlePlayerDying()
; FailSafeUnlockIfStable()
; HandlePendingDeathCheck()
; HandleBleedoutDetection()
; UpdatePlayerProtectionState()
; TrueDeathAndQuit()
; IncrementTrueDeath()
; FinalizeAndQuit()
; FinalizeAndQuitMainMenu()
; GetEffectiveMaxLives()

; --- Respawn Integration ---
; ---------------------------
; ResolveRespawnQuest()
; IsRespawnEnabled()
; HandleDisableRespawn()

; --- Luck + Cooldown (Respawn Resolution) ---
; --------------------------------------------
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
; ResetLuck()
; LuckTier()
; PickLuckReminderMessage()
; PickLuckLoadFlavour()
; MaybeNotifyLuckThreshold()
; DecodePlayed()
; EncodePlayed()

; --- Character Journal ---
; -------------------------
; JournalEnsureOpenerLogged()
; JournalLogEvent()
; JournalEnsureStartDay()
; JournalDayIndex()

; --- Identity & GUID ---
; -----------------------
; EnsureGuid()
; GetTickGuid()
; EnsureGuidMarker()
; EnsureGuidInIndex()
; GetCosaveGuid()
; WriteIdentitySnapshotStatic()
; WriteIdentitySnapshotLastSeen()
; TryRestoreGuidMissingCosave()
; TryRestoreGuidTamperedCosave()
; EnsureTransientPlayerState()
; ResetTransientJobsAndCaches()

; --- Feats & Unlocks ---
; -----------------------
; TryScheduleFeats()
; HandleFeats()
; TierMenuPrefix()
; ResolveDeathMessageMenu()
; ResolvePermadeathMenu()
; ResolveDSRMenu()
; ResolveRespawnMenu()
; ResolveDefiantFeatUnlockMenu()
; IsMiraakDefeated()
; IsAlduinDefeated()
; IsHarkonDefeated()
; IsMolagBalDefeatedVigilant()

; --- Soul Bonus ---
; ------------------
; SyncSoulBonusAbility()
; RemoveSoulBonusAll()
; GetSoulBonusSpellByTier()

; --- UI & Messaging ---
; ----------------------
; OpenTimedMessageSWF()
; SwfNoBonus()
; HandleLoadNotification()
; HandleRespawnMenu()
; ResolveDefiantTransitionMenu()
; PlayDefiantTransitionMessageSequenceSWF()
; ResolveDragonSoulReviveMenu()
; IsEndlessActive()
; NotifyEndlessChimLoad()
; PickEndlessChimLine()

; --- Uninstall / Cleanup ---
; ---------------------------
; HandleUninstallMode()
; ReenableAfterUninstall()


; =======================================================
; --- Gameplay Config (INI via SKSE plugin) + Logging ---
; =======================================================

; Logging
Bool _logEnabled = False
Int  _logLevel = 2 ; 1=Errors, 2=Info, 3=Debug
Int  _enableLogNotifications = 0

; Core toggles
Bool _disableRespawn = False
Bool _disableRespawnMessage = False
Bool _disableDeathMessage = False
Bool _disableDragonSoulRevive = False
Bool _disableDragonSoulReviveMessage = False
Bool _disableLuckSystem = False
Bool _disableCharacterJournalLog = False
Bool _enableCharacterSheetCompatibility = False

Quest _respawnQuest = None
Bool _respawnAvailable = False

; Feats
Bool _disableDefiantSoulFeat = False
Bool _disableSoulFeats = False
Bool _disableSoulBonus = False

; Anti-cheat: track Feats Dragon Souls via a guarded counter (blocks large console jumps).
Bool _disableDragonSoulAnticheat = False

; Luck / notifications
Int _luckReminderNotificationMode = 0 ; 0=flavour,1=basic,2=disabled
Int _loadNotificationMode = 0 ; 0=default,1=no flavour,2=only flavour,3=disabled
Float _luckTickAt = 0.0

; Uninstall / disable mode
Bool _uninstallMode = False ; INI: UninstallMode=1 -> safe cleanup + disable
Bool _modDisabled = False
Bool _uninstallNotified = False
Int  _uninstallStage = 0
Float _uninstallAt = 0.0

; Used during uninstall to remove Dragon Soul Revive components.
Spell Property DSRAbility Auto
Spell Property DSROnDying Auto
Quest Property DSRQuest Auto

; Soul Bonus tier abilities (constant-effect Ability spells; applied/removed by script)
Spell Property SoulBonus1Iron Auto
Spell Property SoulBonus2Silver Auto
Spell Property SoulBonus3Gold Auto
Spell Property SoulBonus4Ebon Auto
Spell Property SoulBonus5Platinum Auto

; Boss quest latches
Quest Property MQ305 Auto
Quest Property DLC1VQ08 Auto
Quest Property DLC2MQ06 Auto

; Shared globals
GlobalVariable Property IronSoul_DeathCount Auto
GlobalVariable Property IronSoul_DSR_Enabled Auto

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

; Tunables
Int Property IRON_SOUL_MAX_LIVES = 10 AutoReadOnly
Int Property DEFIANT_SOUL_MAX_LIVES = 100 AutoReadOnly
Int Property LUCK_REGEN_SECONDS = 3600 AutoReadOnly ; Luck 0->100 duration

; Read INI overrides via SKSE plugin (all optional)- 
; Data\SKSE\Plugins\IronSoul.ini
; File: Data\SKSE\Plugins\IronSoul.ini
; Sections are organizational only.
Function LoadConfig()
    ; Defaults (script defaults)
    _logEnabled = False
    _logLevel = 2
    _enableLogNotifications = 0

    ; Messaging (SWF)
    _disableRespawnMessage = False
    _disableDragonSoulReviveMessage = False

    ; Gameplay / integration
    _disableRespawn = False
    _disableDeathMessage = False
    _enableCharacterSheetCompatibility = False
    _disableDragonSoulRevive = False
    _disableSoulBonus = False
    _disableCharacterJournalLog = False
    _uninstallMode = False
    _CHIM = 0

    ; Luck / load notifications
    _disableLuckSystem = False
    _luckReminderNotificationMode = 0
    _loadNotificationMode = 0

    ; Feats
    _disableDefiantSoulFeat = False
    _disableSoulFeats = False

    Int v = IronSoulNative.GetConfigInt("EnableLogging", -1)
    if v == 0
        _logEnabled = False
    elseif v == 1
        _logEnabled = True
    endif

    v = IronSoulNative.GetConfigInt("LogLevel", -1)
    if v >= 1 && v <= 3
        _logLevel = v
    endif

    v = IronSoulNative.GetConfigInt("EnableLogNotifications", -1)
    if v == 0
        _enableLogNotifications = 0
    elseif v == 1
        _enableLogNotifications = 1
    endif

    v = IronSoulNative.GetConfigInt("DisableDeathMessage", -1)
    if v == 0
        _disableDeathMessage = False
    elseif v == 1
        _disableDeathMessage = True
    endif

    v = IronSoulNative.GetConfigInt("DisableDragonSoulRevive", -1)
    if v == 0
        _disableDragonSoulRevive = False
    elseif v == 1
        _disableDragonSoulRevive = True
    endif

    v = IronSoulNative.GetConfigInt("DisableDragonSoulReviveMessage", -1)
    if v == 0
        _disableDragonSoulReviveMessage = False
    elseif v == 1
        _disableDragonSoulReviveMessage = True
    endif

    v = IronSoulNative.GetConfigInt("DisableRespawn", -1)
    if v == 0
        _disableRespawn = False
    elseif v == 1
        _disableRespawn = True
    endif

    v = IronSoulNative.GetConfigInt("DisableRespawnMessage", -1)
    if v == 0
        _disableRespawnMessage = False
    elseif v == 1
        _disableRespawnMessage = True
    endif

    v = IronSoulNative.GetConfigInt("DisableSoulBonus", -1)
    if v == 0
        _disableSoulBonus = False
    elseif v == 1
        _disableSoulBonus = True
    endif

    v = IronSoulNative.GetConfigInt("DisableCharacterJournalLog", -1)
    if v == 0
        _disableCharacterJournalLog = False
    elseif v == 1
        _disableCharacterJournalLog = True
    endif

    v = IronSoulNative.GetConfigInt("UninstallMode", -1)
    if v == 0
        _uninstallMode = False
    elseif v == 1
        _uninstallMode = True
    endif

    v = IronSoulNative.GetConfigInt("EnableCharacterSheetCompatibility", -1)
    if v == 0
        _enableCharacterSheetCompatibility = False
    elseif v == 1
        _enableCharacterSheetCompatibility = True
    endif

    v = IronSoulNative.GetConfigInt("CHIM", -1)
    if v == 0
        _CHIM = 0
    elseif v == 1
        _CHIM = 1
    endif

    ; Luck / notifications
    v = IronSoulNative.GetConfigInt("DisableLuckSystem", -1)
    if v == 0
        _disableLuckSystem = False
    elseif v == 1
        _disableLuckSystem = True
    endif

    v = IronSoulNative.GetConfigInt("LuckReminderNotificationMode", -1)
    if v >= 0 && v <= 2
        _luckReminderNotificationMode = v
    endif

    v = IronSoulNative.GetConfigInt("LoadNotificationMode", -1)
    if v >= 0 && v <= 3
        _loadNotificationMode = v
    endif

    v = IronSoulNative.GetConfigInt("DisableDefiantFeat", -1)
    if v == 0
        _disableDefiantSoulFeat = False
    elseif v == 1
        _disableDefiantSoulFeat = True
    endif

    v = IronSoulNative.GetConfigInt("DisableSoulFeats", -1)
    if v == 0
        _disableSoulFeats = False
    elseif v == 1
        _disableSoulFeats = True
    endif

    v = IronSoulNative.GetConfigInt("DisableDragonSoulAnticheat", -1)
    if v == 0
        _disableDragonSoulAnticheat = False
    elseif v == 1
        _disableDragonSoulAnticheat = True
    endif

    ; Publish DSR enabled state for all scripts (DSR reads this GlobalVariable; avoids config reads during death events).
    if IronSoul_DSR_Enabled
        ; Hard disable DSR while the controller is inert (uninstall mode or mod-disabled latch).
        if _modDisabled || _uninstallMode || _disableDragonSoulRevive
            IronSoul_DSR_Enabled.SetValue(0.0)
        else
            IronSoul_DSR_Enabled.SetValue(1.0)
        endif
    endif

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

Function LogMsg(Int level, String msg)
	if !_logEnabled
		return
	endif
	if level > _logLevel
		return
	endif

	if _enableLogNotifications == 1
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

Function LogSystemSnapshot()

	if !_logEnabled || _logLevel < LOG_INFO()
		return
	endif

	LogMsg(LOG_INFO(), "===== Iron Soul System Snapshot =====")

	; SKSE / Datastore Integrity
	Bool skseOK = IronSoulNative.IsAvailable()
	Bool dsOK = False
	if skseOK
		dsOK = IronSoulNative.DataStoreReady()
	endif

	LogMsg(LOG_INFO(), "SKSE: Available=" + skseOK \
		+ " DataStore=" + dsOK \
		+ " SessionGUID=" + _sessionGuid)

	; GUID sanity
	if _sessionGuid == "" || _sessionGuid == "999999"
		LogMsg(LOG_ERR(), "WARNING: Invalid or fallback SessionGUID detected")
	endif

	; Respawn / DSR
	Bool hasRespawn = (_respawnQuest != None)
	Bool respawnRunning = (hasRespawn && _respawnQuest.IsRunning())

	Float dsrEnabled = 0.0
	if IronSoul_DSR_Enabled
		dsrEnabled = IronSoul_DSR_Enabled.GetValue()
	endif

	LogMsg(LOG_INFO(), "Respawn: Present=" + hasRespawn \
		+ " Running=" + respawnRunning \
		+ " DisableRespawn=" + _disableRespawn \
		+ " DSR=" + dsrEnabled)

	; Detect mismatch
	if hasRespawn && !_disableRespawn && !respawnRunning
		LogMsg(LOG_ERR(), "WARNING: Respawn quest present but NOT running")
	endif

	; Core Config
	LogMsg(LOG_INFO(), "Config: Logging=" + _logEnabled \
		+ " Level=" + _logLevel \
		+ " Notify=" + _enableLogNotifications \
		+ " CHIM=" + _CHIM \
		+ " UninstallMode=" + _uninstallMode \
		+ " ModDisabled=" + _modDisabled)

	; Systems
	LogMsg(LOG_INFO(), "Systems: Luck=" + (!_disableLuckSystem) \
		+ " SoulBonus=" + (!_disableSoulBonus) \
		+ " SoulFeats=" + (!_disableSoulFeats) \
		+ " DragonSoulReviveDisabled=" + _disableDragonSoulRevive)

	; Luck Persistence
	LogMsg(LOG_INFO(), "Luck: Loaded=" + _luckCooldownLoaded \
		+ " Dirty=" + _luckCooldownDirty \
		+ " LastSec=" + _luckCooldownLastSec \
		+ " NextPersistAt=" + _luckCooldownNextPersistAt)

	if !_disableLuckSystem && !_luckCooldownLoaded
		LogMsg(LOG_ERR(), "WARNING: Luck system enabled but cooldown not loaded")
	endif

	; Runtime Health
	LogMsg(LOG_INFO(), "Runtime: PendingDeathCheck=" + _pendingDeathCheck \
		+ " PendingDisableRespawn=" + _pendingDisableRespawn \
		+ " UninstallStage=" + _uninstallStage)

	if _pendingDeathCheck
		LogMsg(LOG_ERR(), "WARNING: Death pipeline still pending")
	endif

	; Player Snapshot
	Actor p = Game.GetPlayer()
	if p
		Int deaths = 0
		if IronSoul_DeathCount
			deaths = IronSoul_DeathCount.GetValue() as Int
		endif

		LogMsg(LOG_INFO(), "Player: Level=" + p.GetLevel() \
			+ " Dead=" + p.IsDead() \
			+ " InCombat=" + p.IsInCombat() \
			+ " Deaths=" + deaths)

        ; Soul Tier check (if datastore working)
        if dsOK
        	Int tier = PersistGetInt(p, GetKey(soulTierIndex, _sessionGuid), 0)
        	LogMsg(LOG_INFO(), "SoulTier=" + tier)
        endif
	endif

	LogMsg(LOG_INFO(), "===== End Snapshot =====")

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
; - Controller does not manage MirrorData or periodic flushes.
; - Controller only invokes IronSoulNative.DataFlushNow() at critical points.
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
; - DisableLuckSystem=0: played time maps to Luck% (0..100)
; - DisableLuckSystem=1: played time maps to cooldown readiness (0..3600s)
String Property luckLastSec                = "IS_7314" AutoReadOnly ; Luck/Cooldown: last real-time second anchor
String Property luckPlayedToken            = "IS_7315" AutoReadOnly ; Luck/Cooldown: played-seconds token (encoded)
String Property luckNotifiedTier           = "IS_7316" AutoReadOnly ; Luck: last notified threshold tier
String Property luckResetKind              = "IS_7317" AutoReadOnly ; Luck: reset-kind tag (1=post-death, 2=post-respawn)

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
String Property dragonSoulsTrusted         = "IS_9646" AutoReadOnly
String Property dragonSoulsLastSeen        = "IS_7440" AutoReadOnly

; Boss latches
String Property miraakKilled               = "IS_4911" AutoReadOnly
String Property alduinKilled               = "IS_9897" AutoReadOnly
String Property harkonKilled               = "IS_9808" AutoReadOnly
String Property molagBalKilled             = "IS_1627" AutoReadOnly

; Defiant
String Property defiantFeatUnlocked        = "IS_1989" AutoReadOnly
String Property defiantActivated           = "IS_6139" AutoReadOnly

; Journal markers
String Property journalStartDay            = "IS_5341" AutoReadOnly
String Property journalOpenerLogged        = "IS_2270" AutoReadOnly
String Property journalEndlessLogged       = "IS_1927" AutoReadOnly
String Property journalUninstallLogged     = "IS_6086" AutoReadOnly

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
    if IronSoulNative.DataHasKey(dataKey)
        return IronSoulNative.DataGetInt(dataKey, fallback)
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
        Int cur = StorageUtil.GetIntValue(player, dataKey)
        if cur != value
            StorageUtil.SetIntValue(player, dataKey, value)
        endif
    endif
EndFunction

String Function PersistGetString(Actor player, String dataKey, String fallback)
    if !player
        return fallback
    endif
    if dataKey == ""
        return fallback
    endif
    if IronSoulNative.DataHasKey(dataKey)
        return IronSoulNative.DataGetString(dataKey, fallback)
    endif
    ; Only heal MainData from co-save if the value truly exists in co-save.
    if StorageUtil.HasStringValue(player, dataKey)
        String v = StorageUtil.GetStringValue(player, dataKey, fallback)
        IronSoulNative.DataSetStringIfChanged(dataKey, v)
        return v
    endif

    return fallback
EndFunction

Function PersistSetString(Actor player, String dataKey, String value, Bool useIfChanged = True)
    if dataKey == ""
        return
    endif
    if useIfChanged
        IronSoulNative.DataSetStringIfChanged(dataKey, value)
    else
        IronSoulNative.DataSetString(dataKey, value)
    endif
    if player
        String cur = StorageUtil.GetStringValue(player, dataKey)
        if cur != value
            StorageUtil.SetStringValue(player, dataKey, value)
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
Float Property StandardPollSeconds = 1.00 Auto
Float Property FastPollSeconds     = 0.20 Auto
Float Property PendingFastLoopWatchdogSeconds = 30.0 Auto ; clears stuck fast-loop jobs
String _sessionGuid = "999999"

; Pending Jobs / Timers
Int _soulBonusAppliedTier = -1

Bool  _pendingDisableRespawn = False
Bool  _pendingDeathCheck     = False
Bool  _pendingLoadMessage    = False
Bool  _pendingIronIntro      = False

Float _deathCheckAt  = 0.0
Float _ironIntroAt   = 0.0
Float _loadMessageAt = 0.0

Float _pendingDisableRespawnStartedAt = 0.0
Float _pendingLoadMessageStartedAt    = 0.0
Float _pendingDeathCheckStartedAt     = 0.0

Int   _dsrSoulsAtDeath = -1

; Feats / Heartbeat
Bool  _pendingFeats = False
Bool  _featsLastSeenInit = False

Float _featsAt = 0.0
Float _nextHeartbeatAt = 0.0        ; heartbeat cadence gate
Float _nextFeatsSoulCheckAt = 0.0

; GUID Tick State
String _tickGuid = ""
Bool   _tickGuidValid = False

; Bleedout / Death Resolution
Bool  _wasBleedingOut = False
Bool  _bleedoutArmed = False
Bool  _bleedoutDecisionMade = False
Bool  _bleedoutDecisionIsRespawn = False
Bool  _bleedoutForcedKill = False
Bool  _deathEventLocked = False

Float _pendingTrueDeathAt = 0.0
Float _pendingQuitMenuAt  = 0.0
Bool  _pendingQuitArmed   = False

Bool  _updateQueued = False
Bool  _isQuitting   = False

; Respawn Messaging
Bool  _pendingRespawnMenu = False
Bool  _respawnMenuArmed   = False
Float _respawnWarningAt   = 0.0
Bool  _pendingLuckResetAfterRespawn = False
Bool  _pendingCooldownResetAfterRespawn = False

; Permanent death counter AV (unused vanilla actor value; exposed for UI mods)
String _deathAVName = "DEPRECATED05"
Bool  _pendingDeathResync = False
Float _deathResyncAt      = 0.0

; Bootstrap
Bool _bootstrapActive = False
Int  _bootstrapTriesLeft = 0

Event OnInit()
	LoadConfig()
	; Reset Vigilant quest cache each session so Vigilant can be installed/updated between runs.
	_vigilantMq08Cache = None
	_vigilantMq08Tried = False
	LogMsg(LOG_INFO(), "OnInit fired (script running).")

	StartBootstrap()

	QueueUpdate(StandardPollSeconds)
EndEvent

Function StartBootstrap()
    ; Kick off bootstrap sequence for GUID system.
    ; We retry until:
    ;  - Player reference exists, and
    ;  - EnsureGuid() can succeed (identity ready; player name available).

    _bootstrapActive = True
    _bootstrapTriesLeft = 30 
    _updateQueued = False

    QueueUpdate(1.0)
EndFunction

Function GameReloaded(Bool isLoadGame)
    ; Load config / log settings first.
    LoadConfig()

    ; Reset Vigilant quest cache on reload so Vigilant can be installed/updated between sessions.
    _vigilantMq08Cache = None
    _vigilantMq08Tried = False

    Actor player = Game.GetPlayer()
    if !player
        LogMsg(LOG_ERR(), "OnPlayerLoadGame: player None (alias not filled yet?)")
        return
    endif

    ; If uninstall cleanup has already run, keep the controller inert until the user disables UninstallMode.
    ; Also force-disable the DragonSoulRevive system via the shared global while inert.
    if _modDisabled || _uninstallMode
        if IronSoul_DSR_Enabled
            IronSoul_DSR_Enabled.SetValue(0.0)
        endif
        QueueUpdate(30.0)
        return
    endif

    ; DSR: ensure quest/spells exist when enabled (covers prior uninstall removal)
    SyncDSROnLoad(player)

    ; Identity bootstrap
    String name = IronSoulNative.GetPlayerName()
    String cosaveGuid = StorageUtil.GetStringValue(player, characterGuid, "")

; Attempt to restore GUID if co-save GUID looks suspicious (present, but not known to MainData),
; using identity snapshots (only beyond level 1).
    TryRestoreGuidTamperedCosave(player, name, cosaveGuid)

    String guid = EnsureGuid(player)

    LogMsg(LOG_INFO(), "OnPlayerLoadGame: Player=" + name + " GUID=" + guid)

    if guid != "" && name != ""
        WriteIdentitySnapshotStatic(guid, player, name)
        WriteIdentitySnapshotLastSeen(guid, player)
        EnsureGuidMarker(guid)
    endif

    ; Validate player execution context (actor presence, GUID identity, and transient state)
    if EnsureTransientPlayerState(player, guid)
        return
    endif

    ; SoulBonus: sync on load
    if guid != ""
        SyncSoulBonusAbility(player, guid)
    endif

    UpdatePlayerProtectionState(player, guid)

    ; One-time reconcile / enforcement
    if guid != ""
        Int deathsNow = PersistGetInt(player, GetKey(deathCount, guid), 0)

        if _enableCharacterSheetCompatibility
            SyncDeathAV(player, deathsNow)
        endif

        ; Keep the global in sync (used by UI / other systems)
        IronSoul_DeathCount.SetValue(deathsNow)

        ; Enforce essential / quest state using current identity.
        UpdatePlayerProtectionState(player, guid)

        ; Journal: Endless Mode activation (CHIM) - record once when the run becomes eligible.
        if !_disableCharacterJournalLog
            if _CHIM == 1
                Int endlessStart = IRON_SOUL_MAX_LIVES
                Int defActive = 0
                if !_disableDefiantSoulFeat
                    defActive = PersistGetInt(player, GetKey(defiantActivated, guid), 0)
                endif
                if defActive == 1
                    endlessStart = DEFIANT_SOUL_MAX_LIVES
                endif

                if deathsNow >= endlessStart
                    Int chimLogged = PersistGetInt(player, GetKey(journalEndlessLogged, guid), 0)
                    if chimLogged != 1
                        JournalLogEvent("CHIM realized: Death is merely an illusion, a cycle to be broken. Endless Mode activated.")
                        PersistSetInt(player, GetKey(journalEndlessLogged, guid), 1, True)
                    endif
                endif
            endif
        endif
    endif

    LogSystemSnapshot()

    ; Schedule load message (delayed UI + load-time enforcement).
    ScheduleLoadMessage(isLoadGame, player, guid)
EndFunction

Event OnUpdate()
    _updateQueued = False

    if _isQuitting
        return
    endif

    Actor player = Game.GetPlayer()

    ; Soft-uninstall mode: disable all functionality and run cleanup once.
    if _uninstallMode
        HandleUninstallMode(player)
        return
    endif

    ; If uninstall cleanup previously ran in this save, but UninstallMode is now off, re-enable.
    if !_uninstallMode && _modDisabled
        ReenableAfterUninstall(player)
        return
    endif

    ; Validate player execution context (actor presence, GUID identity, and transient state)
    if EnsureTransientPlayerState(player, "")
        return
    endif

    ; Luck / Cooldown regen tick (menu-safe). Run early so menu time never advances.
    if _tickGuidValid
        if IsLuckActive()
            TickLuckRegen(player, _tickGuid)
        elseif IsCooldownModeActive()
            TickCooldownRegen(player, _tickGuid)
        endif
        UpdatePlayerProtectionState(player, _tickGuid)
    endif

    ; Defer initialisation bootstrap if necessary
    if BootstrapTick()
        return
    endif

    ; Fail-safe: unlock death handling if player is stable
    FailSafeUnlockIfStable(player)

    ; Timed load-notification handler
    HandleLoadNotification(player)

    ; Low-frequency (5s) maintenance and progression integrity checks
    OnUpdateHeartbeat(player)

    ; Soul Feats evaluation (unlock messages)
    TryScheduleFeats(player)
    HandleFeats(player)

    ; Delayed true-death confirmation (no respawn branch)
    if HandlePendingDeathCheck(player)
        return
    endif

    ; Delayed respawn message
    HandleRespawnMenu(player)

    ; Bleedout detection and possible immediate actions
    if HandleBleedoutDetection(player)
        return
    endif

    ; Disable _respawnQuest job
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

    ; Refresh last-seen identity snapshot (I.L/I.D) on this low-frequency cadence.
    WriteIdentitySnapshotLastSeen(guid, player)

    if _enableCharacterSheetCompatibility
        Int deathsNow = PersistGetInt(player, GetKey(deathCount, guid), 0)
        SyncDeathAV(player, deathsNow)
    endif

    ; Dragon Soul integrity tracking (optional)
    ;  - Sample DragonSouls once per heartbeat (~5s).
    ;  - If the increase since last heartbeat is 1..3, we count it as "trusted" toward Feats.
    ;  - If the increase is >3, we treat it as suspicious and do NOT credit Feats progress.
    ; This can be disabled via disableDragonSoulAnticheat. Boss-based feat gating below still runs.
    if !_disableDragonSoulAnticheat
        Int curSouls = player.GetActorValue("DragonSouls") as Int

        Int lastSouls = PersistGetInt(player, GetKey(dragonSoulsLastSeen, guid), curSouls)
        Int delta = curSouls - lastSouls

        ; Debug notification for suspicious jumps
        if delta > 3
            Debug.Notification("[Iron Soul] Unusual Dragon Soul increase detected (D=" + delta + "); Feats progress not updated. Leave bug report if legitimate.")
        endif

        if delta > 0 && delta <= 3
            Int featsSouls = PersistGetInt(player, GetKey(dragonSoulsTrusted, guid), 0)
            featsSouls = featsSouls + delta
            PersistSetInt(player, GetKey(dragonSoulsTrusted, guid), featsSouls, True)

            ; Trigger Feats evaluation soon (message boxes must be shown in a safe context).
            ; If all Feats are disabled via INI, we still track the counter but do not schedule messaging.
            if !_disableDefiantSoulFeat || !_disableSoulFeats
                _pendingFeats = True
                if _featsAt < (nowRT + 4.0)
                    _featsAt = nowRT + 4.0
                endif
            endif

            ; Journal: log Dragon Soul claims (event-driven; no periodic visible-log writes).
            Int j = 0
            while j < delta
                Int claimed = featsSouls - (delta - 1 - j)
                JournalLogEvent("Absorbed a Dragon's Soul. Dragon Souls Claimed: " + claimed)
                j += 1
            endwhile
        endif

        ; Always advance last-seen snapshot so we don't re-credit the same delta next tick.
        PersistSetInt(player, GetKey(dragonSoulsLastSeen, guid), curSouls, True)
    endif

    ; --- Boss defeat polls (Ebon / Platinum gating) ---
    ; Some boss defeats are only reliably detectable by quest stage progression (no stable actor OnDeath hook).
    ; To make Ebon/Platinum unlock feel near-immediate even when no Dragon Soul delta occurs, we poll the relevant
    ; quest states on this same low-frequency cadence (~5s) and latch per-character when detected.
    ;
    ; Performance notes:
    ;  - Only polls until a per-character latch flag is set, then becomes a cheap O(1) read.
    ;  - Each poll is guarded by the current Soul Feat so we don't keep checking after the tier is already earned.
    Int curTier = PersistGetInt(player, GetKey(soulTierIndex, guid), 0)
    Int deaths  = PersistGetInt(player, GetKey(deathCount, guid), 0)

    if deaths < IRON_SOUL_MAX_LIVES && !_disableSoulFeats
        ; Platinum checks (Molag Bal has priority over Miraak for variant credit).
        if curTier < 4
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
        if curTier < 3
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
EndFunction

Bool Function BootstrapTick()
    if !_bootstrapActive
        return False
    endif

    Actor p = Game.GetPlayer()
    if !p
        ; Only burn retries when the player ref truly isn't available.
        _bootstrapTriesLeft -= 1

        if _bootstrapTriesLeft <= 0
            _bootstrapActive = False
            LogMsg(LOG_ERR(), "Bootstrap: player still None after 60s; continuing normal polling.")
            return False
        endif

        LogMsg(LOG_INFO(), "Bootstrap: player None; retrying (" + _bootstrapTriesLeft + "s left)")
        _updateQueued = False
        QueueUpdate(1.0)
        return True
    endif

    ; Do NOT consume retries while in UI/menu mode (e.g., long RaceMenu sessions).
    if Utility.IsInMenuMode()
        ; Keep bootstrap active and retry later.
        _updateQueued = False
        QueueUpdate(1.5)
        return True
    endif

    ; Acquire a GUID when identity is ready.
    ; EnsureGuid() should return "" until IronSoulNative.GetPlayerName() is available.
    String bguid = EnsureGuid(p)
    if bguid == ""
        ; Identity not ready yet (name not available). Keep bootstrapping.
        _updateQueued = False
        QueueUpdate(1.0)
        return True
    endif

    ; Bootstrap complete only after we successfully obtain a GUID.
    _bootstrapActive = False
    LogMsg(LOG_INFO(), "Bootstrap: GUID ready; bootstrap complete (" + bguid + ")")

    ; SoulBonus: initial sync once GUID becomes available (new game)
    SyncSoulBonusAbility(p, bguid)

    return False
EndFunction

Function TickLuckRegen(Actor player, String guid)
    ; Advances per-character Luck regeneration (0 -> 100 over LUCK_REGEN_SECONDS).
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

    ; Initialize on first run so Luck starts at 100 on a new game.
    if lastSec <= 0 || playedTok <= 0
        played = LUCK_REGEN_SECONDS
        _luckCooldownPlayedTok = EncodePlayed(nowSec, played)
        _luckCooldownLastSec = nowSec
        LuckCooldownMarkDirty()
        ; New game: suppress threshold reminder spam by marking 100 as already notified.
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

    Int luckNow = GetLuckValue(player, guid)
    MaybeNotifyLuckThreshold(player, guid, luckNow)
    LogMsg(LOG_DBG(), "Luck: " + luckNow + " / 100 (" + played + "/" + LUCK_REGEN_SECONDS + "s)")
EndFunction

Function QueueUpdate(Float afDelay)
	if _updateQueued
		LogMsg(LOG_DBG(), "QueueUpdate skipped; already queued. delay=" + afDelay)
		return
	endif
	_updateQueued = True
	LogMsg(LOG_DBG(), "QueueUpdate scheduled. delay=" + afDelay)
	RegisterForSingleUpdate(afDelay)
EndFunction

Function RescheduleIfJobsRemain()
    ; Keep the update loop tight while any short-lived jobs are pending, or while the player is in bleedout (so we react quickly).
    ; Safety watchdog: if a fast-loop job gets stuck, clear it to avoid 0.20s polling forever.
    Float nowRT = Utility.GetCurrentRealTime()

    if _pendingDisableRespawn && _pendingDisableRespawnStartedAt > 0.0 && (nowRT - _pendingDisableRespawnStartedAt) > PendingFastLoopWatchdogSeconds
        _pendingDisableRespawn = False
        LogMsg(LOG_INFO(), "Watchdog: cleared _pendingDisableRespawn after " + (nowRT - _pendingDisableRespawnStartedAt) + "s")
    endif
    if _pendingLoadMessage && _pendingLoadMessageStartedAt > 0.0 && (nowRT - _pendingLoadMessageStartedAt) > PendingFastLoopWatchdogSeconds
        _pendingLoadMessage = False
        LogMsg(LOG_INFO(), "Watchdog: cleared _pendingLoadMessage after " + (nowRT - _pendingLoadMessageStartedAt) + "s")
    endif
    if _pendingDeathCheck && _pendingDeathCheckStartedAt > 0.0 && (nowRT - _pendingDeathCheckStartedAt) > PendingFastLoopWatchdogSeconds
        _pendingDeathCheck = False
        LogMsg(LOG_INFO(), "Watchdog: cleared _pendingDeathCheck after " + (nowRT - _pendingDeathCheckStartedAt) + "s")
    endif

    ; Reset start timers when jobs complete normally.
    if !_pendingDisableRespawn
        _pendingDisableRespawnStartedAt = 0.0
    endif
    if !_pendingLoadMessage
        _pendingLoadMessageStartedAt = 0.0
    endif
    if !_pendingDeathCheck
        _pendingDeathCheckStartedAt = 0.0
    endif

    if _pendingDisableRespawn || _pendingLoadMessage || _pendingDeathCheck || _wasBleedingOut
        QueueUpdate(FastPollSeconds)

    else
        QueueUpdate(StandardPollSeconds)
    endif
EndFunction

; Called from GameReloaded() and is responsible only for arming the load-message job.
Function ScheduleLoadMessage(Bool isLoadGame, Actor player, String guid)
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


; ======================
; --- Death Handling ---
; ======================

Function HandlePlayerDying(Actor akKiller)
	; PRIMARY DEATH HANDLER (non-essential deaths / OnDying).
	; Policy:
	; - Respawn decisions happen in the bleedout handler.
	; - If a dragon soul is available and DSR is enabled, we give DSR a grace window to revive.
	; - Otherwise this is a true death (log + quit).

	Actor player = Game.GetPlayer()
	if !player
		LogMsg(LOG_ERR(), "OnDying: player None")
		return
	endif
	if _uninstallMode
		return
	endif
	if _modDisabled
		return
	endif

	; Hard gate to prevent double-trigger / re-entrancy.
	if _deathEventLocked
		LogMsg(LOG_DBG(), "OnDying ignored; deathEventLocked")
		return
	endif
	_deathEventLocked = True

	String name = IronSoulNative.GetPlayerName()
	if name == ""
		name = "Player"
	endif

	String guid = EnsureGuid(player)
	if guid == ""
		LogMsg(LOG_ERR(), "OnDying: missing GUID; ignoring")
		_deathEventLocked = False
		return
	endif

	Float nowRT = Utility.GetCurrentRealTime()
	LogMsg(LOG_INFO(), "OnDying: Player=" + name + " GUID=" + guid)

	; Ensure respawn quest is not running here; bleedout handler owns respawn decisions.
	if _respawnQuest && _respawnQuest.IsRunning()
		_respawnQuest.Stop()
	endif

	; Keep player NON-essential so:
	; - DSR can revive if souls exist, OR
	; - True death can proceed normally.
	player.GetActorBase().SetEssential(False)

	; If we're already in another death pipeline (e.g., pending quit from bleedout),
	; do not allow OnDying to arm a second pipeline.
	; (These flags exist in your script already; if any are not present, remove those lines.)
	if _pendingQuitArmed
		LogMsg(LOG_INFO(), "OnDying: pendingQuitArmed already set; skipping DSR grace")
		return
	endif
	if _pendingDisableRespawn
		LogMsg(LOG_INFO(), "OnDying: pendingDisableRespawn already set; skipping DSR grace")
		return
	endif
	if _pendingDeathCheck
		LogMsg(LOG_DBG(), "OnDying: pendingDeathCheck already armed")
		return
	endif

	; Snapshot souls so the delayed check can validate consumption *if it wants to*.
	; IMPORTANT: Do NOT hard-fail into permadeath purely because the delta wasn't observed;
	; that validation should be "best effort" (handled in your pending check function).
	Int soulsNow = player.GetActorValue("DragonSouls") as Int

	; Arm DSR grace only if DSR is enabled and a soul is available right now.
	if !_disableDragonSoulRevive && soulsNow > 0
		_dsrSoulsAtDeath = soulsNow
		_pendingDeathCheck = True

		; Track when the grace pipeline began (for watchdog logging / stuck protection).
		_pendingDeathCheckStartedAt = nowRT

		; Grace window (keep as constant if you have one).
		_deathCheckAt = nowRT + 10.0

		; Ensure we enter fast polling to catch the outcome promptly.
		_updateQueued = False
		QueueUpdate(FastPollSeconds)
		return
	endif

	; No souls (or DSR disabled): this is a true death.
	_dsrSoulsAtDeath = -1
	LogMsg(LOG_INFO(), "TRUE DEATH: no dragon souls available (or DSR disabled); skipping DSR grace")

	; True death resets Luck/Cooldown to 0 per design.
	if IsLuckActive()
		ResetLuck(player, guid)
		PersistSetInt(player, GetKey(luckResetKind, guid), 1, True) ; post-death
	elseif IsCooldownModeActive()
		ResetCooldown(player, guid)
	endif

	; Small delay to allow death menu state/animations to settle (keep if you rely on it).
	Utility.Wait(3.0)

	; Lock stays true; we're committing to exit.
	TrueDeathAndQuit(player)
EndFunction

Function FailSafeUnlockIfStable(Actor player)
    ; If the player is stable again and no death-related jobs are pending,
    ; unlock death handling. Prevents stuck locks suppressing future deaths.
    if _deathEventLocked
        if player && !player.IsDead() && !player.IsBleedingOut() && !_pendingDisableRespawn && !_pendingDeathCheck
            _deathEventLocked = False
        endif
    endif
EndFunction

Bool Function HandlePendingDeathCheck(Actor player)
    ; When no respawn is available, HandlePlayerDying arms a delayed check so
    ; DragonsoulResurrect has a chance to revive (if a soul exists). If the player is
    ; still dead after the grace window, this is a true death and we log + exit.

    if !_pendingDeathCheck
        return False
    endif

    if !player
        LogMsg(LOG_ERR(), "HandlePendingDeathCheck: player None")
        ; Don't keep a stuck pending state if the player pointer is lost.
        _pendingDeathCheck = False
        _dsrSoulsAtDeath = -1
        _deathEventLocked = False
        return False
    endif

    ; If DSR is disabled, do not honor any pending grace state.
    if _disableDragonSoulRevive
        _pendingDeathCheck = False
        _dsrSoulsAtDeath = -1
        _deathEventLocked = False
        if player.IsDead()
            LogMsg(LOG_INFO(), "TRUE DEATH: DSR disabled; resolving pending death check immediately")
            TrueDeathAndQuit(player)
            return True
        endif
        ; Player is alive; nothing to do.
        return False
    endif

    Float nowRT = Utility.GetCurrentRealTime()

    ; Still within grace window: keep fast polling alive.
    if nowRT < _deathCheckAt
        _updateQueued = False
        QueueUpdate(FastPollSeconds)
        return True
    endif

    ; Grace window ended: resolve.
    _pendingDeathCheck = False

    Int soulsBefore = _dsrSoulsAtDeath
    _dsrSoulsAtDeath = -1

    if player.IsDead()
        LogMsg(LOG_INFO(), "TRUE DEATH: confirmed after DSR grace window; exiting")
        TrueDeathAndQuit(player)
        return True
    endif

    ; Player is alive after grace window:
    ; This is a "survived / revived" outcome. Do NOT force true death.
    Int soulsAfter = player.GetActorValue("DragonSouls") as Int

    if soulsBefore > 0 && soulsAfter < soulsBefore
        LogMsg(LOG_INFO(), "DSR: revive confirmed (souls before=" + soulsBefore + " after=" + soulsAfter + ")")
    else
        ; Best-effort validation failed (or no snapshot). Treat as revive anyway.
        LogMsg(LOG_INFO(), "DSR grace: player alive but soul delta not observed (before=" + soulsBefore + " after=" + soulsAfter + "); treating as revive/survival")
    endif

    ; Revived / survived: return to a sane non-death state.
    _deathEventLocked = False
    _wasBleedingOut = False
    _bleedoutArmed = False
    _bleedoutForcedKill = False

    ; Respawn is not available in this branch, so keep the player non-essential.
    player.GetActorBase().SetEssential(False)

    return False
EndFunction

Bool Function HandleBleedoutDetection(Actor player)
    ; Job A2: Detect bleedout-based "fake death" states (essential/protected).
    ;
    ; PRIMARY ROLE:
    ; - Handle cases where the player enters bleedout but OnDying will NOT fire
    ;   (common for essential/protected actors).
    ; - If no respawn is actually available, resolve the state immediately by
    ;   forcing a real death so the normal death pipeline (and DragonsoulResurrect) runs.
    ;
    ; FAILSAFE ROLE:
    ; - If the player should have been non-essential but somehow entered bleedout
    ;   anyway (state drift, mod interaction, timing issues), this prevents an
    ;   infinite bleedout soft-lock by forcing resolution.
    if !player
        return False
    endif

    Bool nowBleed = player.IsBleedingOut()
    Float nowRT = Utility.GetCurrentRealTime()

    ; Entering bleedout
    if nowBleed && !_wasBleedingOut
        LogMsg(LOG_INFO(), "BLEEDOUT: entered bleedout")
        _bleedoutArmed = True
        _bleedoutDecisionMade = False
        _bleedoutDecisionIsRespawn = False
        _pendingTrueDeathAt = 0.0
        String n0 = IronSoulNative.GetPlayerName()
        String guid0 = GetTickGuid(player)
        if guid0 != ""
            ; Decide bleedout outcome once per bleedout episode.
            ; - If Luck system is active (DisableLuckSystem=0), roll immediately.
            ; - If Cooldown mode is active (DisableLuckSystem=1), respawn is only allowed when cooldown is ready.
            ; - If neither mode is active, respawn is unavailable (force real death to avoid soft-lock).
            Bool freeRespawn = False
            if IsLuckActive()
                ; Luck mode: roll once per bleedout episode.
                if !_bleedoutDecisionMade
                    Int luck0 = GetLuckValue(player, guid0)
                    Int roll0 = Utility.RandomInt(1, 100)
                    _bleedoutDecisionMade = True
                    _bleedoutDecisionIsRespawn = (roll0 <= luck0)
                    LogMsg(LOG_INFO(), "BLEEDOUT: luck roll=" + roll0 + " luck=" + luck0 + " => respawn=" + _bleedoutDecisionIsRespawn)
                endif
                freeRespawn = _bleedoutDecisionIsRespawn

                if freeRespawn
                    ; Respawn chosen: start respawn quest ASAP and let it handle the revive.
                    if _respawnQuest && !_respawnQuest.IsRunning()
                        _respawnQuest.Start()
                    endif
                    _pendingDisableRespawn = True
                    _pendingLuckResetAfterRespawn = True
                    _pendingRespawnMenu = True
                    _respawnMenuArmed = False
                else
                    ; True death chosen: stop respawn quest immediately, then allow a short bleedout window before forcing a real death.
                    if _respawnQuest && _respawnQuest.IsRunning()
                        _respawnQuest.Stop()
                    endif
                    _pendingDisableRespawn = False

                    ; True death chosen: immediately reset Luck/Cooldown to 0 per design.
                    if _disableLuckSystem == 0
                        ResetLuck(player, guid0)
                        PersistSetInt(player, GetKey(luckResetKind, guid0), 1, True) ; post-death
                    else
                        ResetCooldown(player, guid0)
                    endif

                    if _pendingTrueDeathAt <= 0.0
                        _pendingTrueDeathAt = nowRT + 5.0
                    endif

                    ; Arm post-death quit sequence (wait for death menu, then quit).
                    _pendingQuitArmed = True
                    _pendingQuitMenuAt = 0.0
                endif
            elseif IsCooldownModeActive()
                ; Cooldown mode: no probability. Respawn only if cooldown is ready.
                if !_bleedoutDecisionMade
                    _bleedoutDecisionMade = True
                    _bleedoutDecisionIsRespawn = IsCooldownReady(player, guid0)
                    LogMsg(LOG_INFO(), "BLEEDOUT: cooldown ready=" + _bleedoutDecisionIsRespawn)
                endif
                freeRespawn = _bleedoutDecisionIsRespawn

                if freeRespawn
                    if _respawnQuest && !_respawnQuest.IsRunning()
                        _respawnQuest.Start()
                    endif
                    _pendingDisableRespawn = True
                    _pendingCooldownResetAfterRespawn = True
                    _pendingRespawnMenu = True
                    _respawnMenuArmed = False
                else
                    ; True death chosen: stop respawn quest immediately, then allow a short bleedout window before forcing a real death.
                    if _respawnQuest && _respawnQuest.IsRunning()
                        _respawnQuest.Stop()
                    endif
                    _pendingDisableRespawn = False

                    ; True death chosen: immediately reset cooldown to 0 per design.
                    ResetCooldown(player, guid0)

                    if _pendingTrueDeathAt <= 0.0
                        _pendingTrueDeathAt = nowRT + 5.0
                    endif

                    ; Arm post-death quit sequence (wait for death menu, then quit).
                    _pendingQuitArmed = True
                    _pendingQuitMenuAt = 0.0
                endif
            else
                ; No luck/cooldown mode: respawn unavailable.
                freeRespawn = False
            endif

            ; If a respawn path is chosen and the intro poem hasn't been shown yet, schedule it for ~6s after entering bleedout.
            if freeRespawn
                Int ironIntroShown0 = PersistGetInt(player, GetKey(ironIntroShown, guid0), 0)
                if ironIntroShown0 == 0
                    _pendingIronIntro = True
                    _ironIntroAt = nowRT + 6.0
                endif
            endif

            ; If we entered bleedout but respawn is unavailable (no luck/cooldown mode), our state drifted.
            ; Force a real death (non-essential) so Skyrim fires OnDying and DSR can handle souls.
            if !freeRespawn && !IsLuckActive() && !IsCooldownModeActive()
                LogMsg(LOG_INFO(), "BLEEDOUT: entered bleedout but no respawn available; forcing non-essential death to avoid soft-lock")
                if _respawnQuest && _respawnQuest.IsRunning()
                    _respawnQuest.Stop()
                endif
                player.GetActorBase().SetEssential(False)

                if !_bleedoutForcedKill
                    _bleedoutForcedKill = True
                    LogMsg(LOG_INFO(), "BLEEDOUT: forcing player.Kill() to re-enter proper death pipeline (DSR/death)")
                    _pendingIronIntro = False
                    _ironIntroAt = 0.0
                    player.Kill()

                    ; Latch bleedout state before returning so we don't re-trigger "entered bleedout" every tick.
                    _wasBleedingOut = True
                    QueueUpdate(FastPollSeconds)
                    return True
                endif
            endif
        endif
    endif

    ; If a iron intro is scheduled, fire it only while still in bleedout and only once.
    if nowBleed && _pendingIronIntro && nowRT >= _ironIntroAt
        String guidP = GetTickGuid(player)
        if guidP != ""
            if IsRespawnEnabled()
                Int ironIntroShownP = PersistGetInt(player, GetKey(ironIntroShown, guidP), 0)
                if ironIntroShownP == 0
                    OpenTimedMessageSWF(SwfNoBonus("1ironintro"), 15.0)
                    PersistSetInt(player, GetKey(ironIntroShown, guidP), 1, True)
                endif
            endif
        endif
        _pendingIronIntro = False
        _ironIntroAt = 0.0
    endif

    ; Pending true death (Luck loss): after a short bleedout delay, force a real death so the death menu can play.
    if nowBleed && _pendingTrueDeathAt > 0.0 && nowRT >= _pendingTrueDeathAt
        LogMsg(LOG_INFO(), "BLEEDOUT: luck chose true death; forcing real death after delay")
        _pendingTrueDeathAt = 0.0
        _pendingIronIntro = False
        _ironIntroAt = 0.0

        ; Ensure respawn quest is not running so we get the normal death pipeline/menu.
        if _respawnQuest && _respawnQuest.IsRunning()
            _respawnQuest.Stop()
        endif

        ; Drop essential protection and kill to enter proper death pipeline.
        player.GetActorBase().SetEssential(False)

        if !_bleedoutForcedKill
            _bleedoutForcedKill = True
            player.Kill()

            ; Latch bleedout state before returning so we don't re-trigger "entered bleedout" every tick.
            _wasBleedingOut = True
            QueueUpdate(FastPollSeconds)
            return True
        endif
    endif

    ; After forcing a true death from bleedout, wait for the death menu and quit after ~4 seconds in-menu.
    ; FinalizeAndQuitMainMenu() adds an additional 1s safety wait before quitting.
    if _pendingQuitArmed
        if Utility.IsInMenuMode()
            if _pendingQuitMenuAt <= 0.0
                _pendingQuitMenuAt = nowRT
            elseif (nowRT - _pendingQuitMenuAt) >= 4.0
                FinalizeAndQuitMainMenu()
                return True
            endif
        endif
    endif

    ; Exiting bleedout
    if !nowBleed && _wasBleedingOut && _bleedoutArmed
        LogMsg(LOG_INFO(), "BLEEDOUT: exited bleedout (respawn completed)")
        _bleedoutArmed = False

        ; Cancel any scheduled poem if bleedout ended before it fired.
        _pendingIronIntro = False
        _ironIntroAt = 0.0

        ; If respawn completed, ensure the Respawn quest gets stopped (if it is still running)
        ; and restore correct protection policy.
        if IsRespawnEnabled()
            if _respawnQuest && _respawnQuest.IsRunning()
                _pendingDisableRespawn = True
            endif
            String guidExit = GetTickGuid(player)
            if guidExit != ""
                UpdatePlayerProtectionState(player, guidExit)
            endif
        endif

        ; Clear any pending true-death/quit timers (safety).
        _pendingTrueDeathAt = 0.0
        _pendingQuitArmed = False
        _pendingQuitMenuAt = 0.0

        ; Clear decision latch for the next bleedout episode.
        _bleedoutDecisionMade = False
        _bleedoutDecisionIsRespawn = False

        _bleedoutForcedKill = False
        _deathEventLocked = False
    endif

    _wasBleedingOut = nowBleed
    return False
EndFunction

; Ensures the player's protection state is consistent with DSR vs respawn requirements.
; Policy (when respawn system is active):
; - If a dragon soul is available and DSR is enabled: keep the player NON-essential so DSR OnDying can fire.
; - If no dragon soul is available: keep the player essential so bleedout-based logic can run.
; Outside respawn-active contexts, we keep the player non-essential (perm-death behavior).
Function UpdatePlayerProtectionState(Actor player, String guid)
    if !player || guid == ""
        return
    endif

    ; Don't toggle protection while dead/bleeding out (avoid edge cases during death handling).
    if player.IsDead() || player.IsBleedingOut()
        return
    endif

    ; If respawn is not active, do not force essential protection here.
    if !IsRespawnEnabled()
        if player.IsEssential()
            player.GetActorBase().SetEssential(False)
        endif
        return
    endif

    ; Respawn is active: choose protection based on whether DSR can actually consume a soul.
    if _disableDragonSoulRevive
        if !player.IsEssential()
            player.GetActorBase().SetEssential(True)
        endif
        return
    endif

    Int soulsNow = player.GetActorValue("DragonSouls") as Int
    if soulsNow > 0
        if player.IsEssential()
            player.GetActorBase().SetEssential(False)
        endif
    else
        if !player.IsEssential()
            player.GetActorBase().SetEssential(True)
        endif
    endif
EndFunction

Function TrueDeathAndQuit(Actor player)
	if !player
		return
	endif

	; Identity (GUID required)
	String name = IronSoulNative.GetPlayerName()
	String guid = EnsureGuid(player)
	if guid == ""
		LogMsg(LOG_ERR(), "TRUE DEATH: missing GUID; exiting without logging state")
		Debug.MessageBox("Could not determine character identity. Exiting to prevent state corruption.")
		FinalizeAndQuit()
		return
	endif

	; Commit: death + cycle reset
	; Record the death in authoritative stores (MainData immediate flush with co-save backup).
	IncrementTrueDeath(player, guid, name)

	; Read deaths AFTER increment so first true death is deathsNow == 1.
	Int deathsNow = PersistGetInt(player, GetKey(deathCount, guid), 0)

	Utility.Wait(1.0)

	; Optional: iron intro (first true death, respawn disabled)
	if !IsRespawnEnabled()
		Int ironIntroShownTD = PersistGetInt(player, GetKey(ironIntroShown, guid), 0)
		if deathsNow == 1 && ironIntroShownTD == 0
			OpenTimedMessageSWF(SwfNoBonus("1ironintro"), 15.0)
			PersistSetInt(player, GetKey(ironIntroShown, guid), 1, True)
		endif
	endif

	; Ensure the player is not essential (kept as-is)
	player.GetActorBase().SetEssential(False)

	; Cached state for tier-aware menus
	; Soul tier: 0=Iron, 1=Silver, 2=Gold, 3=Ebon, 4=Platinum
	Int soulTierTD = PersistGetInt(player, GetKey(soulTierIndex, guid), 0)

	; Defiant gating
	Int defFeat = 0
	Int defActive = 0
	if !_disableDefiantSoulFeat
		defFeat = PersistGetInt(player, GetKey(defiantFeatUnlocked, guid), 0)
		defActive = PersistGetInt(player, GetKey(defiantActivated, guid), 0)
	endif

	; Defiant transition sequence (10th death, feat earned, not yet activated)
	; 1) Show normal tier permadeath screen (3s)
	; 2) Show tier-contextual Defiant transition (3s)
	; 3) Show Defiant intro (10s)
	; 4) Quit
	if deathsNow == IRON_SOUL_MAX_LIVES && defFeat == 1 && defActive != 1
		; Commit Defiant activation FIRST so quitting/crashing during the UI sequence cannot lose it.
		PersistSetInt(player, GetKey(defiantActivated, guid), 1, True)

		; Defiant overrides SoulBonus: strip all SoulBonus abilities immediately
		SyncSoulBonusAbility(player, guid)
		IronSoulNative.DataFlushNow()

		; Journal: Defiant activation milestone (written/queued; no periodic writes).
		JournalLogEvent("You refuse Sovngarde and rise again. Defiant Soul awakened. Death limit is now 100.")

		; Continuous on-screen sequence: 3s permadeath tier -> 3s transition -> 10s intro.
		PlayDefiantTransitionMessageSequenceSWF(soulTierTD)

		FinalizeAndQuit()
		return
	endif

	; Caps + mode flags
	Int hardCap = IRON_SOUL_MAX_LIVES
	if defActive == 1 && deathsNow >= IRON_SOUL_MAX_LIVES
		hardCap = DEFIANT_SOUL_MAX_LIVES
	endif

	Bool isDefiantMenus = (defActive == 1)
	Bool endlessMenus = IsEndlessActive(deathsNow, defActive)
	Bool quitToMainMenu = False

	; Journal: normal defeat (non-cap). Special cases (Defiant transition / permadeath) are handled elsewhere.
	if !_disableCharacterJournalLog
		if !endlessMenus && deathsNow != hardCap
			Int capJ = IRON_SOUL_MAX_LIVES
			if defActive == 1 && deathsNow >= IRON_SOUL_MAX_LIVES
				capJ = DEFIANT_SOUL_MAX_LIVES
			endif
			JournalLogEvent("Defeated. Deaths: " + deathsNow + " / " + capJ + ".")
		endif
	endif

	; Messaging + enforcement
	if endlessMenus
		; Endless Mode (CHIM):
		; - Show permadeath screen only at the exact cap (10 or 100).
		; - After the cap, Endless deaths use a blocking message box and a hard quit.
		if deathsNow == hardCap
            JournalLogEvent("No strength remains to rise. Sovngarde claims the fallen. Deaths: " + deathsNow + " / " + hardCap)
			OpenTimedMessageSWF(ResolvePermadeathMenu(soulTierTD, isDefiantMenus), 10.0)
		else
			if !_disableDeathMessage
				Debug.MessageBox("SOVNGARDE CALLS\n\nDeaths: " + deathsNow + " / ???")
			endif
		endif
	else
		if deathsNow == hardCap
			; True permadeath scenario:
			; - 10th death without Defiant
			; - 100th death with Defiant active
			JournalLogEvent("No strength remains to rise. Sovngarde claims the fallen. Deaths: " + deathsNow + " / " + hardCap)
			OpenTimedMessageSWF(ResolvePermadeathMenu(soulTierTD, isDefiantMenus), 10.0)
			quitToMainMenu = True
		else
			if !_disableDeathMessage
				OpenTimedMessageSWF(ResolveDeathMessageMenu(soulTierTD, deathsNow, isDefiantMenus), 4.0)
			endif
		endif
	endif

	if quitToMainMenu
		FinalizeAndQuitMainMenu()
	else
		FinalizeAndQuit()
	endif
EndFunction

Function IncrementTrueDeath(Actor player, String guid, String displayName)
	if !player || guid == ""
		return
	endif

	int deaths = PersistGetInt(player, GetKey(deathCount, guid), 0) + 1
	PersistSetInt(player, GetKey(deathCount, guid), deaths, True)

	LogMsg(LOG_INFO(), "IncrementTrueDeath: GUID=" + guid + " deaths=" + deaths)
    IronSoulNative.DataFlushNow()
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
    UnregisterForUpdate()

    Utility.Wait(1.0)
    Game.QuitToMainMenu()
EndFunction

; Returns the death cap used for load enforcement and notifications:
;  - Iron Soul: 10
;  - Defiant Soul (activated or pending activation): 100
;  - Endless: effectively unbounded (only if CHIM opt-in is enabled and deaths have reached the Endless threshold)
Int Function GetEffectiveMaxLives(Actor player, String guid, Int deathsNow)
    if !player || guid == ""
        return IRON_SOUL_MAX_LIVES
    endif
    Int defActive  = PersistGetInt(player, GetKey(defiantActivated, guid), 0)

    if _disableDefiantSoulFeat
        defActive = 0
    endif

    ; Endless opt-in is controlled by Endless.CHIM (see LoadConfig()).
    ; If Defiant is not enabled, Endless begins once deaths reach the Iron cap.
    ; If Defiant is active, Endless begins once deaths reach the Defiant cap.
    Int endlessStart = IRON_SOUL_MAX_LIVES
    if defActive == 1
        endlessStart = DEFIANT_SOUL_MAX_LIVES
    endif

    ; Endless is an explicit opt-in via IronSoul.ini (plugin-based config) (Endless.CHIM = 1 or "1").
    ; With CHIM enabled, once the relevant cap is reached, max lives becomes effectively unbounded.
    if IsEndlessActive(deathsNow, defActive)
        return 2147483647
    endif

    if defActive == 1
        return DEFIANT_SOUL_MAX_LIVES
    endif

    return IRON_SOUL_MAX_LIVES
EndFunction


; ===========================
; --- Respawn Integration ---
; ===========================
;
; Respawn - Death Overhaul is an optional dependency.
; If Config.DisableRespawn=1 or the quest cannot be resolved via GetFormFromFile,
; Respawn integration is treated as disabled (fail-closed).
;
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
        LogMsg(LOG_INFO(), "Respawn quest resolved: running=" + q.IsRunning())

    else
        ; Fail-closed: if we cannot resolve the quest, do not attempt integration.
        _respawnAvailable = False
        _disableRespawn = True
        LogMsg(LOG_INFO(), "Respawn quest not found; treating Respawn integration as disabled")
    endif
EndFunction

Bool Function IsRespawnEnabled()
    return (!_disableRespawn) && _respawnAvailable && (_respawnQuest != None)
EndFunction

Bool Function HandleDisableRespawn(Actor player)
    ; Job B: stop _respawnQuest after respawn finishes
    if !IsRespawnEnabled()
        _pendingDisableRespawn = False
        return False
    endif
    if _pendingDisableRespawn
        LogMsg(LOG_DBG(), "JOB B: pending disable respawn. dead=" + player.IsDead() + " bleed=" + player.IsBleedingOut())
        ; If the player is truly dead (death screen / reload), respawn did not complete; stop polling.
        if player.IsDead() && !player.IsBleedingOut()
            LogMsg(LOG_INFO(), "JOB B: player truly dead; clearing pending disable-respawn state")
            _pendingDisableRespawn = False
            _pendingRespawnMenu = False
            _respawnMenuArmed = False
            _deathEventLocked = False
            _bleedoutForcedKill = False
            return False
        endif
        if !player.IsBleedingOut() && !player.IsDead()
            if _respawnQuest && _respawnQuest.IsRunning()
                LogMsg(LOG_INFO(), "JOB B: stopping _respawnQuest")
                _respawnQuest.Stop()
            else
                LogMsg(LOG_INFO(), "JOB B: _respawnQuest not running/None")
            endif

            ; Apply post-respawn resets (Luck -> 0 or Cooldown -> 0), then restore correct protection policy.
            String guidB = GetTickGuid(player)
            if guidB != ""
                if _pendingLuckResetAfterRespawn
                    _pendingLuckResetAfterRespawn = False
                    ResetLuck(player, guidB)
                    PersistSetInt(player, GetKey(luckResetKind, guidB), 2, True) ; post-respawn
                endif
                if _pendingCooldownResetAfterRespawn
                    _pendingCooldownResetAfterRespawn = False
                    ResetCooldown(player, guidB)
                endif
                UpdatePlayerProtectionState(player, guidB)
            endif

            ; arm delayed warning AFTER respawn completes
            if _pendingRespawnMenu && !_respawnMenuArmed
                _respawnMenuArmed = True
                _respawnWarningAt = Utility.GetCurrentRealTime() + 4.0
            endif

            _pendingDisableRespawn = False
            _deathEventLocked = False
            _bleedoutForcedKill = False
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
    LogMsg(LOG_DBG(), "Cooldown: " + played + " / " + LUCK_REGEN_SECONDS)
EndFunction

Int Function GetLuckValue(Actor player, String guid)
    ; Returns the current luck value in [0..100].
    ; NOTE: Timing keys may be write-gated; prefer cached state when available for accurate rolls/notifications.
    if !player || guid == ""
        return 100
    endif
    if !IsLuckActive()
        return 100
    endif

    Int playedTok = 0

    if _luckCooldownLoaded && _luckCooldownGuid == guid
        playedTok = _luckCooldownPlayedTok
    else
        playedTok = PersistGetInt(player, GetKey(luckPlayedToken, guid), 0)
    endif

    if playedTok == 0
        return 100
    endif

    Int playedSec = DecodePlayed(playedTok)
    ; playedSec==0 means freshly reset -> luck 0. Negative is treated as invalid/uninitialized.
    if playedSec < 0
        return 100
    endif
    if playedSec == 0
        return 0
    endif

    Int luck = (playedSec * 100) / LUCK_REGEN_SECONDS
    if luck < 0
        luck = 0
    elseif luck > 100
        luck = 100
    endif
    return luck
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

    ; Reset threshold notifications for this regen cycle.
    ; Default to "post-respawn" for very-low flavour until a specific reset kind is set.
    PersistSetInt(player, GetKey(luckResetKind, guid), 2, True)
    PersistSetInt(player, GetKey(luckNotifiedTier, guid), 0, True)
EndFunction

Int Function LuckTier(Int luck)
    ; 0: 0-24, 1:25-49, 2:50-74, 3:75-99, 4:100
    if luck >= 100
        return 4
    elseif luck >= 75
        return 3
    elseif luck >= 50
        return 2
    elseif luck >= 25
        return 1
    endif
    return 0
EndFunction

String Function PickLuckReminderMessage(Int tier)
    ; Returns a reminder message for the given tier (1..4) based on LuckReminderNotificationMode.
    if tier <= 0
        return ""
    endif

    if _luckReminderNotificationMode == 1
        if tier == 1
            return "Your luck is returning."
        elseif tier == 2
            return "Your luck has improved."
        elseif tier == 3
            return "The odds favor you."
        endif
        return "You're feeling lucky."
    endif

    ; Flavour (mode 0)
    if tier == 4
        return "You're feeling lucky."
    endif

    Int r = Utility.RandomInt(1, 5)
    if tier == 1
        if r == 1
            return "You remain unsettled."
        elseif r == 2
            return "Unease lingers."
        elseif r == 3
            return "Caution tempers your steps."
        elseif r == 4
            return "You feel on edge."
        endif
        return "Doubt has not fully left you."
    elseif tier == 2
        if r == 1
            return "You feel steady again."
        elseif r == 2
            return "Your thoughts are clear."
        elseif r == 3
            return "You feel grounded."
        elseif r == 4
            return "Your footing is firm."
        endif
        return "You feel balanced once more."
    elseif tier == 3
        if r == 1
            return "Your confidence holds."
        elseif r == 2
            return "Your resolve carries you forward."
        elseif r == 3
            return "Your steps feel true."
        elseif r == 4
            return "The path ahead is clear."
        endif
        return "You move with purpose."
    endif

    return ""
EndFunction

String Function PickLuckLoadFlavour(Int luck, Int resetKind)
    ; Returns a flavour line for the 2nd load notification based on Luck.
    ; resetKind: 1=post-death, 2=post-respawn (used only for Luck 0-24).
    Int r = Utility.RandomInt(0, 4)

    if luck >= 75
        ; 75-99 (High)
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

    elseif luck >= 50
        ; 50-74 (Stable)
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

    elseif luck >= 25
        ; 25-49 (Low)
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
    endif

    ; 0-24 (Very Low) - choose pool by resetKind
    if resetKind == 1
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
    endif

    ; Default: post-respawn
    if r == 0
        return "You are still shaken from your recent trial."
    elseif r == 1
        return "The ordeal still weighs heavily on you."
    elseif r == 2
        return "Your breath has steadied, but not your thoughts."
    elseif r == 3
        return "You have not yet recovered from what nearly ended you."
    endif
    return "Your nerves have not fully settled."
EndFunction

Function MaybeNotifyLuckThreshold(Actor player, String guid, Int luck)
    ; Fires a one-time notification when luck reaches a new threshold: 25, 50, 75, 100.
    if !player || guid == ""
        return
    endif
    if !IsLuckActive()
        return
    endif
    if _luckReminderNotificationMode == 2
        return
    endif

    Int tierNow = LuckTier(luck)
    if tierNow <= 0
        return
    endif

    Int tierPrev = PersistGetInt(player, GetKey(luckNotifiedTier, guid), 0)
    if tierNow <= tierPrev
        return
    endif

    PersistSetInt(player, GetKey(luckNotifiedTier, guid), tierNow, True)

    String msg = PickLuckReminderMessage(tierNow)
    if msg != ""
        Debug.Notification(msg)
    endif
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
	PersistSetInt(player, GetKey(journalOpenerLogged, guid), 1, True)
EndFunction

Function JournalLogEvent(String eventText, Bool urgent = False)
	; Primary journal entry writer (SKSE-backed).
	; - Computes Day X from the persisted journal start day (stored once per GUID).
	; - Ensures the opener prints once per GUID before the first event line.
	; - Sends only: "Day X: <Event text...>" to IronSoulNative.LogJournalEntry().
	; - The SKSE plugin prepends "<CharacterName> " automatically.
	if _disableCharacterJournalLog
		return
	endif
	if eventText == ""
		return
	endif

	Actor player = Game.GetPlayer()
	if !player
		return
	endif

	String guid = GetTickGuid(player)
	if guid == ""
		return
	endif

	Int startDay = JournalEnsureStartDay(player, guid)
	JournalEnsureOpenerLogged(player, guid)

	Int dayIdx = 1
	if startDay != -1
		Int nowDay = Utility.GetCurrentGameTime() as Int
		dayIdx = (nowDay - startDay) + 1
	endif
	; Day 1 minimum (no Day 0)
	if dayIdx < 1
		dayIdx = 1
	endif

	String line = "Day " + dayIdx + ": " + eventText
	IronSoulNative.LogJournalEntry(line)

	; urgent preserved for call-site intent (e.g., permadeath lines).
	; If you later want "urgent" to force an auth store flush, implement it here.
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

Int Function JournalDayIndex(Actor player, String guid)
	if _disableCharacterJournalLog
		return 1
	endif
	Int startDay = JournalEnsureStartDay(player, guid)
	if startDay == -1
		return 1
	endif
	Int nowDay = Utility.GetCurrentGameTime() as Int
	Int idx = (nowDay - startDay) + 1
	if idx < 1
		idx = 1
	endif
	return idx
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
;   - Binary DataStore (MainData + MirrorData) with self-heal + periodic/on-save flush
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
        EnsureGuidMarker(guid) ; ensure collision marker + global index
        return guid
    endif

    ; 2) Identity must be ready (RaceMenu / very early loads can return empty).
    String pn = IronSoulNative.GetPlayerName()
    if pn == ""
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
    IronSoulNative.DataFlushNow()

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

	IronSoulNative.DataSetInt("G.U." + guid, 1)
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

String Function GetCosaveGuid(Actor player)
	if !player
		return ""
	endif
	return StorageUtil.GetStringValue(player, characterGuid, "")
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
	; Recovery rule:
	;  - Require >= 3 / 4 matches across:
	;      1) Name match (I.N:<guid>)
	;      2) RaceFormID match (I.R:<guid>)
	;      3) Level within +/- _idLevelTolerance of last-seen level (I.L:<guid>)
	;      4) Game day within +/- _idDayTolerance of last-seen day (I.D:<guid>)
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

		; 1) Name
		if nSaved != "" && pn == nSaved
			matches += 1
		endif

		; 2) Race
		if rSaved >= 0 && ridNow == rSaved
			matches += 1
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
		if matches > bestMatches
			bestGuid = cand
			bestMatches = matches
			bestDayDelta = dT
			bestLvlDelta = dL
		elseif matches == bestMatches && matches > 0
			if dT < bestDayDelta || (dT == bestDayDelta && dL < bestLvlDelta)
				bestGuid = cand
				bestMatches = matches
				bestDayDelta = dT
				bestLvlDelta = dL
			endif
		endif
		endif
	EndWhile

	if bestMatches < 3 || bestGuid == ""
		return ""
	endif

	; Restore authoritative GUID back to co-save directly (do NOT use Persist helpers).
	StorageUtil.SetStringValue(player, characterGuid, bestGuid)
	EnsureGuidMarker(bestGuid)
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
	;  - Only overwrite co-save if we find a >= 3/4 identity snapshot match (same rule as missing co-save recovery).
	;
	; Returns:
	;  - The GUID you should treat as authoritative for this session (may equal cosaveGuid).
	; Side effects:
	;  - If a strong match is found, overwrites co-save to the recovered GUID and ensures marker/index.

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

	Int lvlNow = player.GetLevel()
	if lvlNow <= 1
		; New games naturally start at level 1. Do not "recover".
		EnsureGuidMarker(cosaveGuid)
		return cosaveGuid
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

			; 1) Name
			if nSaved != "" && pn == nSaved
				matches += 1
			endif

			; 2) Race
			if rSaved >= 0 && ridNow == rSaved
				matches += 1
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
			if matches > bestMatches
				bestGuid = cand
				bestMatches = matches
				bestDayDelta = dT
				bestLvlDelta = dL
			elseif matches == bestMatches && matches > 0
				if dT < bestDayDelta || (dT == bestDayDelta && dL < bestLvlDelta)
					bestGuid = cand
					bestMatches = matches
					bestDayDelta = dT
					bestLvlDelta = dL
				endif
			endif
		endif
	EndWhile

	; Require strong match to overwrite co-save.
	if bestMatches < 3 || bestGuid == ""
		; Inconclusive: keep co-save as-is (do NOT bless it here).
		; Caller can decide whether to accept-and-heal or to log / prompt.
		return cosaveGuid
	endif

	; Restore authoritative GUID back to co-save directly (do NOT use Persist helpers).
	StorageUtil.SetStringValue(player, characterGuid, bestGuid)
	EnsureGuidMarker(bestGuid)

	; Flush ASAP so we don't bounce between GUIDs on crash / early exit.
	IronSoulNative.DataFlushNow()

	LogMsg(LOG_INFO(), "GUID tamper recovery: co-save '" + cosaveGuid + "' -> restored '" + bestGuid + "' (" + bestMatches + "/4 match)")

	return bestGuid
EndFunction

; Validate player execution context (actor presence, GUID identity, and transient state)
Bool Function EnsureTransientPlayerState(Actor player, String guid)
    ; Player missing: defensive reset, no identity changes.
    if !player
        LogMsg(LOG_ERR(), "OnUpdate: player None; clearing transient state")

        ResetTransientJobsAndCaches()

        ; Also invalidate tick guid cache (no actor)
        _tickGuid = ""
        _tickGuidValid = False

        QueueUpdate(StandardPollSeconds)
        return True
    endif

    ; Hot-path: if we already know the session guid and tick guid is valid + matches, do nothing.
    if _sessionGuid != "" && _tickGuidValid && _tickGuid == _sessionGuid
        return False
    endif

    ; Acquire guid if caller didn't provide one.
    String g = guid
    if g == ""
        if _tickGuidValid
            g = _tickGuid
        else
            g = EnsureGuid(player)
            _tickGuid = g
            _tickGuidValid = (g != "")
        endif
    else
        ; Caller provided guid: update per-tick cache.
        _tickGuid = g
        _tickGuidValid = (g != "")
    endif

    ; GUID boundary: new character detected.
    if g != "" && g != _sessionGuid
        _sessionGuid = g

        ResetTransientJobsAndCaches()

        ; NOTE: keep _tickGuid cache set to g (already done above)
        QueueUpdate(StandardPollSeconds)
        return False
    endif

    return False
EndFunction

Function ResetTransientJobsAndCaches()
    _featsLastSeenInit = False

    _pendingDisableRespawn = False
    _pendingDeathCheck = False
    _pendingLoadMessage = False
    _pendingIronIntro = False
    _pendingFeats = False
    _pendingDeathResync = False

    _ironIntroAt = 0.0
    _deathCheckAt = 0.0
    _deathResyncAt = 0.0
    _featsAt = 0.0
    _loadMessageAt = 0.0

    ; Heartbeat / cadence timers are transient (GetCurrentRealTime can reset across reloads).
    _nextHeartbeatAt = 0.0
    _nextFeatsSoulCheckAt = 0.0

    ; Pending job guard timers
    _pendingDeathCheckStartedAt = 0.0
    _pendingDisableRespawnStartedAt = 0.0
    _pendingLoadMessageStartedAt = 0.0

    _bleedoutForcedKill = False
    _pendingTrueDeathAt = 0.0
    _pendingQuitMenuAt = 0.0
    _pendingQuitArmed = False
    _bleedoutDecisionMade = False
    _bleedoutDecisionIsRespawn = False
    _pendingLuckResetAfterRespawn = False
    _pendingCooldownResetAfterRespawn = False
    _wasBleedingOut = False
    _bleedoutArmed = False

    _pendingTrueDeathAt = 0.0
    _bleedoutDecisionMade = False
    _bleedoutDecisionIsRespawn = False
    _deathEventLocked = False

    _pendingRespawnMenu = False
    _respawnMenuArmed = False

    ; Luck/Cooldown session cache is transient; reset to avoid stale deltas across reloads.
    _luckCooldownLoaded = False
    _luckCooldownDirty = False
    _luckCooldownGuid = ""
    _luckCooldownLastSec = 0
    _luckCooldownPlayedTok = 0
    _luckCooldownNextPersistAt = 0

    _soulBonusAppliedTier = -1
EndFunction


; ==================
; --- Soul Feats ---
; ==================
;
; Tier state: 0=Iron, 1=Silver, 2=Gold, 3=Ebon, 4=Platinum. Highest eligible tier always takes priority.
; This value is stored in MainData (authoritative) and backed up to co-save via an obfuscated key.
; Per-character unlocks based on confirmed Dragon Souls obtained or boss kills, and death count. Display one-time messages on unlock.
; Future: Soul Bonus tiers (Iron 5% / Silver 10% / Gold 15% / Ebon 20% / Platinum 30%) will be applied via a separate ability/effect system.
; All Soul Bonuses are lost once Defiant activates (at the end of the 10th-death Defiant transition sequence).

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

    if !IsRespawnEnabled()
        return
    endif

    if Utility.IsInMenuMode() || player.IsDead() || player.IsBleedingOut()
        return
    endif

    Int deaths = PersistGetInt(player, GetKey(deathCount, guid), 0)
    Int soulsObtained = PersistGetInt(player, GetKey(dragonSoulsTrusted, guid), 0)

    Float nowRT = Utility.GetCurrentRealTime()

    ; Defiant Feat: 1 Dragon Soul obtained with under 10 deaths.
    if !_disableDefiantSoulFeat
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
        Int desiredTier = 0
        if deaths < IRON_SOUL_MAX_LIVES
            ; Determine the highest eligible tier at this moment (tiers may upgrade upward over time; Silver -> Gold allowed).
            ; Evaluation priority: Platinum > Ebon > Gold > Silver.
            ; Platinum variant credit priority: Molag Bal (Vigilant) > Miraak (Dragonborn).
            Int molagFlag = PersistGetInt(player, GetKey(molagBalKilled, guid), 0)
            Int miraakFlag = PersistGetInt(player, GetKey(miraakKilled, guid), 0)
            Bool molagKilled = (molagFlag == 1)
            Bool miraakKilledBool = (miraakFlag == 1)
            if molagKilled || miraakKilledBool
                desiredTier = 4 ; Platinum

            else
                Int alduinFlag = PersistGetInt(player, GetKey(alduinKilled, guid), 0)
                Int harkonFlag = PersistGetInt(player, GetKey(harkonKilled, guid), 0)
                Bool alduinKilledBool = (alduinFlag == 1)
                Bool harkonKilledBool = (harkonFlag == 1)
                if alduinKilledBool || harkonKilledBool
                    desiredTier = 3 ; Ebon

                elseif soulsObtained >= 20
                    desiredTier = 2 ; Gold

                elseif soulsObtained >= 10
                    desiredTier = 1 ; Silver
                endif
            endif
        endif

        Int curTier = PersistGetInt(player, GetKey(soulTierIndex, guid), 0)

        if desiredTier > curTier
            _pendingFeats = True
            if _featsAt < (nowRT + 4.0)
                _featsAt = nowRT + 4.0
            endif
            return
        endif

        ; Also schedule one-time tier messages if a tier was previously earned but its message wasn't shown yet.
        if curTier == 4
            Int shownA = PersistGetInt(player, GetKey(tierMsgShownPlatinum, guid), 0)
            if shownA != 1
                _pendingFeats = True
                if _featsAt < (nowRT + 4.0)
                    _featsAt = nowRT + 4.0
                endif
                return
            endif

        elseif curTier == 3
            Int shownP = PersistGetInt(player, GetKey(tierMsgShownEbon, guid), 0)
            if shownP != 1
                _pendingFeats = True
                if _featsAt < (nowRT + 4.0)
                    _featsAt = nowRT + 4.0
                endif
                return
            endif

        elseif curTier == 2
            Int shownG = PersistGetInt(player, GetKey(tierMsgShownGold, guid), 0)
            if shownG != 1
                _pendingFeats = True
                if _featsAt < (nowRT + 4.0)
                    _featsAt = nowRT + 4.0
                endif
                return
            endif

        elseif curTier == 1
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
    Int soulsObtained = PersistGetInt(player, GetKey(dragonSoulsTrusted, guid), 0)

    ; ---- Defiant Feat (eligibility only; activation occurs at the end of the 10th-death transition sequence) ----
    if !_disableDefiantSoulFeat
        Bool defiantEligible = (soulsObtained >= 1 && deaths < IRON_SOUL_MAX_LIVES)
        Int defFeat = PersistGetInt(player, GetKey(defiantFeatUnlocked, guid), 0)
        if defiantEligible && defFeat != 1
            PersistSetInt(player, GetKey(defiantFeatUnlocked, guid), 1, True)
            JournalLogEvent("Soul Feat Unlocked: Defiant Soul")
            OpenTimedMessageSWF(ResolveDefiantFeatUnlockMenu(), 10.0)
            return
        endif
    endif

    ; ---- Soul Feats (prestige tiers; do not affect death lifecycle) ----
    ; Option A: grant only the highest eligible tier.
    if !_disableSoulFeats
        Int desiredTier = 0
        if deaths < IRON_SOUL_MAX_LIVES
            ; Tier eligibility (highest wins): Platinum > Ebon > Gold > Silver.
            ; Platinum variant credit priority: Molag Bal (Vigilant) > Miraak (Dragonborn).
            Int molagFlag = PersistGetInt(player, GetKey(molagBalKilled, guid), 0)
            Int miraakFlag = PersistGetInt(player, GetKey(miraakKilled, guid), 0)
            Bool molagKilled = (molagFlag == 1)
            Bool miraakKilledBool = (miraakFlag == 1)
            if molagKilled || miraakKilledBool
                desiredTier = 4 ; Platinum

            else
                Int alduinFlag = PersistGetInt(player, GetKey(alduinKilled, guid), 0)
                Int harkonFlag = PersistGetInt(player, GetKey(harkonKilled, guid), 0)
                Bool alduinKilledBool = (alduinFlag == 1)
                Bool harkonKilledBool = (harkonFlag == 1)
                if alduinKilledBool || harkonKilledBool
                    desiredTier = 3 ; Ebon

                elseif soulsObtained >= 20
                    desiredTier = 2 ; Gold

                elseif soulsObtained >= 10
                    desiredTier = 1 ; Silver
                endif
            endif
        endif

        Int curTier = PersistGetInt(player, GetKey(soulTierIndex, guid), 0)

        if desiredTier > curTier
            PersistSetInt(player, GetKey(soulTierIndex, guid), desiredTier, True)

        if desiredTier == 4
            Int molagFlagJ = PersistGetInt(player, GetKey(molagBalKilled, guid), 0)
            Int miraakFlagJ = PersistGetInt(player, GetKey(miraakKilled, guid), 0)
            if molagFlagJ == 1
                JournalLogEvent("Molag Bal Defeated: Soul Feat Unlocked: Platinum Soul")
            elseif miraakFlagJ == 1
                JournalLogEvent("Miraak Defeated: Soul Feat Unlocked: Platinum Soul")
            else
                JournalLogEvent("Soul Feat Unlocked: Platinum Soul")
            endif
        
        elseif desiredTier == 3
            Int alduinFlagJ = PersistGetInt(player, GetKey(alduinKilled, guid), 0)
            Int harkonFlagJ = PersistGetInt(player, GetKey(harkonKilled, guid), 0)
            if alduinFlagJ == 1
                JournalLogEvent("Alduin Defeated: Soul Feat Unlocked: Ebon Soul")
            elseif harkonFlagJ == 1
                JournalLogEvent("Harkon Defeated: Soul Feat Unlocked: Ebon Soul")
            else
                JournalLogEvent("Soul Feat Unlocked: Ebon Soul")
            endif
        
        elseif desiredTier == 2
            JournalLogEvent("Soul Feat Unlocked: Gilded Soul")
        
        elseif desiredTier == 1
            JournalLogEvent("Soul Feat Unlocked: Silver Soul")
        endif
            curTier = desiredTier
            ; SoulBonus sync only when tier changes
            SyncSoulBonusAbility(player, guid)
        endif

        ; One-time tier messages (separate from tier int so we never spam messages on load).
        if curTier == 4
            Int shownA = PersistGetInt(player, GetKey(tierMsgShownPlatinum, guid), 0)
            if shownA != 1
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

                String menuP = "5platinumfeatunlockmiraak"
                if platVar == 1
                    menuP = "5platinumfeatunlockmolagbal"
                endif
                OpenTimedMessageSWF(SwfNoBonus(menuP), 10.0)
                return
            endif

        elseif curTier == 3
            Int shownP = PersistGetInt(player, GetKey(tierMsgShownEbon, guid), 0)
            if shownP != 1
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

                String menuE = "4ebonfeatunlockharkon"
                if ebonVar == 1
                    menuE = "4ebonfeatunlockalduin"
                endif
                OpenTimedMessageSWF(SwfNoBonus(menuE), 10.0)
                return
            endif

        elseif curTier == 2
            Int shownG = PersistGetInt(player, GetKey(tierMsgShownGold, guid), 0)
            if shownG != 1
                PersistSetInt(player, GetKey(tierMsgShownGold, guid), 1, True)
                OpenTimedMessageSWF(SwfNoBonus("3goldfeatunlock"), 10.0)
                return
            endif

        elseif curTier == 1
            Int shownS = PersistGetInt(player, GetKey(tierMsgShownSilver, guid), 0)
            if shownS != 1
                PersistSetInt(player, GetKey(tierMsgShownSilver, guid), 1, True)
                OpenTimedMessageSWF(SwfNoBonus("2silverfeatunlock"), 10.0)
                return
            endif
        endif
    endif
EndFunction

String Function TierMenuPrefix(Int soulTier)
    ; Tier state: 0=Iron, 1=Silver, 2=Gold, 3=Ebon, 4=Platinum
    if soulTier == 0
        return "1iron"

    elseif soulTier == 1
        return "2silver"

    elseif soulTier == 2
        return "3gold"

    elseif soulTier == 3
        return "4ebon"

    elseif soulTier == 4
        return "5platinum"
    endif
    ; Fallback
    return "1iron"
EndFunction

String Function ResolveDeathMessageMenu(Int soulTier, Int deathsNow, Bool isDefiant)
    if isDefiant
        return "0defiantdeath" + deathsNow
    endif
    return TierMenuPrefix(soulTier) + "death" + deathsNow
EndFunction

String Function ResolvePermadeathMenu(Int soulTier, Bool isDefiant)
    if isDefiant
        return "0defiantpermadeath"
    endif
    return TierMenuPrefix(soulTier) + "permadeath"
EndFunction

String Function ResolveDSRMenu(Int soulTier, Bool isDefiant)
    if isDefiant
        return "0defiantdragonsoulrevive"
    endif
    return TierMenuPrefix(soulTier) + "dragonsoulrevive"
EndFunction

String Function ResolveRespawnMenu(Int soulTier, Bool isDefiant)
    if isDefiant
        return "0defiantrespawn"
    endif
    return TierMenuPrefix(soulTier) + "respawn"
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
    if tier <= 0
        return SoulBonus1Iron
    elseif tier == 1
        return SoulBonus2Silver
    elseif tier == 2
        return SoulBonus3Gold
    elseif tier == 3
        return SoulBonus4Ebon
    elseif tier >= 4
        return SoulBonus5Platinum
    endif
    return None
EndFunction

Function RemoveSoulBonusAll(Actor player)
    if !player
        return
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
    ; Tier mapping: 0=Iron, 1=Silver, 2=Gold, 3=Ebon, 4=Platinum.

    if !player
        return
    endif

    ; If SoulBonus is disabled or we're uninstalling, strip immediately even if GUID isn't ready yet.
    if _disableSoulBonus || _uninstallMode
        RemoveSoulBonusAll(player)
        _soulBonusAppliedTier = -1
        return
    endif

    ; We need a GUID to read persisted tier/Defiant state.
    if guid == ""
        return
    endif

    ; Defiant active hard-disables SoulBonus: strip all abilities and stop.
    Int defActiveSB = PersistGetInt(player, GetKey(defiantActivated, guid), 0)
    if defActiveSB == 1
        RemoveSoulBonusAll(player)
        _soulBonusAppliedTier = -1
        return
    endif

    Int tier = PersistGetInt(player, GetKey(soulTierIndex, guid), 0)
    if tier < 0
        tier = 0
    elseif tier > 4
        tier = 4
    endif

    Spell desired = GetSoulBonusSpellByTier(tier)

    ; Fast path: same tier as last time. If the spell was removed externally, reapply.
    if tier == _soulBonusAppliedTier
        if desired && !player.HasSpell(desired)
            player.AddSpell(desired, False)
        endif
        return
    endif

    ; Tier changed: remove old and apply new.
    RemoveSoulBonusAll(player)
    if desired
        player.AddSpell(desired, False)
    endif
    _soulBonusAppliedTier = tier
EndFunction


; ======================
; --- UI & Messaging ---
; ======================

Function OpenTimedMessageSWF(String menuName, Float duration = 4.0)
    if menuName == ""
        return
    endif

    ; Clamp duration so we never "hang" or no-op.
    if duration <= 0.0
        duration = 0.1
    endif

    ; Aggressive policy: interrupt any existing custom menu to guarantee our timed message shows and closes deterministically.
    UI.CloseCustomMenu()
    Utility.WaitMenuMode(0.05)

    UI.OpenCustomMenu(menuName, 0)
    Utility.WaitMenuMode(duration)
    UI.CloseCustomMenu()
EndFunction

; If Soul Bonus is disabled, use the "nobonus" SWF variants for specific menus.
String Function SwfNoBonus(String menuName)
    if menuName == ""
        return ""
    endif
    if _disableSoulBonus
        return menuName + "nobonus"
    endif
    return menuName
EndFunction

; Defiant Soul unlock menu has 4 variants depending on Soul Feats and Soul Bonus settings.
; 0defiantfeatunlock                 : feats and soulbonus enabled
; 0defiantfeatunlocknobonusnofeats   : feats and soulbonus disabled
; 0defiantfeatunlocknofeats          : feats disabled
; 0defiantfeatunlocknobonus          : soulbonus disabled
String Function ResolveDefiantFeatUnlockMenu()
    String base = "0defiantfeatunlock"
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

; Defiant transition sequence: 3s permadeath tier screen -> 3s defiant transition -> 10s defiant intro.
; Aggressive policy: interrupts any other custom menu at start, then keeps something open continuously.
Function PlayDefiantTransitionMessageSequenceSWF(Int soulTierTD)
    String m1 = ResolvePermadeathMenu(soulTierTD, False)
    String m2 = ResolveDefiantTransitionMenu(soulTierTD)
    String m3 = SwfNoBonus("0defiantintro")

    if m1 == "" || m2 == "" || m3 == ""
        return
    endif

    ; Interrupt anything currently open once.
    UI.CloseCustomMenu()
    Utility.WaitMenuMode(0.05)

    ; 1) 3 seconds
    UI.OpenCustomMenu(m1, 0)
    Utility.WaitMenuMode(3.0)

    ; 2) 3 seconds (no close-first gap)
    UI.OpenCustomMenu(m2, 0)
    Utility.WaitMenuMode(3.0)

    ; 3) 10 seconds (no close-first gap)
    UI.OpenCustomMenu(m3, 0)
    Utility.WaitMenuMode(10.0)

    UI.CloseCustomMenu()
EndFunction

; Used by IronSoulDSROnDying so the OnDying script can be the ONLY place
; that opens the Dragon Soul Revive UI, while still using Iron Soul's tier/Defiant
; logic to pick the correct contextual menu.
String Function ResolveDragonSoulReviveMenu(Actor player)
    if !player
        return ""
    endif

    String guid = EnsureGuid(player)
    if guid == ""
        return "1irondragonsoulrevive"
    endif

    if _disableDragonSoulReviveMessage
        return ""
    endif

    Int soulTier = PersistGetInt(player, GetKey(soulTierIndex, guid), 0)
    Int defActive = PersistGetInt(player, GetKey(defiantActivated, guid), 0)

    if _disableDefiantSoulFeat
        defActive = 0
    endif

    return ResolveDSRMenu(soulTier, (defActive == 1))
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

	_pendingLoadMessage = False

	String guid = EnsureGuid(player)
	if guid == ""
		return
	endif

	Int deaths     = PersistGetInt(player, GetKey(deathCount, guid), 0)
	Int soulTier   = PersistGetInt(player, GetKey(soulTierIndex, guid), 0)
	Int daysPassed = Utility.GetCurrentGameTime() as Int
	Int defActive  = PersistGetInt(player, GetKey(defiantActivated, guid), 0)
	if _disableDefiantSoulFeat
		defActive = 0
	endif

	; Defiant "active band" (post-activation, before cap).
	Bool defiant = (defActive == 1 && deaths >= IRON_SOUL_MAX_LIVES && deaths < DEFIANT_SOUL_MAX_LIVES)

	; Endless opt-in is controlled by Endless.CHIM (see LoadConfig()).
	Bool endless = IsEndlessActive(deaths, defActive)

	; Effective cap (used only for permadeath enforcement when CHIM is disabled).
	Int maxLives = GetEffectiveMaxLives(player, guid, deaths)

	; Permadeath enforcement on load (CHIM disables load enforcement)
	if _CHIM == 0
		if deaths >= maxLives
			OpenTimedMessageSWF(ResolvePermadeathMenu(soulTier, (defActive == 1)), 10.0)
			FinalizeAndQuitMainMenu()
			return
		endif
	endif

	; LoadNotificationMode:
	;  0 = default (stats + flavour)
	;  1 = no flavour (stats only)
	;  2 = only flavour
	;  3 = disabled
	if _loadNotificationMode == 3
		return
	endif
	Bool showStats  = (_loadNotificationMode == 0 || _loadNotificationMode == 1)
	Bool showFlavour = (_loadNotificationMode == 0 || _loadNotificationMode == 2)

	Bool luckActive = IsLuckActive()
	Int luckVal = 100
	Int resetKind = 2
	if luckActive
		luckVal = GetLuckValue(player, guid)
		resetKind = PersistGetInt(player, GetKey(luckResetKind, guid), 2)
	endif

	if showStats
		if luckActive
			Debug.Notification("Deaths: " + deaths + " | Luck: " + luckVal + " | Days Passed: " + daysPassed)
		else
			Debug.Notification("Deaths: " + deaths + " | Days Passed: " + daysPassed)
		endif
	endif

	if !showFlavour
		return
	endif

	; If Luck is active and not full, replace the 2nd load notification with Luck flavour.
	; Luck 100 uses the normal tier-dependent load notification.
	if luckActive && luckVal < 100
		Debug.Notification(PickLuckLoadFlavour(luckVal, resetKind))
		return
	endif

	; Priority: Endless > Defiant > Soul Feat (death-band flavour)
	if endless
		; When Endless is enabled (CHIM opt-in), always use the CHIM/Godhead notification pool.
		NotifyEndlessChimLoad(deaths)

	elseif defiant
		; After 75 deaths in Defiant mode, show a "rest" warning instead of the usual line.
		if deaths >= 75
			Debug.Notification("Your soul yearns for rest.")
		else
			Debug.Notification("Your Defiant Soul endures.")
		endif

	else
		; Death-band flavour (under 10 deaths):
		; 0: peerless
		; 1-3: prevails
		; 4-6: rises stronger
		; 7-9: endures

		if deaths <= 0
			if soulTier == 4
				Debug.Notification("Your Platinum Soul knows no equal")
			elseif soulTier == 3
				Debug.Notification("Your Ebon Soul defies fate.")
			elseif soulTier == 2
				Debug.Notification("Your Gilded Soul is peerless.")
			elseif soulTier == 1
				Debug.Notification("Your Silver Soul is peerless.")
			else
				Debug.Notification("Your Iron Soul is peerless.")
			endif

		elseif deaths <= 3
			if soulTier == 4
				Debug.Notification("Your Platinum Soul prevails.")
			elseif soulTier == 3
				Debug.Notification("Your Ebon Soul prevails.")
			elseif soulTier == 2
				Debug.Notification("Your Gilded Soul prevails.")
			elseif soulTier == 1
				Debug.Notification("Your Silver Soul prevails.")
			else
				Debug.Notification("Your Iron Soul prevails.")
			endif

		elseif deaths <= 6
			if soulTier == 4
				Debug.Notification("Your Platinum Soul rises stronger.")
			elseif soulTier == 3
				Debug.Notification("Your Ebon Soul rises stronger.")
			elseif soulTier == 2
				Debug.Notification("Your Gilded Soul rises stronger.")
			elseif soulTier == 1
				Debug.Notification("Your Silver Soul rises stronger.")
			else
				Debug.Notification("Your Iron Soul rises stronger.")
			endif

		else
			if soulTier == 4
				Debug.Notification("Your Platinum Soul endures.")
			elseif soulTier == 3
				Debug.Notification("Your Ebon Soul endures.")
			elseif soulTier == 2
				Debug.Notification("Your Gilded Soul endures.")
			elseif soulTier == 1
				Debug.Notification("Your Silver Soul endures.")
			else
				Debug.Notification("Your Iron Soul endures.")
			endif
		endif
	endif

    ;TEST
    Form f = Game.GetFormFromFile(0x000B12, "Iron Soul - Permadeath Lite.esp")
    GlobalVariable gv = f as GlobalVariable
    
    if gv
        gv.SetValueInt(5)
        Debug.MessageBox("IronSoul_DeathCount = " + gv.GetValueInt())
    else
        Debug.MessageBox("IronSoul_DeathCount NOT FOUND")
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
        String guid = EnsureGuid(player)
        if guid != ""
            Int soulTier = PersistGetInt(player, GetKey(soulTierIndex, guid), 0)
            Int defActive = PersistGetInt(player, GetKey(defiantActivated, guid), 0)
            if _disableDefiantSoulFeat
                defActive = 0
            endif
            OpenTimedMessageSWF(ResolveRespawnMenu(soulTier, (defActive == 1)), 4.0)
        endif
    endif
EndFunction

String Function ResolveDefiantTransitionMenu(Int curTier)
    ; Contextual 10th-death Defiant transition message, based on highest unlocked Soul Feat.
    ; Tier state: 0=Iron, 1=Silver, 2=Gold, 3=Ebon, 4=Platinum. Highest eligible tier always takes priority.
    if curTier >= 4
        return "0defiantdeathmessage10platinum"

    elseif curTier == 3
        return "0defiantdeathmessage10ebon"

    elseif curTier == 2
        return "0defiantdeathmessage10gold"

    elseif curTier == 1
        return "0defiantdeathmessage10silver"
    endif

    ; Fallback: Iron tier.
    return "0defiantdeathmessage10iron"
EndFunction


; ===========================
; --- Endless Mode (CHIM) ---
; ===========================

Bool Function IsEndlessActive(Int deathsNow, Int defActive)
    ; Endless (CHIM) begins at the Iron cap unless Defiant is active,
    ; in which case it begins at the Defiant cap.
    Int endlessStart = IRON_SOUL_MAX_LIVES
    if defActive == 1
        endlessStart = DEFIANT_SOUL_MAX_LIVES
    endif
    return (_CHIM == 1 && deathsNow >= endlessStart)
EndFunction

Function NotifyEndlessChimLoad(Int deaths)
    Int mode = IronSoulNative.GetConfigInt("LoadNotificationMode", 0)
    if mode >= 3
        return ; Disabled / Silent
    endif

    Int daysPassed = Utility.GetCurrentGameTime() as Int

    ; Core notification
    if mode != 2
        Debug.Notification("Deaths: " + deaths + " | Days Passed: " + daysPassed)
    endif

    ; Flavour notification
    if mode != 1
        Int idx = Utility.RandomInt(0, 9)
        String line = PickEndlessChimLine(idx)
        if line != ""
            Debug.Notification(line)
        endif
    endif
EndFunction


; Picks 1 of 10 short CHIM/Godhead lines and appends "Deaths: X / ???" on the same line.
String Function PickEndlessChimLine(Int idx)
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


; ===========================
; --- Uninstall / Cleanup ---
; ===========================
;
; When UninstallMode=1 in config:
;  - All Iron Soul functionality is disabled.
;  - A one-time cleanup pass clears any risky runtime state (deferred kill / essential / ghost / paralysis).
;  - The controller quest stops itself.
Function HandleUninstallMode(Actor player)
    ; If uninstall has already completed in this save, keep the quest permanently inert.
    if _modDisabled
        ; Safety: ensure SoulBonus remains disabled in inert state.
        RemoveSoulBonusAll(player)
        _soulBonusAppliedTier = -1
        if !_uninstallNotified
            _uninstallNotified = True
            Debug.MessageBox("Iron Soul has been safely disabled.\nYou may now uninstall the mod, or leave it installed in its disabled state.")
        endif
        QueueUpdate(30.0)
        return
    endif

    ; Stage 0: cancel pending jobs so no gameplay logic runs during cleanup.
    if _uninstallStage == 0

        ; Journal: uninstall/disable milestone (one-time).
        if !_disableCharacterJournalLog
            String guidU = EnsureGuid(player)
            if guidU != ""
                Int unLogged = PersistGetInt(player, GetKey(journalUninstallLogged, guidU), 0)
                if unLogged != 1
                    JournalLogEvent("The soul retreats into itself, no longer strong enough to defy the cruel fate that awaits.")
                    PersistSetInt(player, GetKey(journalUninstallLogged, guidU), 1, True)
                endif
            endif
        endif

        _pendingDisableRespawn = False
        _pendingLoadMessage = False
        _pendingDeathCheck = False
        _pendingRespawnMenu = False
        _respawnMenuArmed = False
        _pendingDeathResync = False

        ; SoulBonus: uninstall mode always strips SoulBonus abilities immediately.
        RemoveSoulBonusAll(player)
        _soulBonusAppliedTier = -1

        ; Disable DSR immediately so it cannot fire during cleanup.
        if DSRAbility && player.HasSpell(DSRAbility)
            player.RemoveSpell(DSRAbility)
        endif
        if DSROnDying && player.HasSpell(DSROnDying)
            player.RemoveSpell(DSROnDying)
        endif
        if DSRQuest
            DSRQuest.Stop()
        endif

        ; Ensure Respawn mod quest is running so Respawn works after we disable Iron Soul.
        if _respawnQuest
            if !_respawnQuest.IsRunning()
                _respawnQuest.Start()
            endif
        endif

        _uninstallStage = 1
        QueueUpdate(FastPollSeconds)
        return
    endif

    ; Stage 1: release any deferred-kill state while the player is protected.
    if _uninstallStage == 1
        player.GetActorBase().SetEssential(True)
        player.EndDeferredKill()

        ; Force a death attempt while essential to clear stuck states.
        player.DamageAV("Health", player.GetAVMax("Health") + 999.0)

        _uninstallAt = Utility.GetCurrentRealTime() + 3.0
        _uninstallStage = 2
        QueueUpdate(FastPollSeconds)
        return
    endif

    ; Stage 2: restore and clear flags, remove optional DSR assets, then stop this quest.
    if _uninstallStage == 2
        if Utility.GetCurrentRealTime() < _uninstallAt
            QueueUpdate(FastPollSeconds)
            return
        endif

        player.RestoreAV("Health", 1000.0)
        player.SetGhost(False)
        player.SetAV("Paralysis", 0.0)
        player.GetActorBase().SetEssential(False)

        ; Optional: remove DSR spells/quest if provided.
        if DSRAbility && player.HasSpell(DSRAbility)
            player.RemoveSpell(DSRAbility)
        endif
        if DSROnDying && player.HasSpell(DSROnDying)
            player.RemoveSpell(DSROnDying)
        endif

        ; Also remove SoulBonus abilities if present.
        RemoveSoulBonusAll(player)
        if DSRQuest
            DSRQuest.Stop()
        endif

        _modDisabled = True

        if !_uninstallNotified
            _uninstallNotified = True
            Debug.MessageBox("Iron Soul has been safely disabled.\nYou may now uninstall the mod, or leave it installed in its disabled state.")
        endif

        QueueUpdate(30.0)
        return
    endif
EndFunction

Function SyncDSROnLoad(Actor player)
    ; Ensures DSR quest/spells exist when DSR is enabled in config.
    ; This covers cases where UninstallMode previously removed/stopped DSR, and later the user re-enables DSR.
    ; Assumption: session-based only (no live hotswap). Safe to call on load.
    if !player
        return
    endif

    ; Do not install while Iron Soul is inert or while DSR is config-disabled.
    if _modDisabled || _uninstallMode || _disableDragonSoulRevive
        return
    endif

    if DSRQuest && !DSRQuest.IsRunning()
        DSRQuest.Start()
    endif
    if DSRAbility && !player.HasSpell(DSRAbility)
        player.AddSpell(DSRAbility, False)
    endif
    if DSROnDying && !player.HasSpell(DSROnDying)
        player.AddSpell(DSROnDying, False)
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
    _uninstallStage = 0
    _uninstallAt = 0.0
    _uninstallNotified = False

    ; Reset transient jobs/caches so nothing resumes half-armed.
    ResetTransientJobsAndCaches()

    ; Re-evaluate respawn integration on next tick.
    _pendingDisableRespawn = True
    _pendingDeathResync = True
    _pendingDeathCheck = False
    _pendingRespawnMenu = False
    _respawnMenuArmed = False

    ; Restore Dragon Soul Revive system if enabled in config.
    if !_disableDragonSoulRevive
        if DSRQuest && !DSRQuest.IsRunning()
            DSRQuest.Start()
        endif
        if DSRAbility && !player.HasSpell(DSRAbility)
            player.AddSpell(DSRAbility, False)
        endif
        if DSROnDying && !player.HasSpell(DSROnDying)
            player.AddSpell(DSROnDying, False)
        endif
    endif

    ; Kick the controller back into normal cadence.
    QueueUpdate(FastPollSeconds)
EndFunction