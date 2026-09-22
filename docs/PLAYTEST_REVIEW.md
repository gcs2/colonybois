# Presentation and interaction review — 22 September 2026

## User assessment

The user rejected the colony presentation, font, overwhelming interface and tutorial flow. The repeated city buildings did not convincingly communicate 120,000 residents. The planet's fixed colony marker floated over rotating geography. Colonization felt free and instantaneous, with an entire starter settlement appearing without construction. There was no sound feedback. Flagship travel lacked engagement. These are failures of the player experience even where automated checks passed.

The project remains an **early systems demo**. The urban art and tutorial have not passed the human acceptance gate. A population counter and a faster renderer do not establish city fidelity or fun.

## This correction pass

- Colony markers and labels now belong to the globe's transform and use depth testing. Automatic globe rotation is removed; orbital rotation is user-controlled.
- Founding commits 300 Marks, 100 materials and 80 supplies from an established settlement. An 18-day project reports landing, assembly and commissioning. Route disruption pauses it. Completion creates only a hub with 70 materials and 60 supplies left; no homes, roads or population are conjured.
- Save schema 3 preserves version 1/2 expeditions and introduces pending settlement projects. Review sessions use isolated save prefixes.
- Right-drag orbits; middle-drag pans the colony; wheel zooms; R/F tilt. Q/E and WASD remain. Urban overview starts much farther out.
- Construction is a drawer opened with Build/B. Economy, logistics and logs are expandable. The first urban step is paused observation, followed by inspection, funding, timed repair and a civic ability. The font stack and panel treatment are revised, not declared final.
- Batched city scenery covers a larger, uneven footprint with mixed building masses, an off-center tall district, gardens and a river edge. It is still procedural placeholder scenery; most boroughs are fixed aggregates, not separately simulated cities.
- Original synthesized cues cover interface actions, construction, launch, arrival and rejected commands; the Sound control mutes them. This is basic feedback, not a complete soundscape.
- Flagship travel has a visible active route, a directional ship silhouette and an optional follow camera. These improve feedback but do not establish an engaging exploration loop.

## Verification and limits

The simulation suites pass 92 baseline, 43 urban and 19 landing assertions, with additional UI checks. Checks include real cargo debit, duplicate rejection, mid-project save/load, bare-hub completion, route interruption, legacy urban save migration, marker transform inheritance and tutorial ordering. Rendered captures were inspected after changes. These checks do not validate sound through the user's speakers, subjective visual quality or fun.

The Windows computer-use skill inspected the user's running game and a separate review build. Native screenshots confirmed the clutter and repeated scenery. Injected navigation clicks did not produce a confirmed transition, and the tool later reported concurrent user input. Automation stopped sending input rather than competing. This is **not** recorded as a completed manual end-to-end playthrough. The separate review session used `--playtest` to keep its saves apart from normal play.

Existing performance measurements were taken with EU4 running and are not a clean baseline. This pass increases batched scenery; do not carry forward old frame-time claims as if they measured the revised scene.

Rendered play is now capped at 60 FPS to avoid spending CPU/GPU capacity on unbounded drawing. Headless verification remains uncapped. No new controlled minimum-hardware benchmark is claimed.

## Gate before expanding features

1. Have a player start fresh and understand the first task without reading a sidebar manual.
2. Verify free camera controls and selection in an actual input session, including multiple window sizes.
3. Play one complete landing: understand the cargo cost, follow its progress, then build a useful first settlement.
4. Develop a coherent alien building kit and authored district layout. Assess skyline, street hierarchy, asymmetry, density, landmarks and near/far readability. More copies of a placeholder mesh are not an art solution.
5. Prototype one meaningful flagship exploration decision. A moving map icon with a countdown remains insufficient.

Do not add more factions, battles or procedural plots to compensate for failures in these fundamentals.
