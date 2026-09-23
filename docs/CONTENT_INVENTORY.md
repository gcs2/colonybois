# Content inventory and integration gaps

23 September 2026. Source audit of the current game, not a claim of Spore parity or final art approval. The user's breadth/depth requirement applies to the whole project, independently of any screenshot. See [CONTENT_CORPUS.md](CONTENT_CORPUS.md) and [SPACE_STAGE_TARGET.md](SPACE_STAGE_TARGET.md).

Stages are separate: **brief** specifies an identity; **asset** means a usable candidate file exists; **mechanic** means an actual rule runs; **integrated** names the playable context in which the rule can be reached; **reviewed** requires the relevant human art/input/fun judgment. Headless tests do not advance that last stage. A field-only or strategy-only implementation is not integrated across the game.

## Current inventory by family

| Family | Brief / identities | Candidate assets | Running mechanics and integration | Review / missing depth |
| --- | --- | --- | --- | --- |
| Ship equipment | Four original tools plus arc lance, recoverable shroud, reserve energy packs and purchased cargo/drive upgrades | Four authored tool icons, provisional equipment glyphs and capped particles | Surface tools, three orbital threats including dodgable warnings, inventory energy use, finite recharge and real paid hold/range/emitter upgrades now share one campaign | Original ship/HUD/audio quality remains rejected/provisional. Full tools/weapons/upgrade tiers and installation choices remain missing. |
| Goods and resources | Alloy billets, purified water, resonant glass; living pod specimens and cultivated produce; colony materials/supplies and Marks | Pod mesh and inventory glyphs; manufactured commodity artwork missing | Shared ship cargo with provenance, finite planetary stock/demand, environmental prices, actual home-colony exports and purchased upgrades. Diplomacy changes real quotes | Owned outposts now produce at real cost into capped warehouses; markets replenish slowly within caps. Paid automatic carriers now move real warehouse goods and appear on the sector chart; carrier 3D art, manufacturing recipes and broad resource variety remain missing. |
| Lifeforms | 14 named species briefs, enumerated below | Two species have candidate GLBs; grazer procedural animation and pod motion run | Pod stock, collection, cultivation and grazer reserve rule exist in the field. Grazer behavior is bounded visual motion, not a planetary food web. | User liked the original creature direction; fuller animation/ecology approval remains open. Twelve briefs are not twelve working species. |
| Worlds and sites | Morrow / Morrow Basin. Strategic scenario: 12 systems, 24 planets, three environment definitions | Procedural globe and terrain; candidate relay GLB; strategic terrain/colony rendering | One shared expedition visits 24 orbital destinations and three landable pilot worlds. Two unclaimed surfaces support paid ship-delivered export outposts and persistent site coordinates. | Twenty-four orbital destinations do not mean twenty-four landable worlds. Human Sol, further surfaces and finished planet artwork remain missing. |
| Civilizations and characters | Veyr Directorate, Orin Consortium, Thalen Commune; government/philosophy/species are distinct. Three candidate named representatives in data/diplomacy.json | Three original editable SVG busts with gaze, blink and response poses; contact_representatives_v1.json supplies art specifications | Territorial first contact; attitude/reasons; real trade pricing, transit pledges, chart-sharing alliances, one-time goodwill and exclusive surveys in personal flight | Portrait candidates are not approved final art or 3D rigs. Voice, military obligations, war diplomacy and broader society AI remain missing. |
| Artifacts and discoveries | Six strategic entries: `archive`, `garden`, `beacon`, `lattice`, `seed`, `relay` | Field relay mesh; it is not the same record as the strategic relay discovery | Strategic discoveries offer authored resource/relationship decisions and persist. Field relay is scan-able and prompts spaceflight. | No discoverable equipment rewards, artifact inventory, contested ownership or connected ancestor campaign. Repeated numeric rewards are shallow content. |
| Ships and fleets | One player scout in the field; strategic flagship record; fleet expansion documented | Candidate `scout.glb`; current ship presentation rejected | Controllable surface/orbit craft, altitude, approach orders, zoom, thruster effects. Strategic flagship travels the graph separately. | No combat ships, escorts, losses, repair or hull damage; no ship acquisition. |
| Colonies and infrastructure | 13 catalog entries listed below; three environmental constraints | Procedural/courtyard building kit, city textures, advisor art; eight building-kit specs | Roads, zoning, utilities, service reach, crime/fire and colony projects in strategic/urban modes. Aggregate simulation only. | City appearance rejected; finite development demand, service capacity and shared flight logistics remain unfinished. Thirteen entries include zones and road, not thirteen finished building models. |
| Achievements and history | Explorer, Merchant and Defender pilot families; three paid upgrades; existing strategic milestones/ranks; structured expedition chronicle | Badge/progress panels, notifications and animated contact candidates; reward art/audio still provisional | Alternate eligibility changes purchasable hold/range/emitter. Snapshot v7 records contact, trade, colonies, freight, combat, arrivals and equipment. Defender has only three available contacts | Full reference badge families/master ranks, reward animation and complete war/fleet/story timeline remain unfinished. |

Evidence: `data/catalog.json`, `data/morrow_planet.json`, `art/specs/species_catalog_v1.json`, `art/specs/building_kit_v1.json`, `scripts/simulation.gd`, `scripts/encounter_state.gd`, `scripts/encounter.gd`, `scripts/grazer_motion.gd`, `scripts/city_rules.gd`. Review history: [TASK_BOARD.md](TASK_BOARD.md), [PLAYTEST_REVIEW.md](PLAYTEST_REVIEW.md), [NEXT_SESSION.md](NEXT_SESSION.md).

## Species records

| ID | Name | Asset / mechanic / integration |
| --- | --- | --- |
| `lantern_pod` | Lantern pod | Candidate `pod.glb`; field identity `pod`, collection reserve, deployable seed, growth and finite produce order. Proposed wider habitat/synergy rules are not implemented. |
| `bell_grazer` | Bell grazer | Candidate `grazer.glb`; field identity `grazer`, scanning and reactive motion. Native reserve is enforced by the collecting rule, not an ecosystem population model. |
| `veil_reed` | Veil reed | Brief only. Ambient reeds are scenery, not a working implementation of this species. |
| `ember_lichen` | Ember lichen | Brief only. |
| `sail_frond` | Sail frond | Brief only. |
| `bloom_float` | Bloom float | Brief only. |
| `frostlace` | Frostlace | Brief only. |
| `pollen_imp` | Pollen imp | Brief only. |
| `pebbleback` | Pebbleback | Brief only. |
| `silt_whisk` | Silt whisk | Brief only. |
| `hush_fungus` | Hush fungus | Brief only. |
| `ribbon_kite` | Ribbon kite | Brief only. |
| `glass_mantis` | Glass mantis | Brief only. |
| `cloud_manta` | Cloud manta | Later megafauna brief only; no transport network. |

## Other existing identities

Infrastructure: `road`, `habitat`, `industry`, `service`, `power`, `life_support`, `extractor`, `spaceport`, `terraformer`, `police`, `fire`, `clinic`, `transit`. Their running limitations are recorded in README and the city systems documents.

Strategic milestones: First export; Worldshaper; First discovery; Three horizons; New beginning; Growing community; Harsh-world pioneer; First alliance. Ranks: Captain, Pathfinder, Steward. Field journal entries are separate event IDs; neither count should be inflated by counting each delivery as a new achievement design.

## Equipment authoring contract now in code

`data/equipment.json` is authoritative for the four current tools' stable IDs, names, categories, target sets, scan requirements, reach, cycle, energy/sample cost, icons, palette/effect colors, constraints and acquisition descriptions. `scripts/equipment_catalog.gd` validates it and provides defensive copies. Commands, keyboard slot order, mouse approach, HUD, equipment inspection and particles consume it. Costs are paid only after final command validation. Unknown tool selection does not cancel or corrupt the current tool.

There is no save migration: version 3 field snapshots retain their existing shape and version 1/2 migration paths. Every current tool starts installed. The acquisition field describes that fact; it is not an unlock system. World-specific effects, reserve/capacity rules, audio behavior and animations remain explicit code. Adding a JSON entry alone cannot invent a new command handler, animation or sound. The validator deliberately rejects unsupported handlers.

The current layout still has four number-key slots and three categories. Expanding the catalog requires pagination/shortcut/layout review as well as mechanic coverage. Do not silently claim an unlimited equipment UI.

Verification: 27 equipment checks include malformed definitions, missing icons, duplicate/unknown handlers, exact range limits, defensive copies, changed tuning reaching both HUD and command, cancellation, and no double spending. The complete suite passes 380 assertions plus UI checks, including prior save migrations and deterministic continuation. Rendered HUD and the 1280×720 equipment panel were inspected for description fit. Build `build/versions/20260923-030715/FrontierWorlds.exe` and its exported-pack smoke test passed; Play.cmd selects that build. These checks do not approve the UI visually.

## Next playable expansion

The next content work should create a space-adventure decision rather than extend the planting lesson. Start with the missing hull/damage/recovery foundation and one readable orbital threat, then a useful countermeasure or exploration reward with a real acquisition path. A tool must offer a new action with a cost, a target and a reason to choose it. Carry its unlock, energy use, damage and repair through saves before multiplying variants.

Shared ship/cargo/clock/location/history across the strategic and personal-flight views remains the prerequisite for a multi-world supply-chain set. After that bridge, introduce related content together: a harsh world, a useful deposit, equipment that changes access, a faction with demand and a persistent route. Expand native species where their interactions change that exploration/trade decision. This sequencing does not remove any family from the full objective.

## Orbital encounter update

The personal ship shares hull, energy, equipment and cargo across the sector. Morrow's custodian/wreck/pulse hazard now coexist with Nacre's pursuing raider and Kestrel's anchored sentry, which use dodgable 3D warning volumes. Defeat recovery, one-time cargo salvage and a paid emitter upgrade are integrated. Four starting surface tools, one energy weapon, one paid damage upgrade, one acquired shroud and three authored enemies are implemented; fleets, war and a full weapon corpus remain missing. Candidate ships, HUD and audio are unapproved. See [ORBITAL_ENCOUNTERS.md](ORBITAL_ENCOUNTERS.md).
