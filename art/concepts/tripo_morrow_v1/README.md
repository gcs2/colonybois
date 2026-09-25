# Morrow Tripo concept set v1

Six isolated source images for a first GPT-image-to-Tripo-to-Godot asset experiment. These are 2D concept candidates, not accepted art, generated 3D meshes, or proof that Tripo can reproduce the designs faithfully.

The primary visual reference is `artifacts/field-instruments-review/01-surface-populated-v3.png`. It was used for Morrow's chunky, hand-painted game look and palette. Individual foreground elements were regenerated as separate objects; nothing was cropped from the screenshot. The ore outcrop was the strongest first-pass object and retained its initial design. Plant, relay, scout ship and grazer were simplified after visual review.

## Images

| File | Intended in-game use | Current status |
|---|---|---|
| `survey-relay-v2.png` | Morrow surface survey landmark | Candidate; compact twin-spire field instrument |
| `morrow-scout-skiff-v2.png` | Player's small surface/expedition craft | Candidate; compact cream-and-terracotta scout skiff |
| `lantern-plant-v3.png` | Harvestable Morrow flora / lantern-gel source | Candidate; three stalks and three bulbs, simplified form |
| `basalt-lantern-ore-v1.png` | Harvestable mineral deposit | Candidate; retained from the first pass |
| `lantern-grazer-v2.png` | Small ambient non-sapient Morrow fauna | Candidate; simple orange pod grazer |
| `portable-repair-case-v1.png` | Portable repair inventory item | Candidate; based on the separate field-supplies board |

The five Morrow surface images are 1254×1254. The repair case is 1536×1024. Relay and scout skiff are transparent PNGs; the other four use a solid warm-gray studio background. Those are separate generation outputs, not post-processed crops.

## Tripo handoff

Start with **one** image-to-model pilot, preferably `morrow-scout-skiff-v2.png` because the ship is the player-facing asset and the art contract calls for a scout-ship pilot. Keep the image isolated and unedited. Inspect the full result from front, side, rear and above before deciding whether a second concept view is needed. Export GLB only after checking model geometry, texture, scale, pivot, transparency and underside. Then inspect it in Godot under actual Morrow lighting and at gameplay camera distance.

No Tripo upload or purchase is recorded here. The project art contract requires a confirmed per-pilot price and applicable license before a paid submission. Generated source images are preserved in the default Codex image-generation folder as well as copied here for project use.

Full generation prompts and source provenance are in [`PROMPTS.md`](PROMPTS.md). Original imagegen outputs are retained under `C:\Users\zephy\.codex\generated_images\01a0c79d-5b12-7440-bffd-6ce98d166941` with output IDs recorded in that file.
