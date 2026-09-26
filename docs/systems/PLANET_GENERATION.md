# Visitable planet production pipeline

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

Latest travel checkpoint: [INTERSTELLAR_FLIGHT.md](INTERSTELLAR_FLIGHT.md) adds 24 orbital destinations and three connected landing regions. Earlier single-world limitations below are historical; strategic climate-project visuals and broader surface/content generation remain unfinished.

## Morrow recipe-driven surface composition pass — 26 September 2026

The shared PlanetSurfaceRuntime still owns spherical elevation, surface color, geodesic advance, bounded feature queries and local projection. The unchanged macro opportunity regions and stable saved deltas now coexist with role assignment clustered across 3×4 spherical cells. Fine habitat content remains a deterministic 64 m query inside a 192 m active radius; new category streams do not relocate existing feature IDs.

The renderer now adds recipe-colored ground layers and sampled-relief context, and places Morrow water from the authored waterbody specification. The local chart samples terrain_height, derives land/water colors and labels the largest sampled connected water body when present in its 125 m window. Route endpoints and ship/contact coordinates remain world anchored; the 50 m ruler is derived from that window. The chart does not read waterbody_specs directly. The distant visual shell reuses recipe elevation/ruggedness but remains a visual-only mesh outside local interaction; the latest critic says its smooth slope can be mistaken for traversable terrain.

A 1920×1080 integrated mining capture after the habitat, chart, terrain and HUD changes was independently reviewed against the approved canon. Both world and HUD visual gates fail. The environment remains mostly smooth brown ground with small scattered life; the chart’s terrain contrast is weak. The HUD footprint is more aligned, but cargo pictograms are still small, the synthetic inventory is mostly empty, and ALT is a detached high-contrast strip. The mining state is away from the authored basin, so no visible water is expected in that frame. See the integrated visual review at ../reviews/VIEW_MOCK_COVERAGE.md#integrated-morrow-world-and-hud-runtime-26-september-2026.

Focused integrated checks: test_surface_exploration.gd passed 63 assertions in 46.31 s; test_planet_surface_runtime.gd passed 18 checks in 0.62 s; test_planet_surface_window.gd passed 608 assertions in 0.57 s; chart-only checks passed 5 assertions; and test_flight_hud.gd passed 69 assertions in 21.63 s. The capture harness passed its scripted assertions. No full suite, native play, export, performance, or player-acceptance claim is supported.
## Morrow seeded surface field — 25 September 2026

Morrow's personal surface scene now opens into a bounded 256 m-radius field. The authored basin height is preserved through 39 m and blends into recipe-seeded terrain through 96 m. The same cached recipe noise drives surface height and color. A stable three-region layout names Morrow Basin, Glassgrass Reach and Rillstone Shelf; tile feature records for cover, rock, flora and fauna derive from planet ID, geography seed, generator version and tile coordinates, independent of global gameplay RNG. The existing expedition species representatives are distributed among those regions. Returning from orbit restores the stored surface position; encounter and expedition snapshots migrate old records additively.

This is deterministic local-field exploration, not whole-sphere surface travel or streamed planetary terrain. The playable radius is 256 m around the basin. There is no chunk streaming, spherical surface reference-frame handoff, or measured performance budget, and not every deterministic feature point is an interactive lifeform. The terrain chart is still a close-up 80 m surface chart with panning so nearby targets remain separately selectable; system and galaxy maps stay separate. The user's latest direction explicitly prioritizes consistent planet-wide exploration and seeded flora/fauna beyond this landing field. The spherical orbit generator and planar surface field must converge on one versioned recipe; don't describe local repeatability as whole-planet generation. See [the runtime visual review](../reviews/VIEW_MOCK_COVERAGE.md#morrow-surface-field-and-hud-25-september-2026) for the independent critic's rejection against the approved art target.

## Implemented checkpoint — 23 September 2026

`planet_generator.gd` generates spherical elevation, latitude/elevation-dependent temperature, humidity, six biome classifications and cloud density from a versioned recipe. `planet_archetypes.json` supplies temperate, frozen and arid climate/palette rules. Morrow has a fixed seed and a land constraint beneath its existing basin coordinate. Sampling is independent of frame rate, camera and gameplay RNG.

The renderer uses baked surface color, physical-condition and relief-normal maps. Clouds are a separate drifting shell; atmosphere is a restrained additive rim. This is stylized rendering, not physical atmospheric scattering or a plate-tectonics model. Morrow orbit and atlas share textures. All surveyed strategic planet overviews now use this same renderer with their full persistent seeds, replacing the previous modulo-100 shader seed. Unknown strategic worlds remain concealed. Settlement markers inherit globe rotation.

Warming changes the frozen climate's equatorial temperature; water recovery changes arid humidity. The strategic project's real completion fraction blends the visual result. Both preserve the original elevation/coastline and sites. Economic effects remain in the existing aggregate strategic simulation. The isolated flight field does not yet inherit strategic climate projects.

512×256 maps baked in about 0.6–0.7 seconds per world on this development PC during rendered review. They are generated once per distinct recipe/size and shared by active views. The cache holds four recipes; visible globes retain evicted resources until released. No geography generation occurs per frame. A climate project may request a second bake once. This synchronous first-use cost needs worker-thread or offline preparation before galaxy-scale streaming; do not generate hundreds of worlds at startup.

## Recipe contract

Persist an ID, full integer seed, generator version, archetype, authored sites and deliberate climate overrides. Never derive terrain from the order worlds are visited or from truncated seeds. Version 1 is pinned in Morrow's definition and generated strategic recipes. Before introducing version 2, add saved recipe/version migration for strategic planets; never silently regenerate a player's established geography. Runtime texture caches are disposable, not authoritative saves.

`sample(direction)` is the source of geographic truth. `region_sample(latitude, longitude, east_km, north_km)` queries that same field in a local tangent frame. The globe shader reads textures baked from these samples. Longitude wraps continuously; the two poles are spherical rather than special random tiles. Authored land constraints affect only their neighborhood and cannot eliminate oceans globally.

## Recipe-to-play production pipeline

Build worlds from a stable recipe and a player-facing vertical slice, not by scattering unrelated scenery.

1. **Identity:** persist planet ID, full seed, generator version, archetype, authored sites, and intentional climate overrides. Never silently reroll an established planet. Treat the region-grid resolution and coordinate convention as versioned data contracts.
2. **One geography query:** map the saved planet-fixed direction to one spherical sample. The globe, landing terrain, coastline, elevation, temperature, moisture, and biome must all agree with that sample. Keep local tangent coordinates as a view of the sphere, not an independent plane.
3. **Stable regions:** derive each region ID from recipe identity/version and integer spherical cell coordinates. Give terrain dressing, flora, fauna, resources, and authored points of interest separate deterministic streams keyed by stable region/feature IDs. Adding a plant species must not relocate an ore seam.
4. **Habitat kits:** choose a small authored kit from sampled biome and conditions: ground material, geological silhouettes, clustered plants, a few readable fauna roles, weather/audio, and one distinctive landmark or interaction. Density alone does not make a world distinct.
5. **Bounded streaming:** sample shared chunk edges from the same geography function and load only a small neighborhood around the scout. Keep ambient life as capped visual effects; simulate offscreen population and recovery in aggregate.
6. **Persistent change:** store sparse deltas keyed by stable feature/site ID—discovery, depletion, construction, and meaningful ecological change—separately from the generated baseline. Re-entering a region must regenerate its unchanged content and reapply its deltas.
7. **Prove one connected slice:** use Morrow Basin and one adjacent 512 m region. Fly across the boundary, see and use a region-specific opportunity, leave for orbit, save/reload, return to the same planet-fixed location, and confirm both repeatable geography and preserved change. Only then widen travel or add planet families. Review same-state runtime captures against the approved canon; tests do not establish art acceptance or fun.

**Current gap:** Planet-fixed deterministic placement now spans bounded neighboring regions and re-enters with stable unchanged features, but this is not whole-sphere streaming, a dense living ecosystem, or a finished biome kit. The practical movement envelope remains about 1.2 km in a tangent frame, with one authored landing basin and a small set of resource opportunities. The current visual gate still fails; see the integrated review above.
## Work still required to make every world visitable

1. Persist one shared ship/location/cargo/chronicle across strategic and personal flight. Select a real planet ID through system travel rather than launching a second isolated scenario.
2. Continue extending the bounded Morrow landing window from the spherical sampler. Match coast, climate, elevation, and authored sites at the selected coordinate; add deterministic finer detail without altering large geography. The current runtime samples the shared recipe but still needs stable multi-region terrain and landmark continuity beyond its provisional tangent-frame bound.
3. Select biome kits from temperature, water, terrain and atmosphere: ground materials, geological meshes, plants, fauna, weather, ambient sound and landing hazards. Kits need authored creepy-cute assets and distinct interactions. Palettes alone are insufficient.
4. Place resource opportunities using geological/ecological constraints and independent seeded streams. Persist depletion, structures, discoveries and environmental changes as deltas. No new economic resource production is claimed by this renderer.
5. Orbital entry now follows the actual rotating site-marker direction instead of a fixed space point. Continue with landmark/terrain continuity and reference-frame handoff at the chosen site; test every approach hemisphere, camera scale and environment. Current Morrow return is a local scene transition with one landable basin, not seamless planetary flight.
6. Extend beyond three terrestrial families only after three genuinely different expeditions work. Airless/cratered moons, volcanic worlds, deep oceans and gas giants require their own geology, atmosphere and access rules; do not implement them as palette swaps.

## Art acceptance

The rendered study is produced by `tests/review_planet_generation.gd`; it is an engine image, not a concept painting. The user accepted this pass as good enough to move on. Further polish is deferred behind gameplay; this does not claim final AAA art. Target readable continental silhouettes, restrained relief, thin atmosphere, distinct material response, intentional sun direction and clouds that leave important geography legible. Review at actual orbital size as well as close-up, across seeds and near both poles. Avoid camouflage-like noise, oversized marker dots and luminous outlines. The ship, random starfield and terrain kits remain separate unresolved art tasks.

The next asset loop is: environment specification → globe/geography review → coordinated terrain/rock/flora material kit → actual generated landing region → motion/audio and gameplay review. Generated concepts/textures support authored reusable geometry; a concept sheet does not count as a working planet.

## Evidence

Generator checks cover repeated seeds, changed seeds, bounded physical fields, climate differences, longitude seam, landable-site constraint, region/globe agreement, identical rebuilt texture data, cache eviction and climate changes preserving geography. Atlas integration verifies shared map resources. Strategic UI checks verify persistent seeds, climate blending and markers attached to the globe. Captures and automated checks do not establish native control feel, final art quality or enjoyable expeditions.
