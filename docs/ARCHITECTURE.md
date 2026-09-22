# Architecture

`scripts/simulation.gd` is a RefCounted simulation with no scene nodes. It loads the catalog once, owns all authoritative state, validates commands, advances fixed one-day ticks, and emits changed/message signals. The renderer can be replaced without changing saves or simulation rules.

`scripts/main.gd` owns view-specific scene objects and a shared Camera3D/HUD. Only the selected world is rendered. UI calls `command(action, args)`; the simulation does not read UI controls or rely on active-view state. Time advances globally at 1 or 3 ticks per real second; 0 pauses. All view changes preserve the same simulation instance.

## State and commands

State includes version, seed, tick, credits, systems, planets, colonies, factions, agreements, discoveries, milestones, rank, flagship and a reserved fleet list. IDs are stable (`s1`, `s1p0`, faction IDs). Tile keys are `x,z`, each on a 64×64 grid. Catalog definitions live in `data/catalog.json`.

Supported commands: `build`, `travel`, `colonize`, `diplomacy`, `trade`, `import`, `terraform`, `discover`, `specialize`. They return an empty string on success or an explanation on rejection. Observe `changed` for UI refresh and `message(text)` for significant events.

Growth uses road-connected facilities, local life-support distance, utility balance, supplies, jobs and residents, environmental suitability, pollution, and services. Zone upgrades are staggered through authoritative cell iteration every six days. Native binary snapshots preserve numeric precision and insertion order, so continuation matches uninterrupted simulation.

## Graphs and views

- **Travel graph:** twelve star nodes and undirected authored edges. Breadth-first paths minimize jumps. Entering an embargoed capital is prohibited; rerouting finds alternate paths where available. Travel costs six days per edge.
- **Road graph:** four-neighbor grid search begins at the spaceport, propagates through roads, and attaches adjacent buildings. Utility generation is colony-wide for connected facilities; life-support reach and commute length are spatial.
- **Trade flow:** a colony selects one alien export partner/resource, and optionally an internal import source. Surplus reserves, path availability and treaties gate flow. Rate caps stand in for freight capacity.
- **Globe:** visual survey representation, separate from its fixed colony patch. Climate parameters inform both views; colony terrain colors refresh at 10% climate increments.

## Persistence and scaling

Snapshots have an eight-byte magic header and schema version, followed by native variants with object decoding disabled. Writes go to a temporary sibling before rename. Manual and automatic slots are separate. Version mismatches are rejected rather than guessed.

Schema 2 introduces the optional urban scenario and scaled district population. Version 1 expedition/sandbox snapshots migrate by retaining existing state and defaults, then setting version 2. Future/unknown versions remain rejected. Urban manual/autosave slots use an `urban` prefix and cannot overwrite the other modes through normal controls.

All colonies simulate even when invisible. Population/jobs are aggregates and rendered meshes are disposable. Start profiling before raising limits: suitability currently scans placed cells, and growth refreshes connectivity. Cache dirty spatial influence maps and road components before attempting very large cities. Rendering currently uses modular MeshInstance3D nodes; batch repeated meshes with MultiMesh when content warrants it.

## Next architectural split

### Firm simulation budget principle

The new campaign targets a city of roughly 120,000 with SimCity 4-like urban fidelity. This is not a request for 120,000 agents. Building/district aggregates hold population, housing, jobs, demand, service coverage and political interests. Avoid per-person needs, inventories, commutes and world-wide pathfinding. Ambient vehicles and pedestrians are disposable, capped visual effects; offscreen economies must not depend on them. Later congestion can use aggregate road flows if playtesting justifies it.

The initial urban slice uses 160 occupied cells on the existing 64×64 patch, with construction authority bounded to tiles 22–42 / 24–40, plus four authored background district population/job aggregates. Their populations currently remain fixed; they are context, not four hidden detailed simulations. City totals sum background populations and the editable district's live population. Urban lots use a population/jobs multiplier of ten; economic consumption/output remains normalized to the prototype's lot units. Background geometry is a batched visual representation, not individual buildings tied to resident records.

Connectivity still refreshes through the existing colony pipeline. Access overlays now invalidate when the connectivity signature changes. Before increasing caps, cache connectivity after edits and stagger slow systems. Profile frame time and memory as well as ticks; the existing 285-cell benchmark alone does not validate a developed city.

Building presentation caches nodes per tile and replaces only changed lot geometry. Urban residential/service lighting also invalidates when that lot's road connection changes. This avoids rebuilding the whole district for an ordinary zone edit; full view and terrain-overlay changes still reconstruct the scene. Batched background buildings use MultiMesh. These are bounded optimizations, not evidence of unlimited city scale.

`scripts/urban_scenario.gd` defines the authored district, validated civic commands, timed repair and ongoing fee/arrears. `scripts/urban_view.gd` draws batched context geometry and modular alien buildings. Public mutual aid exchanges actual supplies/materials with a reserve and cooldown. Sponsored priority works requires an eligible selected zone, stock, cash and no arrears. The ordinary simulation owns time and calls the civic update regardless of the active view. Neither module simulates citizens or fauna.

### Proposed campaign state extensions — not implemented

Separate nation, region/site claim, city/district, colony administration and planet environment. A planet cannot have only one political owner once multiple jurisdictions exist. A nation can operate sites on several planets; species identity must not supply ownership. Commands must validate jurisdiction, treaty access and affected parties for global terraforming.

Store a small authored cast, explicit commitments, event outcomes, campaign facts and seeded scenario identity in authoritative state. Select alternate histories once at scenario creation, then preserve their facts. Keep sandbox collection rewards in a separate profile and retain mode-specific saves. Introduce versioned migrations or explicit incompatibility messages when changing the current save schema; preserve the internal `credits` treasury key while displaying Marks.

These extensions are proposed boundaries, not existing types or implemented commands. Add them in the bounded order in ROADMAP.md rather than building a general political simulator first.

### Presentation components

The presentation script intentionally keeps the initial prototype easy to run. Before more content, split colony rendering, galaxy rendering and each HUD panel into scenes/components. Preserve command boundaries. Future tactical battles should take fleet IDs and return validated damage/retreat outcomes; pause strategy time during that first battle slice. Do not put combat state into visual ship nodes.
