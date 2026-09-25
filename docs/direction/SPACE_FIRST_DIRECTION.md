# Space-first direction

> Design intent; task status and execution order live in the task board. [Documentation map](../README.md).

Latest user direction: exploration, dynamic alien worlds and interplanetary supply chains become the main game. Cities support population, administration, production and eventual military recruitment. Direct first-person ship flight/combat is a desired later capability. This supersedes the city-first production sequence; it does not delete the existing playable city prototype or its research.

## Core promise

Discover worlds worth caring about, personally explore and influence them with your ship and tools, and connect their unusual strengths into a civilization capable of reaching farther. The ancestors' mystery emerges through that expansion and the people affected by it. Read [SPORE_SPACE_STAGE_RESEARCH.md](../research/SPORE_SPACE_STAGE_RESEARCH.md) for the concrete reference mechanics and the distinction between enjoyable personal interaction and repetitive servicing. Richer trade, living planets, diplomacy and history remain endorsed.

Working rhythm: spot a lead in the living galaxy → personally pilot the ship into range and approach a world → scan, meet life, and use a chosen tool on an interesting target → make a consequential choice about cargo, danger, or diplomacy → carry the result to a buyer, contact, or colony → earn recognition and buy a new capability → follow the new opportunity. The ship and the world stay present during the action; menus explain and extend play rather than replacing it. Routine freight can be automated after discovery. Optional missions, discoveries and playful surprises add stories without making repeated errands the core loop.

This is a synthesis informed by the Space Stage manual, the saved gameplay samples and the user's timestamp notes. The Gemini chronology pasted on 25 September is a useful mechanics hypothesis map; its exact timestamps, controls and specific causal claims still need targeted review. See the [video evidence register](../research/SPORE_EXTENDED_VIDEO_EVIDENCE.md) and [source register](../research/SPORE_SOURCE_REGISTER.md). Use source footage to understand action-feedback-reward patterns, then keep our own art, writing and interface original.

## What makes a planet different

Give each authored world an environmental rule, a recognizable ecological relationship, a practical opportunity and a complication. Temperature/color alone are insufficient. Examples below are proposals, not approved lore or implemented mechanics:

- A storm world grows conductive filaments during seasonal blooms. Harvesting windows affect supply; excessive harvesting reduces the next bloom. Storage or another supplier makes the route dependable.
- A cold moon has plentiful structural ore but little available energy. Imported reactor components unlock processing; a local heat source offers a different settlement footprint.
- A living ocean produces specialized biological compounds. A native species depends on the same organism; an agreement or cultivated substitute may outperform unrestricted extraction.

Use a handful of ecological state variables and timed transitions, with visible fauna and plants representing them. Do not simulate every organism or promise unrestricted evolution. World discovery must include atmospheric behavior, sound, motion and an interesting decision, not only a resource tooltip.

The user now explicitly wants a broad flora/fauna collection with ecological synergies. See [LIVING_ECOSYSTEMS.md](LIVING_ECOSYSTEMS.md) and the fourteen-species production catalog in `art/specs/species_catalog_v1.json`. Habitat patches and feeding roles are separate. Plan bounded aggregate populations and actual resource flows; art/animation reuse supports growth of the collection. Only the existing pod/grazer and simple field cultivation are implemented so far.

## Trade should change what the player can do

Use a small number of resources with different functions and actual production relationships. Raw materials, processed components and specialist products should not all be differently colored sellables. Test perhaps six goods and two short production chains before widening the catalog.

Illustrative chain: ore + energy → structural components; biological compounds + components → expedition equipment. Reliable equipment supply enables longer or harsher expeditions. Another faction may supply one stage, making diplomacy an alternative to self-sufficiency. Resource names and recipes remain to be authored.

Demand is finite. Production consumes inputs, customers consume outputs, inventories buffer interruptions and route capacity constrains delivery. Recurring operating costs, travel time, reserves, access treaties and environmental variation should all be legible. No unlimited sale price or circular trade profit. A price change alone is less interesting than a shortage that alters exploration choices.

Offer useful automation: minimum reserves, delivery priorities, backup suppliers and warnings for sustained disruption. Report why a route is underperforming. The flagship opens opportunities and responds to exceptional events; personal hauling remains available without requiring the player to service every established route.

## Colonies support the adventure

Start with landing site, extraction/production modules, population/skills, life support and a few meaningful placement decisions. Colonies can supply crew, specialists, administrative capacity and later recruits. Recruitment takes people and training capacity, creating an opportunity cost rather than generating soldiers from an abstract button.

Deep municipal zoning remains an optional later layer if playtests justify it. The 120,000-person home city and Vanguard background remain available narrative/context assets, but a mandatory extended city tutorial no longer precedes the space loop. Whether to retain a short political prologue is an open pacing decision. Nations remain distinct from planets and species.

## The ancestors through playable discoveries

Expressive alien contact, consequential trade and a persistent timeline follow [DIPLOMACY_AND_CHRONICLE.md](DIPLOMACY_AND_CHRONICLE.md). The chronicle links discoveries, agreements, decisions and eventual battles to their known causes; it must not reveal hidden facts.

Keep the historical foundation: a forgotten outpost, evidence of Earth's former civilization, internal conflict and outside invasion, neither flawless ancestors nor uniformly evil invaders. The final resolution is still open.

Prefer living evidence: a modified ecosystem, a still-used trade standard, a community claiming an old charter, a facility serving a purpose different from its apparent one. Restoring a route can reveal a contradiction in the supposed evacuation history. Using an installation can alter who controls access. History should affect present choices instead of rewarding a quota of recordings.

## Art pipeline priorities

Retain specification → concept → dimensional model → engine review → revision → validated export. Move the pilot from HAB-01 to one complete expedition scene: a distinctive terrain patch, three related flora forms, one fauna species, a useful resource formation, one ancestral structure and an authored scout ship visible up close. Limit variation until those assets form a coherent world.

Ships intended for first-person flight require actual 3D geometry, close-view materials, a readable cockpit/HUD, thruster/weapon sockets and collision proxies. A pre-rendered city overview remains possible; do not make fixed-angle sprites the only source for ships or navigable environments. Preserve the creepy-cute identity across all views.

## Revised production gates

1. **Personal ship interaction:** one isolated planet encounter with responsive scout movement, scanning, collection/deployment and one visible environmental response. Gate: it is fun to visit and experiment before adding a larger economy. Specify tool feedback, creature behavior and sound with the art. Keep the small first-person flight/renderer risk test, but do not make cockpit combat a prerequisite for proving this loop.
2. **Expedition art pilot:** develop that encounter into one genuinely distinctive authored planet scene with a useful discovery, playful behavior and a clear decision. Human visual/play review is required.
3. **Three-world economy:** home base plus two complementary destinations, six provisional goods, two production chains, finite demand and automatic routes. Gate: discovering the second world makes the first more useful; one disruption has understandable remedies.
4. **Living frontier slice:** a trade partner, a rival claim and one ancestor encounter with persistent consequences. A peaceful 30–60-minute session should work without repeated errands.
5. **Integrated combat:** connect the proven flight slice to persistent ships, crew, production and fleet orders. Losses and repairs affect the strategic economy. Pause strategic time initially during combat.

The galaxy may eventually support many worlds, but do not author twelve elaborate biomes before three worlds produce a good loop. Full municipal simulation, massive seamless worlds, multiplayer, unrestricted ecology and large fleet battles are outside these first gates.

Existing code has simple environment modifiers and aggregate trade, not the richer ecology or supply-chain model proposed here. No engine migration or rendering-format rewrite has been approved.
