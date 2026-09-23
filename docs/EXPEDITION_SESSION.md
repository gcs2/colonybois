# Shared expedition session — first integration checkpoint

23 September 2026. Task I01 is in progress; the multi-world loop is not complete.

The Morrow flight entry now owns an `ExpeditionSession` containing the sector simulation and the local encounter model. They share one treasury: purchases and field sales directly change the sector account, and colony income reaches the ship's displayed Marks. The local model has no second Marks balance when bound to a campaign. Fractional colony income is retained; the HUD displays whole Marks.

Active flight advances a fixed one-second clock. Every 30 seconds the sector advances one simulation day, including colony production, existing routes and projects. The partial day is saved. Pause and inspection stop both models. Surface/orbit transitions do not advance the economy themselves. This cadence is an initial balance setting, not a claim of final economic tuning. Energy still requires a pack or docking; income cannot regenerate energy.

## Persistence and migration

- Manual and autosave campaign files are `field_encounter_campaign.fw` and `field_encounter_campaign_auto.fw` in the game's user data directory. Review runs use a separate prefix.
- Each versioned binary snapshot contains the sector, ship/encounter state and partial-day clock. Temporary-file replacement avoids writing a partially serialized snapshot over the previous save.
- On entry, the newer existing campaign slot is selected. If neither exists, the newer legacy field JSON is imported. Original JSON files remain untouched.
- Migration preserves existing Marks, hull, energy, packs, specimens, surveys, cooldowns, local orders and history. It does not add the unrelated strategic demo's 650-Mark starting balance or retroactively simulate colony income.
- Invalid startup restoration pauses the scene and disables saving, so an empty fallback cannot overwrite the affected campaign. A successful manual restore clears this protection.
- The old urban, expedition and sandbox demos retain their separate saves and suspended-session behavior. They are not silently merged into the new flight campaign.

Escape → Chronicle currently shows colony day, shared treasury and the latest tax/upkeep/export amounts. This is temporary observability for the integration; it does not replace the planned full economic interface or unified timeline.

Validation: 565 assertions plus UI checks passed; the exported flight package passed a headless startup smoke test using isolated review slots. Play.cmd selects build `20260923-130227`. Native visual/fun review was not performed for this infrastructure checkpoint.

## Evidence and limits

`test_expedition_session.gd` exercises shared purchases/sales, fractional money, exactly-once day ticks, non-regenerating energy, transitions, full save round trips, deterministic continuation, rejected snapshots, legacy preservation, and the actual encounter scene's pause/inspection/save/load/HUD paths. Existing tests continue to exercise isolated local rules as well.

Other worlds are still not personally visitable. Navigation, cargo manifests, ship equipment, cross-world ownership, sector presentation and chronicle events still need integration. The local model still mixes Morrow world state with ship state; split those before adding second-world flight. The sector flagship's travel record is not yet the personal ship's travel authority. Do not call I01 or overall parity complete.

Next: give the shared session sole ownership of destination and ship travel; expose the real sector through its flight navigation view; persist each world's local state separately. Prove travel away and back retains cargo, condition, elapsed production and discoveries before broadening the catalog.
