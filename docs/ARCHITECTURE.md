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

All colonies simulate even when invisible. Population/jobs are aggregates and rendered meshes are disposable. Start profiling before raising limits: suitability currently scans placed cells, and growth refreshes connectivity. Cache dirty spatial influence maps and road components before attempting very large cities. Rendering currently uses modular MeshInstance3D nodes; batch repeated meshes with MultiMesh when content warrants it.

## Next architectural split

### Firm simulation budget principle

The new campaign targets a city of roughly 120,000 with SimCity 4-like urban fidelity. This is not a request for 120,000 agents. Building/district aggregates hold population, housing, jobs, demand, service coverage and political interests. Avoid per-person needs, inventories, commutes and world-wide pathfinding. Ambient vehicles and pedestrians are disposable, capped visual effects; offscreen economies must not depend on them. Later congestion can use aggregate road flows if playtesting justifies it.

The initial urban slice should use one editable 64×64 district plus authored background district aggregates. City population totals and editable-district totals must remain distinct and derived from actual data. Cache road connectivity after edits, stagger slow economic/political updates, and use dirty flags for overlays. Batch repeated geometry and reduce distant detail. Profile simulation tick time, frame time and memory on the development PC before expanding; the existing 285-cell benchmark does not validate a developed city.

### Proposed campaign state extensions — not implemented

Separate nation, region/site claim, city/district, colony administration and planet environment. A planet cannot have only one political owner once multiple jurisdictions exist. A nation can operate sites on several planets; species identity must not supply ownership. Commands must validate jurisdiction, treaty access and affected parties for global terraforming.

Store a small authored cast, explicit commitments, event outcomes, campaign facts and seeded scenario identity in authoritative state. Select alternate histories once at scenario creation, then preserve their facts. Keep sandbox collection rewards in a separate profile and retain mode-specific saves. Introduce versioned migrations or explicit incompatibility messages when changing the current save schema; preserve the internal `credits` treasury key while displaying Marks.

These extensions are proposed boundaries, not existing types or implemented commands. Add them in the bounded order in ROADMAP.md rather than building a general political simulator first.

### Presentation components

The presentation script intentionally keeps the initial prototype easy to run. Before more content, split colony rendering, galaxy rendering and each HUD panel into scenes/components. Preserve command boundaries. Future tactical battles should take fleet IDs and return validated damage/retreat outcomes; pause strategy time during that first battle slice. Do not put combat state into visual ship nodes.
