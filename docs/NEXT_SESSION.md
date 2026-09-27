# Resume here

Updated 27 September 2026. [TASK_BOARD.md](TASK_BOARD.md) is the only production queue; [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md) owns the objective.

## Current checkpoint

Work in the isolated checkout `C:/Users/zephy/.codex/worktrees/r01-transition-audit/New project`, branch `codex/r01-v01-v04-transition-audit`. Preserve the dirty main checkout. The latest pushed and independently verified checkpoint is `bb0190b3c2feb8fe4dcecb60f9ba5db596f754f7`. It includes the compact notification/chart alignment, measured inventory atlas crops and 12-logical-pixel chart-title lift. Godot generated numerous `.import` sidecars and `.uid` files in this worktree; do not stage them or the unrelated local `art/visual-canon/ui-element-candidates/PROMPTS.md` edit.

The R01 source-to-mock audit remains closed with insufficiency, not a runtime-motion pass. The user approved the nine focused transparent UI elements in [visual canon](../art/visual-canon/ui-element-candidates/focused-elements-v5/README.md) for live HUD use. The actual flight HUD uses image-backed console, tabs, surface chart, Marks, notification and orbital-target housings with real state. A populated campaign renderer harness earned 7 Marks and one each Energy Pack, Repair Pack and freight item through campaign trade, then captured 1920×1080 and 2560×1440 flight and inventory. The newest run completed in 27.2 s; its assertions confirmed the campaign path. The chart title now clears the bezel, though it remains close to the lower edge. The inventory icon crops modestly improve pictogram scale. The notification remains a display-only fixture, not proof of a discovery trigger. Captures are ignored local artifacts, not portable build proof.

The live system and galaxy maps show a model-derived scout at its route position. The galaxy-route ship reads at the approved scale. The system-map ship still reads too large beside its planets: the independent critic estimates 0.7–0.8 planet diameters versus about one-third in the approved system mock. A system-only correction is underway on branch `codex/system-ship-scale-20260927`, worktree `C:/Users/zephy/.codex/worktrees/system-ship-scale/New project`, based on `bb0190b`; keep the galaxy model unchanged. The galaxy destination card was seen with three worlds; four/five-plus worlds and keyboard navigation remain unverified. Morrow's world remains pale, flat and sparse against the approved lush T-score target. Terraform T-score, altitude, and biosphere tier are distinct.

The [latest independent review](reviews/VIEW_MOCK_COVERAGE.md#surface-hud-readability-and-system-ship-scale-follow-up--27-september-2026) scores the current populated surface HUD at 68/100 at 1920×1080 and 69/100 at 2560×1440; the separate scene scores are 52/53. Chart-title legibility improved. The earlier integrated system and galaxy HUD scores remain 62/65 at each size, with scene scores 48/51 and 44/47. Every score remains below the 90-point gate; interaction and motion values are provisional from stills. The full Morrow scene remains visually far below the approved target. No native-input playtest, performance profile, export check, positive user verdict or fun claim was made.

The focused `test_flight_hud.gd` attempt ran for about 31 s, reported mismatches in the already-dirty test source (it expects a 220×190 chart and 188×146 map while runtime source is 250×215 and 207×150, and it accesses nonexistent `scene.status_backing` while current source uses `status_plate`), then was stopped. Leave that pre-existing test diff untouched until its intended baseline is reconciled. No full suite was run.

## Next work

1. Correct the system-map scout alone to roughly 60–70% of its current rendered size, retaining the real recognizable ship and planet/route anchoring. Capture both resolutions and verify the galaxy-route ship remains unchanged.
2. Continue surface HUD work on actual hover/readout behavior and terrain-chart marker hierarchy. Show true counts and capacity; preserve real empty slots. Resolve the dirty `test_flight_hud.gd` expectations only after reconciling their owning baseline.
3. Once the HUD is materially closer, run the bounded player-follow camera A/B on one ordinary uncut scene; document parameters and choose or retain perspective.
4. Build shared seeded Morrow terrain/habitat/landmark composition across adjacent traversable regions, preserving planet-fixed geography and saved changes. Keep this separate from the HUD score.
5. Resume connected-voyage work after the visual gates move materially toward canon.

Do not stage, reset or overwrite unrelated main-checkout changes. At the next verified milestone, update owning records, make a small commit, push, and verify the full remote hash.
