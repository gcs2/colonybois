extends SceneTree

const Campaign = preload("res://scripts/expedition_session.gd")
const Encounter = preload("res://scenes/encounter.tscn")
const Geography = preload("res://scripts/planet_geography.gd")
const SurfaceWindow = preload("res://scripts/planet_surface_window.gd")
const Equipment = preload("res://scripts/equipment_catalog.gd")
const Field = preload("res://scripts/encounter_state.gd")

var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: "+message)

func run() -> void:
	var scene: Node3D = Encounter.instantiate()
	scene.campaign = Campaign.new()
	root.add_child(scene)
	await process_frame
	scene.save_path = "user://region_resource_loop_test.json"
	scene.set_process(false)
	scene.set_physics_process(false)
	var opportunity: Dictionary = SurfaceWindow.prospecting_opportunity(Geography.definition("morrow"))
	var repeated: Dictionary = SurfaceWindow.prospecting_opportunity(Geography.definition("morrow").duplicate(true))
	check(opportunity == repeated and not str(opportunity.id).is_empty(), "The prospect ID and fixed position reproduce from the saved recipe")
	var basin_region: String = Geography.surface_runtime(Geography.definition("morrow")).region_id(Geography.site_direction("morrow"))
	check(str(opportunity.region_id) != basin_region and Vector2(opportunity.position_m.x,opportunity.position_m.y).length() < Geography.SURFACE_TRAVEL_RADIUS_M, "The single prospect is in a reachable seeded region adjacent to Morrow Basin")
	scene._update_visuals()
	check(not scene.targets.prospect.visible, "The prospect is concealed until the ship enters its region")
	var seam_position: Vector3 = scene.targets.vein.position
	scene._set_surface_up(opportunity.up)
	scene.ship.position = scene.targets.prospect.position+Vector3.UP*4.0
	scene._refresh_surface_geography()
	scene._update_visuals()
	check(scene.targets.prospect.visible and scene.surface_window_region_id == opportunity.region_id, "Crossing reveals the prospect as the seeded region recenters")
	check(scene.targets.vein.position == seam_position, "The existing authored seam stays at its original position")
	var prospect_position: Vector3 = scene.targets.prospect.position
	scene._set_surface_up(Geography.site_direction("morrow"))
	scene._refresh_surface_geography()
	scene._set_surface_up(opportunity.up)
	scene._refresh_surface_geography()
	scene._update_visuals()
	check(scene.targets.prospect.position == prospect_position and scene.prospect_feature.id == repeated.id and scene.targets.prospect.visible, "Leaving and recentering preserves the prospect ID, position and reveal")
	scene.selected = "prospect"
	scene._select_tool("scan")
	scene.held = true
	scene._operate(Equipment.seconds("scan")+0.1)
	check("prospect" in scene.model.state.scanned and scene.model.state.history.any(func(entry: Dictionary) -> bool: return entry.id == "scan_prospect"), "The existing scanner identifies the regional prospect in the field record")
	var gap: float = scene.ship.position.distance_to(scene._target_position("prospect"))
	var energy_before: float = scene.model.state.energy
	check(not scene.campaign.mining_reason(Equipment.reach("mine")+1,str(opportunity.id)).is_empty() and scene.model.state.energy == energy_before and scene.campaign.commerce.quantity("glass") == 0, "Out-of-range extraction is rejected without spending energy or cargo")
	for _slot: int in range(scene.campaign.commerce.capacity()): scene.campaign.commerce.add_cargo("glass",1,"morrow")
	check(not scene.campaign.mining_reason(gap,str(opportunity.id)).is_empty() and scene.model.state.energy == energy_before, "Full cargo rejects extraction before spending energy")
	scene.campaign.commerce.state.cargo.clear()
	scene._select_tool("mine")
	scene.held = true
	scene._operate(Equipment.seconds("mine")+0.1)
	check(scene.status.text.begins_with("Glass +1 · cargo "), "Mining reports the actual glass cargo load")
	check(scene.campaign.commerce.quantity("glass") == 1 and is_equal_approx(scene.model.state.energy,energy_before-Equipment.energy("mine")), "The cutter yields one existing cargo unit and spends its configured energy")
	check(scene.model.state.surface_changes.get(str(opportunity.id),{}) == {"removed":true}, "Extraction records one stable sparse depletion delta")
	check(scene.campaign.diplomacy.state.events.back().kind == "discovery" and scene.campaign.diplomacy.state.events.back().outcome.feature_id == opportunity.id, "Campaign history records the stable prospect result")
	var energy_after: float = scene.model.state.energy
	check(not scene._tool_reason("mine","prospect",gap).is_empty() and is_equal_approx(scene.model.state.energy,energy_after), "A depleted prospect cannot be extracted or spend more energy")
	var invalid: Dictionary = scene.model.snapshot()
	invalid.surface_changes[opportunity.id] = {"removed":false}
	check(Field.new().restore_snapshot(invalid) == ERR_INVALID_DATA, "Save validation rejects malformed prospect depletion")
	var saved_position: Vector3 = scene.ship.position
	var saved_up: Vector3 = scene._saved_surface_up()
	scene._change_flight_mode("orbit")
	scene._save()
	scene.model.state.surface_changes.clear()
	scene.campaign.commerce.state.cargo.clear()
	scene._load()
	check(scene.model.state.flight_mode == "orbit" and scene.model.state.surface_changes.get(str(opportunity.id),{}) == {"removed":true} and scene.campaign.commerce.quantity("glass") == 1, "Orbit save and reload restore both depletion and cargo")
	scene._change_flight_mode("surface")
	scene._update_visuals()
	check(scene.ship.position.distance_to(saved_position) < 0.05 and scene._saved_surface_up().distance_to(saved_up) < 0.00001 and scene.targets.prospect.visible and not scene.prospect_shard.visible, "Returning restores the same planet-fixed site and depleted presentation")
	var campaign_paths: Array[String] = [scene._campaign_path(false),scene._campaign_path(true)]
	scene.free()
	for path: String in campaign_paths:
		var absolute_path: String = ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path): DirAccess.remove_absolute(absolute_path)
		if FileAccess.file_exists(absolute_path+".tmp"): DirAccess.remove_absolute(absolute_path+".tmp")
	print("Region resource loop checks: assertions=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
