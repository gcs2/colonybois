# Resume here

## User direction at this checkpoint

The user logged off and requested a safe stopping point. Their latest additions prioritize a polished art production pipeline and SimCity 4-style city dynamics. Do not continue adding placeholder systems as a substitute for authored art. Pixel art / pre-rendered / real-time 3D is an open choice, not an approved rewrite.

Read in order:

1. `docs/SC4_SYSTEMS_AND_RENDERING.md` — sourced research, finite demand, wealth/education/service capacity, regional specialization and rendering comparison.
2. `docs/ART_PRODUCTION_PLAN.md` — complete production loop, scope gates, performance/UX/audio, eight-building kit and release-quality plan.
3. `art/specs/building_kit_v1.json` — dimensional source briefs; no finished Blender/GLB assets exist yet.
4. `docs/AI_AND_TRANSPORT.md` — explainable mayor/nation planners, bounded budgets and transport design.

## Exact next task

Start the **HAB-01 courtyard terrace art pilot**. Verify/install an appropriate Blender toolchain if needed (not on PATH at checkpoint). Create a coordinated concept sheet from the spec, then a dimensionally correct model/blockout and Godot review scene. Compare real-time orthographic and pre-rendered isometric-style presentation using the same asset; include a pixel-style study before asking the user to choose the direction. Preserve the existing executable and renderer while experimenting. Do not mass-produce the kit before human visual review.

After the pilot, implement finite demand/occupancy/construction reservations and service capacity in a bounded playable block. Appointed mayors follow those underlying economics; do not prioritize the mayor ahead of the art pilot based on an earlier commentary suggestion.

Suggested continuation prompt:

> Resume from docs/NEXT_SESSION.md. Start HAB-01 from art/specs/building_kit_v1.json and prove the spec-to-3D-art production loop. Create an in-engine review block and compare orthographic 3D, pre-rendered sprites and a pixel-style study before committing to the full kit. Keep the working game intact and checkpoint the pilot to GitHub. Follow docs/SC4_SYSTEMS_AND_RENDERING.md for the next simulation work.

## Playable stopping point

`Play.cmd` opens the versioned executable in `build/current.txt`. Start a **new urban tutorial** to see the revised starting lots; old saves preserve their layouts. Rectangular zoning is free; development spends materials. Ledger/Services tabs expose daily economics and coverage. Top layer menu shows access, suitability, crime, fire and service reach. V cycles district/harbor/skyline views. Two road-connected powered shuttle stops produce a visible route; harbor boats are decorative. Full railways, maritime freight, wealth tiers, schools, parks, regional labor markets and mayors are not implemented.

Three generated advisor portraits and three generated color textures are integrated. Their exact prompts/provenance are in ADVISOR_ART.md and CITY_TEXTURES.md. The current procedural building kit is still an interim model set, not the finished authored assets specified in the production plan.

## Verification and caveats

Tests: 92 baseline, 43 urban, 19 landing, 24 city assertions plus UI checks. Verified deterministic economy/risk behavior, multi-tile collision/frontage, free rectangle input, service effects, ledger reconciliation, persistence and route continuity. Captures inspect ledger, safety layer and textured architecture. User input previously interrupted native automation; no claim of a complete manual gameplay pass. EU4 was running during development, so timing samples are not a clean performance baseline.

Before reporting the checkpoint complete: build, smoke the exported pack, commit and push, compare remote HEAD, leave a clean working tree. No overnight automation has been scheduled; this handoff is the explicit next-session trigger.
