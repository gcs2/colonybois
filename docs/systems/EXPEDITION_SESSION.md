# Shared expedition session — first integration checkpoint

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. Historical first integration checkpoint. [The travel checkpoint](INTERSTELLAR_FLIGHT.md) supersedes the Morrow-only limitations below. Task I01 remains in progress; trade/progression/contact integration is not complete.

The Morrow flight entry now owns an `ExpeditionSession` containing the sector simulation and the local encounter model. They share one treasury: purchases and field sales directly change the sector account, and colony income reaches the ship's displayed Marks. The local model has no second Marks balance when bound to a campaign. Fractional colony income is retained; the HUD displays whole Marks.

Active flight advances a fixed one-second clock. Every 30 seconds the sector advances one simulation day, including colony production, existing routes and projects. The partial day is saved. Pause and inspection stop both models. Surface/orbit transitions do not advance the economy themselves. This cadence is an initial balance setting, not a claim of final economic tuning. Energy still requires a pack or docking; income cannot regenerate energy.

## Persistence and migration

- Manual and autosave campaign files are `field_encounter_campaign.fw` and `field_encounter_campaign_auto.fw` in the game's user data directory. Review runs use a separate prefix.
- Each versioned binary snapshot contains the sector, ship/encounter state and partial-day clock. Version 25 also saves captain identity and first-commitment completion. Temporary-file replacement avoids writing a partially serialized snapshot over the previous save.
- On entry, the newer existing campaign slot is selected. If neither exists, the newer legacy field JSON is imported. Original JSON files remain untouched.
- Migration preserves existing Marks, hull, energy, packs, specimens, surveys, cooldowns, local orders and history. It does not add the unrelated strategic demo's 650-Mark starting balance or retroactively simulate colony income.
- Invalid startup restoration pauses the scene and disables saving, so an empty fallback cannot overwrite the affected campaign. A successful manual restore clears this protection.
- The old urban, expedition and sandbox demos retain their separate saves and suspended-session behavior. They are not silently merged into the new flight campaign.

## P02 captain foundation — 28 September 2026

The flight menu now separates **New scout expedition** from **Continue scout expedition**. New opens a captain-name and philosophy screen over the existing Morrow flight scene, then starts that same `ExpeditionSession`; it is not a separate creator mode. A first-time Continue with no save also opens the screen. A failed initial autosave rolls back the unstarted identity instead of entering play unsaved.

Scientist commits to survey Morrow from orbit; Zealot commits to establish a scanned native species on another world; Knight commits to neutralize Morrow's existing custodian. These are obligations fulfilled through existing survey, specimen release and personal-combat actions, not hidden stat bonuses. The founding choice and completion are chronicle events; completion is linked to the action that fulfilled it. The Chronicle shows the active or fulfilled commitment.

Version 1–24 saves load with an explicit `unrecorded` captain and no fabricated founding history. Player identity remains separate from faction government. Species choice, new character art and source-game powers are not part of this flow.

The focused `test_captain_founding.gd` passed 20 checks in 5.77 seconds, including the real Morrow survey, screen signal, completion history and version-24 migration. `test_planet_biosphere.gd` ran 74 checks and reported four failures in its scene approach/scan/collection/inventory path; the later ecology-release checks had no additional reported failures. No baseline comparison was made, so those failures are unresolved rather than attributed to this change. No graphical runtime review, independent visual score or user presentation approval exists; the designer mock remains pending, and the screen's current vector emblems are provisional.

Escape → Chronicle currently shows colony day, shared treasury and the latest tax/upkeep/export amounts. This is temporary observability for the integration; it does not replace the planned full economic interface or unified timeline.

Validation: 565 assertions plus UI checks passed; the exported flight package passed a headless startup smoke test using isolated review slots. Play.cmd selects build `20260923-130227`. Native visual/fun review was not performed for this infrastructure checkpoint.

## Evidence and limits

`test_expedition_session.gd` exercises shared purchases/sales, fractional money, exactly-once day ticks, non-regenerating energy, transitions, full save round trips, deterministic continuation, rejected snapshots, legacy preservation, and the actual encounter scene's pause/inspection/save/load/HUD paths. Existing tests continue to exercise isolated local rules as well.

Other worlds are still not personally visitable. Navigation, cargo manifests, ship equipment, cross-world ownership, sector presentation and chronicle events still need integration. The local model still mixes Morrow world state with ship state; split those before adding second-world flight. The sector flagship's travel record is not yet the personal ship's travel authority. Do not call I01 or overall parity complete.

Next: give the shared session sole ownership of destination and ship travel; expose the real sector through its flight navigation view; persist each world's local state separately. Prove travel away and back retains cargo, condition, elapsed production and discoveries before broadening the catalog.
