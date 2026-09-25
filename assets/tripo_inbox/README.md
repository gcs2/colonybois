# Tripo model drop-off and import review

## Where to put the downloads

Save each Tripo export directly in this folder:

`C:\Users\zephy\Documents\ChatGPT\New project\assets\tripo_inbox\`

Use **GLB** with textures embedded. Keep the files flat in this folder for now. They can be imported into the isolated Godot review gallery, but do not attach them to gameplay scenes or move them into runtime folders until their art, scale, pivots, mesh cost, and gameplay-distance appearance are approved. This inbox is ignored by Git for model binaries, so experimental downloads will not be committed by accident. Keep this README and any later approval notes tracked.

## Suggested filenames for the gallery models

Rename files to these descriptive names when downloading. If a model is a second generation or alternate, use `-candidate-b`, `-candidate-c`, and so on. Leave out the dragon, as requested.

| Gallery item | Suggested inbox filename | Intended role | After review |
|---|---|---|---|
| Human woman in a space suit | `vanguard-human-candidate-a.glb` | Character-model experiment | Review-only. Character modeling is deferred; do not add to the playable cast or story without reopening that art decision. |
| Alien capitol / civic building | `alien-civic-hall-v1.glb` | Colony landmark | Candidate for a future city-asset folder; no approved runtime destination exists yet. |
| Rectangular cargo pod | `freight-canister-v1.glb` | Visible ship cargo | `assets/encounter/` after scale, attachment and inventory-display review. |
| Small scout ship | `scout-ship-candidate-a.glb` | Player ship / ship variant | Compare against the current `assets/encounter/scout.glb`; do not replace it until the in-game comparison is approved. |
| Circular ship subsystem | `ship-subsystem-candidate-a.glb` | Unidentified drive, shield or utility module | Identify its function from the Tripo project/concept before assigning a final name; likely `assets/encounter/`. |
| Box-shaped mounted subsystem | `ship-hardpoint-candidate-a.glb` | Weapon or tool hardpoint module | Confirm whether it is the Arc Lance or another module before naming/integration; likely `assets/encounter/`. |
| Large orbital service vessel / station | `orbital-service-vessel-v1.glb` | Physical docking and service location | `assets/encounter/` after size, approach-view and performance review. |
| Exposed mineral outcrop | `mineral-outcrop-candidate-a.glb` | Visible surface resource deposit | Candidate for a future planet-world asset folder; preserve resource identity in its asset record. |
| Survey relay, first generation | `survey-relay-candidate-a.glb` | Planetary or orbital survey landmark | Compare with the existing `assets/encounter/relay.glb`; choose one only after gameplay-distance review. |
| Survey relay, second generation | `survey-relay-candidate-b.glb` | Alternate relay generation | Keep as a separate candidate until compared; do not import both as duplicates by default. |
| Armored humanoid in dark suit | `armored-character-candidate-a.glb` | Character-model experiment | Review-only. Character modeling is deferred; no cast integration is authorized by this inbox. |

## Godot import pilot — 25 September 2026

Four local Tripo exports have been copied into the isolated visual-review worktree and loaded in Godot 4.7.2. The 1080p comparison capture is `artifacts/visual-critic-surface-pass/tripo-inbox-gallery-1080.png` in that worktree. The models render with their embedded materials; Godot's GLB scene importer has automatic mesh LOD generation enabled. The gallery normalizes each candidate for close-up readability, so it does **not** establish relative gameplay scale.

To reproduce the review gallery, place local copies of the four GLBs in this worktree using the matching filenames `tripo-gemstone-outcrop-candidate.glb`, `tripo-lantern-flora-candidate.glb`, `tripo-freight-canister-candidate.glb`, and `tripo-scout-ship-candidate.glb`, then run `Godot_v4.7.2-stable_win64_console.exe --path . --script tools/CaptureTripoInbox.gd`. The binary candidates are deliberately ignored by Git. Godot's [mesh LOD guide](https://docs.godotengine.org/en/4.7/tutorials/3d/mesh_lod.html) confirms automatic LOD generation for imported glTF scenes; enabling LOD does not make these sources automatically suitable for repeated close-range use.

| Inbox export | Review label | Source bounds (GLB units) | Source triangles | Approx. file size | Review status |
|---|---|---:|---:|---:|---|
| `gemstone rock pile 3d model.glb` | Gemstone outcrop | 0.98 × 0.61 × 0.94 | 1,962,835 | 64.2 MiB | Strong mineral seams; retain only after reducing geometry and checking readability at flight distance. |
| `glowing crystal plant 3d model.glb` | Lantern flora | 0.70 × 0.98 × 0.45 | 1,994,788 | 61.8 MiB | Clear three-bulb silhouette; tame the near-white bulbs and verify ground contact. |
| `futuristic container 3d model.glb` | Freight canister | 0.98 × 0.50 × 0.44 | 1,932,671 | 62.5 MiB | Best first optimization pilot; set actual pod dimensions and inspect its underside/attachment point. |
| `spacecraft 3d model.glb` | Scout ship candidate | 0.83 × 0.43 × 0.98 | 1,950,226 | 62.8 MiB | Promising palette; inspect top, side, rear, underside, forward axis, and engine sockets before any comparison with the current scout. |

The approximate source triangle and file-size figures are not runtime frame-time or GPU-memory measurements. These four local copies remain review-only and are not committed or considered approved game assets. The comparison follows the existing Spore-grounded roles: visible resources and collectable life extend planet discovery/mining; the canister visualizes carried cargo; the ship is a candidate player-ship presentation. It does not add new mechanics or inventory.

If the Tripo gallery uses different names, use the suggested filename based on what the model actually depicts. Keep the dragon out of the inbox.

## Before anything moves into the game

For each candidate, record its Tripo task/project name, source concept, model settings and export date. Inspect front, back, sides, underside, scale, pivot, material/texture quality, thin parts and triangle count. Then test it in the intended live camera at both normal and close gameplay distances and in an exported build. A normalized gallery proves only that Godot can import and render the GLB; it does not approve gameplay integration or performance.

Only approved ship and orbital models belong in the existing `assets/encounter/` runtime folder. Creature/specimen concepts currently live in `assets/specimens/`; that does not make the humanoid character experiments approved. The project does not yet have final runtime folders for civic buildings or mineral world props. Keep those candidates here until we create and test the right integration path.

Do not use the rejected `art/tripo_ready/` folder. Do not put account credentials or private tokens here.
