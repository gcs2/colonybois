# Flight interface: color, interaction and navigation

23 September 2026. **Specification, not implemented behavior.** The user liked the new orbital concept but explicitly requested a more colorful UI, inventory, ship subsystems and a whole-planet map. Preserve readable negative space while increasing useful interaction. Keep original creepy-cute character; avoid generic icy military instruments.

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

- Upper left: location and a compact breadcrumb **surface → planet → system → galaxy**. Each level opens a meaningful view; unavailable destinations explain why.
- Lower left: compact ship condition/energy cluster. Clicking the cluster opens Systems. Do not display an invented hull value before health exists.
- Lower center: colorful pictographic hotbar, grouped into survey, interaction and ship equipment. Hover explains range, resource cost and result; selection shows valid targets. Tool feedback comes from actual command state.
- Lower right: local radar with a clearly labeled Planet Map control. Radar is a nearby navigation instrument; the whole-world map is a separate screen.
- Right edge: Cargo, Systems, Comms and Chronicle controls with optional shortcuts. Use a single expandable drawer, not a wall of permanently open panels.
- Contextual target card: name, distance, scan state and relevant actions. Expand detail on request. One primary tutorial prompt at a time.

## Inventory: usable cargo, not a numeric label

Cargo opens a readable item grid with distinct silhouettes and category tabs: resources, specimens, artifacts and equipment. Selecting an item reveals quantity, origin, survey knowledge and supported uses. Show occupied versus available capacity with a documented unit; never mix mass and slot counts without explaining the rule.

First implementation must bind to existing real field stock. Unimplemented specimen/artifact types must not appear as owned items. Equip and hotbar assignment use validated commands. Trade actions require a reachable contact/port and actual demand. Discard requires an explicit amount and confirmation; deployed specimens follow habitat/tool rules. During single-player inspection pause flight and show the pause state consistently; later unified simulation must have an explicit shared pause policy.

## Systems: equipment with consequences

Show a readable ship diagram with selectable propulsion, reactor, scanner, tractor/cargo and utility hardpoints. Record installed module, condition where simulated, operating state, energy cost and compatibility. Weapons/shields enter this screen only when functional.

The initial panel can inspect current equipment and select supported tools. A later power-routing command should trade engine performance against scanner/utility output within a finite budget; do not put nonfunctional sliders into the playable HUD. Unsupported repairs/upgrades explain the missing facility or prerequisite. Persistent installations and cooldowns belong in shared simulation state, not UI nodes.

## Whole-planet map

Provide a rotatable, zoomable globe of the **entire planet**, with the ship and known sites attached to stable latitude/longitude coordinates. A selected site's detail can show a local surface inset. This is not a stretched image of the existing 100×100 encounter patch.

Start with terrain/biome, survey coverage, resources, settlements/jurisdictions and route layers. Reveal surveyed information gradually. Fog should distinguish unknown, remotely sensed and visited regions. Display multiple nations where scenario data provides them; a species does not imply a single planetary owner.

Selecting a known destination shows distance, travel/resource requirements and available actions; committing a route changes actual navigation. Existing Morrow Basin must be labeled as the available landing site until more surfaces exist. Other mapped regions may be geographic context but must not promise playable terrain that has not been built. Globe, orbital planet and local terrain must share a geography seed and site coordinates; no rotating continent beneath a floating marker.

System view displays planets, moons and travel routes; galaxy view displays surveyed stars, reach and political/trade connections. Switching map scale preserves selection and location. Planet-scale navigation requires persistent planetary geography and the shared-state integration task; the current local encounter alone cannot honestly provide it.

## Review sequence

1. Establish colored instrument components and clickable drawers using real existing data.
2. Review flight readability and inventory interactions in engine at normal and small window sizes.
3. Add persistent planet coordinates and honest map coverage, then route actions and shared-state integration.
4. Add actual subsystem tradeoffs, reviewed sound/motion and richer equipment content.

The generated orbital image is a lighting/composition reference. It does not approve all of its ship details, typography or realism, and it does not replace an engine implementation or the original creepy-cute art direction.
