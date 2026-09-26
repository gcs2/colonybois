# Resume here

Updated 25 September 2026. This is the operational handoff, not a second queue. [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md) owns the objective and acceptance criteria, [ROADMAP.md](ROADMAP.md) owns milestone gates, and [TASK_BOARD.md](TASK_BOARD.md) remains the sole production queue.

## Checkout and hashes

Continue in `C:\Users\zephy\.codex\worktrees\orbit-surface-gate\New project` on `codex/orbital-hud-camera-review-warm`. The current tree was clean at code checkpoint `bf14235dd946b2beabf2116fd9d51ab2eef1499d`; the goal/roadmap/task-board clarification is commit `38b3e41d6a5dc3eca997cdbbcdaf41f730dcf6ea`. This branch is local and has not been pushed or verified as an off-device backup. The main checkout at `C:\Users\zephy\Documents\ChatGPT\New project` remains untouched.

## Current verification

- The 18-portrait item mapping, campaign HUD sizing adjustment and synthetic camera-trace harness are in the code checkpoint. Focused `test_flight_hud.gd` passed 50 assertions with zero failures in 4.41 seconds (5.37 seconds including the wrapper). No full suite was run.
- The cold worktree had no import cache: cargo capture and headless editor import logged missing `.godot/imported/*.ctex` resources and a `scripts/main.gd:684` `tabs` error; they produced no cache or usable capture.
- In the warm worktree, the focused HUD check passed, but the fresh 12-image cargo capture produced no new output or images and was stopped. The launcher reported 216.11 seconds; Godot had used 61.30 CPU seconds. The existing 13 cargo-review files, dated 25 September 2026 around 18:40 local, are pre-change evidence. The synthetic camera harness has not run.
- There is no new critic verdict, user verdict or visual acceptance for the portrait/HUD-size/camera-trace changes. A successful automated HUD test does not supply that evidence.

## Next work

Continue Roadmap M1 from [TASK_BOARD.md](TASK_BOARD.md): the connected, native-input three-world voyage with discovery, danger, contact, trade, upgrade, return and save/resume. Preserve the open transition-parity gate until there is an uninterrupted input-recorded expedition. Prioritize playable travel over another broad capture run. Consider a smaller one-state runtime capture only if the warmed setup makes it demonstrably cheap; capture the same state as approved canon and keep critic and user verdicts separate.

## Run discipline

Use Godot 4.7.2 and `tools/RunGodot.ps1 -Profile <unique-label>` for isolated user data; pass the engine path when needed because `.tools` is not copied into worktrees. Check for existing Godot processes before launching and serialize imports, tests and captures. Use `tools/Test.ps1 -Tests <case>` for focused checks; `-All` requires an explicit reason. Run `tools/DocumentationReport.py` after documentation changes. Do not claim performance, audio, native playability or acceptance from synthetic captures or tests. No paid terms or purchases without explicit approval.
