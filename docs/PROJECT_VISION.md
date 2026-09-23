# Frontier Worlds: project vision

Current design synthesis · 22 September 2026

**Explore living alien worlds, connect their strengths into a space civilization, and discover what happened to the ancestors who forgot yours.**

Latest priority update: [Space-first direction](SPACE_FIRST_DIRECTION.md) supersedes the city-first sequence below. Cities now support exploration, logistics, administration and eventual fleet manpower. Preserve their existing prototype, but do not require a full municipal game before reaching space. Later first-person ship combat is desired; [the technical assessment](FLIGHT_TECH_ASSESSMENT.md) proposes an early small feasibility test. [Diplomacy and the chronicle](DIPLOMACY_AND_CHRONICLE.md) define expressive alien contact, meaningful trade and persistent history. The older urban detail below remains deferred design material, not the immediate production order.

This is a single-player Windows 3D strategy game combining the accessible exploration, alien relationships and wonder of Spore's space stage with the legible urban planning and interdependence of SimCity. Its own identity is a creepy-cute inhabited universe with serious political consequences. Frontier Worlds is a working title. This document records the intended experience, not a claim that the campaign is implemented.

## What the new story changes

The original prototype began with a tiny colony and expanded outward. The campaign now begins with an existing urban society. Its structure is **district responsibility → national leadership → interstellar responsibility**, with the city remaining relevant throughout.

| New story element | Gameplay consequence | Feasible first implementation |
| --- | --- | --- |
| Start in a city of about 120,000 | Repair, rebalance and redevelop an inherited network; existing residents have needs | One editable district with aggregate background districts |
| Corrupt government and the Vanguard | Success builds supporters; a change of government changes authority and obligations | One civic crisis, a coalition decision and a visible consequence |
| Coup or open rebellion | Different governing actions and institutional dependencies | Two capability packages using the same construction/economy commands |
| Independent nations on the homeworld | Diplomacy begins before alien contact; launch access and trade can be negotiated | Two neighboring governments and one shared infrastructure agreement |
| Ancient founders forgot the colony | New settlements need representation and dependable support | Colony charters and explicit service commitments, introduced after the city slice |
| Imperfect ancestors and diverse invaders | Evidence changes present relationships and claims | One discovery involving two living parties and a practical decision |
| Living, variable story | Events respond to resources, commitments and relationships | Authored event conditions and persistent outcomes before procedural plots |
| Spaceflight already exists | The player gains command of a program; no primitive technology grind | Existing spaceport plus a political/economic launch-access decision |

The biggest risk is building a second full game before reaching the space game we wanted. The political opening must use city and diplomacy systems, remain bounded, and offer a quick-start frontier route in sandbox. It does not require street combat, individual voter simulation or a complete nation simulator.

## The playable rhythm

At home, inspect a district, identify a bottleneck and choose a response. At national scale, negotiate the access or supplies that make that response possible. In space, scout a connected system, assess a world and establish a specialized colony. Automated routes turn that colony's surplus into economic and diplomatic opportunities. Return when there is an interesting decision, not because a maintenance timer demands another errand.

A frozen mining settlement might grow around geothermal sites, import supplies from a foreign partner, or invest in warming. The partner may be a neighboring country from the tutorial. Warming can improve development while disturbing native ecology or affecting another settlement. The same project therefore has spatial, economic and political consequences.

The original 30–60-minute first-playable target remains a test of the core loop, not a promise that an entire dramatic campaign fits into one hour. Measure how quickly the opening reaches satisfying decisions and exploration before choosing its final length.

## A city that already exists

The opening city has roughly 120,000 people, a logical street grid and a recognizable urban structure. Apartments, offices, shopping streets, factories, parks, schools, hospitals and transport infrastructure establish scale. The spaceport connects to freight and arterial roads at the edge. History is one visible layer of a modern place.

Start the player with limited jurisdiction over a district. Background districts continue contributing population, jobs, budgets and utility demand in aggregate. The city overview must distinguish city totals from the editable district's totals. Do not display 120,000 over a simulation containing a handful of houses. Author real aggregate population and capacity data; individual resident agents are unnecessary.

The first district can reuse the 64×64 terrain patch. Its relationship to a larger city must be explicit rather than compressing an entire metropolis into the old starter plot. A larger city overview and additional editable districts can follow only if useful.

Initial growth remains light zoning: habitat, industry and services, two growth levels, direct placement for infrastructure. Commercial buildings and civic landmarks can initially be visual/data variants within service demand; independent commercial demand, transit operations and detailed municipal budgets are later extensions. Roads provide connectivity and distance penalties before any commuter or congestion simulation.

**Firm fidelity constraint: SimCity 4-like urban richness, not a simulation of every person and object.** Population, households, jobs, demand and political interests are aggregate counts at building or district scale. Visible pedestrians, trains and cars are a capped presentation layer; their absence offscreen must not stop production or commuting. No persistent 120,000-agent population, individual shopping trips, household inventories or world-wide pathfinding. Richness should come from zoning, density, services, environmental constraints and readable feedback. If traffic becomes useful later, estimate flows between districts or road segments rather than assigning a car to every commuter.

Update slow systems less often, cache connectivity until construction changes it, and refresh overlays only when needed. Render nearby detail with batching and distance-based simplification; simulate offscreen places with the same authoritative aggregates. Profile on the development PC before selecting hardware budgets or raising caps. A visually busy city must not require a busy CPU for every visible activity.

Growth needs demand, access, power, life support, employment and local suitability. Explain blockers in plain language. Existing districts make redevelopment, service allocation and opportunity cost important; avoid bulldozing occupied neighborhoods as a consequence-free optimization. Relocation and compensation can begin as simple aggregate costs before adding household detail.

## Decisions change the tools you have

These are proposed abilities, not implemented unlocks. A decision should grant a useful verb, make its cost understandable, and leave a visible consequence. Avoid both purely cosmetic dialogue choices and one obviously superior path.

| Direction | Useful action | Tradeoff that changes play |
| --- | --- | --- |
| Public reconstruction coalition | Dispatch mutual-aid crews between districts | Reserve some capacity for members' essential needs |
| Institutional reconstruction coalition | Issue priority works orders through existing departments | Sponsors expect contracts or appointments; breaking commitments has consequences |
| Broad uprising | Negotiate local charters and volunteer logistics | Representation and local autonomy constrain unilateral decisions |
| Institutional coup | Requisition stock and mobilize inherited facilities quickly | Backers can withhold cooperation; coercion creates resistance |
| Joint orbital consortium | Use shared launch sites, pooled expeditions and rescue capacity | Partners share access and mission priorities |
| Independent national program | Choose missions and research policy unilaterally | Pay the full cost and negotiate access to foreign facilities |
| Autonomous frontier charter | Let a colony manage routine development and local trade | Less direct control and negotiated national contributions |
| Central administration | Direct production and redirect strategic stock | Higher administrative burden and responsibility for local shortages |

An uprising does not guarantee democracy; a coup does not permanently prohibit reform. Institutions can change through later choices at visible costs. No single virtue meter should decide every relationship. Track concrete commitments, public services, concessions and grievances before considering a broad approval model.

Choices should preview known effects without spoiling every future event. Delayed consequences should be traceable to a promise or action. Routine obligations can be automated; political depth must not become an endless stream of emergency popups.

## Nations, environments and maps

A species is not a nation. A nation is not a planet. A planet can contain multiple governments, and a nation can administer settlements on several planets. Government describes institutions and available policy; philosophy describes priorities and reactions. Neither is a biological destiny.

The MVP's expansionist directorate, mercantile consortium and ecological commune remain useful authored faction test cases. They are not yet the final narrative cast or the only permitted societies. Some worlds may be unified; the player can pursue federation, coexistence or later domination. Unification is optional.

The map structure needs separate layers:

- **City:** road and utility access between districts and sites.
- **Planet:** environmental conditions, jurisdictions, settlement sites, shared infrastructure and claims.
- **Galaxy:** a readable shallow 3D graph of systems and travel routes, with chokepoints and access rules.
- **Trade:** agreements connecting actual producers and consumers through permitted routes.
- **Later battle:** a separate tactical scene using persistent fleet records.

Switch views with short transitions. Seamless surface-to-space traversal is outside the proof of fun. Frontier fog distinguishes unknown signals, visited systems and surveyed opportunities. Political information can later have separate uncertainty, but already learned history must remain reliable unless a specific deception is established.

## Colonies, resources and terraforming

The bounded frontier scenario remains twelve connected systems, one to three planets per system, three player colony sites and three environmental families. The developed home-city aggregates are a new workload that must be profiled separately, not assumed to fit the old colony benchmark.

Temperate worlds offer flexible settlement but valuable productive land. Frozen worlds encourage compact development near geothermal heat. Arid worlds make water access and widely spaced deposits important. These differences must affect layout, not just terrain color.

Marks fund treasury transactions. Supplies and construction materials are physical stocks; power is local capacity. Automated trade must respect surplus reserves, treaty terms, route access and embargoes. Persistent colonies operate while the flagship explores. Transparent shortages belong in an overview; significant changes can pause and request a decision.

Start with warming on frozen worlds and water recovery on arid worlds. Projects take time and consume stock, improve suitability and change the visual environment without destroying existing buildings. Dynamic coastlines and terrain deformation are deferred.

Multipolar planets change the rules: one colony cannot silently claim authority to alter everyone's atmosphere. Local mitigation can remain a domestic action; global terraforming needs relevant agreements or creates an explicit dispute. Environmental effects must consult affected jurisdictions when that system is introduced.

## Story through play

[The story treatment](STORY_CURRENT.md) supplies the narrative spine. The opening coalition should persist as characters, institutions and commitments. A neighbor who helped build your launch program can later disagree over a colony. A frontier settlement can ask for the representation you once demanded at home.

Discoveries should provide capabilities, claims and choices. A working installation, living community, legal dispute or ecological phenomenon can reveal history through play. Recordings may support a scene but cannot be the main content delivery mechanism. Six authored discoveries are enough to test this structure before building a procedural narrative engine.

The first campaign has fixed historical facts and an authored resolution still to be written. Player actions affect institutions, alliances and the state of the ending. Later alternate campaigns can choose a different scenario package at generation and then maintain consistency. Use seeded, eligible events with prerequisites, actors, consequences and cooldowns; do not call unrestricted random twists a living story.

Three ranks recognize varied accomplishments in exploration, settlement and diplomacy. Promotions open optional specializations and recognition. Construction, navigation and basic diplomacy must not be gated behind repetitive achievement quotas. Peaceful play remains viable.

## Sandbox and fleets

Sandbox offers the core construction and space systems without campaign obligations, with optional fog, resource grants, free construction, rapid travel and other god tools. Current cheats implement a subset of this direction. A future scenario setup can support a developed-city start or a frontier start.

Campaign accomplishments can unlock additional architecture, species presets, government variants, flags and starting scenarios. Core systems remain available immediately. Provide an explicit unlock-all sandbox option so story completion is not compulsory. Collection unlocks require a separate persistent profile; campaign saves and sandbox saves must stay isolated.

Direct fleet battles come after the core loop: flagship plus up to six escorts, two ship roles, movement on a 3D tactical plane, group selection, move, attack, focus fire and retreat. Initially pause strategic time during battle. Ships and losses draw on the colony economy. Conquest, ground warfare and defensive infrastructure wait until a small battle is enjoyable. There is no creature editor, multiplayer or direct ship piloting in the MVP.

## Art and tone

Characters should be original, expressive and creepy-cute: unusual body plans, readable gestures, appealing silhouettes and the occasional unsettling detail. Humans can share the stylized treatment. Humor and affection remain present even when the history becomes dark. Avoid realistic armored portrait lineups and recognizable copies of existing species.

City design needs a different kind of discipline: orderly modern blocks, consistent modular buildings, readable density and restrained detail. Playful creatures do not require chaotic mushroom-house settlements. Species anatomy can influence entrances, circulation and public spaces without destroying urban legibility.

The latest city image is still too Earth-like. Preserve alien divergence in the city itself: more roundabouts and circular civic spaces, unfamiliar building forms, and potentially **benevolent supermegafauna as public transport**. Flying squid-like creatures could carry platforms between landing groves maintained through food, shelter and care. A route can be productive while requiring open corridors or habitat investment. This is an exploratory future option, not an implemented promise. Its gameplay should use aggregate capacity and environmental requirements, represented by a few animated creatures rather than detailed animal/passenger agents.

Use generated imagery for concept boards, portraits, icons and surface references. Build actual game geometry from reusable modular meshes. Images are not game-ready 3D assets. Review concept boards for scale and direction, then test camera, selection and readability in Godot. [The urban study](CITY_CONCEPT.md) tests the revised scale; it is not an approved final art style or a gameplay screenshot.

## What exists and what comes next

The current prototype implements the small colony/galaxy loop, environment-sensitive growth, simple diplomacy, automatic resource exchange, discoveries, climate projects, ranks, fog, sandbox tools and versioned saves. A separate **Urban tutorial** now starts with 120,000 residents across one editable district and four fixed background population aggregates. It includes an actual broken road link, two timed repair agreements, mutual aid or priority works, and persistent sponsorship fees. The district continues operating in other views. The background boroughs are not independently evolving economies yet. It does **not** implement the Vanguard takeover, national politics, story actors, multiple jurisdictions per planet, campaign unlocks, creature transit or battles.

Keep one authoritative fixed-tick simulation independent of scenes, stable IDs, data-driven definitions and validated commands. Extend it with district aggregates, nations, site claims, commitments and campaign facts as needed. Save schemas require explicit migration or clear incompatibility handling. Visual nodes must never become the authoritative political or economic state.

The bounded **urban tutorial slice** is now available for playtesting: one editable district, one infrastructure problem, two ways to solve it and a persistent consequence. Test whether players care about the place and want to try the other approach. Then add the smallest national/diplomatic bridge into the existing space loop. A full cinematic campaign comes after this bridge works.

See [Roadmap](ROADMAP.md) for acceptance gates and [Architecture](ARCHITECTURE.md) for implementation boundaries. No reliable calendar estimate exists for the full vision yet. The scope should grow in response to observed play, not merely because a system sounds exciting.
