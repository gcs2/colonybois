# Tripo asset pack v1 — source concepts and Spore mapping

Generated source art for a small, traceable Frontier Worlds → Tripo → Godot experiment. These are concepts, not approved final game assets. The original nine prop inputs are in `batch_01_props/`; the 16 newly isolated Space Stage equipment concepts are in `batch_02_space_equipment/`. The orbital composition mock in `reference_only/` is excluded from both batches.

## Where the images are

Each PNG is under 5 MB. Each batch has its own README; [batch 02's guide](batch_02_space_equipment/README.md) numbers the 16 items and maps their roles to Spore. The excluded orbit mock is kept in `reference_only/`.

| File | Purpose in our game | Relationship to Spore Space Stage | Tripo target |
|---|---|---|---|
| `batch_01_props/orbital-service-vessel-v1.png` | Giant inhabited service ship/station visible beside a planet; visual home for existing orbit services | **Original presentation addition.** Gives physical presence to docking, recharge, repair and shop access; it is not a new Spore-style tool or station mechanic. | Hero environment prop, 18k faces, triangle topology; target about 36 × 14 × 24 m; no collision needed for the first visual pass. |
| `batch_01_props/arc-lance-module-v1.png` | Visible weapon mount on the scout | **Closest to Spore's Laser weapon family.** Our current game already has the Arc Lance; this image is its installed visual housing, not a new Pulse weapon. `emitter` is a damage upgrade to that existing action. | Ship hardpoint module, 4k faces; about 1.2 × 0.5 × 0.35 m; muzzle socket remains authored in Godot. |
| `batch_01_props/shield-projector-module-v1.png` | Visible support-system mount | **Direct functional analogue: Spore Shield.** Our paid `shield` upgrade already supplies a temporary defensive effect. The mesh must not change duration, price or protection. | Ship hardpoint module, 4k faces; about 0.8 × 0.8 × 0.8 m. |
| `batch_01_props/survey-array-v1.png` | External antenna/sensor visual | **Presentation for scan and survey verbs**, which echo Spore's scanning/discovery play; not a claim that the reference has this exact upgrade. | Ship utility module, 4k faces; about 1.3 × 0.8 × 0.45 m. |
| `batch_01_props/drive-booster-v1.png` | Visible engine upgrade | **Closest to Spore's interstellar-drive/range progression.** Our `drive` tiers already change reachable parsec distance; this is their visual expression. | Ship engine module, 4k faces; about 1.4 × 0.75 × 0.7 m. |
| `batch_01_props/freight-canister-v1.png` | Small physical cargo pods on the scout | **Visual support for Spore's ship cargo/hold.** Pod count must be a capped display derived from actual cargo, never a second inventory. | Cargo prop, 2k faces; about 0.65 × 0.42 × 0.42 m each. |
| `batch_01_props/surface-extractor-v1.png` | Placed resource-harvesting building on a planet | **Original extension of Spore colony resource/production play**, not an equipped ship tool. It should only appear where an actual colony or site has the corresponding installation. | Environment prop, 8k faces; about 3 × 2.5 × 2.5 m; ground contact at origin. |
| `batch_01_props/cultural-collectible-v1.png` | Scannable/recoverable alien object | **Echoes Spore's collectible artifacts and discovery**, but the object's acquisition, scarcity and journal entry are our design. It has no effect until a real collection command exists. | Small world prop, 3k faces; about 0.5 × 0.5 × 0.4 m; center pivot. |
| `batch_01_props/alien-civic-hall-v1.png` | Alien colony administration landmark | **Closest to Spore colony Town Hall/city buildings**, with a distinct Frontier Worlds civic silhouette. Not a ship tool. | Building prop, 12k faces; about 24 × 18 × 22 m; ground-level origin. |
| `reference_only/orbit-context-mock-v1.png` | Composition reference: planet, service vessel, scout | **Never upload.** This is a view mock, not a single object; Tripo would merge or reinterpret its contents. | No mesh. |
## Tripo batch recipe

1. Open **Generate Smart Mesh** in Tripo Studio, select **Triangle**, and use **Batch 3D Gen** / batch upload for separate objects. Tripo's Smart Mesh tutorial documents up to ten separate images per batch; its newer Batch-to-3D announcement says up to thirty in that workflow. This folder has nine eligible isolated objects, so it fits the documented ten-image Smart Mesh path. If the live Studio presents different controls, follow the live limit.
2. In the file picker, open `art/concepts/tripo_asset_pack_v1/batch_01_props/`, filter to PNG images, press **Ctrl+A**, then **Open**. That folder contains exactly the nine prop inputs. Do not use Multi-view for the folder: that mode is for several views of **one same object**, in front/left/back/right order.
3. Use the face targets in the table as starting caps, not guarantees. Enable texture/PBR; start at 1K–2K texture resolution for ordinary props and reserve higher resolution for the service vessel only if it is visibly useful in the game camera. Review the exact credit total before starting all nine jobs; a batch is still multiple generated models.
4. For each result, inspect the whole mesh from front, side, rear and underside; check whether openings and thin parts survived. Export **GLB** with embedded textures. Tripo and Godot recommend glTF/GLB for this runtime path.
5. Save each export under the matching filename in `assets/tripo_inbox/` (the folder and README are ready). Keep candidates local while we inspect them. After approval, promote station and ship modules to `assets/encounter/`, surface objects to `assets/world/`, and the civic hall to `assets/city/`; retain the approved PNG, exact prompt, settings, source/task ID and a brief import note. Do not use `art/tripo_ready/`.

The first proof should be the service vessel or Arc Lance module imported in the real orbit/ship view. Check scale, orientation, pivots, visible materials, draw calls, memory and packaged loading before making the rest production dependencies. Module hardpoints and projectile sockets remain separate authored transforms in Godot; do not bake firing logic into a generated mesh.

## Sources

- [Tripo Smart Mesh tutorial](https://www.tripo3d.ai/blog/smart-mesh-tutorial): batch inputs, file limits, topology, polygon controls and GLB export.
- [Tripo's newer Batch-to-3D workflow](https://www.tripo3d.ai/blog/tripo-image-gen-update): a separate workflow with up to thirty images.
- [Tripo generation docs](https://platform.tripo3d.ai/docs/generation): one object per image-to-model task and four views of one object for multi-view.
- [Godot supported 3D formats](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html): GLB/glTF import path.
- Local Spore grounding: `docs/research/SPORE_SPACE_STAGE_RESEARCH.md`, `docs/parity/reference_inventory.json` and `docs/parity/COVERAGE.md`.

Generated by OpenAI image generation on 24 September 2026. The project-local PNG copies are authoritative input files for this pack; originals remain in the Codex generated-image store.
