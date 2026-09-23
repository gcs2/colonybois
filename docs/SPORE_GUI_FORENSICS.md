# Spore Space Stage GUI: forensic review

23 September 2026. Research checkpoint, not a shipped interface redesign. This supersedes the earlier assumption that recolored buttons and generic drawers would establish the desired visual direction. Related work: V01–V04, V05, D01, P01 and I01 in [TASK_BOARD.md](TASK_BOARD.md).

## Finding

Our interface organizes software features. Spore's interface organizes the experience of operating a ship in a living world. The useful lesson is the relationship between spatial navigation, tools, cargo, planetary conditions and characters. Copying its blue frames would miss that relationship.

The next pass should replace the composition and interaction model before adding more decorative panels. Preserve the working commands, saves and atlas. Build original instruments around them.

## Evidence register

**Observed** means inspected game pixels. **Documented** means described by a source. **Interpretation** means our design reasoning. These are deliberately separate. Research images are references, not production assets; none are included in the game or committed here.

| ID | Evidence inspected | What it establishes / limits |
| --- | --- | --- |
| M | [EA/Maxis manual distributed on Steam](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/17390/manuals/manual.pdf?t=1642702281), printed pp. 46–51; PDF sheets 26–28 | Original diagrams and control explanations. Rendered locally for inspection. Not proof of every retail animation or input edge case. |
| G1 | [Travel screenshots](https://www.gamepressure.com/spore/traveling-to-another-planet/zb151d), image IDs 893351328 and 893351359 | Full surface HUD and homeworld service conversation. Polish localization, small resolution. |
| G2 | [Terraforming screenshot](https://www.gamepressure.com/spore/setting-up-colonies-and-planet-upgrades/zc151e), image 893378781 | Close view of the planetary instrument and ecosystem slots. |
| G3 | [Contact screenshot](https://www.gamepressure.com/spore/other-civilisations/zd151f), image 893408890 | Portrait, dialogue, relationship cue and reply composition. |
| G4 | [Trade/collection screenshots](https://www.gamepressure.com/spore/trade/z81520), images 893447343, 893447359 and 893447375 | Shop, badges and cargo transaction controls. The second image actually shows badges despite misleading page alt text. Pixel inspection matters. |
| V | [GameplayDump: Spore: Space Stage Gameplay](https://www.youtube.com/watch?v=bVmJpkFRXFw), sampled frames and adjacent states | Recorded gameplay, not our own input test. Version/mod configuration unconfirmed. Timecodes below refer to the player's displayed time; samples are not a frame-accurate motion analysis. |
| S | [Community ModAPI SpaceGameUI documentation](https://modapi-docs.sporecommunity.com/class_u_i_1_1_space_game_u_i.html) | Primary documentation of the community's reverse-engineered interface, not an official Maxis design specification. |

### Documented structure — M

The manual places the planetary minimap at lower left and ship health/energy at lower right. Tool categories select palettes; slots carry counts and shortcuts. Planetary navigation and terraforming share an instrument location. The wheel traverses surface, orbit, system and galaxy scales. Galaxy controls include map filters, while history and collection have persistent access. Tools have context restrictions. This is a hierarchy of views and actions, not merely a zoomable camera.

### Observed composition — G1–G4

**G1:** The surface screenshot leaves the center to the world. A small mission panel occupies the upper left; map and communicator sit below it. The colored tool tray adjoins the ship display at lower right. A thin bottom strip connects the two clusters. The service conversation groups repair/recharge/trade separately from larger dialogue actions.

**G2:** Temperature and atmosphere share a compact two-dimensional target with habitability rings. Plant/animal slots sit beside it. Planet name, communicator and progression remain nearby. This compact instrument exposes multiple conditions without opening a large report.

**G3:** Contact is a composed scene: creature portrait on the left, speech on the right, choices below, identity/relationship above. The world and parts of the HUD remain visible behind it. A still does not establish portrait animation behavior.

**G4:** The shop uses a dense pictorial grid, prices below items, quantity markings, dim unavailable entries and an owner-colored header. The selling area has explicit quantity controls and item details. Badges use prominent medallions, progress marks and dim undiscovered silhouettes. Exact quantity step sizes and lock conditions need direct interaction verification.

### Observed sequence — V

| Displayed time | Visible state |
| --- | --- |
| 17:38 | Ship editor, excluded from flight-HUD conclusions. |
| 41:10 | City layout editor, also a separate interface mode. |
| 47:02 | Colonist outfitter, not a Space Stage flight tool palette. |
| 52:55 | System scene; tool tray collapsed, ship/status and bottom strip remain. |
| 53:08 | Galaxy scene; hovered star has a nearby distance card; orange cargo tray open. |
| 53:26 | Communicator portrait and hover label available beside navigation. |
| 53:31 | Planet surface; lower-left geographic map and open cargo tray. |
| 53:36 | Same world; planetary instrument now shows ecological slots. |
| 53:41 | Pulled back from planet; tool tray collapsed. |
| 53:56 | System scene; a different blue palette open in the same lower-right location. |

These samples support contextual replacement and stable instrument anchors. They do **not** establish exact transition durations, easing, sound envelopes or whether every window pauses simulation. The current browser route provides visual observations; I have not listened to or analyzed its audio.

### Structural corroboration — S

The community SDK names active palettes, palette panels, a cargo palette, a current-tool panel above the ship thumbnail, terraforming ecosystem slots, star/planet tooltips and an empire-relationship rollover. That independently supports the distinction between tool selection, cargo and contextual world feedback. It does not justify importing Spore's UI files or assuming its internal code architecture should become ours.

## Why this matters for our design

The following are interpretations and original requirements, not claims that Spore implements our proposed behavior.

### 1. A coherent instrument cluster

Separate rectangles distributed around the screen make every feature compete for attention. A connected lower instrument assembly can make several functions feel like one vehicle. Its left side answers **where am I?**; its right side answers **what can my ship do?** The central world answers **what am I doing it to?**

The bridge between those questions is selection feedback. Selecting a specimen should connect its world highlight, scan knowledge, cargo capacity and applicable tool. A generic target paragraph cannot carry that entire relationship.

Keep the ship display physically adjacent to its equipment palette. Put navigation beside planetary conditions and nearby communications. Place persistent Marks and chronicle access in a quiet lower rail. Temporary warnings can interrupt that arrangement; ordinary tutorial prose should not dominate it.

### 2. Two levels of tool selection

The existing four large tool buttons will become unmanageable as abilities grow. Use category → item → world target, with a stable selected-item display. Changing category must not silently activate an ability or forget the previous selection.

For the first working revision, expose only two populated groups: **Survey** (scanner) and **Environment** (warming, deployment). Give collection a visible cargo/tractor affordance. Test whether combining tractor and deployment under Cargo is clearer before freezing the taxonomy. Do not fill the bar with clickable empty Weapons, Colonization or Diplomacy tabs to imply finished features.

Specify slot states separately: available, hovered, selected, unavailable in this view, insufficient energy, exhausted consumable, executing and cooling down. Locked-but-discoverable is a progression state, not the same as temporarily unavailable. Every unavailable state needs a concise reason. Cooldowns and consumables must come from actual model state.

### 3. Color needs hierarchy and material

Our mint/apricot/honey/violet palette is a useful start, but thin icons on uniform flat cards remain generic. Use original filled silhouettes, internal shading, shaped sockets, restrained raised edges and an identifiable active category. Give the housing a consistent material treatment. Highlight the useful object, not every border.

Design icons at their actual display size. A scanner should read as an instrument; a seed as a living object; cargo as a physical container. Distinguish silhouette before adding detail. Keep a small readable text family for values and explanations. Do not adopt a decorative alien alphabet for routine reading.

Color should reinforce categories, selected state and urgency without confusing them. Keep our honey energy identity; adopting Spore's exact bar colors or frames is unnecessary. Every warning needs shape/text as well as hue.

### 4. Navigation should feel continuous

The current default wheel changes altitude and Ctrl-wheel changes camera distance. This works against the desired expectation of pulling back to discover a larger world. Prototype wheel-based semantic zoom; retain dedicated altitude keys and an accessible remapping option. Keep transitions cancellable where practical, preserve the target and explain view-dependent tools.

Our full globe atlas remains useful for survey planning. It does not replace an always-available compact navigation instrument. The HUD map should support nearby orientation without opening a pause panel. The atlas should handle the entire globe, survey layers and destination planning. Later system/galaxy views must share persistent ship/location state through I01; breadcrumbs alone do not solve integration.

### 5. Cargo is part of the action loop

Quick cargo inspection should show physical slots, quantity and capacity while preserving context. Full inventory can supply provenance, habitat requirements and equipment details. Keep ship cargo and remote storage visibly separate.

An item should suggest what can be done with it: inspect, deploy, sell or assign to an automatic route. Only show actions that have implemented command paths. A trade quote must state location, buyer, quantity, unit value, total and capacity consequences. Our supply-chain game needs finite demand and repeat-route setup; those are deliberate additions, not Spore behavior inferred from a screenshot.

### 6. Diplomacy is an encounter with a character

The communicator should identify who is calling before the conversation opens. A dedicated scene should make room for an expressive original representative, its institution, mood and stated purpose. Government, nation, species and planet remain separate entities.

Choices need consequences and obligations in plain language. Repairing a ship, purchasing equipment and agreeing to defend an ally are different decisions and should not be identical list rows. A treaty preview can explain commitments; a shop needs a transaction layout. Shared visual components are useful, but a universal drawer is not the appropriate final presentation for both.

### 7. Planetary conditions should guide actions

Our ecology has more potential complexity than a single habitability score. Do not immediately expose every variable. A compact instrument should answer: what is limiting the environment, what is stable, and what would this selected intervention change? Expand to habitat/trophic details on demand.

Pair a proposed intervention with a bounded preview, energy/material costs and any known ecological or diplomatic consequences. Distinguish measured information from unknown conditions. Never reveal unscanned species through the interface just because the simulation knows them.

### 8. Motion and sound carry state

Author separate feedback for hover, equip, valid target, unavailable action, execution, cancellation and completion. An equip sound should not fire repeatedly while hovering. A failed operation must not play a success cue. Stop looping thrust/tool audio on pause, cancellation and scene changes.

Candidate motion targets for our prototype: short button depression, selected tool settling into its socket, restrained charge movement, portrait greeting/reaction and navigation scale transition. Exact timings are design hypotheses to tune in engine. Reference video sampling has not measured them. User-approved AI hum candidates still need acquisition and integration; no purchase is authorized.

## Audit of the current build

| Current implementation | Problem exposed by the research | Required correction |
| --- | --- | --- |
| `encounter.gd::_make_ui`, top row of utility buttons | Constant application-menu density | Consolidate secondary access; preserve a compact persistent status rail. |
| Four large buttons in the bottom center | No scalable category/item hierarchy | Data-backed palettes and a selected-tool socket adjacent to the ship. |
| Left energy panel and right navigation text | Information dispersed; no live spatial instrument | Navigation/conditions left, ship/equipment right; atlas remains an expansion. |
| `_pick`, `_activate_selected` and approach orders | One click can hide multiple steps behind automatic travel | Show selected target, approaching, in range, executing and cancelled states distinctly. |
| `_show_popup`, cargo and systems builders | Useful real data, generic presentation | Preserve commands; separate quick cargo, detailed equipment and character conversation layouts. |
| `_inspection_open` pauses all local time | Inspection policy is blanket, not a deliberate mode distinction | Keep current safe behavior until explicit policy tests exist. Palette changes should remain live; full inspection can pause with a visible indicator. This is our policy, not verified Spore behavior. |
| Wheel altitude / Ctrl-wheel zoom | Larger world hidden behind a modifier and threshold | Prototype scale navigation without breaking left-handed bindings. |
| Existing flat vector icons and StyleBoxFlat framing | Color change without authored visual identity | Original shaded icon family, housing kit and complete interaction states. |
| Separate field and strategic state | Interface promises exceed navigable world | I01 remains a hard dependency for connected system/galaxy navigation. |

## Production slice and acceptance gates

Implement one coherent flight HUD slice before another feature expansion:

1. Extract HUD presentation from the large encounter script; commands stay validated in the existing model. Define `NavigationInstrument`, `ToolPalette`, `ShipInstrument`, `TargetFeedback`, `ContactPanel` and shared tooltip components. These are presentation responsibilities, not new simulations.
2. Author a composition board at 1440×810 and 1280×720 using our actual ship/world capture. Include ordinary flight, active scan, cargo-full failure, low energy, planetary conditions and incoming contact. Clearly label mock states that do not yet exist.
3. Produce an original UI asset kit: housing corners/edges, category tabs, slot sockets, filled tool icons, target markers, small status symbols and portrait framing. Supply normal/hover/selected/unavailable/pressed states and scalable source files. Reuse components without making every screen identical.
4. Implement the live palettes, quick cargo, ship energy and target-state feedback against existing mechanics. Keep full inventory, equipment and atlas accessible. No fake hull meter, combat tabs or upgrade transactions.
5. Native-input playtest the loop below. Capture ordinary and worst-case screens. User review determines whether the visual direction succeeds.

| Playtest | Acceptance condition |
| --- | --- |
| Change tools and scan a subject | Player can identify active tool, valid target, range/approach and completion without opening help. |
| Collect with full cargo | No stock lost; reason appears at the relevant slot/target; no success animation. |
| Run out of energy | Cost and shortage understandable before retry; no negative values or false completion. |
| Pause during an operation | Visual, sound and simulation states agree; resume does not duplicate the action. |
| Inspect inventory and return | Correct items/capacity; original target retained; explicit pause preserved. |
| Open atlas and choose the basin | Same geography and location; actual navigation; unknown regions remain unknown. |
| Switch scale or cancel approach | Selection and tool availability remain coherent; no stray clicks reach the world through UI. |
| Bright terrain, night terrain, small window | Labels/slots readable; no clipping; flight target and ship remain visible. |
| Repeated hover/equip/cancel | No sound spam, stuck highlights, leaked particles or accumulating UI nodes. |

## Remaining forensic questions

This is a substantially deeper reference baseline, not a claim of exhaustive retail reverse engineering. Still required: dense late-game tool palettes; exact lock/cooldown rendering; sustained combat target feedback; shop quantity edge cases; native zoom/input behavior; conversation animation sequencing; notification prioritization under simultaneous events; and a real listening audit. Manual/wiki mouse-button descriptions conflict, so bindings should be verified in the retail game rather than copied from an uncertain secondary description. Pre-release demo screenshots must not be mixed silently with retail evidence.

The research changes the next implementation target: a composed, contextual instrument system with authored assets. The current build remains a prototype until that composition is implemented and reviewed in motion.
