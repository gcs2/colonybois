# Carried cargo, finite markets and purchasable unlocks

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. Implementation checkpoint for E01, I01, V02 and P01. This is a connected commerce pilot, not full Spore progression or economy parity.

## Play the loop

Open communications (Y or its icon), choose **Approach local dock**, then use Market, Upgrades or Energy. Transactions require the ship to be within docking range. Inspection pauses simulation. Inventory (I) shows quantities and source worlds; the HUD distinguishes the commodity hold from specimen cradles. Escape contains Badges, with progress, alternate eligibility paths and installed status.

At Morrow, load colony alloy. Each freight unit removes four real construction materials; exports must preserve 80 materials. Bulk quantities are 1, 4 or 8. This starts trade with no free money and no compulsory growing/delivery mission. Exporting competes with future colony construction. Freight capacity starts at eight; the two living-specimen cradles and three energy-pack slots remain separate.

The three ordinary pilot goods are alloy billets, purified water and resonant glass. Frozen worlds sell inexpensive water; arid worlds value it and supply inexpensive glass; cold worlds value that glass. Arid markets also value alloy. The spread makes same-market buying and selling a loss. Stock and demand are finite and shared by both docks on a planet. Changing views, landing and reloading never reset them. Every four colony days, markets recover one demand unit per good and one stock unit for their environmental producer goods, capped at initial capacity. Border embargoes also block transactions.

Example checked from a fresh campaign: load eight home alloys, sell at Kestrel I, buy an expanded hold, buy three glass, sell at Nacre I, carry eight waters back to Kestrel, then purchase the drive. This is one route through the pilot, not an assigned mission. Travel spends energy; foreign recharge and reserve packs still cost Marks. Production balance and longer sessions need playtesting.

## Progression pilot

Later combat integration adds Defender and the paid focused emitter, with Explorer 2 as an alternative unlock. See [ORBITAL_ENCOUNTERS.md](ORBITAL_ENCOUNTERS.md). Hold/drive behavior below remains unchanged.

Definitions live in `data/space_commerce.json`. Explorer measures distinct visited systems at thresholds 2/3/5/8/12. Merchant measures distinct origin/destination/commodity deliveries at 1/3/6/12/24. Repeating the same delivery does not increase that count; local resale never qualifies. These are **scenario adaptations**, not retail Spore thresholds or an assertion that its full badge semantics are reproduced. See SPORE_BADGE_PARITY.md for reference research and remaining families.

The expanded hold costs 120 Marks, requires Merchant 1 **or** Explorer 2, and increases freight capacity to 16. The extended drive costs 160 Marks, requires Explorer 1 **or** Merchant 2, and increases travel range from three to five links. Longer trips retain their full energy cost. Unlocks only permit purchases. Purchased equipment changes actual command limits and cannot be bought twice. Higher badge tiers currently provide recognition; further rewards remain unimplemented. Master ranks are not yet integrated with these badges.

## State and verification

Campaign snapshot version 3 adds cargo lots, source planets, depleted market stocks/demand, distinct trade flows, earned tiers and installations. Versions 1 and 2 migrate to an empty hold with no historical trade or free upgrades invented. Failed commerce or malformed saves leave existing state intact. Mid-journey ship ownership and the single shared Marks treasury are unchanged.

`tests/test_space_commerce.gd` exercises the resource-funded peaceful journey, actual dock button, bulk exports, reserve/capacity/stock/demand limits, embargo/proximity checks, no local arbitrage, badge deduplication, paid capacity/range, persistence and migration. `tests/review_commerce.gd` renders real panels at 1080p. Existing regression suites cover travel, input, energy, hazards, saves and palettes. Rendered layout checks do not establish native input feel, enjoyable balance or art approval.

## Surface prospecting pilot

25 September 2026. A scanned surface seam can now be worked with the Resonance cutter. Each world carries a finite four-crystal seam; surveying reveals it, and each successful cut spends 8 ship energy and occupies one real cargo unit. The resulting Resonant glass uses the campaign commodity inventory, market stock/demand, transaction ledger and chronicle, so it can be transported and sold through the existing economy. Remaining crystals persist per world across visits and save/load. The save migration accepts the prior campaign format without granting stock.

`tests/test_encounter.gd` covers the scan/target/tool interaction (54 assertions); `tests/test_expedition_session.gd` covers shared cargo, sale and persistence/migration (48 assertions). The 1080p before/after capture harness is `tests/review_surface_mining.gd`; local captures live under ignored `artifacts/visual-critic-surface-pass/mining/`. Independent visual review confirms the transaction feedback and target card are legible, but rejects the overall terrain/HUD materials and finds the ore still primitive. These are focused behavior and composition checks, not Spore feature parity, player acceptance, or a performance result.

### Visual critic review — 25 September 2026

The independent comparison packet paired the approved populated Morrow target (`artifacts/field-instruments-review/01-surface-populated-v3.png`), the basalt-lantern ore concept, actual 1080p intact/3-of-4 gameplay captures, and Spore's sample-collection frames at 30:05.2 and 30:07.2. The Spore frames show a ship collecting visible living samples with a beam; the mission text asks for plant and animal samples. This is a reference for keeping the action, target, tools and result legible together, **not** evidence that Spore has ore mining or these depletion rules.

The critic found the adjusted approach position, enclosing target ring, target card and `+1 Resonant glass` / cargo / energy receipt legible. It also found that the Tripo outcrop silhouette and mineral distribution appeared unchanged after mining. The actual image therefore communicated depletion mainly through `3 / 4` text. The approved target's terrain/material variation, clustered rocks and flora, and coordinated HUD are still substantially stronger than the live scene. Additional medium-level findings: distinguish the selected ore ring from the unrelated plant ring, make the cargo reward icon recognizable, strengthen the beam endpoint/acquisition cue, and improve resource-label contrast. No motion, audio, performance or overall-art approval was granted.

The reviewed Tripo GLB is one mesh primitive with one material; its internal mineral veins cannot be independently removed. The follow-up represents each of the four finite game-world resource units as a removable lode made from a basalt socket and three faceted crystal shards. `tests/test_expedition_session.gd` passes 48 assertions after that change. A lightweight 1080p staged capture harness was added, but it produced no images before the slow-machine run was stopped; the large-GLB review rerun also did not complete. Consequently this lode iteration is **not visually re-reviewed or accepted**. The prior critic's rejection still stands: depletion reads mainly through text, and the full scene/HUD remain far below target. Re-capture intact/partial/exhausted states and obtain an independent review when the runtime is responsive. Do not infer visual acceptance or performance from the code checks.

### Mining-to-manufacturing pilot — 25 September 2026

The first useful production recipe is connected to the same campaign economy. Scan and mine two units of Resonant glass from a finite seam, obtain two Alloy billets through real cargo/trade, then land within 12 m of a completed owned outpost with its Glassworks module and at least one local supply. Fabricating a Resonance focusing head consumes those four cargo units plus one local supply and no Marks. The head installs permanently on the shared ship, records the fabrication in campaign history, and reduces each later mine cut from 8 to 5 energy. The flight HUD and equipment details show the installed cost. The crafted-only head is not sold by the upgrade shop.

`tests/test_expedition_colonies.gd` covers the physical recipe, pictured colony action, real ingredient/supply consumption, energy reduction, HUD detail and campaign save/load (67 assertions). The related encounter, session, commerce, HUD and equipment suites pass 54, 48, 49, 50 and 27 checks. This proves the bounded behavior and persistence path; it does not establish that the new lode stages are visually readable or that the broader economy is fun or balanced. Additional recipes, processing stations, manufacturing routes, population-driven demand and market production remain open.

## Remaining scope

Remote service markets use bounded aggregate production/consumption, not simulated mines, farms, broad manufacturing, population demand or freight arrivals. [Owned export outposts](EXPEDITION_COLONIES.md) now produce separate physical warehouse stocks at actual operating cost; one Glassworks recipe converts traded/mined inputs into a useful ship upgrade. Kits occupy four freight spaces. [Paid freight contracts](EXPEDITION_FREIGHT.md) now sell actual warehouse consignments under demand/access/cost constraints. Additional recipes, processing stations, import routes, dynamic prices, seller inventories of upgrade tiers, full badge families/ranks, prize animations and proper commodity/badge artwork remain open. The old strategic resource routes remain separate. [Contact](EXPEDITION_CONTACT.md) now provides three animated portrait candidates and consequential price/access/chart agreements; military diplomacy remains missing.

The reused UI, world/ship kit and audio bank remain provisional or rejected. No claim of AAA presentation or full parity accompanies this checkpoint.
