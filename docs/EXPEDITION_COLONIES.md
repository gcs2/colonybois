# Ship-delivered colonies and export production

23 September 2026. Connected pilot for I01, E01, U01 and P01. Personal flight can now establish an export outpost; this does not complete Spore colony, production or defense parity.

## Play the colony loop

1. At an established colony, approach a dock through Communications and open **Upgrades**. Load a colony kit for **300 Marks, 100 colony materials and 80 colony supplies**. It occupies four actual freight spaces. One kit may be aboard at a time; the scenario allows three total colonies, including Morrow and projects in progress.
2. Carry the kit to unclaimed Nacre I or Kestrel I. Complete the orbital survey, descend, open **Inventory**, and select the kit. Click clear ground. The footprint rejects steep terrain and leaves clearance for water, life, relics, resources and the landing approach.
3. The ship flies to the footprint before unloading. Stop, steer, choose another tool or open a drawer to cancel; the kit stays aboard. There is no second charge when it lands.
4. The site progresses through cargo, frame and pressure-shell stages over **18 colony days: nine active minutes**. Construction continues off-screen. Inspection and pause stop simulation time. Delivered construction does not require further supply trips.
5. Click the hub or use **Communications → Colony administration**. Commission alloy, water or glass production for **60 Marks, 20 local materials and 10 local supplies**. Replacement pays the same cost and retains existing warehouse cargo.
6. A facility produces every two colony days (60 active seconds). Frozen worlds produce two alloy or water units; arid worlds produce two glass units; other combinations produce one. Each cycle consumes half a local supply and two Marks on frozen worlds, one elsewhere. Output pauses at insufficient reserves or the 16-unit warehouse cap.
7. At that world's dock, open **Warehouse**, load real output into the ship and trade it at another world's market. Quantities and origin are conserved. Automated freight is the next integration, not part of this checkpoint.

Only the landing hub exists at completion: no instant town or invented population. Its remaining construction cargo follows the existing settlement model (70 materials, 60 supplies). Full settlement design, workforce requirements, defenses, terraforming-dependent capacity and planet-wide sites remain incomplete. The source city's aggregate economy remains authoritative.

## Persistence and presentation

Campaign snapshot v5 stores kit source, selected coordinates, construction, facility, warehouse and status alongside ship, market, relations and chronicle. Older snapshots migrate without free kits or invented colonies. Failed commands and rejected snapshots leave state unchanged.

The mesh recipe follows `art/specs/outpost_kit_v1.json`. Four construction stages and three export silhouettes replace instant buildings. These are bounded prototype meshes; they are not approved final art. Labels appear on hover. Scene terrain and placement share the same height function. Visual objects do not run a second economy.

Independent service markets now replenish one unit of local producer stock and one unit of demand per good every four colony days, bounded by initial caps. Non-producer stock needs sales; scene changes never reset inventories. These market sources remain an aggregate approximation, separate from owned outpost warehouses. Manufacturing inputs, population demand and freight arrivals must replace/extend this approximation in subsequent work.

## Evidence and open gates

`test_expedition_colonies.gd` covers cost/capacity validation, physical travel and survey, protected sites, actual mouse picking and flight approach, cancellation, staged/off-screen construction, deterministic save/load, operating costs, specialization, storage, cargo conservation, old-save migration and replenishment timing. `review_colonies.gd` renders construction and administration at 1080p. These checks establish behavior and layout, not enjoyable pacing, native control feel or final art quality.

Next: persistent automated cargo routes using these physical warehouses, actual route/access constraints and finite destination demand; retain optional manual trading. Continue broader parity and bounded presentation work alongside that integration.
