# Living ecosystems and a growing species collection

User direction, 2026-09-23: expand the original creepy-cute flora/fauna into a broad collection whose organisms interact, change environments and create useful opportunities. Species should matter through ecology, trade and abilities. This document and `art/specs/species_catalog_v1.json` define the next system; the current encounter still uses its small fixed ecological model.

## Discovery becomes an ecological toolkit

A species can provide a resource, support another organism, modify a habitat, or enable a new action. Benefits depend on a viable population in a suitable place. A specimen in a cargo hold does not grant a permanent empire-wide bonus. Populations consume resources, occupy habitat and can fail to establish.

Example: a warm basin contains lantern pods and bell grazers. Moderate grazing spreads seeds; an overlarge herd strips them. A pollen imp can improve reproduction, provided flowers and roosts survive. A ribbon kite reduces grazer pressure but needs prey. A glass mantis offers a different form of control and may also eat the pollinators you wanted to protect. Hush fungus returns nutrients from litter; without organic input, it cannot replenish soil indefinitely.

The payoff could be a dependable nursery export, insulation material, a new expedition consumable, or access to a biological technology. A healthy world can specialize differently from an intensively harvested world. Both can be interesting choices, with visible costs.

## Habitats and feeding roles are different

Use spatial habitat patches such as shoreline, wetland, mineral scrub, canopy edge, vent margin and cold shelter. Conditions include temperature, moisture, available light, nutrients and exposure. A planet contains a small mosaic of these patches; borders and connectivity affect establishment and dispersal.

Within those habitats, producers support consumers; predators consume prey; detritivores and decomposers process dead material. Pollination, shelter, seed dispersal and habitat engineering add other relationships. These are webs with several feeding paths, rather than a requirement that every planet fill the same herbivore/carnivore checklist. NOAA describes aquatic food webs and the effects of changing predators; the National Park Service explains pollination's role in plant reproduction. These are inspirations for a deliberately simplified alien ecology, not validation of our invented organisms or balancing numbers. [NOAA food webs](https://prod-01-alb-www-noaa.woc.noaa.gov/education/resource-collections/marine-life/aquatic-food-webs), [NPS pollinators](https://www.nps.gov/subjects/pollinators/index.htm).

**Trophic roles** describe feeding relationships. **Habitat zones** describe where organisms live. An airborne grazer and a ground grazer can occupy comparable feeding roles while needing very different habitat. A decomposer should not be treated as the top predator in a linear tier ladder. Trophic position can vary with diet.

## Initial authored collection

Fourteen briefs establish ecological and animation variety. Only lantern pods and bell grazers currently have models; the rest are production briefs, not finished assets.

| Species | Function / possibility | Complication |
| --- | --- | --- |
| Lantern pod | Cultivated seeds, grazer food, nursery exports | Harvest removes reproduction material |
| Bell grazer | Seed dispersal; proposed naturally shed insulation fiber | Large herds overgraze |
| Veil reed | Sediment capture, water-treatment membranes, sheltered roots | Occupies shore habitat and stores pollutants |
| Ember lichen | Thermal-habitat producer and biological catalyst | Depends on finite vent chemical flux |
| Sail frond | Captures available fog and shelters moist pockets | Cannot create water where none is available |
| Bloom float | Filter-feeder food and buoyant compounds | Dieback creates a decomposition load |
| Frostlace | Cold-world crop and cryoprotectant export | Warming can remove its climate niche |
| Pollen imp | Compatible plant reproduction | Needs both food and roosts; vulnerable to predators |
| Pebbleback | Substrate disturbance and naturally shed mineral shell | Excess scraping removes protective vegetation |
| Silt whisk | Detritus processing in shallow water | Limited capacity under heavy organic loading |
| Hush fungus | Nutrient recovery from litter | Needs organic inputs and suitable conditions |
| Ribbon kite | Predator that may relieve grazer pressure | Depends on prey; cannot be stocked without limit |
| Glass mantis | Suppresses some grazers | Also consumes useful pollinators |
| Cloud manta | Later filter-feeding megafauna transport partnership | Food, rest and air corridors constrain route capacity |

Avoid a single universal best ecosystem. Temperature ranges, competing habitat needs, feeding requirements and resource goals should make several local arrangements viable. Terraforming can improve one system while damaging another. The player should see this before committing a major intervention.

## Bounded simulation proposal

Begin with three habitat patches and six interacting species, including producers, consumers, one predator and a decomposer. Keep the full catalog available for later content selection. Track biomass/population index per species per patch, available nutrients, detritus, moisture, suitability and production. Simulate fixed ecological steps through the authoritative state; detailed animals exist only in the viewed scene.

Suggested tick sequence:

1. Apply external inputs and climate changes, then compute habitat suitability and resource-limited carrying capacity.
2. Compute proposed growth, consumption and mortality from the same previous snapshot. Allocate limited shared resources across competing demands before committing changes.
3. Transfer actual consumed biomass through feeding links with bounded efficiency. Account for growth, waste, detritus and metabolic losses. Nutrient recycling consumes detritus; it is not a free production multiplier.
4. Apply bounded reproduction and dispersal through connected suitable patches. Reserve capacity so two incoming populations cannot each claim all remaining space.
5. Apply harvesting and derive usable ecological services from surviving populations. Cap overlapping services; two pollinators cannot provide two copies of the same unlimited benefit.
6. Record meaningful transitions and summarize causes. Keep ordinary fluctuations out of the emergency notification stream.

Exact rates, step duration and conversion efficiencies require tuning. Use stable IDs, fixed ordering and saved RNG state when randomness is introduced. Avoid per-animal reproduction, hunger/pathfinding across a planet, unrestricted species-pair comparisons and stiff numerical food-web solvers in the first implementation. Compile each patch's sparse set of actual interactions; cap active species initially and profile before expanding.

Ambient animation reflects the aggregate result: feeding clusters when food is abundant, movement toward surviving patches under shortage, fewer visual representatives at low population, and stressed poses under bad conditions. The visible animal is not the unit of economic stock. Existing grazer curiosity is presentation behavior and does not yet alter ecological biomass.

## Player actions and explanations

Scan to learn tolerances and observed relationships. Later research improves confidence in uncertain interactions. Before introduction, show a coarse suitability assessment, known diet, likely competitors, establishment cost and what remains unknown. Offer a small monitored introduction before committing a large habitat. Avoid invisible arbitrary catastrophes.

Actions: collect a viable sample, cultivate, introduce, establish a protected reserve, set a harvest ceiling, improve a habitat connection, quarantine, or negotiate access to another world's biological resource. Delegation handles established cultivation and ordinary recovery; the flagship remains useful for discovery and unusual interventions.

The ecology panel should answer concrete questions: “Seed output is low: pollinators lack roosts”; “Herd growth exceeds the available foliage”; “Recycling has slowed because litter is exhausted.” Show before/after trends, food links and limiting factors. Reserve exact population counts for genuinely countable stock; otherwise use clear biomass or abundance measures.

The catalog records observed discoveries, provenance and known interactions. Story mode can unlock authored encounter variants or optional sandbox tools through meaningful discoveries. Preserve a playable sandbox without compulsory campaign grinding. A large species collection should support alternative solutions, including trade for a product instead of introducing its producer everywhere.

## Art and animation production loop

Each species brief records body plan, silhouette, size, material palette, habitat, feeding role, interaction response, animation family, export source, visual states and review status. Related organisms can share rigs while retaining distinct silhouettes and useful differences. Seeded cosmetic variation does not count as a new authored species.

Current buoyant-bell animation uses named 3D part pivots plus procedural deformation: independent eyes, body pulse, fins and flexible tendrils. Other body plans need different motion solutions: rooted flex for plants, folding canopies, wing-beat rigs, contact-aware walking legs, aquatic body waves and gliding megafauna. Use authored resting/feeding/startled poses blended with gaze and environmental response. A generic humanoid animation set would not cover these creatures well.

Produce a reviewed family in small batches: brief → silhouette/model → motion study → habitat placement → ecological behavior → optimization. Track source and exports. Validate the model and its animation at normal play distance before filling the catalog with costly assets. A future Blender/Skeleton3D pipeline can supply skinned meshes and baked clips for complex species; the present procedural grazer is not a claim that this pipeline already exists.

## Implementation gates

1. **Small food web:** adding/removing one population predictably changes two others; conservation, competition and reproduction bounds pass deterministic tests.
2. **Two viable arrangements:** one favors seed export, another ecological recovery or specialist production. Neither dominates every habitat.
3. **Living presentation:** at least one stress/feeding visual is driven by real ecological state; offscreen simulation behaves identically.
4. **Interplanetary use:** a discovered species or imported product enables a new capability elsewhere, with actual establishment and freight constraints.
5. **Collection expansion:** add families only when they create new interactions, environments or actions. Review repetition and art cost before moving from fourteen briefs toward a large library.

Required tests: save/load mid-transition, no negative populations, shared-resource allocation, no infinite recycling profit, bounded service stacking, extinction/reintroduction, climate stress and recovery, stable results across view changes, and a peaceful session with few forced interruptions. The first acceptance test is whether the player enjoys trying a different ecological arrangement and understands the outcome.
