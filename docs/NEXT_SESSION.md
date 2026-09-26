# Resume here

Updated 25 September 2026. This handoff points to the self-directed objective in [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md). [TASK_BOARD.md](TASK_BOARD.md) remains the sole production queue.

## Checkout and checkpoint

Continue in `C:\Users\zephy\.codex\worktrees\orbit-surface-gate\New project` on `codex/orbital-transition-gate`. The current branch includes the Morrow mining/production checkpoint and the new flight HUD, route-label, system-map and camera commits. The last feature commit before this handoff update is `05d199e` (`Keep flight camera tracking scout in orbit`); verify `git status`, `git rev-parse HEAD` and `origin/codex/orbital-transition-gate` before further work or claiming backup.

Preserve the main checkout at `C:\Users\zephy\Documents\ChatGPT\New project`; it contains unrelated changes and has not been used for this work. Keep Godot runs and review captures isolated by `tools/RunGodot.ps1 -Profile <label>`; the engine binary may be supplied with `-GodotPath` because `.tools` is ignored and is not copied into worker worktrees. Workers return commits; Sol integrates and pushes only the reviewed integration checkpoint.

## Current implemented checkpoint

- The flight palette and Inventory group now read actual campaign climate charges, carried freight, reserved colony kit and held species with live quantities. Existing action keys and the cargo drawer remain authoritative; the HUD does not create items or new economy actions.
- The system chart gives the planets more screen presence and a restrained star field. The galaxy route quote is positioned at 68% of its projected path, away from the ship-origin label in the reviewed fixture. Orbit contact/service views keep the camera focused on the ship with more responsive focus smoothing.
- The current one-recipe mining → Glassworks → Resonance focusing-head production loop remains a pilot, not broad manufacturing.

## Evidence and limits

Captured with Godot 4.7.2 on the RTX 5070 Ti using isolated GUI profiles. Ignored local review images include `artifacts/cargo-review/current-flight-tools-1080.png`, `current-flight-inventory-1080.png`, `current-freight-1080.png`, `artifacts/system_selected_1080.png` and `artifacts/system_sector_route_1080.png`. The cargo review harness generated 12 captures and its five campaign-immutability checks passed. Focused tests passed: `test_flight_hud.gd` (50 assertions, 4.17 s) and `test_flight_presentation.gd` (21 assertions, 3.79 s), 7.97 s total. No full suite or performance profile was run.

The independent critic found Marks and compact ALT readable, and confirmed the local chart stays on the surface while system/galaxy navigation use separate views. The cargo quantities are visible but most items still use indistinguishable generic glyphs; surface detail and top-left notification contrast remain far below the approved canon. Static images do not prove camera motion, native response, travel feel, audio, fun or user acceptance. Camera following still needs a moving-ship runtime capture. See [art/visual-canon](../art/visual-canon/README.md) and the [mock coverage register](reviews/VIEW_MOCK_COVERAGE.md).

## Next work

1. Finish the bounded V01/V02 inventory correction: give each existing cargo/specimen item a distinct pictorial glyph while preserving real counts, capacity and actions. Do not fabricate item art or alter economy rules to fill cells.
2. Return immediately to Roadmap milestone one: native-input, connected three-world flight/discovery/danger/contact/trade/upgrade/return/save-resume. Capture an input-recorded moving-ship segment so camera response and the still-open approach/landing transition gate can be assessed.
3. Keep the Morrow scene's large art gap visible in the queue, but do not let isolated surface polish delay the connected voyage. Continue the independent critic loop only for matched, material visual changes.

## Selective verification

`tools/Test.ps1` runs nothing without arguments, selects cases with `-Tests`, and requires explicit `-All` for the suite. Run only domain checks touched by the change and record duration; visual captures are separate evidence. Run `tools/DocumentationReport.py` when adding/moving docs. Check live processes and machine power mode before multi-instance review or profiling; run imports/performance measurements one at a time. No paid terms or purchases without explicit approval.
