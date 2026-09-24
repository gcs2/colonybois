# Purchased hull and reactor capacity

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. C01/P01 implementation checkpoint; this advances the connected ship loop without claiming complete survival-tool or badge parity.

Dock services → Upgrades now separates Equipment, Hull and Reactor. Each capacity family has four purchased tiers: **150, 225, 325 and 450**, following the starting 100. Tier two onward requires the preceding installation. Hull accepts Defender or Explorer at the corresponding tier; reactors accept Merchant or Explorer. This retains peaceful access. Prices are 160/320/650/1,200 Marks for hull and 180/360/700/1,300 for reactors. These values are explicit authored-sector tuning, not claimed retail Spore numbers.

Installation preserves current hull and energy amounts. It does not repair damage or fill the extra capacity. Existing field repair still costs 30 energy for up to 35 hull with its cooldown/hazard restrictions; packs restore up to 50 energy with the same cooldown and finite stock. Foreign recharge charges the actual missing units at the local rate. Homeworld recharge remains free; passive regeneration remains absent. Costs to fire, survey, travel and recover are unchanged. Higher capacity makes longer expeditions possible after the player funds and fills it.

HUD meters, service quotes, pack feedback and the systems panel use the same capacity derived from purchased equipment. One persistent ship carries these upgrades between worlds. Session snapshot v8 loads v1–v7; validated commerce ownership and prerequisite chains are restored before accepting hull/energy above 100. Bad loads leave the live campaign intact. Capacity is derived, never trusted from a save's claimed maximum. Old saves receive no free upgrade or resources.

## Verification and remaining work

The 46 new integration assertions include an actual peaceful export voyage funding its first reactor, sequential purchases, refusal to skip tiers, no installation refill, no regeneration, fixed pack/repair amounts above the old cap, foreign pricing, binary round trips, corrupt-save atomicity, v7 migration, actual shop-button purchase and authoritative HUD values. The full suite passes with 906 assertions plus UI checks. Actual renderer captures cover the shop at 1080p and systems at 1440p, with both panels generated at both resolutions. They confirm layout/function, not player approval of this still-provisional presentation.

Repair consumables, complete seller inventories, wider progression families/master ranks, distinct weapon roles and surface combat remain open. Current hull/energy upgrades are installed ship components, so each can be purchased once per ship; they do not pretend to implement scarce consumable stock. Defender's higher tiers remain unreachable with three encounters; Explorer supplies a reachable alternate route. Continue with inventory-selected repair packs and then distinct weapon roles, rather than indefinite panel ornamentation. Native pacing/difficulty and presentation review remain necessary.
