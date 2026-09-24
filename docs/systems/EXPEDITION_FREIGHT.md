# Automated physical freight

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. E01/I01/P01 checkpoint. This is the user-requested automation of established trade, an adaptation beyond hands-on Spore cargo trading; it is not a claim of retail feature parity.

## Play

Open **Communications → Colony administration → Freight contracts**. Choose a completed outpost, a destination system you have visited, one commodity and a warehouse reserve of 0, 4 or 8. The contract displays transport time, current four-unit sale value and transport margin before commitment.

Chartering costs **80 Marks** once per outpost. The carrier holds four units and has a five-link range. A shipment needs four actual warehouse units above the selected reserve, at least four units of known buyer demand, an open charted itinerary and enough Marks for transport. Each link takes two colony days each way; transport costs four Marks per link for the whole round trip, prepaid at departure. Same-system journeys have a one-link minimum. One colony day is 30 active seconds.

The carrier takes goods out of the warehouse, spends time outbound, sells only what the destination still wants, then returns. Actual arrival prices include active trade agreements. Unsold cargo comes home; if storage has filled, it remains aboard until space opens. Nothing is conjured into the player's hold, and the flagship remains free to explore.

Foreign automatic sales require a trade agreement. An embargo can close the booked transit itinerary. Non-aggression permits transit but does not reopen an embargoed market; such a shipment returns unsold. Route status explains holds and records new border blockages in the chronicle without repeating the same notification each tick.

**Pause departures** lets the current shipment finish. **Recall** reverses an outbound shipment's elapsed progress, retains cargo and pauses future departures. Transport is not refunded. Reconfigure an idle, empty carrier without another charter fee. The current two-outpost cap implies at most two carriers. There is no purchase of real goods or services outside the game.

The sector chart draws the booked itinerary and an orange carrier marker. These are strategic positions updated on colony ticks, not independently simulated 3D ships. Inspection pauses the shared simulation; travel continues through the usual personal journey rules.

## Accounting and persistence

Transport enters global/local upkeep; sales enter export receipts. The contract keeps cumulative shipment counts, delivered units, receipts and transport expenses across reconfiguration. The displayed transport margin excludes facility operating costs and the initial charter. Merchant progression counts distinct origin/destination/commodity flows once, just as manual sales do. Delivery chronicle entries record actual quantity, proceeds, unsold stock and the pricing agreement when applicable.

Snapshot v6 contains routes, cargo, phases, remaining time, itineraries and cumulative totals. V1–v5 saves receive no free carriers. Validation checks capacity, actual graph edges and endpoint consistency before replacing live state. One campaign clock runs freight, colony production, demand and ship travel; scene changes do not create another economy.

## Evidence and remaining scope

`tests/test_expedition_freight.gd` has 49 checks covering costs, reserves, time, manual/automatic cargo separation, changing demand, storage blockage, border closure, transit versus trade rights, recall, treaty pricing, Merchant deduplication, causal history, saves/migration and actual contract-button behavior. The full regression baseline plus these checks totals 802 assertions and UI checks. `tests/review_freight.gd` renders contract, outbound status and chart states at 1080p. These establish behavior/layout, not native control feel or economic balance.

Still missing: freighter 3D art and docking motion, piracy/escorts/losses, multi-stop routes, intermediate manufacturing, direct colony-to-colony supply deliveries, dynamic prices and population-driven demand. Service markets retain bounded aggregate replenishment. This implementation sells owned outpost output; it does not automate buying/importing arbitrary commodities or the older strategy-demo resource routes.

Next production should broaden spaceship challenge and encounter/progression breadth alongside the authored scout/art pipeline. Do not keep expanding economic submodels at the expense of flight, danger and presentation. A complete journey still needs native playtesting and user review before core-loop acceptance.
