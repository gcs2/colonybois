# Allied escorts and persistent losses

23 September 2026. F01 implementation checkpoint. An alliance now grants access to a physical escort alongside shared charts. This connects diplomatic choices to the same personal flight, combat, travel, treasury and chronicle.

## Playing the feature

Earn an Explorer, Merchant or Defender tier and establish an alliance. In that nation's orbit, open Communications / Y → Fleet and request its ship. A nation lends one ship at a time. The highest of those three badge tiers grants one slot per tier, capped at three. This is a scenario bridge; reference master-rank progression and five-slot fleets remain open.

The flight HUD shows fleet capacity and faction-colored hull meters with named tooltips. Its fleet icon opens the roster. Ships follow the flagship in a bounded formation, retain damage across travel and surface/orbit changes, and assist the target you actively attack. Stop/manual cancellation ends the attack order. **Follow / hold fire** keeps escorts from firing; it does not make them invulnerable. Fleet inspection pauses the shared simulation.

| Ally | Escort candidate | Hull | Weapon |
| --- | --- | ---: | --- |
| Veyr Directorate | Latchwing | 100 | 10 damage / three seconds |
| Orin Consortium | Bellrunner | 80 | 8 damage / two seconds |
| Thalen Commune | Reedskate | 120 | 8 damage / three seconds |

Escort weapons reach 32 m and use their own firing cycle, without draining or replenishing the flagship's energy. Formation movement is bounded to 18 m per simulation tick, with interpolated presentation. Terrain clearance and the orbital globe constrain positions. These are original scenario values, not a claim to match Spore's retail ship statistics.

## Risk and consequence

- Surface and orbital defenses can aim at the closer escort. Their existing fixed-volume warnings can hit escorts, the flagship, or both. The Morrow pulse field can also damage escorts.
- Destroyed ships remain lost. Each loss costs seven relations with the lending nation and enters the chronicle once. A replacement requires 60 simulation seconds, 120 Marks, an available slot and a renewed request in allied territory.
- Return a ship to dismiss it. Its remaining hull is preserved; dismiss/recruit does not repair it. Losing the alliance or entering an embargo recalls the ship immediately.
- Dock services → Fleet provides repairs at 0.8 Marks per missing hull point, rounded up. Physical dock proximity, affordability and embargo checks apply. Repairing an escort costs Marks even at the homeworld; free homeworld **energy recharge** remains unchanged.
- Allied final hits use the same persistent enemy defeat, Defender progression and salvage outcomes as flagship hits. Escorts do not automatically collect salvage or start unrelated fights.

## Persistence and verification

Session v11 stores faction ship identity, assignment, hull, position, cooldown, sortie/loss counts, replacement time and fleet stance. Older campaigns gain no free ships. Loads validate alliance access, earned capacity, health, clocks and record shape before replacing the live campaign. Cosmetic meshes and beam flashes remain outside saves.

`tests/test_allied_fleet.gd` has 53 assertions: earned capacity, recruitment, actual UI commands, damage, costs, replacements, recall, atomic persistence, migration, deterministic formation, actual orbital/surface enemy strikes and scene-clock combat. The scene check allows escorts time to catch up; they do not teleport into weapon range to pass it. Stop and inspection guards cover both flagship and allied fire. Full-suite results and current package are recorded in NEXT_SESSION.md.

`tests/review_allied_fleet.gd` renders actual orbit formation, roster and contact states at 1080p/1440p. The first render exposed a clipped HUD icon, corrected by allocating its proper width. Models are original modular **candidates**, specified in [allied_escorts.json](../art/specs/allied_escorts.json); current HUD, ship art and reused audio remain unapproved. Native combat feel, final rigs, dedicated weapon audio and frame-time profiling remain review gates.

## Reference and remaining scope

[Space fleets](https://spore.fandom.com/wiki/Space_fleets), [Alliance](https://spore.fandom.com/wiki/Alliance) and [Space Stage](https://spore.fandom.com/wiki/Space_Stage) indexed excerpts support ally-supplied ships, progressive fleet access and relationship penalties for losses. Full-page fleet retrieval was blocked. Exact retail capacity unlocks, repair/replacement rules and complete fleet behavior remain audit work. Our three-slot badge bridge, costs and timers are explicit adaptations.

This is personal allied support. Rally Call is now connected through [active support](SHIP_SUPPORT.md); war and the territorial pilot are tracked under W01. Larger fleet capacity, AOE repair, allied attack requests, production-built military fleets, selectable formations and first-person piloting remain tracked requirements. Planet modification is deferred by the latest user instruction; follow NEXT_SESSION.md for the current work order. No full F01 or Space Stage parity claim is made.
