# Space Stage successor: complete target and evidence

Updated 23 September 2026. The active user goal is feature breadth comparable to **all of Spore's Space Stage**, with original art, more satisfying flight and richer trade. A single encounter is not completion. These rows are implementation families, not a claim that every individual Spore tool has already been inventoried. The tool-by-tool, mission-by-mission and upgrade-by-upgrade inventory remains required before a parity audit can pass. Previous small-MVP exclusions describe production order, not the final goal.

## Latest playtest changes our priorities

The user rejected the mandatory planting/warming sequence, constant-height flight, F-centric interaction, weak danger and cheap presentation. Ecology supports exploration and supply chains; it must not replace spaceship play. The desired experience includes mouse-first actions, arrows/numpad for a left-handed mouse setup, real vertical flight and planetary departure, health/energy/weapons, satisfying achievements and animation, sound on every meaningful interaction, music, spoken guidance and tutorial pointers. They are willing to pay for quality audio and authorize browser-assisted production. Approve a concrete price/license before purchase; willingness to pay is not a subscription order.

Preserve the alien/Vanguard campaign. A human Sol-system start is an additional desired scenario direction; its precise historical relationship to that campaign is not settled. Do not erase one to implement the other.

## Research: interaction and HUD

The [official Spore manual](https://shared.steamstatic.com/store_item_assets/steam/apps/17390/manuals/manual.pdf?t=1642702281), printed pages 46–47, identifies separate tool categories, tools, minimap, communications, health and energy, pause and options. It describes mouse-applied tools, alternate arrow-key movement, and vertical/zoom controls. The [official control reference](https://www.spore.com/comm/tutorials/controls) includes Space-stage shortcuts. See also our earlier [wiki research](SPORE_SPACE_STAGE_RESEARCH.md).

Design consequence: reserve consistent screen regions for ship condition, navigation, active tool and communications. Keep the world unobscured. Tool actions need targeting feedback, sound, energy/cooldown feedback, cancellation and a visible result. Do not copy interface art or ship designs. The present rectangular HUD is still interim; fewer paragraphs alone do not achieve the requested quality.

## Requirement ledger

| Required family | Current evidence / gap | Completion evidence required |
| --- | --- | --- |
| Mouse-first tools and movement | Click target approaches/uses; terrain click moves in Morrow | Native playtest of targeting, cancellation and accessibility in every flight scene |
| Arrows/numpad, mouse-only alternatives, remapping | Additive action bindings and on-screen ascent/descent/stop; remapping UI missing | Left-handed input playtest; saved bindings; no mandatory F/WASD |
| Surface altitude, orbit, planetary return | Same Morrow state survives surface/orbit round trip; tests in test_flight.gd | Natural-feeling transitions, more than one visitable world; native input review |
| System/galaxy navigation, range, fog, wormholes, core | Existing strategic graph/fog; field flight is still isolated | Unified ship/location/state and traversable range/access/endgame mechanics |
| Health, energy, repair, recharge, damage, defeat/recovery | Energy exists; field danger/health/defeat absent | Actual damage and costs, readable bars/warnings, fair recoverable failure |
| Weapons, targeting, upgrades, cooldowns, combat | Missing in personal flight | Functional weapon catalog and enemy encounters; meaningful tests and playtests |
| Allied fleet recruitment, commands, losses | Missing | Persistent fleet ships, ally consequences, usable flight combat |
| Hostile empires, wars, raids, defense, conquest | Strategic relations only | AI decisions, attacks, territorial outcomes and diplomacy consequences |
| Contact, expressive aliens, government/philosophy | Three authored faction rules; static UI | Animated representatives, coherent reasons, distinct actions/abilities |
| Relations, gifts, treaties, alliances, tribute, buyouts | Some treaties/trade in strategic prototype | All interactions catalogued, costed and persistent; visible reactions |
| Trade, cargo, supply chains, prices and demand | Local pod order and separate strategic resource trade | Connected physical cargo/economy, route access, finite demand, optional manual trading |
| Colonization, colony design, production, defenses | Existing aggregate city prototype | Integrated personal flight/empire loop, visible costs/time, viable specialization |
| Terraforming climate and atmosphere | Strategic climate project; local thermal tool | Planet-wide states, tool effects, ecology support, capacity and consequences |
| Collection, abduction, deployment, ecological tiers | Two modeled organisms; simple samples/cultivation | Species inventory, habitats/feeding relationships, meaningful interventions |
| Terrain sculpting, coloring and world decoration | Missing | Usable manipulation tools with persistent visible results |
| Uplift/monolith, tribal/civilization worlds | Missing | Civilizations advance and enter living diplomacy |
| Planet destruction and extreme tools | Missing | Persistent outcomes and reactions; exhaustive special-tool inventory |
| Discoveries, artifacts, rare collections, story | Six strategic discoveries; short local journal | Distinct discovery gameplay, useful rewards, ancestor campaign encounters |
| Missions, timed dangers, ecological crises | Planting intro rejected; no replacement mission system yet | Variety without compulsory repeated errands; threats can be understood and prevented |
| Badges, ranks, alternate unlocks, philosophies | Three strategic ranks; field milestones only log entries | Full progression inventory, meaningful alternate paths, audiovisual achievement delivery |
| Chronicle, decisions, losses, alliances, annihilation | Strategic history plus isolated local journal | One persistent structured timeline covering actual gameplay events |
| Sandbox, cheats, story unlocks | Strategic sandbox cheats exist | Same flight systems usable in sandbox; deliberate story rewards without withholding basics |
| Human solar-system colonization | Not implemented | Selectable playable human scenario, coherent resources/locations and progression |
| Ship/building/creature editors, user content | Previously deferred; absent | Explicit scope decision for editors; do not silently count as parity |
| Galactic Adventures extension | Not assumed to be base Space Stage | Clarify expansion scope; do not claim expansion parity |
| Professional HUD, icons, radar, tutorial arrows | First compact flight HUD and pointer; still placeholder visual design | Reviewed visual system and native readability at supported window sizes |
| Lifelike animation and responsive ship FX | Three bounded procedural grazers; scout banks/pitches | Art-reviewed creature rigs, ship effects, encounters and achievement animation |
| Full SFX coverage, music, spoken guidance | 20 original flight/UI WAVs, adaptive thrust, candidate music, Windows scratch speech/captions and mixer; professional performances and full-game coverage still missing | Event coverage audit, mixed tracks, subtitles, volume controls, licensed masters |
| Saves, performance, regression, fun | Tests cover existing bounded mechanics | Cross-view deterministic state, migrations, full sessions and clean-PC profiles |

## Production order

1. **Flight/input checkpoint:** mouse commands, arrows/numpad, ascent and orbital return, remove planting from required introduction; migrate old saves. This is progress, not a completed game.
2. **Responsive ship encounter:** health, weapons, telegraphed danger, fair recovery; proper HUD instruments/tool icons; audio event coverage, music and spoken tutorial with pointers. Keep actual player input and listening review as gates.
3. **One connected expedition:** merge personal flight with the strategic authoritative state; visit multiple worlds, buy/sell cargo, refuel/repair, meet an alien and earn a useful promotion. Avoid accumulating disconnected demos.
4. **Sol human scenario and living sector:** scenario content, stronger trade/diplomacy, civilizations, threats and ancestor narrative. Keep scenario data separate from engine logic.
5. **Complete the parity ledger:** enumerate every base-game tool/upgrade/mission/ability and close gaps by family. Full fleet control and first-person flight remain required ambitions. Audit every family and all explicit user additions before marking the goal complete.

Each working milestone must pass appropriate tests, be rebuilt, visually/input reviewed where possible, committed and pushed, with the remote hash verified. Native user evaluation and audio listening cannot be replaced by automated assertions.
