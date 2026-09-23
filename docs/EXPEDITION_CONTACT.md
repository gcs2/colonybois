# Personal contact and persistent diplomatic consequences

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
