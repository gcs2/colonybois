# Resume here

Updated 25 September 2026. This is the operational handoff, not a second queue. [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md) owns the objective and acceptance criteria, [ROADMAP.md](ROADMAP.md) owns milestone gates, and [TASK_BOARD.md](TASK_BOARD.md) remains the sole production queue.

The active app-goal prompt still says to close the R01/V01/V04 source-to-mock audit first. The task board records R01 as concluded with an insufficiency finding and directs work to the M1 voyage; follow that current queue. The updated [production goal](PRODUCTION_GOAL.md) defines the broader end state.

## Checkout and hashes

Continue in `C:\Users\zephy\.codex\worktrees\orbit-surface-gate\New project` on `codex/orbital-transition-gate`. The verified code checkpoint is `0ae53885cac767644b1b9a94f35d3740f1e49f48`; it builds on the earlier goal/roadmap checkpoint `39719a6893b36a2f330246fc3e9b6d6730e06c01`. The remote still needs a live hash check after this documentation checkpoint is committed and pushed. The main checkout at `C:\Users\zephy\Documents\ChatGPT\New project` remains untouched.

## Current verification

- The 25 September surface field checkpoint uses recipe ID/seed/generator version for repeatable Morrow landforms and regional feature points across a 256 m-radius local field. Basin height is preserved through 39 m, blending into the seeded field by 96 m; species placements span Basin, Glassgrass Reach and Rillstone Shelf. Surface position is preserved across orbit/return and migrated saves. This is not whole-sphere travel, streamed terrain, or dense interactive fauna.
- Selective focused checks passed: `test_expedition_session.gd` 48 assertions/10.86 s; `test_flight.gd` 37/6.24 s; `test_flight_hud.gd` 52/6.69 s; `test_surface_exploration.gd` 41/0.65 s. No full suite was rerun. The test runner lists 45 cases. A trial full-field map zoom merged nearby target markers and failed HUD interaction checks; it was reverted. The live chart remains a panning 80 m local chart.
- Four actual synthetic runtime views at 1080p/1440p were recaptured for surface/orbit. The independent critic rejected both against approved canon: sparse broad orange terrain, oversized scout and three visible item slots on surface; small globe, empty orbit composition and clipped wreck label in orbit. The upper-right Marks/Cargo readout is now legible with no duplicated Marks text. These stills do not prove native controls, route behavior, movement, performance or acceptance.

- The 18-portrait item mapping, campaign HUD sizing adjustment and synthetic camera-trace harness are in the code checkpoint. Flight HUD and encounter action buttons now accept keyboard focus, with a restrained ivory/gold focus style. The focused `test_flight_hud.gd` passed 52 assertions with zero failures in 4.52 seconds. No full suite was run. Native Tab traversal and rendered focus visibility remain unverified.
- The cold worktree had no import cache: cargo capture and headless editor import logged missing `.godot/imported/*.ctex` resources and a `scripts/main.gd:684` `tabs` error; they produced no cache or usable capture.
- In the warm worktree, the focused HUD check passed, but the fresh 12-image cargo capture produced no new output or images and was stopped. The launcher reported 216.11 seconds; Godot had used 61.30 CPU seconds. The existing 13 cargo-review files, dated 25 September 2026 around 18:40 local, are pre-change evidence.
- A later isolated GUI attempt to run `tests/review_camera_follow.gd` with profile `m1-camera-follow-review` produced no CSV, images, or completion output. The process was stopped after 233.03 seconds elapsed and 65.56 CPU seconds; no Godot process or temporary profile override remains. Do not repeat this harness without first finding a cheap cause/fix.
- A separate native game launch used profile `m1-native-playtest`, but the Windows Computer Use helper timed out and then failed with `GetCursorPos: Access is denied`. The verified game process was stopped; no native controls were applied and no gameplay verdict was obtained.
- Earlier portrait/HUD-size/camera-trace changes still lack user acceptance. The fresh critic verdict applies only to this surface/orbit capture set and is rejection, not approval; continue using the user-approved Field Instruments images as ground truth.

## Next work

Continue Roadmap M1 from [TASK_BOARD.md](TASK_BOARD.md): the connected, native-input three-world voyage with discovery, danger, contact, trade, upgrade, return and save/resume. Preserve the open transition-parity gate until there is an uninterrupted input-recorded expedition. Prioritize playable travel over another broad capture run. Diagnose native desktop-control availability before another GUI review; any capture must be small and demonstrably cheap, matched to approved canon, with critic and user verdicts kept separate.

## Run discipline

Use Godot 4.7.2 and `tools/RunGodot.ps1 -Profile <unique-label>` for isolated user data; pass the engine path when needed because `.tools` is not copied into worktrees. Check for existing Godot processes before launching and serialize imports, tests and captures. Use `tools/Test.ps1 -Tests <case>` for focused checks; `-All` requires an explicit reason. Run `tools/DocumentationReport.py` after documentation changes. Do not claim performance, audio, native playability or acceptance from synthetic captures or tests. No paid terms or purchases without explicit approval.
