# Active Shield and Rally Call

23 September 2026. C01/F01 connected support checkpoint; broader Space Stage parity remains open. No planet-editing work was added.

## Use and tradeoffs

Dock → Upgrades → Support offers two permanent tools. After purchasing one, click its icon in the Weapons palette or activate it through Equipment. The palette action preserves the selected weapon and current attack order. Hover for the name, effect, price-independent energy cost, duration and cooldown. The same visible-slot number controls work as for other tools; neither F nor WASD is required.

| Tool | Purchase and eligibility | Activation | Consequence |
| --- | --- | --- | --- |
| Shield | 500 Marks; Defender 3 **or** Colonist 2 | 30 energy; 10 s active; 45 s cooldown from activation | Blocks flagship damage. Does not protect escorts or colony ports. Weapons still cost energy. |
| Rally Call | 360 Marks; Defender 2 **or** Diplomat 1 | 25 energy; 12 s active; 60 s cooldown from activation | Doubles flagship and assisting escort weapon damage, including when flying alone. Does not heal, refill energy, increase range or bypass fire rules. |

Activating both spends 55 of the starting reactor's 100 energy before any weapon fire or travel. That can enable an attack window but leave little reserve for withdrawal. Energy never regenerates. Active duration ends well before the tool is reusable. Using a pack or visiting a dock does not reset its cooldown; a new activation costs energy again.

Shield covers surface defenses, orbital guardians, hostile raid strikes and the wreck's pulse field through one authoritative incoming-damage method. Those same attacks still damage exposed escorts. A shielded commander can still lose a colony port to bombardment. Emergency tow clears active effects but preserves their recharge deadlines.

Rally affects the surface laser, seeker, bomb, orbital lance and existing escort fire. Missiles and bombs store the damage multiplier at launch: expiry or departure does not weaken a committed shot, and activating after launch does not strengthen it. Enemy aim, damage, territorial surrender, alliance restrictions, weapon energy and individual firing cooldowns keep their existing rules. No extra shots are invented.

## Feedback and persistence

The shield renders a mostly clear cyan envelope with a travelling surface pattern and a brighter blocked-hit response. Rally shows violet signal rings. Small named icons beside ship condition show remaining active time across palette categories; hotbar slots show active/cooldown seconds. The two purchases have their own shop tab. Equipment lists active support before the old tool-inspection grid. [Effect specification](../art/specs/ship_support_effects.md) records geometry, visual intent and limits.

The older recovered artifact remains available as **Pulse ward**, with its existing `shroud_*` save keys and orbital damage reduction/drain. It is not invisibility and is not the new timed Shield. The clearer name distinguishes two different effects without deleting an earned item or granting the purchased tool during migration.

Session v18 / field v9 store each tool's active-until time, ready time and use count on the shared simulation clock. Travel consumes duration; inspecting or pausing freezes it. Saving, loading and rebuilding a scene never reset it. Older saves initialize inactive support and gain no free purchases. Owned tools remain in the existing commerce inventory. Invalid clocks, nonintegral counts, unowned effects and unsupported projectile multipliers reject before a campaign is replaced. Render phase and hit flashes are cosmetic, not authoritative combat state.

## Evidence and limits

The full regression suite passed with the initial 57 support assertions; the expanded **60-check** support suite and 46 capacity checks passed after shop layout changes. Tests exercise paid/earned acquisition, atomic refusals, all flagship damage paths, exposed escorts/ports, actual allied fire, boost-at-launch, expiration, tow, shared travel, binary/JSON persistence, legacy migration, pause/inspection, actual icon activation, tooltips/effects and visible purchase bounds. `tools/CaptureShipSupport.gd` renders shop, Shield, Rally, Equipment and cooldown states at 1080p and 1440p.

Tests and captures do not establish native usability, balanced combat, final art or AAA acceptance. The effect is an original candidate; activation/impact cues reuse existing audio. Dedicated generated/licensed audio and listening review remain outstanding. Cloaking, AOE fleet repair, full weapon-tier breadth, five-slot/master-rank fleet progression, wider fleet orders and first-person combat remain open.

Reference: the indexed [StrategyWiki tool table](https://strategywiki.org/wiki/Spore/Tools) describes Shield as invulnerability with recharge and Rally Call as doubled personal/allied damage. Our timings, prices and attainable sector badge alternatives are explicitly original scenario tuning. Direct [Shield](https://spore.fandom.com/wiki/Shield) retrieval was blocked; [Cooldown](https://spore.fandom.com/wiki/Cooldown) leaves its numerical cooldown unspecified. Exact retail timing and unlock parity are not claimed.
