# Personal interstellar travel checkpoint

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. Tasks I01, V04, V07 and E01 advance; the complete trade/progression/diplomacy loop and visual-quality gate remain open.

## Playable behavior

In the Morrow expedition, ascend into orbit and press **G**, click the navigation icon with the **Sector chart** tooltip, or zoom out past the orbital limit. Select a revealed star, choose an orbital body, and click **Depart**. The quote shows energy, duration and remaining energy. Inspection pauses the simulation; committing a journey advances it, and Escape opens the pause/save menu during transit.

The authored sector has twelve systems and twenty-four visitable orbital destinations. Names and additional orbital bodies are revealed on arrival in a system; planetary geography still requires each planet's orbital survey. Unknown distant systems cannot be selected through the frontier fog. Journeys follow accessible links through explored intermediate systems. Initial drive range is three links per order, at eight energy and twelve seconds per link. Transfers inside a system take three energy and six seconds. These are initial balance values, not completed progression tuning.

Only three worlds currently support descent:

| World | Landing region | Presentation differences |
| --- | --- | --- |
| Morrow, in Solace | Morrow Basin | Existing temperate encounter |
| Nacre I | Thawline | Frozen terrain profile, ice, pale terrain and fewer ground plants |
| Kestrel I | Glass Basin | Arid ridges, dry basin, warmer sky and sparse ground cover |

Planet overview and orbit use the same seeded recipe and surface-fixed landing coordinates. Arrival rebuilds the viewed world and clears old scene orders; it does not reset the ship. Other destinations explicitly say that surface exploration is unavailable in this build. Their models reject descent too. Surfaces reuse the current creature/prop kit; this is not the promised broad species or material-culture corpus, and not approved final artwork.

## Resource costs and persistence

- One flagship record owns destination, route, remaining transit time and current planet. The old strategic travel command cannot independently move that same ship.
- Launch consumes energy once. Repeated clicks, unavailable routes, insufficient energy, unfinished orbital surveys and active custodian pursuit cannot bypass validation. Leave the defense field before jumping. A border closing during travel returns the ship to its departure orbit without refunding drive energy or revealing the destination.
- Hull, energy, equipment, reserve packs, specimens and their cooldowns travel with the ship. Energy never regenerates passively. Free recharge remains limited to Morrow; other ports charge the displayed local rate from the shared treasury.
- Inactive planets retain their own scans, ecology, surface stock, finite orders, service stock and encounter state. They contain no copied ship, cargo or money. Established production continues in aggregate while away; no offscreen creatures or geometry are instantiated.
- Morrow's wreck and custodian are specific to Morrow. [Nacre's raider and Kestrel's sentry](ORBITAL_ENCOUNTERS.md) now add different behaviors and persistent salvage. Other orbits still need encounter content; no general fleet/war simulation is implied.
- Combined snapshot version 2 includes inactive planets and transit state. Version 1 combined saves and old field JSON migrate. Tests cover saving mid-journey, returning to changed worlds and rejecting malformed inactive-world state without replacing the live campaign.
- The local ID `morrow` corresponds to strategic planet `s0p0`; all other personal planet IDs match their strategic IDs. The `ExpeditionSession` owns that translation. Legacy urban/strategic demo modes remain separate.

## Verification and next work

Build `20260923-132749` is selected by Play.cmd. The final full suite passed 610 assertions plus UI checks, and the exported pack passed a headless flight startup smoke test using isolated review saves.

The interstellar suite covers all twenty-four orbital destinations, both new atmospheric approaches, expenses, scarcity, closed borders, mid-transit restore, per-world persistence and return-to-title after scene replacement. Engine renders at 1080p were inspected. Bright-surface text contrast and a terrain intersection under the arid mineral patch were corrected. These checks do not establish native input feel, engaging content or AAA presentation.

The next connected-loop work is actual interplanetary commodity cargo and market transactions, expressive contact linked to encountered factions, and badge eligibility leading to real shop upgrades. The current specimen counter is not yet a general cargo manifest with provenance. Existing three-rank sector milestones do not constitute full Space Stage badge parity. Full system/galaxy presentation, additional surface regions, original environment-specific assets, transit effects/audio, richer danger, unified history and the approved AI sound replacements remain open.
