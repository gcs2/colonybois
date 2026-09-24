# Alien colonies: surrender, capture and ruins

23 September 2026. W01 offensive-action pilot, using the same personal ship, weapons, economy and simulation clock. Snapshot v17. Coloring/sculpting remain excluded and further planet modification remains deferred.

## Playing

Veyr I, Orin I–II and Lumen I–III now have landable settlements. Each has a civic hall, habitation terraces, export works, two turrets and one patrol. These are small frontier compounds, not full cities or multi-city planetary invasions. Neutral guards do not attack. Declare war through Communications → Conflict before using weapons; confirmation still names the treaty and escort consequences. A military jump can enter a hostile destination at normal energy cost; that permission does not let freight cross a closed border or let the flagship cross hostile intermediate systems.

Select the defense laser, purchased seeker or ground bomb, then click the appropriate target. Existing range, approach, energy, cooldown, dodge, ally and damage rules apply. Civic/housing/industry start at 240/96/96 hull. Losing 160 total civilian-structure hull triggers surrender while the hall survives. Guard losses alone do not force surrender. Ten laser hits against the hall cost 50 energy and leave it at 80 hull. These are original tuning values; taking those hits under defensive fire has not passed a native balance playtest.

Surrender stops new attacks and guard/escort fire. Committed projectiles still land. Click the hall to inspect its terms. Approach within 30 m and wait for airborne ordnance before choosing:

- **Accept:** transfer that planet, its surviving structures and finite export reserves into actual colony administration. The port retains proportional hall damage. A destroyed factory transfers no production module; the existing paid installation action restores it. A small authored civil reserve supplies 20 materials and 20 supplies. Capture gives no Marks, ship repair, energy or colony kit. The three-administered-site cap includes home and projects already under construction.
- **Reject:** a second confirmation resumes hostilities and ends further surrender offers from that colony. Destroying the hall leaves an unclaimed ruin, loses its reserve and closes markets, services and freight. Other contacted governments lose 15 relations, or 25 for the ecological Commune. Rebuilding requires an actually purchased kit, survey, physical deployment and eighteen colony days; it gives only the usual landing hub.

The former owner's other worlds keep their ownership and market restrictions. Mixed ownership makes the star contested; a player foothold permits transit, but a neighboring hostile planet remains embargoed. When a government has no territory left, its war ends, its raid withdraws, its treaties end and the chronicle records territorial defeat. This does **not** claim its species is extinct. Enemy reconquest and enemy-versus-enemy wars remain open.

## Economy and recognition

An undisturbed foreign holding starts with eight export units and adds one per sixty active seconds, up to sixteen, while at peace with surviving industry. This capture reserve is separate from its ordinary shop stock; a fully unified rival production/trade economy remains future work. Annexation transfers the reserve once to the player's warehouse and clears the original record. Existing production, upkeep, cargo collection and freight then operate from the captured outpost. Capture cannot transfer a second reserve on replay.

Conqueror counts distinct accepted surrenders, with scenario tiers at 1/2/5/10/20 and the existing tier-point system. Conqueror 1 is another eligibility path to the 160-Mark first hull upgrade; buying capacity does not heal damage. Capture does not also count as colony founding, and damaging civilians gives no Defender credit. With the current three-site cap, only Conqueror tiers 1–2 are reachable. More badge definitions are not a claim that their later content exists.

## Implementation and evidence

`territory_catalog.gd` and `data/territories.json` define the six holdings. `surface_combat.gd` owns all combat HP and projectiles; `territories.gd` owns outcomes and transfers. `expedition_session.gd` owns their shared clock and atomic snapshot. Per-planet ownership now governs trade, prices, services and escort recruitment. The sector graph still governs transit. No separate tactical clock, individual inhabitants or higher colony cap was introduced.

Snapshot v17 preserves outcomes, damage, ownership, reserves, colonies, relationships and recognition. v16 saves initialize no conquests or new badge rewards. Invalid outcomes, duplicate awards, invented surrendered HP and missing territorial records reject without replacing the current session. Terminal history remains after a ruin is rebuilt.

The full regression suite passed with 60 territorial checks; the expanded 72-check suite also passes, including paid reconstruction and its save/load. Tests cover real weapons, costs, surrender, defense damage, refusal, territory transfer, surviving production, mixed-system access, government defeat, upgrade purchase, construction limits, persistence and actual scene click/button wiring. `tools/CaptureTerritories.gd` produces actual settlement, surrender, annexation and ruin views at 1080p and 1440p. The primitive authored building kit follows [its specification](../art/specs/alien_colony_structures.md). This is implementation/layout evidence, not native input, combat balance or final art/audio approval.

Still open: multi-city invasions, richer occupation obligations, economic/religious acquisition, rival war economies, allied attack requests, enemy retakes, more weapon/defense roles, extinction policy and broader fleet combat. Final presentation and full-session enjoyment remain unapproved.

Reference context: indexed excerpts from [Invasion](https://spore.fandom.com/wiki/Invasion), [Turret](https://spore.fandom.com/wiki/Turret) and [War](https://spore.fandom.com/wiki/War) distinguish damaging a city, surrender and destruction. This pilot adapts those interactions; its costs, thresholds and frontier-compound abstraction are scenario choices, not claims of exact retail parity.
