# Hostile encounters beyond Morrow

23 September 2026. C01/P01/R02/I01 checkpoint: two new authored orbital threats, physical salvage and a paid weapon upgrade. This is combat/progression breadth, not fleet combat or full Spore weapon/badge parity.

## Play

Travel to Nacre I or Kestrel I and remain in orbit. A survey identifies the contact; approaching its patrol area also exposes the warning. The arrival lane and dock are outside that area. Select the arc lance and click the hostile vessel to approach and fire. Stop, steering, pause or another order cancels repeated fire. Retreating outside the patrol area breaks contact; jumps require disengagement.

| Encounter | Behavior | Hull | Attack | Salvage |
| --- | --- | --- | --- | --- |
| Morrow custodian | Existing mobile exclusion patrol; old wreck/pulse field remains separate | 66 | Existing warning and direct fire retained | Existing phase shroud at the wreck |
| Nacre I Rake cutter | Independent raider pursues within a bounded region | 88 | Two-second fixed warning volume, radius 6; 18 hull damage | Two alloy freight units |
| Kestrel I Watchbell sentry | Abandoned machine remains anchored | 110 | Three-second fixed warning volume, radius 10; 28 hull damage | Two resonant-glass freight units |

New threats first give two warning ticks, then commit to an aim position. Moving outside the marked **3D volume**, including vertically, evades the strike. The aim does not track the ship after commitment. Four seconds of weapon recovery precede another aim. The phase shroud reduces incoming damage to 30% while still consuming energy. Disabled enemies cease firing; existing emergency tow preserves recoverable failure with damaged hull and depleted energy.

Click a neutralized foreign vessel to recover its two cargo units. The ship approaches within ten local units, and the actual hold must have room. Cargo retains its world of origin and can be sold through ordinary markets. Recovery is one-time, and both defeat and recovery survive leaving, returning and saving. There is no assigned errand or unlimited bounty.

## Progression

The **Defender** pilot badge counts distinct neutralized authored contacts, including the nonlethal Morrow encounter. Thresholds are 1/3/6/10/20; only the first two tiers are reachable with the current three contacts. These are original scenario thresholds, not an assertion of retail Spore badge semantics.

**Focused arc emitter** appears in dock Upgrades after Defender 1 **or Explorer 2**. It costs 180 Marks and raises actual arc-lance damage from 22 to 33. Range (24), energy (10 per shot) and cooldown (two seconds) remain unchanged. Peaceful exploration therefore preserves an alternative unlock path. Eligibility never grants free equipment.

## State, art and evidence

`data/orbital_encounters.json` holds enemy identities, movement, hull, attack and salvage definitions. Campaign and field snapshots are v7. Current and inactive worlds migrate their aim, countdown and salvage fields; previously unused foreign enemy state acquires the appropriate intact hull. The campaign binds purchased equipment directly into weapon behavior. Chronicle records neutralization, recovered cargo and actual emergency tow; repeated encounters cannot duplicate achievements or rewards.

`art/specs/hostile_vessels_v1.json` specifies the Rake's split-jaw silhouette and Watchbell's suspended-eye body. `scripts/hostile_vessel.gd` authors their original modular meshes and small vane motion. Warning geometry matches the damage radius; a brief flash marks resolution. These remain simple candidate models, not approved final art. The reused firing/notification sounds are also still provisional; no professional audio claim accompanies this work.

`test_orbital_encounters.gd` has 45 assertions for safe arrivals, windup/evasion/damage, behavior differences, recovery, deterministic mid-warning saves, world persistence, actual mouse combat, salvage capacity, paid/peaceful progression and old-save migration. The regression suite now totals 847 assertions plus UI checks. `review_orbital_encounters.gd` provides 1080p gameplay and close model captures. Native input, difficulty/fun, full audio and final visual review remain required.

The present local state still supports one authored contact per pilot orbit. Multiple persistent ships, fleets, empire war/conquest, raids on colonies/freight, broader weapon categories and a full progression corpus remain unimplemented. Next prioritize the authored player-scout asset and flight/target feedback review, then expand combat entities and the reference feature inventory; avoid claiming parity from these three encounters.
