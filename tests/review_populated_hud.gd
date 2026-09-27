extends SceneTree
## Actual encounter renderer with cargo and supplies earned through campaign APIs.
## Isolated review state only; never loads or writes a player save.
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const OUTPUT := "res://artifacts/populated-hud-review"

func _initialize() -> void:
	call_deferred("run")

func require(ok: bool, explanation: String) -> void:
	if not ok:
		push_error(explanation)
		quit(1)
		assert(ok, explanation)

func travel(game: RefCounted, planet: String) -> void:
	if game.field.state.flight_mode != "orbit":
		game.field.change_flight_mode("orbit")
	var error: String = game.begin_travel(planet)
	require(error.is_empty(), "Campaign travel to %s: %s" % [planet,error])
	for tick: int in range(60):
		if not game.traveling(): break
		game.tick()
	require(not game.traveling() and game.field.state.planet_id == planet, "Arrived at %s through campaign travel" % planet)

func earn_and_populate(game: RefCounted) -> Dictionary:
	var commerce: RefCounted = game.commerce
	var home_dock: Vector3 = Field.service_position("basin_port")
	require(game.field.marks == 0.0, "Campaign starts with its real zero-Mark treasury")
	require(commerce.export_alloy(game,"basin_port",home_dock,8).is_empty(), "Load eight Alloy from Morrow reserve")
	require(commerce.quantity("alloy") == 8, "Exported Alloy is held in ship cargo")
	travel(game,"s2p0")
	var trade_dock: Vector3 = Field.service_position("orbit_tender")
	require(commerce.transact(game,"orbit_tender",trade_dock,"alloy",8,false).is_empty(), "Sell eight Morrow Alloy at S2")
	require(is_equal_approx(game.field.marks,192.0), "Eight Alloy sale earns 192 Marks")
	require(commerce.quantity() == 0, "Sold Alloy leaves the hold")
	# The earned balance pays real local service prices; no account, badge, stock,
	# inventory or campaign field is assigned to manufacture a review state.
	var energy_error: String = game.purchase_service("orbit_tender",trade_dock,"pack")
	require(energy_error.is_empty(), "Buy an energy pack from S2 tender: %s" % energy_error)
	var repair_error: String = game.purchase_service("orbit_tender",trade_dock,"repair_pack")
	require(repair_error.is_empty(), "Buy a repair pack from S2 tender: %s" % repair_error)
	var purchased_good := ""
	for good: String in commerce.catalog.goods:
		if commerce.market("s2p0")[good].stock <= 0: continue
		if commerce.transact(game,"orbit_tender",trade_dock,good,1,true).is_empty():
			purchased_good = good
			break
	require(not purchased_good.is_empty(), "Buy at least one affordable freight unit from S2")
	var earned_balance: float = game.field.marks
	travel(game,"morrow")
	require(game.field.marks == earned_balance and commerce.quantity() == 1, "Return to Morrow with bought freight and remaining earned Marks")
	game.field.change_flight_mode("surface")
	return {
		"acquisition": "New campaign; export_alloy(basin_port, 8) at Morrow; begin_travel/tick to s2p0; transact(sell 8 Alloy) for 192 Marks; purchase_service(pack); purchase_service(repair_pack); transact(buy 1 %s); return by campaign travel; land at Morrow." % purchased_good,
		"earned_sale_marks": 192,
		"remaining_marks": int(game.field.marks),
		"purchased_cargo": purchased_good,
		"cargo_quantity": commerce.quantity(),
		"cargo_capacity": commerce.capacity(),
		"energy_packs": game.field.state.energy_packs,
		"repair_packs": game.field.repair_pack_count(),
		"planet": game.field.state.planet_id,
		"flight_mode": game.field.state.flight_mode,
		"explorer_badge": int(commerce.state.badges.explorer),
		"merchant_badge": int(commerce.state.badges.merchant)
	}

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	print("Populated HUD: creating fresh campaign")
	var game := Session.new()
	var evidence: Dictionary = earn_and_populate(game)
	print("Populated HUD: campaign acquisition complete · %d Marks · cargo %d/%d · energy packs %d · repair packs %d" % [evidence.remaining_marks,evidence.cargo_quantity,evidence.cargo_capacity,evidence.energy_packs,evidence.repair_packs])
	var records: Array[Dictionary] = []
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		var view := SubViewport.new()
		view.size = resolution
		view.size_2d_override = Vector2i(1600,900)
		view.size_2d_override_stretch = true
		view.own_world_3d = true
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		print("Populated HUD: creating encounter for %dx%d" % [resolution.x,resolution.y])
		var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
		scene.campaign = game
		view.add_child(scene)
		await process_frame
		print("Populated HUD: %dx%d encounter scene ready" % [resolution.x,resolution.y])
		scene.set_process(false)
		scene.set_physics_process(false)
		scene.audio.muted = true
		scene.audio.set_volume("voice",0)
		scene._apply_flight_mode()
		scene._restore_ship()
		scene._update_visuals()
		scene._update_camera(1.0)
		scene._dismiss_first_landing_welcome()
		scene._refresh_ui()
		# Keep the production notification plaque visible for a mock comparison.
		# This seeds display state only; it does not claim to exercise a discovery trigger.
		scene._toast("Relay discovered")
		for frame: int in range(3): await process_frame
		var flight_image: String = "%s/populated-flight-%d.png" % [OUTPUT,resolution.x]
		print("Populated HUD: capturing flight view %s" % flight_image)
		view.get_texture().get_image().save_png(flight_image)
		# Route the real Inventory / I shortcut through the encounter's production
		# input handler instead of forcing the popup state directly.
		var inventory_key := InputEventKey.new()
		inventory_key.pressed = true
		inventory_key.keycode = KEY_I
		inventory_key.physical_keycode = KEY_I
		scene._unhandled_input(inventory_key)
		for frame: int in range(3): await process_frame
		require(scene.popup.visible and scene.popup_kind == "cargo" and scene.cargo_location == "ship", "HUD Inventory action opens the onboard cargo drawer")
		var inventory_image: String = "%s/populated-inventory-%d.png" % [OUTPUT,resolution.x]
		print("Populated HUD: capturing onboard Inventory %s" % inventory_image)
		view.get_texture().get_image().save_png(inventory_image)
		var record: Dictionary = evidence.duplicate(true)
		record.merge({
			"resolution": [resolution.x,resolution.y],
			"flight_image": flight_image,
			"inventory_image": inventory_image,
			"inventory_action": "InputEventKey I routed through production encounter input handler",
			"popup_kind": scene.popup_kind,
			"inventory_location": scene.cargo_location,
			"rendered_scene": "scenes/encounter.tscn"
		},true)
		records.append(record)
		scene.free()
		view.free()
	var manifest := FileAccess.open(OUTPUT+"/evidence.json",FileAccess.WRITE)
	manifest.store_string(JSON.stringify({
		"kind": "isolated campaign-earned actual encounter HUD render; notification plaque populated with a display-only fixture; not player save, native input, or visual acceptance",
		"records": records
	},"\t"))
	print("Populated HUD review: two resolutions; campaign path assertions passed.")
	quit()
