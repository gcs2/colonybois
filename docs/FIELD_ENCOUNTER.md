# Morrow Basin: first personal ship encounter

Checkpoint: 2026-09-23. This is a playable, isolated interaction prototype, not the completed space game or approved final art. Names and ecological details are provisional. Existing colony/galaxy sessions remain intact.

## Play

Open `Play.cmd` and choose **NEW · Morrow Basin — fly, sample, grow** at the top of the menu. The field resumes its own autosave. Return saves field progress and restores the original session exactly; its strategic simulation is suspended during this isolated experiment. The field is not yet a destination in the galaxy.

WASD moves the scout relative to the camera. Q/E lowers/raises altitude. Right-drag orbits and tilts; wheel zooms. Click a subject or press Tab to cycle subjects. Keys 1–4 select Scan, Collect, Warm and Seed. Hold F to operate, release to cancel; the **Operate** button also starts/cancels a timed action. Completed actions require another press, preventing accidental repeated collection. Space pauses. Losing focus pauses and cancels tool use; press Space to resume. Escape closes contact/journal. F5 makes a manual save, F9 restores it.

1. Approach and scan the lantern pods, then collect a seed. Scan a floating grazer to learn about its feeding reserve.
2. Select and scan the pale mineral bed. Warm it for 25 ship energy, then deploy the seed. Tools require range of 13 meters and completion of a short operation.
3. Watch the canopy grow over 20 simulation seconds. The relay responds with light. The encounter establishes no canonical explanation of the relay or ancestors.
4. A mature bed produces one cultivated pod every 12 simulation seconds, storing up to eight. Contact Vell to sell a pod for 18 Marks or agree recurring deliveries. This local nursery wants six pods total; automatic deliveries retain one local pod and stop after fulfilling the order.
5. Inspect the journal, save, leave and revisit. Ecology, inventory, order progress, Marks, history and ship position persist.

The visible wild plants shrink as samples are taken; the last native pod is protected. This is a bounded ecological constraint, not a full simulated food web. The user endorsed the initial asset direction, then requested more lifelike animation and a larger interconnected species catalog.

The animation pass gives each grazer independent blinking/gaze, fin hinges, a breathing bell, flexible trailing tendrils and foraging/curious/startled visual states. Close approach and collecting/warming tools cause retreat; scans encourage curiosity; animals settle after a disturbance. Movement is smoothly bounded. Three visible creatures use a small procedural pose hierarchy and GPU tendril deformation; they do not run a population simulation. The GLB retains named articulation groups, but does not contain a skinned skeleton or baked animation clips. Future walking/climbing species will need proper joint rigs and contact-aware motion. Fins/stems/tendrils are double-sided thin surfaces in this candidate kit. The environment now has a gradient sky and moving water highlights.

## State and scope

`scripts/encounter_state.gd` owns validated tool commands, finite stock, growth, production, buyer demand and history. One-second ticks are independent of the render rate. Tools commit only at completion after checking range and prerequisites again. Contact is available from anywhere within this small encounter. There is no route graph, freighter simulation, freight cost or persistent alien faction relationship in this local trial.

`scripts/encounter.gd` owns movement, camera, picking, operation feedback, procedural terrain, bounded ambient creatures and UI. Movement uses fixed physics updates, a terrain-clearance limit, basin boundary and relay exclusion radius. This is an assisted surface survey craft, not the planned first-person space combat flight model.

Separate saves: `field_encounter.json` (manual) and `field_encounter_auto.json` (every 30 simulation seconds and on normal exit), under Godot's Frontier Worlds user directory. Startup prefers the autosave; F9 explicitly restores the manual file. No offline progress. Review mode uses `review_` filenames; script tests use ignored `artifacts/` files. Save schema 1 rejects missing/invalid fields without replacing live state. Save writes currently replace the individual target file; crash-proof journaled persistence remains a hardening task.

Vell reuses the existing original finance advisor portrait as a provisional nursery liaison. This does not implement the future animated interspecies diplomacy screen. Synthesized tool sounds, confirmation/error cues and a mute button are included; no music, recorded performances or ambient audio mix yet.

## Spec-to-mesh pilot

Source brief: `data/encounter_art.json`. Rebuild source: `tools/AuthorEncounter.gd`. Four original candidates export to `assets/encounter/`: scout, lantern pod, bell grazer and relay. The versioned source combines deliberately chosen profiles, ellipsoids and curved tubes, then merges static parts by material for export to GLB. Palette comes from the spec; profile coordinates remain authored in the generator. No third-party model download, automatic image-to-3D claim or Blender source is implied.

This is a small reproducible code-to-GLB branch of the art pipeline. It has not passed concept approval, close-view modeling/material refinement or human art review. The larger concept → DCC refinement → export loop is still required for production assets. Generated concept images and a cockpit were not produced in this checkpoint.

Rebuild candidates:

```powershell
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/AuthorEncounter.gd
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import --quit
```

Rendered review:

```powershell
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . res://scenes/encounter.tscn -- --field-capture
```

This writes four disposable actual-engine captures under `artifacts/field_0.png` through `field_3.png`, then exits. The capture sequence stages before/after ecology using real model commands; it is not a manual playthrough. Captures and runtime/build output stay out of Git.

## Verification and remaining gates

46 encounter assertions cover invalid/out-of-range commands, partial operation cancellation, exactly-once tool completion, seed conservation, protected native reserve, thermal cost, growth, finite deliveries, storage bounds, deterministic continuation, malformed saves, picking, button operation, visible ecology, contact/journal and return to the exact suspended campaign. Eight of these check exported articulation nodes, curiosity, startle/curl, recovery, movement bounds, independent materials, blinking and zero-time updates. The previous 178 simulation assertions and UI checks also pass.

`tools/CaptureFauna.gd` renders 120 actual-engine frames of curiosity followed by a thermal-tool startle under `artifacts/fauna_motion/`. The optional local `artifacts/bell-grazer-motion.gif` assembles those frames for review; it is not a generated concept animation. Camera tracking in that motion study is staged for readability. The character's actual behavior controller drives the poses.

Rendered checks caught and corrected ground winding, thin-mesh culling, excessive unmerged surfaces and a cropped advisor portrait. A short RTX 5070 Ti Laptop/OpenGL sample at the 60 FPS cap reported p50/p95 frame intervals of 16.67 ms; the final close-view sample reported 513 draw calls and 293,684 primitives. These are frame intervals including the cap, not isolated GPU cost or a clean hardware benchmark. Background workload was uncontrolled; no minimum-spec claim.

Native computer-use window access timed out before input could be sent. Automated picking and operation checks do not establish that movement feels good or that the scene is attractive/fun. Next: a real player completes the encounter, tries cancellation and orbit/zoom, identifies the ecological relationship without coaching, and chooses whether to revisit or automate. Fix that feedback before adding worlds, fleet combat or a large tool catalog.
