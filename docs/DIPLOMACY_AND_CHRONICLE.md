# Alien contact and the civilization chronicle

User-endorsed direction: approachable, expressive diplomacy and trade inspired by Spore, plus a persistent timeline of discoveries, decisions, allies, wars and fleet losses. This is the full design specification. [EXPEDITION_CONTACT.md](EXPEDITION_CONTACT.md) records the integrated first-contact, portrait, treaty-consequence and structured-history pilot; the remaining scope below is not all implemented.

## Contact screen

An original expressive alien representative occupies the main portrait area. Show society name, species, government and philosophy separately. A compact relationship panel explains trust, grievances, dependencies and active commitments. The player can communicate, propose trade, negotiate access, ally or take hostile actions through clear contextual choices. Preserve Spore's immediacy without copying its interface artwork or species.

Start with posed portraits and a few authored expression states; full animated characters follow a proven interaction loop. Reuse the asset-spec pipeline for silhouettes, expressive ranges, materials and animation requirements. No runtime language model is required for negotiation logic or dialogue.

Trade proposals show both sides of an offer: goods, quantity per period, price, duration, minimum reserves, transport capacity, delivery route and interruption conditions. Explain whether a partner needs the goods and what blocks an agreement. A route is a persistent agreement drawing on actual output, not a recurring manual delivery mission. Use a small useful proposal set before building elaborate bargaining.

Diplomatic agreements alter access and obligations. Allies may share survey information or grant passage while expecting help. A hostile nation may still accept a limited trade deal. Planet, nation, species and empire are distinct identities; a war with a government is not automatically a war with every member of its species.

## A chronicle with causes

Record first contact, world discoveries, settlements, major construction/capability milestones, meaningful player decisions, agreements, broken promises, war declarations, battles, named ship losses, territorial changes, regime changes and confirmed civilization destruction. Keep important individual ships named. Summarize routine production and minor skirmishes so history remains readable.

Each event needs a stable ID, game date, event type, actors, locations, subject entities, player knowledge, known cause IDs and explicit outcome data. Store the payload that was true at the time; a renamed nation or destroyed ship must not erase its historical identity. The visual timeline is a view of this history, not the source of diplomatic truth.

Example chain: survey a storm world → agree to protect a migration corridor → establish biological-material exports → divert the corridor for a strategic installation → partner suspends exports → production stalls → choose compensation or coercion. Timeline cards can trace these links without inventing causality after the fact.

Filters: exploration, politics, trade, colonies, military and ancestors; select a nation, ship or system to see its history. Cards can focus the galaxy map, show a surviving landmark, display the original decision and explain present consequences. Add a session recap and later an era summary. Author these summaries from recorded facts; do not hallucinate victories or historical motives.

War and destruction deserve clear consequence records, not only celebratory counters. Distinguish fleets defeated, a polity dissolved, a colony destroyed and actual confirmed extinction. Unobserved outcomes remain uncertain; do not reveal the hidden galaxy or ancestor plot through omniscient timeline entries.

## Implementation boundaries

Current `state.log` retains only 80 short messages. It is a temporary activity feed and cannot serve as a durable historical record. Introduce a versioned `history_events` collection separate from transient UI logs, with indexed summaries as volume grows. Preserve old saves without fabricating their missing history; mark the point from which comprehensive records are available.

Emit events from successful validated commands and authoritative outcome resolution. Give battle results stable IDs so loading/retrying cannot duplicate casualties or history. Persist unresolved commitments separately and reference the events that created or broke them. Diplomacy reads explicit agreements/grievances, not prose parsed from timeline text.

First slice: one alien contact portrait, one production-backed trade offer, one alliance or access agreement, and a timeline recording survey, choice, agreement and first completed delivery. Gate: every card reflects a real outcome and at least one diplomat reacts to a recorded commitment. Full wars and destruction entries become available when those systems exist; do not fake them for UI spectacle.
