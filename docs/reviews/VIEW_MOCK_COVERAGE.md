# Every-view mock coverage

> Review/evidence record; captures and prompts do not imply acceptance or a current production instruction. [Documentation map](../README.md).

Field Instruments is the approved direction, not blanket approval of new images. This is an open working inventory derived from `encounter.gd` and `main.gd`; dispatch inspection does not establish exhaustiveness. Delegated signal, conflict, chart, city and other panel modules still need a complete state audit. Each state below needs an explicit visual in the review board. An existing prompt, a tab label, or a hero image with a hidden state does not count as coverage.

## Coverage audit - 24 September 2026

The user challenged the implementation-first drift. Small functional corrections and critic checks for clipping did not satisfy the required source/current/mock comparison. No claim of 100% source fidelity or mock coverage is supported.

| Dimension | Verified register result | Limit |
|---|---|---|
| Source workflows visually sampled | 17/61 (27.9%) | Open denominator; not all states or rules observed |
| Source workflows with readable evidence | 6/61 (9.8%) | Exact cited claims only |
| Source interactions fully verified | 0/61 | Before/action/result, restrictions and failure evidence incomplete |
| Source presentation / audio reviewed | 0/61 / 0/61 | Muted stills do not establish delivery or sound |
| View families with a base candidate file | 6/33 (18.2%) | File presence only; all have pending states or corrections |
| View families with fully evidenced required mock states | 0/33 | No family currently has its complete state sheet and review trail |
| Exact individual-state denominator | Not yet closed | Existing rows bundle states; do not invent a state-level percentage |
| Implemented / user-accepted | Separate task-board evidence | Neither tests nor critic approval imply user acceptance |

Recomputed with tools/ReferenceCoverageReport.py and checked the six candidate files on disk (all 1672x941). Source resolution scores measure actual source gameplay pixels, not these generated mock dimensions. No new source-verification flags were awarded in this audit. Independent audit supports the zero complete-state result but found missing explicit substates; the existing rows below now name orbital combat/salvage, navigation cancellation/swap phases, contact first/repeat/refusals, chronicle pagination and save fallbacks. The 33-family denominator remains open, not a certified exhaustive partition.

| Family | Existing base candidate | Still missing |
|---|---|---|
| N01 | artifacts/field-instruments-review/01-surface-v1.png | Correct chart units, actual icon scale, all navigation substates |
| N05 | artifacts/field-instruments-review/03-orbit-v1.png | Approach/service/selection/invalid/low-energy states and achievable asset mapping |
| N06 | artifacts/field-instruments-review/04-system-v1.png | Remove redundant chart; selected/unavailable/travel states |
| N07 | artifacts/field-instruments-review/05-galaxy-local-v1.png | Correct range geometry; overview/below-plane/fog/refusal states |
| C01 | artifacts/field-instruments-review/10-contact-v2.png | Approved replacement face/dialogue treatment; agreements/exchange/fleet/conflict states |
| X02 | artifacts/field-instruments-review/23-motion-storyboard-v1.png | Every specified motion state, timing and actual motion evidence |

All other 27 registered families lack a mapped Field Instruments base candidate. Character experiments do not count as screen mocks; actual game captures do not count as redesign mocks. Contact window/choices have partial user endorsement, not whole-family approval.

### Orbital HUD comparison inspected in this audit

Navigation follow-up: the atlas now uses unobscured full-screen galaxy/system recaptures at effective 1080p. Independent critic contact_shop_critic verified readable endpoint states; RF002/RF003 gain readable evidence only. The older small frame limitation below applies to the initial orbital comparison, not the replacement system/galaxy cards. The actual scale-change boundary and surface approach sequence remain absent. Corrected mocks must show populated category trays, quantities, alternate categories, ally indicators and brief notifications. Five isolated icons are insufficient evidence of content capacity. Preserve the user's Escape-only application menu rather than copying Spore's permanent bottom strip.

- Source: archived Spore manual image manual-27.png, printed pages 48-49, establishes tool categories/expansion, contextual availability, selection then targeting and wheel-based scale controls. The 02:00:09 system-video frame establishes broad composition only: gameplay is small, overlay-obscured and unsuitable for exact text/value claims. System footage is not a direct equivalent of our separate orbital encounter view.
- Current: artifacts/landing-motion/frame-050.png from the latest native sequence. Small globe with large empty sky, scattered bottom HUD panels, separate text status blocks and weak instrument grouping. The landing ring/readout corrections do not resolve these composition problems.
- Target: 03-orbit-v1.png inspected directly. World dominates; small grouped ivory/charcoal controls and pictorial categories. Detailed ship/planet/dock art is a target, not proof of achievable implementation or approved assets. Fictional altitude/currency/energy values are illustration only.
- Required next evidence: readable extended gameplay before/during/after planet approach and scale changes, plus our corresponding states and a corrected orbital state sheet. Do not implement a new orbital HUD from this one hero image alone.

### Navigation boundary review and missing state sheet

Four readable intermediate source frames now supplement the galaxy/system endpoints; see [source evidence](../research/SPORE_EXTENDED_VIDEO_EVIDENCE.md). Independent critic confirmed the compact system summary, its collapse as planets spread out, and stable HUD anchors. The earlier statement that the boundary is entirely absent is superseded; continuous motion, triggering input, approach and audio remain unverified. Counters remain 17/61 sampled, 6/61 readable, zero complete interaction/presentation/audio verification.

N07 state sheet must show known-star hover (including crowded/long names), unknown-signal redaction, hover exit without activation, selected route, and each actual refusal reason. N06 must show intermediate/settled scale change, planet hover versus selection, available quote, departure/transit, back/cancel availability, access interruption and orbital arrival. Existing overview/fog/camera-angle requirements remain. These are missing mocks, not newly covered states; the [interface contract](SPORE_INTERFACE_CONTRACT.md) owns their behavior.

Critic comparison: 05 lacks the known-system summary; 04 lacks transition/refusal states and still has redundant chart/foreground clutter. Actual system capture separates the quote into a remote text panel and lacks ship/HUD continuity. Its 12-second quote is outdated; current code quotes 2 seconds locally and 2–4 interstellar. No new view-family completion or user acceptance is awarded.

### Navigation composition fixtures

`tests/review_field_navigation.gd` generates eight schematic states at 1920×1080 and 2560×1440: known hover, unknown hover, selected journey, insufficient energy, intermediate scale, system selection, transit and arrival. Outputs are `artifacts/field-instruments-review/states/navigation-{known,unknown,selected,denied,intermediate,system,transit,arrival}-{1920,2560}.png`. These are code-drawn layout studies, not final environmental/art mocks, campaign-bound UI or input tests. Six base candidate families and zero complete family state sets remain unchanged.

The range ellipse and fixture destination share a projected plane; the 2.4 pc target is at 80% of a 3 pc radius. Known rows and unknown redaction are deliberate fixture data, not actual generated Nacre geography. Quote arithmetic follows the current formula but does not invoke campaign validation. System selection is a separate 92-energy fixture, not the next event after the 84-energy interstellar arrival. Cached provisional glyphs now render correctly; transit has one ship. Remaining requirements include real world fidelity, hovered planet, crowded/long names, all refusal reasons, interruption/back controls, motion, free camera, tooltip behavior and input. No user acceptance is implied.

Independent critic contact_shop_critic confirmed compact known/unknown summaries, distinguishable hover/selection, legible refusal, fixed HUD placement and corrected glyph/range/single-ship fixtures; selected1440p introduced no observed clipping. Critique found ambiguous energy units, mixed journey balances, an unlabelled departure-centered range and weak star-to-system continuity. Follow-up renders explicitly label the separate local journey, energy available/after departure and departure reach; the intermediate star is now anchored at the former galaxy target with a collapsed name header. Those follow-up corrections rendered successfully but have not received another independent visual verdict. Flat panel materials and actual transition motion remain unresolved; no complete family coverage is awarded.

## Delivery status

### Populated surface study, 24 September

Source: artifacts/references/spore/video/surface-1805-v3.png, paused at 1805.490461 seconds; contextual ecology panel, populated specimen tray, beam and life silhouettes. Current comparison: artifacts/scout_surface_95.png is a dated fixture, not a new build capture. Proposed: artifacts/field-instruments-review/01-surface-populated-v2.png and 01-surface-populated-v3.png. Prompts and input roles are preserved in FIELD_INSTRUMENTS_MOCK_PROMPTS.md.

Independent critic contact_shop_critic found v2's right assembly approximately 920×320 at normalized 1080p versus its 620×230 prompt target; chart also too large. V3 reduces the right assembly to approximately 660×247, still slightly oversized; chart including tabs remains about 290×220 versus 190×170 requested. Approximate world occupancy now exceeds 80%. Its tooltip no longer covers the scanner and points clearly to the energy pack. Those specific corrections work; neither image is user-accepted.

Selection remains incoherent: scanner has mustard upper and green lower corners, while the hovered energy cell has mustard selection ticks. Foreground blur persists. Actual pack effect is 50, not the illustrated 40. Five tabs and twelve mixed slots are an illustrative capacity fixture, not the actual four categories and 18-item page. Asset feasibility, geography and other states remain unverified. Neither image proves responsive layout, immediate tooltip timing or a live action.

Required state specification before implementation: one persistent equipped-tool treatment; separate hover/focus/pressed/disabled states; tooltip anchored to the actual hovered item without covering adjacent slots; real inventory packs under Inventory; actual category/page capacity; condition panel distinct from local map; immediate resource count/gauge changes on validated use; zero-count and cooldown refusals. Keep candidate evidence separate from runtime proof. No new complete-family count is awarded.

### Deterministic inventory state study

The isolated tests/review_field_inventory.gd prototype now produces seven states at 1920×1080 and 2560×1440 under artifacts/field-instruments-review/states. It uses the real EncounterState pack commands and real catalog descriptions over a generated static landscape. No game scene, save or export was changed. Palette browsing, scanner persistence, chart geometry and hover/focus input are fixtures; this is not a playable HUD implementation.

| State stem | Visible contract | Evidence limit |
|---|---|---|
| inventory-ready | Energy 36, two packs, actual 50-energy effect; white hover distinct from amber equipped scanner | Hover assigned by fixture, not native pointer timing |
| inventory-used | Actual button-command call gives energy 86, one pack, eight-second cooldown | No audiovisual or animation timing review |
| inventory-empty | Zero packs; visible reason; rejected command preserves energy 36 | Full cargo/specimen inventory not covered |
| inventory-full | Full energy; rejected command preserves two packs | No dock/recharge coverage implied |
| inventory-repair | Real repair description and owned count | Inspection only, no repair-use proof |
| inventory-keyboard | Strong distinct focus; Enter / Space copy | Focus assigned by fixture, not keyboard navigation proof |
| inventory-equipped | Named scanner tooltip with real reach | Equipped scanner is a fixture, not validated runtime persistence |

Independent contact_shop_critic inspected all six initial 1920 states and several 2560 counterparts, then verified corrected ready/used/empty/keyboard/equipped at 1920 and ready at 2560. The misleading tooltip triangle was removed; fixture cursor, focus text/contrast, communications inset and named scanner context passed that bounded check. Resource values and refusal logic stayed legible. Other 1440p images were generated but not all independently inspected.

Art gates remain: small intricate supply portraits, inconsistent category/scanner/consumable vocabulary, flat ivory material treatment, schematic chart and static concept world. Fixed tooltip positioning is remote from the scanner. Three consumables do not demonstrate 18-slot capacity, working category changes, the full possessions view or its complete state set. User acceptance remains open; no complete-family percentage changes.

Reproduce locally: `.tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/review_field_inventory.gd --rendering-method gl_compatibility`. This requires the locally preserved background and supply atlas identified in FIELD_INSTRUMENTS_MOCK_PROMPTS.md. Images remain ignored local artifacts; tracked code/prompts do not constitute an off-device image backup.

### Base candidates and remaining gates

- Generated candidates: `artifacts/field-instruments-review/01-surface-v1.png`, `03-orbit-v1.png`, `04-system-v1.png`, `05-galaxy-local-v1.png` `23-motion-storyboard-v1.png` and `10-contact-v2.png` (window/choices endorsed; face and dialogue rejected). `10-contact-v3-face.png` is an unapproved face experiment with the same obsolete dialogue.
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
| N04 | Personal combat (surface/orbit) | Enemy selection/health, orbital pulse threat, telegraph, impact, shield, damage direction, retreat/defeat | 02 + combat state sheet |
| N05 | Orbital flight | Planet approach/moving destination/final braking, ascent/descent cancellation, outbound fade/scene swap/arrival, service tender, geographic marker attachment; no terrain chart | 03 |
| N06 | System navigation | Whole system, selected destination, unavailable destination, travel in progress | 04 + navigation state sheet |
| N07 | Galaxy navigation | Local reach, overview, below-plane orbit, fog states, unaffordable/out-of-range/embargo travel | 05/06 + navigation state sheet |
| N08 | Planet atlas | Geography/survey, resources, settlements, life, hazards, unsurveyed data | 07 + atlas layer sheet |
| C01 | Communications | Incoming transmission, first/repeat contact, empty/multiple roster, remote/docked access, war/embargo refusals, proposed/active/withdrawn agreements, one-time chart exchange, fleet, conflict | 10 + communication state sheet |
| P01 | Possessions | Onboard cargo, surface store, specimens, energy/repair supplies, item use, full/empty storage | 08 + inventory state sheet |
| P02 | Ship systems | Installed modules, sockets, selected component, comparison, locked/absent equipment | 09 |
| D01 | Dock market | Buy/sell, quantity, total, stock/demand, affordability, capacity, transaction result | 11 + transaction state sheet |
| D02 | Dock upgrades | Equipment, hull, reactor, support; badge eligibility, purchase price, already owned | 12 + upgrade state sheet |
| D03 | Dock supplies | Energy/repair consumables, paid service, free home recharge, insufficient Marks | Dock service state sheet |
| D04 | Dock warehouse | Local store, ship transfer, reserves, capacity limits | 15 + warehouse state sheet |
| D05 | Dock fleet | Recruit/service escorts, unavailable berth/insufficient stock | 17 + fleet state sheet |
| D06 | Existing climate | Current condition/project/complete state only; expansion deferred | 19 + climate state sheet |
| E01 | Orbital signals | Offer, commitment, scan, decision, resolution; wreck salvage approach/cancel/reward | 18 + signal sequence sheet |
| E02 | Colony defense | Threat notification, defender condition, ammunition and response | 17 + defense sheet |
| E03 | Colony terms | Surrender, capture, ruins, consequences and commitment | 18 + terms sheet |
| L01 | Colony administration | Colony selection, construction stages, producing colony, shortage, storage | 15 + colony state sheet |
| L02 | Freight | Configure route, source reserve, destination demand, active, paused, blocked, recall | 16 + freight state sheet |
| R01 | Recognition | Badge case, selected badge/tier, locked unlock, earned reward notification | 13 + reward sheet |
| R02 | Chronicle | Timeline/filters, causal references, pagination boundaries, empty filter; selected-event panel explicitly proposed | 14 |
| B01 | Existing biosphere | Ecosystem inspection, missing slot, viable state, existing climate link | 19; no new ecology-led opening |
| A01 | Title / scenarios | Continue/new voyage, trial/saved expedition/urban/sandbox, available/missing save, replacement warning; Sol marked planned | 21 + application state sheet |
| A02 | Escape | Resume, save/load, settings, return; save success/failure, missing/corrupt/legacy saves, no-campaign fallback and overwrite confirmation | 20 + save/load sheet |
| A03 | Settings | Audio sliders/mute, controls and arrows/numpad, reduced motion | 20 + settings sheet |
| A04 | Sandbox | Separate save identity, permitted toggles, reset/cheat feedback | 21 + sandbox sheet |
| U01 | Retained city | Build view, overview, demand, ledger, services, overlays, advisor, repair/sponsorship/arrears | 22 + retained city sheet |
| U02 | Retained strategy | Legacy galaxy, planet, empire diplomacy, imports/exports, specialization, discovery decisions, followed/released travel camera, existing terraform | Retained/deferred strategy sheet; mark superseded navigation clearly |
| X01 | Shared interactions | Hover/focus/pressed/disabled, long names, populated palette, inaccessible control reasons | Cross-screen state sheet |
| X02 | Interface motion | Boarding, skip, reduced motion, tray open/close, communicator reveal, reward | 23 + implemented motion prototype later |

## Review requirements

For every row: link current implementation evidence, candidate image(s), source timestamp/manual page where applicable, observed discrepancies, and acceptance status. Shared components may be reused, but the required state must actually be shown. Original or legacy-only screens may have no Spore equivalent; say so rather than inventing one.

Check 1920×1080 and larger layouts, pointer hit areas, keyboard focus, named tooltips, short/long item names and full inventories. Test actual scaling in implementation; raster mocks do not prove responsive layout. Full-screen world views must remain visually dominant.

## Motion rules

Initial boarding may use roughly 700 ms of visual assembly: short lateral housing travel, a catch settling, tool-tray unfolding, communicator shutters. Input must be usable immediately; skip snaps to the settled state. Reopening ordinary panels should take roughly 120–180 ms, be interruptible/reversible, and never steal aim/focus. Reduced motion uses an immediate state change or a brief fade, without travel, bounce, shake or gauge sweeps. Those numbers are initial targets for playtesting, not measured finished behavior. Author sound separately: soft mechanism/catch/relay cues at low level, no toy keyboard bounce. Preserve the real hull/energy values throughout.
