extends SceneTree
## Actual UI baseline, isolated synthetic inventories; no purchases or player saves.
const Session = preload("res://scripts/expedition_session.gd")
const OUTPUT = "res://artifacts/cargo-review"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var evidence: Array = []
	for fixture: String in ["empty", "freight", "kit", "specimens", "surface"]:
		var view := SubViewport.new()
		view.size_2d_override = Vector2i(1600, 900)
		view.size_2d_override_stretch = true
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var game := Session.new()
		if fixture != "empty":
			game.field.state.energy = 40
			game.field.state.energy_packs = 2
			game.field.state.repair_packs = {"repair_pack": 1, "mega_repair_pack": 1}
			game.commerce.add_cargo("alloy", 2, "morrow")
			game.commerce.add_cargo("water", 1, "s1p0")
			game.commerce.add_cargo("glass", 1, "s2p0")
			game.biosphere.state.cargo = {"moss_lantern": 3, "pocket_manta": 2, "veil_maw": 1}
			game.field.state.produce = 5
		if fixture == "kit": game.colonies.state.kit_source = "morrow"
		assert(game.commerce.used_space(game) <= game.commerce.capacity())
		var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
		scene.campaign = game
		view.add_child(scene)
		scene.set_process(false)
		scene.set_physics_process(false)
		scene.audio.muted = true
		scene._update_camera(1)
		scene._refresh_ui()
		var before: Dictionary = game.snapshot().duplicate(true)
		if fixture == "freight":
			for group: String in ["Main tools", "Inventory"]:
				scene.hud.palette_expanded = true
				scene.hud.show_group(group)
				scene._refresh_ui()
				view.size = Vector2i(1920, 1080)
				for frame: int in range(8): await process_frame
				await RenderingServer.frame_post_draw
				var flight_path: String = OUTPUT + "/current-flight-%s-1080.png" % ("tools" if group == "Main tools" else "inventory")
				assert(view.get_texture().get_image().save_png(flight_path) == OK)
				evidence.append({"fixture": fixture, "view": group, "size": [1920, 1080], "image": flight_path,
					"freight_used": game.commerce.used_space(game), "freight_capacity": game.commerce.capacity(),
					"specimens": game.biosphere.used(), "surface_produce": game.field.state.produce})
		for dimensions: Vector2i in [Vector2i(1920,1080), Vector2i(2560,1440)]:
			view.size = dimensions
			scene._cargo_tab(fixture if fixture in ["specimens", "surface"] else "ship")
			for frame: int in range(8): await process_frame
			await RenderingServer.frame_post_draw
			var path: String = OUTPUT + "/current-%s-%d.png" % [fixture, dimensions.y]
			assert(view.get_texture().get_image().save_png(path) == OK)
			evidence.append({"fixture": fixture, "size": [dimensions.x, dimensions.y], "image": path,
				"freight_used": game.commerce.used_space(game), "freight_capacity": game.commerce.capacity(),
				"specimens": game.biosphere.used(), "surface_produce": game.field.state.produce})
		assert(before == game.snapshot(), "Browsing cargo must not mutate campaign state")
		scene.free()
		view.free()
	var file := FileAccess.open(OUTPUT + "/current-evidence.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"kind": "actual UI; synthetic isolated state; no native-input or audio evidence", "captures": evidence}, "\t"))
	print("Cargo baseline: 12 captures; five campaign immutability checks passed.")
	quit()
