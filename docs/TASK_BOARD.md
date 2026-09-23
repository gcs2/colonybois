# Production task board

Updated 23 September 2026. This is the current work queue, not a list of finished features. Keep it updated at each checkpoint and when user feedback changes priorities. Long-term requirements remain in [SPACE_STAGE_TARGET.md](SPACE_STAGE_TARGET.md); resume instructions remain in [NEXT_SESSION.md](NEXT_SESSION.md).

**Current focus:** a colorful, interactive flight presentation, an authored scout and believable planet, with approved AI audio. The latest concept's overall appearance received positive feedback; its ice-blue interface did not. The image is a visual target, not an engine capture. AAA quality is the target; it is not the current build's status.

Status meanings: **In progress** = current work; **Next** = ordered near-term queue; **Dependency** = a prerequisite remains; **Later** = tracked, not currently under construction; **Prototype** = some working code exists, but the feature has not passed its final gate.

## Immediate queue

| ID | Task | Status and current evidence | Gate |
| --- | --- | --- | --- |
| V01 | Visual direction and colorful interactive HUD | **In progress.** Candidate orbital concept received positive feedback. Color and interaction revision specified in [FLIGHT_INTERFACE.md](FLIGHT_INTERFACE.md). Current in-game HUD remains rejected. | Readable engine implementation with distinct instrument colors, deliberate typography, hover/selection feedback and unobscured flight. User review required. |
| V02 | Inventory and cargo interface | **Next.** Local quantities exist; no proper inventory screen. | Inspect real items, quantities, capacity and provenance; equip supported tools and explain unavailable actions. No decorative fake inventory. |
| V03 | Ship subsystem interface | **Next.** Energy exists; full subsystem simulation does not. | Show actual installed equipment and resource use. Add validated power/activation controls with visible effects; health/repair depend on C01. |
| V04 | Whole-planet map and view hierarchy | **Next.** A local patch and orbital globe exist, not a persistent explorable whole-planet map. | Rotatable globe, survey fog, known sites and route selection linked to persistent coordinates. Unknown regions stay unknown; show which destinations are actually visitable. |
| A01 | Acquire and integrate approved AI engine audio | **Dependency.** User likes Generations 1–3, prefers 3. No files acquired or integrated; release rights unresolved. | Preserve candidates, obtain suitable files/rights, trim and test loops, synchronize thrust. No purchase without a concrete price/license approved by user. |
| A02 | Replace rejected cues; complete interaction sound coverage | **Next, depends on A01 for engine.** Rejected synthesized bank remains in packaged build. | Approved AI-generated equips, clicks, scans and transitions; consistent mix; no keyboard-like bounce. Listening review, not waveform-only approval. |
| V05 | Wider camera range and thrust/tool particles | **Next.** Zoom remains limited; intended particles absent. | Useful close-to-wide zoom without exposing a small terrain patch as an entire world; capped effects track thrust, target and cancellation. |
| V06 | Authored scout asset | **Next.** Current game ship rejected; concept is not a mesh. | Dimensioned spec → consistent views → authored 3D source → materials/animation sockets → in-engine near/far review. Original creepy-cute design. |
| V07 | Planet scale, geography, clouds and lighting | **Next.** Procedural globe is a prototype. | Consistent geography/site attachment; coherent sun, atmosphere and cloud layers; convincing approach and return. Clearly distinguish local reference-frame transitions from seamless flight. |
| V08 | Astronomically grounded starfield | **Next.** Current random star points are not accurate. | Licensed catalog with provenance, positions and brightness; documented observer frame for fictional worlds; no false claim of an accurate sky from random dots. |
| Q01 | Native playtest, accessibility and performance | **Ongoing gate.** Latest recorded baseline: 267 assertions plus UI checks; no new game tests run for this documentation checkpoint. | Test actual input, supported window sizes, legibility, listening and clean-PC performance. Automated captures do not establish fun or AAA quality. |
| Q02 | Checkpoints and remote backup | **Ongoing gate.** Small validated commits required. | Push each working milestone and verify remote hash; report failures. Keep generated drafts, runtimes and builds out of Git. |

## Following the presentation pass

| ID | Task | Status / dependency | Gate |
| --- | --- | --- | --- |
| C01 | Health, weapons, threats and fair recovery | **Later.** Personal-flight danger absent. Follows current presentation corrections. | One readable encounter with damage, costs, repair, energy/cooldowns and recoverable defeat. |
| I01 | Connect personal flight to the strategic simulation | **Later, critical.** Field and strategic saves/state remain separate. | One authoritative ship, cargo, time, location and history across surface, planet, system and galaxy. No duplicated or reset economy. |
| E01 | Multiple worlds, discoveries and finite trade | **Prototype / later integration.** Local order and strategic trades exist separately. | Three-world loop with actual surplus/demand, capacity, access and useful specialization; automatic routes remove errands. |
| D01 | Expressive diplomacy and alien characters | **Prototype / later.** Three faction rules; presentation static. | Animated original representatives, clear motives, meaningful treaties/grievances and distinct obligations. |
| L01 | Living ecosystems and organism collection | **Prototype / later.** Two modeled organisms; 14 species briefs. | Bounded trophic/habitat interactions, useful planet effects and collection decisions; no per-organism planet simulation. |
| P01 | Equipment progression, ranks and unified chronicle | **Prototype / later.** Separate milestone/history systems. | Discoveries unlock useful optional capabilities; decisions, losses and alliances enter one durable timeline. Terraria-like access progression remains a design possibility. |
| S01 | Ancestor campaign, Vanguard and planetary nations | **Later.** Story foundation documented, political opening unimplemented. | Living characters and present-day consequences; fallible ancestors, varied invaders, no recording hunt or compulsory planetary unity. |
| S02 | Sandbox and alternative human start | **Prototype / later.** Strategic sandbox exists; integrated flight sandbox and Sol scenario absent. | Same core simulation, separate saves, deliberate cheats/story rewards; human scenario does not overwrite alien campaign. |
| F01 | Fleet commands and eventual first-person combat | **Later.** Not implemented. | Bounded enjoyable flight/combat pilot before scaling; persistent ships and losses connected to production. |
| U01 | Colony support, finite demand and service capacity | **Deferred behind space-first loop.** City prototype exists; visual quality rejected. | Aggregate cities support trade, administration and recruitment. Finite demand, regional specialization and service capacities remain tracked. |
| R01 | Full Space Stage feature inventory | **Later / research incomplete.** Family ledger exists. | Enumerate individual tools, upgrades and abilities; explicitly settle editor/expansion scope rather than claiming parity prematurely. |

## How progress is reported

Each checkpoint should identify changed task IDs, actual shipped behavior, validation, remaining gaps and remote commit. Update this board in the same commit as the implementation. Concepts, specifications, code, packaged builds and user-approved results are separate stages. Do not turn a row green solely because a test passed or a concept looks attractive.
