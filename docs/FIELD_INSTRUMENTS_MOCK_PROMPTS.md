# Field Instruments complete-view mock register

Status: UI direction selected by the user; individual screens remain candidates. Environmental fidelity reference is approved. This is a prompt register, **not a claim that every image has been generated**. Generation uses the built-in imagegen tool. Specs include actual implemented view families plus explicitly marked proposed/legacy states. Not every shown mechanism is implemented. See GALAXY_CHECKPOINT_PENDING.md for uncommitted implementation status.

24 September correction: first aggregate/synthesize actual Spore references, our current captures and our proposed versions. Pause further generation until this comparison foundation is established. Use larger physical tool artwork (about 40% more area, 18% linear) within compact controls rather than larger panel shells. Keep reference2's labels/units/layout out of unrelated scales; no parsecs on a surface chart. No foreground blur concealing gameplay. A galaxy target inside a 3 pc reach must actually lie inside its projected range. See VISUAL_FIDELITY_FEASIBILITY.md for renderer facts and production limitations.

Shared prompt:

Use case: ui-mockup. Original Frontier Worlds game interface design mock, NOT a shipped screenshot. One complete 16:9 game screen at 1920x1080 composition, no outer poster border.
Reference image 1 establishes APPROVED environmental fidelity: attainable stylized real-time Godot 3D, simple repeated meshes, matte materials, directional light, original creepy-cute life. Reference image 2: use ONLY the LEFT 'FIELD INSTRUMENTS' concept as the now-approved interface direction; ignore its other two panels.
Visual system: compact matte ivory instrument housings, charcoal inset displays, tactile flat catches and shallow segmented gauges, sharply clipped corners, mustard / vermilion / muted teal / plum accents with functional meaning. Not glossy, no copper, no rounded rectangle pill buttons, no ornamental borders or giant sci-fi cockpit. Crisp contemporary humanist sans serif. Readable labels where necessary, recognizable filled item/tool symbols, hover tooltips. Keep bone housings compact, not broad white walls. No copied franchise assets or logos.
Consistent active-flight anchors: planetary local chart LOWER LEFT on SURFACE ONLY; contextual pictorial tool palette adjoins ship status LOWER RIGHT. Hull orange, energy gold, persistent reserve values. Category→item→world-target hierarchy; counts belong to individual slots. Compact communicator indicator beside navigation. Marks currency. Escape utilities are NOT a permanent bottom menu strip. No persistent selected-tool caption above the palette.
Environment complexity and UI construction should be feasible as a near-term art pass, with a few original shapes and textures. Do not imply photorealism, huge new cities, on-foot RPG or creature editor. Material polish and hierarchy, not gratuitous detail. No wall of prose. Exact key labels specified below; other tiny text can be omitted rather than invented.

## 01-surface

SURFACE EXPLORATION. Match the reference surface environment and cream/rust scout. Ship above clay/sage terrain, clustered rocks, pond, visible bell grazer feeding near mint lantern reeds. Living behavior clear but no huge creatures. Small target reticle, faint directional pointer to the relay. A compact field-instrument local chart lower left; lower right open Survey category with six pictorial slots, selected scanner. Hover tooltip 'Survey relay'. Hull '100', energy '76'. Top-left 'Morrow'. A small three-lamp discovery cue. No black full-width bottom bar. The world must occupy over 80% of the view.

## 02-surface-combat

SURFACE COMBAT. Same ship, terrain, instrument placement. One distinct hostile sentry on rocky rise, one hostile small flyer, clearly telegraphed amber ground impact area; player ship evading sideways with short exhaust. Restrained bright impact sparks. Weapons palette expanded in lower right with laser, seeker, shield, repair pack icons; cooling-down slot visibly swept. Hull '62', energy '41'; damage warning near hull, not covering world. Local surface chart lower left with hostile symbols. Hover tooltip 'Shield · 30 energy'. No cinematic explosions hiding targets.

## 03-orbit

ORBITAL FLIGHT. Large attractive stylized globe of Morrow fills left half, believable coherent continents/ocean/cloud shapes and terminator, original cream/rust scout in foreground right, one modest orbital service tender. Attractive attainable procedural globe, no spectacular photoreal NASA texture. Pale site marker visibly fixed to a continent. Three tiny positional affordances for approach/service/contact. Tool tray lower right is collapsed; hull and energy gauges stay. Lower left a compact altitude/scale instrument, NOT planetary terrain radar. Tooltip near tender 'Dock · home recharge free'. 'Morrow orbit'. No recharge button floating in the HUD.

## 04-system

SYSTEM NAVIGATION. Entire screen is an obliquely viewed 3D solar system, a warm star and three distinguishable small globes on subtle elliptical orbit tracks, one tiny ship marker. Full-screen scene, not a mini window. Field-instrument controls occupy only small corners. One selected planet outlined with close tooltip 'Nacre I · 3 energy'. Mouse destination interaction directly on planet. Compact scale/orientation gauge lower left; no planetary local chart. Hull/energy lower right. Distant outer orbit clipped naturally at screen edge. Clear readable scale, not an astronomy diagram full of labels.

## 05-galaxy-local

GALAXY LOCAL NAVIGATION. Full-screen oblique spiral-arm neighborhood. Stars have obvious depth through perspective. A soft galactic dust band recedes toward a far luminous core. Small explored pocket has colored, named stars; unknown stars remain dim with no leaked planet/faction information. One engine range boundary is a circle IN THE GALAXY PLANE, projected as a clearly tilted ellipse around the ship, never a face-on screen circle. Range '3 pc', selected star '2.4 pc'. One prospective course, no permanent hyperlane graph. Selected star has adjacent tactile triangular activation tab, NO Jump rectangle/card. Compact bone instrument pieces at lower corners, no terrain minimap. Camera can orbit freely. Stars and ring must share perspective.

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
