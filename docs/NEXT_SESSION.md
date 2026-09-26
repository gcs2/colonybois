# Resume here

Updated 26 September 2026. TASK_BOARD.md is the sole production queue; PRODUCTION_GOAL.md owns the objective and ROADMAP.md owns milestone gates. This handoff records the current Sol integration checkpoint.

## Direction and evidence boundaries

The five approved or user-liked stills are together in [art/visual-canon](../art/visual-canon/README.md). The Spore evidence audit is closed with an insufficiency finding; it does not establish continuous motion, timing, input, or audio. The current V01/V04 runtime comparison remains open and rejected. Preserve the user's surface-follow camera, full 6x2 inventory, upper-left notifications, upper-right Marks, surface-only local chart, compact ALT, separate system/galaxy maps, and Field Instruments materials.

Build worlds through the documented recipe pipeline: persistent identity/seed/version and authored sites, one spherical geography sampler, stable regions and independent feature streams, reusable habitat kits, bounded scout-centered streaming, sparse stable-ID changes, and a connected expedition. Morrow remains the proving world; do not add ad-hoc decoration or planet families ahead of it. See [PLANET_GENERATION.md](systems/PLANET_GENERATION.md).

## Protected checkout and integration branch

- Main checkout: C:\Users\zephy\Documents\ChatGPT\New project, branch codex/frontier-prototype, last observed HEAD 46fc837c3a745c5147ce6d127e2704a4eb6c026d, dirty and six commits behind at that inspection. It remains untouched.
- Sol integration worktree: C:\Users\zephy\.codex\worktrees\r01-transition-audit\New project, branch codex/r01-v01-v04-transition-audit. Current integration HEAD at the beginning of this checkpoint was 873da01090d631bdec2d7df69b8b263e6ae702a8. The working checkpoint includes reviewed HUD, movement, persistence, Morrow recipe and surface-scene commits plus local recipe/HUD corrections.
- HUD implementer worktree: C:\Users\zephy\.codex\worktrees\v01-hud-surface-pass\New project, branch codex/v01-hud-surface-pass, last confirmed HEAD c7180177ead36de3db33c061efbccfddb37b8b8d. A bounded notice/card pass is in progress.
- World implementer worktree: C:\Users\zephy\.codex\worktrees\v04-morrow-world-pipeline\New project, branch codex/v04-morrow-whole-planet, last confirmed HEAD 5e30fd3d3721a164f00028337ee9630a59b4ff40. A bounded deterministic habitat-coverage pass is in progress.
- Remote hash for the current integration branch is not verified. The previous live GitHub check could not connect on port 443. Cached tracking refs are not proof.

## Integrated changes and verification

The integrated surface chart now fills more of its existing frame. The Morrow recipe supplies the same sampled relief and waterbody used by the local surface renderer and map; saved radial direction drives movement/re-entry, the feature window recenters at region boundaries, and sparse stable-ID changes survive save/reload and inactive-world migration.

Focused results on the integrated branch:
- test_planet_generation.gd: 21 assertions, zero failures, 0.67 seconds after moving the authored lake out of the landable site.
- test_surface_exploration.gd: 63 assertions, zero failures, 37.78 seconds after one-time ignored asset import.
- test_flight_hud.gd: 64 assertions, zero failures, 18.43 seconds after adding a six-pixel gap between discovery toast and objective.
No full suite was run. The imported Godot cache and generated .import/.uid sidecars are worktree-local; do not stage them.

The actual-renderer 1920x1080 synthetic mining capture is ignored at artifacts/visual-critic-surface-pass/mining/surface-mining-after-1080.png. An independent critic confirms the HUD and world changes are integrated together. The chart/inventory footprint is close to canon, but the playfield is still mostly empty pale ground; the seam card is detached and too large; the top-left pickup notice is faint; and the seam label is separated from its ring. This is not visual acceptance, native-input play, fun evidence, or performance measurement. The computer is in Silent mode; make no performance claim.

## Next work

Finish the two bounded visual lanes, integrate their exact commits, run only the directly relevant checks, and capture/review the same integrated Morrow state again. Keep the full inventory and chart/inventory frame sizes. The visual gate remains open until world features, target anchoring, interaction-card placement, and notice readability materially improve. Then resume the next task-board priority in the connected voyage.

Use Godot 4.7.2. Serialize imports, tests, and captures; use unique per-worktree run profiles. Keep generated captures, saves, runtimes, and rejected art out of Git. No purchases or paid terms without explicit approval.