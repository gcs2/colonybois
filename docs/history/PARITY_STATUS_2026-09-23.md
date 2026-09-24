# Spore Space Stage parity check-in — 23 September 2026

> Historical context or unselected alternative; not current instructions, canon or work order. [Documentation map](../README.md).

**Preliminary research snapshot, not the authoritative task board.** Category ownership, completeness and forecast calibration remain unfinished. The user prefers check-ins derived from TASK_BOARD.md. Preserve these measurements and estimates as dated working material; do not treat them as accepted scope or a validated schedule. See [goal and check-in contract](../delivery/GOAL_AND_CHECKINS.md).

Audited code checkpoint: `6451ed6d5da9f259740d10a88ab5a86baf1dac3b`. Current playable build: `20260923-123429`. This is a dated snapshot; adding this report will itself change the repository's file/commit counts.

**Estimated functional pre-enrichment parity: 15–20%. Requested polished-game readiness: approximately 5–10%.** These are engineering judgments, not measured fractions of an exhaustively enumerated retail feature list. The individual tool/upgrade/event audit is still incomplete; uncertainty is material. Code volume and passing tests are not completion or visual approval.

We have two separate playable prototypes: the personal Morrow flight encounter and the strategic colony/galaxy simulation. Ship, cargo, time and saves are not unified. That integration is the main blocker to a complete Space Stage session.

## Scoring method and scope

0 means no usable implementation; 10–25 means foundations or an isolated slice; around 50 means substantial mechanics work but incomplete family/integration; 75 would mean broad end-to-end coverage; 100 requires intended baseline behavior, persistence, verification and accepted interaction quality. Approximate scores use five-point increments. A working isolated prototype receives partial credit only.

Weights below are relative estimates of remaining production importance/effort, not percentages. They sum to 106; the weighted arithmetic result is 17.4%, deliberately reported as a 15–20% range rather than false precision. Presentation readiness is a separate rough judgment, not another calculated feature score.

The target is base Space Stage gameplay with the user's explicit adaptations: original IP/art, no compulsory gopher grind, Marks, inventory pack use, and Escape utilities. Baseline equipment/upgrade variants and enough content to exercise each mechanic are included. Additional organism/commodity corpus, richer synergies, ancestor/Vanguard campaign, human Sol, deep SimCity simulation and first-person fleet combat are enrichment/additional ambitions, not extra credit toward baseline parity. Galactic Adventures and multiplayer are excluded. Ship/building editors are recorded as missing; the full creature creator remains deferred and would require a separate scope/estimate before claiming wider creation parity.

## Category audit

| Category | Estimated complete | Weight | Actual evidence / gap |
| --- | ---: | ---: | --- |
| Personal ship controls and targeting | 40% | 6 | Mouse orders, arrows/numpad, selection/cancellation; remapping and native feel incomplete. |
| System/galaxy travel, range, fog and endgame | 15% | 7 | 12-node strategy map; personal flight is disconnected; wormholes/core progression missing. |
| Planet generation and visitable surfaces | 20% | 6 | Three globe archetypes; only Morrow has personal flight and one authored landing region. |
| Tool palettes, inventory and cargo interface | 35% | 5 | Working categories, 18-slot pages, hover help and packs; tiny actual catalog, no unified hold. |
| Energy, hull, repair and ship services | 55% | 4 | Finite energy, packs, stock, home recharge, damage and tow; foreign services/travel not integrated. |
| Weapons, upgrades and combat | 15% | 6 | One weapon and one hostile encounter; no broad weapon/upgrade catalog or full combat loop. |
| Allied fleet recruitment and commands | 0% | 3 | No working allied squadron recruitment, orders or persistent losses. |
| Empire warfare, raids, defenses and conquest | 0% | 6 | Relations exist; no functioning interstellar war/conquest simulation. |
| Alien contact, diplomacy and philosophies | 20% | 6 | Three rule-based factions and a few treaties; expressive contact and most actions missing. |
| Trade, markets and interplanetary economy | 20% | 5 | Finite local sale and strategic routes; no shared ship cargo/market loop. |
| Colonization, city layout and production | 30% | 5 | Aggregate city and founding mechanics exist in the strategy prototype; flight integration missing. |
| Terraforming and habitability | 15% | 4 | Strategic climate projects and one local thermal tool; complete planet/tool/ecology loop absent. |
| Collection, abduction, deployment and ecosystems | 15% | 4 | Two lifeforms and simple samples/deployment; full ecological tiers/population interactions missing. |
| Terrain sculpting, coloring and decoration | 0% | 2 | No working manipulation tool families. |
| Uplift and developing civilizations | 0% | 2 | No monolith-equivalent or civilization development simulation. |
| Extreme tools and philosophy powers | 0% | 2 | No planet destruction or broader special-power families. |
| Missions, crises and event variety | 5% | 3 | One optional salvage/danger encounter; no full event/contract/crisis system. |
| Artifacts and rare collections | 10% | 2 | Six strategic discoveries; no integrated physical artifact collection loop. |
| Badges, ranks and purchasable unlocks | 5% | 5 | Three simple strategic ranks; no shared badge system or badge-gated shops. |
| History and chronicle | 20% | 2 | Separate local and strategic logs; no unified durable event timeline. |
| Sandbox and cheats | 15% | 2 | Strategic cheats exist; no shared flight sandbox or unified scenario state. |
| Ship/building editors and creation support | 0% | 3 | No editors. Full creature creator remains explicitly deferred by user. |
| Tutorial and contextual guidance | 15% | 3 | Prompts, controls and local guidance; coherent end-to-end teaching loop missing. |
| HUD and interface parity | 15% | 4 | Several interaction corrections work; visual design rejected, major screens still absent. |
| Art, animation, effects and audio | 10% | 4 | Asset/effect/mixer infrastructure; art and audio quality rejected or unapproved, voice missing. |
| Persistence, integration and performance | 25% | 5 | Tested local snapshots and bounded profiles; no unified game-state/session validation. |

## Codebase measurements

Measured from Git-tracked files at the audited commit; physical lines include comments and blank lines. Runtimes, builds, saves, ignored generated previews and Git object storage are excluded. Assets are files, not approved finished game content.

| Measure | Value |
| --- | ---: |
| Tracked files | 312 |
| Runtime GDScript | 6,502 lines / 27 files |
| Automated test GDScript | 1,789 lines / 18 scripts |
| Review / fixture / profile GDScript | 339 lines / 8 scripts |
| All GDScript, including tools/tests | 8,837 lines / 55 files |
| Build/authoring/tool scripts | 443 lines / 8 files; overlaps all-GDScript count |
| Design documents | 40 Markdown files / 2,475 lines |
| Tracked footprint | 21.74 MiB |
| Candidate 3D assets | 4 GLBs |
| Other assets | 31 SVGs, 6 PNGs, 20 WAVs, 5 shaders |
| Godot scene files | 2; most scenes/UI are assembled by code |
| JSON definitions/specifications | 12 files |
| Git commits | 34; first checkpoint 22 September 2026 |
| Verification | 537 assertions plus UI checks; latest exported-pack smoke passed |

Actual playable breadth: 1 personal-flight planet and 1 surface site; 12 strategic systems with 24 planet records; 3 environment archetypes; 3 strategic factions; 4 starting field tools; 1 energy weapon; 1 acquired defense; 1 hostile ship encounter; 13 building/infrastructure definitions; 6 strategic discoveries. Two live service locations are both on the homeworld. These counts must not be presented as 24 personally visitable planets or a complete interstellar market.

The largest runtime files are `encounter.gd` (1,761 lines) and `main.gd` (1,260). Together they contain 46.5% of runtime GDScript. This is a maintenance/integration risk: extract coherent responsibilities while connecting state, rather than conducting a speculative engine rewrite.

## Forecast before enrichment

Low-confidence planning ranges, not delivery promises. Assume one sustained AI-assisted production lane delivering about 35 effective hours/week, regular user playtests, stable baseline scope, and real art/audio production and review alongside code. Tool runtime is not interchangeable with those effective hours. We have about two calendar days of repository history and no completed end-to-end milestone throughput from which to make a reliable empirical forecast.

| Outcome | Remaining planning effort | Elapsed range from now | Conditional calendar window |
| --- | --- | --- | --- |
| Connected three-world vertical slice | 80–160 focused hours | Roughly 2–5 weeks | October 2026 |
| Mechanically broad parity alpha, still with placeholder/rejected presentation | 600–1,200 focused hours | Roughly 4–8 months | January–May 2027 |
| Reviewed, polished pre-enrichment baseline | 1,400–2,800 focused hours total | Roughly 9–18 months | June 2027–March 2028 |

These effort bands are cumulative from the audited state, not amounts to add together. They are provisional engineering estimates, not historical measurements or externally benchmarked rates. At 15 effective hours/week, the same total workload is roughly 22–43 months. Faster code generation alone does not establish faster art acceptance, balancing or testing. Full creature-creation/procedural animation parity, or significant new scope, is not priced into these dates.

The requested AAA-quality bar has not been demonstrated. The polished range is a planning allowance toward a coherent small production, not a guarantee that a date or number of hours will produce AAA art. Repeated reskins without accepted direction can exhaust that allowance without improving the result.

## Next evidence that should change the estimate

One persistent ship leaves Morrow, visits two other worlds, collects cargo, meets a faction, compares actual prices, buys a useful unlocked upgrade, handles a resource shortage or hostile encounter, then saves/reloads without losing state. This is a connected-loop milestone, not full parity. Measure how long that takes and how much survives player review; revise the remaining forecast then. Stop treating additional HUD variants or catalog names as substitutes for this integration.

Evidence sources: `scripts/simulation.gd`, `scripts/encounter_state.gd`, `scripts/encounter.gd`, `scripts/flight_hud.gd`, `scripts/planet_generator.gd`, `data/catalog.json`, `data/equipment.json`, `data/energy_services.json`, `tools/Test.ps1`, and the detailed requirement ledgers in SPACE_STAGE_TARGET.md / SPORE_BADGE_PARITY.md. Older content documents contain historical counts; this snapshot uses current code and latest validation.
