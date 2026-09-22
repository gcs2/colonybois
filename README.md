# Frontier Worlds

A playable, original 3D colony-and-galaxy prototype. Windows desktop; **Godot 4.7.2 stable**, typed GDScript, OpenGL compatibility renderer. No paid assets, runtime AI service, or API keys required.

## Play

Double-click **Play.cmd**, then choose **Urban tutorial**, **Expedition** or **Sandbox** in the opening menu. A portable engine is already installed in this workspace. If a build is present, this launcher uses `build/FrontierWorlds.exe`; otherwise it starts the source project. Keep the `.pck` beside the built executable.

On a fresh checkout, run `powershell -ExecutionPolicy Bypass -File tools/Setup.ps1` to download the pinned engine from its official GitHub release. Alternatively, import `project.godot` in Godot 4.7.2 and press F6/F5. Use the editor or the engine with `--path .` when testing source changes; rebuild before using an existing executable.

## First expedition

For the new city opening, choose **New urban tutorial** instead:

1. Latch begins with 120,000 people across five boroughs. South Loop is your editable district; the other four currently have fixed aggregate populations and batched scenery. Its mint border marks construction authority. The rounded buildings are a graybox, not final art.
2. Click **Inspect crossing · access layer** in the right panel. The broken link isolates 3,840 residents from the hub, preventing their buildings from operating normally.
3. Choose **public repair** (60 materials, eight days) or **sponsored repair** (180 Marks, two days). Time controls are below. Reopening changes the actual road network and restores connected employment.
4. Public repair unlocks **mutual aid**: 30 supplies become 20 materials, keeping a 60-supply reserve, with a twelve-day cooldown. Sponsored repair unlocks **priority works**: inspect a zone marked Ready to grow, then upgrade one level for 30 Marks and 15 materials, with a four-day cooldown. The sponsor receives 1 Mark/day; unpaid fees accumulate and suspend priority works until treasury income clears them.
5. Develop the district or explore the existing frontier. Civic projects and obligations persist across views and saves. The political takeover and creature transport are not implemented yet.

Urban mode uses separate `urban_save.fw` / `urban_autosave.fw` slots. Its city total reflects live South Loop population plus the fixed background aggregates; there are no individual citizen agents. Your treasury is the district's discretionary budget, not the whole city's wealth.

For the original small-settlement loop, choose **New expedition**:

1. Solace starts with roads, three habitats, industry, services, power, and life support. Time runs immediately; Space pauses. Buildings grow every six simulation days if conditions permit.
2. Select **Habitat zone**, then click an empty tile beside the road. Add industry when the colony needs jobs. Costs are construction materials, not Marks. Inspect tiles or use data layers to understand blocked growth.
3. Open **Galaxy**, select a nearby **Unknown** signal, and choose **Travel**. Surveying it reveals its name, planets and neighboring signals. The northern frontier leads to Nacre; open **Nacre I**, establish a colony for 180 Marks, and enter it. Cold-world homes grow best near the red geothermal marker.
4. Explore outward to discover **Orin**, visit it, and sign a trade treaty. Return to any colony through the left settlement list and configure automatic exports. They retain a 60-unit reserve. Other colonies can import from a selected settlement's surplus above 80 units.
5. Survey unexplored systems and resolve discoveries. Sharing discoveries builds relations; keeping them yields resources. Sign non-aggression agreements or an alliance when relations allow.
6. On a harsh world, build a connected **Climate array** and enough power. Start the project in the orbital view. Recovery improves climate over 180 simulated days, spends actual materials and supplies, and affects ecological relations.

The game is an open sandbox. There is no victory screen or mandatory mission chain. Three ranks recognize distinct accomplishments. At Pathfinder, specialize colonies in industry or ecology. Three colonies and twelve systems are the current scenario cap.

**Sandbox mode** adds optional god tools to the left sidebar: Marks and resource grants, free construction, instant travel, reveal/survey the entire map, diplomatic goodwill, and instant climate restoration. Toggle abilities are marked ON. Expedition mode rejects cheat commands. Sandbox has separate manual/autosave slots (`sandbox_save.fw` and `sandbox_autosave.fw`) so it cannot overwrite expedition progress. Both modes start with frontier fog unless you explicitly reveal the map. The Menu button lets you resume or begin a different mode; starting fresh replaces the current unsaved session.

## Controls

| Input | Action |
| --- | --- |
| Left click | Inspect, place construction, or select star |
| Left drag | Paint roads or zones / remove tiles |
| Right click / Escape | Return to inspection |
| 1 / 2 / 3 / 4 | Road / habitat / industry / service |
| WASD / arrow keys | Pan colony camera |
| Q / E | Orbit camera |
| Wheel | Zoom |
| G / P / C | Galaxy / planet / colony |
| Space | Pause / resume |
| F5 / F9 | Save / load |

UI sidebars scroll. Hover over clipped buttons for the complete label. Habitat, industry, and service zones have two automatic development levels; utilities are directly placed. Existing housing remains during shortages, while growth and production slow or stop. There is no population abandonment model yet.

## Saves and tests

Manual save: `%APPDATA%\Godot\app_userdata\Frontier Worlds\frontier_save.fw`.
Autosave: the same folder, `frontier_autosave.fw`, every 60 simulated days. Both are versioned binary snapshots, with object deserialization disabled. Autosave has its own restore button and never overwrites a manual save. No offline simulation.

```powershell
powershell -ExecutionPolicy Bypass -File tools/Test.ps1
powershell -ExecutionPolicy Bypass -File tools/Build.ps1
```

Simulation tests cover deterministic generation and continuation after loading, growth constraints, actual-stock trade, embargoes, climate projects, discovery rewards, and peaceful progression. UI tests exercise screen picking, view navigation, colony founding, overlays, and time controls. `-- --capture` produces rendered preview PNGs under `artifacts/` and exits; it uses a disposable demo state and does not save the expedition.

## Free Windows narration

Read the five provisional story treatments in `docs/STORY_EXPLORATIONS.md`. Render an offline voiceover using installed Windows voices, with no subscription or API key:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Narrate.ps1
```

This creates `artifacts/narration/story-explorations.wav` and a companion HTML reading page. The default prefers Microsoft Zira Desktop and uses a measured speaking rate. `-ListVoices` lists installed voices; `-Voice 'Microsoft David Desktop' -Rate 0` selects a different delivery. Windows desktop voices are basic synthesized readings, not acted dialogue.

For another free listening option, open the generated HTML page in Microsoft Edge and choose **Read aloud** from the context menu, then select a voice and speed. See [Microsoft's Read Aloud guide](https://support.microsoft.com/en-US/edge/use-immersive-reader-in-microsoft-edge). Narration files remain local and excluded from Git; the script and source text are backed up.

## Implementation status

Read the [current story treatment](docs/STORY_CURRENT.md) and [complete project vision](docs/PROJECT_VISION.md). A bounded urban tutorial now implements the initial city context, broken crossing and two civic agreements. The full Vanguard takeover, domestic nations and national space program are still design work. The target is SimCity 4-like urban fidelity with aggregate simulation and a distinctly creepy-cute alien civilization. The [city image study](docs/CITY_CONCEPT.md) tests scale but remains too Earth-like; it is not the final art direction. Marks is implemented; its ledger-origin history remains a proposed lore detail.

- **Implemented:** colony toy; connected multi-world loop; a small playable pass over core MVP systems, with procedural meshes and a procedural planet shader.
- **Still needs playtesting:** whether the colony economy and diplomacy stay interesting for 30–60 minutes. Automated verification does not prove fun or balance.
- **Simplified:** roads have connectivity and commute-distance penalties, not traffic; planets have fixed sites; supply aggregates food/water/logistics; AI factions evaluate lightweight authored rules and do not build competing empires. Government bonuses currently affect trade terms. Trade is an aggregate flow, without visible freighter units.
- **Deferred:** tactical fleet battles, war/conquest, ship construction, full planetary terrain editing, deeper political simulation, large sectors, final art/audio, accessibility pass and public release packaging.

The local build uses the complete portable Godot engine plus a resource pack. It is runnable but larger than a normal release export. See `docs/ROADMAP.md` for gates before adding systems and `docs/ARCHITECTURE.md` for extension points.

Urban verification adds 43 assertions to the 91 baseline simulation assertions, plus UI checks. A separate rendered profile can be run with `.tools\godot\Godot_v4.7.2-stable_win64_console.exe --path . --script tests/profile_urban.gd`. This exercises the city at 3x time and reports frame intervals, draw calls and tracked static memory. These measurements are development-PC observations, not minimum hardware requirements or a guarantee for larger cities.

22 September 2026 observation, **with EU4 running concurrently**: the urban simulation measured roughly 1.5–1.7 ms/tick. A six-second rendered sample on the RTX 5070 Ti Laptop GPU averaged 5.21 ms/frame, p95 6.30 ms, with a 40.98 ms maximum and 86.8 MiB peak Godot-tracked static memory. The sample included road repair at 3x speed. Background workload makes this unsuitable as a clean performance baseline; memory excludes total process/VRAM usage. Incremental per-lot mesh updates and batched background scenery are implemented, but occasional refresh hitches remain to investigate in a controlled profile before raising scope caps.

## Art and licenses

All game geometry, icons, and shaders in this repository are original procedural/code assets. System fonts fall back to Segoe UI/Arial. Rejected generated concepts are archived locally and excluded from Git; unapproved concepts remain studies. The creepy-cute character direction and orderly urban architecture are documented in `docs/ART_DIRECTION.md`. No creature creator is in scope. The campaign direction is selected, while its final resolution remains open. Preview captures show running scenes; generated concepts are labeled separately. Godot is MIT-licensed; its notices can be found at https://godotengine.org/license/ and should accompany any public distribution.


