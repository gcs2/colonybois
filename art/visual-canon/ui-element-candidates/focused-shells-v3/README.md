# Focused Field Instruments shell candidates — v3

Generated with built-in ImageGen on 27 September 2026. All seven PNGs are new transparent-background cutouts derived from the approved view references, not crops from those mocks. They are candidate reusable shells, not user-approved shipped art or evidence of an implemented view. Runtime must supply current icons, item pictures, labels, quantities, meters, selection, hover glow, route and map content.

| File | View coverage | Base-asset contract |
|---|---|---|
| [flight-console-empty.png](flight-console-empty.png) | Surface, orbit, approach, system | One 6 × 2 equipment grid joined to an empty status face; five tabs overlay separately. |
| [shared-tab-base.png](shared-tab-base.png) | Surface, orbit, approach, system | One neutral category tab; category glyph and hover glow overlay separately. |
| [surface-chart-empty.png](surface-chart-empty.png) | Surface, approach only | Angular local chart housing; geography, ship, markers, scale and text are live. |
| [orbit-target-plaque-empty.png](orbit-target-plaque-empty.png) | Orbit, approach | Small blank destination-name plaque. |
| [system-destination-card-empty.png](system-destination-card-empty.png) | Solar-system map | Neutral selected-destination card base; action and resource values are live. |
| [galaxy-system-card-empty.png](galaxy-system-card-empty.png) | Galaxy map | Blank title, two planet rows and footer. |
| [galaxy-status-rail-empty.png](galaxy-status-rail-empty.png) | Galaxy map | Two status tracks plus four equipment cells. |

The shared top-corner [Marks plate](../marks-balance-plate-v1.png) and [notification plaque](../notification-toast-shell-v1.png) remain existing candidates. Five [v2 category glyphs](../category-icons-v2/README.md) are separate candidates. Neither source pixels nor generated shells should be cropped from a full mock.

## Source reference and prompt set

- Flight console: `morrow-surface-ground-truth.png`, `morrow-orbit-approved.png`, `morrow-system-map-approved.png`; prompt for a single wide, low matte ivory clipped-corner chassis with exactly six columns and two rows of empty charcoal wells, plain empty right status face, flat top for separate tabs, genuine transparent exterior; exclude meters, values, tabs, icons and glow.
- Shared tab: same three flight references; prompt for one compact ~67 × 37 dark charcoal notched card with narrow matte ivory bevel and steep shoulder cuts, neutral unselected state and transparent exterior; exclude icon, label, color and glow.
- Surface chart: `morrow-surface-ground-truth.png`, `morrow-approach-approved.png`; prompt for one near-square clipped ivory plate with dark green-charcoal blank map aperture, footer and scale lane, right connector nub; exclude chart contents and text.
- Orbit target plaque: `morrow-orbit-approved.png`, `morrow-approach-approved.png`; prompt for a small charcoal clipped-corner label plaque with a restrained amber left pointer and blank center; exclude destination text, distance, route and glow.
- System destination card: `morrow-system-map-approved.png`; prompt for one neutral dark rectangular card with a fine ivory outline, clipped corners and faint content separator; exclude all selected gold, cost, action, text and planet art.
- Galaxy system card: `galaxy-view-reference.png`; prompt for one compact upright ivory frame with charcoal inset, blank title, two empty circular-thumbnail rows and blank footer; exclude labels and planet art.
- Galaxy status rail: `galaxy-view-reference.png`, `morrow-surface-ground-truth.png`; prompt for one low ivory chassis with two blank status tracks on the left, angular joint, four equal charcoal equipment cells on the right; exclude meter fills and icons.

All prompts requested a flat front-facing 2D game asset, real transparent RGBA, complete uncropped edges, and no blue Windows panels, rounded icon wells or shiny copper. Each generated output was inspected. Pillow confirmed zero alpha at both image corners. The tab and orbit plaque have substantial transparent canvas margin, and some files have faint near-transparent fringe; bounds, 1080p readability, nine-slice suitability and actual in-game appearance are unverified. Do not wire these straight into production without a game-scale comparison and independent visual review. The earlier attempts that baked meter fills, selection glow or an extra tab row were discarded.
