# Mock request intake

This folder contains actionable briefs for UX and game mock designers. It is not a second production queue: docs/TASK_BOARD.md is the sole queue and status ledger.

Every brief names its task-board owner, player activity, and link to the wider game loop; latest user decisions and exclusions; ground-truth images and evidence with their roles and acceptance status; relevant direction, research, system and review links; separate deliverables; shared continuity anchors; exact prompts; dimensions; and output filenames.

## Shared artifact home

Generated review images go in artifacts/designer-mocks/<TASK-BOARD-ID>/ in the assigned review worktree. The designer writes; the coordinator and critic read. Keep that home in place while review is open. Identify the exact worktree and absolute path in the handoff so the user and other agents can open the same files.

Each home contains a README.md index linking its brief, task-board items, ground-truth references and wider project context. Record every image's exact prompt, generator/tool, date, intended state and review status. Generated artifacts are ignored by Git. They are proposals, not proof of runtime behavior, playability, source fidelity or performance. User acceptance decides; critic feedback can guide revisions but cannot override it. Do not overwrite rejected images.