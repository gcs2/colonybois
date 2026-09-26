# Mock request intake

This folder contains actionable briefs for UX and game mock designers. It is not a second production queue: docs/TASK_BOARD.md is the sole queue and status ledger.

Every brief names its task-board owner, player activity, and link to the wider game loop; latest user decisions and exclusions; ground-truth images and evidence with their roles and acceptance status; relevant direction, research, system and review links; separate deliverables; shared continuity anchors; exact prompts; dimensions; and output filenames.

## Shared artifact home

Keep one shared staging home at artifacts/designer-mocks/<TASK-BOARD-ID>/ in the active integration worktree. If a worker creates files in its own worktree, it returns the images and exact prompts to Sol; Sol copies candidates into the shared staging home before critic and user review, then links the exact path. Candidate files stay ignored while review is open. Once the user approves an image, promote that exact original into tracked art/visual-canon and index it there; accepted canon must not live only in artifacts or a worker worktree.

Each home contains a README.md index linking its brief, task-board items, ground-truth references and wider project context. Record every image's exact prompt, generator/tool, date, intended state and review status. Generated artifacts are ignored by Git. They are proposals, not proof of runtime behavior, playability, source fidelity or performance. User acceptance decides; critic feedback can guide revisions but cannot override it. Do not overwrite rejected images.