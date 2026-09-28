# Focused HUD raster assets v7

Updated 28 September 2026. The user approved the selected v7 raster treatments for integration after reviewing the generated mock assets. This is an implementation checkpoint, not approval of the whole HUD.

## Integrated assets

- `inventory-modal-shell-candidate.png` backs the live cargo drawer in `scripts/encounter.gd` through a nine-slice. Live text, counts, tabs, item actions and cargo data remain Godot controls. Its `ScrollContainer` uses vertical auto-scroll; the 12-cell quick palette remains separately paged.
- `hud-plaque-v1.png` is the cleaned, nine-slice backing for Relay notices, the allied fleet strip and target context in `scripts/encounter.gd` and `scripts/flight_hud.gd`.
- `fleet-scout-icon-v1.png` is the raster fleet pictogram used in the escort control.
- `hud-plaque-candidate.png` retains the generated source from which the cleaned v1 plaque was derived.

The five praised lower glowing tabs and their proportions, spacing, colors, icons, hover states and live hit areas remain unchanged. The v7 console replacement was not selected because it would change that protected slot geometry.

## Evidence and remaining review

`artifacts/hud-v7-integration/populated-flight-1920.png` and the 2560 capture show the generated plaques in the closed HUD. The corresponding inventory captures show real campaign-earned freight and supplies. Those images predate the final cargo inset correction. Headless control geometry after that correction reports a 590×500 drawer, 460×380 scroll viewport and 460×378 current cargo content, with 65/65/60/60 logical margins; current content fits and longer categories can use the vertical scrollbar. This is layout evidence, not a rendered visual confirmation.

An independent recheck finds the modal-shell material fits the Field Instruments family and the five lower tabs remain intact. It also finds the shared plaque's bright cyan catches heavier than the full-screen mock and suggests they can read as a cargo-category accent; the user-approved asset remains in place pending a current GPU capture and user review. The target label still competes with the scene at 1080p.

The open inventory has no matching approved full-screen mock yet. A post-padding 1920/2560 GPU capture and a populated state that exceeds the current scroll viewport are still needed before calling the integration visually verified. Current Windows GPU launches fail inside Godot with `winrt::hresult_error`; do not treat headless geometry as a visual pass.
