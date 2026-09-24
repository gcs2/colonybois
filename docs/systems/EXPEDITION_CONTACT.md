# Personal contact and persistent diplomatic consequences

## Compact grid correction (24 September 2026)

The user rejected the wide commodity row with details underneath, preferring the existing compact equipment grid and adjacent details. Trading now follows that layout: three columns of 84x92 item tiles in a 270px scroll area, beside selected-good information and buy/sell actions. Tiles show buy price per unit; immediate named tooltips explicitly identify unit prices; side totals apply the selected quantity. Merchant, actual transaction rules and selection persistence remain. The earlier wide-layout critic verdict does not constitute user acceptance and is superseded.

Build `20260924-033526`. Independent critic reviewed all 12 corrected captures with no blocking layout/refusal issue. 81 contact checks pass; refreshed native 1080p/1440p fixtures include water/glass four-unit totals, buy/sell, exhausted stock and insufficient funds. This is the requested layout correction, not final user art approval.


## Commodity browsing and immediate hover (24 September 2026)

Commodity trading now uses a three-column pictorial selector, preserving the local representative. Selected goods show description, aboard/stock/demand counts and explicitly labeled buy/sell transaction totals. Quantity selection stays 1/4/8. Buy/sell commands revalidate current funds, cargo, stock and access; browsing never changes the campaign. Selection survives transactions. Empty cargo, stock exhaustion and insufficient funds have visible refusal copy. Home reserve export remains separate. No new commodity or crafting mechanics were added.

Contact presentation: 81 checks; commerce: 49 checks pass. Added actual UI selection, buy, sell, selection persistence and stale-funds refusal assertions. Native fixtures captured all three goods, four-unit totals, purchased/sold and unaffordable states at 1080p and 1440p. The glass purchase also exhausted local stock. Full-cargo and demand-exhaustion visual coverage remain open. Independent critique requested explicit total labels and larger imagery; both corrected. Final user acceptance remains open.

Actual hover check (`tests/review_immediate_tooltips.gd`): synthetic pointer over a real contact action produced its visible native tooltip within three frames (51.218 ms observed), with zero configured delay and no click. Screenshot: artifacts/immediate-contact-tooltip.png. This is synthetic native evidence, not human timing/playability acceptance. Commodity captures: artifacts/contact-shop-market-1920.png, market-water-four-1920.png, market-glass-four-1920.png, market-purchased-1920.png, market-sold-1920.png, market-unaffordable-1920.png and 2560 counterparts.


## Field Instruments correction (24 September 2026)

Build `20260924-032013` replaces the rejected blue communicator with matte ivory housing, charcoal chambers, Barlow typography and four painted contact actions. Equipment uses a three-column pictorial grid with prices, tier markers, flavor/effects and fixed purchase/refusal controls. Actor continuity and validated transactions remain. Colony kits now cost 300 Marks only; alternate crafting remains future work. Cut Mark is provisional. First/repeat and relationship-sensitive greetings persist acknowledgment. Native Control tooltip delay is zero following the user's EU4 reference; live pointer timing remains to review.

Verification: contact presentation 76, diplomacy 72, colonies 49, commerce 49 and support 61 checks pass (307 total). Independent critic reviewed locked, available and purchased captures at 1080p/1440p: selection and fixed refusal visible, no major checkpoint blocker. Available/purchased images use an explicitly funded Merchant-tier fixture and actual UI transaction: 1,000 to 880 Marks, cargo capacity 8 to 16. Stills do not establish timing, audio, fun or final art approval. Flavor scroll boundary remains a refinement.

Evidence: local artifacts/contact-first-1920.png, contact-shop-upgrades-1920.png, contact-shop-available-1920.png and contact-shop-purchased-1920.png, with 2560 counterparts. Artwork prompts/provenance: assets/ui/COMMUNICATOR_ASSETS.md. Market and supply layouts, surrounding HUD, animated performance and user acceptance remain open. Earlier checkpoints below are historical.


## Compact equipment catalogue — 24 September 2026

Build `20260924-023446` replaces expanded upgrade paragraphs with a scrollable equipment list and one selected-item detail/purchase area. Selection persists through purchase refreshes and badge links; prices, badge requirements, installed state and refusal reasons use actual commerce data. The portrait and return controls remain visible. This does not add new content or reopen character modeling.

Verification: contact presentation 70, commerce 49 and ship support 61 checks pass, including browsing without campaign mutation, stale-funds refusal, real upgrade installation/payment and retained selection. Updated 1080p/1440p colony-kit captures received independent static critique with no blocking clipping or legibility findings. Unselected entries still require selection or hover to compare price/availability; exhaustive visual review of every item and native input acceptance remain open. Earlier checkpoint evidence below is historical.

## Local shop continuity and concept portrait — 24 September 2026

Communications now names the real local dock and distinguishes approach, in-range services and unavailable/embargoed ports. Clicking revalidates access; remote conversations do not teleport the ship or grant market rights. Providerless generated worlds safely refuse even direct recharge queries. Foreign full reactors say “Energy full,” rather than incorrectly claiming homeworld-free service because the quote was zero.

At an encountered alien's local dock, the representative persists between communications and all shop drawers. The character/return controls stay beside an independently scrolling goods column. Selecting a different remote faction never turns the local shop into that faction's shop. Purchases still validate stock, cargo, price and access; the representative's response state changes only on a command result. Selected shop/quantity tabs have a distinct highlight; kit and repair eligibility are visible near the offer.

The user explicitly authorized using existing generated art as portraits. Tavi now uses the [isolated concept-derived 2D portrait](../../assets/aliens/tavi-portrait-v1.md), cleaned from the endorsed left merchant with built-in imagegen. No procedural mouth/eyes or bobbing are overlaid on that static image. Other factions retain temporary vectors. This is not 3D modeling, a rig, voice or authored acting; final portrait acceptance remains open.

Verification: 38 contact/commerce presentation checks; existing commerce 49, diplomacy 45, energy 21, full-screen navigation 67, ship support 61 and HUD 50 checks pass. Actual Market/Supplies/Upgrades captures at 1920×1080 and 2560×1440 are under `artifacts/contact-shop-*.png`. The independent critic compared these with the endorsed contact composition and sampled Spore shop frame: selected state, supply requirements, fixed actor/exit and isolated portrait fit pass this bounded review. An initial alleged horizontal clip was withdrawn after width measurements; longer content requires vertical scrolling. The long upgrades inspector, pictorial commodity browsing, first/repeat greetings, final Field Instruments materials and native motion/audio/playability remain open. Build `20260924-022214` exported and passed isolated pack startup smoke.

## Contact presentation lifecycle — 24 September 2026

The same representative now survives changes between Agreements, Exchange, Fleet and Conflict drawers, preserving its presentation clock and any response already in progress. Acceptance/refusal starts once after a diplomatic command result. Refreshing a drawer cannot replay it. Closing the panel, leaving communications or choosing another faction clears the old reply and releases that actor; reopening starts with a listening representative.

Earlier verification: 16 scene-level checks covered the first contact-only lifecycle fix; the newer checkpoint above extends continuity into local shops. First/repeat greetings, authored gestures, final layout/audio and native playability review remain open.

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. Integrated pilot for D01, I01, P01 and the personal trade loop. This does not complete Spore diplomacy, alien art or the historical timeline.

## Player interaction

Fly into an inhabited system to establish contact. The Veyr Directorate, Orin Consortium and Thalen Commune occupy their existing sector territories. First contact persists, highlights communications and produces an arrival notification. Open **Y / Communicate** to select an encountered representative. Unknown civilizations are not listed. Known contacts can be reached from other worlds; jump travel suspends negotiation.

The contact panel separates species, government and philosophy; it shows the faction's current relationship and latest reason. Agreements and Exchange have contextual choices, disabled-state explanations and hover details. Negotiation and inspection pause the campaign, while portrait motion continues independently. Local ship services remain accessible without needing alien contact.

## Agreements with actual effects

- **Trade:** requires nonnegative relations and no embargo. Foreign buying prices improve by 10%, selling prices by 10%, rounded to whole Marks. The buy/sell spread remains positive. Prices change in the actual validated transaction; local stock/demand do not refill. No benefit applies outside the partner's territory.
- **Non-aggression:** requires 15 relations. In this pilot it grants transit through the partner's territory even during a commercial embargo. Their markets remain closed. This is a specific access rule, not implemented protection from enemy fleets.
- **Alliance:** requires 40 relations. The ally supplies navigation charts within two links of its territory, opening routes through charted but unvisited systems. Those charts do not award visits, reveal planetary survey layers or establish contact with other civilizations. Military assistance is unimplemented. Withdrawing an alliance does not erase knowledge already learned.
- **Withdrawal:** removes the selected agreement and costs 20 relations. Price/passage benefits end immediately. An ensuing embargo can cancel an in-progress route unless a surviving transit agreement permits it. Charts already shared cannot be unlearned.

Each newly signed agreement gives the existing +5 trust. Re-signing an active agreement fails without changing state. These are explicit local pilot rules, not a claim of exact retail Spore formulas.

## Choices beyond treaties

A one-time goodwill grant costs 120 Marks and adds 15 trust per nation. It cannot be repeated to farm relations. A completed orbital survey can be licensed to one nation for 25 Marks and 8 trust; the exclusive recipient is saved and another nation cannot buy the same findings. A nation will not buy its own territorial charts. Survey energy/time remains real. This offers exploration-based goodwill alongside investment, without a delivery assignment.

Reconciliation costs 80 Marks and restores a negative relationship to zero, reopening trade. Existing public grants and chart licenses remain spent. Gifts, reconciliation and chart returns all use the same campaign treasury as trade and colonies.

## Original representatives and art limits

`art/specs/contact_representatives_v1.json` defines three original candidate body plans: Oolun delegate Tavi Rill, Veyri commissioner Orr Vask, and Velith envoy Nema of Reeds. Editable SVG busts live under `assets/aliens/`; `alien_portrait.gd` supplies slow breathing, gaze, blinks and short response mouth/eye poses. Dialogue is authored per representative. The game does not use runtime AI to choose responses.

These are unapproved vector portrait candidates with one pose each, not final 3D rigs, voiced performances or phoneme lip-sync. Their names/species remain candidate content. 1080p engine renders establish placement/readability only; human art/fun review remains open. Existing ship, world and interface artwork and audio still need the previously requested quality work.

## Chronicle and persistence

Snapshot v4 adds a structured chronicle plus one-time grants, chart exclusivity and contact acknowledgements. Each event keeps a stable sequence ID, campaign time, location, category, representative/nation identity snapshot, outcome and earlier cause ID where known. First contact, first arrival, completed surveys, paid equipment, trades, diplomatic choices and observed embargo changes are recorded. Trade references its active pricing agreement; withdrawal references the pact it breaks. Changing a faction's current name does not rewrite its old events.

**Escape → Chronicle** filters diplomacy, trade and exploration, retains the colony ledger summary, and preserves earlier field history under Local. Fifteen entries render per page so a long campaign does not create thousands of controls at once. Version 1–3 campaigns import with an explicit recording-start boundary; missing past decisions are not invented. Failed loads leave the live campaign intact.

The existing strategic log, colony milestones and all field events have not yet been fully unified. Fleet losses, conquest, annihilation, causally linked story decisions and session summaries require their real underlying systems. Automated commodity freight and production-backed remote market replenishment also remain unfinished.

## Verification

The diplomacy regression takes actual home-colony exports to another world, finances contact goodwill from that sale, flies through the frontier to a faction, signs agreements, checks actual preferred-price purchases and new navigation, exercises embargo/transit/withdrawal, licenses a real energy-funded survey, saves/restores and validates the contact controls. It also checks animation cannot advance the paused campaign, historical identity, causal IDs, repeat-action rejection and migration. Native input feel, performance over a full play session and aesthetic approval are separate gates.
