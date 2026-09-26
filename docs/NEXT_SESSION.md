# Resume here

Updated 25 September 2026. This is the operational handoff, not a second queue. [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md) owns the objective and acceptance criteria, [ROADMAP.md](ROADMAP.md) owns milestone gates, and [TASK_BOARD.md](TASK_BOARD.md) remains the sole production queue.

The active app-goal prompt still says to close the R01/V01/V04 source-to-mock audit first. The task board records R01 as concluded with an insufficiency finding and directs work to the M1 voyage; follow that current queue. The updated [production goal](PRODUCTION_GOAL.md) defines the broader end state.

## Checkout and hashes

Continue in `C:\Users\zephy\.codex\worktrees\orbit-surface-gate\New project` on `codex/orbital-transition-gate`. Current code checkpoint is `7e84e581bb7a75fb8cf2412aac32919304972740`; it includes the goal/roadmap checkpoint `39719a6893b36a2f330246fc3e9b6d6730e06c01`. The 39719a full hash was verified on the remote after push in the prior session; a later live lookup failed because GitHub was unreachable, so recheck after pushing 7e84e5 before claiming backup. The main checkout at `C:\Users\zephy\Documents\ChatGPT\New project` remains untouched.

## Current verification

- The 18-portrait item mapping, campaign HUD sizing adjustment and synthetic camera-trace harness are in the code checkpoint. Flight HUD and encounter action buttons now accept keyboard focus, with a restrained ivory/gold focus style. The focused `test_flight_hud.gd` passed 52 assertions with zero failures in 4.52 seconds. No full suite was run. Native Tab traversal and rendered focus visibility remain unverified.
- The cold worktree had no import cache: cargo capture and headless editor import logged missing `.godot/imported/*.ctex` resources and a `scripts/main.gd:684` `tabs` error; they produced no cache or usable capture.
- In the warm worktree, the focused HUD check passed, but the fresh 12-image cargo capture produced no new output or images and was stopped. The launcher reported 216.11 seconds; Godot had used 61.30 CPU seconds. The existing 13 cargo-review files, dated 25 September 2026 around 18:40 local, are pre-change evidence.
- A later isolated GUI attempt to run `tests/review_camera_follow.gd` with profile `m1-camera-follow-review` produced no CSV, images, or completion output. The process was stopped after 233.03 seconds elapsed and 65.56 CPU seconds; no Godot process or temporary profile override remains. Do not repeat this harness without first finding a cheap cause/fix.
- A separate native game launch used profile `m1-native-playtest`, but the Windows Computer Use helper timed out and then failed with `GetCursorPos: Access is denied`. The verified game process was stopped; no native controls were applied and no gameplay verdict was obtained.
- There is no new critic verdict, user verdict or visual acceptance for the portrait/HUD-size/camera-trace changes. Automated checks or old captures do not supply that evidence.

## Next work

Continue Roadmap M1 from [TASK_BOARD.md](TASK_BOARD.md): the connected, native-input three-world voyage with discovery, danger, contact, trade, upgrade, return and save/resume. Preserve the open transition-parity gate until there is an uninterrupted input-recorded expedition. Prioritize playable travel over another broad capture run. Diagnose native desktop-control availability before another GUI review; any capture must be small and demonstrably cheap, matched to approved canon, with critic and user verdicts kept separate.

## Run discipline

Use Godot 4.7.2 and `tools/RunGodot.ps1 -Profile <unique-label>` for isolated user data; pass the engine path when needed because `.tools` is not copied into worktrees. Check for existing Godot processes before launching and serialize imports, tests and captures. Use `tools/Test.ps1 -Tests <case>` for focused checks; `-All` requires an explicit reason. Run `tools/DocumentationReport.py` after documentation changes. Do not claim performance, audio, native playability or acceptance from synthetic captures or tests. No paid terms or purchases without explicit approval.
