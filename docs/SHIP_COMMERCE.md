# Carried cargo, finite markets and purchasable unlocks

23 September 2026. Implementation checkpoint for E01, I01, V02 and P01. This is a connected commerce pilot, not full Spore progression or economy parity.

## Play the loop

Open communications (Y or its icon), choose **Approach local dock**, then use Market, Upgrades or Energy. Transactions require the ship to be within docking range. Inspection pauses simulation. Inventory (I) shows quantities and source worlds; the HUD distinguishes the commodity hold from specimen cradles. Escape contains Badges, with progress, alternate eligibility paths and installed status.

At Morrow, load colony alloy. Each freight unit removes four real construction materials; exports must preserve 80 materials. Bulk quantities are 1, 4 or 8. This starts trade with no free money and no compulsory growing/delivery mission. Exporting competes with future colony construction. Freight capacity starts at eight; the two living-specimen cradles and three energy-pack slots remain separate.

The three ordinary pilot goods are alloy billets, purified water and resonant glass. Frozen worlds sell inexpensive water; arid worlds value it and supply inexpensive glass; cold worlds value that glass. Arid markets also value alloy. The spread makes same-market buying and selling a loss. Stock and demand are finite and shared by both docks on a planet. Changing views, landing and reloading never reset them. Every four colony days, markets recover one demand unit per good and one stock unit for their environmental producer goods, capped at initial capacity. Border embargoes also block transactions.

Example checked from a fresh campaign: load eight home alloys, sell at Kestrel I, buy an expanded hold, buy three glass, sell at Nacre I, carry eight waters back to Kestrel, then purchase the drive. This is one route through the pilot, not an assigned mission. Travel spends energy; foreign recharge and reserve packs still cost Marks. Production balance and longer sessions need playtesting.

## Progression pilot

Definitions live in `data/space_commerce.json`. Explorer measures distinct visited systems at thresholds 2/3/5/8/12. Merchant measures distinct origin/destination/commodity deliveries at 1/3/6/12/24. Repeating the same delivery does not increase that count; local resale never qualifies. These are **scenario adaptations**, not retail Spore thresholds or an assertion that its full badge semantics are reproduced. See SPORE_BADGE_PARITY.md for reference research and remaining families.

The expanded hold costs 120 Marks, requires Merchant 1 **or** Explorer 2, and increases freight capacity to 16. The extended drive costs 160 Marks, requires Explorer 1 **or** Merchant 2, and increases travel range from three to five links. Longer trips retain their full energy cost. Unlocks only permit purchases. Purchased equipment changes actual command limits and cannot be bought twice. Higher badge tiers currently provide recognition; further rewards remain unimplemented. Master ranks are not yet integrated with these badges.

## State and verification

Campaign snapshot version 3 adds cargo lots, source planets, depleted market stocks/demand, distinct trade flows, earned tiers and installations. Versions 1 and 2 migrate to an empty hold with no historical trade or free upgrades invented. Failed commerce or malformed saves leave existing state intact. Mid-journey ship ownership and the single shared Marks treasury are unchanged.

`tests/test_space_commerce.gd` exercises the resource-funded peaceful journey, actual dock button, bulk exports, reserve/capacity/stock/demand limits, embargo/proximity checks, no local arbitrage, badge deduplication, paid capacity/range, persistence and migration. `tests/review_commerce.gd` renders real panels at 1080p. Existing regression suites cover travel, input, energy, hazards, saves and palettes. Rendered layout checks do not establish native input feel, enjoyable balance or art approval.

## Remaining scope

Remote service markets use bounded aggregate production/consumption, not simulated mines, farms, manufacturing, population demand or freight arrivals. [Owned export outposts](EXPEDITION_COLONIES.md) now produce separate physical warehouse stocks at actual operating cost; kits occupy four freight spaces. Automated ship-cargo routes, dynamic prices, seller inventories of upgrade tiers, full badge families/ranks, prize animations and proper commodity/badge artwork remain open. The old strategic resource routes remain separate. [Contact](EXPEDITION_CONTACT.md) now provides three animated portrait candidates and consequential price/access/chart agreements; military diplomacy remains missing.

The reused UI, world/ship kit and audio bank remain provisional or rejected. No claim of AAA presentation or full parity accompanies this checkpoint.
