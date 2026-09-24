# Frontier Worlds

**Badges and promotions:** click the rank readout or Escape → Badges. Ten accomplishment families now connect exploration, commerce, diplomacy, surveys, settlement and planet work to persistent recognition and paid upgrade eligibility. Select a family, pin progress or inspect its actual shop reward. Brief animated awards use the existing achievement cue. [Rules, tuning and remaining parity gaps](docs/EXPEDITION_PROGRESSION.md).

**System navigation / J:** zoom outward from orbit to see the star and its actual planets. Hover for a quote and click a destination to spend energy and travel; mouse wheel/right-drag and arrows/numpad also work. Zoom farther out to the sector; Escape pauses an active journey for saving. The local terrain chart remains surface-only. [Controls, verified behavior and limits](docs/SYSTEM_NAVIGATION.md).

**Specimen expeditions:** scan a visible lifeform, switch to the tractor and click to collect. Open Inventory → Specimens, choose a carried species and click a surface habitat to release it. Plants stabilize climate; complete food chains improve development. Introductions, habitat loss and chosen sites persist. [Controls, rules and limitations](docs/PLANET_BIOSPHERE.md).

**Planet manipulation:** survey a foreign world, buy climate equipment or finite supplies at a dock, then select an Environment icon and click the globe or terrain. Independent temperature/atmosphere pulses alter appearance, outpost output, utilities, growth capacity and diplomatic relations. Plants collected on other worlds can now stabilize climate tiers; complete food chains support further development. [Rules, verification and remaining work](docs/PLANET_CLIMATE.md).

**Allied fleet:** establish an alliance, earn a badge tier and request an escort through Communications → Fleet while in allied orbit. Escorts follow, assist your attacks and retain damage/losses. Use the HUD fleet icon for orders and dock services → Fleet for paid repairs. [Rules, limitations and verification](docs/ALLIED_FLEET.md).

**Surface combat:** Nacre I and Kestrel I have hostile flyers and sentries. Select the defense laser, or buy a seeker/bomb bay at a dock; click targets/ground to fire, move out of marked strikes, and click wrecks separately for cargo. [Controls, limits and verification](docs/SURFACE_COMBAT.md).

**Repair supplies:** buy basic/full repair packs through dock services → Supplies, then click an owned item in Inventory / I or its hotbar category. Packs have real stock, costs, a shared three-slot locker and a 20-second repair cooldown. [Behavior and verification](docs/REPAIR_SUPPLIES.md).

**Ship progression:** dock services → Upgrades → Hull / Reactor now offers four purchased capacity tiers per family, with badge and prior-installation requirements. New capacity starts empty; home recharge is free and energy never regenerates. See [ship capacity behavior and verification](docs/SHIP_CAPACITY.md).

Flight correction: **Escape** opens the game menu; **I** opens Inventory, where an owned energy pack can be used. Energy never regenerates passively. Homeworld recharge is free through local services; select Weapon before clicking a hostile target. The current cockpit artwork is rejected and remains temporary; see [interface correction contract](docs/SPORE_INTERFACE_CONTRACT.md).

[Current task board](docs/TASK_BOARD.md) tracks active work, dependencies, prototype gaps and deferred features. [Flight interface specification](docs/FLIGHT_INTERFACE.md) records the latest colorful HUD, cargo, subsystem and whole-planet map requirements. The composed instrument HUD, clickable local chart, cargo/equipment panels and planetary atlas are implemented candidates; broader requirements remain in production. See [HUD review](docs/FLIGHT_HUD_REVIEW.md).

**New flight panels:** **Cargo / I** shows onboard specimens separately from surface stock. **Systems / K** inspects tool range, cycle, energy use and selects equipment into the hotbar. Inspection pauses the local simulation; Esc closes it. Gold energy, mint survey, apricot tractor and violet deployer instruments replace the uniform blue palette. These panels read the flight campaign; the whole-planet atlas is implemented, while deeper ship systems remain pending.

**Current direction:** exploration of living alien worlds, useful interplanetary supply chains, expressive diplomacy and the ancestors' mystery. Cities support the space game. Later first-person ship combat is planned, with an early bounded feasibility test. See [Space-first direction](docs/SPACE_FIRST_DIRECTION.md), [flight stack assessment](docs/FLIGHT_TECH_ASSESSMENT.md), [diplomacy and history](docs/DIPLOMACY_AND_CHRONICLE.md), and [next session](docs/NEXT_SESSION.md). These plans extend the prototype; they are not all implemented.

An early 3D colony-and-galaxy systems demo. Windows desktop; **Godot 4.7.2 stable**, typed GDScript, OpenGL compatibility renderer. The presentation and core-loop enjoyment still need substantial work; see [Playtest review](docs/PLAYTEST_REVIEW.md). No paid assets, runtime AI service, or API keys required.

## Play

**Alien contact:** enter an inhabited system, then open **Communicate / Y**. Three original animated portrait candidates present trade agreements, transit pledges, chart-sharing alliances, goodwill and exclusive survey licenses. Agreements change real prices/access; decisions persist in **Escape → Chronicle**. [Contact behavior and current limits](docs/EXPEDITION_CONTACT.md).

**Trading pilot:** open communications (**Y**) and approach the local dock. Market trades real ship cargo; Upgrades sells badge-gated hold/drive improvements; Energy provides recharge and reserve packs. At Morrow, load alloy from actual colony construction stock, then carry it to another world. Frozen water and arid resonant glass offer different trade opportunities. **I** shows cargo origins and capacity; **Escape → Badges** shows unlock progress. Markets have finite stock/demand. [Exact behavior and remaining work](docs/SHIP_COMMERCE.md).

**Latest presentation checkpoint:** shared seeded geography now drives Morrow and surveyed strategic globes, with distinct terrestrial climates, relief, clouds and atmosphere. [Planet pipeline and remaining work](docs/PLANET_GENERATION.md). Morrow Basin, frozen Nacre I and arid Kestrel I support personal surface flight. All 24 sector planets support orbital visits; further landing regions remain pending.

**Sector chart / G:** ascend into orbit, select a revealed star and orbital body, then depart using the displayed energy/time quote. The same ship visits all 24 orbital destinations; Morrow, Nacre I and Kestrel I currently support descent. Foreign recharge costs Marks; home recharge is free. Worlds preserve scans, stock and local changes while you travel. [Travel behavior and limits](docs/INTERSTELLAR_FLIGHT.md).

**Planet atlas / M:** inspect the current world's whole globe, drag to rotate and wheel to zoom. In orbit, commission a 20-energy, 12-second chart; close inspection to let it run. Coverage and progress persist in saves. Select an available landing beacon to issue a real approach. Orbital imaging reveals geography, not ground resources. Older field saves migrate automatically.

**Flight checkpoint:** choose **Morrow expedition — surface to orbit**. Click terrain to fly, or click a subject to approach and use the selected tool. Scan the old relay, then climb into orbit; click the planet to return. Planting is optional. Fly with **arrows / numpad 8,4,2,6 / WASD**. Ascend with **Home / numpad 9 or +**; descend with **End / numpad 3 or minus**. Wheel zooms; Ctrl-wheel changes altitude; right-drag orbits. Scroll out to the surface overview to begin ascent, or scroll in to cancel it. In orbit, zoom inward toward the planet or use Descend to begin landing; scroll out or steer to cancel. Plus/minus chart buttons also control zoom. Mouse-accessible Ascend, Descend and Stop buttons are available. Browse Main tools / Environment / Weapons / Inventory without changing your equipped tool; Tab / Shift-Tab cycle categories, and 1–9 select the visible slots (Ctrl-number addresses a second row when populated). Use the fold/unfold icon to collapse or expand its items. Larger categories support 18 items per page with page arrows. Energy packs are owned inventory items, with count and cooldown. The local chart accepts navigation and target clicks on the surface only; it disappears in orbit. Press Escape for Controls, Audio, Chronicle, Save, Load and Resume. **Audio** has independent effects, music and guide-voice sliders; the new sounds/music are original candidates and guide captions remain available while recorded voice awaits production. Morrow flight now saves its ship and background sector together, with a shared Marks treasury and one colony day per 30 active seconds. Legacy field saves migrate without overwriting the originals. The older strategic demo modes remain separate. Personal multi-world travel now works; three freight commodities and badge-gated paid upgrades now form a trade loop; broader progression, professional HUD and audio remain in development. [Complete target and evidence](docs/SPACE_STAGE_TARGET.md).

Double-click **Play.cmd**, then choose **Urban tutorial**, **Expedition** or **Sandbox** in the opening menu. The launcher prefers the latest completed build recorded in `build/current.txt`, then older local builds, then the source project. Builds now use timestamped directories under `build/versions/` so they do not replace an executable in use. Keep the `.pck` beside the executable. Close an older game window yourself when you are finished with that session; it does not update live.

On a fresh checkout, run `powershell -ExecutionPolicy Bypass -File tools/Setup.ps1` to download the pinned engine from its official GitHub release. Alternatively, import `project.godot` in Godot 4.7.2 and press F6/F5. Use the editor or the engine with `--path .` when testing source changes; rebuild before using an existing executable.

**Personal colonies:** at a home dock, buy a colony kit in **Upgrades** (300 Marks, 100 materials, 80 supplies; four cargo spaces). Survey Nacre I or Kestrel I from orbit, descend, then select the kit in **Inventory** and click clear ground. The ship delivers it and construction takes nine active minutes. Commission an export facility through Communications → Colony administration; collect its real output at the local dock's **Warehouse**. [Colony behavior, costs and remaining work](docs/EXPEDITION_COLONIES.md).

**Automatic freight:** open **Communications → Colony administration → Freight contracts**. Charter a carrier for 80 Marks, choose a visited destination, commodity and reserve. Shipments take real warehouse goods, prepay transport and sell against arrival demand. Foreign contracts need trade agreements; border closures and storage limits can hold cargo. Pause/recall preserve it. Orange markers on the sector chart show carrier progress. [Exact costs, controls and limits](docs/EXPEDITION_FREIGHT.md).

## First expedition

**Scout art candidate:** the new Kiteback model has articulated shell shields and attached engine, survey and weapon effects. Its authored source and current review limits are in [Scout asset](docs/SCOUT_ASSET.md). This is a playable candidate awaiting art acceptance.

**Orbital encounters:** Nacre I's raider pursues; Kestrel I's sentry is stationary. Select the arc lance and click a hostile ship. Move outside its marked strike volume (altitude works too), or retreat to break contact. Click its cleared wreck for cargo salvage. Distinct victories earn Defender progress; Defender 1 **or Explorer 2** unlocks the 180-Mark focused emitter at dock Upgrades. [Behavior, costs and limitations](docs/ORBITAL_ENCOUNTERS.md).

For the new city opening, choose **New urban tutorial** instead:

1. Latch begins with 120,000 people across five boroughs. South Loop is your editable district; the other four currently have fixed aggregate populations and batched scenery. Its mint border marks construction authority. A textured courtyard building kit now replaces the district's repeated single-tile towers; this remains candidate art, not final visual quality.
2. The overview starts paused with construction tucked away. Click **Inspect South Loop** to focus the broken crossing and reveal the repair choice. It isolates eastern neighborhoods from the hub, preventing their buildings from operating normally.
3. Choose **public repair** (60 materials, eight days) or **sponsored repair** (180 Marks, two days). Time controls are below. Reopening changes the actual road network and restores connected employment.
4. Public repair unlocks **mutual aid**: 30 supplies become 20 materials, keeping a 60-supply reserve, with a twelve-day cooldown. Sponsored repair unlocks **priority works**: inspect a zone marked Ready to grow, then upgrade one level for 30 Marks and 15 materials, with a four-day cooldown. The sponsor receives 1 Mark/day; unpaid fees accumulate and suspend priority works until treasury income clears them.
5. Develop the district or explore the existing frontier. Civic projects and obligations persist across views and saves. The political takeover and creature transport are not implemented yet.

Urban mode uses separate `urban_save.fw` / `urban_autosave.fw` slots. Its city total reflects live South Loop population plus the fixed background aggregates; there are no individual citizen agents. Your treasury is the district's discretionary budget, not the whole city's wealth.

## City management pass

- Select habitat, industry or service zoning and **drag a rectangle**. Designation is free; development spends materials when demand, roads and utilities permit it. Adjacent tiles can combine into 2×1, 2×2, 3×2 and other lots. Right-click or Escape cancels a drag. Roads remain a paid brush.
- **Ledger** shows daily taxes, export receipts, crime losses, upkeep, sponsorship and net balance. Choose local tax policy; high taxes slow residential growth. Construction/project payments are one-off orders, outside that daily operating statement.
- **Services** shows civic watch, fire/rescue, clinic and shuttle coverage, with advisor portraits. Services need connected roads and power. Clinics improve productivity; crime loses revenue and can steal supplies; fires halt a building's output for 12 days unless repaired.
- The top-right layer selector exposes access, suitability, crime, fire and service catchments. Data mode focuses the live district and colors its buildings, hiding background scenery that previously covered the overlays.
- Two functioning shuttle stops support longer commutes. Connected routes have capped visual shuttles. **V** cycles district, harbor and skyline viewpoints in Latch. Harbor boats are ambient scenery; railway construction, maritime freight simulation, creature transit and appointed mayors are future work.

See [AI and transport design](docs/AI_AND_TRANSPORT.md) for how mayors, nations, routes and meaningful expansion should work. [Texture provenance and exact prompts](docs/CITY_TEXTURES.md) and [advisor prompts](docs/ADVISOR_ART.md) accompany the generated assets.

For the original small-settlement loop, choose **New expedition**:

1. Solace starts with roads, three habitats, industry, services, power, and life support. Time runs immediately; Space pauses. Buildings grow every six simulation days if conditions permit.
2. Select **Habitat zone**, then click an empty tile beside the road. Add industry when the colony needs jobs. Costs are construction materials, not Marks. Inspect tiles or use data layers to understand blocked growth.
3. Open **Galaxy**, select a nearby **Unknown** signal, and choose **Travel**. Surveying it reveals its name, planets and neighboring signals. At a free planet, select a supply colony and dispatch a landing expedition for **300 Marks, 100 materials and 80 supplies**. It takes **18 days** and needs an accessible route. On completion, enter a bare hub with 70 materials and 60 supplies left. Lay a road beside it and zone homes/services yourself. Cold-world homes grow best near geothermal sites.
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
| Right drag | Free orbit and tilt |
| Middle drag | Pan colony camera |
| R / F | Raise / lower camera angle |
| B / Build | Toggle construction drawer |
| Wheel | Zoom |
| G / P / C | Galaxy / planet / colony |
| Space | Pause / resume |
| F5 / F9 | Save / load |

UI sidebars scroll. Hover over clipped buttons for the complete label. Habitat, industry, and service zones have two automatic development levels; utilities are directly placed. Existing housing remains during shortages, while growth and production slow or stop. There is no population abandonment model yet.

Economy/logistics and expedition logs expand on request. Sound toggles the new synthesized action cues. Galaxy travel can optionally follow the flagship. Planet markers are surface-attached; automatic globe rotation has been removed. The free camera and new UI still need a complete native-input playtest.

## Saves and tests

Morrow flight uses `field_encounter_campaign.fw` and `field_encounter_campaign_auto.fw` in the same user data directory. Both ship and sector progress save together. On entry, the newer slot resumes; if no campaign exists, the newer old field JSON is imported intact. See [shared session behavior and limits](docs/EXPEDITION_SESSION.md).

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
- **Simplified:** roads have connectivity and commute-distance penalties, not traffic; planets have fixed sites; supply aggregates food/water/logistics; AI factions evaluate lightweight authored rules and do not build competing empires. Government bonuses currently affect trade terms. Legacy strategic trade is an aggregate flow. Personal expedition freight now has persistent four-unit consignments and chart markers; 3D freighter units remain missing.
- **Deferred:** tactical fleet battles, war/conquest, ship construction, full planetary terrain editing, deeper political simulation, large sectors, final art/audio, accessibility pass and public release packaging.

The local build uses the complete portable Godot engine plus a resource pack. It is runnable but larger than a normal release export. Save schema 3 accepts version 1/2 snapshots and preserves their existing colonies. `-- --playtest` runs with isolated `review_` save slots. See `docs/ROADMAP.md` for gates before adding systems and `docs/ARCHITECTURE.md` for extension points.

Current verification includes 92 baseline, 43 urban and 19 landing assertions, plus UI checks. A separate rendered profile can be run with `.tools\godot\Godot_v4.7.2-stable_win64_console.exe --path . --script tests/profile_urban.gd`. This exercises the city at 3x time and reports frame intervals, draw calls and tracked static memory. These measurements are development-PC observations, not minimum hardware requirements or a guarantee for larger cities. The historical measurements below predate the wider city scenery; they do not describe the latest renderer.

22 September 2026 observation, **with EU4 running concurrently**: the urban simulation measured roughly 1.5–1.7 ms/tick. A six-second rendered sample on the RTX 5070 Ti Laptop GPU averaged 5.21 ms/frame, p95 6.30 ms, with a 40.98 ms maximum and 86.8 MiB peak Godot-tracked static memory. The sample included road repair at 3x speed. Background workload makes this unsuitable as a clean performance baseline; memory excludes total process/VRAM usage. Incremental per-lot mesh updates and batched background scenery are implemented, but occasional refresh hitches remain to investigate in a controlled profile before raising scope caps.

## Art and licenses

All game geometry, icons, and shaders in this repository are original procedural/code assets. System fonts fall back to Segoe UI/Arial. Rejected generated concepts are archived locally and excluded from Git; unapproved concepts remain studies. The creepy-cute character direction and orderly urban architecture are documented in `docs/ART_DIRECTION.md`. No creature creator is in scope. The campaign direction is selected, while its final resolution remains open. Preview captures show running scenes; generated concepts are labeled separately. Godot is MIT-licensed; its notices can be found at https://godotengine.org/license/ and should accompany any public distribution.



## Equipment and content production

The four current field tools use `data/equipment.json` for reach, timing, costs, targets, presentation and starting acquisition descriptions. The command model, HUD and effects share validated definitions; existing saves are unchanged. This is the foundation for additional functional equipment, not an upgrade/unlock system yet. See [the content inventory](docs/CONTENT_INVENTORY.md) for actual playable content versus briefs and disconnected prototypes.

## Orbital wreck encounter

In Morrow orbit, chart the planet from **M / Atlas** to reveal a wreck in a visible pulse field. Click its world marker, local chart contact or **Salvage** to fly to it. A close, three-second recovery spends 20 energy and installs a phase shroud. The field warns before repeated hull damage; manual movement or Stop cancels salvage. **Shroud** near the hull gauge reduces damage while consuming energy. Leave the field and click **Repair** to recover hull for 30 energy. An emergency tow makes defeat recoverable. The local expedition saves hull, shroud, repair cooldown and losses in version 4 field saves; previous field saves migrate. This is one prototype danger, not fleet combat. [Details and limitations](docs/ORBITAL_THREAT.md).
