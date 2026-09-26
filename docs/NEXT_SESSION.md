# Resume here

Updated 26 September 2026. This is the operational handoff, not a second queue. [TASK_BOARD.md](TASK_BOARD.md) remains the sole production queue; [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md) owns the objective and [ROADMAP.md](ROADMAP.md) owns milestone gates.

## Direction and audit status

The audit of the available Spore navigation-transition evidence is closed with an insufficiency finding: paused source captures and the manual support scale-specific states and documented controls, but do not establish one continuous input-recorded system-to-surface trip, timing, or audio. Keep source-motion parity open until that evidence exists. The broader R01 Space Stage feature inventory is still active research; these are separate questions.

Follow the current task board. Its first item is V04 planet-scale Morrow exploration, then the approved runtime surface/HUD, system-map correction, and the M1 voyage. The older M1-first ordering in this handoff was stale.

## Checkout and remote

Continue in C:/Users/zephy/.codex/worktrees/frontier-hud-planet-continuity/New project on codex/hud-planet-continuity, HEAD 13056d7465c48b1fa6b016d7f062e44f165f9ac3. The working tree has uncommitted camera/HUD and surface-coordinate/window changes; do not stage the generated .import/.uid sidecars or claim these changes are backed up. The main checkout at C:/Users/zephy/Documents/ChatGPT/New project remains untouched.

This branch has no configured upstream. A direct origin lookup failed because GitHub was unreachable from this environment; the current remote hash is unknown. Do not report a push or remote verification.

## Current implementation and evidence

The orbit camera was moved closer to Morrow and the flight HUD now hides the local terrain chart outside surface mode. Planet-fixed direction and deterministic regional feature records are present, but the ship is still clamped to the 256 m planar field and the encounter terrain still comes from PlanetGeography. No adjacent terrain region is traversable yet, and orbital and surface geography are not one source of truth.

The latest actual 1920×1080 runtime captures are local ignored artifacts at artifacts/visual-critic-surface-pass/actual-orbit-1080.png and actual-surface-1080.png. An independent read-only review found that the orbit frame is fuller but still has large empty black space, a soft blue-gray planet, and no readable route; on the surface, the chart shows a lake that is not visible in the scene, terrain is sparse and uniformly rust-colored, and the scout/central target card dominate the view. Both stills remain rejected against the approved canon. They do not prove native movement, visual acceptance, performance, or fun.

The focused test_flight_hud.gd and test_flight_presentation.gd checks passed after the recent HUD/camera edit: 52 and 21 assertions respectively, 13.57 seconds combined. The targeted test_planet_surface_window.gd check passed with zero failures in 0.65 seconds; test_surface_exploration.gd passed 52 assertions with zero failures in 1.65 seconds. No full suite, native-input playtest, or performance measurement was run. A prior parser error was corrected before those checks; the interrupted test invocation is inconclusive and should not be repeated without a specific reason.

## Next work

Implement the V04 first gate described in [TASK_BOARD.md](TASK_BOARD.md): one real crossing from the Morrow Basin into an adjacent deterministic surface region, with terrain sampled from the same saved spherical recipe as the globe. Keep the loaded terrain/feature window bounded, preserve stable region and feature identities, demonstrate one useful life/resource opportunity, save and reload, then return from orbit to the same changed place. Use the existing recipe-to-play pipeline in [PLANET_GENERATION.md](systems/PLANET_GENERATION.md); do not widen the species catalog or decorate more disconnected tiles first.

For verification, use the narrow surface-coordinate/window checks that exercise the change, plus one actual boundary-crossing runtime view. Compare to the approved Morrow targets and obtain a separate critic verdict. Keep transition/source, native-input, visual acceptance, performance, and fun claims separate.

## Run discipline

Use Godot 4.7.2 and a unique tools/RunGodot.ps1 -Profile label. Check for existing Godot processes before a launch and serialize imports, tests, and captures. Use tools/Test.ps1 -Tests <case>; -All needs a major integration gate or explicit request. Run tools/DocumentationReport.py after documentation edits. No paid terms or purchases without explicit approval.
