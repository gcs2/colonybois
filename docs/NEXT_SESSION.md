# Resume here

## Latest steering and combat checkpoint

The user rejects the Windows guide voice, clunky zoom/ineffective descent, and current planet presentation. These corrections and a reusable planet-generation pipeline take priority over additional combat content. The unfinished combat work is now validated: one arc lance and warning/chase/disengage custodian, nonlethal disable, persisted state, version 4-to-5 migration. 440 assertions plus UI checks pass, including 23 combat checks. Geometry and firing sound remain placeholders. No native playtest or artistic approval is implied. The current packaged build predates this source checkpoint. See ORBITAL_COMBAT.md.


## Latest checkpoint: orbital danger and acquired ship defense

[ORBITAL_THREAT.md](ORBITAL_THREAT.md) documents the new charted wreck, telegraphed pulse field, persistent hull, emergency tow, repair and one recovered phase shroud. Chart/contact/world click issues actual ship travel and a timed salvage action; retreat and cancellation matter. Version 3 field saves migrate to version 4. HUD now shows hull beside energy and a clickable shroud/repair control. The 3D wreck and ring are prototype geometry; the previous sound bank is still unapproved. Existing field and strategic worlds remain separate.

Validation: 417 assertions plus UI checks, including 37 orbital encounter checks; reviewed in-game orbital captures at 1600×900 and 1280×720; build `20260923-032255` and exported-pack smoke passed. Native playtesting, professional art/audio approval and a complete Space Stage capability set remain open. Next: weapon/hostile AI pilot, authored scout/wreck and approved AI sound acquisition, then shared flight/sector ship state. Earlier checkpoint sections below are historical context.

## Latest checkpoint: equipment catalog and content inventory

[CONTENT_INVENTORY.md](CONTENT_INVENTORY.md) now audits all nine content families, with actual scope and brief/asset/mechanic/integration/review distinctions. Four existing field tools now read shared validated definitions in `data/equipment.json`; command costs/range/cycle, HUD, approach distance, keyboard slot order and effects use the same source. The equipment inspection states their starting acquisition. Save version stays 3. This is a content-production foundation, not new equipment breadth or final presentation approval.

Validation: 380 assertions plus UI checks pass, including 27 new equipment checks and existing version 1/2 save migration. Rendered HUD/equipment text reviewed at 720p; Windows build `20260923-030715` and exported-pack smoke passed. Next content implementation: readable orbital danger, hull/damage/recovery and a distinct useful capability with an actual acquisition path; do not expand the optional farming lesson. Shared flight/sector state remains essential before claiming multi-world logistics. Approved AI audio acquisition, ship/globe artwork and native playtest gates remain open. Earlier checkpoint sections below are historical context.


## Latest steering and flight checkpoint

The user requires broad, deep, distinct content for every major component of the game. This instruction is **independent of the attached screenshot**. Read [CONTENT_CORPUS.md](CONTENT_CORPUS.md); presentation-only progress is insufficient. After validating/backing up the current camera/effects work, the next content milestone is a data-driven equipment/content ledger tied to actual commands, acquisition and meaningful uses. Keep the full feature-family objective intact.

[FLIGHT_CAMERA_EFFECTS.md](FLIGHT_CAMERA_EFFECTS.md) records the new wider camera, ordinary-wheel zoom, cancellable zoom ascent, distant scenery and capped engine/tool particles. Ctrl-wheel retains altitude control. Effects are cosmetic; strategic integration and complete planet surfaces remain unfinished. The sections below preserve earlier checkpoints; the latest behavior is specified here.


## Latest implementation: composed flight instruments

Read [FLIGHT_HUD_REVIEW.md](FLIGHT_HUD_REVIEW.md). The first composed HUD slice now exists: original shaded tool icons and instrument housings, live clickable local navigation, category palettes, quick cargo, adjacent ship energy/equipment and explicit target states. Category browsing is live and preserves equipment; expanded inspection still pauses. Full globe atlas remains intact. 332 assertions plus UI checks pass, including 19 new HUD integration checks. This is a candidate engine implementation, not art approval. Next: native-input/readability review, dedicated character/trade layouts and richer motion; approved audio acquisition, ship/planet assets and shared sector state remain outstanding. The earlier instruction below to begin this slice is historical context.


## Latest steering: deeper Spore GUI forensics

Read [SPORE_GUI_FORENSICS.md](SPORE_GUI_FORENSICS.md) first. The research checkpoint inspects manual diagrams, game screenshots, timestamped gameplay states and community UI structure, then audits our code. [FLIGHT_INTERFACE.md](FLIGHT_INTERFACE.md) now specifies a composed lower instrument assembly, live planetary navigation, category/item palettes by the ship, distinct targeting states and dedicated commerce/conversation layouts. Next: composition/state boards and an original housing/icon kit, then implement the bounded HUD slice and its acceptance matrix. Current colored buttons and generic drawers remain prototypes. Dense late-game states, frame-accurate motion, native retail input and listening audit remain open; do not claim those were verified.

## Planetary atlas checkpoint

**M / Planet atlas** opens a rotatable whole-globe map. Drag to rotate, wheel to zoom; geography and survey-coverage layers share the orbital globe's seeded material and fixed basin coordinates. A ship marker uses the current local/orbital direction. The one available destination commands actual approach/landing, not teleportation. Orbital imaging costs 20 energy and takes 12 simulation seconds in orbit; it pauses during inspection or surface visits, survives save/load, and records one chronicle milestone. It reveals geography, not ground species/resources. Version 1/2 field saves migrate to version 3.

Only Morrow Basin is landable. The globe is a shared procedural geographic scaffold, not a fully traversable surface or a finished planetary art asset. System/galaxy map integration, multiple landing regions and resource/political layers remain open. Existing local terrain detail is still authored separately from global geometry. Current validation: **313 assertions plus UI checks**, including 34 planet-map checks. Atlas captures in artifacts/flight_ui_atlas_*.png are rendered evidence, not native input review.

**Live task visibility:** keep [TASK_BOARD.md](TASK_BOARD.md) updated at each checkpoint. The colorful cargo/equipment pass and whole-planet atlas are implemented prototypes; the redesigned composition, live navigation instrument and deeper subsystem mechanics remain pending. Prioritize the forensic redesign before unrelated content.

## Interface checkpoint

Cargo / **I** shows two real onboard sample cradles and separate eight-unit surface storage, with quantities, origin and a deployer action. Systems / **K** inspects installed tools, reach, cycle and energy cost, and selects a tool back into flight. Inventory does not fabricate items or count surface produce aboard. All inspection drawers pause both movement and economic time; closing preserves an explicit player pause. Four original vector tool icons use mint, apricot, honey and violet; energy is gold on warm plum housings. These are implemented UI improvements, not final art approval. Full power routing, upgrades and hull/damage are still missing; the atlas checkpoint above supersedes the former missing-map status.

This earlier interface checkpoint passed 279 assertions; the subsequent atlas checkpoint passed **313 plus UI checks**. `tests/review_flight_interface.gd` renders isolated review captures under ignored `artifacts/flight_ui_*.png`; reviewed 1440×810 and 1280×720 layouts. No native player-input/fun approval is implied.

## Active goal: spaceship adventure and Space Stage feature breadth

**Latest steering:** the user explicitly rejected the `flight-sound-audition` palette as keyboard-like and wants actual AI-generated SFX, especially whirring/humming propulsion. Stop shopping for expensive sound libraries; no purchase was made or authorized. `art/specs/audio_ai_v2.json` contains the new prompts. The public ElevenLabs sound-effects page returned four spacecraft-hum candidates without signup/payment; the user subsequently liked Generations 1, 2 and 3, with 3 preferred. They remain unacquired browser auditions; approval of sound character does not supply files or release rights. Do not claim auditory review through browser controls. The rejected bank is still present in the last packaged build and must be replaced/removed in the next audio integration. The user also requests much wider zoom and visible particles synchronized with thrust/tool audio. These corrections precede the planned combat slice.

Read [SPACE_STAGE_TARGET.md](SPACE_STAGE_TARGET.md) first. The user playtested Morrow and rejected the farming-led introduction, F-centric interaction, constant-height flight, lack of danger, weak UI and insufficient audio. The goal is a polished Spore Space Stage spiritual successor, with all its feature families tracked, plus richer trade, flight and a potential human solar-system start. This goal is not complete.

Ecological expansion and city-first art work are deferred. Preserve the approved creepy-cute original assets and existing city/galaxy simulation. Do not add individual citizen/organism simulation. No engine migration is needed.

## Presentation quality gate

The user explicitly reiterated the AAA quality directive. Current ship, HUD and planet presentation are rejected; functional tests are not evidence of artistic success. Next presentation work must establish a coherent visual target, authored ship specification, much wider zoom, particles linked to tools/thrust, believable planetary scale/atmosphere, and a starfield grounded in real star-catalog positions/brightness. Do not call generated concept art an in-engine result or add arbitrary star dots and call them accurate. A Terraria-like exploration/equipment/access progression is endorsed as a possible direction, not authorization to replace spaceship gameplay with block mining.

## Current flight checkpoint

Choose **Morrow expedition — surface to orbit** from Play.cmd. Click a subject to approach and operate the selected tool; click terrain to move. Arrows / numpad 8,4,2,6 / WASD fly. Home, Page Up, numpad 9 or +, and E ascend; End, Page Down, numpad 3 or minus, and Q descend. Numpad 5 or 0, Escape, or Stop cancels. Wheel zooms; Ctrl-wheel changes altitude. Another outward scroll at the surface limit begins ascent; scrolling in cancels it. Right-drag rotates the camera. On-screen flight controls support mouse-only play.

The opening now points to scanning an old relay and leaving the atmosphere; planting is optional. Ascending past 58 local meters enters orbital flight. Click Morrow or Return to Morrow to approach and reenter the same surface. This is a local reference-frame transition, not seamless planetary scale. The orbital globe's surface marker is attached to its rotating transform.

One expedition model continues through both views. Version 1 field saves migrate additively to version 2. Survey, stock, trade and history survive a round trip. **The field is still isolated from the strategic campaign**; a unified ship/sector state is a required next integration, not solved by a Menu button. The full galaxy, other visitable surfaces and human scenario are not present in this flight slice.

## Audio checkpoint

Read [AUDIO_PRODUCTION.md](AUDIO_PRODUCTION.md). Twenty original WAV candidates now include distinct hotbar equips, UI/target/navigation feedback, thrust, atmosphere and a 48-second music loop. Audio settings separate effects, music and voice. Four contextual guide lines use local Windows scratch narration plus captions, with a replacement contract for licensed recordings. Actual listening and paid casting/music selection remain open. No paid services were purchased.

## Next work

1. Follow the bounded HUD redesign and acceptance matrix in the forensic report. Preserve functioning inventory, equipment, atlas and save commands.
2. Acquire approved AI audio and replace the rejected bank; complete the listening/feedback audit. Existing independent sound controls remain. Browser-assisted auditions are authorized; no purchase without an approved concrete price/license.
3. Continue authored ship/planet assets, scale navigation and particles. Native playtesting and listening remain essential.
4. Integrate flight with the sector, diplomacy and cargo, then the planned health/threat slice. Keep the full requirement ledger visible rather than declaring success from a presentation slice.

## Verification and backup

Current code verification: 353 assertions plus UI checks. Camera/effects adds 21 presentation assertions, including manual input overriding approach/ascent. Tests are in tools/Test.ps1. The forensic checkpoint was documentation-only; the subsequent HUD implementation adds the 19 interaction checks. Captures in ignored artifacts demonstrate rendering, not fun or native input quality. Use build/current.txt for the latest completed package; the earlier atlas code checkpoint is cfc102086376adf20b2eb1509c30cc53c5a9d5a1, pushed and remote-verified.

Build with tools/Build.ps1; smoke the resulting pack. Keep each validated milestone in a small commit, push and compare the remote hash. Play.cmd uses build/current.txt and does not live-update an already open game. Previous user-data and downloads/builds remain outside Git.
