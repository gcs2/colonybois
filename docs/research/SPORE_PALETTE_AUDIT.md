# Space Stage palette and input audit

> Reference research; observations, proposals and evidence gaps are not implementation status. [Documentation map](../README.md).

23 September 2026. Companion to the [ten-state review board](../ui-review/index.html) and [interface contract](../reviews/SPORE_INTERFACE_CONTRACT.md). This separates reference taxonomy, observed behavior and proposed implementation. It does not approve a new art direction.

## Evidence and the distinction we previously missed

[SporeWiki's Ship Tools](https://spore.fandom.com/wiki/Ship_Tools) groups tools into eight families: socialization, weapons, main tools, colonization, atmosphere, sculpting, coloring and ship abilities. Permanent tools, consumables and passive upgrades are different usage types. Those families are not proof that every upgrade is a clickable palette action. The wiki is indexed but its full page was blocked during this audit.

The [community SDK's SpaceGameUI](https://modapi-docs.sporecommunity.com/class_u_i_1_1_space_game_u_i.html) independently identifies active palettes, a separate cargo panel, current-tool display above the ship thumbnail, and active effects. It exposes ecosystem slots and star/planet information separately. This is primary evidence about the SDK's reverse-engineered structure, not a complete official UI specification.

The [EA control reference](https://www.spore.com/comm/tutorials/controls) specifies Tab/Shift-Tab for palette cycling, 1–9 for tools, Ctrl-number for second-row slots, Y for communications and contextual Escape. Its arrow/wheel descriptions differ from the [manual](https://shared.steamstatic.com/store_item_assets/steam/apps/17390/manuals/manual.pdf?t=1642702281). Preserve the user's arrow/numpad flight controls; do not blindly replace them with one conflicting source.

The manual explains category → tool → target, when applicable. The [weapon-tools category](https://spore.fandom.com/wiki/Category%3AWeapon_tools) places Energy Pack in weapons. The user's instruction to use a pack as an inventory item takes precedence over reproducing that exact placement. Our generic Recharge button was neither approach.

## Current code versus required behavior

Shared palette checkpoint (23 September 2026): commands remain in the scene/model; `flight_palette.gd` supplies presentation entries for the four existing field tools, energy weapon and owned pack. This is an interaction implementation, not an approved final skin.

| Responsibility | Current implementation | Remaining gap |
| --- | --- | --- |
| Categories | Main tools, Environment, Weapons and Inventory share one adjacent palette; only working entries | Complete reference families and equipment content; local Environment tools are not planetary terraforming |
| Keyed slots | Current-category 1–9; Ctrl-number addresses second row; empty slots do nothing | 18 slots/page and paging tested with a 27-entry fixture; native review and actual wider catalog remain |
| Tab | Tab/Shift-Tab cycle categories without touching selection/target/order | Native retail-equivalence and input-remapping review |
| Collapse | Item area hides; categories, equipped-tool identity and ship condition stay fixed | Original icon toggle now present; final open/close motion and sound |
| Weapon | Shared item entry selects without firing; target click issues model command | More weapons, view restrictions and acquisition paths |
| Consumable | Counted pack in quick Inventory palette and full inventory; real model checks prevent repeated spending | Wider consumable catalog and dedicated inventory artwork |
| Cargo | Two sample cradles, separate surface store | Unified galaxy cargo and wider item capacity/identity |
| Passive upgrades | Remain in Equipment inspection, never fake tool slots | Ownership/prerequisite catalog and meaningful installs |
| Unavailable item | Context, pause, count, pack cooldown, and energy hints; target-specific reason stays at target | Full unlock/purchase presentation |
| Acquisition | Four field tools and lance installed at start; packs purchased; shield salvaged | Badge-gated shops and wider discovery/purchase paths |
| Modal input | Scene rejects commands during inspection/pause before another render | Native accessibility and full map hierarchy review |

Surface/orbit transitions restore the last field tool; entering orbit browses Weapons without auto-equipping or attacking. Quick palette use stays live; full inventory inspection pauses. These are explicit current behaviors, not claims about every retail pause rule.

## Implementation contract for the next palette slice

Separate `browsed_category`, `selected_item`, `selected_target`, `active_order` and `palette_expanded`. Browsing does not replace selection or spend resources. Selecting an active tool updates its icon/cursor and cancels incompatible orders. Clicking a valid world target invokes the model command. Using a consumable is a self-targeted inventory action with a count, not automatic flight to a dock. Passive upgrades cannot be activated.

Render from a shared entry containing stable ID, reference family, interaction type, supported views/targets, owned quantity or installed status, cost, cooldown, icon, tooltip and acquisition/unlock requirements. Keep command validation in the authoritative model; a disabled button is not a safety check. Reference names belong in the parity ledger; original names must remain understandable in game.

Acceptance behavior:

- Palette changes and collapse preserve the selected item, existing order, health, energy and cargo.
- Selecting a weapon does not shoot; selecting a passive upgrade does not issue an order.
- Current-palette number keys resolve the same item as clicking its slot; empty slots do nothing.
- Hover reports the reason an item cannot be used. Charges and cooldowns are attached to that item, not a detached counter.
- An inventory pack consumes exactly one owned unit and shows its effect. Repeated input cannot spend it twice.
- Every view keeps the same ship identity, even where most items are unavailable.
- Escape utilities, left-handed mouse behavior and arrow/numpad access survive the change.

Do not implement unavailable base-game features as inert buttons to fill the palette. Keep their gap status visible in the reference ledger and make working entries use the same scalable presentation.

## Board and validation

`art/specs/space_stage_interface_v2.json` supplies ten states and an explicit category/coverage matrix. `docs/ui-review/data.js` is its browser-readable mirror; regenerate it with `powershell -ExecutionPolicy Bypass -File tools/BuildUIReview.ps1` after editing the specification. The board switches between required layout, source reference and current capture, with clickable region contracts. Wireframes are deliberately not a visual-art proposal. No Spore art is packaged into the game.

Static verification passed: JavaScript syntax, ten unique states, DOM IDs, source references, local capture existence and 1600×900 region bounds. In-app browser navigation to the local board was blocked by its URL policy. **Browser interaction and rendered layout remain unverified.** Do not substitute these checks for a browser or human review. Current game captures can be regenerated by tests/review_flight_interface.gd; they are ignored artifacts, not portable reference assets.

Remaining evidence: early/late retail category ordering, per-tool view restrictions, exact cursor semantics, open/close motion, sounds, incoming-message priority and pause rules during quick palettes versus deeper inspection. The board makes those gaps explicit rather than assuming the prototype's choices are the reference behavior.

Latest visual/capacity checkpoint: [UI_ICON_VOCABULARY.md](../reviews/UI_ICON_VOCABULARY.md). Local chart is surface-only. Original icons, two-row pagination, 1080p/1440p renders and 4K geometry are now covered; fixtures are not playable content.
