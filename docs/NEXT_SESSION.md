# Resume here

Updated 25 September 2026. This short handoff points to the self-directed objective in [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md). [TASK_BOARD.md](TASK_BOARD.md) remains the sole production queue.

## Checkout and checkpoint

Work only in the isolated review worktree at C:\Users\zephy\.codex\worktrees\orbit-surface-gate\New project on codex/orbital-transition-gate. Its current base is 63ed372343e7bdc975a4982c5b7893c7cc913286 plus the local test-runner commit d7a93ca35f85b8ce8a4e6a65386c5fc28ae4edf6. The branch was one commit ahead of origin before the visual-canon checkpoint; inspect remote state before pushing or claiming backup.

The main checkout C:\Users\zephy\Documents\ChatGPT\New project is dirty and six commits behind. Leave its user changes, index, branch and files untouched. Other existing worktrees belong to separate checkpoints; inspect before use.

## Connected gameplay already present

A bounded production loop now connects finite Resonant glass mining, traded Alloy, a completed Glassworks outpost and a crafted Resonance focusing head. The item costs no Marks, installs on the shared ship, persists in the campaign, records in the chronicle and reduces subsequent mining energy from 8 to 5. It is one recipe, not broad manufacturing. Lode depletion reads more clearly after removing occluding rocks, but the art remains provisional and packaged runtime LOD/loading/memory/performance are unverified.

## User-approved visual canon and active work

The user selected the populated Morrow surface image, then approved the exact v2 orbital, solar-system and approach/arrival images. The user also asked to include the earlier galaxy view because they liked it. These now share one tracked folder, [art/visual-canon](../art/visual-canon/README.md), which includes the images, exact Morrow generation prompts and provenance. Do not regenerate accepted stills to satisfy the earlier critic's optional size/ship refinements.

Start a bounded V01/V02 HUD-alignment implementation from the accepted images: place the notification and Marks anchors clearly, show a real item/inventory grid with actual quantities and availability, integrate compact hull/energy status, keep ALT secondary, and preserve the surface-only local chart plus distinct system/galaxy maps. Do not fabricate items or alter campaign actions to fill the mock.

The source-to-mock R01/V01/V04 audit remains open and should continue alongside this bounded implementation. Existing inspected source samples around 7202–7209 seconds include galaxy/system endpoints and intermediate system-scale views; they do not establish trigger input, continuous motion/timing, surface approach, audio or native interaction. The latest source manifest records 18/61 sampled workflows, 9/61 readable and zero fully verified interactions/presentation/audio. Do not claim the transition or full view families closed. Root/runtime captures also show the actual terrain and HUD remain far below the approved composition.

## Selective verification

Test.ps1 now lists tests without running, runs selected cases with -Tests, and requires -All for the suite; selected runs are timed. Run only the smallest relevant flight-HUD test after HUD code changes, then inspect an actual runtime capture against canon. Test-runner save isolation is not a substitute for checking what was actually launched. Avoid concurrent Godot runs and performance profiles until live processes and machine power mode are known. No game tests were run for the visual-canon documentation checkpoint.

The task board owns next order, including the source coverage gate, the broader playability correction, and later whole-planet continuity. Native input/fun review, final Morrow art, animation, audio, clean-PC performance and milestone-one acceptance remain open.