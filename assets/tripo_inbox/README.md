# Tripo model drop-off

## Where to put the downloads

Save each Tripo export directly in this folder:

`C:\Users\zephy\Documents\ChatGPT\New project\assets\tripo_inbox\`

Use **GLB** with textures embedded. Keep the files flat in this folder for now; do not import them into Godot scenes or move them into runtime folders yet. This inbox is ignored by Git for model binaries, so experimental downloads will not be committed by accident. Keep this README and any later approval notes tracked.

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

If the Tripo gallery uses different names, use the suggested filename based on what the model actually depicts. Keep the dragon out of the inbox.

## Before anything moves into the game

For each candidate, record its Tripo task/project name, source concept, model settings and export date. Inspect front, back, sides, underside, scale, pivot, material/texture quality, thin parts and triangle count. Then test it in the intended live camera at both normal and close gameplay distances and in an exported build.

Only approved ship and orbital models belong in the existing `assets/encounter/` runtime folder. Creature/specimen concepts currently live in `assets/specimens/`; that does not make the humanoid character experiments approved. The project does not yet have final runtime folders for civic buildings or mineral world props. Keep those candidates here until we create and test the right integration path.

Do not use the rejected `art/tripo_ready/` folder. Do not put account credentials or private tokens here.
