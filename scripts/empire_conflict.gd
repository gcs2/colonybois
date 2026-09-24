extends RefCounted
## War, warned orbital raids and paid local defenses on the shared expedition clock.
const C = preload("res://scripts/surface_combat.gd")
const Field = preload("res://scripts/encounter_state.gd")
const HOME := Vector3(18,12,14)
static var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/empire_conflict.json"))
var state: Dictionary = {"nations":{},"sites":{},"raid":{},"serial":0,"defended":[]}
var flashes: Array = [] # Render feedback; authoritative damage is applied on the fixed clock.
static func strategic(id: String) -> String: return "s0p0" if id == "morrow" else id
static func field_id(id: String) -> String: return "morrow" if id == "s0p0" else id
static func fresh_nation() -> Dictionary: return {"war":false,"warning":0,"truce":0,"next_raid":0,"victories":0,"declared":0}
static func fresh_site() -> Dictionary: return {"integrity":100,"battery":false,"ammo":0}
func nation(id: String) -> Dictionary: return state.nations.get(id,fresh_nation())
func site(id: String) -> Dictionary: return state.sites.get(strategic(id),fresh_site())
func at_war(id: String) -> bool: return nation(id).war
func local(game: RefCounted) -> bool:
	return not state.raid.is_empty() and state.raid.phase == "attacking" and state.raid.planet == strategic(game.field.state.planet_id) and game.field.state.flight_mode == "orbit" and not game.traveling()
func port_reason(id: String) -> String:
	if site(id).integrity <= 0: return "Port disabled by raid damage. Repair it through Colony defense."
	return ""
func peace_cost(id: String) -> int: return maxi(100,250-nation(id).victories*50)
func reason(game: RefCounted, id: String, action: String) -> String:
	if action in ["declare","peace"]:
		if not data.factions.has(id) or not game.sector.faction_by_id(id).get("contacted",false): return "Establish contact first."
		if game.territory.eliminated(id): return "This government has no remaining territorial holdings."
		var n: Dictionary = nation(id)
		if action == "declare":
			if n.war: return "Already at war."
			return "Truce holds for %d s." % (n.truce-game.field.state.time) if n.truce > game.field.state.time else ""
		if not n.war: return "No war to settle."
		return "Requires %d Marks." % peace_cost(id) if game.field.marks < peace_cost(id) else ""
	if not game.sector.state.colonies.has(id): return "Choose an established colony."
	var s: Dictionary = site(id)
	if action == "battery" and s.battery: return "Defense battery already commissioned."
	if action == "rearm" and (not s.battery or s.ammo == data.battery_ammo): return "No ammunition needed."
	if action == "repair" and s.integrity == 100: return "Port is intact."
	if action not in ["battery","rearm","repair"]: return "Unknown defense order."
	if not state.raid.is_empty() and state.raid.planet == id and state.raid.phase == "attacking": return "Defeat the raid or negotiate peace before servicing this port."
	if game.field.marks < data[action+"_marks"] or game.sector.state.colonies[id].materials < data[action+"_materials"]: return "Needs %d Marks and %d local materials." % [data[action+"_marks"],data[action+"_materials"]]
	return ""
func command(game: RefCounted, id: String, action: String) -> String:
	var blocked: String = reason(game,id,action)
	if not blocked.is_empty(): return blocked
	if action == "declare": declare(game,id,"You declared war."); return ""
	if action == "peace":
		var cost: int = peace_cost(id); game.field.marks -= cost
		state.nations[id].war = false; state.nations[id].truce = int(game.field.state.time)+int(data.truce_seconds)
		state.nations[id].next_raid = 0
		var f: Dictionary = game.sector.faction_by_id(id); f.relation = -10; f.embargo = false; f.reason = "Negotiated peace; former treaties remain ended."
		if not state.raid.is_empty() and state.raid.faction == id: finish(game,"withdrawn")
		game.diplomacy.record(game,"war","Peace with "+str(f.name)+"; 300 s truce. Treaties must be renegotiated.",id,{"marks_delta":-cost,"truce_until":state.nations[id].truce})
		return ""
	state.sites[id] = site(id)
	game.field.marks -= data[action+"_marks"]; game.sector.state.colonies[id].materials -= data[action+"_materials"]
	if action == "repair": state.sites[id].integrity = 100
	else: state.sites[id].battery = true; state.sites[id].ammo = int(data.battery_ammo)
	game.diplomacy.record(game,"war",str(game.sector.state.planets[id].name)+" · "+action+" order completed.","",{"action":action,"marks_delta":-data[action+"_marks"],"materials":-data[action+"_materials"]},0,"",field_id(id))
	return ""
func declare(game: RefCounted, id: String, why: String) -> void:
	var n: Dictionary = nation(id)
	if n.war: return
	n.war = true; n.warning = 0; n.declared = int(game.field.state.time); n.next_raid = int(game.field.state.time)+1; state.nations[id] = n
	var f: Dictionary = game.sector.faction_by_id(id)
	f.relation = mini(-60,int(f.relation)); f.embargo = true; f.reason = why
	for pact: String in ["trade","non_aggression","alliance"]: game.sector.state.agreements.erase(id+":"+pact)
	game.fleet.reconcile(game)
	game.diplomacy.record(game,"war",str(f.name)+" is at war with you. Treaties ended; trade and transit closed.",id,{"reason":why})
	game.field.note("war_"+id+"_"+str(game.field.state.time),str(f.name)+" declared hostilities · open Colony defense.")
func target(game: RefCounted, id: String) -> String:
	var chosen: String = ""; var best: float = -INF
	for pid: String in game.sector.state.colonies:
		if site(pid).integrity <= 0: continue
		var score: float = 100-float(site(pid).integrity)-(30 if site(pid).battery and site(pid).ammo > 0 else 0)
		if id == "consortium":
			for amount: int in game.colonies.state.outposts.get(pid,{}).get("stock",{}).values(): score += amount*5
		if id == "commune": score += float(game.sector.state.planets[pid].terraform)*100
		if score > best: best = score; chosen = pid
	return chosen
func tick(game: RefCounted) -> void:
	flashes.clear()
	var now: int = int(game.field.state.time)
	for id: String in data.factions:
		var f: Dictionary = game.sector.faction_by_id(id)
		if not f.get("contacted",false) or game.territory.eliminated(id): continue
		var n: Dictionary = nation(id); state.nations[id] = n
		if n.war:
			f.relation = mini(-50,int(f.relation)); f.embargo = true
			if state.raid.is_empty() and now >= n.next_raid:
				var pid: String = target(game,id)
				n.next_raid = now+int(data.raid_interval)
				if not pid.is_empty():
					state.serial += 1; state.sites[pid] = site(pid)
					state.raid = {"id":state.serial,"faction":id,"planet":pid,"phase":"inbound","arrival":now+int(data.raid_warning_seconds),"hull":float(data.factions[id].hull),"at":C.packed(HOME),"aim":C.packed(HOME),"fire_at":0,"ready":0,"bombard":0,"battery_ready":0}
					game.diplomacy.record(game,"war","Raid inbound to "+str(game.sector.state.planets[pid].name)+" in 90 s. Intercept in orbit, prepare defenses or negotiate peace.",id,{"raid":state.serial,"planet":pid,"arrival":state.raid.arrival,"target_reason":data.factions[id].priority},0,"raid:"+str(state.serial),field_id(pid))
					game.field.note("raid_"+str(state.serial),"Raid inbound · "+str(game.sector.state.planets[pid].name)+" · 90 s · open Colony defense")
		elif now >= n.truce and f.relation <= -50 and id+":non_aggression" not in game.sector.state.agreements and id+":alliance" not in game.sector.state.agreements:
			if n.warning == 0:
				n.warning = now+int(data.warning_seconds)
				game.diplomacy.record(game,"war",str(f.name)+" threatens war in 90 s unless relations improve above −50.",id,{"deadline":n.warning,"reason":f.reason})
				game.field.note("ultimatum_"+id+"_"+str(now),str(f.name)+" threatens war · improve relations within 90 s")
			elif now >= n.warning: declare(game,id,"Relations remained at or below −50 after the warning.")
		elif n.warning > 0:
			n.warning = 0; game.diplomacy.record(game,"war",str(f.name)+" withdrew its threat of war.",id)
	if state.raid.is_empty(): return
	var r: Dictionary = state.raid; var s: Dictionary = state.sites[r.planet]
	if r.phase == "inbound":
		if now < r.arrival: return
		r.phase = "attacking"; r.bombard = now+15; r.battery_ready = now+6
		game.field.note("raid_arrival_"+str(r.id),"Raid reached "+str(game.sector.state.planets[r.planet].name)+" · port under attack")
		game.diplomacy.record(game,"war","Raid arrived; port under bombardment.",r.faction,{"raid":r.id},game.diplomacy.state.keys["raid:"+str(r.id)],"",field_id(r.planet))
	if not local(game): r.fire_at = 0
	if s.battery and s.ammo > 0 and now >= r.battery_ready:
		s.ammo -= 1; r.battery_ready = now+6; flashes.append({"kind":"battery","planet":r.planet,"at":r.at.duplicate()}); damage(game,12)
		if state.raid.is_empty(): return
	if now >= r.bombard:
		r.bombard = now+15; s.integrity = maxi(0,int(s.integrity)-20); flashes.append({"kind":"bombard","planet":r.planet,"at":r.at.duplicate()})
		game.diplomacy.record(game,"war","Port struck: "+str(s.integrity)+"% integrity remains.",r.faction,{"raid":r.id,"integrity":s.integrity},game.diplomacy.state.keys["raid:"+str(r.id)],"",field_id(r.planet))
		if s.integrity == 0: finish(game,"disabled")
func finish(game: RefCounted, result: String) -> void:
	if state.raid.is_empty(): return
	var r: Dictionary = state.raid
	if result == "defended":
		state.nations[r.faction].victories += 1
		if r.planet not in state.defended: state.defended.append(r.planet)
	game.diplomacy.record(game,"war","Raid "+result+" at "+str(game.sector.state.planets[r.planet].name)+".",r.faction,{"raid":r.id,"result":result,"integrity":state.sites[r.planet].integrity},game.diplomacy.state.keys["raid:"+str(r.id)],"raid_end:"+str(r.id),field_id(r.planet))
	game.field.note("raid_end_"+str(r.id),"Raid "+result+" · "+str(game.sector.state.planets[r.planet].name))
	state.raid = {}; game.commerce.update_badges(game)
func damage(game: RefCounted, amount: float) -> void:
	if state.raid.is_empty() or state.raid.phase != "attacking": return
	state.raid.hull = maxf(0,float(state.raid.hull)-amount)
	if state.raid.hull <= 0: finish(game,"defended")
func fire_reason(game: RefCounted, at: Vector3) -> String:
	if not local(game): return "No active raid in this orbit."
	if not at.is_finite() or at.distance_to(C.position(state.raid.at)) > Field.LANCE_RANGE: return "Approach within 24 m."
	if game.field.state.time < game.field.state.weapon_ready_at: return "Weapon cooling down."
	return "Requires 10 energy." if game.field.state.energy < Field.LANCE_ENERGY else ""
func fire(game: RefCounted, at: Vector3) -> String:
	var blocked: String = fire_reason(game,at)
	if not blocked.is_empty(): return blocked
	game.field.state.energy -= Field.LANCE_ENERGY; game.field.state.weapon_ready_at = game.field.state.time+Field.LANCE_COOLDOWN; game.field.state.weapon_shots += 1
	damage(game,game.field.lance_damage()); return ""
func step(game: RefCounted, ship: Vector3) -> String:
	if not local(game) or not ship.is_finite(): return ""
	var r: Dictionary = state.raid; var now: int = int(game.field.state.time); var at: Vector3 = C.position(r.at)
	at = at.move_toward(ship if ship.distance_to(HOME) < 34 else HOME,3)
	at = HOME+(at-HOME).limit_length(15); r.at = C.packed(at)
	if r.fire_at > 0 and now >= r.fire_at:
		r.fire_at = 0; r.ready = now+5
		game.fleet.hit_volume(game,C.position(r.aim),4,14)
		if ship.distance_to(C.position(r.aim)) <= 4:
			game.field.state.hull = maxf(0,float(game.field.state.hull)-14)
			if game.field.state.hull == 0: game.field._emergency_tow(); return "tow"
			return "hit"
		return "miss"
	if r.fire_at == 0 and now >= r.ready and at.distance_to(ship) < 28:
		var aim: Vector3 = ship
		for escort: Vector3 in game.fleet.positions(game):
			if escort.distance_to(at) < aim.distance_to(at): aim = escort
		r.aim = C.packed(aim); r.fire_at = now+2; return "aim"
	return ""
func restore(value: Variant, now: int, sector: RefCounted, history: RefCounted) -> Error:
	if not value is Dictionary or not value.has_all(["nations","sites","raid","serial","defended"]): return ERR_INVALID_DATA
	if not value.nations is Dictionary or not value.sites is Dictionary or not value.raid is Dictionary or not value.defended is Array: return ERR_INVALID_DATA
	if value.nations.size() > 3 or value.sites.size() > 3 or value.defended.size() > 3 or not C.number(value.serial,0,1e6,true): return ERR_INVALID_DATA
	var seen: Array = []
	for id: Variant in value.defended:
		if not id is String or not sector.state.colonies.has(id) or id in seen: return ERR_INVALID_DATA
		seen.append(id)
	for id: Variant in value.nations:
		if not id is String or not data.factions.has(id) or not sector.faction_by_id(id).get("contacted",false): return ERR_INVALID_DATA
		var n: Variant = value.nations[id]
		if not n is Dictionary or not n.has_all(["war","warning","truce","next_raid","victories","declared"]) or not n.war is bool: return ERR_INVALID_DATA
		for key: String in ["warning","truce","next_raid","declared"]:
			if not C.number(n[key],0,now+600,true): return ERR_INVALID_DATA
		if not C.number(n.victories,0,value.serial,true) or n.declared > now: return ERR_INVALID_DATA
		if n.war and (not sector.faction_by_id(id).get("embargo",false) or n.warning != 0): return ERR_INVALID_DATA
		for pact: String in ["trade","non_aggression","alliance"]:
			if n.war and id+":"+pact in sector.state.agreements: return ERR_INVALID_DATA
	for id: Variant in value.sites:
		if not id is String or not sector.state.colonies.has(id): return ERR_INVALID_DATA
		var s: Variant = value.sites[id]
		if not s is Dictionary or not s.has_all(["integrity","battery","ammo"]) or not s.battery is bool: return ERR_INVALID_DATA
		if not C.number(s.integrity,0,100,true) or not C.number(s.ammo,0,12,true) or (not s.battery and s.ammo != 0): return ERR_INVALID_DATA
	var r: Dictionary = value.raid
	if not r.is_empty():
		if not r.has_all(["id","faction","planet","phase","arrival","hull","at","aim","fire_at","ready","bombard","battery_ready"]): return ERR_INVALID_DATA
		if not r.faction is String or not value.nations.has(r.faction) or not value.nations[r.faction].war or not r.planet is String or not value.sites.has(r.planet): return ERR_INVALID_DATA
		if r.id != value.serial or r.id < 1 or not history.state.keys.has("raid:"+str(r.id)) or history.state.keys.has("raid_end:"+str(r.id)): return ERR_INVALID_DATA
		if r.phase not in ["inbound","attacking"] or not C.number(r.hull,0.01,data.factions[r.faction].hull): return ERR_INVALID_DATA
		if not C.vector_valid(r.at) or not C.vector_valid(r.aim) or C.position(r.at).distance_to(HOME) > 15.01: return ERR_INVALID_DATA
		for key: String in ["arrival","fire_at","ready","bombard","battery_ready"]:
			if not C.number(r[key],0,now+90,true): return ERR_INVALID_DATA
		if (r.phase == "inbound") != (r.arrival > now) or value.sites[r.planet].integrity == 0: return ERR_INVALID_DATA
	state = value.duplicate(true); return OK
