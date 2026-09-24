# Field Instruments complete-view mock register

> Review/evidence record; captures and prompts do not imply acceptance or a current production instruction. [Documentation map](../README.md).

Status: UI direction selected by the user; individual screens remain candidates. Environmental fidelity reference is approved. This is a prompt register, **not a claim that every image has been generated**. Generation uses the built-in imagegen tool. Specs include actual implemented view families plus explicitly marked proposed/legacy states. Not every shown mechanism is implemented. See GALAXY_CHECKPOINT_PENDING.md for uncommitted implementation status.

24 September correction: first aggregate/synthesize actual Spore references, our current captures and our proposed versions. Pause further generation until this comparison foundation is established. Use larger physical tool artwork (about 40% more area, 18% linear) within compact controls rather than larger panel shells. Keep reference2's labels/units/layout out of unrelated scales; no parsecs on a surface chart. No foreground blur concealing gameplay. A galaxy target inside a 3 pc reach must actually lie inside its projected range. See VISUAL_FIDELITY_FEASIBILITY.md for renderer facts and production limitations.

Navigation composition supplement: `tests/review_field_navigation.gd` is a code-native schematic study, not image generation. It draws eight states at1080p/1440p with compact contextual summaries and a fixed ship instrument, using temporary existing glyphs. No generated backdrop or production art is claimed. Read the navigation fixture section in VIEW_MOCK_COVERAGE.md for exact limitations and output paths; this supplements rather than replaces 04/05 environmental targets.

Shared prompt:

Capacity supplement: tests/review_field_capacity.gd draws six palette states at1080p/1440p using existing HUD paging and actual control icons/counts, plus explicitly synthetic palette_fixture.gd entries for18-slot overflow. Reuses surface-review-background-v1.png; no new imagegen call or new playable item. See VIEW_MOCK_COVERAGE.md for limitations.

Projection supplement: tests/review_projected_galaxy.gd uses the actual StarGraph renderer with a compact review-only overlay. No new image generation or raster compositing is involved. Outputs cover known/unknown, rotated and underside views at1080p/1440p; VIEW_MOCK_COVERAGE.md owns evidence and limits. This demonstrates correct projection/footprint while exposing current world-art deficits, not replacing the environmental target.

Use case: ui-mockup. Original Frontier Worlds game interface design mock, NOT a shipped screenshot. One complete 16:9 game screen at 1920x1080 composition, no outer poster border.
Reference image 1 establishes APPROVED environmental fidelity: attainable stylized real-time Godot 3D, simple repeated meshes, matte materials, directional light, original creepy-cute life. Reference image 2: use ONLY the LEFT 'FIELD INSTRUMENTS' concept as the now-approved interface direction; ignore its other two panels.
Visual system: compact matte ivory instrument housings, charcoal inset displays, tactile flat catches and shallow segmented gauges, sharply clipped corners, mustard / vermilion / muted teal / plum accents with functional meaning. Not glossy, no copper, no rounded rectangle pill buttons, no ornamental borders or giant sci-fi cockpit. Crisp contemporary humanist sans serif. Readable labels where necessary, recognizable filled item/tool symbols, hover tooltips. Keep bone housings compact, not broad white walls. No copied franchise assets or logos.
Consistent active-flight anchors: planetary local chart LOWER LEFT on SURFACE ONLY; contextual pictorial tool palette adjoins ship status LOWER RIGHT. Hull orange, energy gold, persistent reserve values. Category→item→world-target hierarchy; counts belong to individual slots. Compact communicator indicator beside navigation. Marks currency. Escape utilities are NOT a permanent bottom menu strip. No persistent selected-tool caption above the palette.
Environment complexity and UI construction should be feasible as a near-term art pass, with a few original shapes and textures. Do not imply photorealism, huge new cities, on-foot RPG or creature editor. Material polish and hierarchy, not gratuitous detail. No wall of prose. Exact key labels specified below; other tiny text can be omitted rather than invented.

## 01-surface

### Populated surface candidate v2 — 24 September

Output: `artifacts/field-instruments-review/01-surface-populated-v2.png`, built-in imagegen. Reference roles: existing 01-surface-v1.png for endorsed environment/material direction; scout_surface_95.png as an explicitly dated current-state comparison, not a style to reproduce. Source inspected first: Spore surface at 1805.490461 seconds, recorded as surface-1805-v3.png, plus the navigation recaptures and manual. This is a capacity/design fixture with illustrative equipment; not newly playable content or a completed navigation state set. Independent review found oversized instruments, ambiguous hover/selection and tooltip overlap; v3 below partially corrects these. Neither is user-accepted.

Exact generation prompt:

```text
Use case: ui-mockup.
Create one complete 16:9 Frontier Worlds game screen, ideally 1920x1080 or higher. This is an original design candidate, not a shipped screenshot. Reference 1 is our existing surface candidate: preserve its stylized real-time environment fidelity, cream/rust scout, clay ground, mint lantern plants, pond and small bell-shaped grazers. Reference 2 is our current implementation capture ONLY to understand present content and the overly scattered UI that needs replacement; do not copy its panels, labels everywhere or pale terrain.
Make an actually coherent navigation/tool HUD in the approved FIELD INSTRUMENTS direction. Compact matte ivory manufactured instrument housings, flat charcoal inset trays, clipped corners, subtle mechanical catches, clean humanist sans serif. No shiny copper, rounded wells, glowing blue desktop windows, persistent selected-tool caption, spreadsheet lists, giant white walls, permanent full-width bottom strip, or heroic cinematic complexity.
Landscape fills the entire screen behind instruments, visible horizon and repeated modular rock/flora clusters continuing past the pond. Foreground sharp enough for gameplay; no depth-of-field blur. Player ship small enough for context but clearly readable. Original creepy-cute bell grazers near the pond, no new character portraits or new species. One world relay with fine selection brackets and small nearby tooltip 'Survey relay' plus '18 m'; no random labels everywhere.
Top left only 'Morrow' with small SURFACE text. Top right very compact '248 Marks'. Lower left LOCAL SURFACE CHART, small approx 190x170 at1080; depicts actual pond shoreline, relay and triangular ship; distance scale '50 m'. No parsecs, star charts, range circle or galaxy icons on this map. A small terrain/ecology tab pair on housing edge, no whole second panel.
Lower right ONE joined tool-and-ship assembly maximum 620x230 pixels at1080. World must still visibly dominate >80%. Compact pictorial category tabs along top edge: survey dish (active amber), cargo crate (teal), weapon emitter (vermilion), sprout (sage), radio (plum). No text category title floating above.
Expanded SURVEY/EQUIPMENT tray has 12 clearly separate dark clipped-square slots in 2 rows of6. Filled original miniature physical tools, not thin line doodles: lens scanner, sample gripper, survey buoy, mapping drone, probe capsule, binocular sensor on row1; energy cell, repair canister, shield puck, locked silhouette, locked silhouette, empty slot on row2. All content is a design capacity fixture, not promised implemented. Selection is fine mustard corner ticks on scanner, not round background. Counts only on finite consumables: buoy 2, drone1, capsule3, energy cell2, repair canister1. Locked slots have small padlocks. No made-up price labels. Tool artwork is larger inside its slots, about18% greater linear coverage than the earlier candidate, leaving clear gaps between slots. Show pointer over energy cell and immediate small charcoal tooltip directly ABOVE THAT SLOT: 'Energy pack' / 'Restores 40 energy' / '2 in cargo'. It must point to the energy cell, not a different control.
Adjacent right edge of same assembly narrow status instrument with Hull orange gauge '100/100', Energy gold gauge '36/100', small altitude 'ALT 12 m'. Gauges must match those values: hull full, energy about one-third. No passive recharge indicator. Small compact communications icon alongside the gauges. No application utility links.
Place a short low-priority notification near upper-left under world name 'Relay discovered' with tiny scanner symbol; no tutorial essay.
Keep lettering clean and minimal, original physical tool art crisp and well separated, attractive but feasible simple 3D world. This is a realistic near-term art and layout candidate, not photorealism. Do not add logos, character portraits, huge cities, on-foot characters, UI captions, extra controls or fake badges.
```

SURFACE EXPLORATION. Match the reference surface environment and cream/rust scout. Ship above clay/sage terrain, clustered rocks, pond, visible bell grazer feeding near mint lantern reeds. Living behavior clear but no huge creatures. Small target reticle, faint directional pointer to the relay. A compact field-instrument local chart lower left; lower right open Survey category with six pictorial slots, selected scanner. Hover tooltip 'Survey relay'. Hull '100', energy '76'. Top-left 'Morrow'. A small three-lamp discovery cue. No black full-width bottom bar. The world must occupy over 80% of the view.

### Populated surface correction v3

Output: `artifacts/field-instruments-review/01-surface-populated-v3.png`, built-in imagegen edit of v2. V2's independent critic review identified oversized instruments, indistinguishable hovered/selected styling, tooltip overlap and foreground blur. V3 reduces footprint and moves the tooltip out of the tray; its hover colors remain incorrect. These are unaccepted form/capacity studies, not implementation instructions.

Exact correction prompt:

```text
Edit this existing Frontier Worlds surface mock. Preserve the landscape, ship, relay, creatures, colors, camera, and all existing UI data. One targeted HUD correction pass only; this is a design mock.
The HUD is too big. Reduce entire lower-right assembly INCLUDING category tabs, tool tray and gauges to 70% of its current width and 70% of its current height, anchored 16px from bottom/right edges. It must occupy approximately x=1090..1904,y=808..1064 in a 1920x1080 normalized composition, at most 43% screen width and24%height; do NOT enlarge icons independently or spread controls back out. Preserve exact 2x6 layout and all 12 content states. Reduce lower-left chart to65% of its present width andheight anchored16px frombottomleft. Maintain legible short labels.
STATE CORRECTION: Scanner (row1col1) is the ONLY equipped tool, with mustard corner ticks. Energy pack (row2col1) is merely hovered: use subtle thin IVORY outline, NO yellow corners and no yellow underline. Remove unexplained green highlight on gripper row1col2. Keep pack count2, repair1, buoy2,drone1,capsule3. Hull100/100full andEnergy36/100 at36%.
TOOLTIP: locate 'Energy pack / Restores 40 energy / 2 in cargo' just to LEFT of the expanded tray at the vertical level of the energy pack, outside all slots, on a compact charcoal tooltip with a tiny right-facing pointer touching the hovered cell's left edge. Do not cover the scanner or any other item. Show cursor on that energy cell. No duplicate tooltip, extra titles or explanation text.
Do not add any other controls, logo, full-width bottom bar or decorative border. Preserve matte ivory clipped housing and charcoal inset, original crisp pictorial icons. The changes should reveal more world rather than replacing it with more UI.
```

Implementation reconciliation: scripts/flight_palette.gd currently has Main tools / Environment / Weapons / Inventory and an 18-slot page. The mock's five tabs and mixed twelve-item tray are a proposed capacity fixture, not approved category semantics. scripts/encounter_state.gd defines PACK_ENERGY as 50: the mock's 40 must be corrected in any production specification. Survey buoy, mapping drone, probe, binocular sensor and gripper artwork do not establish implemented equipment. Existing scanner/collector/pack/repair/shield behaviors need their real categories, costs and availability mapped before production. Do not create new equipment merely to match the generated picture.

### Isolated inventory state prototype assets

24 September: tests/review_field_inventory.gd renders real Godot controls over an explicitly static concept background. It is not imported by any game scene. Background and supply atlas were generated with the built-in imagegen tool and copied into artifacts/field-instruments-review; the script requires those local files and reports missing assets rather than fabricating a replacement. Existing category/scanner glyphs remain temporary. The generated supply atlas is sampled in equal thirds with AtlasTexture; no raster editor or paid API was used.

Background: `surface-review-background-v1.png`, edited from 01-surface-populated-v3.png. Exact prompt:

```text
Edit the supplied original Frontier Worlds mock into a clean environment-only background for a separate UI review prototype. Preserve exact camera, ship, pond, relay, bell-shaped grazers, clay/sage palette, stylized real-time fidelity and landscape composition. REMOVE ALL interface elements: all text, all frames and panels, map, currency, tooltip, selection brackets, arrows, reticles, category tabs, inventory slots, gauges and notification. Reconstruct uninterrupted terrain where they used to be. Keep the ship, its physical exhaust and relay's physical light particles. Make foreground rocks/plants readable and sharp for gameplay, not deliberately blurred. No new characters or objects, no other changes. Output only the clean landscape at the same wide aspect ratio.
```

Supply atlas: `supply-portraits-v1.png`, original three-column image (energy, repair, full repair). Exact prompt:

```text
Use case: ui-mockup asset sheet. Original Frontier Worlds Field Instruments inventory object portraits. Create a clean horizontal 3-column by1-row texture atlas, wide3:1 aspect, equal cells. Entire background a perfectly uniform solid charcoal #242b2a. No text, numerals, captions, grids, frames, glow clouds, floor, drop shadows outside objects or extra objects. Each single object centered in its own third, same apparent size, occupies about70% cell width/height, clear margins, no overlap. These are real material object portraits rather than line icons, easy to recognize at54pixels.
LEFT cell: Energy pack. Squat removable power cell with matte bone outer clamps, graphite rectangular body, two chunky gold terminals on top, transparent amber inset with a single clear zigzag energy motif; industrial simple silhouette, no round blue potion bottle.
MIDDLE cell: Repair pack. Compact sturdy graphite field repair case, matte bone top carry handle and corner guards, a sage inset bearing a simple mechanical wrench motif. No medical red cross.
RIGHT cell: Full repair pack. Same repair family, slightly taller double-module case with two bone side latches, muted teal/sage inset and a clear double-chevron motif. Distinguishable from middle at small scale without looking like completely unrelated technology.
Lighting soft three-quarter upperleft, restrained realistic material depth, stylized miniature engineered tools, no copper ornamental border, no rounded UI wells, no cute faces. Consistent camera and materials, high-quality legible game asset sheet. Use accurate centered thirds; each contains only one item.
```

Captured outputs: states/inventory-{ready,used,empty,full,repair,keyboard,equipped}-{1920,2560}.png; per-state values and limits in states/inventory-evidence.json. These are review artifacts, not proof of 3D-world fidelity, native input, full category capacity or accepted art. The generated source images and renders remain local; code and prompt/review records are tracked.

## 02-surface-combat

SURFACE COMBAT. Same ship, terrain, instrument placement. One distinct hostile sentry on rocky rise, one hostile small flyer, clearly telegraphed amber ground impact area; player ship evading sideways with short exhaust. Restrained bright impact sparks. Weapons palette expanded in lower right with laser, seeker, shield, repair pack icons; cooling-down slot visibly swept. Hull '62', energy '41'; damage warning near hull, not covering world. Local surface chart lower left with hostile symbols. Hover tooltip 'Shield · 30 energy'. No cinematic explosions hiding targets.

## 03-orbit

ORBITAL FLIGHT. Large attractive stylized globe of Morrow fills left half, believable coherent continents/ocean/cloud shapes and terminator, original cream/rust scout in foreground right, one modest orbital service tender. Attractive attainable procedural globe, no spectacular photoreal NASA texture. Pale site marker visibly fixed to a continent. Three tiny positional affordances for approach/service/contact. Tool tray lower right is collapsed; hull and energy gauges stay. Lower left a compact altitude/scale instrument, NOT planetary terrain radar. Tooltip near tender 'Dock · home recharge free'. 'Morrow orbit'. No recharge button floating in the HUD.

## 04-system

SYSTEM NAVIGATION. Entire screen is an obliquely viewed 3D solar system, a warm star and three distinguishable small globes on subtle elliptical orbit tracks, one tiny ship marker. Full-screen scene, not a mini window. Field-instrument controls occupy only small corners. One selected planet outlined with close tooltip 'Nacre I · 3 energy'. Mouse destination interaction directly on planet. Compact scale/orientation gauge lower left; no planetary local chart. Hull/energy lower right. Distant outer orbit clipped naturally at screen edge. Clear readable scale, not an astronomy diagram full of labels.

## 05-galaxy-local

GALAXY LOCAL NAVIGATION. Full-screen oblique spiral-arm neighborhood. Stars have obvious depth through perspective. A soft galactic dust band recedes toward a far luminous core. Small explored pocket has colored, named stars; unknown stars remain dim with no leaked planet/faction information. One engine range boundary is a circle IN THE GALAXY PLANE, projected as a clearly tilted ellipse around the ship, never a face-on screen circle. Range '3 pc', selected star '2.4 pc'. One prospective course, no permanent hyperlane graph. Selected star has adjacent tactile triangular activation tab, NO Jump rectangle/card. Compact bone instrument pieces at lower corners, no terrain minimap. Camera can orbit freely. Stars and ring must share perspective.

### Local galaxy v2 edit provenance

Built-in imagegen edit, 24 September. Input:05-galaxy-local-v1.png; output:artifacts/field-instruments-review/05-galaxy-local-v2.png. Inspected source: navigation-boundary-7202-b.png for compact contextual system rows; actual comparison:artifacts/galaxy-local-1920.png. No source UI art supplied to generation. Exact prompt follows; this remains a candidate, not production art or verified camera behavior.

```text
Use case: ui-mockup. Edit the supplied Frontier Worlds galaxy concept into a revised, achievable real-time game target. Preserve the matte ivory/charcoal FIELD INSTRUMENTS material vocabulary and luminous oblique galactic arm, but simplify excessive photographic dust into softly layered translucent billboards and modest star sprites, suitable for a Godot indie game, no cinematic fantasy spectacle.
Full 16:9 gameplay composition. The world occupies over 85 percent. No outer frame, no inset world window. Galaxy exploration, not a local solar-system diagram.
Fix navigation geometry: put ship at normalized (0.43,0.55). Engine range ellipse center EXACTLY at ship, horizontal radius .24 image width and vertical radius .09 image height, tilted gently to align with galaxy plane. One known star Nacre at (.58,.52) INSIDE that ellipse. A thin prospective course connects ship and Nacre. A small label on ellipse says "3 pc"; distance caption beside Nacre says "1.9 pc". No other routes or hyperlane graph. No face-on radar circle anywhere.
Compact hover summary beside Nacre, no huge white rectangular card. About .15 image width and .14 height. Thin matte ivory mechanical rim, charcoal inset, one ivory header "Nacre". EXACTLY two rows with small planet thumbnail and labels "Nacre I" and "Nacre II". Small line "Charted system". No travel button, no Jump label, no large instructional paragraphs. White hover bracket around star, small mouse cursor nearby. Only 3-5 known stars named. Unknown galaxy stars still visible but dim, unlabelled and without faction colors; a subtle feathered explored region, no black polygon hiding galaxy.
REMOVE the entire lower-left radar/minimap from reference. Instead three very small physical map controls with recognizable ship-focus, orbit-camera and layers pictograms, without text-only button substitutes. They must not resemble a radar. No terrain minimap outside planet surface.
Lower right one compact ship/tool assembly occupying at most .34 width and .13 height: ivory outer housing, charcoal bays, three-dimensional tactile tool portraits (scanner, cargo case, weapon emitter, communication dish) with approximately 40 percent larger artwork area than reference within smaller shells. Tool portraits should feel like tiny objects, no rounded icon wells. Two thin readable gauges "HULL 100/100", "ENERGY 92/100", warm muted hull and amber energy. No unrelated counts. Don't fill entire screen bottom with UI. No shiny copper, flat blue desktop panels, neon, giant rounded buttons or ornamental sci-fi borders. Top left small "Galaxy"; top right "248 Marks".
Keep original art, no Spore assets or copied trademarks. This is a proposed design mock, not a shipped game screenshot. It must be legible at1080p. No extra explanatory annotations.
```

## 06-galaxy-overview

GALAXY OVERVIEW. Full-screen generous three-quarter view of entire spiral galaxy, luminous restrained ivory core and blue-gray dust, thousands of star specks arranged coherently. Clearly marked small explored pocket on one arm, dim unknown arms; do not black out the whole beautiful galaxy. Ship location is a tiny warm arrow. Jump range at this scale is TINY and coplanar, not a giant ring around half the galaxy. Matte ivory corner controls: miniature orientation gimbal lower left, collapsed ship condition lower right, icon controls for ship focus and map layers, tooltips. No planetary minimap, no giant destination card, no hyperlanes. Title 'Galaxy'.

## 07-planet-atlas

PLANET ATLAS / SURVEY. Globe fills screen centre with original Morrow geography, clouds, thin atmosphere and light from one side. Compact field instruments overlay screen edges, not a sub-window. Left vertical icon selector toggles resources / settlements / life / hazards. On globe show three restrained surveyed markers; unknown hemisphere slightly dimmed, no fabricated resource certainty. One attached site marker highlights 'Thawline'. Right small pictorial readings: temperature, atmosphere, water, one resource swatch. Bottom a compact scan progress instrument 'Survey 8 / 12'. No terrain local radar; world still dominates.

## 08-inventory

INVENTORY. Over the same subdued surface scene, a fold-out matte ivory expedition specimen/cargo case fills about 60% of screen. Dense pictorial grid of 24 slots with shallow square dividers, strong original item icons: alloy ingots, clear water vessel, glass prism, lantern gel, energy pack, repair canister, one contained creature. Counts sit within slots. Three icon tabs 'Cargo', 'Specimens', 'Supplies'; cargo '6 / 8'. Selected energy pack has adjacent compact action chip 'Use' and tooltip '+50 energy · consumed'. No independent Recharge button. Distinguish remote storage with one collapsed locator, do not mix its inventory. Ship/world remains visible around case. No giant text inspector.

## 09-ship-systems

SHIP SYSTEMS / EQUIPMENT. A physical matte ivory fold-out service board holds a large three-quarter model of the original cream/rust scout at centre. Four clear equipment sockets around it link to engine, reactor, hull, scanner, with equipped module pictograms and compact capacities. A narrow lower parts tray shows eight available modules, a few empty outlined slots and locked silhouettes. Select engine: clean tooltip 'Drive II · 5 pc'. Small adjacent comparison '3 pc → 5 pc'. Hull/energy actual reserve separated from maximum; no free refill implied. Tactile tab categories, no skill-tree sprawl, no wall of stats.

## 10-contact

DIPLOMATIC CONTACT. An expressive original purple soft-bodied alien merchant with short frond crown, two inset curious eyes and small manipulators occupies LEFT of a compact open communicator, shown as a stylized real-time 3D puppet, no human in an alien costume. Matte ivory iris/shutter frame, asymmetrical but calm, reaches only 65% screen. World and ship HUD remain partially visible. Right: identity 'Tavi Rill', 'Orin Consortium', warm relationship gauge. One short line: 'Your ships have opened a useful road.' Three clearly differentiated pictorial reply controls underneath: trade crates 'Trade', joined hands 'Treaty', globe 'Charts'. Small incoming-call lamp near navigational corner. No trade inventory jammed into the conversation, no long paragraphs.

## 11-dock-market

DOCK MARKET / TRADE. A physical ivory merchant counter interface over a small orbital port backdrop. LEFT merchant stock pictorial grid, RIGHT player hold grid, middle compact selected item and quantity rocker. Distinct items alloy, water, glass, resin vessels; no giant empty cards. Selected water vessel: 'Water', quantity '4', '12 Marks each', '48 Marks total'; stock '8', demand '6', player money '320 Marks', hold '4 / 8'. Clear Buy/Sell direction represented with arrow and small label on tactile controls. Disabled transaction shows a concise cause. Small alien proprietor portrait in header. Bottom icon tabs for market, equipment, supplies, warehouse, fleet. No cash register spreadsheet.

## 12-dock-upgrades

DOCK UPGRADES / SUPPLIES. Field-instrument outfitter opened as a compact equipment cabinet over orbital port. Six large pictorial product slots: drive coil, reactor, hull plating, shield emitter, energy pack, repair pack. Selected drive shows '5 pc drive', '160 Marks', tiny earned Explorer medallion. A locked 8 pc successor shows its prior-drive socket and a dim badge, not a page of requirements. Owned item visibly stamped Installed. Three shop tabs 'Equipment', 'Supplies', 'Service'. A narrow real service strip shows home recharge as 'Home service · free'; purchases remain paid. Separately held pack count '2 / 3'. Colorful useful icons, no laundry list of text buttons.

## 13-badges

BADGES / RECOGNITION. A matte ivory expedition award case over dim orbital scenery. Twelve substantial original medallions in a tidy 4-column pictorial grid; earned badges richly colored and unearned silhouettes subdued. Selected Explorer medallion enlarged modestly at right, five distinct tier pips, progress '7 / 10 systems', a pictured drive coil reward marked 'Available at shops'. A promotion ribbon small at top 'Commander'. No promise of free equipment. Explorer reward animation shown at its settled frame: mechanical case catches and restrained light, not confetti. Excellent silhouette variety, readable at normal resolution.

## 14-chronicle

CHRONICLE / HISTORY. A fold-out matte ivory navigation log with a visual horizontal voyage timeline across the middle, each event a distinct icon and small scene thumbnail: first survey, first trade, alliance, lost escort, new colony. Selected alliance event shows original merchant portrait and a short line 'Alliance with Orin', 'Day 18', 'Shared charts'. Other dated captions short. Top filter icons for exploration, diplomacy, combat, colonies. World remains visible behind. No spreadsheet rows or huge text wall, no fake full cinematic illustration for every entry. Timeline can visibly scroll with a small tactile handle.

## 15-colonies-warehouse

COLONY ADMINISTRATION / WAREHOUSE. Practical space-first management view over a modest colony landing site, not an enormous new city. Matte ivory operations board, left three compact settlement cards with a small thumbnail, population, one problem indicator and specialization pictogram. Selected frozen colony has three physical storage bins shown pictorially for materials, supplies and export stock, quantity indicators and a reserve marker. Small cargo transfer arrows connect local warehouse to player hold. One construction progress diagram shows hub → power → extractor, unfinished stages visibly scaffolding. Labels 'Thawline', 'Population 140', 'Heating shortfall'. One small income/expense summary in Marks; avoid simulating individual citizens.

## 16-freight

FREIGHT CONTRACTS. Full-screen galaxy region remains visible while a compact fold-out ivory route instrument connects two known worlds with a single highlighted shipping itinerary. At left source warehouse icon, at right destination merchant portrait and port. Along route one tiny freighter marker. Lower instrument shows pictorial commodity 'Alloy', reserve '8', load '4', freight fee '8 Marks', net '52 Marks', and 'Demand 6'. Tactile pause and recall symbols. Three small route tabs for active contracts. No permanent galactic hyperlanes, no unsupported universal destinations, no giant ledger.

## 17-fleet-defense

FLEET / DEFENSE. Original flagship and three small distinct escorts displayed in a tactical orbital staging area, still stylized achievable simple meshes. Compact ivory fleet command tray lists ships as silhouettes with individual hull bars and role icons, clear focus/assist/recall controls. A small colony defense instrument shows one actual threatened port, incoming raider bearing and defense battery ammunition, 'Arrival 24 s'. Strong threat hierarchy; one amber warning, no red alarm wallpaper. Pending attack line over world. Player ship remains clearly selectable. No six-role deep RTS battle promise; three escort records.

## 18-signals-terms

SIGNAL ENCOUNTER / CONSEQUENTIAL CHOICE. A compact field-instrument communicator reveals a small distressed convoy in the orbit scene, one expressive alien speaker. Upper panel single short sentence 'Raiders are closing on the convoy.' Two large illustrated action tiles with crisp clipped corners: shield-and-ship 'Escort', departure-and-coins 'Fund escape · 80 Marks'. Short visible consequence below each, 'Risk your hull' and 'Convoy leaves now'. A real deadline instrument '24 s'. Bottom a reserved tab 'Colony terms' with a miniature schematic showing surrender choices capture versus withdraw; no extra dialogue walls. It should read as an encounter in space, not a generic quest log.

## 19-ecosystem

PLANET CONDITIONS / ECOSYSTEM. Optional inspection instrument over the same globe, not a farming game HUD. Compact ivory scientific case displays temperature/atmosphere as a two-axis circular target, water meter and three ecological rows of pictorial slots: plants, grazers, predators. One missing slot is clearly silhouetted, with concise tooltip 'Missing grazer'. One animal card shows shed membrane and optional hunted material as alternative outputs, no compulsory nonlethal rule. A small resource tab shows a mineral outcrop and lantern gel, making mining and harvesting prominent. No new planet painting/sculpting tools. Measured versus unknown information visually distinct.

## 20-escape-settings

ESCAPE MENU / SETTINGS. One full 16:9 screen over the dimmed approved surface, showing a compact matte ivory mechanical pause folio in centre. Large legible hierarchy, Resume prominent, small icon+label actions Save, Load, Chronicle, Badges, Settings, Return to title. Settings subpage visible as a slim hinged secondary leaf with three short sliders Effects/Music/Voice, a small numpad diagram and mouse-first controls, and 'Reduced motion' toggle. Do not put every instruction on the screen. No bottom persistent menu. No rounded pills, glossy buttons or ornamental borders.

## 21-title-scenarios

TITLE / SCENARIO SELECTION. Tasteful attainable real-time game backdrop: original cream/rust scout docked on a small alien landing pad, a few lantern plants and distant planet sky, same matte stylized fidelity. A compact ivory expedition folio at left with title 'Frontier Worlds', three tactile tabs Continue / New voyage / Sandbox. New voyage shows two illustrated postcards 'Morrow' (alien campaign) and 'Sol' (human start, visibly marked Planned). Sandbox leaf contains three compact icon toggles Reveal galaxy / Grant Marks / Free construction; clear separate save marker. No suggestion unfinished Sol scenario is already playable. No giant cinematic city or elaborate painted poster.

## 22-urban-ledger

URBAN SUPPORT MODE / LEDGER AND COVERAGE. Optional legacy city-mode design target, not current space-first production priority. Isometric stylized city district built from a small reusable modular kit, coherent streets with one circular civic junction and buildings of varied footprints; do not claim a whole 120000-person city is rendered. Compact ivory zoning palette below with a rectangular drag preview, clear service-coverage rings on ground. Side fold-out civic ledger shows three understandable rows Income / Services / Net in Marks, four service pictograms for water, health, fire and education, demand bars for habitat/industry/services. One small advisor portrait. No individual citizen simulation, no dense spreadsheet. Main city occupies 75%.

## 23-motion-storyboard

MOTION STORYBOARD, three large consecutive frames across one wide board, EACH based on the approved surface and FIELD INSTRUMENTS UI. Title 'Boarding the expedition'. Frame 1 '0 ms': world already visible and interactive, separated compact ivory instrument sections just outside bottom corners. Frame 2 '240 ms': left chart housing and right tool/ship housing glide inward along subtle mechanical rails, two tiny catches align; a restrained motion arrow, no page of notes. Frame 3 '700 ms': catches shut, amber energy segments illuminate, tool tray unfolds and a tiny ready lamp glows. A small inset shows communicator iris opening to the original purple merchant. Cute believable physical assembly, theme-park-like welcoming presence but no copied Disney or Star Wars designs. No literal seat belts covering gameplay, no cockpit blocking centre. Tiny footer 'Skippable · reduced motion'. This is a storyboard, not a claim that motion is implemented.
