# Galaxy navigation checkpoint

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

24 September 2026. A functional galaxy expansion; presentation and whole-world playability remain open. Field Instruments references are design work and are not the HUD shipped by this checkpoint.

## Behavior

- 2,048 persistent seeded stars arranged into a spiral galaxy, with the twelve authored systems retained as the starting neighborhood. Generated stars carry deterministic orbital planet records; most lack services or surface scenes.
- Actual parsec distances gate personal travel. Drive reach progresses through 3/5/8/12/20 pc; the four purchased upgrades cost 160/520/1200/2600 Marks and retain badge alternatives and prior-tier requirements. Tuning remains provisional.
- Detected/visited/charted knowledge persists. Visible starlight is not full planet/civilization knowledge. Visiting or acquiring a drive can reveal nearby destinations. Territorial access and energy are validated separately from reach.
- Local travel is two simulation seconds; interstellar travel is two to four. Energy is paid; border changes can interrupt travel. Existing voyages retain their saved timing rather than receiving an invented refund. Pause stops travel and shared colony time.
- Mouse wheel zoom, full above/below-plane right-drag orbit, Shift/right or middle-button pan, keyboard arrows/numpad, Home focus and End overview. The range boundary and stars use the same galactic-plane projection. Known-star selection followed by activation starts travel; the current star enters its system view.
- Authored freight links remain; generated carrier connections have their own fixed reach rather than silently inheriting personal drive upgrades.
- Save v19 migrates earlier snapshots and preserves stable IDs and colony history. Planet scenes remain lazy; loading the galaxy does not instantiate thousands of 3D worlds.

## Verification

Bounded preview repair, 24 September: defense-field proximity is now checked in `quote`, which `begin_travel` revalidates. Previously the preview could advertise available travel before commit refused it. Costs, strict field boundary and earlier refusal precedence are unchanged. `test_travel_preview.gd` passes27 checks covering inside/exact/outside boundary, vertical distance, side-effect-free preview/refusal, changed position between quote and commit, other-world coordinates and energy precedence. The45 interstellar integration checks also pass. The isolated24-image review regenerated with matching preview/commit refusal; no new playable export was produced for this repair.

Final relevant checks passed on 24 September: galaxy 40, full-screen navigation 67, system 41. Exported playable build: `build/versions/20260924-003147/FrontierWorlds.exe`; resource-pack headless flight startup smoke passed using isolated playtest slots. Native interaction/art/audio review remains open.

Final galaxy, full-screen navigation and system checks cover deterministic generation, range/cost rejection, purchased drive progression, legacy migration, saved travel, generated orbital visits, geography IDs, camera/zoom projection, navigation and modal behavior. The wider regression suite passed in staged runs before the last renderer optimization; see the pending-checkpoint record for historical evidence and the final checkpoint for the actual exported build.

The cached MultiMesh star rendering measured substantially lower map frame cost than individual star submissions in the capture harness. Earlier measured rotating-map median frame interval was 4.85 ms, p95 7.04 ms, draw CPU median 3.2 ms. This is not a full-game FPS guarantee. A three-starting-colony/galaxy simulation profile is not a dense-city stress test.

## Remaining gaps

Package follow-up: `build/versions/20260924-050435/FrontierWorlds.exe` now includes the preview repair and is selected by `Play.cmd`. Exported-pack flight startup with `--field --playtest` exited cleanly after180 frames; the external travel-preview harness also passed27 checks against exported resources. Previous versions and normal saves were retained. This supersedes the no-new-export limitation above; it does not establish native flight feel or visual acceptance. The bundled README also corrects finished colony-kit cost to300 Marks only.

The critic found excessive empty space in local framing, weak distinctions between knowledge states and thin separated galaxy dust arms. The new reference image also contains incorrect range geometry; do not copy it. Whole procedural surfaces, inhabited generated nations, deeper encounters, wormholes/core and polished travel feedback are separate unfinished requirements. Current scripted captures do not prove native flight feel, audio quality or fun.

Galaxy UI rendering still uses a custom perspective-projected control. It is a real navigable star model, but not a seamless physically scaled space scene. No engine/renderer migration occurred.
