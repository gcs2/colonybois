# Project working agreements

## Checkpoints and backup

- This repository is tracked at https://github.com/gcs2/colonybois.
- Keep changes in small, reviewable commits. After a working milestone and relevant validation, commit and push it before beginning unrelated feature or content work. Verify the remote commit hash; a local commit alone is not an off-device backup.
- Do not accumulate an entire development session without a checkpoint. If work is incomplete, keep that status explicit in its checkpoint message rather than calling it finished.
- Keep downloaded runtimes, build output, save files and rejected art out of Git. Preserve source, configuration, tests and approved design documents.
- Never force-push or rewrite published history as part of routine backup. Report authentication or push failures immediately.

## Documentation ownership

- Start with docs/README.md and docs/NEXT_SESSION.md. TASK_BOARD.md is the sole production queue; PRODUCTION_GOAL.md owns the objective; ROADMAP.md owns milestone gates. Each documentation file has one primary purpose in docs/DOCUMENTATION_MAP.json. Run tools/DocumentationReport.py after documentation moves or additions.
- docs/history contains superseded snapshots and unselected alternatives, not current instructions. Update the owning record rather than appending another competing latest override. Character art/modeling/corpus production is deferred; read docs/reviews/MODELING_POSTMORTEM_2026-09-24.md before any reprioritized retry. No remaining fish/style revision is queued.

## Product constraints

- 24 September portrait exception: the user authorizes existing generated concepts as in-game 2D portraits. Tavi's isolated concept portrait is integrated; cleanup provenance lives in assets/aliens/tavi-portrait-v1.md. This does not reopen 3D modeling, new character design, fish revisions or cast expansion. Do not overlay the old procedural eyes/mouth on raster concept art or claim a static portrait is animated acting.

- Latest evening playtest rejects breadth without playability: clunky UI/combat, cheap audio, slow/jumpy navigation and small landing facades remain unacceptable. Read docs/reviews/PLAYABILITY_REBUILD.md. Prioritize full-screen navigation and responsive travel, an inhabited Morrow with city/port life and expressive communications, and a shared-geography whole-planet pipeline. Explorer badge feedback is the positive reference. Do not resume tool-catalog expansion or compulsory tutorial work ahead of these corrections. Literal Earth size is under discussion, not an approved engine migration.

- 23 September 2026 user scope correction: skip coloring and terrain sculpting; further planet-modification tools are not a current priority. Existing climate/ecosystem behavior stays intact. T02/T03 are explicit exclusions from the agreed delivery scope, not missing work to revive automatically or completed features. Further T01 expansion is deferred. Focus next on exploration, trade, diplomacy and consequential spaceship encounters.

- Latest visual rejection: no rounded icon wells, shiny copper-like borders or persistent selected-tool captions above the palette. Current SVG glyphs remain temporary; typography and planet art are rejected. Preserve named hover tooltips. Do not extend the rejected material style to other screens.

- The local terrain chart appears only on a planet's surface, never in orbital/system/galaxy flight. Use separate maps for those scales. The user endorses the Spore comparison board and requests an original icon/button vocabulary, broad content capacity and 1080p+ support; see docs/reviews/UI_ICON_VOCABULARY.md. Do not substitute text-only labels for recognizable controls where symbols work, or claim preview fixtures are playable content.

- Latest user playtest supersedes the ecology-led slice: read docs/direction/SPACE_STAGE_TARGET.md. Spaceflight, mouse-first tools, arrows/numpad, altitude/orbit, real danger, professional HUD, sound/music/VO and full Space Stage feature breadth are the active goal. Existing small-MVP exclusions are staging decisions, not final success criteria. A human Sol scenario is desired alongside the alien campaign. Do not expand the food-web catalog before fixing spaceship play. User permits browser-assisted audio production and is willing to pay; get a concrete price/license approved before purchase.

- Resume production from docs/NEXT_SESSION.md. Latest direction is docs/direction/SPACE_FIRST_DIRECTION.md: exploration, distinct living planets, supply chains and alien diplomacy take priority; cities support those systems. Preserve the authored-art pipeline but move its pilot to a planet expedition and scout ship. Read docs/research/FLIGHT_TECH_ASSESSMENT.md for an early bounded first-person flight test, and docs/direction/DIPLOMACY_AND_CHRONICLE.md for expressive contact/trade and persistent history. No engine migration or rendering rewrite is approved. Older city-first milestones are deferred.

- Godot 4.7.2, desktop, single-player. Exploration and trade precede full fleet battles. First-person ship flight/combat is a desired later capability; a small early flight/renderer feasibility test is appropriate without launching full combat production.
- Read docs/research/SPORE_SPACE_STAGE_RESEARCH.md: preserve personal ship/tool play, collection, visible world manipulation, expressive contact and optional hands-on trade. The richer economy, living worlds and timeline remain endorsed. Automate established repetition without removing discovery and experimentation; prove a small planet interaction before widening management or full combat.
- Art direction: original creepy-cute, expressive creatures and playful miniature worlds; a love note to Spore's space stage. No creature creator yet. The initial realistic cast board was rejected.
- The endorsed campaign foundation is a forgotten outpost, a corrupt local government and the Vanguard's rise, followed by living interstellar politics and discoveries about Earth. See docs/history/CAMPAIGN_FOUNDATION.md. The five earlier plots remain alternative explorations; the future-echo premise is not approved.
- Nations, planets and species are distinct. Spaceflight does not require planetary unification. Choices must change available actions and create visible obligations, not merely adjust bonuses.
- Current story and gameplay sources are docs/direction/STORY_CURRENT.md and docs/direction/SPACE_FIRST_DIRECTION.md. docs/history/PROJECT_VISION.md is historical. The modern 120,000-person city and Vanguard history remain available context; a mandatory long city-building opening is no longer the priority. The bounded urban tutorial exists; the full political opening does not.
- Urban order must retain alien divergence: circular civic spaces, unusual architecture and potentially benevolent megafauna transit. The latest conventional Earth-like city concept is not the final art direction. Creature transport is a future route/capacity mechanic, not a commitment to simulate every animal or passenger.
- SimCity 4-like urban fidelity is the target. Simulate population, jobs, services and political groups in aggregate; do not add individual citizen/household agents or world-wide per-person pathfinding. Ambient traffic and pedestrians must be capped visual effects. Profile before raising scope caps.
- Player-facing money is Marks, with history in data/catalog.json. The internal credits save key remains for compatibility; do not expose it as the currency's name.
- Read README.md for run/test/build instructions and docs/ROADMAP.md for milestone boundaries.
- The user rejected the current presentation as an early systems demo. docs/reviews/PLAYTEST_REVIEW.md records the critique, corrections and remaining gates. Do not call the city visually convincing or the tutorial successful based on tests, population counters or generated mockups. Native input playtesting and human readability/fun review remain necessary.

## Latest communicator corrections (24 September 2026)

- Reject flat blue Windows-style panels. Review the whole actual aesthetic against Field Instruments mocks with the visual critic, not just clipping. Equipment uses pictorial grids plus effects and flavor. Broader market/HUD conversion remains open.
- EU4 screenshot reference: compact recognizable icons with immediate named tooltips and actual shortcuts where bound. Keep original Field Instruments materials.
- Finished colony kits cost Marks only; crafting should be an alternative, not an additional charge. Crafting remains unimplemented. Cut Mark currency artwork is provisional; retain Marks and one treasury.

- User rejected the wide commodity row with details underneath as a regression. Use the compact equipment-style grid with selected-item details beside it for trading. Do not revive the wide layout based on critic approval; user preference is authoritative.
