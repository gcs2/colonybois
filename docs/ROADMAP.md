# Roadmap and playtest gates

The campaign direction now includes a developed urban opening. A–C below describe the existing prototype, not a finished campaign. Preserve that loop while testing the new opening in bounded slices. Full vision: [PROJECT_VISION.md](PROJECT_VISION.md); narrative: [STORY_CURRENT.md](STORY_CURRENT.md).

## Next: urban tutorial slice

Only schedule this slice now; estimate later work after measuring it. Show a modern, logically gridded city of approximately 120,000 with one editable district and aggregate background districts. Teach one utility or access problem, provide two useful responses, and retain one resulting capability/obligation. Money is Marks. The art study does not constitute implementation.

Gate: the player understands the city's scale, explains the bottleneck, sees who benefits from the repair, and wants to try the other response. Population totals must derive from district data. City simulation must use aggregates with capped visual traffic, not individual citizen agents. Measure frame time, simulation tick time and memory on the development PC; compare to the existing prototype before adding density or more editable districts.

## After the urban gate: national leadership and the frontier bridge

Add nation/site jurisdiction and two homeworld neighbors, one coup/rebellion decision expressed through existing economic and coalition systems, and a joint-versus-independent space-program choice. Carry one commitment into the existing colony loop. Do not introduce ground-combat mechanics for the uprising.

Gate: taking national power does not confer planetary ownership; both political routes offer useful, distinct actions; a neighboring nation matters after reaching space. A player can reach exploration without repeated civic errands. Save/load must preserve the new claims, commitments and outcomes.

## After the bridge: one living-story encounter

Use one discovery with two present-day interested parties, an economic or environmental consequence, and a recurring character. Prove the story advances through play before writing a full campaign event library. Keep historical facts fixed within a seeded scenario. Campaign unlock profiles and alternate scenario packages follow only after the authored path is satisfying.

Gate: the player understands why each party cares, has more than one viable response, and sees a persistent outcome. No recording-collection quota. The canonical final resolution remains a writing decision, not an implemented feature.

## Acceptance checks for the revised direction

- Seeded commands reproduce simulation state; switching views never resets or duplicates activity.
- Disconnected zones explain why they stall; climates create different useful layouts.
- Trade uses real stock, available routes and treaty access, including embargoes.
- Terraforming changes conditions and diplomatic reactions; future shared planets check affected jurisdictions.
- Saves preserve colonies, routes, relationships, projects, discoveries and any introduced campaign state.
- City totals equal their aggregates; decorative pedestrians and cars cannot change economic results.
- Peaceful progression and sandbox remain available without repetitive missions or story completion.
- Profile the existing three-colony/full-sector case and the new developed-city case separately before increasing caps.

## A — Colony toy: implemented

Play through roads, zones, utility shortages, and overlays. Gate: the player can explain why a district is stalled and improve it through layout. Look especially at frozen geothermal placement and arid water access. Tune growth and resource costs from observed play.

## B — Two-world loop: implemented

Galaxy navigation, world-specific layouts, colonization, internal resource transfer and persistence. Gate: the second colony offers a useful specialization rather than merely repeating the starting layout. Current starter kits are deliberately generous; vary them only after onboarding is clear.

## C — Core MVP: prototype implementation

Diplomatic agreements, three factions, automatic exports, six discoveries, climate recovery, and three ranks are playable. Gate: complete a peaceful session, develop two or three colonies, reach an alliance, and choose whether to alter a harsh planet. Record moments of waiting, repetitive actions, confusing explanations, and decisions that feel obvious. Adjust the design before adding breadth.

AI uses simple economic/environmental/territorial rules. Dynamic empire expansion, rival colonies and political events are future deepening work, not part of the present simulation. There are no tactical battles or war states in this build.

## D — Fleet slice: not implemented

One encounter; flagship plus six escorts at most; two ship roles; selection, move, attack, focus fire and retreat on a tactical plane. Pause strategy time during the encounter. Fleet losses must consume colony production to replace. Gate: a small battle is enjoyable on its own and makes tradeoffs in the colony economy. Add conquest only after passing this gate.

## E — Expand selectively

Only after playtesting: colony templates, additional planet types, research choices, deeper government policies and larger sectors. Introduce procedural faction combinations only after the authored three produce recognizable behavior. Keep strategic explanations visible.

## Visual direction

Current live scenes serve as coordinated visual prototypes: galaxy network, frozen settlement, and that settlement's orbital survey. They share a navy/mint interface, warm mineral markers, blue water markers and coral geothermal markers. The actual meshes are deliberately simple. Next art pass: consistent modular building silhouettes, a richer flagship, faction portrait concepts, and modest sound cues. Generated raster art can supply portraits and concept boards; game meshes still need separate construction and review.

## Verification recorded

Simulation suite: 91 assertions, including frontier fog, sandbox isolation, snapshot round trips and deterministic continuation. UI suite covers camera picking, navigation, changing views while simulation runs, founding a colony, both overlays, and pause/speed controls. The three-colony stress fixture contains about 285 placed cells across 12 systems. Timings are printed by each test run; they are simulation-only and do not establish a rendering FPS guarantee.

Playtest the existing loop alongside the next bounded urban slice. There is no claimed 30–60-minute balance validation yet, and the full campaign has no calendar commitment. Tactical fleet work follows the city-to-space bridge and core-loop validation.
