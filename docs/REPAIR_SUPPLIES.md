# Carried repair supplies

23 September 2026. C01/V02/P01 checkpoint. Dock services → Supplies sells two real inventory items; Inventory / I and the Inventory hotbar consume owned packs with a click. Both have original provisional vector icons, item counts, named tooltips and shared cooldown feedback. The inventory places supplies above specimen cradles.

| Supply | Effect | Acquisition |
| --- | --- | --- |
| Repair pack | Up to 75 hull; overflow is lost | Ordinary shop stock; 60 Marks at the home surface port, 90 at its orbital tender, 80 on frozen worlds and 105 on arid worlds |
| Full repair pack | All missing hull, including purchased capacity | Explorer 2 or Defender 2; 260/320 Marks at home surface/orbit, 300 on frozen worlds, 360 on arid worlds |

These are explicit sector tuning values, not asserted retail Spore numbers. The reference Repair Pack page has contradictory effect prose; its unresolved research entry remains open.

Both types share a three-slot repair locker, separate from the existing three energy-pack slots, freight hold and specimen cradles. They consume no reactor energy, work in surface/orbital flight and share a 20-second cooldown with the existing energy-driven field repair. A sound hull rejects consumption. Packs do not require exiting a hazard; their finite stock and cooldown provide the tradeoff against field repair. Pausing or repeatedly opening inventory cannot advance the cooldown or produce supplies. Installation/recharge never grants a repair pack. Energy still never regenerates; home recharge remains free.

Each provider has finite separate stock: the surface port starts with three basic and one full repair; the orbital tender has two basic and one full. Stocks persist per world and do not replenish on visits or view changes. Campaign commands now validate docking, travel and embargoes for **all** services, including existing recharge and energy-pack purchases, which previously bypassed embargo checks. Purchases and repair consumption append actual cost/recovery outcomes to the chronicle.

Session snapshot v9 and field snapshot v8 preserve carried counts, local/inactive-world stocks and the shared repair cooldown. Old campaigns gain the new shop offers but no free carried items, healing or energy. Validation rejects negative/fractional counts, locker overflow, malformed stocks and broken prior-upgrade chains before replacing the live campaign.

## Evidence and next work

The full suite passes with **952 assertions plus UI checks**, including 46 repair-supply checks for price/stock conservation, unlocks, full/fixed recovery, cooldowns, travel, embargoes, legacy migration, corrupt-save atomicity and actual shop/inventory/hotbar clicks. Renderer captures cover supply shop, inventory and palette at 1080p/1440p. Shortened repeated service text after inspecting the first render so both repair offers fit visibly at 1080p. Current art, audio, native input feel and difficulty balance remain unapproved; this is not AAA acceptance.

Next advance distinct weapon roles and surface targets through the same ship, persistent costs and world state. Do not interpret these two items as completed C01, a complete seller catalog or survival-tool parity; mega energy/fleet consumables and wider content remain missing. Keep native presentation/audio work bounded and active alongside feature breadth.
