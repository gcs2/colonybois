# Visitable planet production pipeline

## Implemented checkpoint — 23 September 2026

`planet_generator.gd` generates spherical elevation, latitude/elevation-dependent temperature, humidity, six biome classifications and cloud density from a versioned recipe. `planet_archetypes.json` supplies temperate, frozen and arid climate/palette rules. Morrow has a fixed seed and a land constraint beneath its existing basin coordinate. Sampling is independent of frame rate, camera and gameplay RNG.

The renderer uses baked surface color, physical-condition and relief-normal maps. Clouds are a separate drifting shell; atmosphere is a restrained additive rim. This is stylized rendering, not physical atmospheric scattering or a plate-tectonics model. Morrow orbit and atlas share textures. All surveyed strategic planet overviews now use this same renderer with their full persistent seeds, replacing the previous modulo-100 shader seed. Unknown strategic worlds remain concealed. Settlement markers inherit globe rotation.

Warming changes the frozen climate's equatorial temperature; water recovery changes arid humidity. The strategic project's real completion fraction blends the visual result. Both preserve the original elevation/coastline and sites. Economic effects remain in the existing aggregate strategic simulation. The isolated flight field does not yet inherit strategic climate projects.

512×256 maps baked in about 0.6–0.7 seconds per world on this development PC during rendered review. They are generated once per distinct recipe/size and shared by active views. The cache holds four recipes; visible globes retain evicted resources until released. No geography generation occurs per frame. A climate project may request a second bake once. This synchronous first-use cost needs worker-thread or offline preparation before galaxy-scale streaming; do not generate hundreds of worlds at startup.

## Recipe contract

Persist an ID, full integer seed, generator version, archetype, authored sites and deliberate climate overrides. Never derive terrain from the order worlds are visited or from truncated seeds. Version 1 is pinned in Morrow's definition and generated strategic recipes. Before introducing version 2, add saved recipe/version migration for strategic planets; never silently regenerate a player's established geography. Runtime texture caches are disposable, not authoritative saves.

`sample(direction)` is the source of geographic truth. `region_sample(latitude, longitude, east_km, north_km)` queries that same field in a local tangent frame. The globe shader reads textures baked from these samples. Longitude wraps continuously; the two poles are spherical rather than special random tiles. Authored land constraints affect only their neighborhood and cannot eliminate oceans globally.

## Work still required to make every world visitable

1. Persist one shared ship/location/cargo/chronicle across strategic and personal flight. Select a real planet ID through system travel rather than launching a second isolated scenario.
2. Generate landing regions from the spherical sampler. Match coast, climate and elevation to the selected coordinate; add deterministic finer detail without altering the large geography. Current Morrow ground remains the earlier authored terrain and does not yet match this globe.
3. Select biome kits from temperature, water, terrain and atmosphere: ground materials, geological meshes, plants, fauna, weather, ambient sound and landing hazards. Kits need authored creepy-cute assets and distinct interactions. Palettes alone are insufficient.
4. Place resource opportunities using geological/ecological constraints and independent seeded streams. Persist depletion, structures, discoveries and environmental changes as deltas. No new economic resource production is claimed by this renderer.
5. Add continuous approach cues and reference-frame handoff at the chosen site; test every approach hemisphere, camera scale and environment. Current Morrow return is a local scene transition with one landable basin, not seamless planetary flight.
6. Extend beyond three terrestrial families only after three genuinely different expeditions work. Airless/cratered moons, volcanic worlds, deep oceans and gas giants require their own geology, atmosphere and access rules; do not implement them as palette swaps.

## Art acceptance

The rendered study is produced by `tests/review_planet_generation.gd`; it is an engine image, not a concept painting. The user accepted this pass as good enough to move on. Further polish is deferred behind gameplay; this does not claim final AAA art. Target readable continental silhouettes, restrained relief, thin atmosphere, distinct material response, intentional sun direction and clouds that leave important geography legible. Review at actual orbital size as well as close-up, across seeds and near both poles. Avoid camouflage-like noise, oversized marker dots and luminous outlines. The ship, random starfield and terrain kits remain separate unresolved art tasks.

The next asset loop is: environment specification → globe/geography review → coordinated terrain/rock/flora material kit → actual generated landing region → motion/audio and gameplay review. Generated concepts/textures support authored reusable geometry; a concept sheet does not count as a working planet.

## Evidence

Generator checks cover repeated seeds, changed seeds, bounded physical fields, climate differences, longitude seam, landable-site constraint, region/globe agreement, identical rebuilt texture data, cache eviction and climate changes preserving geography. Atlas integration verifies shared map resources. Strategic UI checks verify persistent seeds, climate blending and markers attached to the globe. Captures and automated checks do not establish native control feel, final art quality or enjoyable expeditions.
