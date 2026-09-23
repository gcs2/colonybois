# Resume here

## Latest steering: deeper Spore GUI forensics

The user explicitly requests a substantially deeper investigation of Spore's actual GUI. Study gameplay screenshots and interaction sequences, not only manual labels; compare composition, tool palettes, cargo, targeting, planetary radar, zoom transitions, diplomacy, trade, feedback and sound timing with our current build. Avoid interpreting recolored rectangular panels as the finished direction. Distinguish observed frames, documented mechanics and our inferences. Audio cannot be judged through browser controls alone. This research now takes priority before further interface redesign.

## Planetary atlas checkpoint

**M / Planet atlas** opens a rotatable whole-globe map. Drag to rotate, wheel to zoom; geography and survey-coverage layers share the orbital globe's seeded material and fixed basin coordinates. A ship marker uses the current local/orbital direction. The one available destination commands actual approach/landing, not teleportation. Orbital imaging costs 20 energy and takes 12 simulation seconds in orbit; it pauses during inspection or surface visits, survives save/load, and records one chronicle milestone. It reveals geography, not ground species/resources. Version 1/2 field saves migrate to version 3.

Only Morrow Basin is landable. The globe is a shared procedural geographic scaffold, not a fully traversable surface or a finished planetary art asset. System/galaxy map integration, multiple landing regions and resource/political layers remain open. Existing local terrain detail is still authored separately from global geometry. Current validation: **313 assertions plus UI checks**, including 34 planet-map checks. Atlas captures in artifacts/flight_ui_atlas_*.png are rendered evidence, not native input review.

**Live task visibility:** keep [TASK_BOARD.md](TASK_BOARD.md) updated at each checkpoint. Latest user feedback likes the orbital concept's overall appearance, but requests a colorful interface rather than all ice blue, real inventory and ship subsystems, and an entire-planet map. [FLIGHT_INTERFACE.md](FLIGHT_INTERFACE.md) specifies these interactions and dependencies. The first colorful instrument/cargo/equipment pass is implemented; the entire-planet map and deeper subsystem mechanics remain pending. Prioritize this presentation/interaction pass before adding unrelated content.

## Interface checkpoint

Cargo / **I** shows two real onboard sample cradles and separate eight-unit surface storage, with quantities, origin and a deployer action. Systems / **K** inspects installed tools, reach, cycle and energy cost, and selects a tool back into flight. Inventory does not fabricate items or count surface produce aboard. All inspection drawers pause both movement and economic time; closing preserves an explicit player pause. Four original vector tool icons use mint, apricot, honey and violet; energy is gold on warm plum housings. These are implemented UI improvements, not final art approval. Full power routing, upgrades, hull/damage and planetary cartography are still missing.

Validation: **279 assertions plus UI checks** pass (flight now 37). `tests/review_flight_interface.gd` renders isolated review captures under ignored `artifacts/flight_ui_*.png`; reviewed 1440×810 and 1280×720 layouts. No native player-input/fun approval is implied.

## Active goal: spaceship adventure and Space Stage feature breadth

**Latest steering:** the user explicitly rejected the `flight-sound-audition` palette as keyboard-like and wants actual AI-generated SFX, especially whirring/humming propulsion. Stop shopping for expensive sound libraries; no purchase was made or authorized. `art/specs/audio_ai_v2.json` contains the new prompts. The public ElevenLabs sound-effects page returned four spacecraft-hum candidates without signup/payment; the user subsequently liked Generations 1, 2 and 3, with 3 preferred. They remain unacquired browser auditions; approval of sound character does not supply files or release rights. Do not claim auditory review through browser controls. The rejected bank is still present in the last packaged build and must be replaced/removed in the next audio integration. The user also requests much wider zoom and visible particles synchronized with thrust/tool audio. These corrections precede the planned combat slice.

Read [SPACE_STAGE_TARGET.md](SPACE_STAGE_TARGET.md) first. The user playtested Morrow and rejected the farming-led introduction, F-centric interaction, constant-height flight, lack of danger, weak UI and insufficient audio. The goal is a polished Spore Space Stage spiritual successor, with all its feature families tracked, plus richer trade, flight and a potential human solar-system start. This goal is not complete.

Ecological expansion and city-first art work are deferred. Preserve the approved creepy-cute original assets and existing city/galaxy simulation. Do not add individual citizen/organism simulation. No engine migration is needed.

## Presentation quality gate

The user explicitly reiterated the AAA quality directive. Current ship, HUD and planet presentation are rejected; functional tests are not evidence of artistic success. Next presentation work must establish a coherent visual target, authored ship specification, much wider zoom, particles linked to tools/thrust, believable planetary scale/atmosphere, and a starfield grounded in real star-catalog positions/brightness. Do not call generated concept art an in-engine result or add arbitrary star dots and call them accurate. A Terraria-like exploration/equipment/access progression is endorsed as a possible direction, not authorization to replace spaceship gameplay with block mining.

## Current flight checkpoint

Choose **Morrow expedition — surface to orbit** from Play.cmd. Click a subject to approach and operate the selected tool; click terrain to move. Arrows / numpad 8,4,2,6 / WASD fly. Home, Page Up, numpad 9 or +, and E ascend; End, Page Down, numpad 3 or minus, and Q descend. Numpad 5 or 0, Escape, or Stop cancels. Wheel changes altitude; Ctrl-wheel zooms. Right-drag rotates the camera. On-screen flight controls support mouse-only play.

The opening now points to scanning an old relay and leaving the atmosphere; planting is optional. Ascending past 58 local meters enters orbital flight. Click Morrow or Return to Morrow to approach and reenter the same surface. This is a local reference-frame transition, not seamless planetary scale. The orbital globe's surface marker is attached to its rotating transform.

One expedition model continues through both views. Version 1 field saves migrate additively to version 2. Survey, stock, trade and history survive a round trip. **The field is still isolated from the strategic campaign**; a unified ship/sector state is a required next integration, not solved by a Menu button. The full galaxy, other visitable surfaces and human scenario are not present in this flight slice.

## Audio checkpoint

Read [AUDIO_PRODUCTION.md](AUDIO_PRODUCTION.md). Twenty original WAV candidates now include distinct hotbar equips, UI/target/navigation feedback, thrust, atmosphere and a 48-second music loop. Audio settings separate effects, music and voice. Four contextual guide lines use local Windows scratch narration plus captions, with a replacement contract for licensed recordings. Actual listening and paid casting/music selection remain open. No paid services were purchased.

## Next work

1. Continue the audio coverage and listening audit (initial flight implementation is in place): distinct tool equip cues, target acquisition, movement confirmation, thrust, scans, cancellation, warnings, impacts and transitions. Add separate SFX/music/voice controls and a music/VO production path. The user explicitly wants satisfying hotbar sounds and is willing to pay for quality audio. Browser-assisted sourcing/auditions are authorized; present a concrete price/license before purchase.
2. Give the ship health and weapons, readable instruments, a telegraphed threat, meaningful energy and fair recovery. Improve original icons, targeting feedback, animations and tutorial arrows. Native playtesting and listening remain essential.
3. Connect personal flight to the sector, diplomacy and cargo. Do not build another isolated demo to avoid integration.
4. Follow the complete requirement ledger rather than declaring success from this slice.

## Verification and backup

Current verification: 279 assertions plus UI checks pass (92 baseline, 43 urban, 19 landing, 24 city, 46 encounter, 37 flight, 18 audio). Tests are in tools/Test.ps1. Flight tests cover click-only approach and scan, right-hand bindings, altitude beyond the previous cap, ascent/return, brake/pause, persistence, legacy migration and the interface behaviors above. Existing encounter tests still cover optional ecology and animation. Captures are in user://flight_captures and artifacts/flight_ui_*.png (ignored runtime output); they demonstrate rendering, not fun or native input quality.

Build with tools/Build.ps1; smoke the resulting pack. Keep each validated milestone in a small commit, push and compare the remote hash. Play.cmd uses build/current.txt and does not live-update an already open game. Previous user-data and downloads/builds remain outside Git.
