extends SceneTree
## Deterministic review fixtures using actual flight scenes and encounter commands.
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Signals = preload("res://scripts/space_signals.gd")
func _initialize() -> void: call_deferred("run")
func capture(scene: Node3D, name: String) -> void:
	scene._update_visuals(); scene._refresh_ui(); scene._update_camera(1)
	await process_frame; await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/signal-"+name+"-"+str(root.size.x)+".png")
func run() -> void:
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		root.size = resolution
		for id: String in ["convoy","registry"]:
			var game := Session.new(); game.field.state = Field.fresh(Signals.catalog[id].planet)
			game.field.bind_account(game.sector.state); game.configure_flagship(); game.climate.bind(game)
			game.field.change_flight_mode("orbit"); game.field.state.survey_ticks = 12
			game.sector.system_by_id(game.system_of(game.field.state.planet_id)).visited = true
			game.field.marks = 240; game.tick()
			var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
			scene.campaign = game; scene.save_path = "res://artifacts/signal-review.json"
			root.add_child(scene); scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
			scene.signal_view.selected = id; scene.signal_view.refresh(0.4,false)
			await capture(scene,id+"-orbit")
			scene._show_popup("signals"); await capture(scene,id+"-offer")
			if id == "registry":
				scene._close_popup(); scene.ship.position = Signals.position(id)+Vector3(0,3,-7)
				game.field.state.position = [scene.ship.position.x,scene.ship.position.y,scene.ship.position.z]
				game.signals.act(game,id,"inspect",scene.ship.position)
				for i: int in range(3): game.tick()
				scene.signal_view.refresh(0.1,false); await capture(scene,"registry-scan")
				for i: int in range(3): game.tick()
				scene._show_popup("signals"); await capture(scene,"registry-decision")
				game.signals.act(game,id,"publish",scene.ship.position)
				scene._show_popup("badges"); await capture(scene,"captain-badge")
			scene.free()
	print("Signal review fixtures captured at 1080p and 1440p; not native playtest approval.")
	quit()
