# Breadth and depth of content

23 September 2026. The user explicitly requires a wide, deep corpus of distinct content throughout the game. This is a general product direction, independent of the screenshot attached to that message. Presentation work and a small mechanical prototype do not fulfill it.

## The requirement

Every major system needs enough distinct things to make discovery, preparation, collection, trade and progression worth pursuing. Distinction should change a decision, an interaction, a constraint or a relationship. New names, colors and higher numbers alone are insufficient.

Keep the full Spore feature-family goal in [SPACE_STAGE_TARGET.md](SPACE_STAGE_TARGET.md). The categories below organize production; they do not replace that goal with a small content pack or claim feature parity.

| Corpus | Functional distinctions to build | Examples of required supporting systems |
| --- | --- | --- |
| Ship tools and equipment | Survey methods, collection limits, environmental reach, travel capability, defense, weapon behavior, utility roles and tradeoffs | Shared equipment catalog; installation/selection; energy/cooldown/capacity; contextual targets; actual upgrade acquisition |
| Resources and goods | Different sources, processing uses, regional demand, transport/storage requirements and substitutes | Planet deposits; production recipes; finite markets; cargo; persistent automated routes |
| Flora, fauna and ecosystems | Habitat, trophic role, interactions, collection/deployment constraints and useful ecosystem changes | Authored species identities; bounded aggregate ecology; scanned knowledge; living animation; habitat feedback |
| Worlds and sites | Hazards, geography, environments, settlements, resource opportunities and political access | More actual visitable destinations; coherent globe/local coordinates; discovery and travel costs |
| Civilizations and characters | Separate species, nations, governments and philosophies; motives, voice, obligations and reactions | Expressive diplomacy; relationship memory; agreements, grievances and decisions with consequences |
| Artifacts and discoveries | Capabilities, research choices, cultural value, disputed ownership and campaign consequences | Authored events and characters; usable rewards; alternatives to repeated recording collection |
| Ships and fleets | Different silhouettes, roles, fittings, movement and tactical behavior | Authored 3D kits, sockets and animation; combat; persistent vessels, losses and production |
| Colonies and infrastructure | Specialized outputs, local constraints, service capacities and regional interdependence | Aggregate city simulation; finite demand; useful world specialization; transport connections |
| Achievements, ranks and chronicle | Recognition across different play styles; optional abilities and durable accounts of choices | Shared milestone definitions; meaningful unlocks; distinct celebration; history of trade, wars, alliances and losses |

## What counts as implemented content

Each entry needs a stable ID and a production record containing:

- Player identity and purpose: name, recognizable silhouette and concise description.
- Mechanical difference: valid targets/conditions, inputs, outputs, limitations and consequential interactions.
- Acquisition and placement: where it is found, manufactured, negotiated or unlocked; seed/scenario rules where applicable.
- Presentation: source art/spec, icon/model/materials, animation/effect/audio requirements and UI states.
- Persistence: owning state, save representation and migration needs; a shared identity across views.
- Verification: an actual use case, failure/cancellation behavior where relevant, and an in-game encounter in which the difference matters.

A written species brief is a brief. A modeled organism is an asset. A working, discoverable organism with gameplay and presentation is implemented content. Track these stages separately. The existing four field tools and two modeled organisms are a foundation, not an adequate corpus.

## Next content milestone

After the current camera/effects checkpoint, start a data-driven equipment/content ledger tied to the playable game. First migrate existing tool definitions out of scattered UI/model constants without changing saves. Then add mechanically distinct, usable entries with the required command paths, acquisition and audiovisual feedback. In parallel planning, identify the shared-state and multi-world prerequisites for resources, markets and discoveries. Do not populate menus with nonfunctional entries to inflate counts.

Grow content in playable sets: a world creates a need or opportunity; a tool lets the player act on it; a resource/specimen has a useful destination; a faction or discovery adds a meaningful choice. Expansion should produce a richer session, not a catalog detached from the game.

The next planning checkpoint must establish a per-family inventory with **brief / asset / mechanic / integrated / reviewed** status. Count working entries and their interactions separately from planned entries. Numerical corpus targets will be explicit production targets, not a substitute for playtesting or permission to cut requested feature families.
