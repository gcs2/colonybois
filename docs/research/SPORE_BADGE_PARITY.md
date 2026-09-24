# Spore badges, achievements and shop unlocks

> Reference research; observations, proposals and evidence gaps are not implementation status. [Documentation map](../README.md).

23 September 2026. Research and implementation target, **not implemented parity**. Wiki pages were often accessible only through search-index excerpts; the badge-case screenshot was inspected in the browser. Conflicting wiki values are listed below rather than silently treated as verified game data.

## Four connected systems

1. **Badges:** leveled accomplishments within the Space Stage. Most families have five levels, with one-time exceptions. [Space Stage](https://spore.fandom.com/wiki/Space_Stage).
2. **Master ranks:** badge points feed ten promotions, at 5, 15, 30, 50, 75, 105, 140, 180, 225 and 275. Promotions also relate to allied fleet capacity; this is not just a title counter. [Master Badge](https://spore.fandom.com/wiki/Master_Badge).
3. **Shop eligibility:** an accomplishment can unlock a tool for purchase. The price, prior upgrade and seller still matter. Many tools have alternative badge paths. [Tools reference](https://strategywiki.org/wiki/Spore/Tools).
4. **Achievements:** separate broader feats, including playtime, combat, civilization development, exploration and ranks. They should not be confused with every tier of an in-run badge. [Space Stage achievements](https://spore.fandom.com/wiki/Space_stage_achievements).

The [observed collection screen](https://www.gamepressure.com/spore/gfx/word/893447359.jpg) gives badges medallions, stars, progress strips, unearned silhouettes, rank filters and a hovered next-tier explanation. A newly unlocked capability needs a route from this screen to its real shop entry, not just a congratulatory toast.

## Family inventory

The [Badge reference](https://spore.fandom.com/wiki/Badge) enumerates these base Space Stage families. Inventory only; names are reference terminology, not approved production names. Cut entries and Galactic Adventures additions are not silently included.

| Activity | Families to account for |
| --- | --- |
| Defense / conflict | Body Guard, Cleaner, Conqueror, Warmonger |
| Development / economy | Colonist, Empire, Economist, Golden Touch, Merchant, Trader, Jack of All Trades |
| Exploration / collection | Explorer, Frequent Flyer, Traveler, Collector, Sightseer, Wonderland Wanderer |
| Ecology / manipulation | Eco Hero, Zoologist, Terra-Wrangler, Planet Artiste, Brain Surgeon |
| Diplomacy / identity | Diplomat, Split Personality |
| Introduction / contracts | Captain's Badge, Gopher, Missionista |
| Exceptional outcomes | Joker, Badge Outta Heck, Dance With the Devil |

Every family needs an explicit retained, adapted, deferred or excluded decision, a counting rule and its unlock edges. Family count alone is not tool or achievement parity. Exact per-tool reward mappings remain an audit task.

## Source-reported examples to preserve structurally

| Family | Reported five thresholds | Why it matters |
| --- | --- | --- |
| [Collector](https://spore.fandom.com/wiki/Collector) | 3 / 8 / 20 / 50 / 100 distinct artifacts | Collection gives cargo upgrades at early tiers; duplicates do not substitute for discoveries |
| [Merchant](https://spore.fandom.com/wiki/Merchant) | 0.5 / 2 / 4 / 7 / 15 million in sales | Another path to cargo upgrades; trading and exploring both support expedition capacity |
| [Diplomat](https://spore.fandom.com/wiki/Diplomat_%28badge%29) | 1 / 2 / 5 / 10 / 20 alliances | Relationships open further social capabilities |
| [Colonist](https://spore.fandom.com/wiki/Colonist) | 5 / 20 / 50 / 100 / 200 buildings | Peaceful development unlocks ship improvements as well as colony benefits |
| [Conqueror](https://spore.fandom.com/wiki/Conqueror) | 2 / 5 / 10 / 20 / 50 planets | Combat supplies an alternate improvement path |
| [Explorer](https://spore.fandom.com/wiki/Explorer) | 15 / 50 / 100 / 250 / 500 inspected systems | Discovery links to world manipulation |
| [Terra-Wrangler](https://spore.fandom.com/wiki/Terra-Wrangler) | 2 / 5 / 10 / 20 / 40 T-score improvements | Climate interventions feed stronger manipulation tools |
| [Frequent Flyer](https://spore.fandom.com/wiki/Frequent_Flyer) | 50 / 150 / 400 / 800 / 1500 flights | Range progression exists, but repeated travel is not an engaging requirement by itself |
| [Gopher](https://spore.fandom.com/wiki/Gopher) | 5 / 10 / 20 / 40 / 70 deliveries | An alternate drive route in Spore; explicitly unsuitable as our compulsory progression path |
| [Missionista](https://spore.fandom.com/wiki/Missionista) | 5 / 10 / 18 / 30 / 50 missions | Contract rewards must be retained without requiring repeated delivery errands |

Illustrative unlock expressions:

- Cargo: **Collector tier 1 OR Merchant tier 2** opens the basic hold; higher variants have their own tiers. [Collector](https://spore.fandom.com/wiki/Collector), [Merchant](https://spore.fandom.com/wiki/Merchant).
- Health: **Colonist OR Conqueror** at the corresponding tier, with prior upgrade requirements for later purchases. [Health](https://spore.fandom.com/wiki/Health).
- Drive: **Frequent Flyer OR Gopher**, plus the preceding drive for later levels. Essential reach must have a non-errand path in our adaptation. [Interstellar Drive](https://spore.fandom.com/wiki/Interstellar_Drive).
- Uplift: **Traveler tier 2 OR Zoologist tier 2** for the monolith. This connects encounters or ecology to civilization development. [Monolith](https://spore.fandom.com/wiki/Monolith).

## Adaptation contract: breadth without gopher grind

Keep leveled accomplishment families, alternate unlock paths, rank recognition, a browsable badge case, pinned progress and actual shop purchases. Do not make range, energy reserves or essential infrastructure depend on repeat deliveries. Optional contracts can involve decisions, discoveries or defending a real ally. Their outcomes count once; repeated text and a larger quota do not make a new mission.

Proposed counting rules, subject to playtest: use distinct stable entity IDs for discoveries and durable accomplishments; record each highest achieved environmental tier per world; avoid build-demolish-rebuild farming, circular buy/sell exploits and reheating/recooling the same planet for points. Once earned, recognition remains in history even when territory is lost. A peaceful path must support useful ship progression. Unlock is permission to buy, not free inventory.

Do not import the long reference thresholds blindly into a twelve-system authored sector. Keep source thresholds in reference data and scenario tuning separately. Preserve the breadth and dependency structure while the user reviews pacing. The explicit anti-gopher exception is not permission to remove other baseline activities.

## Implementation sequence and gates

1. Shared authoritative events with event ID, actor, subject, outcome, time and scenario. Saved deduplication prevents double awards after load or view changes.
2. Data-defined counters, levels, point awards, alternative requirements and prerequisite purchases. Do not infer historical deeds absent from legacy saves.
3. Actual shop entries with separate states: unknown, locked, eligible, unaffordable, out of stock, owned. Show the exact missing badge or prerequisite.
4. Badge case, next-tier/reward preview, pinning, brief celebration and chronicle entry. Recognition must not interrupt flight repeatedly for the same event.
5. A played peaceful route and a different combat/diplomacy route to a shared useful upgrade, purchased and then used. Save/load preserves both progress and ownership. Sandbox cheats are explicitly recorded and do not quietly contaminate campaign progression.

Current state: three strategic ranks and separate flight history entries. No unified badge progression or badge-gated shop exists yet. Energy packs in the flight prototype are ordinary stock, not proof of this unlock system.

## Unresolved source contradictions

- The Badge and UI totals differ (134 versus 139); do not use an unexplained total as the acceptance test.
- Frequent Flyer tier-five points differ between its page and Badge Point (10 versus 15).
- Explorer's terrain-tool rewards conflict with individual terrain-tool pages about required tiers.
- Cloaking Device prerequisites differ across indexed pages.
- Drive range/cost figures differ across upgrade and summary pages.

These require a retail/data audit before exact numeric parity. Do not conceal uncertainty behind a generated catalog. The next full inventory must cover every tool/upgrade edge, not merely these examples.
# Implementation update · 23 September 2026

Latest: [Expedition recognition](../systems/EXPEDITION_PROGRESSION.md) expands to ten scenario families and implements cumulative master promotions, pinning, a browsable case, real alternate shop paths and brief award animation. The three-family note below is checkpoint history. Exact retail thresholds/points, the full badge/achievement catalog, late-rank reachability and master-rank fleet effects remain open. The two original supplementary families are not substitutes for unimplemented retail families.

[SHIP_COMMERCE.md](../systems/SHIP_COMMERCE.md) records the integrated Explorer/Merchant pilot; [ORBITAL_ENCOUNTERS.md](../systems/ORBITAL_ENCOUNTERS.md) adds Defender and a purchased emitter. Three families have five scenario-scaled tiers, persisted progress and alternative eligibility for three paid upgrades that change capacity, range and damage. Only three distinct combat encounters exist, so higher Defender tiers are unreachable. Defender neutralizations do not implement reference Body Guard rescues. These are local adaptations, not retail threshold parity. [The progression manifest](../parity/reference_progression.json) now names all thirty working reference badge families, promotions and achievements; complete thresholds, points and unlock edges remain open. Historical implementation notes above predate these checkpoints.
