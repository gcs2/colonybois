extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
var checks: int=0
var failures: int=0
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; printerr("FAIL: "+message)
func place(game: RefCounted, offset: Vector3) -> void:
	var p: Vector3=Session.Field.WRECK_POSITION+offset
	game.field.state.position=[p.x,p.y,p.z]
func fresh() -> RefCounted:
	var game:=Session.new()
	game.field.change_flight_mode("orbit")
	return game
func _initialize() -> void:
	var radius: float=Session.Field.HAZARD_WARNING
	for offset: Vector3 in [Vector3.ZERO,Vector3(radius-0.01,0,0),Vector3(0,radius-0.01,0)]:
		var game:=fresh(); place(game,offset)
		var before: Dictionary=game.snapshot().duplicate(true)
		var quote: Dictionary=game.quote("s1p0")
		check(quote.reason=="Leave the defense field before jumping.","Preview identifies defense field")
		check(game.snapshot()==before,"Preview has no campaign side effects")
		check(game.begin_travel("s1p0")==quote.reason,"Commit and preview agree inside field")
		check(game.snapshot()==before,"Refusal preserves complete campaign snapshot")
	for offset: Vector3 in [Vector3(radius,0,0),Vector3(radius+0.01,0,0),Vector3(0,radius+0.01,0)]:
		var game:=fresh(); place(game,offset)
		var quote: Dictionary=game.quote("s1p0")
		check(quote.reason.is_empty(),"Boundary/outside preview allows travel")
		check(game.begin_travel("s1p0").is_empty(),"Boundary/outside command allows travel")
		check(game.field.state.energy==100-quote.energy,"Allowed departure pays quoted cost once")
	var entered:=fresh()
	check(entered.quote("s1p0").reason.is_empty(),"Initial safe quote")
	place(entered,Vector3.ZERO)
	check(not entered.begin_travel("s1p0").is_empty() and entered.field.state.energy==100,"Commit revalidates after movement into field")
	var escaped:=fresh(); place(escaped,Vector3.ZERO)
	check(not escaped.quote("s1p0").reason.is_empty(),"Initial unsafe quote")
	place(escaped,Vector3(radius+1,0,0))
	check(escaped.begin_travel("s1p0").is_empty(),"Escape clears refusal without cached denial")
	var other:=fresh()
	other.begin_travel("s1p0")
	while other.traveling(): other.tick()
	place(other,Vector3.ZERO)
	check(other.quote("s1p1").reason.is_empty(),"Morrow field coordinates do not restrict another world")
	var empty:=fresh(); place(empty,Vector3.ZERO); empty.field.state.energy=0
	check(empty.quote("s1p0").reason.begins_with("Need 8 energy"),"Existing resource refusal precedence preserved")
	print("Travel preview checks: %d; failures: %d" % [checks,failures])
	quit(0 if failures==0 else 1)
