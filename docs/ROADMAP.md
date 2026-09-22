# Roadmap and playtest gates

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

The next milestone is a human playtest of this build, not an automatic scope increase. There is no claimed 30–60-minute balance validation yet.
