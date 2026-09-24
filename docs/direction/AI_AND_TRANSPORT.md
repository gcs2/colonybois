# Living cities: AI, transport and rewarding expansion

> Design intent; task status and execution order live in the task board. [Documentation map](../README.md).

Design proposal, with implementation status below. These are rules for a game, not a commitment to simulate every resident or use online language models.

## How the AI actually works

A mayor or foreign government is a small persistent record plus a decision function. The record holds priorities, resources, commitments, beliefs about other actors, and a current plan. The function reads a limited view of the simulation, lists legal actions, estimates their value, and submits one through the same validated command interface the player uses. The simulation decides whether it succeeds.

There is no neural-network training required for this version. We write the options, evaluation rules and failure behavior. Interesting behavior comes from competing needs and consequences rather than hidden dice rolls that invent events.

The decision cycle:

1. Observe: budget, shortages, service gaps, unemployment, known territory and relationships. Nations only see surveyed territory and information they acquired.
2. Set a goal: protect a district, relieve a shortage, secure a trade partner, contain an expanding rival.
3. Generate a bounded candidate list: existing sites and a few suitable empty lots, rather than every possible building in the galaxy.
4. Reject unaffordable, forbidden or impossible options before scoring.
5. Score benefits and costs over a short horizon, adjusted by personality and mandate.
6. Keep the current plan unless a new option is meaningfully better or an emergency invalidates it. Execute one step, record the reason, and reconsider later.

An illustrative score is `urgency × expected improvement × priority − construction burden − recurring cost − political harm`. Normalize terms before weighting so that population counts do not swamp everything else. This is a design formula, not the present runtime implementation.

For example, a district has 55/100 fire risk and a narrow surplus. The mayor estimates a rescue station would cover 420 residents, but its upkeep would push the budget negative. An ordinary mayor saves for it or requests a budget increase. A safety-first mayor uses their emergency allowance. An industrialist may choose a profitable workshop first, accepting a recorded period of exposure. If a fire occurs, it follows the risk model; the plot does not arbitrarily punish a personality.

## Appointing a mayor

The player controls the mandate: housing, industry, conservation or balanced growth; a treasury allowance and material allowance; minimum reserves; tax bounds; protected districts; whether demolition and rezoning are permitted. Default delegation should allow routine construction only. It must not bulldoze a carefully designed city or commit the empire to a treaty.

Each mayor needs identity, two or three understandable priorities, competence expressed as planning horizon or quality of estimates, and a political constituency. Avoid secret efficiency multipliers being the whole character. Loyalty should affect requests, patronage or political responses through authored rules, not randomly erase resources.

Start with advisory mode: show a proposed action, price, expected result, alternatives and explanation. Then enable automatic execution within the chosen allowance. Use the same planner for both. The player can pause delegation, replace the mayor or override a plan. Keep a decision log and make an outcome visible: “Rescue station completed; 420 residents now covered; upkeep +0.75 Marks/day.”

Suggested record: stable ID, nation ID, colony ID, mandate, priority weights, allowed actions, spending allowance, reserve floor, current plan ID, next decision day, recent decisions. Stable IDs and seeded tie-breaking preserve save/load behavior.

## Nations, rivals and allies

Government defines who can authorize a policy, its obligations and institutional bonuses. Philosophy weights goals. A mercantile dictatorship and a mercantile republic can both want trade while having different internal constraints. Neither species nor philosophy defines permanent friendship or evil.

A nation-level planner chooses between economic development, trade proposals, diplomatic reassurance, exploration, territorial claims and, once implemented, military preparation. Local mayors perform the construction steps within allocated budgets. Alliances add actual obligations and shared opportunities, not simply a green relationship score. Rivals can still trade when mutual gains outweigh the perceived threat.

Keep separate relationship components: trust, fear, dependence, grievance and ideological friction. Explain decisions using the strongest reasons. Remember promises and events so that a reliable partner is treated differently from one who recently broke a pact. Reactions should decay on different timescales; immediate anger and historical mistrust should not be one number.

Plans can have prerequisites: “Secure mineral imports” may require contact, favorable terms and an accessible route. If a route is embargoed, re-plan instead of repeatedly submitting the same failing command. War decisions must consider strength, supply, objectives and exit conditions; tactical battles are outside the current city milestone.

## Keep it cheap and testable

Proposed cadence: aggregate city economy daily, a mayor decision every 6 days, national strategy every 30 days, emergency reactions when an incident occurs. Stagger actors across days. Cache road/service graphs until infrastructure changes. Cap candidates and actions per decision. None of this runs per citizen or per rendered frame.

Replay seeded scenarios and inspect a trace of candidates, scores, rejected constraints and chosen actions. Test budget/reserve limits, protected lots, inaccessible sites, lack of information, repeated failures, contradictory orders, saving midway through a plan and emergency overrides. Run automated long sessions to find bankruptcy loops or building/demolishing oscillation. Human playtests determine whether the behavior is interesting.

Optional generated dialogue belongs above this system. A line such as “We need that harbor open” can describe a real decision, but generated text never grants resources, changes treaties or becomes the source of truth. Offline authored dialogue is sufficient for the first version.

## Transport as a source of city growth

Model a network graph: stations and terminals are nodes, road/rail/water/air links are edges. Links have travel cost and capacity. Buildings contribute aggregate commuting and freight demand to nearby stops. Allocate flows between districts and employers; reduce accessibility benefits when a corridor exceeds capacity. Render a small number of vehicles proportional to activity, regardless of population.

| Option | Reward | Tradeoff |
|---|---|---|
| Road shuttles | Cheap local access using existing roads | Limited capacity and operating expense |
| Rail / tram corridors | High-capacity districts and recognizable station centers | Continuous right of way, capital cost, less flexible routes |
| Harbor freight and ferries | Coastal industry and cross-water access | Terminal placement, water routes, specialized capacity |
| Benevolent aerial megafauna | Cross terrain without roads; distinctive civic identity | Feeding groves, resting platforms, ecological limits and weather |

The squid-like carriers should be partners with needs, not engines with tentacles painted on. Healthy habitat sustains route capacity; overcrowding or pollution reduces willingness to visit. Simulate route-level availability, not individual animal or passenger brains. Station design can make the relationship visible: broad landing canopies and garden terraces rather than cages.

Reward expansion through a visible chain: open a connection → improve access to jobs → develop wider lots → gain recurring revenue and new civic choices. Celebrate the first functioning line or newly served neighborhood. Higher density should require dependable services, not a repeated construction quota. Preserve old districts so that progress leaves a history in the city.

## Current build versus next work

Implemented: free rectangular zoning; growing multi-tile lots; daily tax/expense/export ledger; powered road-connected civic services; local crime and fire risk; damage and repairs; two-stop road-shuttle coverage extending the commute allowance; rendered paths and a capped shuttle animation; generated building textures and advisor portraits. Latch's harbor boats are visual ambience for the surrounding city, not a new freight economy. Exports are still the existing aggregate interstellar trade system.

Not yet implemented: appointable mayors, independent nation economies and planning, continuous railway construction, capacity-based transport flows, megafauna routes, functional maritime cargo terminals, combat or conquest. Existing foreign AI is the small relationship/embargo evaluator in `simulation.gd`, not the full planner described here.

Next bounded gate: one advisory mayor recommends three affordable service improvements and accurately explains them; then allow execution inside a player-set allowance. In parallel with later transport work, add one railway corridor with two stations, visible trains and measured accessibility benefits before adding more vehicle types.
