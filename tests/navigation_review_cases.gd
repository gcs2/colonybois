extends RefCounted
## Isolated campaign fixtures for review; no saves or production scene changes.
const Session = preload("res://scripts/expedition_session.gd")

static func make(kind: String) -> Dictionary:
	var game:=Session.new()
	game.field.change_flight_mode("orbit")
	game.field.state.energy=92.0
	game.sector.system_by_id("s1").charted=true
	var target: String="s1p0"
	match kind:
		"denied": game.field.state.energy=5.0
		"embargo":
			game.sector.system_by_id("s1").owner="consortium"
			game.sector.faction_by_id("consortium").embargo=true
		"survey": game.field.state.survey_active=true
		"atmosphere": game.field.change_flight_mode("surface")
		"defense": game.field.state.position=[Session.Field.WRECK_POSITION.x,Session.Field.WRECK_POSITION.y,Session.Field.WRECK_POSITION.z]
		"unknown": game.sector.system_by_id("s1").charted=false
		"system":
			assert(game.begin_travel(target).is_empty())
			while game.traveling(): game.tick()
			target="s1p1"
	var offer: Dictionary=game.quote(target)
	# Commit the same isolated setup, without inventing a quote result.
	# Snapshot restore is intentionally avoided here: inspect the actual fixture command.
	var before: float=game.field.state.energy
	var commit_reason: String=""
	if kind not in ["known","unknown","intermediate"]:
		commit_reason=game.begin_travel(target)
		if kind=="arrival" and commit_reason.is_empty():
			while game.traveling(): game.tick()
		if kind=="transit" and commit_reason.is_empty(): game.tick()
	var after: float=game.field.state.energy
	if kind in ["denied","embargo","survey","atmosphere"]:
		assert(not commit_reason.is_empty() and commit_reason==str(offer.reason))
	if kind=="defense": assert(str(offer.reason).is_empty() and commit_reason=="Leave the defense field before jumping.")
	if not commit_reason.is_empty(): assert(before==after)
	elif kind in ["selected","system","transit","arrival"]: assert(is_equal_approx(after,before-float(offer.energy)))
	var planets: Array[String]=[]
	if kind!="unknown":
		for id: String in game.sector.system_by_id("s1").planets:
			planets.append(Session.Geography.definition(Session.local_id(id)).name)
	return {"target":target,"name":Session.Geography.definition(target).name,"planets":planets,"quote":offer,"before":before,"after":after,"commit_reason":commit_reason,"mismatch":str(offer.reason)!=commit_reason,"remaining":game.sector.state.flagship.remaining,"distance":offer.distance,"range":offer.range}
