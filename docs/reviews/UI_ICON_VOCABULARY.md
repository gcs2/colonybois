# Functional icon controls; artwork rejected

> Review/evidence record; captures and prompts do not imply acceptance or a current production instruction. [Documentation map](../README.md).

The user endorsed the comparison board and requested recognizable icon buttons, a distinct aesthetic, broad content presentation, and 1080p+ support. The local terrain chart belongs only on a planet's surface. It is absent in orbital flight; system and galaxy views require their own navigation, not a reused local chart.

**Latest user review:** rounded icons, shiny copper-like borders, simplistic SVGs, the font treatment and the planet appearance are rejected. The ornamental button well and persistent selected-tool text above the palette have been removed. The 16 glyphs remain provisional because the user explicitly deferred their replacement. Do not treat this kit as the approved aesthetic.

The first source-vector set contains 16 temporary symbols. The [specification](../../art/specs/flight_icon_vocabulary_v1.json) records family shapes and colors. Navigation uses orbital arcs and mint glass; ecology uses branching/lilac forms; weapons use pointed coral shapes; inventory is an amber pod container; communications uses an expressive antennaed face. The proposed pearl-shell/well material direction was rejected; the removed well is kept only in ignored artifacts. Different silhouettes carry meaning independently of color.

These are original editable SVGs, not generated raster images or copied Spore assets. The [icon review page](../ui-review/icons.html), linked from the comparison board, provides size and state previews. Selection now uses a neutral underline, with no rounded or metallic border. Hover and unavailable feedback remain. Ambiguous actions retain labels; hover text names every symbol. Final aesthetic, listening and native accessibility approval remain open.

## Capacity and verification

- Shared tools/inventory supports 18 entries per page, two rows of nine. Number shortcuts follow the current page; Ctrl-number selects its second row. Empty slots do nothing. Category changes reset paging. Collapse hides item/page controls while keeping ship condition and selected-tool identity.
- Current playable inventory is still small. The 27-entry layout fixture is confined to `tests/`, excluded from exports, and explicitly labeled as preview content. It does not grant items or imply a larger equipment catalog.
- Actual Godot gallery and flight renders were inspected at 1920×1080 and 2560×1440; 3840×2160 geometry was checked headlessly. The 1600×900 design canvas scales through Godot's existing canvas-items mode. 4K native rendering, ultrawide composition and user-adjustable UI scale are not yet verified.
- Full regression suite: 537 assertions plus UI checks passed after the correction, including 50 HUD and 15 capacity checks covering pagination, second-row input, empty slots, collapse, modal guards and chart visibility. A former orbital-chart test now clicks the wreck in the 3D world.
- Browser preview of the new HTML gallery has not been inspected by the agent; source, links, SVG XML and JavaScript syntax are validated. The earlier local-file browser policy block was not bypassed.

Captures live under ignored `artifacts/`: `icon_capacity_1080.png`, `icon_capacity_1440.png`, `flight_ui_surface_1080.png`, and `flight_ui_orbit_1440.png`. Regenerate with `tests/review_icon_capacity.gd` and `tests/review_flight_interface.gd` using the pinned engine.

Next visual work must resolve typography, planet presentation and a coherent reference-led interface treatment. Do not expand the rejected ornamental kit into more screens. Preserve the tested item/command behavior. Wider gameplay content remains gated on the connected core loop; a dense layout fixture is not completion of the content epic.

Tooltip verification: `tests/review_tooltip.gd` injects an engine-local pointer event into an offscreen SubViewport, waits for the native tooltip and checks its visible text. The rendered 1080p capture shows the actual tool name and wrapped description. No OS cursor movement is performed. An ordinary native-window injection was affected by window events; the isolated review is automated evidence, not a human input playtest.
