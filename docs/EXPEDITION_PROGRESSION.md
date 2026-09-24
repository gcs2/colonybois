# Expedition recognition and master ranks

23 September 2026. P01 integrated checkpoint. Eleven implemented families are not the thirty-family reference inventory, and this does not complete progression parity.

## What the player does

Click the rank readout near the treasury, or open Escape → Badges. The case displays eleven five-tier families, unearned stars, earned tiers and progress. Select a family to see its counting rule, next threshold and related shop entries. Pin one family's progress to the HUD. A reward link opens its real shop family with that entry first; prices, location, embargoes, prior upgrades and existing ownership still apply.

Accomplishments produce a short animated award and the existing achievement cue during active flight. Awards do not pause the game. Opening an inspection dismisses the displayed card; pending cards wait. Each badge tier and promotion is recorded in the persistent chronicle. The art and audio remain candidates, not approved production masters.

## Counting and tuning

| Family | Authoritative accomplishment | Five scenario thresholds |
| --- | --- | --- |
| Explorer | Distinct visited systems | 2 / 3 / 5 / 8 / 12 |
| Merchant | Distinct origin/destination/commodity sales | 1 / 3 / 6 / 12 / 24 |
| Defender | Distinct neutralized orbital/surface threats | 1 / 3 / 6 / 10 / 20 |
| Diplomat | Distinct civilization alliances recorded | 1 / 2 / 3 / 5 / 10 |
| Trade Envoy | Distinct civilization trade agreements recorded | 1 / 2 / 3 / 5 / 10 |
| Colonist | New landing hubs completed | 1 / 2 / 5 / 10 / 20 |
| Cartographer | Distinct completed orbital surveys | 1 / 3 / 6 / 12 / 24 |
| Naturalist | Distinct catalogued species | 3 / 6 / 9 / 12 / 18 |
| Zoologist | New complete ecosystem tiers recorded | 1 / 2 / 3 / 4 / 6 |
| Captain | Distinct successful optional orbital encounters | 1 / 3 / 6 / 12 / 20 |
| Terra-Wrangler | Per-world highest climate improvement above native tier | 1 / 2 / 4 / 8 / 16 |

An alliance cancellation/re-signing cannot increment Diplomat again. Repeated scanning, returning to a cleared encounter, rebuilding the same ecological tier and heating/cooling back to an old climate maximum cannot farm recognition. Colony kits under construction do not count. Climate recognition occurs at actual pulse completion, including off-screen worlds, and never at transient intermediate values. Once earned, badge tiers remain even if a site, relationship or ecosystem is subsequently lost.

Each newly earned tier awards **2 / 4 / 6 / 8 / 10 points**, cumulatively. These are explicit uniform scenario awards, not verified per-badge retail points. Master promotion thresholds use the documented 5, 15, 30, 50, 75, 105, 140, 180, 225 and 275 progression. Late ranks and some high badge tiers remain unreachable with the current content caps. Do not inflate scores or simulate accomplishments to conceal those gaps.

Cartographer and Naturalist are original supplementary recognition; neither replaces the reference rare-artifact Collector family. Colonist counts completed hubs here rather than retail building placements. Existing Explorer, Merchant and Defender adaptations remain explicit. Trade Envoy covers distinct trade treaties, not economic takeover. Zoologist and Terra-Wrangler are connected pilots; broader disasters, eradication, uplift and civilization outcomes remain open.

## Useful alternate unlock paths

Existing eligibility remains available. New alternatives are Naturalist 1 for the expanded hold; Diplomat 1 or master rank 3 for the extended drive; Colonist 1/2 for hull I/II; Trade Envoy 1 for reactor I; Cartographer 2 for reactor II; and Terra-Wrangler 1 or Zoologist 1 for each of the four reusable climate tools. Unlocking does not waive price, prior installation or docking. Nothing refills hull or energy on promotion.

The allied fleet still uses its documented three-slot badge bridge. Replacing that with reference master-rank capacity and supplying more allies remains F01/P01 work; this checkpoint does not quietly claim that effect is implemented. The broader achievement system, full retail unlock graph, special badges and all thirty reference families remain open.

## Persistence and verification

Snapshot v14 adds saved climate maxima, pinned family and pending notices. Existing earned tiers stay in the authoritative commerce state. New awards derive from real durable evidence, not UI navigation. Version 13 and earlier saves preserve purchased equipment; missing new families initialize to zero and may subsequently earn recognition from surviving evidence. Lost past climate maxima are not invented during migration. Invalid notice tiers, duplicate notices, unknown pins, missing current-version badge fields and malformed climate records reject the load atomically.

`tests/test_progression.gd` covers 51 assertions, including actual scans, paid hold purchase, survey completion, agreements, duplicate avoidance, off-screen climate completion, rank thresholds, migration, malformed snapshots, case pinning, actual shop navigation, panel bounds and animation. Synthetic fixtures isolate some counter boundaries; the existing colony/biosphere suites cover construction and release mechanics. `tests/review_progression.gd` captures case, reward and notice states at 1080p and 1440p. These checks do not establish native usability, balance, user-approved artwork or full-session enjoyment.

## Reference provenance

The [earlier badge audit](SPORE_BADGE_PARITY.md) and [reference manifest](parity/reference_progression.json) remain the scope record. A fresh indexed [Master Badge](https://spore.fandom.com/wiki/Master_Badge) result confirmed ten promotion thresholds and fleet links; direct page retrieval was blocked. [Badge Point](https://spore.fandom.com/wiki/Badge_Point) and [StrategyWiki's badge listing](https://strategywiki.org/wiki/Spore/Badges) also blocked direct retrieval. Per-family points, disputed thresholds and exhaustive unlock edges remain unverified; the implementation's scenario tuning above is separate from those source claims.

The optional-signal checkpoint adds Captain as an original scenario family, with a paid reactor eligibility path at tier 1. It is not the reference one-tier Captain's Badge, and does not close that reference entry. Only two encounters currently exist, so tiers 2–5 remain unreachable. See [SPACE_SIGNAL_ENCOUNTERS.md](SPACE_SIGNAL_ENCOUNTERS.md).
