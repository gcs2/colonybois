# Resume here

Updated 25 September 2026. This handoff points to the self-directed objective in [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md). The [roadmap](ROADMAP.md) now makes replayability measurable: the baseline gate requires at least two distinct viable paths with persistent consequences. [TASK_BOARD.md](TASK_BOARD.md) remains the sole production queue.

## Checkout and checkpoint

Continue in `C:\Users\zephy\.codex\worktrees\orbit-surface-gate\New project` on `codex/orbital-transition-gate`. The current integrated feature checkpoint follows remote baseline `4f67e6b416c0446e57ea27d289cf02c9660ebd6f` and includes three isolated worker commits: `0ee489c` cargo icon lookup, `e3ea9d4` HUD icon wiring and `b786217` Morrow ground detail. The documentation checkpoint follows those feature commits; verify `git status`, `git rev-parse HEAD` and the exact remote tip before continuing or claiming backup.

Preserve the main checkout at `C:\Users\zephy\Documents\ChatGPT\New project`; it contains unrelated changes and has not been used for this work. Keep Godot runs and review captures isolated by `tools/RunGodot.ps1 -Profile <label>`; the engine binary may be supplied with `-GodotPath` because `.tools` is ignored and is not copied into worker worktrees. Workers return commits; Sol integrates and pushes only the reviewed integration checkpoint.

## Current implemented checkpoint

- The flight palette and Inventory group read campaign climate charges, carried freight, reserved colony kits and held species with live quantities. Recognized entries now use existing item/specimen textures; unsupported IDs retain the fallback glyph. The independent critic finds the inventory more pictorial but still too small/abstract for quick item recognition. Existing action keys and cargo behavior remain authoritative.
- The system chart gives the planets more screen presence and a restrained star field. The galaxy route quote is positioned at 68% of its projected path, away from the ship-origin label in the reviewed fixture. Orbit contact/service views keep the camera focused on the ship with more responsive focus smoothing.
- The current one-recipe mining → Glassworks → Resonance focusing-head production loop remains a pilot, not broad manufacturing.

## Evidence and limits

Captured with Godot 4.7.2 on the RTX 5070 Ti using isolated GUI profiles. Ignored review images include `artifacts/cargo-review/current-flight-tools-1080.png`, `current-flight-inventory-1080.png`, `current-freight-1080.png`, `artifacts/visual-critic-surface-pass/mining/surface-mining-before-1080.png` and `surface-mining-after-1080.png`, plus the earlier system/galaxy captures. The cargo harness generated 12 captures and passed five campaign-immutability checks (~16.7 s). The mining harness generated two 1080p captures and passed its state/cargo assertions (~6.1 s); neither measures performance. Targeted `test_flight_hud.gd` passed 50 assertions with zero failures in 3.78 s. The previous 21-assertion flight-presentation test was not rerun because the camera code did not change. No full suite or performance profile was run.

The independent critic confirms distinct cargo pictures and visible quantities, but rates quick item identification a major gap. It rates the live Morrow surface gap critical: broad smooth orange relief, pale sky, coarse repeated rocks and sparse flora remain far from the approved textured rust terrain, teal water, distant relief and varied plants. The mining capture shows a real 4/4→3/4 lode change and glass cargo receipt. Static images do not prove player-follow motion, native response, travel feel, audio, fun, performance or user acceptance; camera following still needs a moving-ship runtime capture. See [art/visual-canon](../art/visual-canon/README.md), the [mock coverage register](reviews/VIEW_MOCK_COVERAGE.md), and the independent re-review in [commerce](systems/SHIP_COMMERCE.md#integrated-cargo-and-morrow-re-review--25-september-2026).

## Next work

1. The bounded V01/V02 inventory correction is integrated. Preserve real counts, capacity and actions; do not fabricate items. Improve quick item recognition later only alongside a broader whole-HUD review.
2. Next, execute Roadmap milestone one: native-input, connected three-world flight/discovery/danger/contact/trade/upgrade/return/save-resume. Capture one uninterrupted, input-recorded moving-ship/approach segment so camera response and the still-open transition-parity gate can be assessed.
3. Keep the Morrow art gap visible, but defer another surface-only pass until the connected voyage is established. Then approach the critical gap as a whole-world presentation task, with paired canon/runtime captures and a bounded performance check.

## Selective verification

`tools/Test.ps1` runs nothing without arguments, selects cases with `-Tests`, and requires explicit `-All` for the suite. Run only domain checks touched by the change and record duration; visual captures are separate evidence. Run `tools/DocumentationReport.py` when adding/moving docs. Check live processes and machine power mode before multi-instance review or profiling; run imports/performance measurements one at a time. No paid terms or purchases without explicit approval.
