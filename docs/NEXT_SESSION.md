# Resume here

Updated 25 September 2026. `docs/TASK_BOARD.md` is the sole production queue; this handoff records the latest isolated checkpoint. Keep the user's dirty main checkout untouched.

## Current checkpoint

A bounded surface-prospecting pilot is implemented on branch `codex/visual-critic-surface-pass` in the isolated worktree `C:\Users\zephy\.codex\worktrees\surface-critic-pass\New project`. It adds a finite scanned four-crystal seam, a selectable Resonance cutter (8 energy per cut), physical crystal depletion, real Resonant glass cargo, and persistence/trade/chronicle integration. The focused suites pass: 54 encounter assertions and 48 campaign assertions. Details and limits are in [SHIP_COMMERCE.md](systems/SHIP_COMMERCE.md).

Before widening the feature, inspect the actual captures at `artifacts/visual-critic-surface-pass/mining/surface-mining-before-1080.png` and `surface-mining-after-1080.png`, then review the independent critique in the task history. The critique confirms state clarity and the reward/target cards, but says the terrain lighting and HUD materials still fail the approved visual direction and the mineral is primitive. Do not call this an art approval. The review harness is `tests/review_surface_mining.gd`.

The computer is currently in Silent mode. No performance profiling or broad asset reimport was run; runtime speed and frame rate are unassessed. This is only a correctness/presentation checkpoint. The art still needs the agreed visual-critic loop and human playtest. Native input feel, sound, animation, and performance have not been validated.

## Working boundaries

- The main checkout `C:\Users\zephy\Documents\ChatGPT\New project` is on `codex/frontier-prototype` with unrelated user changes. Do not modify, stage or commit those files as part of this worktree checkpoint.
- The checked-out worktree is isolated; review `git status` before staging. Keep generated captures and engine caches out of Git. No large Godot import scan.
- Keep the slice aligned with [SPACE_FIRST_DIRECTION.md](direction/SPACE_FIRST_DIRECTION.md) and [SPORE_SPACE_STAGE_RESEARCH.md](research/SPORE_SPACE_STAGE_RESEARCH.md): personal exploration and discovery, finite resources and consequential commerce. Cities remain supporting systems.
- Do not revive coloring, sculpting, a character creator, cast expansion, or broad flora/fauna production. Do not claim Spore parity from this pilot.
- Use the actual screenshot and independent critique to choose the next bounded correction. The full source/mock coverage and professional presentation gates in [TASK_BOARD.md](TASK_BOARD.md) remain open.

## Validation and backup

The two focused Godot suites and 1080p capture harness passed. Run `git diff --check` and `tools/DocumentationReport.py` after the documentation update. A full test-suite run and performance test have not been done in this checkpoint. Once the docs and scope are reviewed, create a small commit on `codex/visual-critic-surface-pass`, push that branch, and verify its remote hash. Do not push to `master` or merge without a separate request.
