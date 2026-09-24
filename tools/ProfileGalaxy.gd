extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
func _initialize() -> void:
	var start: int = Time.get_ticks_usec()
	var game := Session.new()
	print("Galaxy creation ms: ",(Time.get_ticks_usec()-start)/1000.0)
	# Three actual starting colonies; this does not stand in for a dense-city benchmark.
	game.sector._create_colony("s1p0"); game.sector._create_colony("s2p0")
	var samples: Array[float] = []
	for i: int in range(180):
		start = Time.get_ticks_usec(); game.tick()
		samples.append((Time.get_ticks_usec()-start)/1000.0)
	samples.sort()
	print("2048 stars / 3 starting colonies; simulation tick median ms: ",samples[90],"; p95 ms: ",samples[171],"; max ms: ",samples.back())
	start = Time.get_ticks_usec()
	var saved: Dictionary = game.snapshot()
	var loaded := Session.new()
	var error: Error = loaded.restore_snapshot(saved)
	print("Snapshot and restore ms: ",(Time.get_ticks_usec()-start)/1000.0,"; error: ",error,"; payload bytes: ",var_to_bytes(saved).size(),"; static bytes: ",OS.get_static_memory_usage())
	quit(0 if error == OK else 1)
