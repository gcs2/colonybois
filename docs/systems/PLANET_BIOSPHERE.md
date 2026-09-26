# Collect life, establish worlds

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. Integrated L01/T01 checkpoint, not full abduction or ecology parity.

Fly close to a visible lifeform with the scanner selected and click it. Select the tractor and click again to collect. The ship approaches, runs a 1.5-second beam, validates the target and then loads one specimen. Scanning is free; capture and release each cost five energy. Stop, manual movement, departure or inspection cancels an unfinished operation without spending. The twelve-unit expedition hold travels with the ship and is separate from freight, repair packs and the legacy nursery's local pods.

Open Inventory → Specimens, or select the Environment deployer icon, to choose a carried specimen. Click a surface habitat to release it. It is consumed only after arrival and completion; its position and established species persist. Distinct species, not repeated copies, fill ecological slots. Incompatible releases explain the missing slot or food supply and preserve cargo. Every playable species has an original mesh-kit representative, bounded procedural motion and a portrait rendered from that geometry. See [asset specification](../art/BIOSPHERE_ASSET_SPEC.md).

Morrow's existing native species representatives now occupy deterministic positions across Basin, Glassgrass Reach and Rillstone Shelf rather than clustering only around the landing origin. Introduced placements and save validation use the current 256 m playable radius. This is a consistent regional distribution on a bounded local field; it does not yet populate a streamed whole planet, simulate every fauna marker as an interactive organism, or prove visual acceptance. The approved surface concept remains the art target.

## Climate, food chains and stakes

Each T tier has a small, medium and large plant, two distinct herbivores and one predator. Its plants stop passive climate drift from crossing out of the supported ring. Animals complete the ecological tier and allow the next tier's introductions. Active climate tools can still push a planet outside that ring; stabilization is not invulnerability.

Completed ecosystems, limited by current climate, now govern modified-world population caps and export yields. T3 climate with only a T1 food chain retains T1 development. The two foreign sets of six lifeforms let the player complete all three tiers on a destination through actual travel and collection; eighteen species serve this functional requirement. This is not the promised deep content corpus or a generic food-web simulator.

Native populations start with a complete first tier. Each established species has up to four locally collectible specimens; one recovers every sixty active seconds. Taking the last locally available specimen does not eradicate a planetary species. This is an aggregate availability pool, not individually simulated animals. Introduced populations begin with one available specimen. Duplicate introductions cannot inflate the ecosystem or farm its milestones.

Unsuitable climate starts a thirty-second habitat-loss warning. Restoring conditions in time saves the unsupported tiers. Otherwise their species and surface representatives disappear, their stabilization is lost, and the chronicle records the actual affected world even while the ship is elsewhere. Each newly completed T2/T3 ecosystem records a distinct milestone; dedicated reference badge families and shop unlocks remain work for progression, not implicitly completed here.

## Reference and deliberate tuning

Spore's plant sizes, two herbivores and predator per tier, and plants-before-animals sequence informed this implementation. [Terraforming](https://spore.fandom.com/wiki/Terraforming), [Ecological niche](https://spore.fandom.com/wiki/Ecological_niche), [Flora](https://spore.fandom.com/wiki/Flora). Rechecked indexed article excerpts on 23 September; direct full-page retrieval was blocked. No retail playtest or exact-stat parity is claimed. The twelve-unit hold, energy costs, initial native first tier, local recovery and warning durations are explicit scenario tuning. Species names, geometry and portraits are original.

## Architecture and validation

`planet_biosphere.gd` owns cargo, scanned identities, tiers, local stocks, placements, stress, recovery and distinct milestones. It runs on the shared simulation clock; views never own populations. `biosphere_view.gd` handles mouse orders, bounded representatives, animation, beam feedback, inventory and slot inspection. There are at most eighteen representatives in the viewed patch, no planet-wide organism agents or pathfinding. Specimens keep the same species identity in inventory, world and history.

Snapshot v13 validates roles, distinct identities, food-chain ordering, finite stock/cargo, positions and time counters before replacing live state. Earlier saves receive no carried life or completed introductions. Climate effects are rebuilt from the same restored ecology. Older high-climate worlds can now have lower effective capacity until their food chains are completed; this is the intended replacement of climate-only capacity.

`tests/test_planet_biosphere.gd` covers the paid three-world collection → transformation → T3 journey, actual surface picking/arrival/beam commands, cancellation, inspection, cargo conservation, capacity/output effects, saved placements, drift resistance, habitat loss, off-screen chronology, malformed snapshots and v12 migration. `tests/review_planet_biosphere.gd` captures actual surface, inventory and ecosystem screens at 1080p/1440p. Portraits are reproducible with `tools/BakeSpecimenPortraits.gd`, followed by an editor import.

Remaining: native input/fun review, approved creature rigs/materials/audio, broad specimen distributions, sentient/property abduction and its diplomacy, specimen trade, eradication tools and ecological disasters, full Zoologist/Ecologist/Terra-Wrangler progression, and combined/extreme terraforming tools. The old nursery experiment remains available in the separate local sample system; it is not required by this loop. Do not deepen cultivation or expand the food-web catalog before the remaining spaceship feature breadth.
