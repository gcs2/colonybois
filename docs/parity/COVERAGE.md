# Base Space Stage coverage contract

23 September 2026. Reference audit against implementation commit `305d428`. [TASK_BOARD.md](../TASK_BOARD.md) remains the production queue. These manifests describe what must be accounted for; they do not assign competing task percentages.

## User-approved scope exceptions

23 September 2026 user scope correction: skip coloring and terrain sculpting; further planet-modification tools are not a current priority. Existing climate/ecosystem behavior stays intact. T02/T03 are explicit exclusions from the agreed delivery scope, not missing work to revive automatically or completed features. Further T01 expansion is deferred. Focus next on exploration, trade, diplomacy and consequential spaceship encounters. Reference counts below continue to describe Spore, including skipped features. Report retained/adapted, deferred and skipped families separately; never treat exclusions as completed implementations. Planet Artiste is also skipped because its dependent coloring/sculpting activities are excluded.

## What is now enumerated

| Reference set | Enumerated entries | Meaning |
| --- | ---: | --- |
| Ship tools, equipment and world-editing variants | 189 in 84 families | Includes defaults, purchased tiers, individual sculpting stamps, normalized coloring channels and nine archetype powers. Two creature-editor entries are explicitly deferred. |
| Badge families | 30 | The named list yields 134 tiers if 26 have five tiers and four are single awards. The wiki's conflicting 139 total remains unresolved. |
| Master promotions | 10 | Badge-point progression, distinct from per-family tiers. |
| Space-related achievements | 40 | Thirty-nine named Space achievements plus the hidden Earth-destruction achievement. Cross-stage and expansion boundaries are separate. |
| Inherited Space consequence traits | 12 | Names inventoried; precise effects and scenario acquisition still need closure. |

**These are inventory counts, not completed features or a verified exhaustive denominator.** Source pages often provided indexed excerpts while direct retrieval was blocked. Every tool family records its source and evidence limit. Costs, complete unlock edges, exact retail labels, mission templates and context restrictions still have unresolved fields. A retail Collections/data audit is required to close the reference inventory.

Sources: [Ship Tools](https://spore.fandom.com/wiki/Ship_Tools), [Ship Abilities](https://spore.fandom.com/wiki/Ship_Abilities), [Badge](https://spore.fandom.com/wiki/Badge), [Space achievements](https://spore.fandom.com/wiki/Space_stage_achievements), [hidden achievements](https://spore.fandom.com/wiki/Achievements). Individual manifests link the specific variant sources.

## Single owning task per responsibility

Every tool family has one `owner` from TASK_BOARD.md. Dependencies do not create a second owner: C01 owns what a weapon does, P01 owns how an achievement unlocks its purchase, V01 owns how its control is presented, and Q01 owns session verification. One weapon is never counted as four independently delivered tools.

| Owner | Required behavior and acceptance boundary |
| --- | --- |
| I01 | Persistent personal ship and clock across surface, orbit, system and galaxy; no scene-specific inventory or resource resets. |
| E01 | Navigation range, signals, scanning, discovery, cargo capacity, commodities, markets, wormholes and distant exploration goals. Actual collection/deployment behavior belongs to L01. |
| L01 | Abduct/deploy varied organisms and objects, bounded ecological support, sanctuary/eradication/scale interventions and their consequences. A pod-only sampler does not satisfy this family. |
| C01 | Personal weapons, hull/energy upgrades, carried survival consumables, concealment/shield effects, targeting, damage and recovery. Three surface weapon roles and six persistent defenses now complement orbital encounters; the complete catalog remains required. |
| F01 | Allied fleet recruitment, capacity, formation, combat assistance, fleet support tools, persistent losses and relation consequences. Later first-person controls remain an additional tracked ambition. |
| U01 | Colony founding and design, production/happiness tradeoffs, storage, protective utilities, city defenses and planet capacity. Current export hubs cover only the first portion. |
| D01 | Expressive contact, relationship reasons, gifts/bribes/demands, alliances, peace, trade-route purchase offers and usable diplomatic tools. Automatic physical freight does not implement the reference economic-takeover route. |
| W01 | AI empire wars, raids, defense, territorial surrender/conquest, destruction and responses to extreme acts. A lone neutralized skiff is not an empire war. |
| T01 | Planet-wide temperature/atmosphere changes, energy versus charge costs, stability, ecological capacity, buildings and diplomatic outcomes. A warmed bed is not planet terraforming. |
| T02 | **Skipped by user.** Terrain brushes and stamps remain reference-only accounting. |
| T03 | **Skipped by user.** Coloring and reset remain reference-only accounting; unfinished implementation discarded. |
| L02 | Animal/tribal/civilization/space societies, visible advancement, intervention and emergence into diplomacy. Species, governments and planets remain distinct. |
| P01 | Badge counters, master ranks, achievement records, alternative unlock paths, prior upgrades and actual purchases; earned recognition and its presentation. |
| P02 | Archetype identity, nine distinct powers, twelve consequence traits and philosophy changes; our government attribute remains separate. |
| E02 | Optional contracts, timed hazards, emergencies and consequences; tutorial, mission log, cancellation/failure/reward rules; useful prevention or delegation. |
| X01 | Creation/editing systems and their explicit scope decisions. Creature creation remains deferred; ship/building editors and sharing scope cannot silently disappear from the parity audit. |
| S02 | Integrated sandbox, separate saves, deliberate cheats and story rewards. The human Sol start is a desired scenario, distinct from merely finding reference Earth. |
| V01–V08, A01–A03, Q01–Q02 | Interface/art/audio/input/accessibility/performance and verified delivery gates apply to every owning family. A working command or inventory row is insufficient for final acceptance. |

Reference behavior underpinning these boundaries: [Spore research](../SPORE_SPACE_STAGE_RESEARCH.md), [interface contract](../SPORE_INTERFACE_CONTRACT.md), [fleet behavior](https://spore.fandom.com/wiki/Space_fleets), [terraforming](https://spore.fandom.com/wiki/Terraforming), [trade routes](https://spore.fandom.com/wiki/Trade_Route). Acceptance wording above is this project's requirement, not copied retail documentation.

## Concrete corrections to current progress claims

- **Three pilot badges are not three reference-complete families.** Explorer counts distinct visits; Merchant counts distinct commodity routes; Defender counts neutralizations. Reference activities and thresholds differ; the three-slot escort bridge uses these pilot tiers while reference master ranks/fleet unlocks remain absent.
- **The recovered shroud is a shield-like damage reducer.** It provides no invisibility; do not count Cloaking Device as implemented.
- **Four initial weapon roles are not the weapon catalog.** The orbital arc lance is now joined by a surface laser, homing missile and ground-area bomb. Multiple tiers, automatic defense, ground-pulse, consumable and support roles remain missing. The blaster reference also limits which weapons work outside an atmosphere; our orbital combat is an explicit extension, not proof of surface parity. [Blaster](https://spore.fandom.com/wiki/Blaster).
- **Paid freight is an endorsed extension.** It does not close economic takeover, system purchases or all shop progression.
- **The thermal array is still a local planting tool.** Separate [global climate tools](../PLANET_CLIMATE.md) now provide both axes and real colony/diplomatic outcomes. [Specimen collection and plant stabilization](../PLANET_BIOSPHERE.md) now connect to complete food-chain capacity and habitat loss; combined/extreme tools remain missing. Climate potential and ecosystem completion are separate states.
- **The current sector chart is functional travel scaffolding.** [System-scale navigation](../SYSTEM_NAVIGATION.md) now connects real planet destinations and the shared travel clock. Broader planet surfaces, signals, wormholes, the galactic core and final presentation remain open.

## Next implementation target

Subsequent [ship capacity](../SHIP_CAPACITY.md), [repair supply](../REPAIR_SUPPLIES.md), [surface combat](../SURFACE_COMBAT.md) and [allied fleet](../ALLIED_FLEET.md) checkpoints implement purchased hull/energy tiers, finite repair stock, three surface weapon roles and persistent allied escorts with real damage/losses. The manifests above retain their stated implementation-comparison commit. The [climate checkpoint](../PLANET_CLIMATE.md) now adds eight personal axis tools with global visuals, costs and consequences. The [biosphere checkpoint](../PLANET_BIOSPHERE.md) now connects collection, release and ecological stabilization. The [system navigation checkpoint](../SYSTEM_NAVIGATION.md) now connects the planet/system/sector hierarchy to persistent paid travel. [Progression](../EXPEDITION_PROGRESSION.md) now connects ten scenario families to master promotion thresholds, persistent awards, pinning and paid shop alternatives. This is not full reference badge/achievement coverage or master-rank fleet capacity. Next prioritize **optional space encounters and meaningful decisions (E02/E01/D01)**, preserving personal exploration, meaningful costs and persistent outcomes. Avoid deepening nursery cultivation or expanding the food-web corpus before remaining spaceship breadth. No passive energy regeneration; home recharge stays free.

Then continue spaceship equipment, diplomacy, trade and empire conflict; additional planet modification is deferred. Keep the native HUD/flight/audio review gates active. User-approved T02/T03 exclusions and T01 deferral supersede the earlier world-manipulation schedule. Other reference families still require explicit accounting.

## Check-in use

Run `powershell -ExecutionPolicy Bypass -File tools/ParityReport.ps1` for family/variant ownership counts and unresolved audit entries. It validates structure and task references only. Consult the board and playable evidence for actual status. Do not turn rows, tests, source lines or catalog counts into a game completion percentage.
