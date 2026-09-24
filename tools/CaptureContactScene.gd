extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const OUT = "res://artifacts/diplomacy-review"

func _initialize() -> void: call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	for resolution: Vector2i in [Vector2i(1920, 1080), Vector2i(2560, 1440)]:
		root.size = resolution
		var game := Session.new()
		game.field.state = Field.fresh("s7p0")
		game.field.bind_account(game.sector.state)
		game.configure_flagship()
		game.field.change_flight_mode("orbit")
		game.field.marks = 1240
		game.diplomacy.contact(game, "consortium")
		var faction: Dictionary = game.sector.faction_by_id("consortium")
		faction.relation = 25
		faction.embargo = false
		
		var view := SubViewport.new()
		view.size = resolution
		view.size_2d_override = Vector2i(1600, 900)
		view.size_2d_override_stretch = true
		view.own_world_3d = true
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		
		var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
		scene.campaign = game
		scene.process_mode = Node.PROCESS_MODE_DISABLED
		view.add_child(scene)
		scene.audio.muted = true
		scene.save_path = OUT + "/isolated-save.json"
		scene.ship.position = Field.service_position("orbit_tender")
		scene._contact_select("consortium")
		scene.contact_page = "home"
		scene._show_popup("contact")
		scene._update_camera(1)
		scene._refresh_ui()
		
		for frame: int in range(5):
			await process_frame
		await RenderingServer.frame_post_draw
		
		var img: Image = view.get_texture().get_image()
		var path: String = OUT + "/actual-first-%d.png" % resolution.y
		var err := img.save_png(path)
		assert(err == OK, "Failed to save screenshot")
		print("Saved capture: " + path)
		view.free()
	print("Contact scene captures complete.")
	quit()