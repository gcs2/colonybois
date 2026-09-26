# Resume here

Updated 26 September 2026. This is the operational handoff, not a second queue. [TASK_BOARD.md](TASK_BOARD.md) remains the sole production queue; [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md) owns the objective and [ROADMAP.md](ROADMAP.md) owns milestone gates.

## Direction and audit status

The R01/V01/V04 audit of available source → approved mock → current runtime evidence is closed with an insufficiency finding. Paused Spore frames and the manual establish scale-specific states and documented zoom/destination controls, not continuous motion, the video input, timing, or audio. The approved Morrow images are fixed still-image targets. The current local runtime evidence is limited to isolated orbit/surface stills; there is no system/approach/continuous input-recorded sequence, and the last cited integrated system/surface pair is no longer in the artifact directory. The new [transition storyboard brief](art/mock-requests/MORROW_SCALE_TRANSITION_STORYBOARD.md) asks for proposed states only. Keep source/runtime-motion parity unclaimed. R01's broader feature inventory remains active.

Follow the current task board. Its first item is V04 planet-scale Morrow exploration, then the approved runtime surface/HUD, system-map correction, and the M1 voyage. The older M1-first ordering in this handoff was stale.

## Checkout and remote

Continue on isolated branch codex/r01-v01-v04-transition-audit in C:/Users/zephy/.codex/worktrees/r01-transition-audit/New project, based on the verified pushed checkpoint 2428f2288917d12e2c41517090c65172f868d2dd. Verify local status and the remote hash before claiming backup. The user's main checkout at C:/Users/zephy/Documents/ChatGPT/New project remains dirty and six commits behind; leave it untouched. The older frontier-hud-planet-continuity worktree contains uncommitted surface/geography/HUD code and documentation plus generated .import/.uid sidecars; preserve it and do not stage it as part of this audit.

The Spore PNGs and JSON sidecars used in the audit remain in the dirty main checkout's ignored artifacts/references/spore/video/ directory, not in this clean audit worktree. Their filenames, timestamps, video URL, manual provenance, and limits are recorded in docs/research/SPORE_EXTENDED_VIDEO_EVIDENCE.md. The runtime captures remain ignored in the older review worktree; they are not portable evidence from this checkout unless copied deliberately and rechecked.

## Current implementation and evidence

The orbit camera was moved closer to Morrow and the flight HUD now hides the local terrain chart outside surface mode. Planet-fixed direction and deterministic regional feature records are present, but the ship is still clamped to the 256 m planar field and the encounter terrain still comes from PlanetGeography. No adjacent terrain region is traversable yet, and orbital and surface geography are not one source of truth.

The currently available runtime captures are ignored stills in the older frontier-hud-planet-continuity worktree: actual-orbit and actual-surface at 1080p/1440p, plus a later 1080p shared-geography surface view. Independent critique rejects orbit for empty dark space, a soft blue-gray planet and no clear route; the surface chart depicts a lake not visible in the scene, while sparse terrain and the central target card weaken exploration. The active artifact set has no system, galaxy, or approach runtime frame and no continuous/input-recorded sequence. These stills do not prove native movement, transition behavior, performance, fun, or user acceptance.

The focused test_flight_hud.gd and test_flight_presentation.gd checks passed after the recent HUD/camera edit: 52 and 21 assertions respectively, 13.57 seconds combined. The targeted test_planet_surface_window.gd check passed with zero failures in 0.65 seconds; test_surface_exploration.gd passed 52 assertions with zero failures in 1.65 seconds. No full suite, native-input playtest, or performance measurement was run. A prior parser error was corrected before those checks; the interrupted test invocation is inconclusive and should not be repeated without a specific reason.

## Next work

Implement the V04 first gate described in [TASK_BOARD.md](TASK_BOARD.md): one real crossing from the Morrow Basin into an adjacent deterministic surface region, with terrain sampled from the same saved spherical recipe as the globe. Keep the loaded terrain/feature window bounded, preserve stable region and feature identities, demonstrate one useful life/resource opportunity, save and reload, then return from orbit to the same changed place. Use the existing recipe-to-play pipeline in [PLANET_GENERATION.md](systems/PLANET_GENERATION.md); do not widen the species catalog or decorate more disconnected tiles first.

For verification, use the narrow surface-coordinate/window checks that exercise the change, plus one actual boundary-crossing runtime view. Compare to the approved Morrow targets and obtain a separate critic verdict. Keep transition/source, native-input, visual acceptance, performance, and fun claims separate.

## Run discipline

Use Godot 4.7.2 and a unique tools/RunGodot.ps1 -Profile label. Check for existing Godot processes before a launch and serialize imports, tests, and captures. Use tools/Test.ps1 -Tests <case>; -All needs a major integration gate or explicit request. Run tools/DocumentationReport.py after documentation edits. No paid terms or purchases without explicit approval.
