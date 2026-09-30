# Resume here

Updated 30 September 2026. [TASK_BOARD.md](TASK_BOARD.md) is the only production queue; [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md) owns the objective.

## Current checkpoint

R01 remains closed with insufficiency: paused source samples and static captures do not establish a continuous, player-triggered galaxy→system→orbit→approach→surface journey, its timing/audio, or native feel. The current runtime now renders the real scout in system and galaxy views; fresh actual-renderer captures at 1920×1080 and 2560×1440 were independently reviewed. Full-view scores remain below target: system HUD 66/67 and scene 52/53; galaxy HUD 65/66 and scene 42/43. The scout is still marginal at 1080p, galaxy equipment imagery needs a populated review state, scenes remain far from canon, and 4/5+ destinations plus keyboard use are unverified. Details and capture paths are in [the coverage review](reviews/VIEW_MOCK_COVERAGE.md).

Continue in `C:/Users/zephy/.codex/worktrees/r01-audit-closeout/New project`, branch `codex/hud-field-instruments-step1`, based on the pushed R01 audit checkpoint `420776756cdab46697410fedf2bc40e32a0a9627`. The separate `r01-transition-audit` worktree and its dirty files were not touched. The main checkout is now clean and synchronized to `origin/codex/frontier-prototype` at `b183c0d43ec0b68a4290f96be843ec6f7539946a`; the pre-sync working state is preserved locally on `codex/recovery-frontier-prototype-2026-09-30` at `7e059dc` and was not pushed.

The R01 source-to-mock audit remains closed with insufficiency, not a runtime-motion pass. The user-approved focused transparent UI elements in [visual canon](../art/visual-canon/ui-element-candidates/focused-elements-v5/README.md) are wired to live state in the flight HUD. A populated campaign renderer previously earned 7 Marks and one each Energy Pack, Repair Pack and freight item through campaign actions, then captured 1920×1080 and 2560×1440. The existing 52 px pictogram candidate is provisionally retained; its matched comparison scored +1 in HUD art only, with cross-review score drift documented. The notification capture is a display fixture, not proof of a discovery trigger.

Stage 1 of the active HUD sequence adjusts the five approved image-backed tabs from 64×37/gap4/icon-max36 to 72×33/gap2/icon-max32, preserving the approved v5 asset’s 2.17:1 silhouette. A fresh campaign render at 1920×1080 and 2560×1440 completed through `tests/review_populated_hud.gd`; captures and exact state are in ignored `artifacts/hud-step1-20260930/`. The independent six-dimension rubric review scores the live HUD 64/100 and the world 33/100, both provisional from stills: no native pointer/focus, movement, user verdict, or fun acceptance. This confirms the tab row is wider/flatter and closer to the mock, but the HUD gate remains open. The relay prompt still overlaps the relay, the chart footer crowds its frame, instrument depth and information hierarchy remain weak, and the world is far below canon. One existing `SpatialMaterial` specular-remap warning appeared during capture. See [FLIGHT_HUD_REVIEW.md](reviews/FLIGHT_HUD_REVIEW.md) and [VIEW_MOCK_COVERAGE.md](reviews/VIEW_MOCK_COVERAGE.md).

System navigation renders the actual scout GLB at scale 0.20; the route-origin fill that hid it is removed and the route begins clear of its silhouette. Galaxy navigation uses the same GLB in a 96×72 transparent SubViewport drawn at 30×22 logical pixels, with its nose following travel direction. Fresh captures and separate critic scores are recorded in the coverage review. The older `test_galaxy.gd` (43 checks, 11.84 s) and `test_system_chart.gd` (50 assertions, three failures) are historical checks; the route fix is rendered, and survey/site failures remain to be narrowed before relying on those suites. System content comes from `system.planets`, but only three-body composition has been visually exercised; verify 4/5+ bodies. Morrow remains pale, flat and sparse against the approved T-score target. Terraform T-score, altitude, and biosphere tier are distinct.

The 30 September tab comparison is a narrow geometry improvement, not a broad score gain or acceptance. Keep all campaign data and image provenance intact. Use the approved cutouts and real item art in the next pass; do not fill empty slots with invented inventory.




## Next work

1. Continue the approved V01 sequence with item-art scale, truthful 6×2 inventory occupancy, and image-backed slot material; preserve actual quantities and empty capacity. Keep the quick rail within its existing outer footprint.
2. Integrate the live condition pod, dark surface chart, compact real notice, and world-tethered target states. Remove duplicate target titles and keep callouts clear of their subjects. Review ordinary pointer use, named tooltips, keyboard focus, shortcuts, and world visibility at 1080p and 1440p.
3. Have an independent critic score HUD and world separately with the six-row 100-point rubric. Continue until the affected HUD view reaches 90/100, every dimension clears its minimum, and there is no blocking defect; then seek the user’s visual verdict. Still captures do not prove motion or playability.
4. After the HUD gate, compare the current player-follow camera with one or two slightly higher/pitched views in an uncut ordinary-play sequence; retain the perspective default unless the evidence supports a change.
5. Then resume the open V02 inventory-modal task and shared seeded Morrow whole-planet pipeline, following [TASK_BOARD.md](TASK_BOARD.md). Preserve planet-fixed geography and saved changes; Morrow remains far below canon.

Do not stage, reset or overwrite unrelated main-checkout changes. At the next verified milestone, update owning records, make a small commit, push, and verify the full remote hash.

## Spore binary-reference note

The read-only Steam install contains only `Spore/SporeBin/SporeApp.exe`, Windows file-version resource 1.3.0.29, with no `SporebinEP1` folder. The Spore ModAPI Ghidra workflow proves targeted decompilation is viable, but its maps are not confirmed for this base-game binary; its Launcher Kit and most code mods require Galactic Adventures. SDK ship fields/functions remain useful search anchors. No binary scan/decompilation or save manipulation occurred. See [Spore binary scaling feasibility](research/SPORE_SPACE_STAGE_RESEARCH.md#binary-reference-feasibility--27-september-2026); inspect package data first, validate the exact build/map, then corroborate any code hypothesis in game. Do not copy proprietary implementation code.
