# Kiteback scout: authored model candidate

23 September 2026. Replaces the earlier primitive scout in personal surface and orbital flight. This is an integrated art candidate, not player-approved final art or a first-person cockpit.

## Design and source

[Dimensioned specification](../art/specs/scout_v2.json) → [authored geometry](../tools/AuthorScout.gd) → [GLB](../assets/encounter/scout.glb) → [flight motion](../scripts/scout_motion.gd). The model uses longitudinal cross-section meshes for layered shell plates, hooked side shields, an inset visor and a dark structural chassis. Matte pale ceramic and terracotta markings replace the old copper collars. Rear engines have attached housings and nozzle throats; the belly has a separate survey aperture.

The compiled model has **5,432 triangles, 14 mesh instances and six shared materials**. Batching preserves every input triangle and validates the 12,000-triangle/20-instance cap. Mixed indexed and non-indexed parts are normalized before merging so primitive collars cannot suppress authored hull surfaces. No runtime geometry generation or downloaded asset is required. This original source can be revised and re-exported; it is not generated raster concept art masquerading as a mesh.

Rebuild with the pinned Godot executable and `--headless --path . --script tools/AuthorScout.gd`, then import with `--headless --path . --editor --import --quit`. The older bulk encounter author skips the scout so it cannot overwrite this model with v1.

## Motion and effects

Two named shield pivots respond to actual velocity with damped thrust/steering trim, settle at rest and freeze during pause or inspection. Existing hull banking and pitch remain. Four exported attachment points bind port/starboard exhaust, the survey beam and weapon muzzle to the transformed ship. Collection/deployment particles use the belly aperture. The existing 184-particle cap is unchanged.

The integration exposed an older beam-transform defect: world-axis scaling shortened angled beams. Weapon, surface-tool and salvage tethers now scale their local longitudinal axis and meet both endpoints. Gameplay reach, damage, energy, economy and save data are unaffected by the cosmetic model.

## Evidence and remaining gates

- `tests/test_scout.gd`: 13 checks cover imported mesh budgets/sockets, rotated exhaust, bounded motion, pause/settling without state mutation, real surface tool commands and exact angled weapon endpoints.
- Full regression suite: 860 assertions plus UI checks passed; the final geometry batching correction also passed the scout integration checks and author-side triangle preservation validation.
- `tests/review_scout.gd` renders the actual imported mesh from front, rear, top, side and underside, plus surface/orbit flight at 14, 29 and 95 metres. Captures are 1920×1080 under the Compatibility renderer, stored in ignored `artifacts/scout_*.png`.
- Visual review caught and corrected missing batched geometry and disconnected nozzle housings. These captures establish asset integration and readable silhouette, not native input or player art approval.

Surface detail, material richness, close-up cockpit content and final visual direction remain open. Existing planet/terrain, HUD and sound rejection also remains open. Do not widen a ship catalog around this candidate before its design is reviewed; continue the full feature inventory and connected space-adventure systems instead of indefinite scout reskins.
