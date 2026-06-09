
<p align="center">
  <img src="docs/images/iron-soul-logo.png" alt="Iron Soul logo" width="100%">
</p>

Iron Soul: Dead God's Dream
===========================

Iron Soul is a permadeath roguelite system for Skyrim with configurable death rules, Dragon Soul Revive,
and persistent progression, expanding into a multi-character saga built around Sunderhearts, escalating undead pressure,
and the dreams of a dead god.

Version
-------

0.7: The Missing Heart


Requirements
------------

Hard Requirements
- Skyrim Special Edition / Anniversary Edition.
- SKSE64.
- Address Library for SKSE Plugins, required by `ironsoul.dll` through CommonLibSSE NG relocation/versionlib support.
- PapyrusUtil SE, required by core scripts for `StorageUtil`.
- SkyUI.

Soft Requirements
- Respawn - Soulslike Edition: enables optional respawn integration. Without it, Iron Soul still works and falls back to Death behavior.
- ConsoleUtil Extended: needed for custom console commands.
- Skyrim Character Sheet: optional total-death display compatibility through `EnableCharacterSheetCompatibility`.
- Inventory Interface Information Injector (I4): optional inventory icon/classification support for shipped `inventoryinjector` JSON files and item icons.


Current TODO
------------

- Finish Ebon / Platinum restore work.

Systems
-------

Anima

Anima replaces dragon souls as the primary soul-tier progression currency. Anima and unlocked Soul Tiers are
shared progress, making Iron Soul progression persist across characters for a stronger roguelite loop.

Soul Tier unlock targets:

```text
| Soul Tier     | Unlock Requirement            |
| Defiant Soul  | 100 Anima                     |
| Silver Soul   | 250 Anima                     |
| Gold Soul     | 500 Anima                     |
| Ebon Soul     | 1,000 Anima                   |
| Platinum Soul | 2,000 Anima                   |
| Devour Soul   | 5,000 Anima + 50 dragon souls |
```

- Add shared Anima storage and shared Soul Tier unlock persistence.
- Convert Soul Tier unlocking from dragon-soul thresholds to Anima thresholds, keeping dragon souls as an additional Devour Soul requirement.
- Add Anima death rewards from tiered sources: draugr and other undead, dragon priests, dragons, and major bosses.
- Add major Anima payouts for saga bosses such as Alduin, Harkon, and Miraak.
- Add Sunderheart use option `Absorb Anima`; when selected, the consumed Sunderheart grants Anima based on its Sunderheart tier.
- Block Anima gain while the character is in Defiant Soul, preventing new Soul Tier unlocks during Defiant runs.
- Assign Anima-bearing enemies a Soul Level that drives both their Anima reward and Soul Vigor behavior.
- Draft Soul Levels: draugr/undead = 1, dragon priests = 2, dragons = 3, Alduin = 4, Miraak = 5; assign Harkon and other major bosses during tuning.
- Implement Soul Vigor regeneration from enemy Soul Level comparison: enemies below the player's Soul Level have no regeneration, enemies at the player's Soul Level have mild regeneration, and enemies above the player's Soul Level have significant regeneration.
- Treat the player as Soul Level 1 for Soul Vigor comparisons while in Defiant Soul.

Monsters, Soul Levels, and Soul Vigor

Soul Level is the creature-side progression band for Anima-bearing enemies. It determines both the Anima reward
paid on death and how hard the enemy pushes back through Soul Vigor regeneration.

Soul Vigor comparison:

```text
Enemy Soul Level < Player Soul Level: no Soul Vigor regeneration
Enemy Soul Level = Player Soul Level: mild Soul Vigor regeneration
Enemy Soul Level > Player Soul Level: significant Soul Vigor regeneration
Defiant Soul characters count as Player Soul Level 1
```

Recommended Anima rewards:

```text
| Soul Level | Enemy Type / Examples                         | Suggested Reward                   |
| 1          | Skeletons, draugr, basic undead               | 1 Anima                            |
| 1          | Restless/wight/scourge draugr, tougher undead | 2-3 Anima                          |
| 1          | Draugr deathlords, dungeon undead bosses      | 5-10 Anima                         |
| 2          | Dragon priests, named undead cult bosses      | 50 Anima                           |
| 3          | Dragons                                       | 100-250 Anima by dragon difficulty |
| 4          | Harkon, Alduin, other world-shaking bosses    | 1000 Anima                         |
| 5          | Miraak, secret/capstone soul enemies          | 2000 Anima                         |
```

Dragon reward draft:

```text
| Dragon Type      | Reward    |
| Dragon           | 25 Anima  |
| Blood Dragon     | 50 Anima  |
| Frost Dragon     | 75 Anima  |
| Elder Dragon     | 100 Anima |
| Ancient Dragon   | 150 Anima |
| Revered Dragon   | 200 Anima |
| Legendary Dragon | 250 Anima |
```

- Keep common undead rewards low so Nordic ruins remain steady progress instead of tier skips.
- Make dragon priests and named undead boss kills feel like real Anima milestones without replacing dragons.
- Make major quest bosses large shared progress spikes, especially Alduin, Harkon, and Miraak.
- Use Soul Vigor sparingly on low-tier enemies so regeneration feels like supernatural pressure rather than a universal combat tax.
- Add INI tuning later for reward multipliers, Soul Vigor strength, and whether non-draugr undead count as Anima sources.


Sunderhearts

Sunderhearts have begun manifesting throughout Tamriel, radiant remnants of Lorkhan’s Heart, alive with divine anima and forgotten tonal power.
They can purge a death, enhance an item, or be harvested for anima.

```text
| Anima / Soul Tier | Unlocked Tier           | Quest Milestone                 | Starting Found Sunderhearts |
| 0 - Iron          | Dormant Sunderheart      | Dormant Sunderhearts can spawn   | 0                          |
| 250 - Silver      | Kindled Sunderheart      | First major dream               | 1                          |
| 500 - Gold        | Resonant Sunderheart     | Strong dream escalation         | 2                          |
| 1000 - Ebon       | Sublime Sunderheart      | Heart influence becomes obvious | 3                          |
| 2000 - Platinum   | Transcendent Sunderheart | Late-game metaphysical pressure | 4                          |
| 5000 - Devour     | Heart complete          | Manifest the Heart              | 5                          |
| 10000 - ???       | Whole Heart             | Amaranth???                     | 10                         |
```

Proposed Sunderhearts:

```text
| Type     | Weapon Effect                      | Armor/Apparel Effect               | Implementation               | Colour Scheme                 |
| Tonal    | Improve selected weapon temper     | Improve selected armor temper      | Scripted item selection      | Kagrenac Gold (#f0b84a)       |
| Sundered | Armor-piercing damage              | Fortify armor rating               | Perk condition / AV modifier | Sundered Ruby (#e02f3f)       |
| Wail     | Magicka damage / interrupt casters | Spell absorption / Fortify Magicka | Standard effects, tune       | Wailglass Blue (#7aa2ff)      |
| Pact     | Reduce target damage briefly       | Resist magic / resist damage       | Temporary debuff + AV        | Pactwine Rose (#b12c5a)       |
| Red      | Fire damage                        | Resist fire                        | Standard enchantments        | Dragonflame (#ff4a1f)         |
| Ash      | Lingering fire/ash damage          | Resist fire + disease              | Standard effects             | Ashfall Rust (#a86f5d)        |
| Blood    | Absorb health                      | Fortify health                     | Standard enchantments        | Heartblood Ruby (#d91e5b)     |
| Breath   | Absorb stamina                     | Fortify stamina                    | Standard enchantments        | Breathspring Teal (#2ee6a6)   |
| Memory   | Soul trap                          | Fortify enchanting                 | Standard + AV modifier       | Mnemonic Indigo (#5964ff)     |
| Dreaming | Fear or calm on hit                | Fortify illusion                   | Standard illusion + AV       | Lucid Violet (#d66bff)        |
| Missing  | Absorb magicka                     | Fortify magicka                    | Standard enchantments        | Voidmark Blue (#233a8b)       |
| Mortal   | Bonus damage to undead             | Resist disease                     | Keyword condition            | Gravebone (#cbb99a)           |
| Scar     | Bleed / lingering damage           | Fortify health regen               | Magic effect + AV            | Scar-Suture (#c34b45)         |
| Oath     | Bonus damage below half health     | Fortify block                      | Perk condition + AV          | Oathsteel (#6f86a8)           |
| Betrayal | Sneak attack bonus                 | Fortify sneak / muffle             | Perk condition + AV          | Traitor Violet (#5b238c)      |
| Pilgrim  | Turn undead                        | Fortify restoration                | Standard effects             | Pilgrim Candle (#ffe6a8)      |
| Brass    | Stagger chance                     | Fortify heavy armor                | Perk proc + AV               | Weathered Brass (#b08a4b)     |
| Glass    | Critical chance                    | Fortify light armor                | Perk proc + AV               | Glasscut Cyan (#7cf6e7)       |
| Storm    | Shock damage                       | Resist shock                       | Standard enchantments        | Stormcharge (#3aa0ff)         |
| Rime     | Frost damage                       | Resist frost                       | Standard enchantments        | Frostwake (#bdf4ff)           |
| Thorn    | Poison damage                      | Resist poison                      | Standard effects             | Thornvenom (#9bff22)          |
| Burden   | Slow target                        | Fortify carry weight               | Standard slow + AV           | Burden Umber (#8a5f3c)        |
| Gale     | Weapon speed                       | Movement speed                     | AV modifiers, test           | Galefoam Mint (#a8ffd0)       |
| Mirror   | Retaliatory damage on hit          | Reflect damage                     | Scripted retaliation         | Mirrorsheen Silver (#cfd8e3)  |
| Aegis    | Weaken target attack damage        | Resist normal weapons              | Temporary debuff + AV        | Aegis Cobalt (#3452d8)        |
| Hunger   | Stamina drain                      | Reduced stamina costs              | Standard / AV effects        | Hollow Bile (#c7d100)         |
| Crown    | Calm / command chance              | Fortify speech                     | Standard illusion + AV       | Sovereign Gold (#ffe38a)      |
| Rune     | Bonus damage after spellcast       | Magicka regen                      | Small script / perk proc     | Runelight Azure (#14b8ff)     |
| Vigil    | Turn undead / reveal undead        | Detect dead                        | Standard effects             | Vigil White (#f3f7ff)         |
| Doom     | Fear on hit                        | Shout recovery bonus               | Standard fear + AV           | Doomwine (#8b0018)            |
```

- Create Sunderheart item records and assets as Sigil Stone-adjacent MiscObjects using the spherical soul gem mesh as the visual base.
- Build Sunderhearts as tiered shared unlocks with varied effects; new characters can choose a small set of unlocked Sunderhearts, likely three.
- Make Sunderhearts visually scale with power so their red glow intensifies as the character levels or as the chosen Sunderheart tier improves.
- Define Sunderheart Spawns as the target number of active Sunderhearts present in the world at one time, calculated from difficulty preset plus override setting; for example, A++ can keep 9 Sunderhearts active.
- Add a curated Sunderheart spawn-location pool, weighted toward dungeons and hard-to-reach places rather than the general game world.
- Re-roll active Sunderheart locations on each player load so the world hunt changes between characters and reloads.
- Add a Sunderheart proximity heartbeat that only pulses when the nearest active Sunderheart is in the player's current cell, with sound intensity/frequency scaling by distance.
- Prototype Sunderheart inventory use with a MiscObject `OnEquipped` detector; verify SkyUI behavior, the cannot-equip message, stacked copies, leveled-list/container acquisition, and save/load reliability.
- Keep Sunderheart item scripts minimal: use the item only as an activation detector, then hand real logic to an Iron Soul quest/controller path.
- Add Sunderheart activation flow that opens a choice menu, consumes one Sunderheart only after confirmed use, and supports cancel without removing the item.
- When recorded deaths are above 0, Sunderheart activation offers Enhance Item or Purge Death; with 0 deaths, only Enhance Item is shown.
- Add a restore-death Sunderheart action that purges one recorded death, plays the Sunderheart absorb presentation, and drains the orb's red colour as its essence is absorbed.
- Explore Sunderheart item empowerment through Iron Soul native filtered selection sessions displayed with an injected SkyUI InventoryMenu item selector, starting with weapon and armor temper quality.
- Add persistence for unlocked Sunderheart tiers, selected new-game Sunderhearts, absorbed Sunderheart progress, active world spawn locations, and relocation timing.

General

- Integrate cinematic dragon soul absorption. Make DSR wind effect isolated.
- See if swfs can be replaced by prismaUI? Then see if text strings can be localized outside the scripts.


Roadmap
-------

V2: Echoes of Lorkhan
- Add a dream system. After the first Sunderheart is absorbed, the player has a chance to receive dreams while sleeping.
- More Sunderhearts absorbed increase dream chance, expand the dream pool, and cause more metaphysical Sunderhearts to appear in Skyrim. "The Heart wants to be whole again..."
- Dreams focus mostly on historical echoes tied to Lorkhan, the Heart, Kagrenac, the Dwemer, the Tribunal, Red Mountain, and the player's growing connection to the Sunderhearts.
- Dreams include quick scenes and distorted echoes involving Kagrenac's use of the Tools, the disappearance of the Dwemer, Dagoth Ur's fall, and the Tribunal's later use of the Heart.
- Early dreams are fragmented and ambiguous, making it unclear whether the voice guiding the player is Lorkhan, the Heart itself, or something else speaking through it.
- Flesh out the history around Lorkhan, the Heart, and the player's connection to the Sunderhearts.
- Expand the Heart mystery into a stronger story layer that recontextualizes the V1 Sunderheart hunt.

V3: The Dragon Cult Rises
- Rework Draugnarok raid pressure so the endgame source is Labyrinthian and the active pressure network flows from dragon priest barrows.
- Spawn lower raid categories from the closest active dragon priest barrow instead of generic locations where practical.
- Turn roaming mobs into reinforcement bands that travel from dragon priest barrows to Labyrinthian and guard there until cleaned up.
- Completing Labyrinthian should disable or heavily suppress minor capital raids, capital raids, and gate crashes.
- Killing a dragon priest should disable or reduce the raid pressure linked to that priest's barrow.
- Dragon priest anchors to explore: Morokei at Labyrinthian, Rahgot at Forelhost, Hevnoraak at Valthume, Vokun at High Gate Ruins, Volsung at Volskygge,
  Otar at Ragnvald, Nahkriin at Skuldafn, and Krosis at Shearpoint with possible Korvanjund support routing.
- Restore the kill-handler concept as a notification-area draugr kill counter that tracks kills by the player, followers, summons, or player-owned actors.
- Display draugr kill count updates through lightweight notifications.
- Build hidden draugr heat from draugr kills and dragon soul absorption, with dragon souls acting as a louder supernatural signal.
- Use higher heat to increase the chance of a draugr assassin or personal vengeance squad during a Draugnarok pulse.
- Add heat decay, cooldowns, post-attack reduction, and loop protection so assassin kills do not recursively create more assassin pressure.
- Explore optional The Restless Dead integration for richer undead visual variety while preserving Dragon Cultist identity.
- Alduin remains defeatable in V3.
- Corpse system so towns show the effects of raids while main npcs stay alive.

V4: Return of the Dead God
- Add a full quest powered by the dream system, building on the historical Heart dreams introduced in V2.
- As more Sunderhearts are absorbed, the dreams become more direct and begin instructing the player to gather the Tools of Kagrenac through a required mod.
- Dreams reveal that only the Heart's power can make Alduin truly vulnerable.
- Require 50 total shared Sunderhearts absorbed to complete the saga-long Heart collection and unlock the Heart's manifestation path.
- Once all Sunderhearts have been absorbed, the Heart manifests inside a dream realm the player can access at any time. At first, the Heart is incomplete and unsafe to strike.
- If the player uses the Tools on the Heart before the correct ritual is known, the game quits outright.
- A final dream falsely instructs the player to strike the Heart with Sunder once, then Keening once. Following this instruction triggers Dagoth Ur's reveal and awakens Dagoth Soul.
- Reveal that the apparent voice of Lorkhan is actually Dagoth Ur's dream-shadow manipulating the player.
- Through Dagoth Ur's dream-shadow, the player glimpses forbidden knowledge of what happened beneath Red Mountain. This stolen Heart-memory becomes the secret that can be offered to Hermaeus Mora.
- Alternatively, after Dragonborn is completed, Hermaeus Mora may send a vision warning that the force linked to the player is not Lorkhan, but a dark entity trying to control the Heart.
- Add an Apocrypha bargain scene where the player offers Mora the stolen Heart-memory: forbidden knowledge glimpsed through Dagoth's dreams about Kagrenac, the Tools, and the disappearance of the Dwemer.
- Mora reveals that resisting Dagoth requires striking the Heart in the hidden sequence: Sunder, Keening, Sunder, Keening. Performing this sequence awakens Shezarrine Soul.
- Any incorrect use of the Tools on the manifested Heart, other than the Dagoth sequence or the Mora-taught sequence, quits the game outright.
- Choose to accept Dagoth Ur's dream-shadow and awaken Dagoth Soul, or bargain with Mora for the forbidden knowledge needed to resist Dagoth and awaken Shezarrine Soul.
- Main Quest edit: Alduin is unkillable at the Throat of the World until the Heart of Lorkhan quest is completed. When he reaches 0 HP, he does not die; instead, he recovers, deals increased damage, and taunts the player.

V5: Discord Integration
- Add Discord channel integration for the journal system so journal entries and major milestones can be logged to configured Discord channels.
- Add daily challenges that can reward Sunderhearts for accomplishments, such as completing an objective and receiving 3 Sunderhearts.
- Build opt-in network communication into the mod stack, including configuration, failure handling, and safeguards around external Discord posting.

V6: City Recovery
- Add Quartermaster and Cleric support NPCs to cities, unlocked separately for each city.
- Clerics can resurrect fallen city residents once unlocked for that city.
- Quartermasters can supply city guards with silver swords once unlocked for that city.


Credits
-------

- [Simple Dragonsoul Resurrect](https://www.nexusmods.com/skyrimspecialedition/mods/94507), by Mokeine: foundation credit for core Dragon Soul Revive concepts.
- [STB Widgets](https://www.nexusmods.com/skyrimspecialedition/mods/136148), by STB team: credit for `lvlWidget` assets and framework.
- [B612](https://www.nexusmods.com/skyrimspecialedition/mods/127701), by shazdeh2: credit for the item-selection UI foundation and derivative injected InventoryMenu SWF basis.
- [Draugnarok SE](https://www.nexusmods.com/skyrimspecialedition/mods/12849), by unuroboros: credit for original Draugnarok systems/content adapted into Iron Soul.
- [Draugrs - My patches SE by Xtudo](https://www.nexusmods.com/skyrimspecialedition/mods/123225), by Xtudo: credit for draugr eye asset basis used by dynamic draugr eye visuals.
- [High Quality Dice Skins](https://www.nexusmods.com/baldursgate3/mods/1220), by Sir William Snugglepuff: credit for dice visual source material used by Luck roll presentation.
- [Spherical Soulgems SSE](https://www.nexusmods.com/skyrimspecialedition/mods/66634), by Fishbiter: credit for sigil stone mesh source material used as the Sunderheart visual base.
- [Spherical Soulgems SSE - Particle Lights for ENB](https://www.nexusmods.com/skyrimspecialedition/mods/66668), by DeterministicFreeWill: credit for ENB particle light/glow source.


Music Credits
-------------

- [The Ancient Dragon](https://www.youtube.com/watch?v=3bWizcifhRI), by Motoi Sakuraba.
- [Gods of War](https://youtu.be/QWXLzA-c_ow), by Mythic Harmonies
