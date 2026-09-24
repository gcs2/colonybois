# Character modeling postmortem

24 September 2026. **Outcome: the concept-to-game-character fidelity experiment failed its art gate.** Character production is deferred at the user's request. This review does not restart it or lower the desired quality.

## What we owed the player

Demonstrate that the endorsed creepy-cute merchant concept could become a convincing, expressive 3D game character. The model needed the reference's distinctive anatomy, mass, appealing strangeness and material finish, with a credible route to performance in the contact window. The user's later “95%” expressed a desire for a very close match; it was not a measurable score we had earned.

We supplied two real, reproducible mesh experiments, but neither met that visual promise. I was responsible for matching the method and the claims to the actual result. The user should not have had to repeatedly explain that a technically valid mesh was insufficient.

## Evidence and sequence

The comparison uses the [endorsed source sheet](../../art/concepts/characters/merchant-directions-20260924.png), specifically the left creature, and actual three-quarter engine captures from each isolated prototype. I inspected all three again for this postmortem. The earlier [fidelity review](TAVI_FIDELITY_REVIEW.md) contains the multi-view observations. Counts below come from local `model_stats.json` outputs; reproducible sources and commands are in the prototype READMEs. Generated renders and GLBs are ignored local outputs, not off-device asset backups.

| Stage | Delivered evidence | What it established | What it did not establish |
|---|---|---|---|
| Concept / handoff | Selected left/right visual directions; merchant brief | An appealing target and some constraints | Consistent hidden anatomy, production-ready turnarounds or a proven schedule |
| [V1](../../art/prototypes/tavi/README.md) | GLB export/reimport; four 1200×1200 engine views; 51,156 triangles, 55 mesh nodes, 12 materials | A real editable mesh pipeline in Godot Compatibility | Integrated anatomy, finished materials or convincing character presence |
| [V2](../../art/prototypes/tavi_v2/README.md) | Connected implicit anatomy; GLB round trip and four views; 340,980 triangles, 32 mesh nodes, 9 materials | Improved surface continuity and repeatable generation | The reference's form language, deformation topology, rig, animation, runtime budget or acceptance |
| Further concept branches | Philosophy cast, animal diversity, style options and fish/orb revisions | Additional proposals and explicit rejection feedback | Improvement to the actual merchant model or a finished cast |
| Stop | User deferred characters and asked to move on | Clear change of priority | Permission to continue “one more” art pass |

V2 has about **6.7 times V1's triangle count**. That is an observed geometry ratio, not a measured performance cost or fidelity score. Neither model was integrated into the game, rigged, animated, benchmarked in gameplay or accepted by the user.

## Failure analysis — separate ownership of causes

| Cause | Observation | Why it mattered | Correction |
|---|---|---|---|
| Expectation setting | The conversation implied a close concept match before an end-to-end asset had passed review. Technical success remained prominent despite poor art. | The promise exceeded demonstrated capability and made later caveats feel like retreat. | Promise a bounded experiment and its evidence, not a fidelity percentage or a finished-cast schedule. |
| Design specification | One appealing image left underside, back, articulation and exact form transitions unresolved. | Invented geometry drifted from the qualities the user actually liked. | Lock the visible silhouette and anatomy landmarks; resolve uncertain views before detail work. Mark extrapolations as proposals. |
| Shape authoring | V1 assembled primitives; V2 smoothed implicit volumes. V1's cap, eye rims and folds looked separate. V2 lost the rolled mantle edge, structured folds and differentiated underside. | Connectivity solved a mesh property; it did not solve deliberate anatomical design. | Review neutral shape renders first. If the authoring method cannot produce the required forms, change the method or stop the experiment. |
| Materials and performance | Generic spots, simple surfaces, coarse accessories, fixed pose and eyes remained. No rig or acting was tested. | Texture noise could not supply tactile skin, believable fittings or the merchant's confidence. | Approve forms, then purposeful material treatment, then a small acted greeting in the real UI. These are separate gates. |
| Iteration and scope control | More detail, more species and more concept variants appeared before the first asset was proven. Art generation also continued while the reuse/customization question needed an answer. | Output volume displaced the unresolved quality and decision problems. | One character, one uncertainty per revision, a bounded attempt count and a stop condition agreed before restarting. Answer scope questions before producing more art. |
| Acceptance and documentation | Latest corrections competed with old instructions. The fish record still prescribed a goldfish and profile view after the user rejected both. | A rejection could be accidentally reused as an instruction; repeated misses damaged trust. | One current constraint record, explicit rejected status, historical prompts retained only as evidence; no stale task remains active. |

The fish was a separate concept failure, not proof of a 3D renderer limitation. Its final constraints were: a plain **non-goldfish**, facing the viewer in the established character style, in a plain round orb without tools; roughly **half the previous fish height**, superseding the earlier volume request. The possible powerful/final-boss role remained an idea. No candidate earned acceptance.

## Impact and useful work retained

The main cost was trust and attention: an exciting character discussion became frustrating, while the core game did not improve. We do not have a reliable labor-time ledger for this detour, so this postmortem does not invent hours or a monetary loss.

Useful retained work includes original reference directions, the character intention, isolated editable sources, a verified GLB round trip, measured geometry, actual engine captures and concrete negative findings. Keeping the prototypes separate protected the playable project. Independent criticism identified shortcomings, but we did not use those findings early enough to stop the ineffective approach.

This experiment **does not show that Godot caused the quality gap**. It shows that our demonstrated authoring process did not deliver the desired asset. A higher reasoning setting, more polygons or another raster concept does not by itself supply sculpting, topology, material art or acting.

## Changes now and conditions for any later retry

| Responsibility | Action / gate | State |
|---|---|---|
| Production direction | Stop character generation, modeling and corpus expansion; keep the overall space game moving. | Applied in the task board and handoff. |
| Documentation | Separate direction, delivery, system checkpoints, art specs, external research, internal reviews and history; register every file once. | Applied in the [documentation map](../README.md); structural validation is available. |
| Artifact provenance | Preserve V1/V2 source and approved reference; keep failed renders out of the shipped game and routine Git assets. | Existing prototype boundaries retained. |
| Future art lead / agent | First propose a method capable of deliberate form editing: directed modeling/sculpting, or an assessed external base followed by cleanup. No automatic tool purchase or engine change. | Deferred; no method yet demonstrated at the requested fidelity. |
| Future reviewer | Evaluate matched front/side/three-quarter views at portrait size: silhouette, anatomy, appeal, materials, acting, integration and runtime cost separately. User acceptance remains explicit. | Required before any cast expansion. |

If reopened, the first deliverable should be **one convincing neutral shape study**, not eight characters. A failed shape gate stops materials and corpus work. A finished static model must then pass an actual greeting/response sequence in the contact window before it can serve as a reusable production example. Reuse of source tools or compatible rigs does not require a player-facing creature creator; a preset selector remains a later option.

The quality ambition remains. The corrective change is to demand evidence before promising that we can reproduce it.
