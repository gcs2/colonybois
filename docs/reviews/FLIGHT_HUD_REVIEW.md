# Flight instrument implementation review

> Review/evidence record; captures and prompts do not imply acceptance or a current production instruction. [Documentation map](../README.md).

## Shared palette interaction checkpoint

Current palette is adjacent to ship condition, supports collapse and category-relative number keys, and uses the same item path for weapons and counted packs. Tab browses categories without cancelling orders. Wrong-view tools explain their restriction. Menus and explicit pause block commands. 518 assertions plus UI checks passed; 46 HUD checks include 16 new palette/input/consumable cases. Bright-terrain backing and selected weapon/inventory/collapse captures are part of rendered inspection; no native-input or final art approval is implied.

The rendered review restores its arranged pause state after focus loss, which otherwise prevents scripted selection while the window is in the background. Production focus-loss pause remains unchanged. Capture assertions verify the intended category/selection/collapse before saving images.

## Superseding user review: rejected

The user rejected both rounded-panel and custom angular cockpit candidates. Rendered checks below are historical implementation evidence, not approval. Read [SPORE_INTERFACE_CONTRACT.md](SPORE_INTERFACE_CONTRACT.md). Current functional correction removes the footer, uses Escape for utilities, uses inventory for energy packs, explains shield controls in Equipment and separates weapon selection from attacking. The cockpit artwork is still temporary; a new visual direction must follow Spore state/reference analysis.


23 September 2026. Candidate implementation following [Spore GUI forensics](../research/SPORE_GUI_FORENSICS.md). This is an engine-rendered interface pass, not an approved AAA result. Ship, planet and terrain assets are unchanged.

## Historical first implementation

- New `flight_hud.gd` owns the composed instrument layout; encounter commands retain simulation authority.
- Lower-left local chart samples the surface height function. It shows ship heading, contacts, scanned status, selection and actual navigation destination. Click contacts to approach/use; click open ground to fly. In orbit it shows a local schematic with the actual planet/ship positions and a landing command. The full globe atlas remains separate.
- Survey, Cargo and Environment categories contain real equipment. Browsing preserves the selected tool and active order; equipping cancels the old operation. Shortcuts 1–4 reveal the equipped category.
- Energy and equipment share one housing. Sample cradle occupancy opens the actual inventory. Secondary controls moved to the lower rail; pause and inspection are explicit.
- Target feedback distinguishes range, approach, execution, completion, cancellation and unavailability. Resource failures explain their cause before use. Full validation remains in the model.
- Four original shaded SVG tool assets and an original nine-slice housing replace the thin line-icon/flat-panel treatment in the main instruments. See [asset specification](../../art/specs/flight_instruments_v1.json).
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

## Current engine recapture — 25 September 2026

Ran `tests/review_flight_interface.gd` on Godot 4.7.2 from the `codex/morrow-mining-production` branch using the compatibility renderer. It generated 17 actual scene captures under ignored `artifacts/flight_ui_*.png`, across 1920×1080, 2560×1440 and 1280×720. The isolated scripted campaigns did not load or write player saves. This is rendered-state evidence, not native input, motion timing, sound, performance or fun verification.

Root visually inspected the surface 1080p, orbit 1440p, palette, low-energy refusal, active approach, uncharted atlas and Escape-menu captures against the inspected Spore surface frame at 1805.490461 seconds and the surface/orbit Field Instruments composition references. On the surface, the local chart appears in the right scale and the orbit state switches to an altitude gauge; this preserves the user's scale-specific map rule. The live surface still has broad, bright low-detail ground, repeated small props and weak contrast in the upper status copy. Tool glyphs remain temporary and small. Orbit keeps the terrain chart hidden, but the live planet/ship/world composition and separated lower instrument groups remain much less resolved than the orbit reference. The sampled shortage and approach states expose clear text reasons and cancellation, but their static captures do not verify responsive input or travel feel.

The user-rejected type, planet art and provisional glyph/material treatment remain rejected. These captures do not approve the mock's art or close V01/N01/N02/N05. No independent visual-critic tool was available for this pass, so there is no second critic verdict and no acceptance credit. Keep the matched reference/current/mock comparison open; the next pass should cover orbital approach and scale-change motion states, not add decorative HUD breadth.

## Surface console assembly recheck — 26 September 2026

The focused pass raises the console 27 logical pixels, attaches the category cards to the top inset, gives the selected card a warm-gold edge, expands each live inventory cell to 60 px with 6 px gutters, and reduces the right status segment to 144 px inside the continuous housing. The ALT line remains a compact altitude readout in the status header. The chart's dark charcoal field uses terrain-derived relief and water color; it remains a surface-only map.

Actual-renderer captures at 1920×1080 and 2560×1440:
- artifacts/visual-critic-surface-pass/integrated-after-world-hud-20260926/hud-console-1080/surface-mining-after-1080p.png
- artifacts/visual-critic-surface-pass/integrated-after-world-hud-20260926/hud-console-1440/surface-mining-after-1440p.png

The focused test_flight_hud.gd passed 78 assertions, zero failures, in 13.02 seconds on Godot 4.7.2 Compatibility. Its map-color checks were adjusted from the superseded bright palette to retain explicit minimum land/water and relief contrast for the approved charcoal instrument. The independent critic passes console composition and map readability at both resolutions. Remaining local refinements are pictorial weight/contrast for three tool glyphs and stronger casing bevel/inner-rim depth.

Whole-screen verdict remains rejected. The flat, sparse world and oversized/cropped props remain far from the approved Terraform T2 target; seam name/progress/action remain detached from the world marker. This is an isolated synthetic mining state, so its inventory and Marks are not content-quality evidence. T2 means climate T-score; it is not ALT and not the biosphere tier. These captures do not show T-score or establish Morrow's current T2 state.

This is renderer and focused-test evidence only. There was no native-input playtest, exported-build review, performance measurement, user acceptance, or fun review.

## Seam-target feedback integration — 26 September 2026

The mining action card now follows the projected resonant seam with a visible leader. The compact card sits lower and farther from the ship; its action button shows a short verb such as “Mine” while the explanatory copy retains the full tool description. The live remaining count and exhausted state remain tied to the surface model.

Actual-renderer captures at 1920×1080 and 2560×1440 are in `artifacts/visual-critic-surface-pass/hud-seam-integration-20260926/`. `tests/test_encounter.gd` passed 56 assertions, zero failures, in 20.53 seconds. That focused run also exposed and fixed JSON round-trip normalization for depleted-seam counts and a malformed legacy-save migration that accessed a missing position without returning an error.

Independent review passes console footprint, dark surface chart readability, and the tethered seam callout at both resolutions. This is a narrow component verdict only; the whole scene is rejected. A direct mock/runtime recheck found that the five runtime tab cards sit wholly inside the shell and read taller, narrower, and flatter than the canon's wider, lower cards raised over the shell edge. The mock cards are approximately 408 px wide and 44 px tall at 1920×1080; runtime cards are approximately 369 px wide and 50–54 px tall. These are visual estimates, not pixel-perfect layout requirements.

Other V01 deltas remain: tool images 4–6 are dim outline glyphs rather than object-like pictorial art; the synthetic capture has mostly empty cells and cannot establish realistic inventory density; condition bars are segmented and display percentages rather than continuous fills with current/max values; the cargo toast and separate reassurance line do not match the compact discovery pill; the Marks plate sits left of the canon's far-right anchor. ALT remains a compact altitude readout, distinct from Terraform T-score. The seam tether is only one target state; relay/fauna/scan and unavailable/out-of-range feedback need matched states before claiming contextual HUD coverage.

The terrain remains a broad flat tan/brown field with sparse vegetation and oversized/cropped props, far below the approved lush Morrow target. These captures and assertions do not establish user acceptance, native-input playability, performance, export quality, or fun. Godot emitted the existing `SpatialMaterial` `specular` remap warning.

## HUD layout and camera view study — 26 September 2026

The surface HUD was compared directly against the approved Morrow runtime image and the geometry study [flight-hud-layout-target-20260926.svg](../../art/visual-canon/flight-hud-layout-target-20260926.svg). This SVG is a layout mock only: its background and small glyphs are placeholders, and it is not approved world art. The implemented layout adjusts the console height and position, tab attachment and dimensions, inventory cell rhythm, and the surface chart footprint in scripts/flight_hud.gd. The glowing pictorial cards, their dots, shallow proportions, close spacing and selected edge are preserved.

The isolated Godot 4.7.2 Compatibility scene was captured at 1920×1080 and 2560×1440. The current captures are in the ignored local folder artifacts/visual-critic-hud-view-study/runtime-final/ as hud-current-1080p.png and hud-current-1440p.png. Direct comparison and independent review pass the HUD layout at both sizes: the right console occupies about 34% of viewport width and 24.5% of height, while the surface chart is about 14% wide and 22% high. The category cards are connected to the shell, the status and Marks remain legible, and no clipping or overlap was found. The critic's verdict is limited to HUD geometry and rendering.

The capture used an isolated synthetic state with sparse cargo and minimal surface content. It does not establish final inventory content, visual quality of the whole world, native input, accessibility, responsiveness, fun, exported-build behavior, performance, or user acceptance. The broad low-detail ground remains rejected and is the next visual gate.

A same-scene camera comparison tested pitches 0.36, 0.40, 0.45 and 0.55 radians at 1920×1080. Review and independent critique retain 0.36 as the default: 0.40 offers little improvement, while 0.45 and 0.55 reduce horizon and landmark headroom and make the view increasingly tactical. The temporary pitch edits were restored; scripts/encounter.gd remains unchanged. No tilt-shift blur was tested. The project uses Godot Compatibility, and Godot documents native depth-of-field support only for Forward+ and Mobile renderers; a renderer migration is outside this decision and is not approved. See [Godot 4.7 CameraAttributesPractical](https://docs.godotengine.org/en/4.7/classes/class_cameraattributespractical.html).

No automated tests were run for this layout and view study. The full-world review and player acceptance remain open. Keep the current composition as an exploration game and proceed to reusable, seeded whole-planet enrichment with consistent revisits and existing Tripo asset reuse.
