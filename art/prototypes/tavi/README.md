# Tavi: actual 3D maquette, not final character art

This isolated Godot 4.7.2 project demonstrates the **editable mesh → GLB export → GLB reimport → native rendering** loop. It is an intentionally bounded anatomical blockout. It does **not** demonstrate the concept's final modeling/material fidelity, acting, animation or a production-ready game asset.

Reference: the **left** creature in [`../../concepts/characters/merchant-directions-20260924.png`](../../concepts/characters/merchant-directions-20260924.png). The first and third directions are liked; the central radial face is not used. The handoff/spec is [`../../../docs/TAVI_MODEL_HANDOFF.md`](../../../docs/TAVI_MODEL_HANDOFF.md). This merchant has no assigned Spore philosophy. The supplied image is concept art; the images generated here are actual rasterized mesh renders.

## Source and regeneration

- `build_maquette.gd`: all anatomy, prop geometry, material parameters, lighting, cameras, GLB export/reimport and optional orbit review. Named mesh parts are individually editable. Character front is +Z, up is +Y, dimensions are in metres. The implied full anatomy outside this bust is unapproved.
- `skin_texture.py`: deterministic, original 1024×1024 procedural color map and an unused normal-map experiment. The skin has generated UV coordinates; there is no production UV atlas, sculpt bake or authored roughness map.
- `project.godot`, `review.tscn`: standalone review only. The parent `.gdignore` prevents the main game from importing this separate project.
- `tavi_maquette.glb`: generated mesh asset with embedded color texture; importable by Godot or a DCC supporting glTF.
- `renders/front.png`, `three_quarter.png`, `side.png`, `rear.png`: 1200×1200 actual Godot Compatibility captures of the **reimported GLB**, with identical mesh/materials and changing camera.
- `model_stats.json`: measured source mesh/material counts and GLB round-trip error codes.

From repository root in PowerShell (use another Python with Pillow + NumPy if needed):

```powershell
& 'C:/Users/zephy/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' art/prototypes/tavi/skin_texture.py
& .tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path art/prototypes/tavi --editor --import --quit
& .tools/godot/Godot_v4.7.2-stable_win64.exe --path art/prototypes/tavi --audio-driver Dummy
```

The final command opens the isolated renderer, captures four views, then exits. It does not launch, replace or modify a running game. First-time Godot import is required after making the texture PNGs. Generated GLB, maps, renders, logs and stats are ignored by Git and reproducible from these sources. Reimport may additionally extract embedded images as `tavi_maquette_*.png`; those are generated outputs too.

For a live actual 3D inspection, after generation/import:

On the development PC, double-click **`Inspect.cmd`** to regenerate/import and open this separate inspector. The launcher expects the already-installed pinned Godot and bundled Python paths; it downloads nothing. Alternatively:

```powershell
& .tools/godot/Godot_v4.7.2-stable_win64.exe --path art/prototypes/tavi --audio-driver Dummy -- --inspect
```

Drag with the left mouse button to orbit, scroll to zoom, R to reset, Escape to close. This mode rebuilds and reimports the model before review. No UI/game integration is implied. Interactive input is provided but has not been manually playtested.

## Observed result and remaining work

The final proof exported and reimported with Godot error code **0**. Native rendering produced all four views. Measured geometry: **51,156 triangles, 27,979 vertices, 55 mesh nodes, 12 materials**. One embedded color texture is active; the generated normal-map experiment is disabled. No skeleton, skin weights, blend shapes, animation clips or LODs exist.

The broadly recognizable mantle, eyestalks, beak, heavy body and tentacles are dimensional. The proof still falls substantially short of the concept: anatomical joins are intersecting pieces, eyes and folds need sculpted integration, material detail is generic and low contrast, harness fittings are blocky, and lighting/pose lack finished character appeal. The included side and rear views expose those limitations. Fifty-five mesh nodes and twelve materials also require consolidation before production use. Neither triangle count nor a successful export constitutes art approval or a frame-time benchmark.

Next useful step: deliberate sculpt/model editing of the connected mantle–throat–shoulder anatomy, then retopology, purposeful UV/material work, and a small face/tentacle rig with one acted greeting. Do not batch-produce characters from this primitive assembly or claim the generated concept fidelity has been achieved.

Sandbox rendering logged unavailable user shader-cache/certificate-store warnings; captures and GLB round trip still completed. No network content or downloaded tool was used. This test used the already-installed Godot Compatibility renderer; it is not an engine migration.
