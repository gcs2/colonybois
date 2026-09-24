# Actual modeling proof: technical pass, art gate still open

> Review/evidence record; captures and prompts do not imply acceptance or a current production instruction. [Documentation map](../README.md).

24 September 2026. User requested a delegated demonstration of whether our endorsed character concept can become real 3D. One modeling subagent produced a separate Godot project; a second agent critiqued the reference and first rendered model. Main agent inspected the initial and revised three-quarter renders. No generated concept was substituted for an engine capture.

## Result

The prototype is an actual editable mesh assembly exported to GLB and reimported for its review captures. It resembles the broad creature direction but **does not achieve the mock's fidelity**. This proves a small asset generation/export/render loop. It does not prove that procedural authoring alone can produce the desired finished cast, or establish a production schedule.

The user has not accepted this model. The main game has not been modified to use it, and its running process was untouched. The existing contact-window direction remains endorsed; the character is a separate experiment.

## Evidence

- Endorsed direction: `art/concepts/characters/merchant-directions-20260924.png`, LEFT only for this model. RIGHT is a different endorsed direction; middle is too creepy.
- Editable source and isolated project: `art/prototypes/tavi/`.
- Generated real mesh: `art/prototypes/tavi/tavi_maquette.glb`.
- Actual engine captures: `art/prototypes/tavi/renders/front.png`, `three_quarter.png`, `side.png`, `rear.png`.
- Latest inspected captures: 1200×1200, Godot 4.7.2 Compatibility; rendered after GLB reimport. Output status reports successful export, reimport and all four image writes.
- Latest geometry: 51,156 triangles, 55 mesh nodes, 12 used materials. This is a prototype assembly, not optimized character draw-call structure.
- One 1024×1024 procedural color map is active. A generated normal-map experiment is disabled, not a production sculpt bake. No authored UV atlas, skeleton or animation.

Generated files are reproducible local output and ignored. Source, production brief and selectively endorsed reference sheet are intended for Git backup. The prototype must be rebuilt after a fresh checkout. No runtime benchmark has been performed; screenshot generation time is not evidence of game performance.

## Visual comparison

| Dimension | Result | What the actual image shows |
|---|---|---|
| Basic silhouette | Partial | Broad low mantle, lateral eyes, heavy torso, coiling limbs and flask are recognizable. Mantle still feels too much like a smooth cap. |
| Connected anatomy | Below target | Added throat volume closes the first pass's dark cavity. Fold strips, eye housings and several joins still read as assembled objects rather than continuous flesh. |
| Presence/personality | Partial | Body mass and held merchandise suggest the intended occupation. Static symmetric pose and fixed eyes do not yet convey his confident, experienced personality. |
| Materials/lighting | Below target | Softer second-pass lighting helps. Skin remains simple and plastic-looking; harness edges, suckers and eye rims lack the sculpted finish of the concept. |
| Portrait clarity | Partial | Major anatomy is legible. Small details cannot compensate for the face and material gaps. Full contact-window/native UI review is pending. |
| Technical exchange | Pass for prototype | A real GLB is created and reimported into the isolated current-renderer scene; main agent independently inspected GLB structure. |
| Animation and voice | Not tested | No rig, animation clips, lip synchronization or approved vocal performance. |
| Performance | Not tested | Geometry/material counts recorded; no frame-time or memory benchmark. |

The critic's top corrections were continuous throat/shoulder volume, a deeper mantle with a recessed beak and integrated eyestalks, and neutral rough materials under softer lighting. One bounded revision addressed those directions but did not finish them. Do not keep multiplying procedural details or new species to avoid the unresolved quality gap.

## What a modeler needs next

Use TAVI_MODEL_HANDOFF.md and this real dimensional blockout as the starting packet. First reshape the mantle, eye roots and underside as connected anatomy in a sculpting/modeling workflow. Settle limb roots and back anatomy. Review the same front/side/three-quarter views before spending on texture detail. Then build suitable deformation topology, UVs and intentional materials; rig eye aim and five purposeful acting clips. Test in the actual communications window.

An experienced character artist could work from this brief plus approved concept and iterate those choices. The current generator is useful for dimensions and pipeline tests, but it is not a substitute for that finishing work. Godot's ability to render a polished character and our ability to author one are separate questions. This experiment confirms the former pipeline is available and exposes the latter as an open production task.
