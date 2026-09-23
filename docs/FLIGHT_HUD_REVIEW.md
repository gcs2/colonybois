# Flight instrument implementation review

23 September 2026. Candidate implementation following [Spore GUI forensics](SPORE_GUI_FORENSICS.md). This is an engine-rendered interface pass, not an approved AAA result. Ship, planet and terrain assets are unchanged.

## Implemented

- New `flight_hud.gd` owns the composed instrument layout; encounter commands retain simulation authority.
- Lower-left local chart samples the surface height function. It shows ship heading, contacts, scanned status, selection and actual navigation destination. Click contacts to approach/use; click open ground to fly. In orbit it shows a local schematic with the actual planet/ship positions and a landing command. The full globe atlas remains separate.
- Survey, Cargo and Environment categories contain real equipment. Browsing preserves the selected tool and active order; equipping cancels the old operation. Shortcuts 1–4 reveal the equipped category.
- Energy and equipment share one housing. Sample cradle occupancy opens the actual inventory. Secondary controls moved to the lower rail; pause and inspection are explicit.
- Target feedback distinguishes range, approach, execution, completion, cancellation and unavailability. Resource failures explain their cause before use. Full validation remains in the model.
- Four original shaded SVG tool assets and an original nine-slice housing replace the thin line-icon/flat-panel treatment in the main instruments. See [asset specification](../art/specs/flight_instruments_v1.json).
- A completed click-operation no longer requires an extra cancel click before selecting the next subject. World and chart selection use the same command path.

## Rendered state board

Run `tests/review_flight_interface.gd` with the pinned Godot engine to regenerate these local captures. They use isolated scripted state, never the player's save. These are real rendered scenes with arranged test states, not native input recordings.

| Capture | Review purpose |
| --- | --- |
| `artifacts/flight_ui_hud.png` | Ordinary flight; compact prompt, local chart, selected equipment and real cargo. |
| `artifacts/flight_ui_palette.png` | Browsing Environment while the scanner remains equipped. |
| `artifacts/flight_ui_shortage.png` | Thermal tool selected, 10 energy available, 25 required; operation unavailable. |
| `artifacts/flight_ui_approach.png` | Actual pending approach command. |
| `artifacts/flight_ui_cargo.png` | Expanded inventory with real onboard sample quantity. |
| `artifacts/flight_ui_systems_720.png` | Equipment drawer and underlying HUD at 1280×720. |
| `artifacts/flight_ui_orbit_hud.png` | Orbital chart, surface tools unavailable, return command. |
| `artifacts/flight_ui_atlas_uncharted.png` | Whole-globe survey fog. |
| `artifacts/flight_ui_atlas_charted.png` | Completed orbital chart with actual site coordinates. |

Visual review caught undersized tool icons and a ProgressBar minimum-size overlap. Both were corrected. The capture helper now updates visibility when switching views, preventing stale surface labels in scripted orbital captures.

## Verification and limits

332 assertions plus UI checks pass: prior 313 plus 19 HUD integration checks. Those exercise command effects, category browsing during approach, switching tools, chart navigation, scan completion, follow-up subject clicks, cancellation, pause/inspection guards, energy/cargo shortages and orbital landing. The audio regression caught a missing hover-signal connection in the replacement buttons; it is restored without adding duplicate equip cues.

Native input, accessibility, listening and human art/fun approval remain open. The current surface is still a small demonstration patch. This pass does not implement combat, a ship portrait, richer system mechanics, planetary-condition instruments, semantic scale zoom, dedicated diplomacy/trade scenes or strategic-state integration. The existing sound bank remains rejected pending replacement with approved AI assets. Keep those tasks visible; do not call this the finished interface.
