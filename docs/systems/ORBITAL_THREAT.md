# Orbital wreck encounter

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. One playable danger and reward in Morrow orbit. This is a bounded flight mechanic and candidate presentation, not ship combat or final art.

## Player path

Leave the atmosphere and commission the existing orbital chart from the atlas (20 reactor energy, 12 simulation seconds). The chart now marks a drifting wreck and its pulse radius on the live local instrument. The wreck is also visible in the world. Click its world label/shape, its chart contact, or **Salvage** on the target card. The same validated command flies the scout to the wreck. Stop, manual movement, pause or inspection cancels the order. Once close, the ship needs three uninterrupted seconds and 20 energy to recover a **phase shroud**. This is one persistent acquisition, not a repeatable delivery.

The field has a visible core radius of 19 local meters and a warning band out to 31. Exposure counts down in six fixed simulation ticks. The warning band shows risk without damage; each completed pulse in the core removes 18 hull. Moving clear resets the countdown. The cockpit shows hull, energy, distance and time to the next pulse. At zero hull, an emergency tow moves the ship to the safe holding point with 35 hull and at most 15 energy. It records the loss; recharge and repair make recovery possible.

Once recovered, **Shroud** appears beside the hull gauge. It reduces a pulse to five hull damage, consumes two reactor energy each fixed tick while active, and switches off when energy cannot cover it. The reactor separately recovers 1.5 energy per tick. The net reserve therefore still falls while shielding. Surface landing switches it off. Repair restores up to 35 hull for 30 energy, outside the warning band, with a 20-second cooldown. All actions validate before charging and pause during inspection. Existing field saves migrate to version 4.

## Implementation boundary and evidence

`encounter_state.gd` owns hull, exposure, repair timer, shroud ownership and emergency losses. `orbital_scene.gd` draws the wreck and field. `flight_navigation.gd` draws/clicks its chart contact. `encounter.gd` routes ship orders and feedback; `flight_hud.gd` displays controls. The visual ring and primitive wreck are placeholders for an authored 3D asset. The existing sound bank remains unapproved; acquisition currently uses its candidate achievement cue and damage uses the candidate error cue. No weapon, enemy AI, ship fitting economy or sector integration is implied.

`test_orbital_threat.gd` covers warning/core distance, damage timing, escape, energy and acquisition, shield depletion, repair/cooldown, tow recovery, save/load, version 3 migration, chart click, stop, paused controls and HUD state. `review_orbital_threat.gd` writes ignored captures at 1600×900 and 1280×720 for visual inspection. Native input and player judgment remain necessary to decide whether the encounter is tense and readable. The field still contains only one wreck; building a meaningful range of dangers, devices and ships is future work under the full [Space Stage target](../direction/SPACE_STAGE_TARGET.md).

Current packaged checkpoint: `build/versions/20260923-032255/FrontierWorlds.exe` (paired `.pck`), exported-pack smoke passed. Full suite: 417 assertions plus UI checks, zero failures. Captures confirm the warning, hull/energy gauges and controls fit at 1280×720; visual appeal and actual feel still require native playtesting.
