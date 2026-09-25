# Resume here

Updated 25 September 2026. This is a concise operational handoff, not a cap on the self-directed long-term goal in [PRODUCTION_GOAL.md](PRODUCTION_GOAL.md). `docs/TASK_BOARD.md` is the sole production queue. Keep the user's dirty main checkout untouched.

## Current checkpoint

A bounded surface-prospecting pilot is implemented on branch `codex/visual-critic-surface-pass` in the isolated worktree `C:\Users\zephy\.codex\worktrees\surface-critic-pass\New project`. It adds a finite scanned four-crystal seam, a selectable Resonance cutter (8 energy per cut), physical crystal depletion, real Resonant glass cargo, and persistence/trade/chronicle integration. The focused suites pass: 54 encounter assertions and 48 campaign assertions. Details and limits are in [SHIP_COMMERCE.md](systems/SHIP_COMMERCE.md). A local follow-up replaces four tall primitive crystals with four removable lode groups, each a basalt socket with three faceted shards; the updated focused campaign test still passes 48 assertions. This visual change is provisional until captured and independently reviewed.

The latest independent critic compared the actual Tripo review captures against the approved Morrow surface target and Spore sample-collection frames at 30:05.2/30:07.2. It found the placement, ring, target card, beam, cargo receipt and energy decrement legible, but the Tripo outcrop itself looks unchanged after a cut, so depletion reads mainly through `3 / 4` text. The source frames show collection of living samples; they are only an action-feedback analogy, not evidence for our ore-mining or finite-deposit rules. The critic also finds the complete game view far below the target in terrain/material grouping, contrast and coordinated HUD. Read [the full review](systems/SHIP_COMMERCE.md#visual-critic-review-25-september-2026).

The Tripo outcrop file is a single mesh primitive and material, so its embedded veins cannot be individually removed. The harness `tests/review_surface_tripo_asset.gd` was modified to place the separate removable lodes on its exposed face. A faster live-scene capture harness, `tests/review_surface_lode_stages.gd`, was added for intact/partly mined/exhausted stages. Neither produced captures in the slow machine session; the GLB run and then the light capture run were stopped after over 40 seconds without output. There is no visual confirmation of the new lode geometry and no second critic pass. Keep the change provisional; do not call it accepted or performance-tested.

The computer was reported in Silent mode. No performance profiling or broad asset reimport was run; runtime speed and frame rate are unassessed. The focused test is evidence only for its 48 assertions. Art, native input feel, sound, animation, performance and human playability remain unvalidated.

## Working boundaries

- The main checkout `C:\Users\zephy\Documents\ChatGPT\New project` is on `codex/frontier-prototype` with unrelated user changes. Do not modify, stage or commit those files as part of this worktree checkpoint.
- The checked-out worktree is isolated; review `git status` before staging. Keep generated captures and engine caches out of Git. No large Godot import scan.
- Keep the slice aligned with [SPACE_FIRST_DIRECTION.md](direction/SPACE_FIRST_DIRECTION.md) and [SPORE_SPACE_STAGE_RESEARCH.md](research/SPORE_SPACE_STAGE_RESEARCH.md): personal exploration and discovery, finite resources and consequential commerce. Cities remain supporting systems.
- Do not revive coloring, sculpting, a character creator, cast expansion, or broad flora/fauna production. Do not claim Spore parity from this pilot.
- Follow the matched-source/mock/runtime visual-critic loop documented in [TASK_BOARD.md](TASK_BOARD.md) and [SHIP_COMMERCE.md](systems/SHIP_COMMERCE.md). The independent critic must compare evidence, identify concrete severities, and review the same states again after corrections. The full source/mock coverage and professional presentation gates remain open.
- Keep working beyond this surface slice: after it is visually reviewed, advance toward one real mining → processing → useful manufactured-item loop, then choose the next highest-value task from the board. This is not a two-checkpoint stopping condition.

## Validation and backup

`tests/test_expedition_session.gd` passed 48 assertions after the lode change; `tests/test_encounter.gd` has 54 assertions from the prior checkpoint. DocumentationReport passes 118/118 registered files, 638 local links, 0 errors; `git diff --check` is clean. The new visual capture attempt did not finish and the full suite was not run. The branch's latest pushed commit remains `28c227f733ce1c9d8afeb0c2cf1004a96efedf21`; current source, test and documentation edits are local and uncommitted. Continue in this worktree, validate the visual state when the machine allows it, then commit/push only the scoped changes and verify the remote hash. Do not push to `master` or merge without a separate request.
