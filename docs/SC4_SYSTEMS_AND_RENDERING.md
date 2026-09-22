# SimCity 4 research: demand, desirability, regions and art format

Research checkpoint: 22 September 2026. The first section summarizes sources; the remainder is our proposed design, not a description of implemented systems or an exact reconstruction of SC4 formulas.

## Findings that matter

**Demand and desirability are separate.** SC4's demand indicates potential development, while local conditions determine where it is viable. New buildings satisfy demand and reduce the relevant demand bar. Wealth and zone density are separate: a low-density lot can house wealthy residents, and a dense apartment can house lower-income residents. This distinction is described by the [Simtropolis demand reference](https://community.simtropolis.com/omnibus/simcity-4/reference/demand-desirability-and-abandonment-r31).

**Services have capacity as well as reach.** The official manual describes local funding and capacity for schools and hospitals, education supporting higher-paying employment, and desirability varying by occupant type. Neighbor deals require connections, an exporter with surplus, a buyer with need and sufficient funds. Transport stations need useful access at both trip ends. These are connected systems rather than decorative service circles. See the [official Deluxe manual](https://cdn.akamai.steamstatic.com/steam/apps/24780/manuals/SIMC4DpcMAN%28ukeng%29_DDAM.pdf), especially printed pages 34–35, 48–51 and 54–59; PDF page numbers differ.

**Growth ceilings are a separate issue from weak demand.** Archived Maxis guidance distinguishes low demand from unsuitable locations, congestion and missing water. It explains that parks/recreation and regional connections can relieve different growth caps. It also connects educated workers with high-tech development and industrial viability with freight access. Treat the advice as historical SC4 design guidance; do not copy every numerical threshold into our game. [Maxis development tips, preserved by Simtropolis](https://community.simtropolis.com/omnibus/simcity-4/reference/tips-tricks-sc4-development-maxis-r366/).

**SC4's appearance is not a shortcut called “pixel art.”** Ocean Quigley's retrospective describes detailed 3D source buildings rendered into images and applied to simple geometry. This supports considering a pre-rendered workflow without abandoning 3D source assets. [Quigley's account quoted by BeyondSims](https://beyondsims.com/2009/05/impostering-in-simsville/). The search excerpt exposed the quotation; full retrieval was blocked. BAT4Max's own published workflow also documents exporting LOD geometry and rendering selected rotations/zooms. [BAT4Max author documentation](https://community.simtropolis.com/forums/topic/40623-bat4max-v5/).

The [StrategyWiki zoning page](https://strategywiki.org/wiki/SimCity_4/Zoning_and_Demand) appeared in search, but full retrieval failed. Do not treat its abbreviated search text as verified exact simulation formulas. Community descriptions sometimes simplify the relationship between education and wealth; our design keeps them distinct.

## Proposed economic model

Maintain aggregate households by income and skill, building capacity and occupancy, jobs by skill requirement, service consumption, vacancies, migration interest, construction commitments and transport access. No individual citizens or commute agents are required.

Start with three housing income tiers (modest, comfortable, affluent), two density levels, and three workforce skill bands. Income, education, density, species and citizenship are distinct fields. A skilled worker need not be affluent; affluent households still depend on lower- and middle-income service workers. Do not encode wealth as moral worth or biological superiority.

Business categories for the developed slice: everyday retail/services, advanced services/offices, fabrication/logistics and research/high-tech. Split the current generic service zone gradually so existing saves can migrate. Advanced businesses need suitable workers, customers or contracts, reliable infrastructure and appropriate locations. Affluent residents support more discretionary/luxury consumption, but population alone cannot create an infinite high-tech economy.

Demand should be a finite, evolving market rather than a permanent growth permission:

1. Estimate viable demand from accessible jobs, population purchasing power, external orders and regional migration.
2. Subtract existing vacant capacity before authorizing new development.
3. Subtract capacity already committed to construction, preventing many empty lots from all claiming the same opportunity.
4. Rank eligible lots by local desirability and access. Reserve demand when construction starts; release reservations on cancellation or failure.
5. Fill occupancy progressively after completion. Recompute demand with smoothed indicators and bounded rates so cities do not oscillate wildly every tick.

Illustrative housing case, with invented balancing numbers: 200 households are interested in moving in; 80 suitable homes are vacant; 40 are under construction. Only 80 additional homes are justified. Zoning another thousand tiles costs no designation money but cannot summon a thousand households. Removing construction does not create new people; it only releases its reservation.

Keep demand, desirability, affordability, capacity and connectivity visible as separate explanations. “No demand for affluent housing” differs from “Demand exists, but this neighborhood lacks water” and “Construction already satisfies the remaining demand.” Use the ledger and graphs to show the consequences of overbuilding without forcing incessant micromanagement.

## Coverage, quality and desirability

Show a circle while positioning a service for quick comprehension. After placement, show effective coverage and utilization. Range is a catchment estimate, not infinite service output.

| Service | Effective simulation role | Constraint / spatial consequence |
|---|---|---|
| Education | Gradually changes skill mix and access to advanced employment | Student places, teachers, funding, travel access and time |
| Fire/rescue | Reduces incident severity/probability and improves response | Staffing, water availability, road reach and concurrent calls |
| Civic watch | Reduces crime losses and supports confidence | Coverage, staffing, unemployment and social conditions |
| Healthcare | Improves health and workforce reliability | Patient capacity, access, funding and pollution exposure |
| Water/life support | Supplies development and industrial operations | Source yield, network reach, total demand and harsh-world costs |
| Parks | Local amenity, ecological health and leisure | Nearby access, maintenance, land use and crowding |
| Entertainment/culture | Visitor demand and discretionary spending | Household purchasing power, transport, noise and operating cost |
| Transit | Connects residents, work and services | Connected routes, access at each end, capacity and operating budget |

One clinic may cover a wide area geographically yet have room for only part of its patients. Education should improve a district over time rather than instantly transform every nearby household. Parks cannot compensate for missing basic water. Higher-income households may demand higher reliability and amenities; lower-income districts must still remain viable and worthwhile to serve.

A proposed quality calculation combines distance/access, funded capacity divided by actual load, and infrastructure reliability. Coverage scores are capped; overlapping ten identical services must not produce unlimited desirability. Essential shortages can block growth while softer amenities rank sites. Residential, industrial and commercial desirability use different weights: freight access helps a factory, quiet helps homes, customers help shops.

## Cities that need one another

Use regional markets and real route capacity. A research city can buy manufactured goods from a working harbor city; the harbor buys specialist services and relies on education partnerships. Another settlement supplies food, power or recovered water where its environment supports it. Specialization is a consequence of advantages and investment, not only a menu bonus.

Separate local commuting from long-distance trade. Same-world districts may share a labor market if travel times permit. Ordinary interstellar routes move cargo and migrants; they do not imply daily interstellar commutes. Each shipment must have an origin surplus, destination need, price, transport cost, route access and a capacity allocation. Buying and selling the same item through circular routes cannot manufacture money.

Examples of worthwhile decisions: expand a local school or import skilled migrants; protect affordable housing near a new station or permit expensive redevelopment; accept a neighbor's power deal or retain costly autonomy; build freight rail through an industrial corridor or place a harbor terminal on scarce waterfront. An embargo or water shortage should change local choices through these links.

For the first regional test, use just two cities, one labor-market connection on the same planet, one freight good and one utility/service agreement. Prove conservation, specialization benefits and understandable disruption before adding more products. Keep all cities advancing under one authoritative clock; avoid exploiting whichever city happens to be on screen.

## Art format comparison — no decision has been made

The comparison below is a project assessment, not a measured speed claim.

| Approach | Main advantage | Work it still requires | Camera consequence |
|---|---|---|---|
| Hand-authored pixel art | Strong stylization; little runtime geometry | Controlled palette and pixel scale, coherent angles, manual cleanup, many state/animation frames | Best with fixed angles and chosen zoom steps |
| 3D models rendered to sprites | Rich lighting/detail can be baked; same source generates variants | Source modeling, multi-angle exports, atlases, sorting/occlusion, shadows, memory and sprite states | Fixed or stepped angles; arbitrary orbit breaks the illusion |
| Real-time orthographic 3D | Reusable source models, smooth states/lighting, existing Godot foundation | Geometry/material budgets, LOD, strong art direction and performance work | Can start with an isometric-style camera while retaining rotation |

An angled orthographic camera is a presentation choice; it does not require a 2D simulation. Our current camera already uses orthographic projection. The missing quality is not cured by that setting alone: authored models, coherent materials, street composition, lighting and UI still matter.

Hand-authored pixel art might win if that aesthetic is preferred and a restricted camera is acceptable. It is not automatically cheaper for dozens of buildings with four directions, construction, damage, density variants and night states. Image generation does not guarantee aligned pixel grids or consistent silhouettes across those frames. Pre-rendering can reuse a model, but still needs model production and a robust export/atlas pipeline.

Recommendation: keep the existing runtime intact and build a reversible comparison around HAB-01. Use the same footprint and source model for real-time orthographic and four-angle sprite versions; add one deliberately art-directed pixel-style study. Compare inside the same street block, not isolated promotional renders. Log production time, revision time, frame time, texture memory, readability, seams, overlap errors and growth animation quality. Ask the user to choose the preferred visual result after seeing all candidates. Do not commit the whole kit to a format before this test.

This slightly changes the art plan: the first model is also the rendering-format test. A successful reusable 3D source can feed either real-time rendering or pre-rendered sprites. The model/spec effort is not thrown away if the presentation changes.

## Staged implementation and acceptance

1. **Visible finite demand:** replace the present coarse jobs/population gate with occupancy, vacancy and committed construction demand. Gate: development consumes demand; empty zoning does not; cancellation safely releases reservations.
2. **Service reach and load:** add education, water, parks and entertainment alongside the existing safety/clinic services, with capacity and funding. Gate: overcrowding has visible consequences; overlays explain both reach and quality; no unlimited stacking.
3. **Income/skill diversity:** implement modest and comfortable households first, then affluent households and advanced businesses. Gate: density is independent of wealth; every income tier remains useful; education changes skill mix gradually.
4. **Two-city market:** one complementary specialization pair, actual conserved trade and labor access. Gate: connecting cities creates measurable benefit, severing a route removes it, and switching views changes neither result.
5. **Advisory mayor:** recommend improvements using these real constraints; automatic spending follows only after recommendations are reliable. Gate: explanations cite demand, service load, access and costs rather than arbitrary personality bonuses.

Tests must cover deterministic growth allocation, simultaneous construction reservations, save/load mid-development, chronic shortages, vacancies/downgrading, service overload, embargo, demand exhaustion and economic recovery. Human playtests must show that connecting and redesigning districts is enjoyable.

Current status: the executable has coarse demand checks, two development levels, free rectangle zoning, multi-tile lots, police/fire/clinic/shuttle reach and basic risks. It does **not** yet have the regional demand/wealth/education/capacity system above. This document defines that next gameplay work without pretending the current prototype already reproduces SC4.
