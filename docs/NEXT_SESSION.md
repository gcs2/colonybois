# Resume here

## Optional orbital signals — latest gameplay checkpoint

Read [SPACE_SIGNAL_ENCOUNTERS.md](SPACE_SIGNAL_ENCOUNTERS.md). Orbital surveys reveal two physical contacts: Nacre's optional convoy commitment resolves through real combat or a paid escape; Kestrel's guarded registry requires a six-second, eight-energy scan before a public/private ownership-evidence decision. Timers run offworld only after commitment, failures/abandonment have explicit costs, and terminal outcomes cannot be farmed. Captain 1 opens an alternate paid reactor path. Snapshot v15 preserves encounters and migrates older campaigns without free rewards. Existing artwork/audio remain candidates; no planet coloring or sculpting was added.

Validation: full regression suite passed with 60 signal checks, followed by the expanded 67-check suite after fixing scan persistence through scene initialization. Rendered actual orbit, offers, scan, decision and badge views at 1080p and 1440p; compact copy keeps all initial options visible. Native input/fun and final presentation approval remain open.

Playable build: **build/versions/20260923-210207/FrontierWorlds.exe** through Play.cmd. Final signal, shared-session, flight, planet-map and system-chart checks passed after the scan-preservation fix. Exported-pack flight startup smoke passed.

Next: **W01 empire hostility and raids**, integrating current relations, colonies, fleet losses, trade access and chronicle. Start with visible threats and a consequential defense response; avoid a parallel combat simulation or invisible colony damage. Keep remaining personal-ship equipment and full mission breadth tracked. Do not expand ecology, coloring or terrain editing.


## Latest scope correction — planet editing skipped

23 September 2026 user scope correction: skip coloring and terrain sculpting; further planet-modification tools are not a current priority. Existing climate/ecosystem behavior stays intact. T02/T03 are explicit exclusions from the agreed delivery scope, not missing work to revive automatically or completed features. Further T01 expansion is deferred. Focus next on exploration, trade, diplomacy and consequential spaceship encounters.

The uncommitted coloring implementation, icons, tests and snapshot-v15 changes were discarded at the user's request. At that scope-correction checkpoint, the playable and save format remained the prior badges checkpoint (snapshot v14); no coloring feature shipped. The later signals checkpoint above independently introduces v15. Older next-step instructions below are historical where they conflict with this correction.

Previous next step (now implemented as the bounded pilot above): **E02 optional space encounters and consequences**, integrated with E01 exploration and D01 diplomacy. Start from the existing wreck and contact systems: discover an optional situation during flight, choose a consequential response with a visible cost/risk, resolve it through ship or diplomatic actions, and preserve its reward/failure/history. Avoid deliveries, compulsory gardening and additional planet-editing tools. Keep connected flight, readable UI, audio and native playtest gates active.

## Badges and master promotions — latest checkpoint

Read [EXPEDITION_PROGRESSION.md](EXPEDITION_PROGRESSION.md). Ten five-tier families now recognize actual exploration, trade, combat, agreements, completed hubs, surveys, distinct species, ecosystems and climate improvements. Climate maxima prevent oscillation farming; durable agreement/ecosystem IDs prevent repeat awards. Cumulative points drive ten master-rank thresholds and an additional paid-drive eligibility path. Other new alternatives connect distinct activities to hold, hull, reactor and climate equipment. No free items or energy refill. Snapshot v14 preserves recognition, pins and notices with atomic migration/validation.

The badge case provides tier stars, progress, selected-family explanation, pinning and real shop links. A bounded animated notice uses the existing achievement cue. Native feel, final art/audio, full reference badges/achievements, late-rank reachability and master-rank fleet capacity remain open. The extra Naturalist/Cartographer families do not replace baseline artifact or discovery duties.

Validation: **1,262 assertions plus UI checks**, covered by the full-suite run through surface combat, corrected fleet/progression reruns, and the remaining regression suites. Final badge-to-shop sizing changes passed 51 progression, 50 HUD and 49 commerce checks. Actual case/reward/notice renders were inspected at 1080p and 1440p; fixed stale wide-panel bounds and recognition overlapping inspection views. Playable build: **build/versions/20260923-201614/FrontierWorlds.exe** through Play.cmd. Exported-pack flight startup smoke passed.

Superseded next step: T03 coloring and T02 sculpting were skipped by the user. Follow the latest scope correction above.

## System navigation — latest checkpoint

Read [SYSTEM_NAVIGATION.md](SYSTEM_NAVIGATION.md). J or outward orbital zoom now opens the current star and its actual planetary destinations. Mouse destination clicks use the shared travel cost/timer; the marker, energy and progress read that same journey. Known stars in the sector offer View system, and scale controls support arrows/numpad. Real survey/knowledge gates, shared climate globes and surface-only local charts remain intact. Escape/menu guards immediately block departure; restored local travel returns to the correct view. Snapshot v13 is unchanged.

Validation: the final full suite passed **1,211 assertions plus UI checks**, including 41 system checks. Actual 1080p/1440p overview, selection, transit and sector captures were inspected. Corrected caption overlap, undersized icons and false paused transit feedback. This is schematic system navigation, not orbital physics, seamless traversal or native/player presentation approval.

Playable build: **build/versions/20260923-195000/FrontierWorlds.exe** through Play.cmd. Exported-pack flight startup smoke passed.

Next: **P01 progression breadth and master-rank/shop integration**, using the audited reference inventory. Tie the growing set of actual exploration, trade, diplomacy, settlement, collection, terraforming and combat outcomes into persistent badges and visible useful unlocks. Check source conflicts before claiming exact reference thresholds. Preserve alternate peaceful paths and avoid repeat-action farming. Continue weapon/support/world-manipulation families afterward; don't expand the ecology corpus or spend another checkpoint solely reskinning navigation. Native flight/HUD/audio gates remain open.

## Specimen expeditions and ecosystem stability — latest checkpoint

Read [PLANET_BIOSPHERE.md](PLANET_BIOSPHERE.md). Eighteen original role-covering species now connect scanning, paid tractor collection, a twelve-unit hold and mouse-selected release sites across the three landable worlds. Three plant sizes stabilize each climate ring; two herbivores and a predator complete that ecological tier and unlock the next. Effective ecology bounds real colony capacity and output. Thirty seconds of sustained unsuitable climate removes unsupported life, warns in the HUD and records the actual world in the chronicle. Shared-clock local populations recover within a four-specimen cap. Snapshot v13 validates and preserves cargo, identities, slots, placements, stress and unique milestones.

Inventory → Specimens, and the Environment deployer icon, open the real hold. Model-derived portraits make slots match their surface representatives. Original provisional mesh kit/animation and the portrait bake script follow [BIOSPHERE_ASSET_SPEC.md](BIOSPHERE_ASSET_SPEC.md). Art/audio and native feel remain unapproved; no per-organism simulation was added. Legacy nursery pods remain separate and optional.

Validation: **1,169 assertions plus UI checks** in the full suite, followed by **74 biosphere checks** including one added off-screen chronology check, plus rerun climate/diplomacy suites. Current total: **1,170 assertions plus UI checks**. Tests cover a paid three-world journey through full T3, real mouse picking/arrival/beam/release, cargo and energy, saved placements, cancellation/inspection, stable rings and habitat loss. Actual 1080p/1440p surface, inventory and ecosystem renders inspected. Build **build/versions/20260923-175010/FrontierWorlds.exe** via Play.cmd; exported-pack startup smoke passed.

Next: **V04/I01 system-scale navigation and view hierarchy**, giving the personal ship a coherent planet → system → sector journey, clear destinations and actual travel costs. Preserve surface-only local charts and optional arrows/numpad. Do not deepen nursery cultivation or expand the food-web corpus. Full tool/weapon families, rank/shop progression, sentient/property abduction, ecological disasters, extreme manipulation, empire conflict, human Sol and story remain open. Keep native flight/HUD/audio review gates active.

## Personal planet manipulation — previous checkpoint

Read [PLANET_CLIMATE.md](PLANET_CLIMATE.md). Four purchased energy tools and four finite consumables now manipulate independent temperature/atmosphere axes through hotbar selection and planet/terrain clicks. Eight-second pulses continue off-screen; unstabilized climate drifts back. Climate affects globe/atlas/surface appearance, real colony utility demand, growth limits and export yield, plus known-owner/ecological grievances. Snapshot v12 preserves pulses, inventories and finite dock stock. Native geography and existing structures remain intact. The expanded hotbar has named hover help and actual row-relative shortcuts.

Validation: full suite passed at **1,090 assertions plus UI checks**, followed by **54 climate checks** (six additional reverse-axis/boundary checks), bringing current coverage to **1,096 assertions plus UI checks**. Corrected thaw striping, initial unassigned escort visibility, verbose objective overflow, stale colony output readout and ships showing through the atlas. Actual 1080p/1440p climate, surface, atlas and dock renders reviewed. These do not establish native usability, balance or approved art/audio. Playable: **build/versions/20260923-172447/FrontierWorlds.exe** through Play.cmd; exported-pack encounter startup smoke passed.

Next: connect actual specimen collection/deployment to ecological stabilization and visible capacity requirements, preserving spaceship exploration and avoiding a compulsory planting tutorial. Climate potential alone does not complete T01. Keep full tool breadth, civilization responses and presentation/native playtest gates open. Do not turn this into food-web catalog expansion or individual organism simulation. The previous checkpoints below are history.

## Allied escorts — previous checkpoint

Read [ALLIED_FLEET.md](ALLIED_FLEET.md). Alliances now supply one escort per nation, with scenario badge-based slots capped at three. Contact → Fleet handles local-orbit recruitment; the HUD roster shows real hull and opens orders. Escorts follow and assist the selected attack, take actual enemy aim-volume damage, preserve damage through travel/dismissal, and incur relationship loss and a paid/delayed replacement when destroyed. Dock fleet repair uses real proximity/prices/access. Alliance withdrawal or embargo recalls ships. Snapshot v11 validates fleet ownership, slots, hull, cooldowns and history; earlier campaigns gain no free ships.

Validation: full suite passes with **1,042 assertions plus UI checks**, including 53 fleet checks for actual scene attack/cancellation/inspection, enemy strikes, recruitment UI, atomic persistence and three distinct allies. Orbit, roster and contact renders reviewed at 1080p/1440p. Mesh kit, HUD, reused audio and native combat feel remain unapproved. Next: connect planet-wide climate/atmosphere tools (T01) to personal ship use, globe/surface appearance, habitability, colony capacity and diplomatic response. Continue missing weapon/fleet support families; do not expand ecology catalog or launch empire conquest merely because escorts now work.

Playable: **build/versions/20260923-165619/FrontierWorlds.exe** through Play.cmd. Exported-pack encounter startup smoke passed.

## Surface weapons and defenses — previous checkpoint

Read [SURFACE_COMBAT.md](SURFACE_COMBAT.md). Nacre I and Kestrel I now have one bounded pursuing flyer and two fixed defenses each. The starting surface laser, paid seeker missile and paid ground bomb have distinct target/cost/range/timing rules. Mouse orders approach before firing; Stop/manual steering cancel. Telegraphed 3D strikes reward altitude evasion. Separate wreck clicks recover finite cargo; persistent kills contribute to Defender and chronicle. Shared-clock projectiles resolve even after ascent. Snapshot v10 preserves the combat model and migrates earlier campaigns without free victories.

Validation: full suite passes with 989 assertions plus UI checks; 37 new combat checks also passed after final placement/outline corrections. Actual warning/impact renders inspected at 1080p/1440p. Model kit and reused audio remain provisional; native playtest/balance and AAA presentation are still open. Next: allied fleet assistance connected to existing alliances, persistent records and loss consequences, alongside further weapon-family breadth and planet manipulation. No empire conquest or complete combat parity is claimed.

Playable: **build/versions/20260923-163238/FrontierWorlds.exe** through Play.cmd. Exported-pack encounter startup smoke passed.

## Carried repair supplies — previous checkpoint

Read [REPAIR_SUPPLIES.md](REPAIR_SUPPLIES.md). Basic and full-hull repair packs now have finite paid shop stock, a shared three-slot locker, Explorer/Defender eligibility for full repair and a shared 20-second cooldown. Real inventory/hotbar icons consume owned items; full repair respects purchased hull. Campaign service commands also close the energy/recharge embargo bypass and record transactions/recovery in the chronicle. Session v9 / field v8 preserve stocks and migrate older campaigns without free carried packs or restored resources.

Validation: 952 assertions plus UI checks, with 46 repair-supply checks; actual 1080p/1440p shop, inventory and palette captures inspected. Presentation/native feel and balance remain open. Next: distinct weapon roles and surface targets, then fleet help and world-scale manipulation. The research inventory remains open; broad parity and enrichment gates have not passed.

Playable: **build/versions/20260923-160800/FrontierWorlds.exe** through Play.cmd. Exported-pack encounter startup smoke passed.

## Purchased ship capacities — latest checkpoint

Read [SHIP_CAPACITY.md](SHIP_CAPACITY.md). Four hull and four reactor tiers now expand maximum capacity through paid, badge-gated purchases with prior-installation requirements. The ship keeps its existing reserves during installation. Packs, repairs, travel, local recharge prices, HUD and systems use the same authoritative capacity. Snapshot v8 validates ownership before loading expanded reserves and preserves legacy scarcity. Shops separate equipment/hull/reactor families.

Validation: 906 assertions plus UI checks, including 46 new checks and a trade-funded peaceful purchase; native renderer captures at 1080p/1440p reviewed for layout. Final presentation and native player balance/feel remain unapproved. Next: inventory-selected repair consumables with actual shop stock/costs, then distinct weapon roles and surface targets. The reference inventory below remains open; do not equate these eight upgrades with completed C01/P01 or full parity.

Playable: **build/versions/20260923-155315/FrontierWorlds.exe** through Play.cmd. Exported-pack encounter startup smoke passed.

## Reference inventory and next ship progression — latest checkpoint

Read [parity/COVERAGE.md](parity/COVERAGE.md). The sourced working manifests enumerate 84 tool/equipment families with 189 variant entries, 30 badge families, ten master ranks, 40 space-related achievements and twelve inherited traits. Each tool family has one task-board owner. Fourteen audit questions remain, including conflicting wiki values and missing retail verification; these counts are not a completed-feature percentage or an exhaustive parity claim. Run `tools/ParityReport.ps1` to validate references and report ownership counts. The existing board remains the only production queue.

Next implement connected C01/P01 ship survival progression: purchased hull/energy capacity tiers with prerequisite purchases, inventory-selected repair consumables, service prices based on missing capacity, and durable ownership. Preserve no passive energy regeneration, free home recharge and real expedition costs. Then distinct weapons/surface targets, fleet assistance and planet manipulation. Do not wait for disputed reference numbers to implement clearly identified missing capabilities using explicit scenario tuning.

This checkpoint changes research, planning and its reporting utility only. Latest playable remains **build/versions/20260923-153000/FrontierWorlds.exe** via Play.cmd; 860 gameplay assertions plus UI checks belong to the preceding scout checkpoint, not new validation of the research facts.

## Authored scout and attached flight effects — latest checkpoint

Read [SCOUT_ASSET.md](SCOUT_ASSET.md). Kiteback v2 replaces the primitive scout with a dimensioned, reproducibly authored GLB: layered shell plates, an inset visor, hooked articulated shields, engine housings and a belly aperture. Two shield pivots track actual thrust/steering and pause. Named engine/tool/weapon sockets drive existing effects. Angled beams now reach their target correctly; previous world-axis scaling distorted them. The source validates triangle preservation during batching. Final geometry: 5,432 triangles, 14 mesh instances, six materials; the particle cap stays 184.

Validation: full suite passed with 860 assertions plus UI checks; final mesh changes also passed 13 scout integration checks and export geometry validation. Actual 1080p model and surface/orbit captures at near/normal/far distances reviewed. Player art acceptance and native flight review remain open; this is not a final AAA asset claim. Next: finish the detailed base Space Stage tool/upgrade/ability inventory (R01), then use its gaps to expand the connected ship/tool/progression loop. Retain bounded presentation work and existing audio blockers. Do not spend the next checkpoint indefinitely reskinning this scout or expanding ecology.

Playable package: **build/versions/20260923-153000/FrontierWorlds.exe** via Play.cmd; exported-pack startup smoke passed.

## Multi-world orbital threats — previous checkpoint

Read [ORBITAL_ENCOUNTERS.md](ORBITAL_ENCOUNTERS.md). Nacre I now has a pursuing Rake cutter and Kestrel I an anchored Watchbell sentry. Both telegraph fixed 3D strike volumes that can be evaded horizontally or vertically. Mouse weapon orders use the shared hull/energy/cooldown system. Defeats persist, reward a distinct-contact Defender badge and leave one-time physical cargo salvage. Defender 1 or Explorer 2 unlocks a 180-Mark emitter that changes actual damage from 22 to 33. Snapshots v7 migrate current and inactive planets; chronicle includes actual neutralizations, salvage and tows. Two authored mesh candidates and warning/resolution FX are integrated, but art/audio remain provisional.

Validation: 847 assertions plus UI checks; 45 new encounter checks cover real mouse combat, evasion, recovery, cargo/progression and migrations. Gameplay/model captures reviewed at 1080p. Next prioritize V06 player scout specification → authored mesh/materials/sockets → in-engine near/far/flight review, alongside full reference inventory and native playtesting. Multiple combat entities, fleet/war breadth, full weapon/progression corpus and presentation acceptance remain open. Earlier checkpoints below are history.

Playable package: **build/versions/20260923-151135/FrontierWorlds.exe** via Play.cmd; exported-pack startup smoke passed. This checkpoint is implementation evidence, not final art or native playtest acceptance.

## Physical freight contracts — previous checkpoint

Read [EXPEDITION_FREIGHT.md](EXPEDITION_FREIGHT.md). Communications → Colony administration → Freight contracts charters one carrier per completed outpost for 80 Marks. Four-unit consignments preserve a chosen reserve, prepay distance-based transport, travel over charted routes and sell against actual arrival demand/prices. Unsold goods return and cannot overflow storage. Foreign contracts require trade; non-aggression permits transit through embargo but not selling. Pause/recall retain cargo. The sector chart shows booked routes and carrier progress. Snapshot v6, ledger/chronicle integration and distinct Merchant flow counting persist the entire loop.

Validation: 802 assertions plus UI checks; 49 freight checks include conservation, demand, costs, borders, recall continuity, actual UI commands and atomic saves. Current playable: **build/versions/20260923-144855/FrontierWorlds.exe** via Play.cmd; exported-pack startup smoke passed. In-engine 1080p contract/status/chart review completed. Freighter 3D art, native controls/balance and final presentation remain open. Next broaden spaceship encounters and combat/progression beyond Morrow, alongside bounded authored scout/art work; avoid turning the next phase into deeper economic administration. Full Space Stage inventory/parity, Sol, fleets and story remain unfulfilled.

## Carried colony kits and export outposts — latest checkpoint

Read [EXPEDITION_COLONIES.md](EXPEDITION_COLONIES.md). Paid kits occupy four cargo spaces, require an orbital survey, and deploy at a mouse-selected clear surface footprint after the ship arrives. Stop/steer cancels without consuming the kit. Construction advances through cargo/frame/shell stages over 18 colony days, including while off-screen. The finished hub has no invented city population. Paid alloy/water/glass facilities have environment yields, operating costs and capped physical warehouses; collection transfers real stock to the ship. Snapshot v5 preserves all of this. Independent market supply/demand now has bounded time-based replenishment.

Validation: 753 assertions plus UI checks, including 49 colony checks and real scene picking/flight/cancellation. Current playable: **build/versions/20260923-143311/FrontierWorlds.exe** via Play.cmd; exported-pack startup smoke passed. Construction and administration rendered at 1080p; prototype meshes, existing HUD/audio and native feel remain open acceptance gates. Next connect automated physical freight, destination demand and route access, then continue broader parity. Do not restart city-first or ecology-first production. Earlier checkpoint sections below are history.

## Alien contact and consequential agreements — latest checkpoint

Read [EXPEDITION_CONTACT.md](EXPEDITION_CONTACT.md). Real territorial arrival now establishes first contact with an original portrait candidate; Y opens known representatives, their attitude/reason and contextual agreements/exchange. Trade pacts change actual prices; non-aggression permits transit during commercial embargo; alliances share usable charts without awarding visits. Goodwill is a one-time paid grant, survey licenses are exclusive, and withdrawals cost trust and revoke their benefits. Snapshot v4 persists those decisions and causal chronicle events; older saves mark a recording boundary. Chronicle filters/pagination retain the local log and colony ledger. Three animated vector busts have authored specs and 1080p placement review, but remain unapproved artwork; no final rigs/voices or fleet assistance is claimed.

Validation: 704 assertions plus UI checks (45 diplomacy); current playable **build/versions/20260923-140812** via Play.cmd; exported-pack startup smoke passed. Next connect personal colonization/production to renewable market supply and automatic freight; continue danger/fleet breadth and the full feature inventory. Keep final HUD/ship/audio/character direction as open quality gates rather than treating these portraits as approval. No ecology-first corpus expansion. Earlier checkpoint sections are history.

## Cargo, finite trade and purchased upgrades — latest checkpoint

Read [SHIP_COMMERCE.md](SHIP_COMMERCE.md). One persistent expedition now carries three ordinary commodities, draws alloy from real home-colony materials, trades at finite environment-priced markets, earns Explorer/Merchant tiers and purchases functioning cargo/drive upgrades. Y approaches a dock; I inspects provenance/capacity; Escape opens Badges. Purchases require actual proximity, stock, money, capacity and open trade access. Both planetary docks share market exhaustion. Snapshot v3 preserves commerce and migrates earlier campaigns without free goods/equipment. Full Spore progression is not claimed: only two families with five scenario-scaled tiers exist; master ranks and most families remain missing.

Next: integrate actual faction contact/actions and expressive representatives with the personal voyage; connect remote supply/demand and automated freight without replacing hands-on trade. Keep authored ship/art/audio acceptance work open. Market panels and in-engine 1080p captures are functional layout evidence, not an approved visual redesign. 659 assertions plus UI checks pass (49 commerce); native input, balance and listening review remain open. Current playable: **build/versions/20260923-134743** via Play.cmd; exported-pack smoke passed. Earlier dated checkpoints below are history.

## Personal travel — latest checkpoint

Read [INTERSTELLAR_FLIGHT.md](INTERSTELLAR_FLIGHT.md). G or the sector navigation button opens revealed stars and planet destinations. The personal flagship now owns paid/timed travel across all 24 orbital destinations. Morrow, frozen Nacre I and arid Kestrel I support descent; others explicitly remain orbital-only. Hull, energy, equipment, packs and specimens travel together; inactive planets retain changes and continue aggregate production. Snapshot v2 migrates v1, saves transit and preserves per-world stock. The local chart stays surface-only. Next connect commodity cargo/markets, encountered-faction contact and badge-gated shop upgrades. The reused assets, neutral map and sound bank remain provisional/rejected; this is not full parity or visual approval.

## Shared expedition integration — latest checkpoint

Read [EXPEDITION_SESSION.md](EXPEDITION_SESSION.md). Morrow flight now owns the sector and field models in one campaign container, using one treasury, a persisted 30-second colony-day cadence and an atomic combined save. Original field JSON migrates without overwriting it or granting new Marks/energy. Pause and inspection stop both clocks. Other worlds remain unvisitable; old standalone strategic modes are intentionally not silently merged. Next connect authoritative personal travel and separate per-world local state. Earlier presentation sections below remain open acceptance feedback.

Latest meta-direction: keep the active Space Stage goal and TASK_BOARD.md. [GOAL_AND_CHECKINS.md](GOAL_AND_CHECKINS.md) provides positive goal wording and the check-in contract. The parity status/TSV are preliminary research, not a competing queue. Advance the connected expedition milestone alongside bounded presentation work; do not organize the whole project around the latest criticism. No game code changed in this planning checkpoint.

Current playable package: **build/versions/20260923-132749** through Play.cmd. Exported-pack flight smoke passed; 610 assertions plus UI checks pass, including 28 shared-session and 45 interstellar checks. Engine-rendered sector and pilot-surface states were inspected at 1080p; native player/fun review remains open.

## Latest review: icon styling and typography rejected

The user rejects the rounded wells, shiny copper-like borders, current font and planet appearance. SVG glyphs are also below their quality target, but replacement is deferred. Removed the decorative wells and persistent tool title/specification above the palette; retain provisional glyphs, neutral selection underline, actual quantities and hover tooltips. Do not treat the earlier icon vocabulary as approved. Read [UI_ICON_VOCABULARY.md](UI_ICON_VOCABULARY.md).

An isolated Godot pointer-event review successfully rendered the native named tooltip at 1080p; descriptions wrap into readable lines. All tool/category/navigation icons have help. Local chart remains surface-only, two-row pagination and large-display support remain intact. Next visual priority is coherent typography and planet/interface art direction; further ornamental skins without comparison evidence are not progress. Earlier sections below preserve history.

## Icon vocabulary, dense palettes and surface-only chart

Latest user corrections are implemented: local chart is visible only on the planetary surface; original icon controls replace text-only category/navigation buttons. See [UI_ICON_VOCABULARY.md](UI_ICON_VOCABULARY.md) and the icon gallery linked from the comparison board. There are 16 new vector symbols, clear hover names and state feedback. Shared palettes support 18 items/page with paging and current-page shortcuts. A 27-entry fixture is test-only, not shipped content.

534 assertions plus UI checks passed, including 47 HUD and 15 capacity checks. Actual 1080p and 1440p flight/gallery renders reviewed; 4K geometry checked, not native 4K rendering. The new browser gallery is source-validated, not agent-browser-reviewed. Final aesthetic and native input remain open. Continue contextual contact/shop presentation and shared flight/sector integration; do not reopen the settled local-chart scope or expand ecology first.

## Shared palette checkpoint and latest aesthetic steering

The user likes the comparison board and says the work is getting closer. Next: a consistent original icon/button vocabulary, broad content presentation and explicit 1080p+ coverage. Use crisp source vectors where they suit the established assets; generated raster art is optional, not a replacement for consistent interaction design. Keep labels/tooltips where symbols would be unclear.

Shared Main tools / Environment / Weapons / Inventory palette now separates browsing, selection and targeting. Tab/Shift-Tab browse without cancelling; numbers select current-category items; collapse preserves ship condition. Counted packs use the actual model, expose cooldowns and cannot double-spend. Escape remains the utility menu. 518 assertions plus UI checks passed, including 46 HUD checks; latest readability changes passed those 46 again. Final art and native input remain unapproved. See SPORE_PALETTE_AUDIT.md for current limits.

## Latest research checkpoint: ten-state interface board

Open [ui-review/index.html](ui-review/index.html) and read [SPORE_PALETTE_AUDIT.md](SPORE_PALETTE_AUDIT.md). The board compares source evidence, proposed responsibilities and current captures for surface, tools, inventory, conditions, communications, shop, system, galaxy, badges and Escape menu. It is an interaction wireframe, not a newly approved skin. Eight reference tool families are distinguished from cargo and passive upgrades; exact retail palette ordering is still unverified.

Static board validation passed. In-app browser blocked the local file URL; no browser/layout approval is claimed and no alternate browser workaround was attempted. Game build remains `20260923-114317`; this checkpoint does not change executable behavior. Next implementation target is a shared, collapsible category/item palette with context-relative slots, separated browsing/selection/targeting and owned consumables. Review the visual grouping against the board; do not revive rejected housings or declare the full parity goal complete.


Current package: `build/versions/20260923-114317` via Play.cmd. Full suite: **502 assertions plus UI checks passed**; final frame removal also passed the 30 HUD checks. Exported-pack smoke passed. Rendered inspection is not native playtest or art approval. Verify the source checkpoint remote hash before unrelated work. The multistate review camera is explicitly settled after scripted orbit transition (normal processing is disabled in the capture); final captures show the ship and planet.

## Latest checkpoint: rejected cockpit, interaction corrections

The user rejected the custom cockpit screenshot and reiterated **Spore Space Stage parity first**. Read [SPORE_INTERFACE_CONTRACT.md](SPORE_INTERFACE_CONTRACT.md). Do not continue reskinning the current radar/center-deck/console as if its visual direction were approved. Next: annotated reference-to-project state boards and the remaining category/input audit, then a faithful original interface kit. Current changes only correct explicit interaction problems.

Escape opens a modal utility menu (resume/save/load/chronicle/controls/audio/title); the bottom bar is gone. Inventory contains a usable energy-pack item; no HUD recharge/pack/shroud/repair buttons. Shield controls are explained in Equipment. Weapon selection no longer orders an attack; select, then click the target. Cargo capacity is labeled and separated from the weapon. Planet map and Communicate replace Atlas/Contact labels. Full Spore-like palettes and character service UI remain missing.

[ENERGY_ECONOMY.md](ENERGY_ECONOMY.md): no passive recharge, finite packs and shop stock, provider quotes, free homeworld. Both live docks are on Morrow (homeworld), so foreign prices are model-tested only. Flight/sector integration is still absent. Current console artwork, simple ships, service rings and generic drawers remain placeholders/rejected, not final art.

[SPORE_BADGE_PARITY.md](SPORE_BADGE_PARITY.md) inventories 30 families, alternate shop paths, ranks, achievement distinctions and unresolved source contradictions. Badge-gated shops are not implemented. [CORE_LOOP_AND_CONTENT_EPIC.md](CORE_LOOP_AND_CONTENT_EPIC.md) records all subsystem responsibilities and the user's next epic; core-loop alignment and presentation review must precede broad content production. Continue full feature parity after proving the foundation. Do not mark the active goal complete.


## Latest additive content steering

Read [RESOURCE_AND_UNLOCK_DIRECTION.md](RESOURCE_AND_UNLOCK_DIRECTION.md): visible mines, farms, biological/material/cultural goods, expensive worthwhile investments, abundant normal items without modifiers and scarce exceptional traits. User schedules this as potentially post-MVP. Badges/achievements must unlock technologies and purchasable shop stock through meaningful varied accomplishments. Continue the active finite-energy and rejected-HUD corrections first.


## Latest user direction: finite energy and keep moving

The user accepts the current visual pass as good enough to move on; do not keep polishing one task unless pressing. Energy must NOT passively regenerate. Recharge through consumable energy packs or shop service with variable costs; the homeworld is always free. This supersedes the prototype reactor trickle and recharge-based recovery. Implement real commands/costs/access/UI and preserve recoverability without making remote expeditions free.

Visual checkpoint package: `build/versions/20260923-111151`, 469 assertions plus UI checks and exported flight smoke passed.


## Latest checkpoint: flight correction and shared planet geography

Read [PLANET_GENERATION.md](PLANET_GENERATION.md). Morrow orbit/atlas and all surveyed strategic planet overviews now share a versioned spherical generator and terrestrial climate profiles. Color/conditions/relief maps are cached; clouds and atmosphere are separate. Strategic terraforming blends climate without moving geography. 469 assertions plus UI checks cover current systems. Flight descent works from wheel, mouse and keyboard, with far-side routing and cancellation; Windows TTS removed. Voice replacement is still missing.

**Next:** actual generated landing regions linked to shared planet IDs and ship state; native zoom/descent review; acquire approved AI SFX and audition a proper guide voice; authored scout and astronomically grounded sky. Morrow remains the only personal-flight landing site. No final art/feel approval. Full Space Stage goal remains active. Prior checkpoint sections are history.


## Flight correction checkpoint

Descent now starts atmospheric approach from the mouse button, keyboard/numpad descent, Ctrl-wheel down, or inward zoom past the approach scale. Outward zoom or steering cancels. Far-side landing routes around the solid globe; camera scale no longer snaps at the frame transition; ascent starts when zoom reaches its boundary. Windows TTS fallback is removed; guide captions remain and only supplied recordings may speak. No replacement voice has been acquired. 11 new regression checks cover these behaviors; native feel remains unverified. Planet generation is next.


## Latest steering and combat checkpoint

The user rejects the Windows guide voice, clunky zoom/ineffective descent, and current planet presentation. These corrections and a reusable planet-generation pipeline take priority over additional combat content. The unfinished combat work is now validated: one arc lance and warning/chase/disengage custodian, nonlethal disable, persisted state, version 4-to-5 migration. 440 assertions plus UI checks pass, including 23 combat checks. Geometry and firing sound remain placeholders. No native playtest or artistic approval is implied. The current packaged build predates this source checkpoint. See ORBITAL_COMBAT.md.


## Latest checkpoint: orbital danger and acquired ship defense

[ORBITAL_THREAT.md](ORBITAL_THREAT.md) documents the new charted wreck, telegraphed pulse field, persistent hull, emergency tow, repair and one recovered phase shroud. Chart/contact/world click issues actual ship travel and a timed salvage action; retreat and cancellation matter. Version 3 field saves migrate to version 4. HUD now shows hull beside energy and a clickable shroud/repair control. The 3D wreck and ring are prototype geometry; the previous sound bank is still unapproved. Existing field and strategic worlds remain separate.

Validation: 417 assertions plus UI checks, including 37 orbital encounter checks; reviewed in-game orbital captures at 1600×900 and 1280×720; build `20260923-032255` and exported-pack smoke passed. Native playtesting, professional art/audio approval and a complete Space Stage capability set remain open. Next: weapon/hostile AI pilot, authored scout/wreck and approved AI sound acquisition, then shared flight/sector ship state. Earlier checkpoint sections below are historical context.

## Latest checkpoint: equipment catalog and content inventory

[CONTENT_INVENTORY.md](CONTENT_INVENTORY.md) now audits all nine content families, with actual scope and brief/asset/mechanic/integration/review distinctions. Four existing field tools now read shared validated definitions in `data/equipment.json`; command costs/range/cycle, HUD, approach distance, keyboard slot order and effects use the same source. The equipment inspection states their starting acquisition. Save version stays 3. This is a content-production foundation, not new equipment breadth or final presentation approval.

Validation: 380 assertions plus UI checks pass, including 27 new equipment checks and existing version 1/2 save migration. Rendered HUD/equipment text reviewed at 720p; Windows build `20260923-030715` and exported-pack smoke passed. Next content implementation: readable orbital danger, hull/damage/recovery and a distinct useful capability with an actual acquisition path; do not expand the optional farming lesson. Shared flight/sector state remains essential before claiming multi-world logistics. Approved AI audio acquisition, ship/globe artwork and native playtest gates remain open. Earlier checkpoint sections below are historical context.


## Latest steering and flight checkpoint

The user requires broad, deep, distinct content for every major component of the game. This instruction is **independent of the attached screenshot**. Read [CONTENT_CORPUS.md](CONTENT_CORPUS.md); presentation-only progress is insufficient. After validating/backing up the current camera/effects work, the next content milestone is a data-driven equipment/content ledger tied to actual commands, acquisition and meaningful uses. Keep the full feature-family objective intact.

[FLIGHT_CAMERA_EFFECTS.md](FLIGHT_CAMERA_EFFECTS.md) records the new wider camera, ordinary-wheel zoom, cancellable zoom ascent, distant scenery and capped engine/tool particles. Ctrl-wheel retains altitude control. Effects are cosmetic; strategic integration and complete planet surfaces remain unfinished. The sections below preserve earlier checkpoints; the latest behavior is specified here.


## Latest implementation: composed flight instruments

Read [FLIGHT_HUD_REVIEW.md](FLIGHT_HUD_REVIEW.md). The first composed HUD slice now exists: original shaded tool icons and instrument housings, live clickable local navigation, category palettes, quick cargo, adjacent ship energy/equipment and explicit target states. Category browsing is live and preserves equipment; expanded inspection still pauses. Full globe atlas remains intact. 332 assertions plus UI checks pass, including 19 new HUD integration checks. This is a candidate engine implementation, not art approval. Next: native-input/readability review, dedicated character/trade layouts and richer motion; approved audio acquisition, ship/planet assets and shared sector state remain outstanding. The earlier instruction below to begin this slice is historical context.


## Latest steering: deeper Spore GUI forensics

Read [SPORE_GUI_FORENSICS.md](SPORE_GUI_FORENSICS.md) first. The research checkpoint inspects manual diagrams, game screenshots, timestamped gameplay states and community UI structure, then audits our code. [FLIGHT_INTERFACE.md](FLIGHT_INTERFACE.md) now specifies a composed lower instrument assembly, live planetary navigation, category/item palettes by the ship, distinct targeting states and dedicated commerce/conversation layouts. Next: composition/state boards and an original housing/icon kit, then implement the bounded HUD slice and its acceptance matrix. Current colored buttons and generic drawers remain prototypes. Dense late-game states, frame-accurate motion, native retail input and listening audit remain open; do not claim those were verified.

## Planetary atlas checkpoint

**M / Planet atlas** opens a rotatable whole-globe map. Drag to rotate, wheel to zoom; geography and survey-coverage layers share the orbital globe's seeded material and fixed basin coordinates. A ship marker uses the current local/orbital direction. The one available destination commands actual approach/landing, not teleportation. Orbital imaging costs 20 energy and takes 12 simulation seconds in orbit; it pauses during inspection or surface visits, survives save/load, and records one chronicle milestone. It reveals geography, not ground species/resources. Version 1/2 field saves migrate to version 3.

Only Morrow Basin is landable. The globe is a shared procedural geographic scaffold, not a fully traversable surface or a finished planetary art asset. System/galaxy map integration, multiple landing regions and resource/political layers remain open. Existing local terrain detail is still authored separately from global geometry. Current validation: **313 assertions plus UI checks**, including 34 planet-map checks. Atlas captures in artifacts/flight_ui_atlas_*.png are rendered evidence, not native input review.

**Live task visibility:** keep [TASK_BOARD.md](TASK_BOARD.md) updated at each checkpoint. The colorful cargo/equipment pass and whole-planet atlas are implemented prototypes; the redesigned composition, live navigation instrument and deeper subsystem mechanics remain pending. Prioritize the forensic redesign before unrelated content.

## Interface checkpoint

Cargo / **I** shows two real onboard sample cradles and separate eight-unit surface storage, with quantities, origin and a deployer action. Systems / **K** inspects installed tools, reach, cycle and energy cost, and selects a tool back into flight. Inventory does not fabricate items or count surface produce aboard. All inspection drawers pause both movement and economic time; closing preserves an explicit player pause. Four original vector tool icons use mint, apricot, honey and violet; energy is gold on warm plum housings. These are implemented UI improvements, not final art approval. Full power routing, upgrades and hull/damage are still missing; the atlas checkpoint above supersedes the former missing-map status.

This earlier interface checkpoint passed 279 assertions; the subsequent atlas checkpoint passed **313 plus UI checks**. `tests/review_flight_interface.gd` renders isolated review captures under ignored `artifacts/flight_ui_*.png`; reviewed 1440×810 and 1280×720 layouts. No native player-input/fun approval is implied.

## Active goal: spaceship adventure and Space Stage feature breadth

**Latest steering:** the user explicitly rejected the `flight-sound-audition` palette as keyboard-like and wants actual AI-generated SFX, especially whirring/humming propulsion. Stop shopping for expensive sound libraries; no purchase was made or authorized. `art/specs/audio_ai_v2.json` contains the new prompts. The public ElevenLabs sound-effects page returned four spacecraft-hum candidates without signup/payment; the user subsequently liked Generations 1, 2 and 3, with 3 preferred. They remain unacquired browser auditions; approval of sound character does not supply files or release rights. Do not claim auditory review through browser controls. The rejected bank is still present in the last packaged build and must be replaced/removed in the next audio integration. The user also requests much wider zoom and visible particles synchronized with thrust/tool audio. These corrections precede the planned combat slice.

Read [SPACE_STAGE_TARGET.md](SPACE_STAGE_TARGET.md) first. The user playtested Morrow and rejected the farming-led introduction, F-centric interaction, constant-height flight, lack of danger, weak UI and insufficient audio. The goal is a polished Spore Space Stage spiritual successor, with all its feature families tracked, plus richer trade, flight and a potential human solar-system start. This goal is not complete.

Ecological expansion and city-first art work are deferred. Preserve the approved creepy-cute original assets and existing city/galaxy simulation. Do not add individual citizen/organism simulation. No engine migration is needed.

## Presentation quality gate

The user explicitly reiterated the AAA quality directive. Current ship, HUD and planet presentation are rejected; functional tests are not evidence of artistic success. Next presentation work must establish a coherent visual target, authored ship specification, much wider zoom, particles linked to tools/thrust, believable planetary scale/atmosphere, and a starfield grounded in real star-catalog positions/brightness. Do not call generated concept art an in-engine result or add arbitrary star dots and call them accurate. A Terraria-like exploration/equipment/access progression is endorsed as a possible direction, not authorization to replace spaceship gameplay with block mining.

## Current flight checkpoint

Choose **Morrow expedition — surface to orbit** from Play.cmd. Click a subject to approach and operate the selected tool; click terrain to move. Arrows / numpad 8,4,2,6 / WASD fly. Home, Page Up, numpad 9 or +, and E ascend; End, Page Down, numpad 3 or minus, and Q descend. Numpad 5 or 0, Escape, or Stop cancels. Wheel zooms; Ctrl-wheel changes altitude. Another outward scroll at the surface limit begins ascent; scrolling in cancels it. Right-drag rotates the camera. On-screen flight controls support mouse-only play.

The opening now points to scanning an old relay and leaving the atmosphere; planting is optional. Ascending past 58 local meters enters orbital flight. Click Morrow or Return to Morrow to approach and reenter the same surface. This is a local reference-frame transition, not seamless planetary scale. The orbital globe's surface marker is attached to its rotating transform.

One expedition model continues through both views. Version 1 field saves migrate additively to version 2. Survey, stock, trade and history survive a round trip. **The field is still isolated from the strategic campaign**; a unified ship/sector state is a required next integration, not solved by a Menu button. The full galaxy, other visitable surfaces and human scenario are not present in this flight slice.

## Audio checkpoint

Read [AUDIO_PRODUCTION.md](AUDIO_PRODUCTION.md). Twenty original WAV candidates now include distinct hotbar equips, UI/target/navigation feedback, thrust, atmosphere and a 48-second music loop. Audio settings separate effects, music and voice. Four contextual guide lines use local Windows scratch narration plus captions, with a replacement contract for licensed recordings. Actual listening and paid casting/music selection remain open. No paid services were purchased.

## Next work

1. Follow the bounded HUD redesign and acceptance matrix in the forensic report. Preserve functioning inventory, equipment, atlas and save commands.
2. Acquire approved AI audio and replace the rejected bank; complete the listening/feedback audit. Existing independent sound controls remain. Browser-assisted auditions are authorized; no purchase without an approved concrete price/license.
3. Continue authored ship/planet assets, scale navigation and particles. Native playtesting and listening remain essential.
4. Integrate flight with the sector, diplomacy and cargo, then the planned health/threat slice. Keep the full requirement ledger visible rather than declaring success from a presentation slice.

## Verification and backup

Current code verification: 353 assertions plus UI checks. Camera/effects adds 21 presentation assertions, including manual input overriding approach/ascent. Tests are in tools/Test.ps1. The forensic checkpoint was documentation-only; the subsequent HUD implementation adds the 19 interaction checks. Captures in ignored artifacts demonstrate rendering, not fun or native input quality. Use build/current.txt for the latest completed package; the earlier atlas code checkpoint is cfc102086376adf20b2eb1509c30cc53c5a9d5a1, pushed and remote-verified.

Build with tools/Build.ps1; smoke the resulting pack. Keep each validated milestone in a small commit, push and compare the remote hash. Play.cmd uses build/current.txt and does not live-update an already open game. Previous user-data and downloads/builds remain outside Git.

The rejected cockpit SVG is preserved only under ignored artifacts. Production uses neutral readability backing pending the reviewed art kit; this is not a replacement art direction.
