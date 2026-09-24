# Tavi V2: connected implicit sculpt proof

This is a separate second modeling experiment. V1 remains unchanged in `../tavi/`. Both use the approved **left** direction in `../../concepts/characters/merchant-directions-20260924.png`; the newly generated eight-philosophy cast is not a replacement reference. This asset is not assigned a philosophy.

**Status: deferred unfinished prototype at the user's request.** Do not continue character production automatically. This checkpoint preserves the experiment for later comparison; it is not art approval or a decision to build a creature creator.

The substantive change is anatomical construction: mantle, lateral eyestalk roots, neck, shoulders, belly and tentacles now form **one connected mesh surface**, produced from smooth-union signed distances. V1 rendered these as overlapping primitives. Separate eyes, beak, harness and sample vial remain editable meshes.

## Source and operation

- `sculpt_mesh.py`: original NumPy sculpt definition, marching-tetrahedra triangulation, smooth gradient normals, continuous vertex pigment, topology measurements and GLB writer. No image generation, outside model or downloaded dependency was used. Python with NumPy is sufficient.
- `build_maquette.gd`: imports the sculpt, adds eye/merchant detail, exports the complete GLB, reimports it and renders it in Godot 4.7.2 Compatibility. It also supplies the optional orbit inspector.
- `connected_anatomy.glb`: generated high-resolution anatomy alone.
- `tavi_v2_maquette.glb`: generated combined character proof.
- `sculpt_stats.json` and `model_stats.json`: measured geometry, topology and export/import results. These are ignored generated outputs.
- `renders/{front,three_quarter,side,rear}.png`: actual 1200×1200 captures of the reimported complete GLB using the same lighting/cameras as V1. They are not imagegen renders.

Double-click **`Inspect.cmd`** on the development PC to regenerate and inspect. The sculpt takes approximately 35 seconds on the development machine; this is generation time, not a frame-time benchmark. Drag to rotate, scroll to zoom, R to reset, Escape to close. The script uses the existing bundled Python and pinned Godot; it downloads nothing. It does not launch or alter the main game. Interactive input is implemented but has not received a manual playtest.

For automatic capture, from the repository root:

```powershell
& 'C:/Users/zephy/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' art/prototypes/tavi_v2/sculpt_mesh.py
& .tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path art/prototypes/tavi_v2 --editor --import --quit
& .tools/godot/Godot_v4.7.2-stable_win64.exe --path art/prototypes/tavi_v2 --audio-driver Dummy
```

The last command captures all four views and exits. Add `-- --inspect` to remain in the live inspector instead.

## What this proves, and what it does not

The visual joins are materially improved: one surface connects the broad mantle to its eyes, throat, shoulders and curled limbs. Export/reimport works. **This still does not match the approved concept closely enough to pass the fidelity gate.** Shape language, facial folds, controlled asymmetry, believable skin, harness fabrication and character performance remain unfinished. This is a high-resolution sculpt-like proxy, not a runtime triangle budget or a finished production mesh.

The continuous pigment uses GLB `COLOR_0`, not UV maps. Godot's runtime GLB reimport retained the color attribute but did not enable `vertex_color_use_as_albedo` on the returned material in this test. The review script explicitly reapplies that material flag after import. Any standalone Godot use must preserve that setup; otherwise the skin displays white. No normal/roughness maps, sculpt bake, finished UV atlas, retopology, skeleton, skinning, blend shapes, animation or LODs exist.

Automatic topology measurements distinguish one connected component from merely one mesh node. Consult `sculpt_stats.json` for boundary/nonmanifold edges before treating the mesh as watertight. The mesh is not approved for rigging or fabrication. The separate detail parts and materials also need consolidation.

Final measured snapshot: anatomy **325,816 triangles / 162,886 vertices**, **one connected component**, **zero boundary edges**, **zero nonmanifold edges**, and no unused vertices. Combined exported character: **340,980 triangles / 171,635 vertices**, **32 mesh nodes**, **9 materials**. Both GLB export and reimport returned error code **0**, and all four native captures completed. This density is a sculpt-like experiment, not a shipping mesh budget; topology measurements do not constitute a rigging or performance pass.

Next artistic step: directed sculpting of the overhanging rim, beak cavity, distinct throat folds and eye sockets against the fixed reference, followed by proper retopology/material authoring and one acted greeting. Do not mass-produce characters from this experiment or use its triangle count as evidence of quality.

Source is tracked; generated meshes, renders, logs, stats and import caches are ignored. The parent `.gdignore` keeps this isolated project out of the main game's import. Sandbox shader-cache and certificate-store warnings did not prevent native rendering or GLB export/import.
