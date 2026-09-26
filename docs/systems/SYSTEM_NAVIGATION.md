# Personal system navigation

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. Integrated V04/I01 candidate; presentation and native input acceptance remain open.

## Playable behavior

The ship now has separate surface, orbital, system and sector views. Zoom outward at the orbital limit or press **J** / the system icon to open the current system. A known star in the sector chart also offers **View system**. The surface local chart never appears in system or sector views.

The system view shows its actual one to three planetary destinations using the same seeded globes and climate changes as orbital flight. Hover a planet for its conditions and departure quote; click it to request that journey. Clicking the current planet returns to the ship. Destinations with no implemented landing region explicitly say **Orbital destination**. Survey completion governs landing beacons and ecological readouts. Charted systems may be inspected without granting a visit; unknown systems are rejected.

Right-drag rotates the camera; wheel and icon buttons zoom. Arrows or numpad 4/6 select destinations; Enter/numpad Enter activates the selected destination. Up/down or numpad +/− zoom; Home/numpad 5 frame the system. Outward zoom at the limit reaches the sector. Inward zoom into the current planet returns to orbit; zooming toward another planet never spends energy by itself. J/Escape closes idle system inspection.

Travel uses the existing authoritative campaign command and quote: currently three energy and six simulation seconds within a system, with the existing range, border and route checks for other systems. These are scenario values, not claims of retail Spore numerical parity. The same ship marker and progress indicator read the remaining campaign journey; there is no second travel clock. Arrival reconstructs the actual destination orbit with the same resources. A restored local voyage opens this view automatically; interstellar voyages use the sector chart.

During travel, Escape opens the pause/save menu. Opening a modal immediately blocks departure at both the view and controller. The HUD distinguishes active transit from pause. Idle map inspection still follows the existing pause policy; travel runs the shared economy/world clock unless explicitly paused or a modal is open. This is **not** completion of the earlier aspiration that all view changes leave the economy running.

## Implementation and limits

- `scripts/system_chart.gd` renders one active system in its own viewport. Hidden charts stop viewport rendering. The camera is ephemeral UI state; no save-version change is required.
- `scripts/encounter.gd` owns view transitions, pause and validated travel requests. `scripts/sector_chart.gd` exposes known-system entry; `scripts/flight_hud.gd` supplies J and its named-tooltip icon.
- Orbital positions, body sizes, the star and orbit rings are schematic. They are not astronomical scales, simulated orbital motion or an accurate background star catalog.
- Twenty-four planets are orbital destinations; only Morrow, Nacre I and Kestrel I currently have playable surfaces. The view does not invent landing regions or known alien affiliations.
- Camera movement is smooth within the chart, but scale changes still switch views. Seamless flight, broader planet access, signals, wormholes and the galactic core remain open. Existing art and sounds remain provisional.

- **25 September home-system extension:** fresh campaigns include Morrow (morrow), Vesper (s0p1) and Morrow's Moon (s0p2). The Moon has its own stable destination identity and local orbit; existing travel/save paths handle it, and older saves with only Morrow remain valid. A seeded asteroid belt and denser star specks add system context. The current 1920×1080 capture shows all three bodies, but the inspection card still overlaps the Moon and the independent critic rejects the composition. Visual density and performance are not approved or measured.

## Evidence

tests/test_system_chart.gd now exercises 47 focused assertions: the prior chart/transit/save behaviors plus fresh Morrow-system body identities, local Moon orbit, actual travel to Vesper, preservation of Morrow, and snapshot restoration. The latest run passed with zero failures in 34.56 seconds. The current runtime capture and independent rejection are recorded in [VIEW_MOCK_COVERAGE.md](../reviews/VIEW_MOCK_COVERAGE.md); this test result does not establish visual approval or performance.

`tests/review_system_chart.gd` renders actual overview, selection, transit and sector states at 1920×1080 and 2560×1440. It controls focus-loss pause in the fixture so captures actually exercise travel. Screenshots caught undersized buttons, overlapping captions and the misleading pause indicator; these were corrected. Render review does not prove native mouse feel, accessibility, performance on other PCs or player art approval.

Reference basis: the previous manual audit in [SPORE_INTERFACE_CONTRACT.md](../reviews/SPORE_INTERFACE_CONTRACT.md), covering the distinction between surface/system/galaxy views and destination clicking, plus the [official Spore manual](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/17390/manuals/manual.pdf?t=1642702281). The current implementation is an original interpretation with explicit scenario limits above.
