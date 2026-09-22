extends RefCounted
## Cargo is paid before departure; founding does not conjure a completed town.
const MARKS: float = 300.0
const MATERIALS: float = 100.0
const SUPPLIES: float = 80.0
const DAYS: int = 18

static func begin(sim: RefCounted, pid: String, source: String) -> String:
	if not sim.state.planets.has(pid): return "Unknown planet."
	var planet: Dictionary = sim.state.planets[pid]
	if sim.state.flagship.system != planet.system or not str(sim.state.flagship.destination).is_empty(): return "Bring your flagship to this system first."
	if not str(planet.owner).is_empty() or sim.state.settlements.has(pid): return "This site is occupied or an expedition is already landing."
	if sim.state.colonies.size()+sim.state.settlements.size() >= 3: return "Three settlement sites are already committed."
	if not sim.state.colonies.has(source): return "Choose an established colony to supply the landing."
	var depot: Dictionary = sim.state.colonies[source]
	if sim.route_between(sim.state.planets[source].system,planet.system).is_empty(): return "No permitted cargo route from the supply colony."
	if sim.state.credits < MARKS or depot.materials < MATERIALS or depot.supplies < SUPPLIES: return "Landing needs 300 Marks, 100 materials and 80 supplies from the selected colony."
	sim.state.credits -= MARKS
	depot.materials -= MATERIALS
	depot.supplies -= SUPPLIES
	sim.state.settlements[pid] = {"source":source,"remaining":DAYS,"duration":DAYS}
	sim._log("Landing expedition to %s: 300 Marks, 100 materials and 80 supplies committed. Hub ready in 18 days." % planet.name)
	return ""

static func phase(project: Dictionary) -> String:
	if int(project.remaining) > 12: return "Landing cargo and surveying the site"
	if int(project.remaining) > 6: return "Assembling the landing hub"
	return "Commissioning power and life support"

static func tick(sim: RefCounted) -> void:
	for pid: String in sim.state.settlements.keys():
		var project: Dictionary = sim.state.settlements[pid]
		if sim.route_between(sim.state.planets[project.source].system,sim.state.planets[pid].system).is_empty():
			project["blocked"] = true
			continue
		project["blocked"] = false
		project.remaining -= 1
		if project.remaining > 0: continue
		sim._create_colony(pid,false)
		sim.state.settlements.erase(pid)
		var faction: Dictionary = sim.faction_by_id("directorate")
		faction.relation -= 8
		faction.reason = "Your new landing hub challenges our expansion ambitions (-8)."
		sim._log("Landing hub operational on %s. Remaining cargo: 70 materials, 60 supplies. Lay roads and zone your first homes." % sim.state.planets[pid].name)
