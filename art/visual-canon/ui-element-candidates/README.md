# UI element image candidates

Eight initial UI-shell candidates, seven newer focused shell candidates, and five v2 category-icon cutouts were generated with built-in ImageGen on 27 September 2026, using the approved images in the parent folder as composition/style references. This is the shared review home for designers and implementation agents; the approved ground-truth images in the parent folder remain unchanged.

These are candidates, not final art approval. The five [v2 category pictograms](category-icons-v2/README.md) are wired as base-state textures in the isolated R01 HUD branch for review. Safe AtlasTexture regions remove unused transparent canvas while retaining clear margins around each generated mark. The shared notched tab face remains code-drawn and identical across categories. Runtime alone draws the accent glow on pointer hover; selection remains a thin non-glowing underline. Do not crop glyphs from a mock or bake hover/selection effects into their PNGs. Live text, numbers, icons, counts, routes, markers, and state remain data-driven.

## UI-shell candidates

| Candidate | Intended view | Review note |
|---|---|---|
| shared-tab-base-v2.png | Surface, orbit, approach, system | Blank face; wider than target ratio. Not used by the current runtime. |
| field-instruments-console-shell-v1.png | Surface, orbit, approach, system | Empty 6×2 wells and right status bay; not used by the current runtime. |
| surface-chart-housing-v1.png | Surface, approach | Empty surface-only chart window. |
| notification-toast-shell-v1.png | Surface, orbit, approach, system | Blank icon and text lanes. |
| marks-balance-plate-v1.png | All flight/map views | Empty icon and value spaces. |
| system-destination-card-shell-v2.png | Solar-system map | One horizontal card with empty content bands. |
| galaxy-selected-system-card-v1.png | Galaxy map | Empty title, two planet rows, footer. |
| galaxy-status-rail-v1.png | Galaxy map | Empty meters plus four equipment cells. |

The [focused shell v3 set](focused-shells-v3/README.md) covers surface, orbit, approach, system and galaxy, but none of those shell images is wired into the game. The earlier v1 category-icon trial remains local and is superseded by the tracked v2 set. See [PROMPTS.md](PROMPTS.md) for initial prompt provenance and [v2 prompts](category-icons-v2/PROMPTS.md) for the current marks. Generated import sidecars and capture output remain local and must not be committed.
