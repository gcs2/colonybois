# Status check-in contract

> Delivery/reporting convention; the task board remains the only production queue. [Documentation map](../README.md).

This document owns reporting conventions. [PRODUCTION_GOAL.md](../PRODUCTION_GOAL.md) owns the objective; [TASK_BOARD.md](../TASK_BOARD.md) owns work status. No second goal wording or queue is maintained here. Repository documentation is not a live reading of the app's goal service.

When the user asks for a check-in, report:

- Current milestone, next concrete action and actual blockers from existing task IDs.
- Changes since the requested checkpoint, distinguished as proposed, isolated prototype, integrated behavior, verified export and player-accepted result.
- Coverage by non-overlapping owning category. Name the denominator, exclusions, evidence and uncertainty for every percentage. Do not combine research coverage, feature breadth and art acceptance into an invented completion score.
- Code/content statistics dated to an exact commit and counting rules. Asset records are not necessarily approved assets; generated planet records are not necessarily landable worlds.
- Forecast ranges with assumptions, calibrated to reviewed slices rather than tokens, lines of code or image counts.
- Latest playable build, relevant verification limits and verified remote backup hash. A local commit or source change alone is not an updated executable or off-device backup.

The parity TSV and dated estimates are supporting research drafts, not current production status. The reference inventory owns source-feature accounting; the board owns execution. Update the owning record and link to it, rather than copying a long status narrative into several documents.

## Unattended work

An app goal can support continued work subject to runtime availability, usage limits, permissions and blockers; it does not guarantee uninterrupted execution or zero risk. Check the live service before making claims about its state. No task authorizes purchases, unrelated system changes or bypassing access restrictions. Keep scoped permissions and verified backups. [Official goal documentation](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex).
