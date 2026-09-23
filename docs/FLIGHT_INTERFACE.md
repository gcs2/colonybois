# Flight interface: color, interaction and navigation

23 September 2026. **Revised target after [Spore GUI forensics](SPORE_GUI_FORENSICS.md), with a partial implementation.** Colored vector icons, warm panels, real inventory, equipment inspection and the shared planetary atlas are implemented prototypes. Cargo / I, Systems / K and Atlas / M pause the local encounter while open. The first composed HUD and live local navigation are now implemented candidates; see [rendered review](FLIGHT_HUD_REVIEW.md). Planetary-condition toggles, dedicated trade/conversation layouts, semantic zoom, power routing and upgrades remain unfinished. The research supersedes the previous generic-drawer composition. Preserve readable world space and original creepy-cute character.

## Visual language

Use warm ivory labels on deep plum/charcoal instrument housings, with restrained copper edging. Make useful instruments colorful rather than tinting every surface blue. Proposed semantic palette:

| Meaning | Color | Additional cue |
| --- | --- | --- |
| Hull and repair | Coral `#F08072` | Hull silhouette, value and damage warning |
| Energy and power | Honey `#F3C567` | Bolt/charge icon and charge bar |
| Survey and ecology | Leaf mint `#86CF9A` | Scanner/leaf icon and sweep |
| Cargo and fabrication | Apricot `#EBA66D` | Crate silhouette, amount and capacity |
| Navigation | Periwinkle `#A9A7EF` | Waypoint arrow and route line |
| Communication | Orchid `#DCA0CF` | Expressive portrait and message badge |

Color never carries meaning alone. Reserve red warning animation for actual urgent conditions. Selected tools gain a small physical-looking depression, brighter icon and short approved sound; hover is quieter. Offer readable text and UI scaling, reduced motion and independent sound controls. Check contrast over bright clouds as well as night-side terrain.

## Flight HUD

- Lower left: compact live navigation instrument with location, map/planetary-conditions toggle and nearby contact indicator. Planet Atlas expands into the existing full globe; it does not replace local orientation. Keep world coordinates and knowledge consistent.
- Lower right: ship display, real energy and selected-tool socket beside a category/item palette. Systems opens from the ship. Do not display an invented hull value before health exists.
- Tool palette: icon-first categories with populated, functioning items; counts, shortcut, selected and unavailable states remain distinct. Hover explains range, cost and result. Preserve selection across category changes. Do not present empty weapon/colony categories as implemented features.
- Lower rail: quiet persistent Marks, rank/chronicle access and secondary controls. Avoid a permanent row of large application-menu buttons across the sky.
- Contextual world feedback: selection marker and brief target information, then explicit approaching, in-range, executing, cancelled and completed states. Explain failure near the relevant action. Keep tutorial guidance compact and optional.
- Inspection: quick cargo belongs with operational instruments; detailed inventory/equipment can use expanded panels. Diplomacy needs a character-led conversation layout; commerce needs a quantity/price transaction layout. They share components, not one universal drawer.
- Scale: prototype wheel-based semantic zoom through supported views; retain altitude bindings and remapping. Unimplemented system/galaxy transitions must not pretend to navigate. Shared strategic state remains a dependency.

Use the forensic report's production slice and acceptance matrix. Shaped housings, filled shaded icons and authored interaction states are required; recoloring flat default widgets is not the completed art direction. Frame-by-frame animation and listening review remain open.

## Inventory: usable cargo, not a numeric label

Cargo opens a readable item grid with distinct silhouettes and category tabs: resources, specimens, artifacts and equipment. Selecting an item reveals quantity, origin, survey knowledge and supported uses. Show occupied versus available capacity with a documented unit; never mix mass and slot counts without explaining the rule.

Existing cargo binds to real field stock. Unimplemented specimen/artifact types must not appear as owned items. Equip and hotbar assignment use validated commands. Trade actions require a reachable contact/port and actual demand. Discard requires an explicit amount and confirmation; deployed specimens follow habitat/tool rules. Current full inspection pauses flight and simulation consistently. Keep that behavior until the revised mode policy is tested: palette selection stays live; detailed inspection may pause with an explicit indicator. Later unified simulation must share that policy. This policy is our design choice, not a verified Spore behavior.

## Systems: equipment with consequences

Show a readable ship diagram with selectable propulsion, reactor, scanner, tractor/cargo and utility hardpoints. Record installed module, condition where simulated, operating state, energy cost and compatibility. Weapons/shields enter this screen only when functional.

The initial panel can inspect current equipment and select supported tools. A later power-routing command should trade engine performance against scanner/utility output within a finite budget; do not put nonfunctional sliders into the playable HUD. Unsupported repairs/upgrades explain the missing facility or prerequisite. Persistent installations and cooldowns belong in shared simulation state, not UI nodes.

## Whole-planet map

Provide a rotatable, zoomable globe of the **entire planet**, with the ship and known sites attached to stable latitude/longitude coordinates. A selected site's detail can show a local surface inset. This is not a stretched image of the existing 100×100 encounter patch.

Geography and survey coverage now exist; resources, settlements/jurisdictions and route layers remain future work. Reveal surveyed information gradually. Fog should distinguish unknown, remotely sensed and visited regions. Display multiple nations where scenario data provides them; a species does not imply a single planetary owner.

Selecting a known destination shows distance, travel/resource requirements and available actions; committing a route changes actual navigation. Existing Morrow Basin must be labeled as the available landing site until more surfaces exist. Other mapped regions may be geographic context but must not promise playable terrain that has not been built. Globe, orbital planet and local terrain must share a geography seed and site coordinates; no rotating continent beneath a floating marker.

System view displays planets, moons and travel routes; galaxy view displays surveyed stars, reach and political/trade connections. Switching map scale preserves selection and location. Planet-scale navigation requires persistent planetary geography and the shared-state integration task; the current local encounter alone cannot honestly provide it.

## Review sequence

1. Produce the composed HUD and interaction-state boards specified in the forensic report, using real world captures and clearly labeled future states.
2. Author original instrument housings, category tabs, icon silhouettes, target markers and their interaction states.
3. Implement palettes, quick cargo and target feedback using existing validated commands; retain the functioning atlas, inventory and equipment inspection.
4. Review native input, legibility, cancellation, shortage feedback, sound and motion at normal and small window sizes.
5. Integrate strategic state and add actual subsystem tradeoffs and richer content. Do not expand decorative UI faster than its mechanics.

The generated orbital image is a lighting/composition reference. It does not approve all of its ship details, typography or realism, and it does not replace an engine implementation or the original creepy-cute art direction.
