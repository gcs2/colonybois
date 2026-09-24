# Visual fidelity: feasibility and proof

> Reference research; observations, proposals and evidence gaps are not implementation status. [Documentation map](../README.md).

24 September 2026. The user wants this fidelity, not a promise that a nicer mock has already delivered it. This assessment separates engine capability, asset production and verified game behavior.

## Answer

Godot can support the approved stylized surface direction, compact Field Instruments UI, expressive rigged creatures, attractive globes and populated space scenes. There is no demonstrated engine ceiling here requiring an engine migration. **The current game does not achieve the mock's fidelity.** Assets, lighting, terrain composition, animation, UI art and connected world presentation remain the main work. An attractive AI still is not a runtime benchmark, a consistent mesh, or proof of traversable geography.

The new orbital candidate is a more demanding art target than the original bounded surface pass: its close-up coastline/cloud detail, ship material finish and station density should not be presented as a two-day implementation promise. A materially improved surface/HUD pass is a near-term objective; matching these images across a complete procedural universe is substantial production work. A completion date would be speculative until one measured in-engine scene establishes the actual production rate.

## Element-by-element judgment

| Target element | Practical route | Main uncertainty / evidence required |
|---|---|---|
| Surface rock formations and ground | Small authored silhouette kit; blended terrain colors/textures; coherent slope/biome placement; clustered repeated props | Compare ordinary flight camera, near view and rotated view. No extreme foreground blur to conceal defects. |
| Lantern plants and creepy-cute animals | Reusable meshes/rigs, bounded ambient actors, wind or vertex motion, authored idle/move/react animations | Life must look intentional in motion, not randomized bobbing. Readability and footprint must survive distance. |
| Water, depth and lighting | Directional sun, controlled ambient contribution, material contrast, water shader, supported fog and antialiasing | Test on the current renderer. A procedural world cannot blindly depend on pre-baking every location. |
| Field Instruments interface | Original textures or vector shapes for compact housings; rendered object/tool icons; clear typography and state animations | Use real controls at 1080p/1440p/ultrawide. A raster mock cannot prove hit areas, scaling or focus behavior. |
| Planet globe | Shared geography, multiscale surface detail, coherent land/ocean masks, cloud shell, atmosphere shading and attached markers | Avoid fuzzy enlarged maps, incompatible close/far geography, swimming texture detail and drifting sites. |
| Galaxy | Batched stars, layered procedural dust, view-dependent detail, persistent knowledge and geometrically correct range | Artwork must preserve readable selectable stars and actual destinations. A background photograph cannot supply gameplay. |
| Inhabited worlds | Reusable districts/ports, large/medium/small silhouettes, capped ambient traffic and actual services | Greater visual density is separate from individually simulating citizens. No false claim that every window is an interior. |
| Whole accessible planets | Deterministic geography and chunked detail around the player, suitable level of detail and saved changes | Current generated orbital records are not fully landable worlds. This remains a separate engineering gate. |

## Current engine evidence

`project.godot` selects `gl_compatibility` for both renderer entries. The flight scene already creates a WorldEnvironment, directional shadows and ordinary fog. The 4.7 [renderer comparison](https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html) documents core 3D, shadows, standard material support, fog, tone mapping, glow and SSAO for Compatibility; it reserves volumetric fog, screen-space reflections and several advanced illumination features for Forward+. This corrects outdated blanket assumptions about Compatibility effects. Verify the installed engine's actual output before relying on a setting.

Keep the existing renderer for the current pass. A later renderer comparison, if justified and authorized, would need identical scenes, quality settings and frame-time measurements; selecting Forward+ is not a substitute for art production. No renderer or engine switch occurred in this assessment.

Godot documents [MultiMesh instancing](https://docs.godotengine.org/en/4.7/tutorials/performance/using_multimesh.html) and [automatic mesh LOD](https://docs.godotengine.org/en/4.7/tutorials/3d/mesh_lod.html). Both have practical limits: a MultiMesh cannot cull each instance independently, so scenery should be partitioned into spatial groups; imported mesh LODs still require visual inspection. The MultiMesh tutorial carries a version-update warning. These are supported techniques to evaluate, not a claim that unlimited scenery is free.

## Proof before scaling content

After the pending galaxy checkpoint and reference synthesis, build one genuinely navigable surface demonstration with the actual scout, three rock silhouettes, one plant family, one expressive animal, a water/terrain treatment and the compact HUD. Include target selection, harvesting/scan feedback, an attack or hazard and return to orbit. This is a test of the production method, not a reduction of the full game goal.

Capture a short uncut flight sequence, close/ordinary/far views and at least two light/background conditions. Record the seed, build commit, renderer, resolution and hardware. Measure frame-time distribution and memory on the development PC without silently closing the user's other applications. Establish a baseline without competing game load only when available; label contention runs separately. Aim for responsive 60 fps at 1080p on the development PC, but report measured results instead of guaranteeing it in advance.

Compare the same shot to the approved reference and then inspect the movement that the reference cannot show. Review silhouettes, ground cohesion, lighting, spatial continuity, effects, creature behavior, HUD occupancy, interaction feedback and sound separately. Passing one shot does not complete a planet or the game.

## Reference corpus quality

The project needs a curated evidence corpus, not a pile of generated images or an implied machine-learning training dataset. For each record retain: source URL/creator, exact inspected timestamp or manual page, capture file and resolution, crop context, game/version uncertainty, view/state/action, observed facts, inference, our approved departure, comparable current capture, target mock, and review status. Original reference media remains research material; it does not become a game asset.

Prefer legible gameplay frames and before/during/after samples over promotional renders. Keep original captures; do not AI-upscale a blurry source and treat invented detail as evidence. Repeated near-identical frames add little value. Separate approved references, rejected candidates, source observations and implemented captures. The approved surface reference covers environment fidelity; it does not approve every HUD symbol or creature in it.

## Icon size and craft

The user requested roughly **40% larger artwork area**, which is a linear factor of `sqrt(1.4) = 1.183`. For example, an occupied 42×42-pixel artwork box becomes about 50×50 inside its existing 64×64 control where possible. Measure visible artwork, not transparent canvas padding. This is not a 40% increase in both width and height, and not permission to inflate panel shells.

Operational item icons should resemble distinct physical tools/components: recognizable silhouette, consistent three-quarter angle and lighting, a few readable material regions, purposeful color, and enough negative space for count/cooldown/lock states. Category and navigation symbols can remain simpler. Render from reusable 3D assets where possible, or author original illustrated sprites under the same art specification. Avoid miniature text, unrelated emoji and a different art style for every generated item. Test silhouettes at actual size before adding surface detail.

Default flight should retain at least roughly 80% unobstructed world area as an initial composition target. Collapse unused trays; allow a richly populated trade or inventory panel to occupy the space its work requires. Screen occupancy is a review measurement, not a substitute for legibility or actual hit testing.
