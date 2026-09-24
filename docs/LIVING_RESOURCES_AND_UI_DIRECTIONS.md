# Living resources and interface alternatives

23 September 2026. Design proposals, not shipped mechanics. The user endorses the **surface image's environmental graphic fidelity**, but asks for more convincing living creatures and resources for consumables, equipment and appliances. The flat galaxy Jump button/card and overall UI direction were rejected. Approval of the landscape does not approve its HUD or all its creatures.

The endorsed environment reference is preserved in `art/concepts/surface-fidelity-target-20260923.png` for backup. Built-in imagegen produced two new candidate boards: `artifacts/visual-targets-20260923/ui-alternatives-v1.png` and `artifacts/visual-targets-20260923/wildlife-v1.png`. These remain unapproved local artifacts. Exact [prompts](UI_LIFE_EXPLORATION_PROMPTS.md) are tracked.

## Life means observable behavior

Current tiny umbrella forms need bodies, expressive posture and a readable silhouette at ordinary ship zoom. A grazer bends to feed, another watches, a juvenile follows, and the herd folds its mantles when the ship passes too close. Pond creatures inhale water and settle back into the mud. Plants close around an approaching feeder. Ripples, bent stems and discarded membranes make resource origins visible.

Use short local state machines (rest, forage, drink, alert, flee) and bounded reactions. Nearby actors animate; offscreen populations, habitat health and production remain aggregate records. Start with a small capped group, not hundreds of independent agents. The art board's three-foot anatomy is not perfectly consistent across views; resolve this in the dimensional model sheet before modelling. Its translucency is appearance guidance, not a requirement for expensive subsurface scattering.

The most useful first loop is an existing bell grazer feeding from an existing lantern plant and reacting to the ship. One better animal with two convincing interactions is the pilot; the new brine siphon is a later candidate, not another immediate rig commitment.

## Proposed ingredients with recognizable origins

Most harvests are ordinary predictable commodities. Reserve special traits for a small number of rare strains or exceptional habitats; do not make every item an affix puzzle. Names and numbers remain provisional.

| Material | Where and how it appears | Consumable possibility | Lasting equipment or appliance possibility |
|---|---|---|---|
| Lantern gel | Harvest ripe pods from lantern reeds; leave immature pods for regrowth | Survey ampoule: temporarily reveals nearby concealed biological traces | Bio-optic scanner lens; nursery grow-light |
| Shed membrane | Bell grazers leave visible casts at resting sites; no kill required | Thermal veil cartridge: temporary resistance to one environmental hazard | Heat exchanger diaphragm; cold-storage lining |
| Filter pearls | Brine siphons concentrate dissolved minerals and leave pellets by pools | Purification capsule: counteracts a specific contaminant | Water recycler cartridge; greenhouse filtration |
| Storm gall | Proposed later plant stores charge in swollen organs after storms | Bioelectric pack: finite inventory recharge, manually consumed | Capacitor bank, with actual material and manufacturing costs |
| Bond resin | Proposed later plant exudate, harvested from a replenishing cut | Repair foam: hull repair over time; interrupted by incoming damage | Machine seals and fabrication adhesive |
| Resonant mineral | Visible outcrop, finite local extraction and a paid mine later | Catalyst used by selected advanced consumables | Sensor resonator or specialized drive component |

These are fictional science-fantasy properties, not real biological claims. A resource is not automatically useful for every recipe: distinct roles make different worlds worth visiting.

## Combinations that create choices

1. **Lantern gel + filter pearl → survey ampoule.** A consumable scanner pulse reveals a concealed vein or biological trace within its local radius. It does not reveal an entire planet, guarantee treasure or replace exploration. One pulse consumes the item; clear visual feedback identifies what changed.
2. **Lantern gel + resonant mineral + fabricated frame → bio-optic lens.** A permanent scanner module distinguishes valuable living deposits. Uses an equipment slot and ship energy; it is not a free universal scanner upgrade. Consuming all the gel now delays this investment.
3. **Shed membrane + bond resin → thermal veil cartridge.** Temporarily protects against a matching environment, opening a short risky expedition. It is not damage immunity. Permanent protection competes for a ship equipment slot and has a larger cost.
4. **Filter pearls + membrane + fabricated casing → water recycler.** A production appliance that reduces a greenhouse's imported water requirement while consuming power and replacement filters. It creates upkeep and a new trade opportunity.
5. **Storm gall + conductive mineral → energy pack.** Manufacturing consumes finite inputs, power and machine time. Use it from inventory. No passive ship regeneration, no automatic refill loop, and homeworld docking remains free.

Show recipes as ingredient icons feeding an output icon, with a short explanation of the output's action. One-click production when requirements are met, visible missing ingredients, no paragraph-heavy interactions. Let players learn useful combinations through discovery, trade, partnerships and badges. Avoid compulsory blind mixing or low-probability crafting rolls.

## Cultivation without chores

Discovery establishes a new supply option: collect a starter specimen, inspect its environmental requirements, then choose cultivation, a supplier contract or occasional wild harvesting. A working nursery/habitat produces automatically within finite space, water, energy and population limits. Harvesting removes mature stock; habitat depletion reduces future yield. Population stocks and timers persist on save so re-entering a scene cannot reset them.

Synergies should create understandable tradeoffs. Grazers can improve reed pollination and provide membranes, but eat some harvestable pods. A pond filtration animal can reduce contamination while needing food and habitat space. A sealed monoculture gives more predictable output but loses these secondary products. No universal best layout or infinite multiplication chain.

Keep finite market demand and shipping/storage costs. Wealth buys convenience and new opportunities; common crops do not print unlimited Marks. Do not require the player to tend a garden to leave a planet, use the ship or progress the main story. Peaceful trade and exploration remain complete paths.

## Three distinct interface directions

The new board explores structure, not three colors on the same box. None is selected yet.

| Direction | Identity | Useful qualities | Risk to resolve |
|---|---|---|---|
| Field instruments | Matte ivory ceramic pieces, inset gauges, warm markings, tactile notched edges | Strong expedition identity; physical, legible controls | Can consume too much space; avoid the board's decorative microtext and worn-frame clutter |
| Signal cutouts | Bold coral/blue/yellow flat shapes, graphic arrows, segmented gauges | Colorful, expressive and quick to build | Giant decorative star shapes can feel childish or confuse real stars; keep them out of the world representation |
| Optical navigation | Bare ivory marks over space, small prismatic accents, precise reticles | Leaves the galaxy visible; direct destination interaction | Can become a generic military HUD; needs distinctive icon shapes and readable focus states |

Initial recommendation to test, not a decision: field instruments for cargo/tools and expressive contact, with a light optical destination reticle. Do not hybridize everything before showing real-sized interactive examples.

The interaction must improve along with the aesthetic. First click selects a star and displays reach/energy information nearby. A second deliberate click on that selected star or its adjacent launch affordance issues travel; hover help explains it, and clicking elsewhere changes selection. Gate invalid commands in simulation. Provide keyboard activation and visible hover/focus/disabled states; no compulsory side-card Jump button. Prototype and playtest this behavior before replacing the shipped controls. The local chart remains surface-only.

The board's gauge colors are not approved: settle one consistent hull/energy palette across all screens and reinforce it with icons. Generated text and decorative motifs are not production UI assets.

## Boundary for the next couple of days

The accepted target is environmental fidelity. Prioritize actual galaxy range/fog/navigation and one existing surface polish pass. If that passes, add the grazer's visible body, feeding and alert animation. Full cultivation, a new species rig, recipes, appliances, RPG skill trees and walking are later slices. Do not represent this concept exploration as shipped content or silently turn the project back into an ecology simulator.
