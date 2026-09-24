# Alien colony combat kit

Original creepy-cute frontier colony kit, built from the existing modular primitives. Reuse three architectural roles across the six authored enemy holdings; this is not six independent cities or final approved art.

| Role | Footprint / height | Silhouette and function |
| --- | --- | --- |
| Civic hall | 6 × 6 m / 6 m | Tapered, offset stacked rotunda; paired lens windows and a roof fin. A circular civic pavement joins east/west streets. This is the surrender target; the hall's destruction ruins the colony. |
| Habitation terraces | 6 × 6 m / 4 m | Two staggered broad dwelling wings, recessed shared courtyard and grouped warm windows. Housing survives capture only if it survived the battle. |
| Export works | 5 × 6 m / 5 m | Wide low workshop, three unequal process stacks, material bins and a high service spine. The existing colony export module owns output after capture. |

Use matte faction-colored shells, dark slate foundations, pale window light and neutral paving. Avoid shiny copper, identical one-square buildings and realistic human skyscrapers. Asset origins sit on the terrain, not at the center of the combat hit volume. City labels appear on selection/hover, not above every building permanently.

Damage behavior: surviving structures retain their model; destroyed structures collapse to a low foundation/debris silhouette. Surrender changes a raised pennant and stops defenses. Annexation changes ownership markers without spawning another hub over the old hall. Ruin leaves broken infrastructure and no working port. Visible turret/patrol models reuse the existing combat kit; their real HP remains in `surface_combat.gd`.

Implement in `colony_structure.gd`; build from simple authored dimensions and existing material helpers. Instantiate only the currently viewed settlement. Validate hall/terrace/workshop readability together, click targets, weapon beams/blasts and surrender controls in Godot at 1080p/1440p. Native feel and final art approval remain open.
