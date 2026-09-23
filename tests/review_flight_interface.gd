extends SceneTree
## Reproducible rendered review; isolated --script state, never the player's save.
func _initialize() -> void: call_deferred("run")

func resume_review(scene: Node) -> void:
	# Focus-loss pause can arrive while the scripted render window is in background.
	# Restore the arranged review state; this does not change production focus behavior.
	scene.paused = false
	scene._refresh_ui()

func capture(scene: Node, name: String) -> void:
	resume_review(scene)
	scene._update_visuals()
	# Allow the renderer to settle; scripted transitions update their paused camera explicitly.
	for frame: int in range(30): await process_frame
	resume_review(scene)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/flight_ui_"+name+".png")

func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.audio.muted = true
	scene.audio.set_volume("voice",0)
	scene.model.act("scan","pod",4)
	scene.model.act("collect","pod",4)
	scene._refresh_ui()
	await capture(scene,"hud")
	scene.hud.category_buttons.Environment.pressed.emit()
	await capture(scene,"palette")
	scene._select_tool("warm")
	scene.model.state.scanned.append("bed")
	scene.model.state.energy = 10
	scene.selected = "bed"
	await capture(scene,"shortage")
	scene.model.state.energy = 100
	scene._select_tool("scan")
	scene.selected = "relay"
	scene._activate_selected()
	await capture(scene,"approach")
	scene._stop()
	scene.model.state.energy_packs = 1
	scene.model.state.energy = 30
	scene._show_popup("cargo")
	await capture(scene,"cargo")
	scene._show_popup("systems")
	scene._inspect_system("warm")
	await capture(scene,"systems")
	root.size = Vector2i(1280,720)
	await capture(scene,"systems_720")
	scene._toggle_planet_map()
	await capture(scene,"atlas_uncharted")
	scene.planet_map.hide()
	scene._change_flight_mode("orbit")
	scene._update_camera(1)
	await capture(scene,"orbit_hud")
	resume_review(scene)
	scene._select_weapon()
	assert(scene.weapon_selected)
	await capture(scene,"weapon_palette_720")
	resume_review(scene)
	scene.hud.category_buttons.Inventory.pressed.emit()
	assert(scene.hud.active_group == "Inventory")
	await capture(scene,"quick_inventory_720")
	resume_review(scene)
	scene.hud.collapse_button.pressed.emit()
	assert(not scene.hud.palette_expanded)
	await capture(scene,"collapsed_palette_720")
	scene.model.start_survey()
	for i: int in range(12): scene.model.tick()
	scene._toggle_planet_map()
	await capture(scene,"atlas_charted")
	scene.planet_map.set_layer(true)
	await capture(scene,"atlas_coverage")
	scene.planet_map.hide()
	scene._escape_menu()
	await capture(scene,"escape_menu_720")
	scene.free()
	quit()
