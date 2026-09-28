# UI element image candidates

Eight initial UI-shell candidates, seven newer focused shell candidates, and five v2 category-icon cutouts were generated with built-in ImageGen on 27 September 2026, using the approved images in the parent folder as composition/style references. This is the shared review home for designers and implementation agents; the approved ground-truth images in the parent folder remain unchanged.

The earlier v1/v3 shell experiments remain candidates. The user approved the separate [focused v5 set](focused-elements-v5/README.md) for live HUD use on 27 September 2026; runtime composition and whole-scene acceptance remain open. The five [v2 category pictograms](category-icons-v2/README.md) are wired as base-state textures in the isolated R01 HUD branch for review. Safe AtlasTexture regions remove unused transparent canvas while retaining clear margins around each generated mark. The shared notched tab face was code-drawn in the prior checkpoint; the approved v5 image face now replaces it in the live HUD. Runtime alone draws the accent glow on pointer hover; selection remains a thin non-glowing underline. Do not crop glyphs from a mock or bake hover/selection effects into their PNGs. Live text, numbers, icons, counts, routes, markers, and state remain data-driven.

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

The [v4 pictorial cutout candidates](pictorial-cutouts-v4/README.md) add isolated Inventory, Marks, system-action and galaxy-equipment artwork. The Energy Pack portrait and Marks emblem are now used in the live flight HUD; other v4 cutouts remain candidates. The [v5 surface exploration cutouts](pictorial-cutouts-v5/README.md) supply separate scanner, collector and mining-tool pictures for the live surface tool grid; rendering at game size remains pending a safe Godot review.

## Status readability study — 27 September 2026

`status-pod-readability-v1.svg` is a native-vector type-size comparison against the approved whole-screen surface reference and the current status-bay capture. Its proposed HULL/ENERGY labels and values use 12 px text; ALT uses 14 px. An independent critic approved the proposal for implementation and then reviewed the integrated 1920×1080 and 2560×1440 runtime captures, finding the readouts clearer while the bay, signal lane, inventory spacing, and five glowing tab cards retain their geometry and materials. This is a scoped readability pass, not a new screen canon or acceptance of the whole HUD/world. The saved preview is ignored runtime-review output; keep only the vector source in Git.

## Surface chart legibility study — 27 September 2026

`surface-chart-legibility-v1.svg` compares a restrained and a high-contrast treatment of the live sampled chart terrain, plus a quieter selected-cell cue. Independent pre-review preferred the restrained option and required an in-situ view retaining the real chart housing, controls, markers and runtime state. The implementation applies the reviewed modest contrast/saturation lift to sampled terrain only; live geography, contacts, scale, heading and pointer targets remain runtime-driven. Selection uses warm corner marks and a base rule instead of a bright full-cell outline. Independent review of the integrated 1920×1080 and 2560×1440 populated-campaign captures passes this scoped treatment and finds the housing, side controls and five raised glowing tabs preserved. This is not whole-HUD, interaction, or world acceptance; keep screenshots and the composite mock in ignored/local review output.

## Inventory count hierarchy study — 27 September 2026

`inventory-count-hierarchy-v1.svg` compares the current 14 px count with a narrow dark outline at the same size and a larger 16 px upper bound. Independent pre-review recommends the same-size outline and rejects the larger option as too prominent. The integrated HUD applies a one-pixel dark text outline to the existing live count labels without changing count size, cell geometry, pictograms, shortcuts or tabs. A campaign-earned repair pack was consumed through the production model to render the longest 20-second cooldown suffix; independent review confirms `× 0 · 20s` fits within each cell at 1920×1080 and 2560×1440 without obscuring icons, shortcut hints, neighboring cells or the status pod. The actual cooldown captures and in-situ board remain in local ignored review output; this does not establish native input or whole-HUD acceptance.
