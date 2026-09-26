# Resume here

Updated 26 September 2026. `docs/TASK_BOARD.md` is the only production queue; `docs/PRODUCTION_GOAL.md` owns the objective and `docs/ROADMAP.md` owns milestone gates.

## Current checkpoint

Work in the isolated checkout `C:/Users/zephy/.codex/worktrees/r01-transition-audit/New project`, branch `codex/r01-v01-v04-transition-audit`. Preserve the dirty main checkout at `C:/Users/zephy/Documents/ChatGPT/New project`.

The Spore source-to-mock audit remains insufficient: paused frames/manual controls do not establish continuous scale-transition timing, input, or audio. The HUD work now has a focused local pass: the console and surface chart remain readable at 1920×1080 and 2560×1440, and the mining action card is attached to its visible seam target. Captures: `artifacts/visual-critic-surface-pass/hud-seam-integration-20260926/surface-mining-after-1080p.png` and `.../surface-mining-after-1440p.png`.

Verification: `test_flight_hud.gd` passed 78 assertions in 13.02 s; `test_encounter.gd` passed 56 assertions with zero failures in 20.53 s. The encounter run covers seam feedback and save/restore. It led to fixes that normalize numeric seam-depletion values after JSON load and return `ERR_INVALID_DATA` for a malformed old save instead of dereferencing a missing position. Godot emits an existing SpatialMaterial `specular` remap warning. No full suite or performance profile was run; the machine was in Silent mode.

Independent critic: console PASS, map PASS, tethered callout PASS at both resolutions; whole scene REJECTED because Morrow remains a broad, flat tan field with sparse oversized/cropped props. Minor icon/casing refinement remains, but do not spend another milestone on spacing alone. There is no user acceptance, native-input playtest, exported-build review, performance result, or fun claim.

T-score means the Terraform climate score. It is separate from biosphere/ecological tier and altitude. The approved lush Morrow surface is the intended Terraform T2 visual target; current captures do not show that score or establish Morrow's T2 state.

Keep generated `.import`/`.uid` sidecars and capture artifacts out of Git. Stage only the named source, test, and owning documentation files. Use relevant focused checks and record their duration; serialize imports, game instances, and captures.

## Next work

1. Close the current HUD gate with only readability-driven icon/casing changes; preserve the passed console, map, and seam callout. Keep the complete inventory, recognizable controls/tooltips, top-left notifications, top-right Marks, surface-only local chart, and compact ALT. Do not relabel ALT as T-score.
2. Compare a small number of player-follow camera framings against the approved surface view. The gameplay camera must track the ship and read as interactive; cinematic framing/mode is later work. Inspect the earlier camera harness and diagnose its recorded stall before reuse. Do not change the default based only on a static mock.
3. Enrich Morrow across the whole traversable planet: shared seeded terrain/ecology/landmark geography across adjacent regions, consistent revisits, and preserved saved local changes. Avoid an isolated lush patch that leaves the rest of the globe empty.
4. Return to the connected-voyage task-board work after the camera/world gap has moved materially.

The pinned `Frontier Worlds: art sourcing and production` task has already delivered a non-blocking comparison of external image services and licensed assets, with a small cutout pilot. The user explicitly ruled out buying human labor. Do not reopen commissions, vendor contact, purchases, or paid terms without a changed user decision.

At the next verified checkpoint, update the owning records, make a small commit, push it, and verify the full remote hash. Never stage or overwrite unrelated main-checkout changes.
