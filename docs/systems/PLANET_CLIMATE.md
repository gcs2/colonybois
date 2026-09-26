# Personal planet manipulation

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. Integrated T01 checkpoint; not completed terraforming parity.

An orbital survey reveals independent temperature and atmosphere axes. Buy reusable tools under dock Upgrades → Equipment, or finite single-use supplies under Climate. Select an Environment hotbar icon, then click the planet in orbit or the terrain on its surface. The paid pulse changes one axis over eight shared simulation seconds, including after departure. The climate instrument shows the current point and T0–T3 climate bands. These bands are the terraforming T-score: climate distance from the center. They are separate from the biosphere/ecological T0–T3, which tracks established life and food chains; see [PLANET_BIOSPHERE.md](PLANET_BIOSPHERE.md). Climate potential is not a claim of an established ecosystem.

| Equipment | Effect per pulse | Cost |
| --- | --- | --- |
| Heat ray / Cooling ray | Temperature +10 / −10 | 250 Marks each; 25 energy/use |
| Cloud accumulator / Cloud vacuum | Atmosphere +10 / −10 | 230 Marks each; 20 energy/use |
| Thermal / Cooling catalyst | Temperature +10 / −10 | 65 Marks; consumes one carried unit |
| Atmosphere generator / reducer | Atmosphere +10 / −10 | 60 Marks; consumes one carried unit |

Reusable equipment requires Explorer 2 or Merchant 2. Consumables require Explorer 1 or Merchant 1, have two units per type per dock, and share a six-unit terraforming locker. These are explicit scenario balance choices; they are not claimed as exact retail Spore prices, timing, names or thresholds. Homeworld climate is protected. Survey, range, energy, ownership, finite stock, funds and trade access are validated before spending. No passive energy regeneration was added.

## Connected consequences

- Climate moves gradually; a planet accepts one pending pulse. Changing views cannot duplicate it. A deployed pulse finishes off-screen.
- Unstabilized axes return one point toward native conditions every 30 idle seconds. [Collected and deployed plant sets](PLANET_BIOSPHERE.md) now stop drift from crossing the supported ring; complete food chains determine useful capacity. Do not call the temporary climate state a finished terraformed ecosystem.
- Climate distance from the center determines T-score. Modified planets use 40/120/240/360 resident growth caps at ecological T0/T1/T2/T3, bounded by their current climate, changed power requirements and local suitability. These small outpost limits are scenario tuning, not the established home city's population model. Existing buildings/residents remain intact.
- T0 pauses export outpost production. Higher tiers improve actual output; operating costs track environmental severity. Colony administration displays the same output used by the simulation.
- Substantial native-climate displacement causes one grievance per known affected nation: −20 for a foreign owner and −8 for the ecological commune elsewhere. Reasons, tool deployment, purchases and completion enter the chronicle. This is initial reactive diplomacy, not full reference war/terraforming behavior.
- Snapshot v12 preserves axes, pending pulses, stock, carried units and diplomatic consequences. Climate-derived colony effects are rebuilt from the authoritative state on load. Earlier snapshots receive no tools or fabricated progress.

## Presentation and budgets

The globe and atlas retain identical coastline/elevation textures and receive climate uniforms. A cached ice-free substrate reveals ground as ice retreats. Atmosphere and cloud density respond to pressure. The local terrain changes surface color, frost and dryness; fog and sky respond to atmosphere. No terrain deformation or sea-level simulation is introduced. The additional substrate is one RGB texture per existing cached planet recipe; climate ticks do not rebake geography.

Eight original editable vector icons use a shared thermometer/cloud and direction-arrow vocabulary. Consumables add a canister silhouette. Named hover help gives costs and use instructions; the existing hotbar supports two rows and paging. One bounded orbital ring indicates a settling pulse. These are provisional presentation assets; no final art/audio or player approval is claimed. The atlas now has opaque backing so orbital ships cannot obscure its readings. Unassigned escort meshes start hidden.

## Verification and remaining work

`tests/test_planet_climate.gd` exercises actual purchases, independent gradual axes, finite resources, off-screen continuation, deterministic saved continuation, atomic malformed-save rejection, migration, diplomatic effects, colony utility/output changes and real scene tool/shop commands. It checks shared map/orbit/surface uniforms and unchanged geography texture identity. The full regression suite also covers the expanded hotbar's actual visible shortcuts.

`tests/review_planet_climate.gd` renders native and changed orbit, atlas, surface and dock views at 1080p and 1440p. Review corrected conspicuous thaw striping, unassigned escort visibility and verbose objective overflow. Captures demonstrate rendered state, not native mouse usability, play balance or AAA acceptance.

Subsequent [biosphere work](PLANET_BIOSPHERE.md) now connects collected/deployed specimens to durable ecological stabilization and visible food-chain requirements. No compulsory planting tutorial was introduced. Complete combined/extreme manipulation tools, full ecological capacities and civilization reactions before claiming T01 parity. Keep aggregate simulation and bounded visuals; do not widen the content corpus or add per-organism simulation as a substitute for this interaction.
