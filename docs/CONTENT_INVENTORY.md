# Content inventory and integration gaps

23 September 2026. Source audit of the current game, not a claim of Spore parity or final art approval. The user's breadth/depth requirement applies to the whole project, independently of any screenshot. See [CONTENT_CORPUS.md](CONTENT_CORPUS.md) and [SPACE_STAGE_TARGET.md](SPACE_STAGE_TARGET.md).

Stages are separate: **brief** specifies an identity; **asset** means a usable candidate file exists; **mechanic** means an actual rule runs; **integrated** names the playable context in which the rule can be reached; **reviewed** requires the relevant human art/input/fun judgment. Headless tests do not advance that last stage. A field-only or strategy-only implementation is not integrated across the game.

## Current inventory by family

| Family | Brief / identities | Candidate assets | Running mechanics and integration | Review / missing depth |
| --- | --- | --- | --- | --- |
| Ship equipment | Four entries in `data/equipment.json`: `scan`, `collect`, `warm`, `seed` | Four original shaded SVG icons; bounded tool particles | All four operate in Morrow's surface flight. Shared costs, range, cycle, target eligibility and UI. All start installed. | No acquired upgrades, defenses, weapons, power routing or installation choices. Farming is optional, not the main expansion direction. |
| Goods and resources | Field: living pod samples and cultivated produce. Strategy: construction materials and supplies. Marks is money, power is local capacity. | Pod mesh and inventory glyphs; no distinct manufactured-goods art library | Field samples can be collected/deployed; produce fills one finite six-unit nursery order. Strategy has extraction, production, reserves and automatic resource agreements. | Separate stores and saves; no shared cargo across flight/galaxy, multi-stage recipes or interstellar commodity markets. These are not four interchangeable cargo item types. |
| Lifeforms | 14 named species briefs, enumerated below | Two species have candidate GLBs; grazer procedural animation and pod motion run | Pod stock, collection, cultivation and grazer reserve rule exist in the field. Grazer behavior is bounded visual motion, not a planetary food web. | User liked the original creature direction; fuller animation/ecology approval remains open. Twelve briefs are not twelve working species. |
| Worlds and sites | Morrow / Morrow Basin. Strategic scenario: 12 systems, 24 planets, three environment definitions | Procedural globe and terrain; candidate relay GLB; strategic terrain/colony rendering | One personal-flight landing region and orbit chart. Strategic travel/fog/settlements work in their separate scenario. | Twenty-four strategic records do not mean twenty-four flight destinations. No human Sol scenario, shared travel or additional landable field regions. |
| Civilizations and characters | Veyr Directorate, Orin Consortium, Thalen Commune; governments and philosophies stored separately | Existing advisor portraits in the city prototype; no approved animated alien diplomatic cast | Three strategic factions react to treaties, trade and environmental choices; field contact is a local nursery exchange. | No persistent character cast or animated conversation system; field contact is not interstellar diplomacy. |
| Artifacts and discoveries | Six strategic entries: `archive`, `garden`, `beacon`, `lattice`, `seed`, `relay` | Field relay mesh; it is not the same record as the strategic relay discovery | Strategic discoveries offer authored resource/relationship decisions and persist. Field relay is scan-able and prompts spaceflight. | No discoverable equipment rewards, artifact inventory, contested ownership or connected ancestor campaign. Repeated numeric rewards are shallow content. |
| Ships and fleets | One player scout in the field; strategic flagship record; fleet expansion documented | Candidate `scout.glb`; current ship presentation rejected | Controllable surface/orbit craft, altitude, approach orders, zoom, thruster effects. Strategic flagship travels the graph separately. | No combat ships, escorts, losses, repair or hull damage; no ship acquisition. |
| Colonies and infrastructure | 13 catalog entries listed below; three environmental constraints | Procedural/courtyard building kit, city textures, advisor art; eight building-kit specs | Roads, zoning, utilities, service reach, crime/fire and colony projects in strategic/urban modes. Aggregate simulation only. | City appearance rejected; finite development demand, service capacity and shared flight logistics remain unfinished. Thirteen entries include zones and road, not thirteen finished building models. |
| Achievements and history | Eight strategic milestones; three rank labels; field chronicle events | Existing notification/guide presentation and candidate audio | Strategic ranks unlock optional specialization; field history records surveys, ascent/return, cultivation and deliveries. | Separate chronologies, no fleet-loss or war history, no unified rewards. Current celebrations are prototypes. |

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
