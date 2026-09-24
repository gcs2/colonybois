# Tavi merchant: concept-to-model fidelity test

Status: DEFERRED at the user's request after V2. Preserve both experiments; no further refinement or cast production is currently authorized as the next priority. A bounded requested art-direction comparison does not reopen full modeling. See CHARACTER_SCOPE_OPTIONS.md.

24 September 2026. A bounded asset experiment explicitly requested by the user. This does not change the game engine, render pipeline, saved campaign or approved gameplay scope. The delegated modeler works alongside the main task; no separate user task has been created.

## What the reference is good for

`art/concepts/characters/merchant-directions-20260924.png`, LEFT creature, establishes an endorsed visual direction: broad soft mantle, lateral stalk eyes, protected beak, tentacles, lavender/ochre/teal materials and trade props. This selectively endorsed source sheet is now preserved for backup; its sidecar distinguishes accepted directions from the middle, which is too creepy. The user also likes the right creature, but that is a separate design. Earlier v2 toy face and v3 human-eyed face are rejected. The endorsed contact-window composition remains intact.

This is a plausible concept-art reference to give a modeler. It is not yet a complete production brief or a reliable turnaround. Hidden anatomy, thickness, back of head, eye articulation and deformation are not specified by one AI image. Do not claim the image itself supplies topology, UVs, rig, texture maps or consistent alternate views.

## Character intention

See CHARACTER_ARCHETYPES.md. Tavi is a large, self-assured merchant with a family trading business and experience in the open expanse. Slight arrogance should read as comfortable authority and careful appraisal. He is capable of warmth and loyalty. His size is not a gag or an indicator of greed. His political philosophy remains unassigned by the latest visual feedback.

He inspects a valuable sample closely, occupies the room at rest, and becomes still when a crew is threatened. Do not give him a permanent grin or a human face. His eye direction, mantle angle, tentacle placement and use of personal space do most of the acting.

## Proposed dimensional and material brief

These authoring choices resolve unknowns for a test; they are not new biological canon. Keep them adjustable in source.

- Bust from lower torso upward; no need to invent feet or full locomotion yet. Large pear-shaped body supports the mantle; show weight rather than stacking disconnected spheres.
- Mantle broad and relatively low, overlapping the eyes' bases and underside anatomy. Viewed from the side it must have real depth and an underside, not a flat picture.
- Two short lateral eye stalks with dark pupils and restrained highlights. Eye pose can point at a common target. No human nose, lips, brows or lashes.
- Small protected beak under the mantle, set into soft folds. Avoid a huge exposed radial mouth or toothy horror. Front silhouette is approachable; underside provides biological strangeness.
- Four visible grasping limbs are sufficient for the bust. Clear major curves and attachment points. Coiling limbs must have volume, plausible contact with any held object and no obvious penetrating intersections.
- Lavender skin, ochre underside, muted teal accents; rough organic surfaces, restrained shiny eye surfaces, worn harness. Amber sample flask is an optional separable prop, not required to save a poor face.
- Neutral lighting and material contrast first. Surface speckling must not hide geometry errors. No baked key light painted into albedo.
- Work in meters with documented forward axis and pivot; settle proportions using the rendered views. The portrait will be evaluated around 400–600 pixels high as well as at close-up.

## Deliverables and phases

| Phase | Deliverable | What it proves |
|---|---|---|
| Current delegated proof | Reproducible editable mesh source, exported GLB, neutral front/side/three-quarter renders, measured bounds/geometry/material counts | Actual 3D volume, export/render pipeline and initial silhouette |
| Art refinement | Corrected sculpt/forms, consistent front/side/back/underside model views, cleaned intersections | The design works beyond one camera angle |
| Game asset finish | Suitable topology, UVs, authored base color/roughness/normal treatment, texture/material budgets | Close-up material and shading quality in the current renderer |
| Performance | Eye aim, mantle/limb controls, blink or shutter anatomy, intentional mouth treatment; listen/greet/inspect/accept/refuse clips | Character can act without losing its design |
| Encounter integration | Same representative through contact/trade, real action-linked reactions, 1080p/1440p captures | Works as a game character rather than an isolated render |

Initial portrait asset budget hypothesis: roughly 20–60k triangles and a small shared material set, measured rather than assumed. More geometry cannot substitute for good anatomy. Budget may change after actual in-engine measurements; do not multiply a portrait-quality mesh into hundreds of world actors. Final source might be a Blender file; the first proof uses available local Godot authoring because Blender was not found installed. A reproducible mesh generator is editable source, but is not equivalent to a hand-sculpted, rigged Blender asset.

Godot recommends glTF/GLB for 3D scene exchange and imports materials/scene data. [Official format documentation](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html). AnimationTree can select and blend authored animations; it does not author them. [Official animation documentation](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html). These capabilities establish a viable pipeline, not a guarantee that the current model meets the concept.

## Review rubric

Latest user steering: keep trying the actual model, with a close visual match (approximately “95%”) as the desired outcome. This is an aspirational art acceptance threshold, not permission to assign an invented numeric score. A second connected-surface experiment is underway in art/prototypes/tavi_v2; keep the failed-fidelity first proof for comparison. No higher reasoning setting has been requested or applied as a model override.

Use matched camera framing and a comparable neutral background. Report each dimension as pass, partial or fail, with visible evidence. No single percentage or triangle count substitutes for art judgment.

1. Recognizable head/body silhouette and nonhuman face.
2. Sense of mass, pose and merchant presence.
3. Clean connected anatomy from front, side and back.
4. Material separation, surface richness and controlled highlights.
5. Readability at real communication-window size.
6. Intentional motion and expression; mark untested if unrigged.
7. Successful export/reimport and current-renderer output.
8. Measured runtime cost; capture frame rate alone is not a benchmark.

The prototype must be labeled as a prototype. Never relabel another imagegen output as an engine render. Show the actual model even if it falls short. Preserve source and a generation recipe; keep temporary build/cache/render output out of routine Git. No asset-store or generator subscription purchase is part of this task.

## If continued in a separate conversation

Suggested task title: **Tavi — alien merchant model and performance**.

Task brief: Work only on the original merchant asset and isolated review scene. Read this document, CHARACTER_ARCHETYPES.md and CONTACT_PERFORMANCE_SPEC.md; inspect the endorsed left creature reference and actual model renders. Improve the real model toward the approved design. Preserve the large, confident, family-oriented traveler personality and nonhuman anatomy. Deliver editable source, game-compatible GLB, consistent views and eventually five short authored acting clips. Compare each iteration against the concept and communication-window size; state remaining fidelity gaps. Do not redesign UI, change gameplay/economy, migrate engines, close the running game or purchase services. Coordinate asset paths with the main task and checkpoint validated work to GitHub.

The separate task would own the character asset; the main task would own the contact UI and integration. Agreement on file ownership prevents concurrent edits. Current delegation stays within this task until the user requests that separate task.
