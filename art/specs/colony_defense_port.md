# Colony orbital port: defense pilot asset

Original modular candidate for the shared service-tender position. This is an orbital installation, not a new colony population or a building editor.

- Silhouette: squat central hull, two swept docking arms, paired cargo blisters and an elevated sensor eye. Leave the existing approach ring readable below it.
- Dimensions: approximately 9 × 4 × 7 local metres; hull offset 2 m above the service position. Keep the ship's docking/approach coordinates unchanged.
- Materials: matte desaturated blue-green armor, dark recesses, warm ivory cargo, pale navigation lights. No shiny copper trim.
- Functional sockets: center hull for incoming bombardment; port-side barrel/eye for outgoing defense beams. Both use the same persistent raid damage and finite battery state.
- States: intact; damaged armor with darkened lights; disabled with red navigation warning; commissioned battery with visible paired emitters. These states derive from actual port integrity and battery ownership.
- Construction: reuse `hostile_vessel.gd`'s low-segment modular mesh helpers; at most eleven bounded mesh parts, one per visible colony. No rigid-body wrecks or uncapped particles.
- Verification: inspect next to the real service approach and raid actor at normal orbit camera distance, at 1080p and 1440p. This is a reusable mesh candidate, not approved final art or a substituted screenshot concept.
