# Frontier Worlds: production plan for a polished city-and-space game

**Priority superseded by the space-first pivot:** retain the production loop and quality gates, but use [SPACE_FIRST_DIRECTION.md](SPACE_FIRST_DIRECTION.md) for the next pilot: a distinctive expedition environment and an authored scout ship. HAB-01 and the municipal kit below are deferred. First-person flight means ships and navigable environments need real 3D sources; a fixed-angle city treatment remains optional. See [FLIGHT_TECH_ASSESSMENT.md](FLIGHT_TECH_ASSESSMENT.md).

This is the forward production plan, not a claim that the current build meets the target. Art is a core deliverable. The immediate priority is one coherent, attractive, playable city block built from authored 3D assets. Do not expand factions, battles or procedural plot volume to conceal presentation problems.

## 1. What the finished slice should feel like

A player opens a modern alien city, understands its street hierarchy and scale, recognizes its unusual inhabitants through buildings and institutions, and enjoys moving the camera before touching a tool. They drag zoning, see credible lots develop over time, read why growth stalls, extend a useful transport connection, and watch that investment change the city. Advisors make problems understandable without drowning the player in text. The result should be appealing at city, neighborhood and building distances.

The art direction is creepy-cute civic science fiction: approachable shapes, expressive biological strangeness, thoughtful urban order. It is not a ruined settlement, military space opera, generic Earth city or a field of identical pods. Latch has history: older shell-brick terraces, municipal improvements, merchant additions and imperfect repairs. Architectural variation should express development and use, not random deformation.

Keep existing narrative commitments: the forgotten outpost, fallible ancestors, morally varied alien societies, national rivalry on a shared planet, the Vanguard and later living interstellar politics. Do not put an ancient ruin on every corner of a functioning modern city. Marks has municipal ledger origins; currency and civic symbols belong consistently on signs and UI once their designs are approved.

## 2. A visual language we can manufacture

Three connected shape families:

- Domestic: shell-like roof lips, recessed entrances sized for varied bodies, warm ceramic walls, shared courtyard gardens and useful terraces. Buildings still meet streets and form blocks.
- Civic and commercial: broader shaded entrances, legible public forecourts, covered walkways, circular gathering areas and visible service equipment. A clinic, market and rescue station must read differently in silhouette.
- Industrial and transport: modular sheds, large loading doors, storage and pipelines, strong access routes, gantries and repairable equipment. Unusual technology must appear to do something.

Use asymmetry within coherent blocks: different frontage widths, corner lots, setbacks, a landmark, infill, parks and junctions. Roundabouts belong at selected intersections; they do not replace the entire street network. Native biology can influence openings and sheltered spaces, but alien flair must not make the plan unreadable.

Palette proposal: warm shell ivory and muted sage walls, deep teal roofs and glass, ochre public-transport accents, plum/coral vegetation and small luminous mint signals. Faction paint occupies constrained trim regions; it never recolors entire neighborhoods neon. Material roughness and lighting should separate ceramic, glass, metal and vegetation. Texture detail must survive downsampling without turning the city into noise.

Reject: identical cylinders, detached objects on featureless grass, arbitrary rooftop organs repeated on every asset, perfectly mirrored districts, huge empty margins around each building, unmotivated pipes, oversized signage and glowing outlines as the default presentation. Data layers may deliberately simplify geometry and color.

## 3. Scale and asset contract

Proposed authoring standard to validate on the first block: one simulation tile represents 16 meters. Author DCC files in meters. Import through a wrapper with a consistent 1/16 scale so one tile remains one Godot world unit. Never stretch a finished 1×1 building to fill a 3×2 lot; author a real 3×2 version or assemble dimensioned modules. Existing code-scaled placeholders are not the production standard.

Every spec records: ID, gameplay purpose, footprint, maximum height, frontage direction, entry points, setback, silhouette description, material slots, variants, growth/damage states, animation sockets, collision and selection bounds, geometry budget, texture allocation, concept references, model source, export, engine scene, approval status and review captures. The first eight specs are in `art/specs/building_kit_v1.json`.

Default pivot: ground plane at the footprint's southwest corner; frontage toward negative Z in the engine wrapper. Keep all occupied geometry inside the reserved lot except explicitly allowed eaves. Selection uses the whole logical footprint; visual doors and service connections must align with road frontage. Blender/glTF axis conversion should be verified with a marked test cube before the first asset export. Apply transforms and validate normals; do not hand-fix individual files with unexplained scale factors.

Initial budgets are hypotheses, to be profiled:

| Asset class | Close-view triangles | Distant target | Material slots |
|---|---:|---:|---:|
| Small terrace / shop | 1,500–4,000 | 200–600 | 1–2 |
| Apartment / industry / civic | 4,000–9,000 | 500–1,200 | 2–3 |
| Transport terminal / landmark | 8,000–15,000 | 800–2,000 | 2–4 |
| Small reusable prop | 100–700 | merged or hidden | shared |

Start with shared 1K–2K trim/material sets. Only a hero asset earns unique high-resolution maps when a camera test proves the need. These are ceilings, not targets to fill. Count draw calls, materials, shadows, transparency, animation and scene nodes as well as triangles. Use simplified distant representations where automatic reduction harms the silhouette.

## 4. The repeatable spec-to-3D loop

**A. Write and review the spec.** Start from gameplay and street frontage. Produce a footprint diagram and a silhouette brief. Confirm lot dimensions and service meaning before decorating the object. Unknown design choices remain labeled, not silently treated as canon.

**B. Explore concepts.** Generate a small set of original alternatives from the same specification. Required views: isometric street view plus front, side and top references with consistent features. Generated views may contradict each other; reconcile them in the spec. Choose one direction for the pilot rather than blending every interesting feature into a chaotic asset. Concept approval is the first taste gate.

**C. Build a dimensional blockout.** Use Blender as the proposed source tool and GLB as the runtime exchange format. A versioned Blender Python script can assemble dimensioned walls, roof curves, courtyard, doors and structural modules from the spec. It cannot judge composition or turn an inconsistent concept into a finished model automatically. Keep purposeful mesh edits and source files; avoid uncontrolled procedural variation.

**D. Review in Godot immediately.** Place the blockout beside streets, another building and scale markers at the actual camera angles. Check occlusion, silhouette, selection, frontage and neighborhood composition before UV work. A beautiful isolated render can still fail in this game.

**E. Finish the model.** Refine proportion and bevels, model only visible details, unwrap UVs, assign shared trims and materials, and author useful props. Use generated textures as inputs; inspect seams, color consistency and baked lighting. Create proper roughness/normal information only where it improves the actual view. Do not describe a single generated color image as a complete PBR material.

**F. Add functional states.** Provide construction foundation/scaffold, completed level one, visibly enlarged level two, and restrained damaged appearance. Utilities and occupied lots should look active: a few lit windows, a vent or door cue, dispatch activity. New buildings assemble over time; they do not instantly appear at full height. State variants reuse geometry and materials where possible.

**G. Export and validate.** Preserve editable `.blend` source or a reproducible generator plus deliberate source edits, exported `.glb`, Godot wrapper `.tscn`, material resources, spec and provenance. Validate footprint, height, pivot, naming, material count, triangle count, missing textures, collision, selection and import scale. Record any exception in the spec.

**H. Review the block and revise.** Capture identical near/mid/far views, a silhouette view, neutral-light turntable and a street-level inspection. Compare against the intended city character. Human art approval and performance approval are separate gates. Only an approved pilot unlocks batch production of related assets.

Automation should produce a review gallery and a machine-readable validation report. It must not auto-approve taste because dimensions or tests pass. A revision loop is expected, not a pipeline failure.

## 5. First production kit and approval scene

Pilot: **courtyard terrace HAB-01**, a real 2×2 lot with two asymmetric wings and a usable garden. Prove scale, materials, roof language, road frontage and growth states with this asset. Then make a corner apartment and market sharing its architectural language. Avoid starting with the most elaborate spaceport.

The first approval block should contain 12–20 lots assembled from 6–8 distinct base models, two road widths, one meaningful roundabout, sidewalks, a pocket garden, a service building, transit stops, a small loading area and a clear expansion edge. It must not look like twelve copies rotated randomly. Use block frontage and purposeful gaps, with color variations subordinate to composition.

The review scene must exercise real zoning, multi-tile occupancy, development stages, road disconnection, service coverage and an incident. Advisors and UI need to look deliberate beside the art. A postcard scene without functioning simulation does not pass; a functional scene with ugly assets does not pass either.

Building production order: HAB-01 terrace → HAB-02 corner apartment → COM-01 market → IND-01 fabrication works → CIV-01 rescue station → CIV-02 clinic → TRA-01 shuttle platform → CIV-03 civic watch. Follow with power, life support, spaceport and district landmarks. The first three establish a shared language; later assets should reuse it without sharing identical silhouettes.

## 6. Transport and the life of the city

Show cause and effect. A new operating route makes underserved lots desirable, construction begins, tax revenue changes, and station activity visibly rises. Only animate a capped sample of vehicles; capacity and demand live in the aggregate simulation.

Sequence: finish road shuttles and coverage feedback; add one continuous railway corridor with two stations and capacity; add a functional harbor with water routes and actual cargo allocation; then prototype benevolent megafauna with feeding groves and resting platforms. Current harbor boats are ambient and must not be presented as simulated exports. Megafauna require creature modeling, rigging and animation as their own art workstream.

Stations need a platform length, pedestrian access, vehicle clearances, entry/exit sockets and signage. Rails must meet at compatible connectors and follow an actual connected path. Freight models need cargo attachment points and meaningful loading/dispatch animation. New vehicle types should create different spatial choices, not only change speed.

## 7. Roadmap to a polished vertical slice

| Stage | Concrete deliverable | Gate |
|---|---|---|
| 0 · Recover baseline | Current build, tests, backup, honest issue list | Launch/save/load and core city commands work |
| 1 · Art pipeline pilot | HAB-01 concept, blockout, finished model, GLB, validation gallery | Building looks convincing in-engine at three distances; source can be revised |
| 2 · Coherent city block | First kit, streets/props, authored block composition and growth states | User approves alien identity, urban order and close/far readability |
| 3 · City play loop | Zoning, utilities, service risks, ledger, access/transit and progressive tutorial | A 15–20 minute session invites redesign through understandable consequences |
| 4 · Delegation and rivalry | Advisory mayor first, bounded execution second; one neighboring nation | AI explains affordable choices and respects player mandates; no hidden economic cheating |
| 5 · Two-world journey | Planet/galaxy art, costly timed landing, differentiated colony, trade, one living-story encounter | A 30–60 minute peaceful session is enjoyable without errands |
| 6 · Release-quality slice | Audio, settings, accessibility, saves, packaging, profiling and regression | Fresh install and complete session on agreed hardware with no blocking defects |

Do not schedule all stages by guessed calendar dates. Time the first complete asset loop, record revision effort and reuse savings, then estimate the kit. A feature complete milestone is not automatically polished; art, UX, simulation and performance each have a gate. Direct fleet combat remains after this slice.

## 8. UX, sound and performance are part of the plan

UI: one obvious next action during the opening; context-sensitive construction choices; readable costs and projected upkeep before placement; clear rectangle preview; data legends that match the active layer; service and economic explanations at selection; sensible scaling at 1080p and 1440p. Replace the provisional typography/panel styling as one coordinated design pass, not separate cosmetic tweaks.

Sound: distinct UI confirmations/errors, zone designation, staged construction, infrastructure activation, incidents, transit and city ambience. Use distance and priority limits so a large city does not become a wall of noise. Add music only after defining the emotional range of civic life, mystery and confrontation. Include volume controls and meaningful visual equivalents for warnings.

Performance target to validate: smooth 60 FPS at the agreed development resolution and a measured lower-spec profile; stable frame pacing matters more than an average counter. Record CPU/GPU frame time, memory, draw calls and simulation tick cost with EU4 closed for a controlled baseline, then separately measure concurrent load. Profile the actual authored block, three active colonies, full sector and repeated scene transitions. Keep residents aggregate, traffic bounded and inactive worlds free of detailed scene objects.

Packaging: use release export templates for public builds rather than the current copied editor runtime; validate bundled assets, input/settings persistence, save migration, autosave recovery and missing-file behavior. Test a clean machine/checkout, not only the development directory. Establish minimum hardware only after measurement.

## 9. Definition of done and the next session

An asset is done when its source and export are tracked, it meets the specification or documents an approved exception, its gameplay states work, it is readable in the approved block, its performance is measured and its review images pass human inspection. A whole city is not approved merely because one asset is attractive.

Next session begins with the HAB-01 specification in `art/specs/building_kit_v1.json`, then a coordinated concept sheet and a Blender-to-Godot blockout/export pilot. Blender availability still needs setup verification; no Blender executable was found on PATH during this checkpoint. Do not begin the mayor or additional factions before proving this art loop. Keep the existing game playable and checkpoint each completed stage to GitHub.

Technical references: [Godot 3D import workflow](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/index.html), [Godot mesh LOD](https://docs.godotengine.org/en/stable/tutorials/3d/mesh_lod.html), [Blender glTF exporter](https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html). These document tooling; the art budgets and conventions above are project proposals to validate against pinned Godot 4.7.2.
