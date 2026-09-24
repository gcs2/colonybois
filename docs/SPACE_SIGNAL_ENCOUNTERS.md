# Optional orbital encounters

23 September 2026. E02/E01/D01/P01 integrated pilot. Coloring and sculpting remain skipped; further planet editing remains deferred.

## Playing this checkpoint

Complete an orbital survey of Nacre I or Kestrel I. A physical orbital contact appears and the ship receives a signal notice. Click the contact, the signal icon beneath the rank readout, or Communications → Orbital signals. The panel shows the choices, their costs and relationship consequences; hover explains the detailed rules. Opening inspection pauses the simulation.

- **Nacre I — A narrow departure.** Commit to cover a convoy's departure, then disable the existing Rake cutter within 180 active simulation seconds. Success pays 90 Marks and adds 12 consortium relations. The deadline continues after leaving the planet. Expiry or explicit abandonment costs four relations; declining the initial offer costs nothing. Alternatively, approach the convoy and pay 60 Marks for its passage, gaining eight relations. The payment does not neutralize the cutter or protect the player's ship.
- **Kestrel I — Who owns the silence?** Approach the registry buoy and scan within 12 m for six uninterrupted simulation seconds. Each attempt spends eight energy. The existing sentry remains dangerous. Steering, a new order, departure or tow interrupts the scan; loading and inspection preserve its progress. Once scanned, publish the competing claims for 20 Marks, Commune +12 and Directorate −6, or sell exclusive evidence for 100 Marks, Directorate +10 and Commune −8. Either closes the other option. Declining is also available.

Offers have no deadline until an escort commitment is accepted. These are finite scenario encounters: no respawning rewards, compulsory deliveries or repeated mission quota. Completed outcomes feed the Captain badge family and an alternate eligibility path for the first reactor reservoir. The upgrade still costs 180 Marks, requires dock access and adds empty capacity. Current two-event content can earn Captain 1 only; later tiers are not reachable yet.

## State and integration

`data/space_signals.json` owns scenario content, positions, options and outcome values. `space_signals.gd` owns discovery, offered/active/decision/terminal states, deadlines, paid scan attempts and one-time outcomes. The expedition fixed tick advances it. `signal_view.gd` draws the two bounded orbital actors, a scan beam, a short convoy departure motion and the actual controls. One shared ship position is sampled before simulation ticks, so range checks read current flight rather than its last autosave.

Snapshot v15 preserves encounter state alongside money, relations, contacts, achievements, pending recognition and the chronicle. Older campaigns gain no invented choices, completed encounters, Captain tiers or payouts. Restores validate known encounter IDs, phases, timestamps, progress, choices and required chronicle keys before replacing live state. Chronicle's Encounter filter records discovery, commitment, evidence and final outcome with a cause link. No new AI service, purchase or runtime dependency was added.

Pause, focus loss and map/popup inspection preserve an active scan while canceling ordinary approach orders. Actual movement, Stop, tool changes and travel cancel the scan. A scan interrupted after paying must pay again to restart. A resolved or declined encounter cannot be reopened for another outcome.

## Evidence and limits

The full regression run passed with the initial 60 signal checks; the expanded 67-check signal suite also passed after fixing loaded-scene scan cancellation. Checks cover real surveys, actual weapon damage, paid peaceful resolution, offworld expiry, abandonment, mutually exclusive diplomatic rewards, Captain-only paid shop eligibility, no free recharge, disk persistence, atomic rejection, real mouse picking/buttons, scan beams, pause and fresh-scene resume. Final shared-session, flight, planet-map and system-chart regressions also passed after the fix. The established suites remain separate evidence for their own systems; test counts do not establish fun or visual quality.

`tools/CaptureSignals.gd` renders the actual orbit, offer, scan, decision and badge screens at 1080p and 1440p. Captures exposed verbose option copy hiding the decline choice; the revised panels show all initial choices without scrolling. Existing portraits animate; actor bobbing and departure motion are bounded. Meshes, UI and reused sound cues remain provisional and need native playtesting and player approval. Recorded voice is still absent.

This is not an empire-war simulation, full Spore mission parity, a finalized ancestor-story reveal or an expanding content corpus. The convoy uses the existing local attacker and an aggregate departure deadline; it does not have individually simulated passengers, independent health/target AI or a traveling strategic fleet record. The registry outcome changes real relations, access thresholds, money and history; it does not transfer a planet or implement a legal-ownership simulation. Costs, durations and rewards are scenario tuning.

Spore reference: [Space Stage](https://spore.fandom.com/wiki/Space_Stage), [pirates](https://spore.fandom.com/wiki/Pirate), and [invasion](https://spore.fandom.com/wiki/Invasion) establish personal ship play, independent hostile ships, deceptive signals and territorial danger. Indexed excerpts were accessible; direct Mission/Pirate retrieval was blocked. Our two authored situations are adaptations that exercise the lifecycle, not copied missions or evidence of complete reference coverage. Empire raids, defense, territorial loss, wider emergency/contract types and native balance review remain open.
