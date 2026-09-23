# Project working agreements

## Checkpoints and backup

- This repository is tracked at https://github.com/gcs2/colonybois.
- Keep changes in small, reviewable commits. After a working milestone and relevant validation, commit and push it before beginning unrelated feature or content work. Verify the remote commit hash; a local commit alone is not an off-device backup.
- Do not accumulate an entire development session without a checkpoint. If work is incomplete, keep that status explicit in its checkpoint message rather than calling it finished.
- Keep downloaded runtimes, build output, save files and rejected art out of Git. Preserve source, configuration, tests and approved design documents.
- Never force-push or rewrite published history as part of routine backup. Report authentication or push failures immediately.

## Product constraints

- Resume production from docs/NEXT_SESSION.md. Latest direction is SPACE_FIRST_DIRECTION.md: exploration, distinct living planets, supply chains and alien diplomacy take priority; cities support those systems. Preserve the authored-art pipeline but move its pilot to a planet expedition and scout ship. Read FLIGHT_TECH_ASSESSMENT.md for an early bounded first-person flight test, and DIPLOMACY_AND_CHRONICLE.md for expressive contact/trade and persistent history. No engine migration or rendering rewrite is approved. Older city-first milestones are deferred.

- Godot 4.7.2, desktop, single-player. Exploration and trade precede full fleet battles. First-person ship flight/combat is a desired later capability; a small early flight/renderer feasibility test is appropriate without launching full combat production.
- Read docs/SPORE_SPACE_STAGE_RESEARCH.md: preserve personal ship/tool play, collection, visible world manipulation, expressive contact and optional hands-on trade. The richer economy, living worlds and timeline remain endorsed. Automate established repetition without removing discovery and experimentation; prove a small planet interaction before widening management or full combat.
- Art direction: original creepy-cute, expressive creatures and playful miniature worlds; a love note to Spore's space stage. No creature creator yet. The initial realistic cast board was rejected.
- The endorsed campaign foundation is a forgotten outpost, a corrupt local government and the Vanguard's rise, followed by living interstellar politics and discoveries about Earth. See docs/CAMPAIGN_FOUNDATION.md. The five earlier plots remain alternative explorations; the future-echo premise is not approved.
- Nations, planets and species are distinct. Spaceflight does not require planetary unification. Choices must change available actions and create visible obligations, not merely adjust bonuses.
- Current story and gameplay sources are docs/STORY_CURRENT.md, docs/PROJECT_VISION.md and the superseding docs/SPACE_FIRST_DIRECTION.md. The modern 120,000-person city and Vanguard history remain available context; a mandatory long city-building opening is no longer the priority. The bounded urban tutorial exists; the full political opening does not.
- Urban order must retain alien divergence: circular civic spaces, unusual architecture and potentially benevolent megafauna transit. The latest conventional Earth-like city concept is not the final art direction. Creature transport is a future route/capacity mechanic, not a commitment to simulate every animal or passenger.
- SimCity 4-like urban fidelity is the target. Simulate population, jobs, services and political groups in aggregate; do not add individual citizen/household agents or world-wide per-person pathfinding. Ambient traffic and pedestrians must be capped visual effects. Profile before raising scope caps.
- Player-facing money is Marks, with history in data/catalog.json. The internal credits save key remains for compatibility; do not expose it as the currency's name.
- Read README.md for run/test/build instructions and docs/ROADMAP.md for milestone boundaries.
- The user rejected the current presentation as an early systems demo. docs/PLAYTEST_REVIEW.md records the critique, corrections and remaining gates. Do not call the city visually convincing or the tutorial successful based on tests, population counters or generated mockups. Native input playtesting and human readability/fun review remain necessary.
