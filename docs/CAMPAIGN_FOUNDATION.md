# The Vanguard and the forgotten outpost

## Direction endorsed in conversation

The opening takes place in a developed but neglected society descended from an abandoned colonial outpost. It has existed for thousands of years. The distant civilization that founded it continued flourishing after contact ceased, before civil war and an outside invasion nearly destroyed it. The ancestor polity is provisionally the United Nations of Earth. The player's biological relationship to those ancestors remains undecided; do not silently make every resident human or every alien an engineered human.

The local government is corrupt and ineffective. The player gains influence through reconstruction and can take power through a coup or open rebellion. The Vanguard is a movement and coalition, not automatically the permanent name or ideology of the resulting government. Taking power in one nation does not give control over the planet.

The ancestors were imperfect. The invaders were not a uniformly evil species. The campaign unfolds through present-day relationships and decisions; collecting recordings cannot be its main activity. Going to space ends the opening chapter, not the plot. The first story campaign has an authored canonical backbone and resolution, while local conditions and the consequences of player choices can vary. Later alternate scenarios may vary larger political circumstances without contradicting their own facts.

## The city as a tutorial

**Provisional city name: Latch. Provisional starting district: South Loop.** These are concept names, not approved final naming. The city grew around the pressure doors of the original habitat. A surviving phrase, “keep the latch,” began as an instruction to preserve the air seal and became a promise to keep a place safe for someone returning home.

The opening shows a populated city, not an empty grid. Houses occupy ancient landing struts. Workshops have grown into maintenance galleries. A redundant radar dish supports a public garden. Furnaces, patched pipework, markets, shrines and freight yards show many generations of adaptation. Old technology is only one layer of the place: present-day residents have invented architecture, festivals and useful machines of their own.

The administrator's upper terrace remains warm during a breakdown in the lower district. Players can see residents traveling, workshops closing, and warm windows returning after repairs. The HUD displays population before military prestige. Inspectable districts explain housing, employment, warmth, supply access and representation. The visual concept proposes 2,480 residents across the city, with direct initial control of a smaller district; that figure is illustrative and is not the prototype's simulated population.

The first tutorial teaches inspection and repair through a heating failure, then route planning through a supply bottleneck, zoning through displaced households, and politics through competing claims on the repaired utility. People gain or lose access because of visible infrastructure and policy. A decision should create another way to play instead of merely selecting a dialogue tone.

## Currency with a history

**Provisional name: Cinders; one Cinder.** After the supply ships stopped, communal furnace keepers issued fired-clay rings as claims on heating time. Workshop rings acquired marks identifying their issuer, and people traded them for food, repair labor and shelter. Later administrations standardized them into currency while retaining the old name. Current Cinders are not mechanically exchangeable for a fixed amount of heat: the origin explains the culture without adding an unwanted commodity-backed currency simulation.

The current treasury and displayed trade revenue use Cinders. A neighboring country can have its own money, banking rules and view of who guarantees a payment. The interface may show the local equivalent of a trade without pretending every planet adopted the same currency. Keep material stockpiles distinct from money.

## Choices grant different powers and obligations

These are **proposed campaign abilities, not implemented mechanics**. The founding routes give an initial capability emphasis; they do not permanently equate rebellion with democracy or a coup with dictatorship. Later reforms can change institutions at an understandable cost.

| Choice | Action or feature it enables | Concrete cost or obligation |
| --- | --- | --- |
| Organize public heating cooperatives | Mutual-aid dispatch: neighboring districts share emergency crews and supplies | District councils gain a say in routing; export commitments can be interrupted to meet local guarantees |
| Secure an administrative reconstruction grant | Priority works order: mobilize a project quickly using existing departments | Sponsors acquire concessions and expect appointments or protected contracts |
| Lead a broad uprising | Local charters and volunteer logistics: attract settlements through negotiated membership | Members expect representation; some national decisions require their consent |
| Lead an institutional coup | Requisition and rapid deployment through inherited institutions | Powerful backers can refuse cooperation or demand repayment; coercion generates political resistance |
| Found an orbital consortium with a rival nation | Shared launch sites, joint expeditions and pooled rescue capacity | Partners obtain access and a voice in mission priorities |
| Build an independent national space program | Unilateral missions and exclusive research decisions | Higher resource burden and fewer facilities; neighbors can bargain over overflight and access |
| Federate voluntarily | Shared public infrastructure and a larger common market | Constitutional limits and meaningful regional autonomy |
| Seek dominance over neighbors | Centralized routing and strategic control if the effort succeeds | Opposition, security costs, damaged relationships and possible separatism; conquest is future scope |

Choices should have previews of known costs, visible downstream changes and character reactions. Neither a surprise punishment nor a flat +10% modifier is enough. Avoid strict moral labels: a public system can become exclusionary, and an inherited institution can be genuinely reformed. The player should be able to demonstrate a policy through what their government does.

## A planet contains politics

World, nation, species and faction are separate concepts. Some planets are unified; others contain rival nations, federations, disputed regions or shared orbital institutions. A nation can hold territories on multiple planets. A species can live under different governments. Domestic identity, chauvinism and rivalry do not disappear with orbital travel, and should also have individuals and movements who resist them.

Provisional neighbors for the homeworld: a river-port league with trade leverage, upland settlements controlling water infrastructure, and another industrial state competing for orbital access. Names, flags and biology remain open. Trade, recognition, resource agreements and rivalry begin here before alien first contact. Your government can reach space while these neighbors remain independent. A rival may reach another world before you and establish a colony alongside yours.

Terraforming can affect people outside your borders. Planet-wide projects eventually require agreements, compensation or confrontation; owning one settlement must not imply permission to change everyone's atmosphere. Local environmental mitigation remains available within your own territory.

### Implementation boundary

The current prototype supports one settlement site per planet and simple alien capital ownership. The `owner` field is a legacy simplification; its UI now describes site administration, not planetary sovereignty. Actual multiple nations on one planet are not implemented. Before adding them, separate planet environmental state from regions/sites, nations, colony administrations and diplomatic relationships. Expansion permissions must consult site and treaty claims; population and sovereignty cannot be inferred from species.

## Story, replay and sandbox

The canonical story fixes major historical facts and central motivations. Seeded geography, opportunity placement and local situations provide variation. Alternative campaigns can choose different coherent political configurations at the start. Later events must follow those facts and the player’s decisions rather than arbitrarily changing an ally's history.

Story accomplishments unlock architecture, species presets, starting situations, government variants, flags and unusual scenario rules in sandbox. Core building, diplomacy and exploration are available without finishing the story. An explicit sandbox unlock-all option should remain possible. Unlocks require a separate persistent collection record when implemented; they should not depend on retaining one campaign save.

## What this update implements

- Records the endorsed narrative and design constraints, superseding the earlier “no plot selected” note.
- Gives the prototype's money a player-facing name and historical tooltip while preserving its existing save key and economy.
- Labels colony population explicitly and clarifies that a settlement is not global sovereignty.
- Provides a developed-city art concept for review, not a claim that the story tutorial, coups, domestic nations or these abilities are already playable.

Next story implementation should be a single developed district, a heating problem, one political choice and a visible consequence. Validate whether the place feels inhabited and the choice changes play before expanding the campaign.
