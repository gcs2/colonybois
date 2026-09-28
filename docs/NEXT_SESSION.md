# Resume here

Updated 28 September 2026. [TASK_BOARD.md](TASK_BOARD.md) is the only production queue; [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md) owns the objective.

## Current checkpoint

Work in the isolated checkout `C:/Users/zephy/.codex/worktrees/morrow-hud-layout/New project`, branch `codex/surface-hud-layout-pass`. The pushed HUD baseline is `aed1c0ad421617176da1b9c10872169cd470b1f2`; system-scout and Galaxy-scout integrations are now committed on top. Check the branch's current remote tip before extending it. Preserve the dirty main checkout.

The user says the live HUD/art and visual-critic loop is being handled in another chat; do not duplicate it. This separate checkout holds the bounded V04 follow-up in `C:/Users/zephy/.codex/worktrees/morrow-region-loop/New project`, branch `codex/morrow-region-opportunity`, based on `ca8fca9935dd06f28c158dadf4b8baf512d3d61e`. The prospect loop is implemented but not behavior-verified. Its focused test is registered; a cold first launch was interrupted after 90 seconds without logs/import cache. `git diff --check` passes, and the exact temporary `override.cfg` from that run was removed. Main remains untouched.

The HUD pass tightened the five shared tab cards to the approved mock's 464:214 ratio and even 4 px gaps, then increased centered, top-aligned pictogram occupancy while reserving the live count/shortcut strip. The survey scanner uses the exact generated scanner-module candidate; it is provisional pending current-size alpha/fringe review, a fresh runtime view, and user acceptance. The energy-pack uses its focused generated cutout. No approved repair-pack pictogram is available; do not substitute a Tripo concept image into the HUD. Real catalog state, counts, tooltips, selection and input remain authoritative.

The system map renders the actual scout GLB at reduced scale and hides it during an interstellar voyage rather than implying a local trajectory to a placeholder. Galaxy view renders the same scout in a 96×72 transparent SubViewport, follows the active route through the live flight-clock fraction, and disables that render target while hidden. The focused system-chart test passed 53 assertions in 59.23 seconds, including a real cross-system departure; the Galaxy-scout slice previously passed 9 checks in 1.8 seconds. Godot emitted a non-fatal Godot 3.x `SpatialMaterial.specular` remap warning during scene construction. These checks do not validate pixels, materials, readability, performance, or visual acceptance. The full suite was not run; generated import metadata was needed locally to execute the focused chart check.

The HUD still has no fresh runtime score. The desktop previously showed Godot `0x40000015` and Windows graphics TDR events; rendered comparisons remain paused pending stable graphics. The R01 source-to-mock audit remains closed with insufficiency, not a runtime-motion pass.

## Next work

1. On the V04 branch, run only `test_region_resource_loop.gd` after obtaining a usable local console runtime/import cache and when it will not overlap another import. Inspect its duration and assertions before checkpointing; do not call it visually accepted. Keep generated import sidecars and captures out of Git.
2. Leave the HUD/visual-critic loop to the other chat. When its graphics are stable, capture matched populated surface, orbit, system and galaxy views at 1080p and 1440p; score each independently out of 100 and make no acceptance claim before fresh captures and user review.
3. After the V04 save/return slice is verified or explicitly checkpointed incomplete, advance P02: the New Expedition captain identity/philosophy screen in [EXPEDITION_FOUNDING_SCREEN.md](art/mock-requests/EXPEDITION_FOUNDING_SCREEN.md). Keep species/creature editing deferred; each offered philosophy must create a usable action or obligation.
4. After the HUD is materially closer and reviewed, run the bounded player-follow camera A/B on one ordinary uncut scene. Continue the shared, seeded Morrow geography/habitat work and connected-voyage systems in the task-board order.

Do not stage, reset or overwrite unrelated main-checkout changes. Keep captures and import sidecars out of Git. Push meaningful checkpoints and verify their exact remote hashes.
