# Core alignment and the next content epic

> Design intent; task status and execution order live in the task board. [Documentation map](../README.md).

23 September 2026. User direction: establish the core loop and confirm understanding of all subsystems first, then flesh out a broad, deep corpus with synergies and cohesive story. **Alignment has not passed.** The latest screenshot rejection makes the interface correction an immediate prerequisite. Spore Space Stage parity is the baseline; no optional addition silently replaces a baseline feature.

Latest scope correction: coloring/sculpting are explicitly skipped and further planet editing is deferred. Existing climate/ecosystem behavior remains. Consult the current task board and SPACE_STAGE_TARGET for implementation status; older gap descriptions below describe the original alignment audit.

## Working loop to validate

Explore → discover useful things → choose how to spend energy, cargo space and risk → trade or invest → earn recognition → purchase capabilities → reach new opportunities. Personally flying and applying tools is the activity, not a menu wrapper around an economy. Colonies, ecosystems, diplomacy, combat and history change what the next expedition can achieve.

## Subsystem understanding and integration obligations

| Subsystem | Contribution to the loop | Required connection / current gap |
| --- | --- | --- |
| Flight, scales, fog and range | Discovery, approach, escape and route choice | One ship must move through surface, orbit, system and galaxy; current local flight and sector state are separate |
| Ship tools and upgrades | New ways to act on worlds | Category → item → target; acquisition, costs, cooldowns and visible effects; sparse prototype catalog |
| Energy, hull and recovery | Expedition planning and consequences | Packs, paid services, free homeworld; danger and retreat; galaxy travel energy and unified recovery still missing |
| Planets and geography | Different reasons to visit and different hazards | Shared seeded globe/site generation; generated landing regions still missing |
| Flora, fauna and ecology | Collection, habitability and valuable interventions | Bounded habitat/trophic aggregates; collection/deployment must affect actual planets |
| Cargo, commodities and artifacts | Scarce hold space and discovery value | Physical stock, provenance, quantity and capacity; surface store and hold cannot be conflated |
| Trade and supply chains | Profit, specialization and interdependence | Provider prices, finite demand, real production, access and route costs; optional personal trade plus automation of repetition |
| Colonies and cities | Production, services, administration and manpower | Expensive timed founding, aggregate development and finite demand; cities support space play, not a mandatory long opener |
| Terraforming and sculpting | Visible agency and new settlement/ecology opportunities | Climate/atmosphere, ecological tiers, terrain/color tools and consequences; most manipulation families missing |
| Diplomacy and civilizations | Access, conflict, allies and expressive encounters | Nations differ from species and planets; government differs from philosophy; ties to trade, uplift, borders and obligations |
| War, fleet and conquest | Danger, territorial decisions and material losses | Actual targets, allied ships, raids, defense and capture; isolated custodian is not empire warfare |
| Badges, ranks and shops | Recognition that changes capabilities | Alternate accomplishment paths → shop eligibility → purchase; shared event/progression ledger missing |
| Discoveries and campaign | Meaningful choices and reasons to explore | Forgotten outpost, Vanguard, fallible Earth ancestors, varied invaders; living people and material evidence, not repeated recordings |
| Chronicle | Consequences remain visible and remembered | Structured events for discoveries, choices, battles, losses, treaties and destruction; current logs are separate |
| Sandbox and scenarios | Replay and experimentation | Same core systems, seeded variation, deliberate cheats and story rewards; alien and human Sol scenarios remain distinct |
| HUD, art, animation and audio | Comprehension, personality and satisfying action | Reference-led original art, responsive feedback and reviewed sound; current HUD explicitly rejected |
| Persistence and performance | Trust in a continuous game | Stable IDs, one authoritative fixed-tick simulation, migrations and capped ambient visuals; no per-citizen world simulation |
| Editors and expansion features | Creation and extended play | Remain explicitly recorded as missing/deferred; cannot be silently counted as parity or assumed canceled |

See [SPACE_STAGE_TARGET.md](SPACE_STAGE_TARGET.md) for the full family ledger and [SPORE_INTERFACE_CONTRACT.md](../reviews/SPORE_INTERFACE_CONTRACT.md) for interface review gates. Understanding these responsibilities does not mean they are implemented.

## Gate into the content epic

Demonstrate a connected three-world session with one persistent ship, inventory, time and history. The player discovers, collects, compares a buyer, makes a purchase, handles a shortage or danger, receives meaningful recognition, and uses an acquired capability on a subsequent expedition. Costs must make the choice consequential. Peaceful progression must work without delivery quotas. Save/reload and changing views must preserve everything. The player must recognize the desired Spore-like controls and approve the direction through play.

The gate is a proof of the connected foundation, not completion of full feature parity. The next epic populates and completes the baseline systems alongside that ledger. It must not introduce a new design direction merely because it is easier to implement than an outstanding Spore feature.

## Next epic: content that supports other content

Production order within the epic:

1. Inventory the base-game feature/tool/upgrade families and map every proposed item to a real operation. Explicitly distinguish user-requested differences: no compulsory gopher grind, Marks, Escape utility menu, inventory pack use, original worlds/cast.
2. Author small complete content sets: acquisition, cost/scarcity, uses, buyer/ecology relationships, icon/mesh, feedback, narrative context and a playtest. A name or recolor does not count.
3. Prove several cross-system interactions, then grow the corpus. Common goods keep ordinary parameters and abundant supply; exceptional traits are authored for rare/epic/legendary content with clear scarcity constraints.
4. Make story respond to these interactions through characters, jurisdiction, ownership and consequences. Keep historical truth coherent within a scenario seed. A canonical first campaign and variable later scenarios need not fabricate contradictory history mid-play.
5. Review actual play: which items create new decisions, which are redundant, where does trade become an errand, and which tools delight? Expand from evidence rather than bulk generation.

Illustrative, unapproved content pitch: a biological material is valuable to one civilization, but harvesting its host species harms a useful ecosystem; cultivating it requires a costly facility and another world's input. A recovered artifact changes a present-day ownership dispute and unlocks a useful tool, making diplomacy alter the supply chain. This is a test of connected design, not newly approved lore.

Asset loop: gameplay role → dimensioned visual/species spec → concept approval → authored 3D source/materials/rig → icon and effects → in-engine near/far review → performance and gameplay review → catalog entry. Generated concept imagery is input, not automatic production geometry. See [RESOURCE_AND_UNLOCK_DIRECTION.md](RESOURCE_AND_UNLOCK_DIRECTION.md) for the resource policy.
