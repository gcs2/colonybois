# Two-day presentation target and galaxy correction

**Latest review:** the user endorses the surface environment's graphic fidelity, rejects the flat Jump card/UI, and requests living creatures and useful harvestable materials. See [LIVING_RESOURCES_AND_UI_DIRECTIONS.md](LIVING_RESOURCES_AND_UI_DIRECTIONS.md). This supersedes UI recommendations below; the remaining two-day boundary stands. The endorsed environment image is backed up at `art/concepts/surface-fidelity-target-20260923.png` (approval does not include its HUD or creature designs).

23 September 2026. Design checkpoint, not a shipped game change. Latest user constraint: imagegen must show something realistically approachable in the next couple of days. This bounds the visual pass, not the eventual game. Full Space Stage breadth remains the goal.

## Candidate images and limits

Built-in imagegen generated two targets from actual project screenshots. Exact [prompts](VISUAL_TARGET_PROMPTS_20260923.md) are tracked. Local candidates are `artifacts/visual-targets-20260923/galaxy-v1.png` and `artifacts/visual-targets-20260923/surface-v1.png`. They are ignored, unapproved concept images; their pixels are not backed up in Git. They are not game captures or evidence that any feature is implemented.

The surface image is useful because its cast is already present: scout, relay, bell walkers, lantern plants, rocks and water. Improve composition and material response before adding assets. Do not copy the generated foreground blur: sharp gameplay readability is preferable. Its denser ground cover is a direction to approximate with a small repeated kit and capped instances, not a requirement to model every pebble. It remains one visual study of a location, not proof of a traversable planet or convincing inhabited Morrow.

The galaxy image captures the intended scale and restrained interface, but has diagram inaccuracies: the displayed range is not precisely centred on Solace, and the local parsec scale is exaggerated relative to the visible galaxy. In-engine geometry must be correct. Use separate zoom levels: local jump range matters at close scale; the full galaxy overview shows location and explored territory, with the range shrinking appropriately. Strengthen the fog boundary beyond the subtle generated image. Never turn this picture into a static backdrop and call it a playable galaxy.

## What the screenshots tell us

The current surface has nearly equal brightness everywhere, isolated props in an obvious small circular basin, weak material separation and large disconnected UI blocks. Improving light direction, shadow readability, terrain variation, clustered prop placement and control hierarchy will do more immediately than another creature family.

The current galaxy code is explicitly a 12-node link graph. `sector_chart.gd` draws links; `expedition_session.gd` gates range by hop count. Full-screen layout did not correct either assumption. Calling it Galaxy alone would not fix it.

## First two working days: bounded target

These are effort allocations for a first playable visual pass, not a guarantee of final art quality or a complete galaxy simulation. If galaxy migration exceeds the allocation, finish and validate that checkpoint before surface polish; do not hide a fake galaxy behind a pretty picture.

| Order | Work | Evidence required |
|---|---|---|
| 1 / first day | Galaxy geometry and navigation prototype: seeded spiral distribution, stable positions, cursor-anchored zoom from neighborhood to galaxy, ship-centred parsec range, discovered versus unknown information, no permanent hyperlane diagram. Keep distant rendering cheap. | Actual in-engine capture plus input test: select a star, read distance, distinguish reachable/too far, zoom out and return to ship without losing orientation. |
| 2 / first day, continuing if necessary | Wire actual distance validation to travel and paid engine upgrades; retain energy costs, home recharge and save compatibility. Preserve authored destinations and IDs. | Out-of-range jump rejected by simulation; upgrading opens a previously unreachable destination. Reload preserves position, knowledge, upgrades and transit. A pictured selectable star must resolve to a real destination, or remain explicitly non-interactive in the prototype. |
| 3 / second day if navigation passes | Polish one existing surface scene: directional sunlight/ambient balance, matte ship materials, three rock variations, terrain color/slope blending, dark water, clustered existing flora and restrained exhaust/relay effects. | Same-camera before/after; near and far views remain readable; no asset or terrain collision regressions. No whole-planet claim. |
| 4 / second day | Compact HUD, consistent font hierarchy, visible hover/selected/disabled states, tooltips, icon-first controls, one contextual target. Preserve inventory and category access. | All controls still reachable at 1080p, 1440p and ultrawide; mouse and left-handed keyboard schemes checked. Surface local chart absent from system/galaxy. |

Measure frame time and memory against the existing build on the same PC. First baseline with EU4 closed, then optional contention check. Reduce alpha overdraw, instance counts and texture sizes before choosing expensive rendering features. Generate no replacement sound bank in this visual checkpoint; poor audio still has its own open acceptance gate.

## Galaxy: required behavior beyond the visual prototype

The target is a fully explorable galaxy with spiral structure, a core, dense star fields, discovery fog, living civilizations and engine-limited reach. The twelve authored systems become the starting neighborhood, not the boundary of the universe.

- Store each star's stable galaxy position in parsecs and calculate jump distance from those positions. The range indicator and command validator must use the same function. Never rename link count to parsecs.
- Use Spore's 3, 5, 8, 12 and 20 pc tiers as the parity reference. Badge eligibility plus purchase unlock drives; preserve non-errand advancement paths. Tiers and prices need balance review. Each tier must visibly open new routes or shortcuts.
- Fog represents knowledge: visible distant starlight is not knowledge of its planets, resources, ownership or inhabitants. Distinguish detected, visited and surveyed states. Reveal details through approach, exploration and appropriate contact; preserve them on save.
- Select a destination inside range directly. Show a single prospective jump or an explicitly requested multi-jump itinerary; trade routes are an optional overlay. Political access, energy and hostile encounters remain separate constraints.
- Use a deterministic seed, compact star records, spatial neighbor queries and lazy system generation. Render distant stars in batches and simulate active/offscreen economies at suitable aggregate rates. Do not create thousands of Node3D planetary scenes on startup.
- Preserve existing IDs, colonies, relationships and discoveries when embedding the authored neighborhood. Migrate saved positions and routes explicitly. Trade routing must be audited along with personal travel; an engine upgrade should not silently rewrite freighter capabilities.
- A fictional seeded galaxy is not an astronomically accurate Earth sky. Catalog-based sky work remains a separate requirement with provenance and observer coordinates.

Acceptance: multiple arms visible at overview; independent destinations beyond the original twelve; persistent discovery fog; meaningful range upgrades; short readable travel feedback; working save/load; no unbounded scene or economy load. Visual density alone is insufficient.

## Art specification for this pass

Reuse the authored Kiteback scout and its six-material palette. Improve lighting/exposure and scale readability before remodelling it. Give terrain broad coherent clay/sage/sand regions, rocks darker faceted silhouettes, water a distinct teal value, and flora restrained mint accents. Use three rock silhouettes with rotation/scale variation and the existing plant/creature rigs. Make one landmark recognizable at ordinary flight zoom. Do not create a giant prop library first.

Galaxy stars use warm/cool color and size variation with soft sprite halos; dust can be low-opacity layered sprites or simple shaders. Avoid a single huge photo texture, overbright bloom or an impossible nebula backdrop. UI remains quiet enough to see stars, with warm range/selection accents and distinct relationship colors. Color is reinforced by shape and tooltip text. No shiny copper, ornamental frames or pill-shaped buttons.

Godot's environment controls support lighting and fog adjustments, but feature availability differs by renderer. Keep the existing Compatibility renderer; no dependency on Forward+ screen-space effects or volumetric fog. Verify effects in the actual build rather than assuming the generated image proves feasibility.

## How story, combat and making things can fit later

Keep one coherent loop: discover a place, face an interesting choice, gain a useful capability, and reach something newly possible. The useful Skyrim inspiration is curiosity, landmarks and flexible character development; it does not require a second huge open-world RPG inside this game.

Proposed later demonstration: an old navigation facility still supplies an inhabited settlement. Its residents disagree about its future. Repairing it with a local partner provides a repeatable, paid production route to an unusual drive component; stripping its core gives an immediate unique component but removes local services and damages trust. Negotiation, investment and combat can lead to different outcomes. Discover the ancestors through people living with their infrastructure, not a sequence of audio recordings. Details are proposals, not new campaign canon.

Optional farming/factory pilot: one cultivable material, one mineral input and one fabrication machine produce one distinctive ship part. Habitat conditions influence yield; a discovered recipe specifies the combination. Once established, automate harvesting and production, charge upkeep, respect output capacity and finite market demand, and allow purchased inputs. Make a rare part change an action—such as a new scan mode—rather than just adding a tiny percentage. No daily watering, repeated deliveries, mandatory crop chores or random crafting lottery. Expansion must still compete for Marks, power and logistics.

Proposed specialization branches: Pilot (maneuvers and ship control), Envoy (contact and access), Maker (fabrication and equipment combinations). Unlock through meaningful accomplishments and purchases, not repetition. Prototype one interesting choice before a large skill tree. Existing badge/shop progression is the foundation, not a parallel leveling system.

On-foot exploration is a separate feasibility slice after ship/navigation feel passes: one small port or ruin, one interaction, one encounter, return to the ship. No promise of universal interiors, full humanoid animation, crowds or planetary walking in two days. Whole planets, convincing large homeworld cities, final combat, audio/VO and an expanded content corpus remain substantial later work.

## Research and interpretation

- [SporeWiki: Interstellar Drive](https://spore.fandom.com/wiki/Interstellar_Drive): range tiers 3/5/8/12/20 pc and badge-gated upgrade structure. Adapt progression away from required gopher work.
- [StrategyWiki: Space Stage](https://strategywiki.org/wiki/Spore/Space_Stage): zooming out from planet/system into galaxy and selecting a star inside a travel radius. Supports the navigation correction, not arbitrary fixed hyperlanes.
- [SporeWiki: Spore Galaxy](https://spore.fandom.com/wiki/Spore_Galaxy): many visitable systems, progressive zoom, inhabited worlds and discovery. Its scale is a reference; no promise to simulate all of that immediately.
- [Godot: Environment and post-processing](https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html): lighting, ambient contribution and renderer-dependent effects. Our recommended inexpensive art pass is an implementation judgment based on those controls and the current screenshots.
- [Bethesda: Welcome to Skyrim](https://bethesda.net/en-US/news/the-elder-scrolls-v-skyrim-welcome): free exploration and flexible skills. The proposed ship-focused adaptation is our design inference, not a claim about Skyrim production costs.

Next implementation checkpoint: correct the galaxy model and one useful engine-range progression before widening content. Compare actual gameplay to these candidates and keep the user's art/playability acceptance open.
