# Documentation map

Start with the [current handoff](NEXT_SESSION.md) and [task board](TASK_BOARD.md). For running, controls and build commands, use the [project README](../README.md).

This library is organized by **the question a document answers**, not by a mixture of subsystem, date and priority. Each maintained file has exactly one primary category in [DOCUMENTATION_MAP.json](DOCUMENTATION_MAP.json). Links between categories are expected; duplicated authority is not. The root entry points, `parity/` machine-readable evidence and `ui-review/` web assets retain stable paths where tools or existing entry links depend on them.

## Mutually exclusive homes

| Category | Owns | Does not own |
|---|---|---|
| [Direction](direction/README.md) | Intended player experience, scope, world/story and gameplay requirements | Task status, proof that a feature works |
| [Delivery](delivery/README.md) | Work order, handoff, reporting conventions and documentation governance | A second feature specification or asset acceptance |
| [Systems](systems/README.md) | Architecture and implementation checkpoints: behavior, persistence, validation and known limits | New product priorities or final art approval |
| [Art](art/README.md) | Production briefs, original art/audio direction, asset contracts and deferred character options | Evidence that a generated candidate is accepted |
| [Research](research/README.md) | External-game/platform observations, sources, reference inventories and confidence | Our implementation completion percentage |
| [Reviews](reviews/README.md) | Internal playtests, critiques, mocks, prompt provenance, acceptance feedback and postmortems | Authority to start the next feature |
| [History](history/README.md) | Superseded plans, snapshots and unselected alternatives retained for context | Current instructions, queue or canon |

Classification rule: use the document's primary decision purpose. A feature checkpoint may cite tests and a research paper without becoming three documents in three categories. If a new document has two independent governing purposes, split it and link the parts. Legacy mixed documents retain their historical context; their category identifies their primary purpose, not a claim that every paragraph is exclusive.

## One owner for each current question

| Question | Authoritative owner | Supporting material |
|---|---|---|
| What are we trying to build? | [Production goal](PRODUCTION_GOAL.md) | [Space-first direction](direction/SPACE_FIRST_DIRECTION.md) |
| What features and exclusions define the target? | [Space Stage target](direction/SPACE_STAGE_TARGET.md) | Research inventories account for reference families; exclusions are not delivered features. |
| What happens next; what is its status? | [Task board](TASK_BOARD.md) | [Handoff](NEXT_SESSION.md) is a short pointer, [roadmap](ROADMAP.md) owns milestone gates. |
| What story is currently endorsed? | [Current story](direction/STORY_CURRENT.md) | Older foundation/explorations are historical; a mandatory city-first opening is deferred. |
| What was implemented and checked? | Relevant [system checkpoint](systems/README.md) | Read its date and limits; tests do not establish fun or final quality. |
| How do we report status? | [Check-in contract](delivery/GOAL_AND_CHECKINS.md) | TSV estimates and dated reports are supporting research, not another queue. |
| What visual behavior is required? | [Interface contract](reviews/SPORE_INTERFACE_CONTRACT.md), amended by [view review register](reviews/VIEW_MOCK_COVERAGE.md); user-approved targets and exact prompts are in the [visual canon home](../art/visual-canon/README.md). | Field Instruments is selected. Prompt records and generated images outside that canon are candidates. |
| What is the current character decision? | [Character scope](art/CHARACTER_SCOPE_OPTIONS.md) | [Modeling postmortem](reviews/MODELING_POSTMORTEM_2026-09-24.md): production stopped; prototypes failed the art gate. |
| How complete is our source understanding? | [Reference measurement contract](research/REFERENCE_COVERAGE_METRICS.md) | [Generated evidence report](parity/EXPERIENCE_REPORT.md); coverage is not parity. |

Latest explicit user decisions govern. A historical snapshot or a prompt cannot override a current decision. Apparent conflicts should be resolved in the owning document, with a pointer from the other source, rather than another “latest override” pasted across many files.

## Maintenance and verification

Every `docs/` file, including browser datasets and parity manifests, must be listed once with a category and document status. Status describes the document's role: `design`, `proposal`, `specification`, `checkpoint`, `evidence`, `deferred`, `historical`, `generated` or `current`; none is a game-completion badge.

Run `python tools/DocumentationReport.py` after changes. It checks exhaustive registration, unique ownership, placement, registered historical moves and local documentation links. `--write` refreshes the seven category indexes. It does not score writing quality, verify remote sources, validate media availability or prove semantic MECE for every game feature. The existing parity tooling remains responsible for reference-family/task ownership.

Do not append a session transcript to the handoff. Keep the latest build and concrete next action there; move old handoffs to History. Update existing task IDs in the board. Record new mock rejection or approval in Reviews, and link the decision from the relevant brief. Preserve source and approved design references; rejected render binaries remain local, as required by the working agreements.
