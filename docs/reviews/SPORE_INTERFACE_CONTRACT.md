# Space Stage interface: correction contract

> Review/evidence record; captures and prompts do not imply acceptance or a current production instruction. [Documentation map](../README.md).

## Concrete review board

[Open the ten-state board](../ui-review/index.html). It separates reference evidence, proposed layout responsibilities and current-build captures. [SPORE_PALETTE_AUDIT.md](../research/SPORE_PALETTE_AUDIT.md) records actual category and shortcut mismatches and the next implementation contract. Source taxonomy is not assumed to be exact retail tab order. Browser preview was blocked by the local URL policy; only structure and syntax were verified.


23 September 2026. **The user rejected the cockpit candidate.** This supersedes the custom-console recommendations in FLIGHT_INTERFACE.md and the approval implications of prior rendered reviews. Removing rounded corners or adding a vector frame does not establish quality. The target is close Spore Space Stage interaction and feature parity before elective divergence, with original assets.

## Evidence reviewed again

- EA/Maxis [manual](https://shared.steamstatic.com/store_item_assets/steam/apps/17390/manuals/manual.pdf?t=1642702281), printed pp. 46–51. Inspected the existing local rendered pages, not just extracted text. The web fetch failed on this revisit; the local document remains available for verification.
- Browser pixel inspection of Gamepressure's [shop](https://www.gamepressure.com/spore/gfx/word/893447343.jpg), [badge case](https://www.gamepressure.com/spore/gfx/word/893447359.jpg), and [cargo transaction](https://www.gamepressure.com/spore/gfx/word/893447375.jpg). These are low-resolution Polish-localized references; screenshots do not prove input behavior. The badge image's page caption incorrectly describes trade. No reference art is a production asset.
- Earlier gameplay sampling is recorded in [SPORE_GUI_FORENSICS.md](../research/SPORE_GUI_FORENSICS.md). It does not establish frame timing, sound, or native input fidelity.

Manual observations: the lower-left map changes with view; communication has its own access point. A category opens a tool palette. Tool selection precedes target application. Charges sit at the top of a tool slot; shortcut numbers sit at the bottom. Health/energy sit beside the ship representation. Colony repair and refuelling use communications. System travel, galactic range/filtering and surface navigation are different states. Options and pause exist in the original footer; our Escape-only utility menu is an explicit user-requested difference.

Screenshot observations: the shop has an eight-column pictorial grid, quantities above icons, prices below, dim unavailable entries and a colored owner header. The cargo transaction places quantity adjustment and buy/sell controls outside the item cells. The badge case has rank filters, five columns of medallions, earned stars, progress strips and silhouettes. A hovered Collector badge shows 28/50 and a next-tier explanation. None of these counts belongs beside an unrelated weapon.

## Diagnosis of our rejected screenshot

| Element | Actual meaning | Failure | Correction / remaining work |
| --- | --- | --- | --- |
| Bottom text rail | Save/load/audio/help/history/title | Desktop application controls dominate a gameplay HUD | Removed; Escape opens a modal game menu |
| SHROUD ON | Recovered defensive module, 2 energy/second | Unexplained invented term and detached toggle | Removed from HUD; descriptive shield entry in Equipment; later actual tool-palette slot |
| Arc lance button | Prototype energy weapon | Clicking the palette immediately attacks a prechosen enemy | Select first, then target; item selection itself costs nothing |
| 0/2 beside weapon | Living specimen storage | Looks like ammunition; weapon actually consumes energy | Inventory access beside ship; explicitly labeled cargo occupancy elsewhere; no weapon-adjacent cargo number |
| Recharge | Navigate to prototype service dock | Reads as an instant ability; not item use or character commerce | Removed from HUD. Use an energy-pack item in Inventory; local communications lead to service interaction |
| Atlas / Contact | Planet map / one local nursery deal | Labels don't explain destination or speaker | Planet map / Communicate; full contextual communicator remains missing |
| Radar + independent tool deck + console | Three unrelated custom panels | Excess framing, empty space, military-dashboard tone | Entire visual assembly rejected; do not take minor corrections as approved art |
| Giant threat ellipse + static labels | Graybox pulse zone and encounter actors | Placeholder geometry dominates and labels advertise implementation | Needs a separate art/encounter brief; not repaired by HUD changes |

The shield, lance and dock are implementation scaffolding, not user-approved departures from Spore. Preserve saves and working commands while reconciling them with the parity catalog. Do not invent more signature equipment to avoid implementing the baseline.

## State-by-state target

These are project requirements derived from the evidence, not claims of verified retail behavior.

| State | Navigation / world | Right-hand tools and ship | Interaction contract |
| --- | --- | --- | --- |
| Surface flight | Geographic minimap, planet identity, communicator | Stable category row, compact item palette, ship, health/energy | Category browsing changes neither target nor simulation; selecting an item equips it |
| Tool targeting | Target highlight/cursor; range and outcome preview | Selected item retains its category color | Click valid subject to apply; invalid target explains why without spending stock |
| Cargo | World remains visible | Specimen/commodity icons with quantities; capacity; selected-item details | Choose an item then use/drop/sell where applicable; remote stock is not aboard |
| Consumable | No automatic dock travel | Owned energy-pack item, remaining quantity and use feedback | Consume one valid item; show full-energy, exhausted-stock or cooldown reason |
| Planet conditions | Navigation region switches to climate/ecosystem information | Applicable environmental tools | Measured versus unknown conditions remain distinct; visible intervention results |
| System | Star, planets, ownership and available contact | Equipment stays anchored; unavailable tools explain context | Select planet and travel, then descend through zoom; no detached teleport screen |
| Galaxy | Range, visited status, ownership and filters | Same ship status and inventory identity | Actual persistent ship follows accessible hops; energy and danger matter |
| Communications | Identify speaker, nation and relationship | Dedicated animated character/dialogue composition | Repair/recharge/trade/treaties are character services, not generic flight buttons |
| Shop | Provider identity, quoted prices and stock | Pictorial inventory, locks, owned state, buy/sell quantity | Badge unlock permits purchase; price, capacity and prerequisites still apply |
| Combat | Legible targets, danger and retreat path | Weapon selected; cooldown/energy attached to its slot | Selection never silently declares an attack; friendly/invalid targets cannot be hit accidentally |
| Badges | Collection screen with named accomplishment | Levels, progress, unlock preview, pinning | Achievement event links to a newly available capability and actual shop |
| Escape menu | Dim world, pause simulation and input | Resume, save/load, settings, history, title | Escape closes current window first; settings returns to menu; pre-existing pause is preserved |

## Navigation state contract — source-informed proposal

The [boundary evidence](../research/SPORE_EXTENDED_VIDEO_EVIDENCE.md) supports compact contextual system information and stable HUD anchors during a scale change. The following requirements are our design, not proof of source inputs or implemented Field Instruments behavior. No local surface chart appears in galaxy or system views.

| State | Required presentation and action |
|---|---|
| Known-star hover | Compact adjacent system identity and known planet rows; support long names/crowding. Immediate information, no travel or cost. Leaving hover dismisses it. |
| Unknown signal | Reveal only campaign-permitted knowledge; no concealed names, inhabitants, planet list or resources. Distinguish detected from visited/charted. |
| Selected destination | Distinct from hover. Prospective route, distance, drive reach, energy cost and energy after departure derive from campaign quote. Selection alone spends nothing. |
| Refused departure | Name the actual reason beside the destination/action: range, energy, access, active survey, hostile contact, atmosphere or existing journey. Include defense-field refusal; never imply a ready journey when commit will reject it. |
| Scale change | Intermediate and settled compositions retain recognizable origin/destination, ship identity and HUD anchors. Do not add mandatory cinematic delay. Proposed animation timing needs motion review. |
| Planet hover/selection | Distinguish inspection from committed destination. Expose surveyed versus unknown conditions and surface-capable versus orbital-only access. |
| Departure/transit | Revalidate and charge once; show actual progress and destination. Viewing another scale must not duplicate travel or spend energy again. |
| Back/cancel | Dismissing an uncommitted selection is free. Do not imply cancellation/refund after departure: current journey has no voluntary cancel command and locks chart back controls. Any future change needs explicit design and tests. |
| Access interrupted | Current campaign returns to departure orbit with spent energy not refunded; explain this outcome without a success animation. |
| Arrival | Preserve ship resources, reveal only earned information and identify destination. Arrival in orbit never implies automatic landing or a generated surface on an orbital-only body. |

Current implementation audit: `sector_chart.gd` uses select-then-activate and a generic hover tooltip; `system_chart.gd` uses a detached information panel. Both need reviewed state mocks. `expedition_session.gd` currently quotes3 energy/2 seconds locally; interstellar energy is at least8 and distance-based, duration2–4 seconds. These values belong to the simulation, not UI constants. Defense-field proximity now appears in `quote` and is revalidated by `begin_travel`; the previously recorded mismatch is repaired in source (see GALAXY_NAVIGATION.md for checks and export limits). The older12-second capture must not set mock timings.

## Next visual work, before another skin

1. Produce an annotated reference-to-project board for ordinary surface flight, expanded tools, cargo/consumables, contact, shop, planetary conditions, system and galaxy. Label source facts separately from proposed deviations. Preserve original artwork; don't import Spore UI assets.
2. Match functional grouping, relative screen occupation, icon density and state transitions. The compact tool tray belongs next to the ship, not in an isolated center console. Geographic navigation is not a generic combat radar. No invented frame merely to fill space.
3. Specify icon silhouette, material, hover, selected, locked, insufficient-resource, charge-count and cooldown states at actual 720p size. Establish readable text before ornamental lines. Color must identify category and condition consistently.
4. Review that board against the user's reference target before implementing another full visual language. Then implement one original kit and inspect it in motion across all listed states.

Open forensic work: exact category inventory and ordering across early/late game, context restrictions per tool, collapsed palettes, cursor semantics, incoming call interruptions, retail menu nesting, sounds and animation timing. Native input/listening audit remains unperformed. A static image and passing tests cannot close those gaps.

## Functional correction evidence

`test_flight_hud.gd` exercises Escape nesting, modal input, pause preservation, inventory consumption, weapon selection versus targeting and absence of the utility rail. `review_flight_interface.gd` renders ordinary flight, inventory and Escape menu. These verify the bounded corrections; they do not approve the current console art. Shared flight/sector state, a full communications shop and Spore-like expandable inventory palette are still missing.

The rejected cockpit SVG is preserved only under ignored artifacts. Production uses neutral readability backing pending the reviewed art kit; this is not a replacement art direction.
