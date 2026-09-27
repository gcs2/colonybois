# Resume here

Updated 27 September 2026. `docs/TASK_BOARD.md` is the only production queue; `docs/PRODUCTION_GOAL.md` owns the objective and `docs/ROADMAP.md` owns milestone gates.

## Current checkpoint

Continue in the isolated checkout `C:/Users/zephy/.codex/worktrees/hud-v01-finishing-20260927/New project`, branch `codex/hud-v01-finishing-20260927`. Preserve the dirty main checkout at `C:/Users/zephy/Documents/ChatGPT/New project` and the R01 transition-audit handoff at `C:/Users/zephy/.codex/worktrees/r01-transition-audit/New project`.

The Spore source-to-mock evidence review is closed with insufficiency, not a runtime-motion pass. Source samples are paused/muted and do not link scale changes to input or continuous timing; an 80-frame direct-call landing harness establishes scripted frames only. Current R01 screenshots show a synthetic mining surface at 1920×1080 and 2560×1440, not a connected voyage. Exact source, transition, HUD, and world gaps are recorded in [VIEW_MOCK_COVERAGE.md](reviews/VIEW_MOCK_COVERAGE.md#source-to-mock-transition-audit).

The direct HUD/runtime comparison uses matched 1920×1080 and 2560×1440 captures from one synthetic Morrow mining state, same seed and camera. It shows 0 Marks and one glass item and is not a populated player save. The updated HUD makes seam quantity and reward explicit, tightens the one-line toast, raises the chart, clarifies the active slot, and increases console type while keeping the approved five tab cards unchanged. Focused `test_flight_hud.gd` passed 79 assertions with zero failures; the capture harness passed at both sizes. No full suite, native-input playtest, or performance profile was run. The game still renders with the Compatibility renderer and emits an existing SpatialMaterial `specular` remap warning.

Independent pre-code review passed the telemetry/toast mock. Integrated review confirms the final HULL/ENERGY spacing at both sizes, one-line toast, and preserved tab cards. This supports the bounded HUD integration only; V01 signoff remains open pending a populated campaign, native mouse selection, named tooltip and focus-order/visibility review, inventory/treasury clarity, a second target, and user visual acceptance. Morrow remains a broad smooth tan/brown field with weak far relief and sparse/cropped props.

On 27 September, the only local persisted expedition review save was loaded read-only and confirmed unsuitable for V01 acceptance: Morrow/surface, 0 Marks, empty cargo, zero badges/upgrades, two field-history entries and no chronicle events. Do not present it as a populated player campaign or add mock inventory to the screenshot. Native Windows-app controls are disabled in the available UI tool for this run, so ordinary mouse selection, hover tooltips and keyboard-focus visibility remain open. An isolated same-HUD camera/tilt-shift capture attempt produced only the Godot startup line and no frames before its own process was stopped; no production code or user save was changed. Existing 0.40/0.45/0.55 camera frames and the independent composition critique in the `hud-view-study` checkpoint are useful direction only: they predate the final HUD pass, retain a perspective view, and reject depth-of-field blur over reachable life. Do not rerun the stalled capture path without diagnosing startup.

T-score means the Terraform climate score. It is separate from biosphere/ecological tier and altitude. The approved lush Morrow surface is the intended Terraform T2 visual target; current captures do not show that score or establish Morrow's T2 state.

Keep generated `.import`/`.uid` sidecars and capture artifacts out of Git. Stage only the named source, test, and owning documentation files. Use relevant focused checks and record their duration; serialize imports, game instances, and captures.

## Next work

1. Close the remaining HUD acceptance gates with a legitimately populated campaign at 1920×1080 and 2560×1440. Exercise native mouse selection, named hover tooltips, focus order and visible focus, inventory stack/silhouette clarity, treasury/action grouping, and a second target. Keep the glowing tab cards and square pictorial grid intact; do not fake contents or replace scalable controls with resolution-specific image variants.
2. Finish the reversible view study on the same deterministic planet/seed and final HUD: current player-follow camera versus one modestly higher view, and evaluate scene-only focus as a separate variable only after restoring a cheap actual-renderer capture path. The earlier pitch captures and independent critique favor perspective and sharp reachable targets, so do not add blur to gameplay on the strength of the concept image alone. Godot 4.7.2 Compatibility lacks built-in depth-of-field blur; no renderer migration is approved. Keep perspective as default; do not pivot to an RTS/fully isometric camera.
3. After the HUD/view direction is accepted, enrich all of Morrow across shared seeded terrain/ecology/landmark geography. Reuse suitable Tripo assets through planet-specific placement rules, preserve consistent revisits and saved local changes, and avoid an isolated lush patch that leaves the rest of the globe empty.
4. Return to connected-voyage task-board work after the camera/world gap has moved materially.

The pinned `Frontier Worlds: art sourcing and production` task has already delivered a non-blocking comparison of external image services and licensed assets, with a small cutout pilot. The user explicitly ruled out buying human labor. Do not reopen commissions, vendor contact, purchases, or paid terms without a changed user decision.

At the next verified checkpoint, update the owning records, make a small commit, push it, and verify the full remote hash. Never stage or overwrite unrelated main-checkout changes.
