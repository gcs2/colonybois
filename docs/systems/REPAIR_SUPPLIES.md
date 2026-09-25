# Carried repair supplies

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. C01/V02/P01 checkpoint. Dock services → Supplies sells two real inventory items; Inventory / I and the Inventory hotbar consume owned packs with a click. Both have original provisional vector icons, item counts, named tooltips and shared cooldown feedback. The inventory places supplies above specimen cradles.

| Supply | Effect | Acquisition |
| --- | --- | --- |
| Repair pack | Up to 75 hull; overflow is lost | Ordinary shop stock; 60 Marks at the home surface port, 90 at its orbital tender, 80 on frozen worlds and 105 on arid worlds |
| Full repair pack | All missing hull, including purchased capacity | Explorer 2 or Defender 2; 260/320 Marks at home surface/orbit, 300 on frozen worlds, 360 on arid worlds |

These are explicit sector tuning values, not asserted retail Spore numbers. The reference Repair Pack page has contradictory effect prose; its unresolved research entry remains open.

Both types share a three-slot repair locker, separate from the existing three energy-pack slots, freight hold and specimen cradles. They consume no reactor energy, work in surface/orbital flight and share a 20-second cooldown with the existing energy-driven field repair. A sound hull rejects consumption. Packs do not require exiting a hazard; their finite stock and cooldown provide the tradeoff against field repair. Pausing or repeatedly opening inventory cannot advance the cooldown or produce supplies. Installation/recharge never grants a repair pack. Energy still never regenerates; home recharge remains free.

Each provider has finite separate stock: the surface port starts with three basic and one full repair; the orbital tender has two basic and one full. Stocks persist per world and do not replenish on visits or view changes. Campaign commands now validate docking, travel and embargoes for **all** services, including existing recharge and energy-pack purchases, which previously bypassed embargo checks. Purchases and repair consumption append actual cost/recovery outcomes to the chronicle.

## Direct dock hull repair

In addition to carried repair consumables, local dock facilities provide authoritative flagship hull repair:

- **Missing-hull recovery**: Direct repair restores all missing hull up to full baseline or purchased capacity (`max_capacity("hull")`), leaving sound hull intact without wasted spend.
- **Explicit local Marks tariff**: Unlike homeworld energy recharge which is free on Morrow, dock repair charges an explicit local fee proportional to missing hull:
  - Basin home port (`morrow`, surface): 0.5 Marks / hull point.
  - Guild service tender (`morrow`, orbit): 0.8 Marks / hull point.
  - Frozen worlds (e.g. `s1p0`, orbit): 0.7 Marks / hull point.
  - Arid worlds (e.g. `s2p0`, orbit): 1.0 Marks / hull point.
- **Atomic validation**: Dock repair strictly rejects full hull (`"Hull is sound."`), insufficient funds, remote distance / missing reach, incompatible flight modes (surface vs orbit), in-transit voyages, and active faction trade embargoes.
- **Invariants**: Dock repair consumes Marks and heals the flagship frame; it never restores reactor energy, grants or modifies consumable repair/energy packs, adjusts dock merchant stocks, or clears field cradle cooldowns.
- **Chronicle**: Successful transactions log to the campaign chronicle under category `equipment` with exact Marks spent and dock facility name.

Session snapshot v9 and field snapshot v8 preserve carried counts, local/inactive-world stocks and the shared repair cooldown. Old campaigns gain the new shop offers but no free carried items, healing or energy. Validation rejects negative/fractional counts, locker overflow, malformed stocks and broken prior-upgrade chains before replacing the live campaign.

## Evidence and next work

The full suite passes with **998 assertions plus UI checks**, including 46 direct dock repair checks (`tests/test_dock_repair.gd`) verifying quotes, atomic refusals, multi-tier hull capacity scaling, local/foreign tariffs, embargoes, transit blocks, persistence roundtrips, and invariant protection alongside 46 repair-supply checks. Renderer captures cover supply shop, inventory and palette at 1080p/1440p. Shortened repeated service text after inspecting the first render so both repair offers fit visibly at 1080p. Current art, audio, native input feel and difficulty balance remain unapproved; this is not AAA acceptance.

Next connect direct dock repair to the encounter dock service UI, displaying the dynamic quote and fee. Do not interpret these two items as completed C01, a complete seller catalog or survival-tool parity; mega energy/fleet consumables and wider content remain missing. Keep native presentation/audio work bounded and active alongside feature breadth.
