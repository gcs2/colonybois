# Every-view mock coverage

Field Instruments is the approved direction, not blanket approval of new images. This register accounts for every view family and meaningful substate identified by inspection of `encounter.gd` and `main.gd`. Each state below needs an explicit visual in the review board. An existing prompt, a tab label, or a hero image with a hidden state does not count as coverage.

## Delivery status

- Generated candidates: `artifacts/field-instruments-review/01-surface-v1.png`, `03-orbit-v1.png`, `04-system-v1.png`, `05-galaxy-local-v1.png` and `23-motion-storyboard-v1.png`.
- Surface candidate needs correction: the local surface chart erroneously includes a parsec readout; remove it and any copied galaxy symbols. Preserve distinct surface distances and functional item counts. The heading belongs inside the expanded category tray, never as a floating selected-tool caption.
- Motion candidate is a storyboard, not an implemented animation. Keep the controls compact in full-screen composition; don't let portrait-board proportions turn into a thick cockpit. Gauge startup must never imply passive energy regeneration or hide actual resource values.
- Orbit candidate is a higher-detail art target, not a two-day guarantee. System candidate introduces a redundant lower-left system chart and an overly busy asteroid foreground; reduce this without removing world richness. Galaxy candidate has a significant geometric error: the selected 2.4 pc destination lies outside its pictured 3 pc ellipse. Do not use it as a geometric implementation specification. The latest icon-area increase is not represented in these candidates.
- All other visual coverage remains **pending**. Prompts 01–23 are in FIELD_INSTRUMENTS_MOCK_PROMPTS.md; supplemental state sheets are required below. Latest user priority is aggregate/synthesize paired Spore/current/proposed references before more independent generation.
- Existing in-game captures establish the before state. They do not count as Field Instruments redesign mocks.

## Coverage ledger

| ID | Family | Required visual coverage | Planned base / supplement |
|---|---|---|---|
| N01 | Surface navigation | Normal flight, altitude/ascent cue, local map, hover and target selection | 01 + surface state sheet |
| N02 | Surface tools | Scan, collect, deploy; cooldown, invalid target, out of reach, low/empty energy | 01/02 + tool state sheet |
| N03 | Proposed resources | Visible mining deposit, gel harvest; cargo-full feedback; optional creature reward | Resource state sheet; explicitly proposed |
| N04 | Surface combat | Enemy selection/health, telegraph, impact, shield, damage direction, retreat/defeat | 02 + combat state sheet |
| N05 | Orbital flight | Planet approach, service tender, geographic marker attachment; no terrain chart | 03 |
| N06 | System navigation | Whole system, selected destination, unavailable destination, travel in progress | 04 + navigation state sheet |
| N07 | Galaxy navigation | Local reach, overview, below-plane orbit, fog states, unaffordable/out-of-range/embargo travel | 05/06 + navigation state sheet |
| N08 | Planet atlas | Geography/survey, resources, settlements, life, hazards, unsurveyed data | 07 + atlas layer sheet |
| C01 | Communications | Incoming transmission, base contact, agreements, exchange, fleet, conflict | 10 + communication state sheet |
| P01 | Possessions | Onboard cargo, surface store, specimens, energy/repair supplies, item use, full/empty storage | 08 + inventory state sheet |
| P02 | Ship systems | Installed modules, sockets, selected component, comparison, locked/absent equipment | 09 |
| D01 | Dock market | Buy/sell, quantity, total, stock/demand, affordability, capacity, transaction result | 11 + transaction state sheet |
| D02 | Dock upgrades | Equipment, hull, reactor, support; badge eligibility, purchase price, already owned | 12 + upgrade state sheet |
| D03 | Dock supplies | Energy/repair consumables, paid service, free home recharge, insufficient Marks | Dock service state sheet |
| D04 | Dock warehouse | Local store, ship transfer, reserves, capacity limits | 15 + warehouse state sheet |
| D05 | Dock fleet | Recruit/service escorts, unavailable berth/insufficient stock | 17 + fleet state sheet |
| D06 | Existing climate | Current condition/project/complete state only; expansion deferred | 19 + climate state sheet |
| E01 | Orbital signals | Offer, commitment, scan, decision, resolution | 18 + signal sequence sheet |
| E02 | Colony defense | Threat notification, defender condition, ammunition and response | 17 + defense sheet |
| E03 | Colony terms | Surrender, capture, ruins, consequences and commitment | 18 + terms sheet |
| L01 | Colony administration | Colony selection, construction stages, producing colony, shortage, storage | 15 + colony state sheet |
| L02 | Freight | Configure route, source reserve, destination demand, active, paused, blocked, recall | 16 + freight state sheet |
| R01 | Recognition | Badge case, selected badge/tier, locked unlock, earned reward notification | 13 + reward sheet |
| R02 | Chronicle | Timeline and filters, selected event, empty filter | 14 |
| B01 | Existing biosphere | Ecosystem inspection, missing slot, viable state, existing climate link | 19; no new ecology-led opening |
| A01 | Title / scenarios | Continue/new voyage, urban/expedition/sandbox, save choice; Sol marked planned | 21 + application state sheet |
| A02 | Escape | Resume, save/load, settings, return; save success/failure and overwrite confirmation | 20 + save/load sheet |
| A03 | Settings | Audio sliders/mute, controls and arrows/numpad, reduced motion | 20 + settings sheet |
| A04 | Sandbox | Separate save identity, permitted toggles, reset/cheat feedback | 21 + sandbox sheet |
| U01 | Retained city | Build view, overview, demand, ledger, services, overlays, advisor | 22 + retained city sheet |
| U02 | Retained strategy | Legacy galaxy, planet, empire diplomacy, imports/exports, specialization, existing terraform | Retained/deferred strategy sheet; mark superseded navigation clearly |
| X01 | Shared interactions | Hover/focus/pressed/disabled, long names, populated palette, inaccessible control reasons | Cross-screen state sheet |
| X02 | Interface motion | Boarding, skip, reduced motion, tray open/close, communicator reveal, reward | 23 + implemented motion prototype later |

## Review requirements

For every row: link current implementation evidence, candidate image(s), source timestamp/manual page where applicable, observed discrepancies, and acceptance status. Shared components may be reused, but the required state must actually be shown. Original or legacy-only screens may have no Spore equivalent; say so rather than inventing one.

Check 1920×1080 and larger layouts, pointer hit areas, keyboard focus, named tooltips, short/long item names and full inventories. Test actual scaling in implementation; raster mocks do not prove responsive layout. Full-screen world views must remain visually dominant.

## Motion rules

Initial boarding may use roughly 700 ms of visual assembly: short lateral housing travel, a catch settling, tool-tray unfolding, communicator shutters. Input must be usable immediately; skip snaps to the settled state. Reopening ordinary panels should take roughly 120–180 ms, be interruptible/reversible, and never steal aim/focus. Reduced motion uses an immediate state change or a brief fade, without travel, bounce, shake or gauge sweeps. Those numbers are initial targets for playtesting, not measured finished behavior. Author sound separately: soft mechanism/catch/relay cues at low level, no toy keyboard bounce. Preserve the real hull/energy values throughout.
