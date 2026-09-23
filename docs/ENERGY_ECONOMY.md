# Finite ship energy

23 September 2026. Implemented in the isolated flight prototype; not a complete shared galaxy economy.

- No passive recharge, including waiting, landing and emergency tow. Version 5 saves migrate without free energy or packs.
- Use an **Energy pack** item inside **Inventory / I**: +50 energy, consumes one pack, capacity three, eight-second cooldown. Excess beyond 100 is lost. Full batteries cannot waste a pack.
- Local communications or clicking a service location leads to actual dock travel. Arrival opens services without refilling automatically. The player chooses the quoted service or purchases a pack.
- Homeworld recharge is always free. Away from home, service quotes use missing energy and the provider's rate. Full tanks cannot incur a charge. Pack prices and available stock differ by provider.
- `data/energy_services.json` owns provider locations, rates, pack prices and stock caps. Packs, stock, cooldown, energy and homeworld identity are saved.
- **Current limitation:** Morrow is the only flyable world and is the homeworld, so both accessible recharge services are free. Foreign-world recharge pricing is tested model behavior; foreign travel is not implemented. Local movement currently consumes no energy; tools and defenses do. Interstellar travel cost is a parity integration gap, not permission to make expeditions free.

The service rings and dock approach are temporary scaffolding. Spore-style colony communications should replace this ad hoc presentation when flight and empire state are connected. No permanent Recharge button belongs on the flight HUD. The current inventory drawer also remains a prototype pending the reference-led palette design.
