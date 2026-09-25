# Core alignment and the next content epic

> Design intent; task status and execution order live in the task board. [Documentation map](../README.md).

25 September 2026. User direction: establish the core loop and confirm understanding of all subsystems first, then flesh out a broad, deep corpus with synergies and cohesive story. **Alignment has not passed.** The latest screenshot rejection makes the interface correction an immediate prerequisite. Spore Space Stage parity is the baseline; no optional addition silently replaces a baseline feature.

Latest scope correction: coloring/sculpting are explicitly skipped and further planet editing is deferred. Existing climate/ecosystem behavior remains. Consult the current task board and SPACE_STAGE_TARGET for implementation status; older gap descriptions below describe the original alignment audit.

## Working loop to validate

1. **Read a lead in the world.** The galaxy is a full-screen, spatial map with discovery fog, reachable-range constraints and ship-following travel. The system and planet views preserve the same geography and give a clear next place to go.
2. **Pilot and investigate.** Descend, move freely, approach a landmark, living creature, resource or wreck. Choose a pictorial category and tool, target the world directly, and receive immediate visual, audio and text feedback.
3. **Make a field decision.** Scan or collect useful cargo, uncover an upgrade or encounter danger. Finite energy, hull, cargo room and scarce finds make retreat, combat, tool choice or leaving something behind meaningful.
4. **Bring the result into civilization.** Meet a recognizable alien, use a shop or trade relationship, sell or keep goods, and see the price, capacity, attitude and consequence before committing. Colony production and supply routes make later expeditions more capable; they do not replace piloting.
5. **Carry consequences forward.** Record discoveries, agreements, losses and decisions in the chronicle. Achievements recognize varied play and unlock purchasable options; the player still pays and chooses what to install.
6. **Follow a new possibility.** A capability, relationship, map reveal or living-world change opens another route. Story reveals the ancestors through present-day people, contested evidence and consequences, not a chain of recording hunts.

This is the working core-loop target, not a claim that the connected experience is already fun or complete. Avoid compulsory gopher missions, passive energy regeneration and instant free colony establishment. Automate repetitive logistics only after the player has discovered and chosen them.

## What the Spore evidence changes in the plan

The inspected recording shows a useful continuity pattern across scales: the galaxy view places route and relationship information in the starfield; the system view shows the ship, star and orbital destinations; contact retains a large alien portrait with a short greeting and grouped actions; the shop changes to a pictorial equipment grid plus cargo and transaction details. The ship, its tools and condition remain recognizable anchors as the context changes. The local terrain chart belongs to the surface view, not galaxy or system navigation. These are observations from the sampled [video evidence](../research/SPORE_EXTENDED_VIDEO_EVIDENCE.md), not a claim that every transition or control was verified.

The user's firsthand notes for 6:30–7:10 add a candidate travel grammar: dialogue frames a journey; the camera follows the flagship; interstellar movement feels like an accelerated elastic snap with blip and flight sounds; a later zoom-out/spin supplies a more theatrical cutscene beat. These are experience notes, not yet independently verified timings, exact dialogue, easing curves or audio. Preserve them as design targets to test, not copied animation specifications. The audio still needs a separate listening review.

Translate those findings into four production rules:

1. **One place, several useful scales.** Keep the navigable world full-screen. Let the camera and information change as the player moves between galaxy, system, orbit and surface, while retaining the flagship as a visual anchor. Show discovery fog and reachable range in the galaxy plane; reserve the local terrain chart for the surface.
2. **Travel is an action, not a wait.** Selecting a reachable destination should visibly connect route choice, ship-follow camera motion, arrival and updated cost/state. Give ordinary jumps a fast, responsive, skippable swoop with readable motion feedback; reserve zoom/spin staging for a purposeful reveal. Do not hide a long empty timer behind a map.
3. **The player sees cause and consequence.** A click or tool choice should produce a visible ship/world response, a clear cost or risk, and a legible result. Keep contact character-led and purposeful; keep commerce a separate pictorial transaction view where cargo, quantity, price and capacity can be compared. Do not turn either into an undifferentiated text panel.
4. **The world remains the main attraction.** Keep routine instruments compact, show inhabited environments and alien life beyond the selected target, and put combat warnings/effects near the thing they describe. Tests and attractive mocks help diagnose these rules; only a playable human review can decide whether the result feels good.

## Next proof: review one connected expedition

Return to the **visual critic loop** before growing catalogs or opening another subsystem. Review one short connected expedition already possible in the current game: full-screen galaxy destination choice → system/interstellar travel → arrival and descent → one useful surface action → a consequential contact or transaction. Assemble the three-way comparison for each critical state: (1) timestamped Spore/manual evidence, (2) actual runtime capture, and (3) the closest approved Field Instruments mock. Start with the inspected 2:00 galaxy/system/contact/shop captures, plus the user's 6:30–7:10 travel/cutscene lead. For the latter, capture exact readable text and before/travel/arrival frames; keep the Gemini chronology and user audio impressions identified as hypotheses until corroborated. The review must include motion, not just endpoint screenshots, and 1080p plus a larger supported resolution.

Ask the critic to judge the full composition and the action sequence: can the player see where they are going, understand the selected tool and target, read the result and cost, feel the ship/camera move, notice a consequential risk or reward, and keep the world visually dominant? Include 1080p and a larger supported resolution. Record the three highest-impact mismatches and fix the first one in the live view, then rerun the same comparison. A static mock, clean crop, passing test or critic pass alone is not user acceptance.

Do not broaden the source denominator or add content corpus while this single loop still fails to read or feel coherent. Keep the remaining Space Stage inventory open and use it to prevent scope loss, not as a reason to postpone the playable core.

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
| Climate and ecological effects | Visible planetary agency and consequential choices | Existing climate/ecology tools remain; further planet editing, terrain brushes and coloring are outside current delivery scope |
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
