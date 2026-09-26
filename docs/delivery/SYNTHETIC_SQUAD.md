# Synthetic squad: bounded worker contract

This contract describes a low-cost way to complete independent, reviewable work. It does not alter product direction, task priority, milestone gates, or acceptance authority. [TASK_BOARD.md](../TASK_BOARD.md) remains the only production queue, [ROADMAP.md](../ROADMAP.md) owns milestone gates, and [NEXT_SESSION.md](../NEXT_SESSION.md) owns the current handoff.

## Roster and routing

Use one **GPT-6 Sol coordinator at high reasoning effort** and up to three **GPT-6 Luna workers at high reasoning effort**. The workers may take implementation, design/mock, or bounded verification work. Do not add an API service, paid provider, or external orchestrator. Model choice is a routing preference, not proof of quality or a connected provider.

The coordinator selects one existing task-board item, defines its baseline commit and acceptance evidence, assigns work, resolves conflicts, reviews patches, and owns all integration. Workers receive narrow assignments and separate worktrees when they edit code. The visual/design worker writes only to its explicitly named output home. Do not assign concurrent work when tasks depend on each other or share mutable files, artifacts, or state. Keep a small correction with one worker when delegation costs more than the work.

## Assignment packet

Every worker assignment names:

- the TASK_BOARD item and baseline commit;
- branch and dedicated worktree (or, for visual work, the exact isolated output directory);
- allowed files and directories, including any exclusions;
- expected behavior, public interface, and dependencies;
- the focused verification budget and commands;
- required report fields and whether a commit is requested.

Only the coordinator integrates code, edits shared task-board state, updates cross-cutting documentation, creates checkpoints, or pushes. Workers do not push. A worker must stop before touching an unlisted path and report the dependency instead of broadening scope. An existing dirty worktree belongs to its current author; use another worktree rather than replacing or staging that work.

## Worker report

Return a compact report with:

1. status and branch/worktree;
2. baseline and resulting commit, if a commit was requested;
3. exact changed files;
4. behavior or artifact produced;
5. commands, results, failures, and elapsed time;
6. remaining risks, dependencies, and evidence limits.

Separate observed evidence from inference. Tests establish only the behavior they exercise; they do not establish playability, performance, readability, art acceptance, or fun. Visual proposals stay proposals until the user accepts them.

## Validation and Godot profiles

`tools/Test.ps1 -List` lists registered tests without launching Godot. `tools/Test.ps1 -Tests <name-or-path>` runs only named tests; `-All` is the explicit full-suite opt-in. With no selection, the script prints usage and runs nothing. Use `-Profile <label>` for a labeled test-run profile. The test wrapper reports each selected test and total elapsed time. Prefer the narrowest relevant tests; run the full suite only at a major integration gate or when the user explicitly requests it.

`tools/RunGodot.ps1` launches Godot in ordinary windowed mode by default, or with `-Editor` / `-Headless`. It forwards Godot arguments as an argument array. Each invocation derives a user-data directory name from the normalized project/worktree path and optional profile label, using a temporary root `override.cfg`. This keeps saves/configuration isolated across worktrees while project-local import/cache/build artifacts remain in their own worktrees. `-GodotPath` can point at a shared, read-only engine executable while `--path` still targets the current worktree. The override is ignored, removed after the process exits, and never replaces an existing file; if a developer override already exists, the launcher stops and leaves it untouched. Godot 4.7 documents root `override.cfg` as the project-setting override mechanism and documents both custom user-directory settings in [ProjectSettings](https://docs.godotengine.org/en/4.7/classes/class_projectsettings.html).

Workers report the real commands and durations they ran. Do not claim that parallel agents have proved runtime performance or player enjoyment. Avoid launching concurrent Godot copies for a performance observation; identify background load and its limits.

## Visual and authored-asset work

Visual review uses a matched target/reference and actual runtime capture with provenance, view/state, resolution, camera, build/commit, and relevant measured values. Compare composition, materials, world context, legibility, interaction and motion evidence; no-clipping alone is not acceptance. Critic findings are bounded to supplied evidence, and explicit user decisions take precedence. The approved Morrow views are fixed canon: do not regenerate them. For a missing view, follow the task-backed designer brief and provide concise prompts for the user-selected competent external designer/generator; Codex image generation is not the default. Stage candidates in the shared integration-worktree home, then promote only user-approved originals into tracked art/visual-canon.

For an authored 3D pilot, the intended path is an isolated original 2D concept, reviewed silhouette, image-to-model conversion only after the user approves any concrete price and license, then a small Godot wrapper scene and checks for shape, materials, pivot, collision, camera distance, performance and export loading. Tripo is not connected by this contract. Preserve source/provenance for approved assets; rejected or unreviewed render variants remain local and do not count as shipped art. Character modeling and new character design remain deferred unless current project direction changes.
