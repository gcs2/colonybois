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

## Route threat, piracy and convoy defense

Routine routes through peaceful, unowned or allied territory are 100% safe and automatic. When a route traverses territory that is formally at war (`game.conflict.at_war`) or hostile (`relation < 0`), the carrier encounters deterministic threat (privateers, hostile patrols or raiders).

- **Strict cargo conservation:** Cargo is never silently deleted or vanished. Consignments remain fully aboard the carrier while intercepted, and the incident records carrier, cargo, commodity, timestamp, star system, route endpoints and threat risk.
- **Repeat incident caps:** Incidents are capped to at most one per voyage leg/trip (`incidents_this_trip < 1`). A carrier held at an incident or traversing subsequent hostile links cannot re-trigger runaway notifications or duplicate intercepts.
- **Consequential resolutions:** When intercepted, the drawer presents three distinct convoy orders:
  1. **Pay transit toll (50 Marks):** Charges local Marks upkeep, appeases the intercepting forces (+5 faction relation), and releases the carrier to continue to its destination.
  2. **Divert to return home:** Reverses the carrier's progress without paying a toll, pauses future departures, and safely unloads all cargo back into the origin warehouse upon return.
  3. **Flagship intervention (Convoy escort):** If the player's flagship is present in the incident system, the flagship disperses hostile forces, claims 60 Marks in recovered salvage, credits a naval victory if at war (or applies diplomatic consequences), and releases the carrier to complete its delivery.

## Accounting and persistence

Transport enters global/local upkeep; sales enter export receipts. Paid tolls enter upkeep; recovered salvage enters export receipts. The contract keeps cumulative shipment counts, delivered units, receipts, transport expenses, and incident counts across reconfiguration. The displayed transport margin excludes facility operating costs and the initial charter. Merchant progression counts distinct origin/destination/commodity flows once, just as manual sales do. Delivery and incident chronicle entries record actual quantity, proceeds, unsold stock, tolls, salvage, and the pricing agreement when applicable.

Snapshot v6 contains routes, cargo, phases, remaining time, itineraries, cumulative totals, and incident state (`incident`, `incident_count`, `incidents_this_trip`). V1–v5 saves receive no free carriers. Validation checks capacity, actual graph edges, endpoint consistency, and incident schema before replacing live state. One campaign clock runs freight, colony production, demand and ship travel; scene changes do not create another economy.

## Evidence and remaining scope

`tests/test_expedition_freight.gd` (67 checks) and `tests/test_freight_piracy.gd` (88 checks) cover costs, reserves, travel times, cargo conservation, safe routes (0 incidents), hostile routes, determinism, repeat incident caps, toll payment, divert returns, flagship escort salvage, save/load survival, corrupt incident rejection, and UI drawer integration with resolution controls. `tests/review_freight.gd` renders contract, outbound status and chart states at 1080p. These establish behavior/layout, not native control feel or economic balance.

Still missing: freighter 3D art and docking motion, multi-stop routes, intermediate manufacturing, dynamic prices and population-driven demand. Service markets retain bounded aggregate replenishment. This implementation supports owned outpost output sales and inter-outpost supply deliveries; it does not automate buying/importing arbitrary commodities or the older strategy-demo resource routes.

Next production should broaden spaceship challenge and encounter/progression breadth alongside the authored scout/art pipeline. Do not keep expanding economic submodels at the expense of flight, danger and presentation. A complete journey still needs native playtesting and user review before core-loop acceptance.
