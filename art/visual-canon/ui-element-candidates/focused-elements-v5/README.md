# Focused UI elements — v5 candidates

Nine selected newly generated transparent PNGs, using the approved view mocks as style references. These are individual reusable housings, not crops. The user explicitly approved this nine-image set for the live HUD on 27 September 2026. Approval covers these source elements; runtime placement, legibility, interaction and whole-scene quality still require review. Counts, text, meters, geography, item pictures, focus and pointer-hover glow must be drawn from live state.

| Asset | View coverage | Intended live layers |
|---|---|---|
| [shared-category-tab-v2.png](shared-category-tab-v2.png) | Surface, orbit, approach, system | One base reused for all five category glyphs; hover glow is runtime only. |
| [flight-inventory-console.png](flight-inventory-console.png) | Surface, orbit, approach, system | Six-by-two item grid and compact status bay; item art/counts, hull/energy/ALT/signal overlay. |
| [surface-chart-housing.png](surface-chart-housing.png) | Surface and late approach only | Actual seeded surface geography, ship, landmarks, scale and controls overlay. |
| [system-destination-card.png](system-destination-card.png) | Solar-system map | Destination, relay state, Fly/cost/time and post-trip values overlay. |
| [galaxy-selected-system-card.png](galaxy-selected-system-card.png) | Galaxy map | Selected system, two planet rows and charted state overlay. |
| [galaxy-status-equipment-rail.png](galaxy-status-equipment-rail.png) | Galaxy map | Hull/energy fills and four equipped-item pictures overlay. |
| [orbit-target-plaque.png](orbit-target-plaque.png) | Orbit and approach | Live target name and cue overlay. |
| [marks-balance-plate.png](marks-balance-plate.png) | Surface, orbit, approach, system | Separate Mark emblem and live balance overlay. |
| [notification-plaque.png](notification-plaque.png) | Surface, orbit, approach, system | Separate event glyph and live message overlay. |

Source mocks: [surface](../../morrow-surface-ground-truth.png), [orbit](../../morrow-orbit-approved.png), [approach](../../morrow-approach-approved.png), [system](../../morrow-system-map-approved.png), [galaxy](../../galaxy-view-reference.png). The surface, orbit, approach and system set share one flight console. The galaxy has its own distinct rail. No surface chart belongs on the system or galaxy view.

Generation used built-in ImageGen on 27 September 2026. All nine files are RGBA with transparent corners and intact opaque silhouettes. Thin low-alpha color fringe extends beyond the silhouettes in several files. The approved elements are being composited into the live HUD with data-driven overlays and focused 1080p/1440p captures. Runtime visual acceptance remains open. The original generated outputs and the prompt set are recorded in [PROMPTS.md](PROMPTS.md). Do not ship directly from candidate status.

## Earlier independent visual review — 27 September 2026

A separate Luna High critic compared the initial nine at intended HUD size with the five approved mocks. **Before the user's approval, the critic requested rework.** The shared issue is a pale/yellow low-alpha fringe that can read as permanent glow. The console has an oversized blank right wing; the initial tab was too broad and was superseded by a compact v2; the system card has a permanent yellow stripe; the orbit plaque pointer faces the wrong way. The galaxy card rows and rail panes need layout adjustment at game size. This critique remains useful for runtime sizing and alpha-edge checks. The later user approval authorizes using these exact PNGs in the live HUD.

The tab v2 improves silhouette ratio from about 3.8:1 to about 2.2:1. It retains substantial transparent canvas and a minor pale alpha fringe; review in the actual HUD remains open.
