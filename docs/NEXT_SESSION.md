# Resume here

Updated 28 September 2026. `docs/TASK_BOARD.md` is the only production queue; `docs/PRODUCTION_GOAL.md` owns the objective and `docs/ROADMAP.md` owns milestone gates.

## Current checkpoint

The R01/V01/V04 source-to-mock evidence audit is closed on the isolated `codex/r01-audit-closeout` branch at `5206329960b39085fc02af9f8c846201d0f16574`. The detailed matrix is [VIEW_MOCK_COVERAGE.md](reviews/VIEW_MOCK_COVERAGE.md#source-to-mock-transition-audit). It is an insufficiency finding, not a visual or transition pass; complete R01 research and V01/V04 production remain open. Keep the dirty main checkout at `C:/Users/zephy/Documents/ChatGPT/New project` untouched.

The audited source samples are paused/muted and do not link scale changes to input or continuous timing; an 80-frame direct-call landing harness establishes scripted frames only. Exact source, transition, HUD, camera, and world gaps are recorded in [VIEW_MOCK_COVERAGE.md](reviews/VIEW_MOCK_COVERAGE.md#source-to-mock-transition-audit). The R01 parity inventory remains active research and must not be marked complete from this audit.

Verification: `test_flight_hud.gd` passed 78 assertions in 13.02 s; `test_encounter.gd` passed 56 assertions with zero failures in 20.53 s. The encounter run covers seam feedback and save/restore. It led to fixes that normalize numeric seam-depletion values after JSON load and return `ERR_INVALID_DATA` for a malformed old save instead of dereferencing a missing position. Godot emits an existing SpatialMaterial `specular` remap warning. No full suite or performance profile was run; the machine was in Silent mode.

The current V01 baseline is `codex/hud-card-legibility-20260927` at `84f67ff89bd87bb7cc7be44523bbef12a190b518`; its campaign-earned 1920×1080 and 2560×1440 frames plus `evidence.json` are in `artifacts/hud-view-study-20260928c/`. They still show mostly empty default flight cells and a duplicate, crowded selected-relay label/card. Keep the approved five-tab design stable; refine only against matched crops. The surrounding planet remains a broad, flat tan/brown field with sparse/cropped props. There is no native-input playtest, user visual acceptance, exported-build review, performance result, or fun claim.

T-score means the Terraform climate score. It is separate from biosphere/ecological tier and altitude. The approved lush Morrow surface is the intended Terraform T2 visual target; current captures do not show that score or establish Morrow's T2 state.

Keep generated `.import`/`.uid` sidecars and capture artifacts out of Git. Stage only the named source, test, and owning documentation files. Use relevant focused checks and record their duration; serialize imports, game instances, and captures.

## Next work

1. Match the pinned surface HUD in a small sequence: preserve the five approved raised, dark, notched tabs and lower-right footprint; tune only demonstrable crop differences; fill pictorial cells from real campaign inventory; then integrate the condition pod, compact notice, far-right Marks, dark chart, secondary ALT, and world-tethered target feedback without duplicated labels. Compare matching 1920×1080 and 2560×1440 actual-renderer states; check mouse, focus, tooltips, scaling, and world visibility. Score an independent critic pass out of 100 against the stated rubric and seek the user visual judgment separately.
2. Only after the HUD is materially closer, compare the current perspective with one or two slightly higher player-follow views in uncut ordinary play. Judge miniature feel, landmark/scout scale, targeting, navigation, and motion. Keep perspective as default until evidence supports a documented decision; cinematic mode is later.
3. Enrich Morrow across the whole traversable planet: shared seeded terrain/ecology/landmark geography across adjacent regions, consistent revisits, and preserved saved local changes. Avoid an isolated lush patch that leaves the rest of the globe empty.
4. Return to the connected-voyage task-board work after the camera/world gap has moved materially.

The pinned `Frontier Worlds: art sourcing and production` task has already delivered a non-blocking comparison of external image services and licensed assets, with a small cutout pilot. The user explicitly ruled out buying human labor. Do not reopen commissions, vendor contact, purchases, or paid terms without a changed user decision.

Do not launch Godot or captures while the user is gaming. A separate active chat acknowledged hidden Godot launches during play, although causation of the recurring exception dialog is unconfirmed; this conversation did not launch Godot, and its Windows process query was denied. Resume runtime work only when the user is no longer gaming and the popup risk is resolved. At the next verified checkpoint, update owning records, make a small commit, push it, and verify the full remote hash. Never stage or overwrite unrelated main-checkout changes.
