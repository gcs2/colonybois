# Focused Field Instruments HUD assets v6

Updated 28 September 2026. These selected ImageGen raster assets provide the existing flight-console family. The user specifically praised the five raised glowing tab cards; preserve their shape, color, dimensions, spacing, inset and hover treatment.

- `inventory-console-shell.png` supplies the six-by-two quick-slot tray and adjacent hull/energy bay. Live meters and item slots remain stateful Godot controls.
- `category-tab-states.png` is the original five-column idle/selected atlas, retained for provenance. `category-tab-states-v2.png` removes the diagonal face slashes while preserving the card silhouettes, bevel, spacing, palette and glow; the live HUD now consumes v2. Godot keeps buttons, focus, input, tooltips and category data live.
- `slot-selection-overlay.png` supplies the existing restrained item-selection accent.
- `marks-balance-plate.png` supplies the Marks housing.

The quick palette shows twelve items per page. Overflow uses discrete previous/next controls with a page counter; this is separate from the full cargo drawer, which scrolls when its current category exceeds the visible area.

The v2 tab edit received an independent asset-only pass for removing the extra face lines. This does not verify its live crop, hover or selected-state rendering. These are integrated component assets, not acceptance of the whole HUD. Compare matching live states at 1920×1080 and 2560×1440 against the approved Field Instruments mocks and retain separate interaction, motion and user-acceptance gates.
