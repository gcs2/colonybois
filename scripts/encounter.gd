extends Node3D
## Bounded field encounter. Detailed presentation is independent of the saved model.
signal leave
var suspended_session: Node = null
const Model = preload("res://scripts/encounter_state.gd")
const SectorChart = preload("res://scripts/sector_chart.gd")
var sector_map: PanelContainer
var system_map: PanelContainer
var recognition_notice: PanelContainer
var support_visual: Node3D
var territory_panel: RefCounted
var conflict_view: Node3D
var signal_view: Node3D
var recognition_button: Button
var upgrade_preview: String = ""
var rendered_planet: String = "morrow"
var world_definition: Dictionary = Geography.definition()
var changing_planet: bool = false
const Campaign = preload("res://scripts/expedition_session.gd")
var campaign: RefCounted = null
var dock_page: String = "market"
var commodity_preview: String = "alloy"
var upgrade_family: String = "ship"
var trade_amount: int = 1
const AlienPortrait = preload("res://scripts/alien_portrait.gd")
var contacted_faction: String = ""
var contact_page: String = "home"
var contact_reply: String = ""
var contact_greeting: String = ""
var contact_portrait: AlienPortrait = null
var contact_accepted: bool = true
var chronicle_filter: String = "all"
var chronicle_page: int = 0
const OutpostVisual = preload("res://scripts/outpost_visual.gd")
var kit_mode: bool = false
var enemy_flash: float = 0.0
var deploy_order: bool = false
var deployment_site := Vector2.ZERO
var outpost_visual: Node3D
var outpost_signature: String = ""
var selected_colony: String = ""
var kit_marker: MeshInstance3D
var persistence_blocked: bool = false
const Sound = preload("res://scripts/flight_audio.gd")
const FlightControls = preload("res://scripts/flight_controls.gd")
const FlightInputSettings = preload("res://scripts/flight_input_settings.gd")
const OrbitalScene = preload("res://scripts/orbital_scene.gd")
const GrazerMotion = preload("res://scripts/grazer_motion.gd")
const Instruments = preload("res://scripts/flight_interface.gd")
const TOAST_SIGNAL_ICON = preload("res://assets/ui/flight/signal.svg")
const PlanetMap = preload("res://scripts/planet_map.gd")
const Geography = preload("res://scripts/planet_geography.gd")
const SurfaceCoordinates = preload("res://scripts/planet_surface_coordinates.gd")
const SurfaceRuntime = preload("res://scripts/planet_surface_runtime.gd")
const FlightHUD = preload("res://scripts/flight_hud.gd")
const FlightEffects = preload("res://scripts/flight_effects.gd")
const SurfaceCombat = preload("res://scripts/surface_combat.gd")
const SurfaceVisual = preload("res://scripts/surface_combat_visual.gd")
const FleetVisual = preload("res://scripts/allied_fleet_visual.gd")
const Climate = preload("res://scripts/planet_climate.gd")
const Biosphere = preload("res://scripts/planet_biosphere.gd")
var climate_tool: String = ""
var climate_chart: Control
var climate_ring: MeshInstance3D
var climate_signature: String = ""
var ground_material: ShaderMaterial
var terrain_mesh_instance: MeshInstance3D
var surface_window_region_id: String = ""
var surface_habitat_region_id: String = ""
var regional_cover_instance: MultiMeshInstance3D
var regional_feature_root: Node3D
var surface_region_features: Dictionary = {}
var biosphere_view: Node3D
var fleet_visual: Node3D
var fleet_strip: HBoxContainer
var fleet_button: Button
var fleet_bars: Dictionary = {}
var surface_combat_visual: Node3D
var surface_weapon: String = ""
var surface_selected: String = ""
var surface_aim := Vector3.ZERO
var surface_order: bool = false
var surface_salvage_order: bool = false
const SURFACE_ZOOM_MIN := 12.0
const SURFACE_ZOOM_MAX := 110.0
const ORBIT_ZOOM_MIN := 18.0
const ORBIT_ZOOM_MAX := 320.0
const SURFACE_VISUAL_RADIUS := 1100.0
const LANDING_VEIL_OPACITY := 0.62
const TITLES := {"pod":"Lantern pods", "grazer":"Bell grazer", "bed":"Cold mineral bed", "relay":"Silent relay", "vein":"Resonant glass seam"}
const Equipment = preload("res://scripts/equipment_catalog.gd")
var TOOLS: Array[String] = Equipment.ids()
var COLORS: Array[Color] = Equipment.colors()
var model := Model.new()
var save_path: String = "user://field_encounter.json"
var ship: Node3D
var scout_motion := preload("res://scripts/scout_motion.gd").new()
var camera := Camera3D.new()
var targets: Dictionary = {}
var grown_plants: Array[Node3D] = []
var wild_plants: Array[Node3D] = []
var grazers: Array[Node3D] = []
var grazer_motion: Array[RefCounted] = []
var mineral_crystals: Array[Node3D] = []
var bed_material: StandardMaterial3D
var relay_light: MeshInstance3D
var relay_motes: Array[MeshInstance3D] = []
var ring: MeshInstance3D
var beam: MeshInstance3D
var beam_material: StandardMaterial3D
var selected: String = "relay"
var tool: String = "scan"
var progress: float = 0.0
var held: bool = false
var latched: bool = false
var elapsed: float = 0.0
var tick_clock: float = 0.0
var yaw: float = 0.0
var pitch: float = 0.36
var distance: float = 32.0
var camera_distance_target: float = 32.0
var zoom_ascent: bool = false
var zoom_descent: bool = false
var landing_waypoints: Array[Vector3] = []
var arrival_fade: float = 0.0
var transition_veil: ColorRect
var transition_caption: Label
var ship_locator: Label
var planet_locator: Label
var effects := FlightEffects.new()
var velocity := Vector3.ZERO
var paused: bool = false
var camera_focus := Vector3.ZERO
var audio := Sound.new()
var stats: Label
var objective: Label
var subject: Label
var explanation: Label
var status: Label
var status_backing: ColorRect
var status_icon: TextureRect
var toast_item_icon: String = ""
var progress_bar: ProgressBar
var toolbar: Array[Button] = []
var labels: Dictionary = {}
var popup: PanelContainer
var communicator_shell: Control
var contact_status_pod: Control
var popup_kind: String = ""
var popup_body: VBoxContainer
var toast_time: float = 0.0
var ui_clock: float = 0.0
var frame_samples: Array[float] = []
var capture_step: int = 0
var capture_clock: float = 0.0
var use_button: Button
var surface_root := Node3D.new()
var orbit: Node3D
var surface_environment: WorldEnvironment
var surface_environment_resource: Environment
var destination := Vector3.ZERO
var navigating: bool = false
var approach_subject: bool = false
var landing: bool = false
var vertical_button: float = 0.0
var altitude_order: float = -1.0
var location_label: Label
var flight_readout: Label
var energy_bar: ProgressBar
var departure_button: Button
var guide_arrow: Label
var navigation_marker: MeshInstance3D
var heard_guides: Dictionary = {}
var guide_caption: Label
var caption_time: float = 0.0
var previewing_audio: bool = false
var cargo_location: String = "ship"
var inspected_system: String = "scan"
var cargo_quantity: Label
var system_energy: ProgressBar
var system_buttons: Dictionary = {}
var planet_map: PanelContainer
var hud: Control
var operation_feedback: String = ""
var operation_feedback_until: float = 0.0
var salvage_order: bool = false
var salvage_progress: float = 0.0
var wreck_label: Label
var shroud_ring: MeshInstance3D
var guardian_label: Label
var orbital_target: String = "wreck"
var attack_order: bool = false
var weapon_flash: float = 0.0
var service_order: String = ""
var service_waypoints: Array[Vector3] = []
var selected_service: String = "basin_port"
var weapon_selected: bool = false
var menu_return: bool = false
var menu_shade: ColorRect
var weapon_beam: MeshInstance3D
var flight_input_settings := FlightInputSettings.new()
var flight_rebind_action: String = ""
var flight_binding_labels: Dictionary = {}
var flight_rebind_buttons: Dictionary = {}
var flight_rebind_status: Label

func _exit_tree() -> void:
	if is_instance_valid(suspended_session) and not suspended_session.is_inside_tree():
		suspended_session.free()

func _ready() -> void:
	if DisplayServer.get_name() != "headless": Engine.max_fps = 60
	if "--playtest" in OS.get_cmdline_user_args() or "--field-capture" in OS.get_cmdline_user_args() or "--flight-capture" in OS.get_cmdline_user_args(): save_path = "user://review_field_encounter.json"
	var testing: bool = "--script" in OS.get_cmdline_args()
	if testing: save_path = "res://artifacts/field_test_session.json"
	var startup_error: Error = OK
	if campaign != null:
		model = campaign.field
	elif not testing:
		campaign = Campaign.new()
		model = campaign.field
		if "--field-capture" not in OS.get_cmdline_user_args() and "--flight-capture" not in OS.get_cmdline_user_args():
			var resume_path: String = Campaign.newest_save(_campaign_path(false),_campaign_path(true))
			if not resume_path.is_empty(): startup_error = campaign.load_from(resume_path)
			else:
				var legacy_path: String = Campaign.newest_save(save_path,save_path.replace(".json","_auto.json"))
				if not legacy_path.is_empty(): startup_error = campaign.import_legacy(legacy_path)
			model = campaign.field
	persistence_blocked = startup_error != OK
	rendered_planet = model.state.planet_id
	world_definition = model.definition()
	flight_input_settings.install()
	add_child(audio)
	_make_world()
	var shield_mesh := TorusMesh.new()
	shield_mesh.inner_radius = 2.1
	shield_mesh.outer_radius = 2.17
	shield_mesh.rings = 48
	shield_mesh.ring_segments = 6
	shroud_ring = MeshInstance3D.new()
	shroud_ring.mesh = shield_mesh
	shroud_ring.material_override = _mat(Color("b898dc"),true)
	shroud_ring.position.y = 0.45
	ship.add_child(shroud_ring)
	# Keep the ship and camera while swapping surface/orbit presentation.
	add_child(surface_root)
	for child: Node in get_children():
		if child is WorldEnvironment:
			surface_environment = child
			surface_environment_resource = child.environment
		elif child is Node3D and child not in [surface_root,ship,camera] and not child is Light3D:
			child.reparent(surface_root)
	orbit = OrbitalScene.new()
	orbit.planet_definition = model.definition()
	add_child(orbit)
	_build_service_ports()
	if campaign != null:
		campaign.climate.bind(campaign)
		territory_panel = preload("res://scripts/territory_panel.gd").new(); territory_panel.setup(self)
		conflict_view = preload("res://scripts/conflict_view.gd").new()
		orbit.add_child(conflict_view); conflict_view.setup(self)
		signal_view = preload("res://scripts/signal_view.gd").new()
		orbit.add_child(signal_view); signal_view.setup(self)
		biosphere_view = preload("res://scripts/biosphere_view.gd").new()
		surface_root.add_child(biosphere_view); biosphere_view.setup(self)
		var pulse_mesh := TorusMesh.new(); pulse_mesh.inner_radius = 19.0; pulse_mesh.outer_radius = 19.16
		pulse_mesh.rings = 64; pulse_mesh.ring_segments = 6
		climate_ring = _mesh(pulse_mesh,orbit.planet.position,_mat(Color("d5dcab"),true),orbit)
		climate_ring.visible = false
		surface_combat_visual = SurfaceVisual.new()
		surface_root.add_child(surface_combat_visual)
		surface_combat_visual.setup(model.state.planet_id)
		fleet_visual = FleetVisual.new(); add_child(fleet_visual)
		fleet_visual.setup(campaign.fleet.catalog)
	var lance_mesh := CylinderMesh.new()
	lance_mesh.top_radius = 0.07
	lance_mesh.bottom_radius = 0.13
	lance_mesh.height = 1
	weapon_beam = _mesh(lance_mesh,Vector3.ZERO,_mat(Color("f3b48a"),true),self)
	weapon_beam.visible = false
	add_child(effects)
	effects.setup(ship)
	support_visual = preload("res://scripts/ship_support_visual.gd").new(); add_child(support_visual)
	var nav_mesh := TorusMesh.new()
	nav_mesh.inner_radius = 0.6
	nav_mesh.outer_radius = 0.72
	navigation_marker = _mesh(nav_mesh,Vector3.ZERO,_mat(Color("b0dee9"),true))
	navigation_marker.visible = false
	_make_ui()
	_restore_ship()
	if campaign != null: campaign.fleet.prepare(campaign,ship.position)
	_apply_flight_mode()
	_update_visuals()
	_update_camera(1.0)
	_refresh_ui()
	if signal_view != null: signal_view.ready_for_orders = true
	get_tree().auto_accept_quit = false
	if campaign != null and campaign.traveling(): _show_travel_view()
	if persistence_blocked:
		paused = true
		_toast("Save could not be restored. Saving disabled to protect your progress: "+error_string(startup_error))

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_cancel_orders(true)
		paused = true
		audio.suspend_voice(true)
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		audio.save_settings()
		_save(false)
		get_tree().quit()

func terrain_height(x: float, z: float) -> float:
	return Geography.surface_height(world_definition,x,z)

func _sync_surface_pose() -> void:
	var up: Vector3 = _saved_surface_up()
	var saved_position: Array = model.state.surface_position
	if Vector2(ship.position.x,ship.position.z).distance_to(Vector2(float(saved_position[0]),float(saved_position[2]))) > 0.5:
		# Explicit scene placement remains a supported way to set a surface pose;
		# ordinary flight keeps position and radial direction synchronized each physics step.
		up = Geography.surface_pose(world_definition,ship.position.x,ship.position.z)
	var offset: Vector2 = Geography.surface_local_position(world_definition, up)
	ship.position.x = offset.x
	ship.position.z = offset.y
	model.state.surface_position = [ship.position.x,ship.position.y,ship.position.z]
	model.state.surface_direction = [up.x,up.y,up.z]

func _saved_surface_up() -> Vector3:
	var direction: Array = model.state.surface_direction
	var up := Vector3(float(direction[0]),float(direction[1]),float(direction[2]))
	return up.normalized() if up.length_squared() > 0.000001 else Geography.site_direction(rendered_planet)

func _set_surface_up(up_value: Vector3) -> void:
	var up: Vector3 = up_value.normalized()
	var offset: Vector2 = Geography.surface_local_position(world_definition, up)
	ship.position.x = offset.x
	ship.position.z = offset.y
	model.state.surface_direction = [up.x,up.y,up.z]
	model.state.surface_position = [ship.position.x,ship.position.y,ship.position.z]

func _terrain_base(x: float, z: float) -> float:
	return Geography.surface_base(world_definition,x,z)

func _distant_landform(x: float, z: float) -> float:
	# Warped, offset ranges layer a stronger silhouette behind the playable basin.
	# This only shapes the distant rendered shell; gameplay terrain queries stay put.
	var recipe_phase: float = float(int(world_definition.get("geography_seed",0))%997)*0.001
	var warp_x: float = sin((x+z)*0.006+recipe_phase)*42.0
	var warp_z: float = cos((x-z)*0.004-recipe_phase*1.7)*54.0
	var ridge: float = sin((x+warp_x)*0.018+cos((z+warp_z)*0.009+recipe_phase)*1.4)
	var shoulder: float = sin((z+warp_z)*0.013+sin((x+warp_x)*0.007-recipe_phase)*1.1)
	var broken_edge: float = cos((x-z)*0.025+sin((x+z)*0.008+recipe_phase))*1.8
	var far_ridge: float = sin((z+warp_z)*0.008+sin((x+warp_x)*0.006+recipe_phase)*1.6)
	var peak: float = pow(maxf(0.0,cos((x+warp_x)*0.011+sin((z+warp_z)*0.007-recipe_phase))),6.0)
	var foothill: float = sin((z+warp_z)*0.022+sin((x+warp_x)*0.01+recipe_phase)*1.4)
	var amplitude: float = 0.8 if world_definition.archetype == "frozen" else 1.0
	if rendered_planet != "morrow":
		var legacy_edge: float = cos((x-z)*0.025+sin((x+z)*0.008))*0.35
		return (3.0+ridge*6.0+shoulder*2.0+legacy_edge)*amplitude
	return (12.0+ridge*16.0+shoulder*8.0+broken_edge*2.0+far_ridge*7.0+peak*3.0+foothill*5.0)*amplitude

func _mat(color: Color, emissive: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	if emissive:
		material.emission_enabled = true
		material.emission = color
	return material

func _mesh(mesh: Mesh, at: Vector3, material: Material, parent: Node3D = self) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = at
	node.material_override = material
	parent.add_child(node)
	return node

func _ship_socket(id: String) -> Vector3:
	var socket: Node3D = ship.find_child(id,true,false)
	return to_local(socket.global_position) if socket != null else ship.position

func _asset(id: String, at: Vector3, size: float = 1.0) -> Node3D:
	var node: Node3D = load("res://assets/encounter/"+id+".glb").instantiate()
	node.position = at
	node.scale = Vector3.ONE*size
	add_child(node)
	return node

func _make_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("5a7187") if world_definition.archetype == "arid" else Color("28425e") if world_definition.archetype == "frozen" else Color("48647a")
	sky_material.sky_horizon_color = Color("8291a2") if world_definition.archetype == "arid" else Color("9ab2c2") if world_definition.archetype == "frozen" else Color("8499a8")
	sky_material.ground_bottom_color = Color("382c30")
	sky_material.ground_horizon_color = Color("a87b5e")
	sky_material.sky_curve = 0.2
	var sky := Sky.new()
	sky.sky_material = sky_material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("bfa28d")
	env.ambient_light_energy = 0.28
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.0
	env.fog_enabled = true
	env.fog_light_color = Color("b99a83")
	env.fog_density = 0.0021
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-34,-44,0)
	sun.light_color = Color("ffeacc")
	sun.light_energy = 0.85
	sun.shadow_enabled = true
	sun.shadow_blur = 1.2
	sun.directional_shadow_max_distance = 180.0
	add_child(sun)
	add_child(camera)
	camera.current = true
	camera.fov = 52
	camera.far = 900
	ground_material = ShaderMaterial.new()
	ground_material.shader = preload("res://assets/shaders/expedition_ground.gdshader")
	ground_material.set_shader_parameter("surface_detail",1.0 if rendered_planet == "morrow" else 0.0)
	ground_material.set_shader_parameter("recipe_seed",float(int(world_definition.get("geography_seed",0))%8192))
	surface_window_region_id = Geography.surface_region_id(world_definition,_saved_surface_up()) if rendered_planet == "morrow" else ""
	surface_habitat_region_id = Geography.surface_runtime(world_definition).habitat_region_id(_saved_surface_up()) if rendered_planet == "morrow" else ""
	surface_region_features = _surface_feature_sets(_saved_surface_up())
	_rebuild_surface_terrain(_saved_surface_up())
	var rng := RandomNumberGenerator.new()
	rng.seed = int(world_definition.geography_seed)
	var rock_meshes: Array[SphereMesh] = []
	var rock_materials: Array[StandardMaterial3D] = []
	var rock_palette: Array[Color] = [Color("52423c"),Color("73604f"),Color("4d6461"),Color("826959"),Color("514e59")]
	for variant: int in range(rock_palette.size()):
		var rock_mesh := SphereMesh.new()
		rock_mesh.radial_segments = 7 if variant == 0 else 5 + (variant % 3) * 2
		rock_mesh.rings = 3 if variant == 0 else 2 + (variant % 3)
		rock_mesh.radius = 1
		rock_mesh.height = 2
		rock_meshes.append(rock_mesh)
		rock_materials.append(_mat(rock_palette[variant]))
	var rock_shapes: Array[Vector3] = [Vector3(0.9,0.72,1.3),Vector3(0.72,1.45,0.88),Vector3(1.32,0.82,0.9),Vector3(0.95,1.18,1.24),Vector3(1.25,1.22,0.76)]
	for i: int in range(65):
		var a: float = rng.randf()*TAU
		var r: float = rng.randf_range(24,47)
		var at := Vector3(cos(a)*r,0,sin(a)*r)
		at.y = terrain_height(at.x,at.z)-0.4
		var rock_size := Vector3(rng.randf_range(0.8,2.4),rng.randf_range(0.9,3.2),rng.randf_range(0.8,2.1))
		var overlaps_defense: bool = false
		if rendered_planet == "morrow":
			for landmark: Vector2 in [Vector2(18,16),Vector2(9,-13),Vector2(8,-4),Vector2(-7,4)]:
				if Vector2(at.x,at.z).distance_to(landmark) < 6.0: overlaps_defense = true
		for id: String in SurfaceCombat.profiles(rendered_planet):
			var site: Vector3 = SurfaceCombat.home(rendered_planet,id)
			if Vector2(at.x,at.z).distance_to(Vector2(site.x,site.z)) < 6: overlaps_defense = true
		if overlaps_defense: continue
		var variant: int = i % rock_meshes.size() if rendered_planet == "morrow" else 0
		var rock: MeshInstance3D = _mesh(rock_meshes[variant],at,rock_materials[variant])
		rock.scale = rock_size*rock_shapes[variant] if rendered_planet == "morrow" else rock_size
		rock.rotation = Vector3(sin(float(i)*1.7)*0.1,a,cos(float(i)*1.3)*0.1) if rendered_planet == "morrow" else Vector3(0,a,0)
	# Morrow water is rendered from the same versioned basin recipe as relief and map sampling.
	if rendered_planet == "morrow":
		_make_morrow_waterbodies()
	else:
		var pool := SphereMesh.new()
		pool.radius = 1
		pool.height = 2
		var water := _mesh(pool,Vector3(-23,-0.6,0),_mat(Color("83b6c2") if world_definition.archetype == "frozen" else Color("368d91")))
		water.scale = Vector3(6.0,0.1,12.0)
		water.visible = world_definition.archetype != "arid"
	_make_ground_cover(rng)
	_make_regional_features()
	for i: int in range(16):
		var a: float = rng.randf()*TAU
		var r: float = rng.randf_range(23,33)
		var x: float = cos(a)*r
		var z: float = sin(a)*r
		_asset("pod",Vector3(x,terrain_height(x,z),z),rng.randf_range(0.22,0.42))
	var pod_at := Vector3(-7,terrain_height(-7,4),4)
	for i: int in range(3):
		var at: Vector3 = pod_at+Vector3(i*2.3-1,0,sin(i*2)*2)
		at.y = terrain_height(at.x,at.z)
		wild_plants.append(_asset("pod",at,0.9 if i == 0 else 0.7))
	targets.pod = wild_plants[0]
	# Additional reed clusters hugging the pond shoreline
	if world_definition.archetype != "arid":
		var shoreline_center := Vector2(-23.0,0.0)
		var shoreline_radii := Vector2(5.8,11.5)
		if rendered_planet == "morrow":
			var water_runtime: Object = Geography.surface_runtime(world_definition)
			var waterbody: Dictionary = water_runtime.generator.waterbody_specs()[0]
			shoreline_center = water_runtime.local_offset(Geography.site_direction(rendered_planet),waterbody.center_up)
			shoreline_radii = Vector2(float(waterbody.east_radius_m),float(waterbody.north_radius_m))*1.19
		for i: int in range(8):
			var angle: float = (i / 8.0) * TAU
			var px: float = shoreline_center.x + cos(angle) * shoreline_radii.x
			var pz: float = shoreline_center.y + sin(angle) * shoreline_radii.y
			var shore_pod := _asset("pod", Vector3(px, terrain_height(px, pz), pz), rng.randf_range(0.35, 0.65))
			shore_pod.rotation.y = rng.randf() * TAU
	for i: int in range(3):
		var at := Vector3(-9+i*3,6+i*0.4,-3-i*1.2)
		var grazer_scale: float = (0.92 if i == 0 else 0.64) if rendered_planet == "morrow" else (0.8 if i == 0 else 0.5)
		grazers.append(_asset("grazer",at,grazer_scale))
		var motion := GrazerMotion.new()
		motion.configure(grazers.back(),i)
		grazer_motion.append(motion)
	targets.grazer = grazers[0]
	var bed := Node3D.new()
	bed.position = Vector3(8,terrain_height(8,-4),-4)
	add_child(bed)
	targets.bed = bed
	var bed_mesh := CylinderMesh.new()
	bed_mesh.top_radius = 4.0
	bed_mesh.bottom_radius = 4.3
	bed_mesh.height = 0.08
	bed_mesh.radial_segments = 40
	bed_material = _mat(Color("7e776f"))
	bed_material.roughness = 0.95
	_mesh(bed_mesh,Vector3(0,-0.05,0),bed_material,bed)
	for i: int in range(7):
		var a: float = i*2.4
		var plant: Node3D = _asset("pod",bed.position+Vector3(cos(a)*2.3,0.2,sin(a)*2.3),0.01)
		grown_plants.append(plant)
	var vein := Node3D.new()
	# The only authored mineral opportunity is deliberately placed in the first
	# adjacent spherical region; the existing scan/cutter/ore save path owns it.
	var vein_position: Vector2 = Vector2(18,16)
	if rendered_planet == "morrow":
		var basin_up: Vector3 = Geography.surface_direction(world_definition,0,12)
		var adjacent_up: Vector3 = Geography.surface_runtime(world_definition).advance(basin_up,620,0)
		vein_position = Geography.surface_local_position(world_definition,adjacent_up)
	vein.position = Vector3(vein_position.x,terrain_height(vein_position.x,vein_position.y),vein_position.y)
	vein.rotation.y = 0.43
	add_child(vein)
	targets.vein = vein
	# Each mineable lode owns its socket and three shards. Oversized rocks at the same coordinates hid depletion when a lode disappeared.
	var crystal := CylinderMesh.new()
	crystal.top_radius = 0.015
	crystal.bottom_radius = 0.17
	crystal.height = 0.62
	crystal.radial_segments = 5
	var socket_mesh := SphereMesh.new()
	socket_mesh.radius = 0.36
	socket_mesh.height = 0.3
	for i: int in range(Model.MINERAL_DEPOSIT_UNITS):
		var lode := Node3D.new()
		lode.position = Vector3(-1.1+i*0.73,0.0,(i%2)*0.56-0.28)
		lode.rotation.y = 0.4+i*0.63
		vein.add_child(lode)
		var socket_material := _mat(Color("514c4d"))
		var socket := _mesh(socket_mesh,Vector3(0,0.04,0),socket_material,lode)
		socket.scale = Vector3(1.0,0.52,0.86)
		var shard_colors: Array[Color] = [Color("64aaa4"),Color("a9bdb0"),Color("53a79b"),Color("8baab5")]
		for shard_index: int in range(3):
			var gem_material := _mat(shard_colors[i] if shard_index == 0 else shard_colors[(i+shard_index+1)%shard_colors.size()],true)
			gem_material.roughness = 0.48
			gem_material.metallic = 0.12
			gem_material.emission_energy_multiplier = 0.62 if shard_index == 0 else 0.36
			var shard := _mesh(crystal,Vector3((shard_index-1)*0.2,0.31+0.05*(shard_index%2),0.04*(shard_index-1)),gem_material,lode)
			shard.rotation = Vector3(0.04*(shard_index-1),0.6*shard_index,0.16*(shard_index-1))
			shard.scale = Vector3(0.84 if shard_index == 0 else 0.58,1.0 if shard_index == 0 else 0.72,0.82)
		mineral_crystals.append(lode)
	var relay: Node3D = _asset("relay",Vector3(9,terrain_height(9,-13),-13))
	targets.relay = relay
	var core := SphereMesh.new()
	core.radius = 0.42
	core.height = 1.1
	relay_light = _mesh(core,relay.position+Vector3(0,2.8,-0.1),_mat(Color("a8ebce"),true))
	relay_light.visible = false
	# Bioluminescent floating motes orbiting the relay
	var mote_mesh := SphereMesh.new()
	mote_mesh.radius = 0.22
	mote_mesh.height = 0.44
	var mote_mat := StandardMaterial3D.new()
	mote_mat.albedo_color = Color("7cf5d4")
	mote_mat.emission_enabled = true
	mote_mat.emission = Color("7cf5d4")
	mote_mat.emission_energy_multiplier = 2.5
	for i: int in range(8):
		var mote := _mesh(mote_mesh, relay.position + Vector3(0, 1.5 + i * 0.4, 0), mote_mat)
		relay_motes.append(mote)
	ship = _asset("scout",Vector3(0,5,17),0.74)
	scout_motion.setup(ship)
	var torus := TorusMesh.new()
	torus.inner_radius = 1.94
	torus.outer_radius = 2.0
	torus.rings = 32
	torus.ring_segments = 8
	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color = Color("f3c567", 0.94)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_mat.emission_enabled = true
	ring_mat.emission = Color("f3c567")
	ring_mat.emission_energy_multiplier = 0.35
	ring = _mesh(torus,Vector3.ZERO,ring_mat)
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.055
	cylinder.bottom_radius = 0.14
	cylinder.height = 1
	beam_material = _mat(COLORS[0],true)
	beam = _mesh(cylinder,Vector3.ZERO,beam_material)
	beam.visible = false

func _make_morrow_waterbodies() -> void:
	var runtime: Object = Geography.surface_runtime(world_definition)
	var anchor: Vector3 = Geography.site_direction(rendered_planet)
	for waterbody: Dictionary in runtime.generator.waterbody_specs():
		var east_radius: float = float(waterbody.get("east_radius_m", 1.0))
		var north_radius: float = float(waterbody.get("north_radius_m", 1.0))
		var center_up: Vector3 = waterbody.center_up
		var center_offset: Vector2 = runtime.local_offset(anchor,center_up)
		var water_level: float = float(waterbody.get("surface_elevation", -0.025))*SurfaceRuntime.PROVISIONAL_HEIGHT_SCALE_M+0.12
		var water_surface := SurfaceTool.new()
		water_surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		var segments: int = 96
		var rings: int = 10
		var water_color := Color("286c70")
		var shore_color := Color("75aaa0")
		for ring_index: int in range(rings):
			var radius_a: float = 1.16*float(ring_index)/float(rings)
			var radius_b: float = 1.16*float(ring_index+1)/float(rings)
			for index: int in range(segments):
				var angle_a: float = TAU*float(index)/float(segments)
				var angle_b: float = TAU*float(index+1)/float(segments)
				var point_aa: Vector3 = _morrow_water_vertex(runtime,anchor,center_up,east_radius,north_radius,radius_a,angle_a,center_offset,water_level)
				var point_ab: Vector3 = _morrow_water_vertex(runtime,anchor,center_up,east_radius,north_radius,radius_a,angle_b,center_offset,water_level)
				var point_ba: Vector3 = _morrow_water_vertex(runtime,anchor,center_up,east_radius,north_radius,radius_b,angle_a,center_offset,water_level)
				var point_bb: Vector3 = _morrow_water_vertex(runtime,anchor,center_up,east_radius,north_radius,radius_b,angle_b,center_offset,water_level)
				var tone_a: Color = water_color.lerp(shore_color,smoothstep(0.70,1.16,radius_a))
				var tone_b: Color = water_color.lerp(shore_color,smoothstep(0.70,1.16,radius_b))
				water_surface.set_color(tone_a); water_surface.add_vertex(point_aa)
				water_surface.set_color(tone_b); water_surface.add_vertex(point_bb)
				water_surface.set_color(tone_b); water_surface.add_vertex(point_ba)
				water_surface.set_color(tone_a); water_surface.add_vertex(point_aa)
				water_surface.set_color(tone_a); water_surface.add_vertex(point_ab)
				water_surface.set_color(tone_b); water_surface.add_vertex(point_bb)
		water_surface.generate_normals()
		var water_shader := Shader.new()
		water_shader.code = "shader_type spatial; varying vec3 wp; void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){float ripple=sin(length(wp.xz)*0.16-TIME*0.36+sin(wp.x*0.12+wp.z*0.14)*0.5); float glint=sin(dot(wp.xz,vec2(0.19,0.11))+TIME*0.22); float sheen=clamp(0.88+ripple*0.07+glint*0.035,0.72,1.0); ALBEDO=COLOR.rgb*sheen; ROUGHNESS=0.32; METALLIC=0.02;}"
		var water_material := ShaderMaterial.new()
		water_material.shader = water_shader
		_mesh(water_surface.commit(),Vector3(center_offset.x,water_level,center_offset.y),water_material)

func _morrow_water_vertex(runtime: Object, anchor: Vector3, center_up: Vector3, east_radius: float, north_radius: float, radial: float, angle: float, center_offset: Vector2, water_level: float) -> Vector3:
	var east: float = cos(angle)*east_radius*radial
	var north: float = sin(angle)*north_radius*radial
	var up: Vector3 = runtime.advance(center_up,east,north)
	var offset: Vector2 = runtime.local_offset(anchor,up)
	return Vector3(offset.x-center_offset.x,0.0,offset.y-center_offset.y)

func _make_ground_cover(rng: RandomNumberGenerator) -> void:
	var morrow_cover: bool = rendered_planet == "morrow"
	var leaf_surface := SurfaceTool.new()
	leaf_surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i: int in range(4):
		var angle: float = i*TAU/4
		for p: Vector3 in [Vector3(-0.13,0,0),Vector3(0,0.85,0.28),Vector3(0.13,0,0)]: leaf_surface.add_vertex(p.rotated(Vector3.UP,angle))
	leaf_surface.generate_normals()
	var shader := Shader.new()
	shader.code = "shader_type spatial; render_mode cull_disabled; void vertex(){VERTEX.x+=sin(TIME*1.2+MODEL_MATRIX[3].x)*VERTEX.y*0.12;} void fragment(){ALBEDO=vec3(0.31,0.36,0.40)+COLOR.rgb*0.16; ROUGHNESS=0.95;}"
	if morrow_cover:
		shader.code = "shader_type spatial; render_mode cull_disabled; void vertex(){VERTEX.x+=sin(TIME*1.2+MODEL_MATRIX[3].x)*VERTEX.y*0.12;} void fragment(){ALBEDO=COLOR.rgb; ROUGHNESS=0.95;}"
	var material := ShaderMaterial.new()
	material.shader = shader
	var batch := MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.use_colors = true
	batch.mesh = leaf_surface.commit()
	var base_instance_count: int = 900 if morrow_cover else (160 if world_definition.archetype == "frozen" else 80 if world_definition.archetype == "arid" else 520)
	var regional_cover: Array = surface_region_features.get("cover",[]) if morrow_cover else []
	batch.instance_count = base_instance_count+regional_cover.size()
	var patch_centers: Array[Vector2] = [Vector2(-13,6),Vector2(-9,-4),Vector2(15,6),Vector2(18,-15),Vector2(-20,-13)]
	var additional_centers: Array[Vector2] = []
	if morrow_cover:
		additional_centers = [Vector2(-35,9),Vector2(34,12),Vector2(37,-15),Vector2(-31,-25),Vector2(20,-32)]
	var additional_rng := RandomNumberGenerator.new()
	var foreground_palette: Array[Color] = [Color("668b67"),Color("83a66f"),Color("6e9c96"),Color("b49a65"),Color("947b9b"),Color("ad8065")]
	for i: int in range(base_instance_count):
		var detail_rng: RandomNumberGenerator = rng
		var center: Vector2
		if morrow_cover and i >= 520:
			if i == 520: additional_rng.state = rng.state
			detail_rng = additional_rng
			center = additional_centers[(i-520)%additional_centers.size()]
		else:
			center = patch_centers[i%patch_centers.size()]
		var at: Vector2 = center+Vector2(detail_rng.randfn(0,3.5),detail_rng.randfn(0,3))
		var size: float = detail_rng.randf_range(0.3,0.95)
		batch.set_instance_transform(i,Transform3D(Basis(Vector3.UP,detail_rng.randf()*TAU).scaled(Vector3.ONE*size),Vector3(at.x,terrain_height(at.x,at.y),at.y)))
		var generated_color := Color(detail_rng.randf(),0.25,detail_rng.randf())
		batch.set_instance_color(i,foreground_palette[i%foreground_palette.size()] if morrow_cover else generated_color)
	var cover_palette: Array[Color] = [Color("829780"),Color("93aa90"),Color("a1ad8d"),Color("71918b"),Color("b4a181"),Color("8b7886")]
	for feature_index: int in range(regional_cover.size()):
		var feature: Dictionary = regional_cover[feature_index]
		var at: Vector2 = feature["position"]
		var index: int = base_instance_count+feature_index
		var size: float = float(feature["size"])*0.7
		batch.set_instance_transform(index,Transform3D(Basis(Vector3.UP,float(feature["rotation"])).scaled(Vector3.ONE*size),Vector3(at.x,terrain_height(at.x,at.y),at.y)))
		batch.set_instance_color(index,cover_palette[int(feature["variant"])%cover_palette.size()])
	var node := MultiMeshInstance3D.new()
	node.multimesh = batch
	node.material_override = material
	if is_instance_valid(regional_cover_instance): regional_cover_instance.queue_free()
	regional_cover_instance = node
	if is_instance_valid(surface_root): surface_root.add_child(node)
	else: add_child(node)

func _surface_feature_sets(center_up: Vector3 = Vector3.ZERO) -> Dictionary:
	var grouped: Dictionary = {"cover":[],"rock":[],"flora":[],"fauna":[]}
	if rendered_planet != "morrow": return grouped
	var anchor: Vector3 = Geography.site_direction("morrow")
	var query_center: Vector3 = center_up.normalized() if center_up.length_squared() > 0.000001 else _saved_surface_up()
	var runtime: Object = Geography.surface_runtime(world_definition)
	var query_position: Vector2 = runtime.local_offset(anchor,query_center)
	var nearfield_radius: float = 192.0
	var window: Dictionary = runtime.window(query_center)
	for feature: Dictionary in window.features:
		var kind: String = str(feature.get("kind", ""))
		if not grouped.has(kind): continue
		if model.state.surface_changes.has(str(feature.id)): continue
		var position: Vector2 = runtime.local_offset(anchor,feature.up)
		if kind in ["rock","flora","fauna"] and position.distance_to(query_position) < nearfield_radius: continue
		grouped[kind].append({"id":feature.id,"region_id":feature.region_id,"kind":kind,"position":position,"variant":feature.variant,"size":feature.size,"rotation":feature.yaw})
	var habitat_window: Dictionary = runtime.habitat_window(query_center)
	for feature: Dictionary in habitat_window.features:
		var kind: String = str(feature.get("kind", ""))
		if kind not in ["rock","flora","fauna"]: continue
		if model.state.surface_changes.has(str(feature.id)): continue
		var position: Vector2 = runtime.local_offset(anchor,feature.up)
		if position.distance_to(query_position) < 8.0: continue
		grouped[kind].append({"id":feature.id,"region_id":feature.region_id,"kind":kind,"position":position,"variant":feature.variant,"size":feature.size,"rotation":feature.yaw})
	return grouped

func _make_regional_features() -> void:
	if is_instance_valid(regional_feature_root): regional_feature_root.queue_free()
	regional_feature_root = Node3D.new()
	if is_instance_valid(surface_root): surface_root.add_child(regional_feature_root)
	else: add_child(regional_feature_root)
	var rocks: Array = surface_region_features.get("rock",[])
	if not rocks.is_empty():
		var mesh := SphereMesh.new()
		mesh.radial_segments = 7
		mesh.rings = 3
		mesh.radius = 1.0
		mesh.height = 2.0
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_colors = true
		multimesh.mesh = mesh
		multimesh.instance_count = rocks.size()
		var colors: Array[Color] = [Color("51433f"),Color("755e50"),Color("5a6966"),Color("86705e"),Color("52515b")]
		for index: int in range(rocks.size()):
			var feature: Dictionary = rocks[index]
			var at: Vector2 = feature["position"]
			var size: float = float(feature["size"])
			var scale := Vector3(size*1.25,size*2.1,size*(0.78+float(int(feature["variant"])%3)*0.12))
			multimesh.set_instance_transform(index,Transform3D(Basis(Vector3.UP,float(feature["rotation"])).scaled(scale),Vector3(at.x,terrain_height(at.x,at.y)-0.45,at.y)))
			multimesh.set_instance_color(index,colors[int(feature["variant"])%colors.size()])
		var rock_material := StandardMaterial3D.new()
		rock_material.vertex_color_use_as_albedo = true
		rock_material.roughness = 0.92
		var rock_batch := MultiMeshInstance3D.new()
		rock_batch.multimesh = multimesh
		rock_batch.material_override = rock_material
		regional_feature_root.add_child(rock_batch)
	var flora: Array = surface_region_features.get("flora",[])
	if not flora.is_empty():
		var flora_colors: Array[Color] = [Color("a8d2a0"),Color("97c5c4"),Color("c4bf8b"),Color("b2a6cb"),Color("72aaa1"),Color("d5ae8b")]
		var flora_material := StandardMaterial3D.new()
		flora_material.vertex_color_use_as_albedo = true
		flora_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		flora_material.roughness = 0.9
		for variant: int in range(flora_colors.size()):
			var shaped: Array = flora.filter(func(item: Dictionary) -> bool: return int(item.variant)%flora_colors.size() == variant)
			if shaped.is_empty(): continue
			var flora_multimesh := MultiMesh.new()
			flora_multimesh.transform_format = MultiMesh.TRANSFORM_3D
			flora_multimesh.use_colors = true
			flora_multimesh.mesh = _flora_shape_mesh(variant)
			flora_multimesh.instance_count = shaped.size()
			for index: int in range(shaped.size()):
				var feature: Dictionary = shaped[index]
				var at: Vector2 = feature.position
				var scale := Vector3(float(feature.size)*1.5,float(feature.size)*1.55,float(feature.size)*1.5)
				flora_multimesh.set_instance_transform(index,Transform3D(Basis(Vector3.UP,float(feature.rotation)).scaled(scale),Vector3(at.x,terrain_height(at.x,at.y),at.y)))
				flora_multimesh.set_instance_color(index,flora_colors[variant])
			var flora_batch := MultiMeshInstance3D.new()
			flora_batch.multimesh = flora_multimesh
			flora_batch.material_override = flora_material
			regional_feature_root.add_child(flora_batch)
	var fauna: Array = surface_region_features.get("fauna",[])
	var fauna_limit: int = mini(30,fauna.size())
	for variant: int in range(3):
		var shaped: Array = []
		for index: int in range(fauna_limit):
			var feature: Dictionary = fauna[index*fauna.size()/fauna_limit]
			if int(feature.variant)%3 == variant: shaped.append(feature)
		if shaped.is_empty(): continue
		var animal_mesh := MultiMesh.new()
		animal_mesh.transform_format = MultiMesh.TRANSFORM_3D
		animal_mesh.use_colors = true
		animal_mesh.mesh = _fauna_shape_mesh(variant)
		animal_mesh.instance_count = shaped.size()
		for index: int in range(shaped.size()):
			var feature: Dictionary = shaped[index]
			var at: Vector2 = feature.position
			var size: float = float(feature.size)
			animal_mesh.set_instance_transform(index,Transform3D(Basis(Vector3.UP,float(feature.rotation)).scaled(Vector3(size*1.6,size*1.2,size*1.6)),Vector3(at.x,terrain_height(at.x,at.y)+0.12,at.y)))
			animal_mesh.set_instance_color(index,[Color("dba36c"),Color("83c5c0"),Color("c4b979")][variant])
		var animal_material := StandardMaterial3D.new()
		animal_material.vertex_color_use_as_albedo = true
		animal_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		animal_material.roughness = 0.82
		var animal_batch := MultiMeshInstance3D.new()
		animal_batch.multimesh = animal_mesh
		animal_batch.material_override = animal_material
		regional_feature_root.add_child(animal_batch)

func _flora_shape_mesh(variant: int) -> Mesh:
	var cylinder := CylinderMesh.new(); cylinder.top_radius = 0.08; cylinder.bottom_radius = 0.15; cylinder.height = 1.0
	var bulb := SphereMesh.new(); bulb.radius = 0.42; bulb.height = 0.84
	var cone := CylinderMesh.new(); cone.top_radius = 0.0; cone.bottom_radius = 0.36; cone.height = 0.95
	var parts: Array = []
	var count: int = 3 if variant in [0,3] else 5 if variant == 1 else 4 if variant == 2 else 7
	for i: int in range(count):
		var angle: float = TAU*float(i)/float(count)
		var offset := Vector3(cos(angle)*0.22,0,sin(angle)*0.22)
		if variant == 0:
			parts.append([cylinder,_shape_xform(offset+Vector3.UP*0.42,Vector3(0.6,0.82,0.6),angle)])
			parts.append([bulb,_shape_xform(offset+Vector3.UP*0.95,Vector3(0.52,0.65,0.52),angle)])
		elif variant == 1 or variant == 5:
			parts.append([cone,_shape_xform(offset+Vector3.UP*(0.4 if variant == 1 else 0.9),Vector3(0.6,1.2,0.5),angle)])
		elif variant == 2:
			parts.append([cylinder,_shape_xform(offset+Vector3.UP*0.7,Vector3(0.36,1.35,0.36),angle)])
			parts.append([bulb,_shape_xform(offset+Vector3.UP*1.45,Vector3(0.3,0.52,0.3),angle)])
		elif variant == 3:
			parts.append([bulb,_shape_xform(Vector3(cos(angle)*0.44,0.82,sin(angle)*0.44),Vector3(0.9,0.34,0.9),angle)])
		else:
			parts.append([bulb,_shape_xform(Vector3(cos(angle)*0.35,0.22,sin(angle)*0.35),Vector3(1.0,0.22,0.52),angle)])
	return _joined_shape(parts)

func _fauna_shape_mesh(variant: int) -> Mesh:
	var body := SphereMesh.new(); body.radius = 0.52; body.height = 1.04
	var limb := CylinderMesh.new(); limb.top_radius = 0.035; limb.bottom_radius = 0.09; limb.height = 0.6
	var fin := CylinderMesh.new(); fin.top_radius = 0.0; fin.bottom_radius = 0.32; fin.height = 0.7
	var parts: Array = [[body,_shape_xform(Vector3.UP*(0.58 if variant != 2 else 1.0),Vector3(1.2,0.8,1.0) if variant == 0 else Vector3(1.5,0.45,1.0) if variant == 1 else Vector3(0.8,0.9,1.0))]]
	if variant == 0:
		for x: float in [-0.34,0.34]:
			for z: float in [-0.3,0.3]: parts.append([limb,_shape_xform(Vector3(x,0.2,z),Vector3(0.75,0.85,0.75))])
	elif variant == 1:
		for side: float in [-1.0,1.0]: parts.append([fin,_shape_xform(Vector3(side*0.7,0.5,0),Vector3(1.1,0.55,0.62),side*PI*0.5)])
		parts.append([limb,_shape_xform(Vector3(0,0.5,-0.65),Vector3(0.28,1.6,0.28))])
	else:
		for i: int in range(6):
			var angle: float = TAU*float(i)/6.0
			parts.append([limb,_shape_xform(Vector3(cos(angle)*0.4,0.34,sin(angle)*0.4),Vector3(0.7,1.25,0.7),angle)])
		parts.append([fin,_shape_xform(Vector3(0,1.5,0.05),Vector3(0.65,1.2,0.65))])
	return _joined_shape(parts)

func _shape_xform(at: Vector3, size: Vector3, angle: float = 0.0) -> Transform3D:
	return Transform3D(Basis(Vector3.UP,angle).scaled(size),at)

func _joined_shape(parts: Array) -> Mesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for part: Array in parts: surface.append_from(part[0],0,part[1])
	surface.generate_normals()
	return surface.commit()

func _style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(1)
	style.set_border_width_all(1)
	style.border_color = Color("45606d")
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style

func _label(text: String, size: int, color: Color = Color("ebebdf")) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(text: String, callback: Callable, parent: Control, cue: String = "ui_confirm") -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 42
	button.focus_mode = Control.FOCUS_ALL
	Instruments.instrument(button,"",Instruments.NAV)
	Instruments.focus_cue(button)
	button.mouse_entered.connect(func() -> void:
		if not button.disabled: audio.play("ui_hover")
	)
	button.pressed.connect(func() -> void:
		if not cue.is_empty(): audio.play(cue)
		callback.call()
	)
	parent.add_child(button)
	return button

func _panel(parent: Control, rect: Rect2) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel",_style(Color(0.095,0.075,0.13,0.94)))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation",10)
	panel.add_child(box)
	return box

func _make_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)
	var theme := Theme.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Segoe UI Variable Text","Segoe UI"])
	theme.default_font = font
	theme.default_font_size = 16
	root.theme = theme
	transition_veil = ColorRect.new()
	transition_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_veil.color = Color(0.03,0.04,0.07,0)
	root.add_child(transition_veil)
	transition_caption = _label("",22,Instruments.PAPER)
	transition_caption.position = Vector2(510,350)
	transition_caption.size = Vector2(580,60)
	transition_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(transition_caption)
	hud = FlightHUD.new()
	root.add_child(hud)
	location_label = hud.location_label
	stats = hud.stats
	objective = hud.objective
	subject = hud.subject
	explanation = hud.explanation
	flight_readout = hud.flight_readout
	energy_bar = hud.energy_bar
	progress_bar = hud.progress_bar
	departure_button = hud.departure_button
	use_button = hud.use_button
	toolbar = hud.toolbar
	hud.action_requested.connect(_hud_action)
	hud.tool_requested.connect(_select_tool)
	hud.ui_cue.connect(func(cue: String) -> void: audio.play(cue))
	hud.altitude_requested.connect(func(direction: float) -> void:
		if paused or _inspection_open(): return
		if direction < 0 and model.state.flight_mode == "orbit":
			_begin_landing()
			return
		if direction != 0: _cancel_orders()
		vertical_button = direction
		altitude_order = -1)
	hud.navigation.set_terrain(terrain_height)
	hud.navigation.destination_requested.connect(_chart_navigate)
	hud.navigation.target_requested.connect(_command_target)
	hud.navigation.landing_requested.connect(func() -> void:
		if not _inspection_open() and not paused: _begin_landing())
	status = _label("",14,Color("ffe0a8"))
	status_backing = ColorRect.new()
	status_backing.position = Vector2(28,74)
	status_backing.size = Vector2(216,48)
	status_backing.color = Color("1c2426",0.98)
	status_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_backing.z_index = 20
	status_backing.hide()
	root.add_child(status_backing)
	status.position = Vector2(68,74)
	status.size = Vector2(168,48)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status.add_theme_color_override("font_color",Color("fff0cb"))
	status.z_index = 21
	root.add_child(status)
	status_icon = TextureRect.new()
	status_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	status_icon.custom_minimum_size = Vector2.ZERO
	status_icon.position = Vector2(36,86)
	status_icon.size = Vector2(24,24)
	status_icon.texture = TOAST_SIGNAL_ICON
	status_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	status_icon.modulate = Color("e9b72f")
	status_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_icon.z_index = 21
	status_icon.hide()
	root.add_child(status_icon)
	guide_caption = _label("",16,Color("b7d2e0"))
	guide_caption.position = Vector2(390,605)
	guide_caption.size = Vector2(530,58)
	guide_caption.add_theme_color_override("font_outline_color",Color("09131f"))
	guide_caption.add_theme_constant_override("outline_size",5)
	guide_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(guide_caption)
	guide_arrow = _label("▼",28,Color("ffe0a8"))
	root.add_child(guide_arrow)
	if campaign != null:
		climate_chart = preload("res://scripts/climate_chart.gd").new()
		climate_chart.position = Vector2(24,125); root.add_child(climate_chart); climate_chart.hide()
		climate_chart.ecosystem_requested.connect(_show_popup.bind("biosphere"))
		fleet_strip = HBoxContainer.new(); fleet_strip.position = Vector2(575,24)
		fleet_strip.add_theme_constant_override("separation",10); root.add_child(fleet_strip)
		fleet_button = _button("",_show_popup.bind("fleet"),fleet_strip)
		fleet_button.icon = load("res://assets/ui/flight/fleet.svg")
		fleet_button.custom_minimum_size.x = 104
		fleet_button.add_theme_constant_override("icon_max_width",32)
		for id: String in campaign.fleet.catalog:
			var bar := ProgressBar.new(); bar.custom_minimum_size = Vector2(78,10)
			bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER; bar.show_percentage = false
			bar.mouse_filter = Control.MOUSE_FILTER_STOP
			Instruments.meter(bar,Color(campaign.fleet.catalog[id].color))
			fleet_strip.add_child(bar); fleet_bars[id] = bar
	ship_locator = _label("◇  SHIP",12,Instruments.GOLD)
	planet_locator = _label(model.definition().name.to_upper(),13,Instruments.PAPER)
	wreck_label = _label("◇  DRIFTING WRECK · PULSE FIELD",13,Instruments.COMMS)
	guardian_label = _label("◇  CUSTODIAN SKIFF",13,Instruments.CARGO)
	for locator: Label in [ship_locator,planet_locator,wreck_label,guardian_label]:
		locator.mouse_filter = Control.MOUSE_FILTER_IGNORE
		locator.hide()
		locator.add_theme_color_override("font_outline_color",Color("151322"))
		locator.add_theme_constant_override("outline_size",4)
		root.add_child(locator)
	for id: String in targets:
		var label: Label = _label(TITLES[id],13,Color("e3e9de"))
		label.add_theme_color_override("font_outline_color",Color("191724"))
		label.add_theme_constant_override("outline_size",3)
		labels[id] = label
		root.add_child(label)
	menu_shade = ColorRect.new()
	menu_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_shade.color = Color(0,0,0,0.65)
	menu_shade.hide()
	root.add_child(menu_shade)
	popup = PanelContainer.new()
	popup.position = Vector2(1020,100)
	popup.size = Vector2(555,595)
	popup.add_theme_stylebox_override("panel",_style(Instruments.INK))
	root.add_child(popup)
	communicator_shell = preload("res://scripts/communicator_shell.gd").new()
	root.add_child(communicator_shell)
	communicator_shell.z_index = 29
	communicator_shell.hide()
	contact_status_pod = preload("res://scripts/contact_status_pod.gd").new()
	root.add_child(contact_status_pod)
	contact_status_pod.z_index = 29
	contact_status_pod.position = Vector2(1090, 785)
	contact_status_pod.hide()
	popup.resized.connect(_sync_communicator_shell)
	var popup_scroll := ScrollContainer.new()
	popup_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	popup.add_child(popup_scroll)
	popup_body = VBoxContainer.new()
	popup_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	popup_body.add_theme_constant_override("separation",12)
	popup_scroll.add_child(popup_body)
	popup.visible = false
	popup.visibility_changed.connect(func() -> void:
		menu_shade.visible = popup.visible and (popup_kind == "menu" or menu_return)
		_sync_communicator_shell()
		if not popup.visible: _reset_contact_presentation())
	planet_map = PlanetMap.new()
	planet_map.definition = model.definition()
	root.add_child(planet_map)
	planet_map.close_requested.connect(func() -> void: planet_map.hide(); audio.play("ui_close"))
	planet_map.travel_requested.connect(_map_travel)
	planet_map.survey_requested.connect(_map_survey)
	planet_map.ui_cue.connect(func(cue: String) -> void: audio.play(cue))
	sector_map = SectorChart.new()
	root.add_child(sector_map)
	sector_map.close_requested.connect(func() -> void: sector_map.hide(); audio.play("ui_close"))
	sector_map.travel_requested.connect(_launch_journey)
	sector_map.system_requested.connect(_open_system_view)
	system_map = preload("res://scripts/system_chart.gd").new(); root.add_child(system_map)
	system_map.close_requested.connect(_close_system_view)
	system_map.orbit_requested.connect(_close_system_view)
	system_map.sector_requested.connect(_toggle_sector_map)
	system_map.travel_requested.connect(_launch_journey)
	system_map.ui_cue.connect(func(cue: String) -> void: audio.play(cue))
	if conflict_view != null: conflict_view.setup_ui(root)
	if signal_view != null: signal_view.setup_ui(root)
	recognition_button = _button("",_show_popup.bind("badges"),root)
	recognition_button.position = Vector2(1536,24); recognition_button.size = Vector2(40,32)
	recognition_button.add_theme_font_size_override("font_size",11)
	Instruments.instrument(recognition_button,"log",Instruments.GOLD)
	recognition_notice = preload("res://scripts/recognition_notice.gd").new(); root.add_child(recognition_notice)
	recognition_notice.opened.connect(func() -> void: _show_popup("badges"))
	_select_tool("scan")

func _physics_process(delta: float) -> void:
	if paused or _inspection_open() or (campaign != null and campaign.traveling()): velocity = Vector3.ZERO; return
	var input_direction: Vector3 = FlightControls.direction()
	if Input.is_action_pressed("flight_brake"): _cancel_orders(); input_direction = Vector3.ZERO
	var orbital: bool = model.state.flight_mode == "orbit"
	# In orbit, an unambiguous descent input commands atmospheric approach.
	if orbital and input_direction.y < 0 and is_zero_approx(input_direction.x) and is_zero_approx(input_direction.z):
		if not landing: _begin_landing()
		input_direction.y = 0
	var speed: float = 16.0 if orbital else 12.0
	var move := Vector3(input_direction.x,0,input_direction.z).rotated(Vector3.UP,yaw).limit_length(1)*speed
	if not input_direction.is_zero_approx():
		if biosphere_view != null: biosphere_view.cancel()
		if conflict_view != null: conflict_view.cancel()
		if signal_view != null: signal_view.cancel()
		kit_mode = false; deploy_order = false
		navigating = false
		approach_subject = false
		landing = false
		held = false
		progress = 0
		altitude_order = -1
		zoom_ascent = false
		salvage_order = false
		salvage_progress = 0
		attack_order = false
		surface_order = false
		service_order = ""
	if navigating:
		if landing and landing_waypoints.is_empty(): destination = orbit.landing_position()
		if approach_subject: destination = _target_position()+Vector3(0,1,1).normalized()*Equipment.reach(tool)*0.55
		if attack_order:
			var away_from_guardian: Vector3 = ship.position-model.guardian_position()
			away_from_guardian.y = 0
			if away_from_guardian.is_zero_approx(): away_from_guardian = Vector3.RIGHT
			destination = model.guardian_position()+away_from_guardian.normalized()*(8 if model.state.guardian_disabled and not model.has_wreck() else Model.LANCE_RANGE-3)
		var offset: Vector3 = destination-ship.position
		# Intermediate landing waypoints guide a continuous arc, not repeated stops.
		if landing and not landing_waypoints.is_empty():
			if offset.length() < 4.0:
				destination = landing_waypoints.pop_front()
				offset = destination-ship.position
			move = offset.normalized()*speed if not landing_waypoints.is_empty() else FlightControls.arrival_velocity(offset,speed)
		else: move = FlightControls.arrival_velocity(offset,speed)
		if offset.length() < 0.65:
			navigating = false
			move = Vector3.ZERO
			if landing:
				if not landing_waypoints.is_empty():
					destination = landing_waypoints.pop_front()
					navigating = true
				else: _change_flight_mode("surface"); return
			if not service_order.is_empty():
				if not service_waypoints.is_empty():
					destination = service_waypoints.pop_front()
					navigating = true
				else:
					selected_service = service_order
					_show_popup("service")
			if approach_subject: approach_subject = false; held = true; latched = false
	if input_direction.y != 0 or vertical_button != 0:
		move.y = clampf(input_direction.y+vertical_button,-1,1)*12
	elif altitude_order >= 0:
		move.y = clampf((altitude_order-ship.position.y)*2,-14,14)
		if absf(altitude_order-ship.position.y) < 0.2: altitude_order = -1
	velocity = velocity.move_toward(move,delta*28)
	if orbital:
		ship.position += velocity*delta
		var orbital_flat := Vector2(ship.position.x,ship.position.z).limit_length(80)
		ship.position.x = orbital_flat.x
		ship.position.z = orbital_flat.y
		ship.position.y = clampf(ship.position.y,-55,75)
		# The orbital globe is solid, including during point-and-click flight.
		var away: Vector3 = ship.position-orbit.planet.position
		if away.length() < 21: ship.position = orbit.planet.position+away.normalized()*21
	else:
		_advance_surface_motion(delta)
		var surface_limit: float = Geography.surface_travel_radius(rendered_planet)
		var flat := Vector2(ship.position.x,ship.position.z)
		if flat.length() > surface_limit:
			flat = flat.limit_length(surface_limit)
			_set_surface_up(Geography.surface_direction(world_definition,flat.x,flat.y))
		ship.position.y = maxf(ship.position.y,terrain_height(ship.position.x,ship.position.z)+2.7)
		if ship.position.y >= 58: _change_flight_mode("orbit"); return
		var away: Vector3 = ship.position-targets.relay.position
		if Vector2(away.x,away.z).length() < 3 and away.y < 7:
			var outward := Vector2(away.x,away.z).normalized()
			if outward.is_zero_approx(): outward = Vector2.RIGHT
			ship.position.x = targets.relay.position.x+outward.x*3
			ship.position.z = targets.relay.position.z+outward.y*3
			_set_surface_up(Geography.surface_direction(world_definition,ship.position.x,ship.position.z))
		_refresh_surface_geography()
	if Vector2(velocity.x,velocity.z).length() > 0.2: ship.rotation.y = lerp_angle(ship.rotation.y,atan2(-velocity.x,-velocity.z),delta*5)
	ship.rotation.z = lerpf(ship.rotation.z,-move.rotated(Vector3.UP,-ship.rotation.y).x*0.025,delta*5)
	ship.rotation.x = lerpf(ship.rotation.x,-velocity.y*0.015,delta*4)

func _advance_surface_motion(delta: float) -> void:
	var anchor_frame: Dictionary = SurfaceCoordinates.tangent_frame(Geography.site_direction(rendered_planet))
	var current_up: Vector3 = _saved_surface_up()
	var current_frame: Dictionary = SurfaceCoordinates.tangent_frame(current_up)
	var plane_motion: Vector3 = anchor_frame.east*velocity.x+anchor_frame.north*velocity.z
	var east_m: float = plane_motion.dot(current_frame.east)*delta
	var north_m: float = plane_motion.dot(current_frame.north)*delta
	var next_up: Vector3 = Geography.surface_runtime(world_definition).advance(current_up,east_m,north_m)
	ship.position.y += velocity.y*delta
	_set_surface_up(next_up)
	_refresh_surface_geography()

func _refresh_surface_geography() -> void:
	if rendered_planet != "morrow": return
	var up: Vector3 = _saved_surface_up()
	var runtime: Object = Geography.surface_runtime(world_definition)
	var next_region_id: String = runtime.region_id(up)
	var next_habitat_region_id: String = runtime.habitat_region_id(up)
	var region_changed: bool = next_region_id != surface_window_region_id
	var habitat_changed: bool = next_habitat_region_id != surface_habitat_region_id
	if not region_changed and not habitat_changed: return
	surface_window_region_id = next_region_id
	surface_habitat_region_id = next_habitat_region_id
	surface_region_features = _surface_feature_sets(up)
	if region_changed:
		_rebuild_surface_terrain(up)
		var cover_rng := RandomNumberGenerator.new()
		cover_rng.seed = int(world_definition.geography_seed)
		_make_ground_cover(cover_rng)
	_make_regional_features()

func _process(delta: float) -> void:
	if hud != null and model.state.flight_mode == "surface":
		hud.navigation.recenter_surface(Vector2(ship.position.x,ship.position.z))
	if campaign != null and recognition_notice != null:
		var suspended: bool = paused or _inspection_open()
		recognition_notice.advance(delta,suspended)
		if not suspended and not recognition_notice.visible and not campaign.recognition.state.queue.is_empty():
			recognition_notice.present(campaign.recognition.state.queue.pop_front(),campaign); audio.play("achievement")
	audio.update_flight(delta,velocity.length(),model.state.flight_mode == "orbit",paused or _inspection_open())
	if not paused and not _inspection_open(): caption_time -= delta
	guide_caption.visible = caption_time > 0
	frame_samples.append(delta*1000)
	if frame_samples.size() > 600: frame_samples.pop_front()
	if not paused and (not _inspection_open() or (campaign != null and campaign.traveling() and not popup.visible)):
		elapsed += delta
		tick_clock += delta
		while tick_clock >= 1:
			tick_clock -= 1
			var old_count: int = model.state.history.size()
			var distance: float = ship.position.distance_to(OrbitalScene.WRECK_POSITION) if model.state.flight_mode == "orbit" else INF
			var old_shots: int = model.state.guardian_shots
			var old_pulse: int = model.state.threat_clock
			var old_escorts: Array = campaign.fleet.active_ids() if campaign != null else []
			model.state.position = [ship.position.x,ship.position.y,ship.position.z]
			if model.state.flight_mode == "surface": _sync_surface_pose()
			var pulse: String = campaign.tick(distance) if campaign != null else model.tick(distance)
			if model.state.planet_id != rendered_planet:
				if not changing_planet: changing_planet = true; call_deferred("_reload_destination")
				return
			if sector_map.visible: sector_map.refresh()
			if system_map.visible: system_map.refresh()
			if campaign != null: campaign.fleet.prepare(campaign,ship.position)
			var escorts: Array = campaign.fleet.positions(campaign) if campaign != null else []
			var attack: String = model.guardian_step(ship.position,escorts) if pulse != "tow" and not (campaign != null and campaign.traveling()) else ""
			if campaign != null: campaign.fleet.orbit_hits(campaign,old_shots,old_pulse)
			if campaign != null and model.state.flight_mode == "surface":
				var ground_event: String = campaign.combat.step(campaign,ship.position)
				if ground_event == "tow": attack = "tow"
				elif ground_event == "hit": _toast("Surface defenses hit · move clear of their aim"); audio.play("error")
				elif ground_event == "aim": audio.play("target_lock")
				elif ground_event == "shield_block": audio.play("scan_complete")
			if campaign != null and pulse != "tow" and attack != "tow":
				var raid_event: String = campaign.conflict.step(campaign,ship.position)
				if raid_event == "tow": attack = "tow"
				elif raid_event == "hit": _toast("Raid strike hit · move clear of the aim volume"); audio.play("error")
				elif raid_event == "aim": audio.play("target_lock")
				elif raid_event == "shield_block": audio.play("scan_complete")
			if campaign != null and pulse != "tow" and attack != "tow" and conflict_view != null and conflict_view.attacking:
				campaign.fleet.assist(campaign,"raid",true,ship.position)
			elif campaign != null and pulse != "tow" and attack != "tow":
				campaign.fleet.assist(campaign,"guardian" if model.state.flight_mode == "orbit" else surface_selected,attack_order if model.state.flight_mode == "orbit" else surface_order and not surface_salvage_order,ship.position)
			if not model.has_wreck() and attack in ["guardian_hit","guardian_miss","tow"]:
				enemy_flash = 0.35
				audio.play("scan_complete")
			if attack == "guardian_aim":
				_toast("Incoming strike · move outside the marked volume")
				audio.play("target_lock")
			elif attack == "guardian_miss": _toast("Strike evaded")
			if pulse == "shield_block" or attack == "shield_block": audio.play("scan_complete")
			if pulse == "tow" or attack == "tow":
				_cancel_orders()
				_restore_ship()
				arrival_fade = 0.8
				_toast("Emergency tow · return to a dock or use an energy pack")
				if campaign != null: campaign.diplomacy.record(campaign,"combat","Flagship disabled; emergency tow recovered it with damaged hull and depleted energy.","",{"planet":model.state.planet_id,"tow":model.state.tow_count},0,"tow:"+str(model.state.tow_count))
				audio.play("error")
			elif pulse == "pulse" or attack == "guardian_hit":
				_toast("Incoming fire · move, shield or neutralize the attacker" if attack == "guardian_hit" else "Defense pulse hit · leave the core or engage the shield")
				audio.play("error")
			if model.state.history.size() != old_count:
				if pulse not in ["pulse","tow"] and attack not in ["guardian_hit","tow"]:
					_toast(model.state.history.back().text)
					audio.play("arrival")
				if popup.visible: _show_popup(popup_kind)
			if int(model.state.time)%30 == 0 and "--field-capture" not in OS.get_cmdline_user_args(): _save(false)
			if campaign != null:
				for id: String in old_escorts:
					if campaign.fleet.state.ships[id].status == "lost":
						_toast(campaign.fleet.catalog[id].name+" lost · relations −7"); audio.play("error")
	if sector_map.visible and campaign != null and campaign.traveling():
		sector_map.graph.travel_fraction = clampf(1.0-(campaign.sector.state.flagship.remaining-tick_clock)/maxf(1,campaign.sector.state.flagship.duration),0,1)
		sector_map.graph.queue_redraw()
	_update_camera(delta)
	if not paused and not _inspection_open() and model.state.flight_mode == "orbit": orbit.advance(delta)
	if not paused and not _inspection_open() and model.state.flight_mode == "surface":
		for motion: RefCounted in grazer_motion:
			motion.advance(delta,ship.position)
			motion.actor.position.y = maxf(motion.actor.position.y,terrain_height(motion.actor.position.x,motion.actor.position.z)+3.0)
	_update_visuals()
	if deploy_order and not navigating and not paused and not _inspection_open(): _finish_deployment()
	_operate(delta)
	_operate_salvage(delta)
	_operate_attack()
	_operate_surface_attack()
	if surface_combat_visual != null: surface_combat_visual.refresh(campaign,surface_selected,tick_clock,delta,paused or _inspection_open())
	if fleet_visual != null: fleet_visual.refresh(campaign,delta,paused or _inspection_open())
	if support_visual != null: support_visual.refresh(model,ship.position,delta,paused or _inspection_open())
	if conflict_view != null: conflict_view.refresh(delta)
	if signal_view != null: signal_view.refresh(delta,paused or _inspection_open() or model.state.flight_mode != "orbit")
	if biosphere_view != null: biosphere_view.refresh(delta,paused or _inspection_open() or model.state.flight_mode != "surface")
	if not paused and not _inspection_open():
		weapon_flash = maxf(0,weapon_flash-delta)
		enemy_flash = maxf(0,enemy_flash-delta)
	_update_flight_effects(delta)
	ui_clock += delta
	if ui_clock > 0.1:
		ui_clock = 0
		_refresh_ui()
	toast_time -= delta
	status.visible = toast_time > 0 or paused
	if is_instance_valid(status_backing): status_backing.visible = status.visible
	if is_instance_valid(status_icon): status_icon.visible = toast_time > 0 and not paused
	if paused: status.text = "Paused — Space to resume"
	if "--field-capture" in OS.get_cmdline_user_args(): _capture(delta)
	if "--flight-capture" in OS.get_cmdline_user_args(): _capture_flight(delta)

func _update_camera(delta: float) -> void:
	distance = lerpf(distance,camera_distance_target,minf(1,delta*8))
	var focus: Vector3 = ship.position+Vector3(0,-1,0)
	if model.state.flight_mode == "surface":
		# A slightly wider follow view keeps the scout readable against the terrain.
		# Looking a little behind the ship places it lower in frame while preserving follow.
		focus -= Vector3(sin(yaw),0,cos(yaw))*3.0
	camera_focus = camera_focus.lerp(focus,minf(1,delta*14))
	var offset := Vector3(sin(yaw)*cos(pitch),sin(pitch),cos(yaw)*cos(pitch))*distance
	camera.position = camera_focus+offset
	if model.state.flight_mode == "surface": camera.position.y = maxf(camera.position.y,terrain_height(camera.position.x,camera.position.z)+1.5)
	else:
		var away: Vector3 = camera.position-orbit.planet.position
		if away.length() < 20: camera.position = orbit.planet.position+away.normalized()*20
	camera.look_at(camera_focus)

func _zoom_camera(steps: float) -> void:
	if paused or _inspection_open(): return
	var orbital: bool = model.state.flight_mode == "orbit"
	if steps < 0 and zoom_ascent: _cancel_orders()
	if steps > 0 and landing: _cancel_orders()
	var minimum: float = ORBIT_ZOOM_MIN if orbital else SURFACE_ZOOM_MIN
	var maximum: float = ORBIT_ZOOM_MAX if orbital else SURFACE_ZOOM_MAX
	camera_distance_target = clampf(camera_distance_target*pow(1.14,steps),minimum,maximum)
	if not orbital and steps > 0 and camera_distance_target >= SURFACE_ZOOM_MAX-0.1:
		if not zoom_ascent:
			_departure()
			zoom_ascent = true
			_toast("Ascending to orbit · scroll in or Stop to cancel")
	elif orbital and steps < 0 and camera_distance_target <= 45:
		if not landing:
			_begin_landing()
			zoom_descent = true
	elif orbital and camera_distance_target >= ORBIT_ZOOM_MAX and steps > 0:
		_toggle_system_view()

func _update_flight_effects(delta: float) -> void:
	var stopped: bool = paused or _inspection_open()
	var orbital: bool = model.state.flight_mode == "orbit"
	scout_motion.advance(delta,ship.basis.inverse()*velocity,stopped)
	effects.update(delta,velocity.length(),stopped,orbital,terrain_height(ship.position.x,ship.position.z),tool,beam.visible,_target_position(),progress)
	if not stopped: arrival_fade = maxf(0,arrival_fade-delta*1.8)
	var outbound: float = 0
	if not orbital and velocity.y > 0.1: outbound = smoothstep(53,58,ship.position.y)
	# Cover only the reference-frame swap, not the visible final approach.
	if orbital and landing and landing_waypoints.is_empty(): outbound = LANDING_VEIL_OPACITY*(1-smoothstep(0.65,1.8,ship.position.distance_to(destination)))
	transition_veil.color.a = maxf(arrival_fade,outbound)
	transition_caption.text = model.definition().name.to_upper()+(" / ORBIT" if orbital else " / ATMOSPHERE")
	transition_caption.modulate.a = transition_veil.color.a
	for locator: Label in [ship_locator,planet_locator,wreck_label,guardian_label]:
		locator.modulate.a = 1.0-transition_veil.color.a

func _update_visuals() -> void:
	orbit.landing_marker.visible = landing and model.state.flight_mode == "orbit" and not _inspection_open()
	if support_visual != null: support_visual.refresh(model,ship.position,0,true)
	_update_outpost_visual()
	orbit.show_aim(model,enemy_flash)
	if orbit.hostile_visual != null: orbit.hostile_visual.disabled = model.state.guardian_disabled
	orbit.guardian.rotation.z = 0.35 if model.state.guardian_disabled else 0.0
	if model.state.guardian_alert > 0 and not model.state.guardian_disabled:
		var facing: Vector3 = ship.position-model.guardian_position()
		if Vector2(facing.x,facing.z).length() > 0.1: orbit.guardian.rotation.y = atan2(-facing.x,-facing.z)
	var orbital: bool = model.state.flight_mode == "orbit"
	orbit.guardian.position.x = model.state.guardian_x
	orbit.guardian.position.z = model.state.guardian_z
	var guardian_ink: StandardMaterial3D = orbit.guardian_eye.material_override
	guardian_ink.albedo_color = Color("6d727c") if model.state.guardian_disabled else (Color("f17e77") if model.state.guardian_alert >= 3 else Color("f0ae77"))
	guardian_ink.emission = guardian_ink.albedo_color
	weapon_beam.visible = weapon_flash > 0 and not _inspection_open()
	shroud_ring.visible = model.state.shroud_on
	shroud_ring.rotation.y = elapsed*0.3
	ship_locator.visible = distance > 85 and not _inspection_open() and not camera.is_position_behind(ship.position)
	ship_locator.position = camera.unproject_position(ship.position)+Vector2(10,10)
	planet_locator.visible = orbital and distance > 150 and not _inspection_open() and not camera.is_position_behind(orbit.planet.position)
	planet_locator.position = camera.unproject_position(orbit.planet.position)+Vector2(-25,-28)
	wreck_label.visible = model.has_wreck() and orbital and not _inspection_open() and not camera.is_position_behind(OrbitalScene.WRECK_POSITION)
	wreck_label.position = camera.unproject_position(OrbitalScene.WRECK_POSITION)+Vector2(12,-18)
	guardian_label.visible = model.has_guardian() and orbital and (model.state.survey_ticks >= int(model.definition().survey_seconds) or model.state.guardian_alert > 0) and not _inspection_open() and not camera.is_position_behind(model.guardian_position())
	guardian_label.text = (model.enemy_profile().name.to_upper()+ (" · DISABLED" if model.state.guardian_disabled else " · WARNING" if model.state.guardian_alert > 0 else "")) if model.has_guardian() else ""
	guardian_label.position = camera.unproject_position(model.guardian_position())+Vector2(10,-22)
	navigation_marker.visible = navigating
	navigation_marker.position = destination-Vector3(0,0.8,0)
	guide_arrow.visible = not paused and not _inspection_open() and surface_weapon.is_empty() and climate_tool.is_empty()
	if orbital:
		guide_arrow.position = Vector2(1400,615)
		ring.visible = false
		for label: Label in labels.values(): label.visible = false
		return
	if model.state.landings > 0: guide_arrow.visible = false
	if "relay" not in model.state.scanned:
		var projected: Vector2 = camera.unproject_position(_target_position("relay"))
		guide_arrow.position = Vector2(clampf(projected.x-14,350,1180),clampf(projected.y-72,130,610))-Vector2(0,sin(elapsed*4)*5)
		guide_arrow.visible = guide_arrow.visible and not camera.is_position_behind(_target_position("relay"))
	else: guide_arrow.position = Vector2(1400,615+sin(elapsed*4)*4)
	for i: int in range(wild_plants.size()):
		wild_plants[i].scale = Vector3.ONE*(0.9 if i == 0 else (0.7 if i < int(model.state.native_stock) else 0.3))
		wild_plants[i].rotation.z = sin(elapsed*1.1+i)*0.035
	bed_material.albedo_color = Color("7a5d4e") if model.state.warm else Color("6e6962")
	for i: int in range(grown_plants.size()):
		grown_plants[i].visible = model.state.seeded
		grown_plants[i].scale = Vector3.ONE*(0.08+float(model.state.growth)*(0.55+0.06*(i%3)))
		grown_plants[i].rotation.z = sin(elapsed*1.2+i)*0.045
	for i: int in range(mineral_crystals.size()):
		mineral_crystals[i].visible = i < int(model.state.ore_remaining)
	relay_light.visible = "relay" in model.state.scanned or model.state.growth >= 1
	var relay_pos: Vector3 = targets.relay.position
	for i: int in range(relay_motes.size()):
		var m_ang: float = elapsed * 0.85 + (i / float(relay_motes.size())) * TAU
		var m_rad: float = 1.35 + sin(elapsed * 1.5 + i) * 0.25
		var m_y: float = 1.6 + sin(elapsed * 2.0 + i * 1.1) * 0.5 + (i * 0.3)
		relay_motes[i].position = relay_pos + Vector3(cos(m_ang) * m_rad, m_y, sin(m_ang) * m_rad)
	ring.position = targets[selected].position+Vector3(0,0.08,0)
	ring.scale = Vector3.ONE*(1.0+sin(elapsed*3)*0.035)
	ring.visible = not kit_mode and not deploy_order and not camera.is_position_behind(_target_position())
	for id: String in labels:
		var at: Vector3 = _target_position(id)+Vector3(0,0.5 if id == "vein" else 3,0)
		var label: Label = labels[id]
		if id == "vein": label.text = "RESONANT SEAM · %d / %d" % [model.state.ore_remaining,Model.MINERAL_DEPOSIT_UNITS] if model.state.ore_remaining > 0 else "DEPLETED CRYSTAL SEAM"
		var screen_at: Vector2 = camera.unproject_position(at)
		label.position = screen_at+Vector2(54,-22) if id == "vein" else screen_at-Vector2(label.size.x/2,20)
		if id == "vein":
			var ship_screen: Vector2 = camera.unproject_position(ship.position)
			var ship_rect := Rect2(ship_screen-Vector2(78,38),Vector2(156,76))
			if Rect2(label.position,label.size).intersects(ship_rect):
				var left_position: Vector2 = screen_at-Vector2(label.size.x+18,22)
				var above_position: Vector2 = screen_at-Vector2(label.size.x*0.5,label.size.y+22)
				label.position = left_position if not Rect2(left_position,label.size).intersects(ship_rect) else above_position
			label.position.x = clampf(label.position.x,365.0,1480.0-label.size.x)
		label.visible = id == selected and not camera.is_position_behind(at) and not _inspection_open() and label.position.y > 145 and label.position.y < 650 and label.position.x > 350
		label.modulate.a = 1.0

func _target_position(id: String = "") -> Vector3:
	if id.is_empty(): id = selected
	var node: Node3D = targets[id]
	return node.position+Vector3(0,2.5 if id in ["pod","relay"] else 0.6,0)

func _activate_support(id: String) -> void:
	if paused or _inspection_open(): return
	var blocked: String = campaign.use_support(id) if campaign != null else Model.Support.use(model,id)
	_toast(blocked if not blocked.is_empty() else Model.Support.catalog[id].name+" active")
	audio.play("error" if not blocked.is_empty() else "scan_complete" if id == "shield" else "target_lock")
	if blocked.is_empty(): _save(false)
	_refresh_ui()

func _hud_action(action: String) -> void:
	if action.begins_with("item:"):
		if paused or _inspection_open(): return
		var id: String = action.trim_prefix("item:")
		if not hud.Palette.unavailable(id,model).is_empty(): return
		if Model.Support.catalog.has(id): _activate_support(id)
		elif id == "lance": _select_weapon()
		elif id == "seed" and campaign != null: _cargo_tab("specimens")
		elif Climate.data().tools.has(id): _select_climate(id)
		elif SurfaceCombat.data().weapons.has(id): _select_surface_weapon(id)
		elif id == "pack": _hud_action("pack")
		elif Model.repair_items().has(id): _hud_action(id)
		else: _select_tool(id)
		_refresh_ui()
		return
	if action.begins_with("category:") or action in ["palette_toggle","page_previous","page_next"]:
		if paused or _inspection_open(): return
		hud._internal_action(action)
		audio.play("ui_confirm")
		return
	match action:
		"pause": _toggle_pause()
		"menu": _exit_encounter()
		"save": _save()
		"load": _load()
		"atlas": _toggle_planet_map()
		"sector": _toggle_sector_map()
		"system_view": _toggle_system_view()
		"departure": _departure()
		"use":
			if not paused and not _inspection_open():
				if not climate_tool.is_empty(): _apply_climate()
				elif kit_mode or deploy_order: _stop()
				elif model.state.flight_mode == "surface" and not surface_weapon.is_empty():
					if surface_order: _stop()
					else: _order_surface_attack(surface_selected,surface_aim)
				elif model.state.flight_mode == "orbit":
					if landing: _stop()
					elif orbital_target == "guardian":
						if weapon_selected or model.state.guardian_disabled: _command_guardian()
						else: _select_weapon()
					else: _command_wreck()
				else: _activate_selected()
		"weapon": _select_weapon()
		"dock": _approach_service("orbit_tender" if model.state.flight_mode == "orbit" else "basin_port")
		"pack":
			if paused or _inspection_open(): return
			var error: String = model.use_energy_pack()
			_toast(error if not error.is_empty() else "Energy pack consumed · energy %d / %d" % [model.state.energy,model.max_capacity("energy")])
			audio.play("error" if not error.is_empty() else "cargo")
		"repair_pack", "mega_repair_pack":
			if paused or _inspection_open(): return
			var hull_before: float = model.state.hull
			var error: String = campaign.use_repair_pack(action) if campaign != null else model.use_repair_pack(action)
			_toast(error if not error.is_empty() else "%s · restored %d hull" % [Model.repair_items()[action].name,model.state.hull-hull_before])
			audio.play("error" if not error.is_empty() else "cargo")
			if error.is_empty(): _save(false)
		"shield", "rally_call": _activate_support(action)
		"shroud":
			if paused or _inspection_open(): return
			var error: String = model.toggle_shroud()
			_toast(error if not error.is_empty() else ("Pulse ward active · consumes 2 energy per second" if model.state.shroud_on else "Pulse ward deactivated"))
			audio.play("error" if not error.is_empty() else "ui_confirm")
		"repair":
			if paused or _inspection_open(): return
			var error: String = model.repair(_wreck_distance())
			_toast(error if not error.is_empty() else "Field repair complete · 35 hull restored")
			audio.play("error" if not error.is_empty() else "cargo")
		"stop": _stop()
		"zoom_in": _zoom_camera(-1)
		"zoom_out": _zoom_camera(1)
		"cargo", "systems", "contact", "journal", "controls", "audio":
			_toggle_drawer(action)
		_:
			if action.begins_with("category:"): audio.play("ui_confirm")

func _chart_navigate(at: Vector2) -> void:
	if paused or _inspection_open(): return
	if model.state.flight_mode == "surface":
		at = at.limit_length(Geography.surface_travel_radius(rendered_planet))
		_navigate(Vector3(at.x,maxf(ship.position.y,terrain_height(at.x,at.y)+4),at.y))
	else: _navigate(Vector3(at.x,ship.position.y,at.y))

func _command_target(id: String) -> void:
	if id == "service":
		_approach_service("orbit_tender" if model.state.flight_mode == "orbit" else "basin_port")
		return
	if id == "wreck": _command_wreck(); return
	if id == "guardian": _target_guardian(); return
	if paused or _inspection_open() or id not in targets: return
	if id != selected: _cancel_orders()
	selected = id
	_activate_selected()

func _wreck_distance() -> float:
	return ship.position.distance_to(OrbitalScene.WRECK_POSITION) if model.has_wreck() and model.state.flight_mode == "orbit" else INF

func _command_wreck() -> void:
	if paused or _inspection_open(): return
	orbital_target = "wreck"
	var reason: String = model.salvage_reason(0)
	if not reason.is_empty(): _toast(reason); audio.play("error"); return
	if salvage_order: _stop(); return
	_navigate(OrbitalScene.WRECK_POSITION+Vector3(0,0,8))
	salvage_order = true
	audio.play("target_lock")

func _select_weapon() -> void:
	if paused or _inspection_open() or model.state.flight_mode != "orbit": return
	_cancel_orders()
	surface_weapon = ""
	climate_tool = ""
	weapon_selected = true
	hud.select_tool("lance")
	audio.play("ui_confirm")

func _target_guardian() -> void:
	if not model.has_guardian(): return
	if paused or _inspection_open(): return
	orbital_target = "guardian"
	if weapon_selected or model.state.guardian_disabled: _command_guardian()
	else: _toast("Select the weapon first, then click the skiff to attack")

func _command_guardian() -> void:
	if paused or _inspection_open() or model.state.flight_mode != "orbit": return
	orbital_target = "guardian"
	if model.state.guardian_disabled and (model.has_wreck() or model.state.guardian_salvaged): _toast("Contact cleared · no remaining cargo"); return
	if attack_order: _stop(); return
	if not model.state.guardian_disabled and model.state.energy < Model.LANCE_ENERGY: _toast("Need 10 energy to fire the arc lance"); audio.play("error"); return
	_cancel_orders()
	if ship.position.distance_to(model.guardian_position()) > (10 if model.state.guardian_disabled else Model.LANCE_RANGE):
		_navigate(model.guardian_position())
	attack_order = true
	audio.play("target_lock")

func _operate_attack() -> void:
	if not attack_order or paused or _inspection_open() or navigating or model.state.flight_mode != "orbit": return
	if model.state.guardian_disabled and not model.has_wreck() and campaign != null:
		var recovered: String = campaign.salvage_enemy(ship.position)
		_cancel_orders()
		_toast(recovered if not recovered.is_empty() else "Salvage secured in cargo")
		audio.play("error" if not recovered.is_empty() else "cargo")
		if recovered.is_empty(): _save(false)
		return
	var error: String = model.lance_reason(ship.position)
	if error == "Arc lance recharging.": return
	if error == "Close within 24 m to fire.":
		_navigate(model.guardian_position())
		attack_order = true
		return
	if not error.is_empty():
		_cancel_orders()
		_toast(error)
		audio.play("error")
		return
	var at: Vector3 = model.guardian_position()
	if campaign != null: campaign.fire_weapon(ship.position)
	else: model.fire_lance(ship.position)
	weapon_flash = 0.17
	var origin: Vector3 = _ship_socket("WeaponEmitter")
	weapon_beam.position = (origin+at)*0.5
	var axis: Vector3 = (at-origin).normalized()
	var side: Vector3 = axis.cross(Vector3.FORWARD).normalized()
	if side.length() < 0.1: side = axis.cross(Vector3.RIGHT).normalized()
	weapon_beam.basis = Basis(side,axis*origin.distance_to(at),side.cross(axis))
	audio.play("scan_complete")
	if model.state.guardian_disabled:
		_cancel_orders()
		_toast("Custodian disabled · it remains intact" if model.has_wreck() else "Hostile neutralized · click its wreck to recover cargo")
		audio.play("achievement")
		_save(false)
	else: _toast("Arc lance hit · %s %d / %d" % [model.enemy_profile().name,model.state.guardian_hull,model.enemy_profile().hull])

func _select_surface_weapon(id: String) -> void:
	if paused or _inspection_open() or model.state.flight_mode != "surface" or campaign == null: return
	if not SurfaceCombat.installed(model,id): return
	_cancel_orders(); surface_weapon = id; weapon_selected = false
	climate_tool = ""
	hud.select_tool(id); audio.play("ui_confirm")

func _order_surface_attack(target: String, point: Vector3) -> void:
	if paused or _inspection_open() or campaign == null: return
	_cancel_orders(); surface_selected = target; surface_aim = point
	var local: Dictionary = campaign.combat.world(model.state.planet_id)
	var salvage: bool = local.units.has(target) and local.units[target].hull <= 0
	if not salvage:
		if surface_weapon.is_empty(): return
		var reason: String = campaign.combat.reason(campaign,surface_weapon,target,point,ship.position)
		if reason not in ["","Approach within weapon range.","Weapon cooling down."]: _toast(reason); return
	surface_order = true
	surface_salvage_order = salvage
	audio.play("target_lock")
	_approach_surface_target()

func _approach_surface_target() -> void:
	var local: Dictionary = campaign.combat.world(model.state.planet_id)
	var salvage: bool = local.units.has(surface_selected) and local.units[surface_selected].hull <= 0
	var at: Vector3 = SurfaceCombat.position(local.units[surface_selected].at) if local.units.has(surface_selected) else surface_aim
	var reach: float = 9 if salvage else float(SurfaceCombat.data().weapons[surface_weapon].range)
	if ship.position.distance_to(at) <= reach*0.9:
		navigating = false; return
	var away: Vector3 = (ship.position-at).normalized()
	if away.is_zero_approx(): away = Vector3.BACK
	destination = at+away*reach*0.75
	destination.y = maxf(destination.y,terrain_height(destination.x,destination.z)+4)
	navigating = true

func _operate_surface_attack() -> void:
	if not surface_order or paused or _inspection_open() or campaign == null or model.state.flight_mode != "surface": return
	var selected_unit: Dictionary = campaign.combat.world(model.state.planet_id).units.get(surface_selected,{})
	if not selected_unit.is_empty() and selected_unit.hull <= 0 and not surface_salvage_order:
		_cancel_orders(); _toast("Target disabled · click the wreck for salvage"); return
	_approach_surface_target()
	if navigating: return
	var local: Dictionary = campaign.combat.world(model.state.planet_id)
	if local.units.has(surface_selected) and local.units[surface_selected].hull <= 0:
		var recovered: String = campaign.combat.salvage(campaign,surface_selected,ship.position)
		_cancel_orders(); _toast(recovered if not recovered.is_empty() else "Salvage loaded")
		if recovered.is_empty(): audio.play("cargo"); _save(false)
		return
	var error: String = campaign.combat.fire(campaign,surface_weapon,surface_selected,surface_aim,ship.position)
	if error == "Weapon cooling down.": return
	if not error.is_empty(): _cancel_orders(); _toast(error); audio.play("error"); return
	if surface_weapon == "surface_laser":
		var origin: Vector3 = _ship_socket("WeaponEmitter")
		var end: Vector3 = SurfaceCombat.position(local.units[surface_selected].at)
		var axis: Vector3 = (end-origin).normalized()
		var side: Vector3 = axis.cross(Vector3.FORWARD).normalized()
		if side.length() < 0.1: side = axis.cross(Vector3.RIGHT).normalized()
		weapon_beam.position = (origin+end)*0.5
		weapon_beam.basis = Basis(side,axis*origin.distance_to(end),side.cross(axis))
		weapon_flash = 0.2
	audio.play("scan_complete")
	if surface_weapon == "ground_bomb" or (local.units.has(surface_selected) and local.units[surface_selected].hull <= 0):
		_cancel_orders()
		_toast("Bomb away" if surface_weapon == "ground_bomb" else "Target disabled · click the wreck for salvage")

func _refresh_surface_combat_ui() -> void:
	if campaign == null or model.state.flight_mode != "surface": return
	var local: Dictionary = campaign.combat.world(model.state.planet_id)
	var incoming: int = 0
	for unit: Dictionary in local.units.values():
		if unit.fire_at > model.state.time: incoming += 1
	hud.guardian_warning.text = "%d INCOMING · MOVE CLEAR OF THE MARKERS" % incoming if incoming > 0 else ""
	if surface_weapon.is_empty() and surface_selected.is_empty(): return
	objective.text = "Hostile surface contacts · engage or withdraw."
	var spec: Dictionary = SurfaceCombat.data().weapons.get(surface_weapon,{})
	if local.units.has(surface_selected):
		var unit: Dictionary = local.units[surface_selected]
		subject.text = SurfaceCombat.profiles(model.state.planet_id)[surface_selected].name
		explanation.text = "Hull %d / %d" % [unit.hull,SurfaceCombat.profiles(model.state.planet_id)[surface_selected].hull] if unit.hull > 0 else "Cargo recovered" if unit.salvaged else "Click wreck to recover cargo"
	else:
		subject.text = spec.get("name","Surface combat")
		explanation.text = "Click the ground to aim" if surface_weapon == "ground_bomb" else "Click a hostile target"
	hud.action_state.text = "APPROACHING" if surface_order and navigating else "FIRING" if surface_order else "READY"
	use_button.text = "Cancel" if surface_order else "Use"
	use_button.disabled = paused or _inspection_open() or surface_weapon.is_empty() or (surface_selected.is_empty() and not surface_order)
	use_button.tooltip_text = spec.get("role","Select a weapon, then click a hostile contact.")
	for id: String in SurfaceCombat.data().weapons:
		if campaign.combat.state.ready > model.state.time: hud.count_labels[id].text = "%ds" % (campaign.combat.state.ready-model.state.time)

func _operate_salvage(delta: float) -> void:
	if not salvage_order or paused or _inspection_open() or model.state.flight_mode != "orbit": return
	if navigating or _wreck_distance() > Model.SALVAGE_REACH:
		salvage_progress = 0
		return
	var reason: String = model.salvage_reason(_wreck_distance())
	if not reason.is_empty():
		_toast(reason)
		_cancel_orders()
		return
	salvage_progress += delta/3.0
	# A short, visible tether confirms that the ship is working the actual wreck.
	beam.visible = true
	var end: Vector3 = OrbitalScene.WRECK_POSITION
	var origin: Vector3 = _ship_socket("ToolEmitter")
	beam.position = (origin+end)*0.5
	var axis: Vector3 = (end-origin).normalized()
	var side: Vector3 = axis.cross(Vector3.FORWARD).normalized()
	if side.length() < 0.1: side = axis.cross(Vector3.RIGHT).normalized()
	beam.basis = Basis(side,axis*origin.distance_to(end),side.cross(axis))
	beam_material.albedo_color = Instruments.COMMS
	beam_material.emission = Instruments.COMMS
	if salvage_progress < 1: return
	var error: String = model.salvage(_wreck_distance())
	_cancel_orders()
	_toast(error if not error.is_empty() else "Shield recovered · inspect and activate it in Equipment")
	audio.play("error" if not error.is_empty() else "achievement")

func _operate(delta: float) -> void:
	beam.visible = false
	if paused or _inspection_open() or model.state.flight_mode == "orbit" or not held or latched:
		progress = 0
		return
	var gap: float = ship.position.distance_to(_target_position())
	var error: String = _tool_reason(tool,selected,gap)
	if not error.is_empty():
		_toast(error)
		audio.play("error")
		latched = true
		progress = 0
		return
	if progress == 0:
		audio.play("collect" if tool == "mine" else tool)
		for motion: RefCounted in grazer_motion: motion.react(tool,_target_position())
	progress += delta/Equipment.seconds(tool)
	var end: Vector3 = _target_position()
	beam.visible = true
	var origin: Vector3 = _ship_socket("ToolEmitter")
	beam.position = (origin+end)*0.5
	var axis: Vector3 = (end-origin).normalized()
	var side: Vector3 = axis.cross(Vector3.FORWARD).normalized()
	if side.length() < 0.1: side = axis.cross(Vector3.RIGHT).normalized()
	beam.basis = Basis(side,axis*origin.distance_to(end),side.cross(axis))
	if progress >= 1:
		var operation_distance: float = ship.position.distance_to(end)
		error = _commit_tool_action(tool,selected,operation_distance)
		var completed: String = "+1 Resonant glass · cargo %d / %d" % [campaign.commerce.quantity("glass"),campaign.commerce.capacity()] if tool == "mine" and campaign != null else ("Survey complete" if tool == "scan" else "Operation complete")
		_toast(error if not error.is_empty() else completed,"glass" if error.is_empty() and tool == "mine" else "")
		audio.play("error" if not error.is_empty() else ("scan_complete" if tool == "scan" else "cargo"))
		latched = true
		held = false
		progress = 0
		operation_feedback = ("SECURED" if tool == "mine" else "COMPLETE") if error.is_empty() else "FAILED"
		operation_feedback_until = elapsed+3
		if error.is_empty(): effects.confirm(end,tool)
		if error.is_empty() and tool == "mine": _save(false)

func _tool_reason(action: String, target: String, gap: float) -> String:
	if action == "mine":
		return campaign.mining_reason(gap) if campaign != null else "Surface mining requires the shared expedition cargo manifest."
	return model.reason(action,target,gap)

func _commit_tool_action(action: String, target: String, gap: float) -> String:
	if action == "mine":
		return campaign.extract_surface_crystal(gap) if campaign != null else "Surface mining requires the shared expedition cargo manifest."
	return model.act(action,target,gap)

func _unhandled_input(event: InputEvent) -> void:
	if not flight_rebind_action.is_empty():
		if event is InputEventKey and event.pressed and not event.echo:
			if event.physical_keycode == KEY_ESCAPE:
				_cancel_flight_rebind()
			else:
				_capture_flight_key(event)
			get_viewport().set_input_as_handled()
		return
	if system_map != null and system_map.visible and not popup.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			match event.physical_keycode:
				KEY_ESCAPE: _escape_menu()
				KEY_J: _toggle_system_view()
				KEY_G: _toggle_sector_map()
				KEY_SPACE: _toggle_pause()
				KEY_F5: _save()
				KEY_F9: _load()
				_: system_map.key(event.physical_keycode)
		return
	if sector_map != null and sector_map.visible and not popup.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			match event.physical_keycode:
				KEY_ESCAPE: _escape_menu()
				KEY_G: _toggle_sector_map()
				KEY_SPACE: _toggle_pause()
				KEY_F5: _save()
				KEY_F9: _load()
		return
	if event is InputEventKey and event.pressed and not event.echo and popup.visible:
		if event.physical_keycode == KEY_ESCAPE: _escape_menu()
		elif popup_kind != "menu" and not menu_return:
			match event.physical_keycode:
				KEY_I: _toggle_drawer("cargo")
				KEY_K: _toggle_drawer("systems")
				KEY_M: _toggle_planet_map()
		return
	if event is InputEventKey and not event.echo:
		if event.physical_keycode == KEY_F and not paused and not _inspection_open():
			held = event.pressed
			if not held: latched = false
		if not event.pressed: return
		match event.physical_keycode:
			KEY_M: _toggle_planet_map()
			KEY_G: _toggle_sector_map()
			KEY_J: _toggle_system_view()
			KEY_I: _toggle_drawer("cargo")
			KEY_K: _toggle_drawer("systems")
			KEY_Y: _toggle_drawer("contact")
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
				if not paused and not _inspection_open():
					hud.refresh_items(model,false,_flight_inventory_entries())
					hud.activate_slot(event.physical_keycode-KEY_1+(9 if event.ctrl_pressed else 0))
			KEY_TAB:
				if not paused and not _inspection_open():
					hud.cycle_group(-1 if event.shift_pressed else 1)
					audio.play("ui_confirm")
			KEY_SPACE: _toggle_pause()
			KEY_ESCAPE: _escape_menu(); return
			KEY_F5: _save()
			KEY_F9: _load()
	if _inspection_open() or paused: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			var sign_y: float = 1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1
			if not event.ctrl_pressed: _zoom_camera(-sign_y)
			elif model.state.flight_mode == "orbit" and sign_y < 0:
				_begin_landing()
			else:
				var target_altitude: float = ship.position.y if altitude_order < 0 else altitude_order
				_cancel_orders()
				altitude_order = clampf(target_altitude+sign_y*6,3,65)
		if event.button_index == MOUSE_BUTTON_LEFT: _pick(event.position)
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x*0.006
		pitch = clampf(pitch+event.relative.y*0.004,0.2,1.3)

func _pick(screen: Vector2) -> void:
	if paused or _inspection_open(): return
	if conflict_view != null and conflict_view.pick(screen): return
	if signal_view != null and signal_view.pick(screen): return
	if biosphere_view != null and not biosphere_view.deploy_id.is_empty():
		if biosphere_view.pick(screen): return
	if not climate_tool.is_empty() and campaign != null:
		if model.state.flight_mode == "surface":
			if _surface_point(screen) is Vector2: _apply_climate()
			return
		var climate_ray: Vector3 = camera.project_ray_normal(screen)
		var climate_from: Vector3 = camera.project_ray_origin(screen)
		var near_planet: Vector3 = climate_from+climate_ray*maxf(0,(orbit.planet.position-climate_from).dot(climate_ray))
		if near_planet.distance_to(orbit.planet.position) <= 19: _apply_climate(); return
	if kit_mode and campaign != null and model.state.flight_mode == "surface":
		var point: Variant = _surface_point(screen)
		if point is Vector2: _order_deployment(point)
		return
	if outpost_visual != null and model.state.flight_mode == "surface":
		var hub_at: Vector3 = outpost_visual.position+Vector3(0,2,0)
		if not camera.is_position_behind(hub_at) and camera.unproject_position(hub_at).distance_to(screen) < 32:
			selected_colony = campaign.colonies.strategic_id(model.state.planet_id)
			_show_popup("colonies")
			return
	var provider: String = "orbit_tender" if model.state.flight_mode == "orbit" else "basin_port"
	var service_at: Vector3 = Model.service_position(provider)
	if not camera.is_position_behind(service_at) and camera.unproject_position(service_at).distance_to(screen) < 22:
		_approach_service(provider)
		return
	if model.state.flight_mode == "orbit":
		var wreck_gap: float = camera.unproject_position(OrbitalScene.WRECK_POSITION).distance_to(screen) if not camera.is_position_behind(OrbitalScene.WRECK_POSITION) else INF
		var guardian_gap: float = camera.unproject_position(model.guardian_position()).distance_to(screen) if not camera.is_position_behind(model.guardian_position()) else INF
		if model.has_guardian() and guardian_gap < 37 and (not model.has_wreck() or guardian_gap < wreck_gap):
			_target_guardian()
			return
		if model.has_wreck() and wreck_gap < 33:
			_command_wreck()
			return
		var ray: Vector3 = camera.project_ray_normal(screen)
		var from: Vector3 = camera.project_ray_origin(screen)
		var near: Vector3 = from+ray*maxf(0,(orbit.planet.position-from).dot(ray))
		if near.distance_to(orbit.planet.position) <= 19: _begin_landing(); return
		var plane := Plane(Vector3.UP,ship.position.y)
		var at: Variant = plane.intersects_ray(from,ray)
		if at is Vector3: _navigate(at)
		return
	if campaign != null:
		var closest_enemy: float = 32
		var enemy: String = ""
		var local: Dictionary = campaign.combat.world(model.state.planet_id)
		for id: String in local.units:
			var at: Vector3 = SurfaceCombat.position(local.units[id].at)
			if camera.is_position_behind(at): continue
			var gap: float = camera.unproject_position(at).distance_to(screen)
			if gap < closest_enemy: closest_enemy = gap; enemy = id
		if not enemy.is_empty():
			if SurfaceCombat.profiles(model.state.planet_id)[enemy].get("civilian",false) and (surface_weapon.is_empty() or campaign.territory.world(model.state.planet_id).phase != "held"):
				_show_popup("territory"); return
			surface_selected = enemy
			if not surface_weapon.is_empty() or local.units[enemy].hull <= 0: _order_surface_attack(enemy,SurfaceCombat.position(local.units[enemy].at))
			else: _toast("Hostile surface contact · select a weapon to engage")
			return
		if surface_weapon == "ground_bomb":
			var point: Variant = _surface_point(screen)
			if point is Vector2: _order_surface_attack("",Vector3(point.x,terrain_height(point.x,point.y),point.y))
			return
	if biosphere_view != null and biosphere_view.pick(screen): return
	var closest: float = 48
	var picked: String = ""
	for id: String in targets:
		var at: Vector3 = _target_position(id)
		if camera.is_position_behind(at): continue
		var d: float = camera.unproject_position(at).distance_to(screen)
		if d < closest: closest = d; picked = id
	if not picked.is_empty():
		_command_target(picked)
		return
	# Ray march against the actual terrain height, never an arbitrary screen plane.
	var from: Vector3 = camera.project_ray_origin(screen)
	var ray: Vector3 = camera.project_ray_normal(screen)
	for i: int in range(1,480):
		var at: Vector3 = from+ray*float(i)*0.5
		if at.y <= terrain_height(at.x,at.z):
			var flat := Vector2(at.x,at.z).limit_length(Geography.surface_travel_radius(rendered_planet))
			_navigate(Vector3(flat.x,maxf(ship.position.y,terrain_height(flat.x,flat.y)+4),flat.y))
			return

func _navigate(at: Vector3) -> void:
	_cancel_orders()
	destination = at
	if model.state.flight_mode == "orbit":
		var flat := Vector2(at.x,at.z).limit_length(75)
		destination = Vector3(flat.x,clampf(at.y,-50,70),flat.y)
	navigating = true
	audio.play("navigation")

func _activate_selected() -> void:
	if held or approach_subject: _stop(); return
	if model.state.flight_mode == "orbit": return
	var error: String = _tool_reason(tool,selected,0)
	if not error.is_empty(): _toast(error); audio.play("error"); return
	_cancel_orders()
	audio.play("target_lock")
	if ship.position.distance_to(_target_position()) > Equipment.reach(tool)*0.85:
		destination = _target_position()+Vector3(0,1,1).normalized()*Equipment.reach(tool)*0.55
		navigating = true
		approach_subject = true
	else: held = true

func _cancel_orders(preserve_signal_scan: bool = false) -> void:
	if conflict_view != null: conflict_view.cancel()
	if signal_view != null: signal_view.cancel(preserve_signal_scan)
	if biosphere_view != null: biosphere_view.cancel()
	surface_order = false
	surface_salvage_order = false
	kit_mode = false
	deploy_order = false
	service_order = ""
	service_waypoints.clear()
	zoom_ascent = false
	zoom_descent = false
	landing_waypoints.clear()
	salvage_order = false
	salvage_progress = 0
	attack_order = false
	effects.reset()
	operation_feedback = ""
	navigating = false
	approach_subject = false
	landing = false
	held = false
	latched = false
	progress = 0
	vertical_button = 0
	altitude_order = -1
	velocity = Vector3.ZERO

func _stop() -> void:
	var had_order: bool = navigating or attack_order or salvage_order or (held and not latched) or altitude_order >= 0
	_cancel_orders()
	if had_order:
		operation_feedback = "CANCELLED"
		operation_feedback_until = elapsed+2
	audio.play("cancel")

func _toggle_pause() -> void:
	paused = not paused
	_cancel_orders(true)
	audio.suspend_voice(paused)

func _departure() -> void:
	if paused or _inspection_open(): return
	if model.state.flight_mode == "orbit":
		if landing: _stop()
		else: _begin_landing()
		return
	_cancel_orders()
	altitude_order = 63
	audio.play("departure")

func _begin_landing() -> void:
	if model.definition().sites.is_empty(): _toast("No playable landing region on this planet yet."); return
	if paused or _inspection_open() or model.state.flight_mode != "orbit" or landing: return
	var route: Array[Vector3] = FlightControls.landing_route(ship.position,orbit.landing_position(),orbit.planet.position)
	_navigate(route.pop_front())
	landing_waypoints = route
	landing = true
	_toast("Approaching "+str(model.definition().sites[0].name)+" · Stop or steer to cancel")
	audio.play("entry")

func _rebuild_surface_terrain(center_up: Vector3) -> void:
	var runtime: Object = Geography.surface_runtime(world_definition)
	var anchor: Vector3 = Geography.site_direction(rendered_planet)
	var center_offset: Vector2 = Geography.surface_local_position(world_definition,center_up) if rendered_planet == "morrow" else Vector2.ZERO
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var coordinates: Array[float] = []
	for v: int in range(-1250,-320,20): coordinates.append(float(v))
	for v: int in range(-320,-48,8): coordinates.append(float(v))
	for v: int in range(-48,49,2): coordinates.append(float(v))
	for v: int in range(56,321,8): coordinates.append(float(v))
	for v: int in range(340,1251,20): coordinates.append(float(v))
	for xi: int in range(coordinates.size()-1):
		for zi: int in range(coordinates.size()-1):
			for sample_offset: Vector2 in [Vector2(0,0),Vector2(1,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),Vector2(0,1)]:
				var px: float = lerpf(coordinates[xi],coordinates[xi+1],sample_offset.x)
				var pz: float = lerpf(coordinates[zi],coordinates[zi+1],sample_offset.y)
				var radial_distance: float = Vector2(px,pz).length()
				var h: float
				var color: Color
				var vertex_x: float = px
				var vertex_z: float = pz
				var recipe_ruggedness: float = 0.0
				var recipe_elevation: float = 0.0
				if rendered_planet == "morrow":
					var sample_up: Vector3 = runtime.advance(center_up,px,pz)
					var sample: Dictionary = runtime.sample(sample_up)
					recipe_elevation = float(sample.elevation)
					recipe_ruggedness = float(sample.ruggedness)
					h = recipe_elevation*SurfaceRuntime.PROVISIONAL_HEIGHT_SCALE_M
					var absolute_offset: Vector2 = runtime.local_offset(anchor,sample_up)
					vertex_x = absolute_offset.x-center_offset.x
					vertex_z = absolute_offset.y-center_offset.y
					color = runtime.surface_color(sample_up)
				else:
					var absolute_x: float = px+center_offset.x
					var absolute_z: float = pz+center_offset.y
					h = terrain_height(absolute_x,absolute_z)
					color = Geography.surface_color(world_definition,absolute_x,absolute_z)
				var far_start: float = 260.0 if rendered_planet == "morrow" else Geography.surface_travel_radius(rendered_planet)+80.0
				var far_blend: float = smoothstep(far_start,far_start+(560.0 if rendered_planet == "morrow" else 220.0),radial_distance)
				var distant_height: float = _distant_landform(vertex_x+center_offset.x,vertex_z+center_offset.y) if rendered_planet == "morrow" else _distant_landform(px,pz)
				if rendered_planet == "morrow":
					# The distant shell is a stable visual continuation of the sampled
					# recipe. Local gameplay height and its 1.2 km travel envelope stay exact.
					distant_height += maxf(0.0,recipe_elevation)*24.0+recipe_ruggedness*32.0
				h = lerpf(h,distant_height,far_blend)
				var visual_radius: float = maxf(0.0,radial_distance-far_start)
				h -= visual_radius*visual_radius/3200.0
				if rendered_planet == "morrow":
					color = color.darkened(0.11).lerp(Color("747a73"),far_blend*0.48)
				surface.set_color(color)
				surface.add_vertex(Vector3(vertex_x,h,vertex_z))
	surface.generate_normals()
	if is_instance_valid(terrain_mesh_instance): terrain_mesh_instance.queue_free()
	var terrain_parent: Node3D = surface_root if is_instance_valid(surface_root) else self
	terrain_mesh_instance = _mesh(surface.commit(),Vector3(center_offset.x,0,center_offset.y),ground_material,terrain_parent)

func _change_flight_mode(mode: String) -> void:
	model.state.position = [ship.position.x,ship.position.y,ship.position.z]
	if model.state.flight_mode == "surface": _sync_surface_pose()
	if not model.change_flight_mode(mode): return
	_cancel_orders()
	_restore_ship()
	_apply_flight_mode(true)
	arrival_fade = LANDING_VEIL_OPACITY if mode == "surface" else 1.0
	audio.play("arrival")
	_toast(model.definition().name+" orbit reached" if mode == "orbit" else "Atmospheric entry complete")
	_save(false)

func _apply_flight_mode(preserve_zoom: bool = false) -> void:
	var orbital: bool = model.state.flight_mode == "orbit"
	orbit.wreck.visible = model.has_wreck()
	orbit.guardian.visible = model.has_guardian()
	orbit.field_ring.visible = model.has_wreck()
	surface_root.visible = not orbital
	orbit.visible = orbital
	# Only one WorldEnvironment is active; hidden nodes still register environments.
	surface_environment.environment = null if orbital else surface_environment_resource
	orbit.environment.environment = orbit.get_meta("environment",orbit.environment.environment)
	if not orbit.has_meta("environment"): orbit.set_meta("environment",orbit.environment.environment)
	if not orbital: orbit.environment.environment = null
	for button: Button in toolbar: button.disabled = orbital
	weapon_selected = false
	climate_tool = ""
	hud.select_tool(tool)
	hud.set_orbital_mode(orbital)
	if orbital: hud.set_active_group("Weapons")
	use_button.disabled = orbital
	if not preserve_zoom:
		distance = 85 if orbital else 38
		camera_distance_target = distance
	else:
		# Reference-frame changes keep scale; settle gently instead of snapping.
		camera_distance_target = clampf(camera_distance_target,45,ORBIT_ZOOM_MAX) if orbital else clampf(camera_distance_target,SURFACE_ZOOM_MIN,75)
	effects.reset()
	beam_material.albedo_color = COLORS[TOOLS.find(tool)]
	beam_material.emission = COLORS[TOOLS.find(tool)]
	camera_focus = ship.position
	_update_camera(0 if preserve_zoom else 1)

func _select_tool(value: String) -> void:
	if paused or _inspection_open(): return
	if not Equipment.has_tool(value): return
	if model.state.flight_mode == "orbit" and hud != null and hud.orbital_mode: return
	_cancel_orders()
	tool = value
	surface_weapon = ""
	surface_selected = ""
	climate_tool = ""
	progress = 0
	held = false
	latched = false
	var index: int = TOOLS.find(tool)
	beam_material.albedo_color = COLORS[index]
	beam_material.emission = COLORS[index]
	hud.select_tool(value)
	Instruments.meter(progress_bar,COLORS[index])
	audio.play("equip_collect" if value == "mine" else "equip_"+value)

func _refresh_ui() -> void:
	var s: Dictionary = model.state
	var orbital: bool = s.flight_mode == "orbit"
	location_label.text = model.definition().name.capitalize()
	stats.text = "%d Marks   ·   Cargo %d/2   ·   %d surveys" % [model.marks,s.samples,s.scanned.size()]
	if campaign != null: stats.text = "%d Marks   ·   Cargo %d/%d   ·   Specimens %d/12" % [model.marks,campaign.commerce.used_space(campaign),campaign.commerce.capacity(),campaign.biosphere.used()]
	energy_bar.max_value = model.max_capacity("energy")
	hud.hull_bar.max_value = model.max_capacity("hull")
	energy_bar.value = s.energy
	hud.hull_bar.value = s.hull
	hud.hull_label.text = "HULL   %d / %d" % [s.hull,model.max_capacity("hull")]
	hud.energy_label.text = "ENERGY   %d / %d" % [s.energy,model.max_capacity("energy")]
	flight_readout.text = "ORBIT  ·  %.0f m/s" % velocity.length() if orbital else "ALT %.0f m  ·  %.0f m/s" % [maxf(0,ship.position.y-terrain_height(ship.position.x,ship.position.z)),velocity.length()]
	flight_readout.tooltip_text = "Orbital flight speed" if orbital else "Height above the terrain directly below your ship; flight speed."
	var field_distance: float = _wreck_distance()
	hud.danger_label.text = "PULSE CORE · %d m · NEXT IN %d s" % [field_distance,6-int(s.threat_clock)] if orbital and field_distance < Model.HAZARD_RADIUS else ("PULSE FIELD · %d m · KEEP CLEAR" % field_distance if orbital and field_distance < Model.HAZARD_WARNING else "")
	hud.guardian_warning.text = "CUSTODIAN LOCKING · %d s" % [3-int(s.guardian_alert)] if orbital and s.guardian_alert > 0 and s.guardian_alert < 3 else ("CUSTODIAN FIRING · %d s TO NEXT SHOT" % maxi(0,int(s.guardian_ready_at)-int(s.time)) if orbital and s.guardian_alert >= 3 and not s.guardian_disabled else "")
	if orbital and model.has_guardian() and not model.has_wreck() and not s.guardian_disabled:
		hud.guardian_warning.text = ("STRIKE IN %d s · MOVE OUTSIDE THE MARKER" % maxi(0,int(s.guardian_fire_at)-int(s.time))) if s.guardian_fire_at > 0 else (model.enemy_profile().name.to_upper()+" · HOSTILE CONTACT" if s.guardian_alert > 0 else "")
	hud.refresh_items(model,paused or _inspection_open(),_flight_inventory_entries())
	if campaign != null:
		hud.set_cargo_readout(campaign.commerce.used_space(campaign),campaign.commerce.capacity())
	else:
		hud.set_cargo_readout(s.samples,2)
	hud.quick_cargo.text = "Inventory"
	hud.quick_cargo.tooltip_text = "Cargo: %d / 2 specimens · Energy packs: %d [I]" % [s.samples,s.energy_packs]
	if campaign != null: hud.quick_cargo.tooltip_text = "Freight and kits: %d / %d · Specimens: %d / 12 · Energy packs: %d [I]" % [campaign.commerce.used_space(campaign),campaign.commerce.capacity(),campaign.biosphere.used(),s.energy_packs]
	if campaign != null:
		var pending: int = campaign.diplomacy.unread().size()
		hud.navigation_actions[1].tooltip_text = "%d incoming transmissions · Communicate [Y]" % pending if pending > 0 else "Communicate · known civilizations and local services [Y]"
		hud.navigation_actions[1].modulate = Color("ffe9ac") if pending > 0 else Color.WHITE
	hud.paused_badge.text = "GAME PAUSED" if popup.visible and popup_kind == "menu" else "FLIGHT PAUSED" if paused else "INSPECTION PAUSED" if popup.visible else "IN TRANSIT" if campaign != null and campaign.traveling() else "INSPECTION PAUSED" if _inspection_open() else ""
	hud.navigation.orbital = orbital
	var service_at: Vector3 = Model.service_position("orbit_tender" if orbital else "basin_port")
	hud.navigation.service_at = Vector2(service_at.x,service_at.z)
	hud.navigation.ship_at = Vector2(ship.position.x,ship.position.z)
	if not orbital: hud.navigation.recenter_surface(hud.navigation.ship_at)
	hud.navigation.heading = -ship.rotation.y
	hud.navigation.planet_at = Vector2(orbit.planet.position.x,orbit.planet.position.z)
	hud.navigation.wreck_at = Vector2(OrbitalScene.WRECK_POSITION.x,OrbitalScene.WRECK_POSITION.z)
	hud.navigation.wreck_known = model.has_wreck() and s.survey_ticks >= int(model.definition().survey_seconds)
	var skiff_at: Vector3 = model.guardian_position()
	hud.navigation.guardian_at = Vector2(skiff_at.x,skiff_at.z)
	hud.navigation.guardian_known = hud.navigation.wreck_known or s.guardian_alert > 0
	hud.navigation.guardian_disabled = s.guardian_disabled
	hud.navigation.guardian_alert = s.guardian_alert
	hud.navigation.surveyed = s.scanned
	hud.navigation.selected = selected
	hud.navigation.navigating = navigating
	hud.navigation.destination = Vector2(destination.x,destination.z)
	hud.navigation.locked = paused or _inspection_open()
	for id: String in targets: hud.navigation.points[id] = Vector2(targets[id].position.x,targets[id].position.z)
	hud.navigation.queue_redraw()
	departure_button.text = ("Cancel approach" if landing else "Return to Morrow") if orbital else "Leave atmosphere"
	if orbital:
		if s.survey_ticks < int(model.definition().survey_seconds): objective.text = "Chart Morrow from Planet map to locate orbital signals."
		elif not s.guardian_disabled and not s.shroud_unlocked: objective.text = "A custodian guards the wreck. Disable it or risk a fast salvage."
		elif not s.shroud_unlocked: objective.text = "Click the wreck inside the pulse field to recover its pulse ward."
		else: objective.text = "Shield recovered. Explore, repair or return to Morrow."
	elif s.landings > 0: objective.text = "Explore freely. Your surveys are secure."
	elif "relay" not in s.scanned: objective.text = "Click the relay to investigate its signal."
	elif not s.history.any(func(entry: Dictionary) -> bool: return entry.id == "first_orbit"): objective.text = "Follow the signal. Leave the atmosphere."
	else: objective.text = "Explore freely. Your surveys are secure."
	if orbital:
		if landing:
			subject.text = "Morrow Basin / atmospheric approach"
			hud.action_state.text = "DESCENDING"
			explanation.text = "Routing around the planet" if not landing_waypoints.is_empty() else "On final approach · Stop or steer to cancel"
			use_button.text = "Cancel"
			use_button.disabled = paused or _inspection_open()
		elif orbital_target == "guardian" and model.has_guardian() and s.guardian_disabled and not model.has_wreck():
			subject.text = model.enemy_profile().name+" / wreck"
			hud.action_state.text = "CLEARED" if s.guardian_salvaged else "SALVAGE"
			explanation.text = "Cargo recovered." if s.guardian_salvaged else "Click to recover two freight units."
			use_button.text = "Cancel" if attack_order else "Recover"
			use_button.disabled = paused or _inspection_open() or s.guardian_salvaged
			use_button.tooltip_text = "Approach the wreck and load its goods into available cargo space."
		elif orbital_target == "guardian" and model.has_guardian() and not s.guardian_disabled:
			var skiff_gap: float = ship.position.distance_to(skiff_at)
			subject.text = "%s / %.0f m" % [model.enemy_profile().name,skiff_gap]
			hud.action_state.text = "APPROACHING" if navigating and attack_order else ("FIRING" if attack_order else "TARGETED")
			explanation.text = "Hull %d/%d · %d damage · 10 energy/shot" % [s.guardian_hull,model.enemy_profile().hull,model.lance_damage()]
			use_button.text = "Cancel" if attack_order else ("Fire" if weapon_selected else "Equip")
			use_button.disabled = paused or _inspection_open() or (weapon_selected and s.energy < Model.LANCE_ENERGY and not attack_order)
			use_button.tooltip_text = "Click to approach and fire the selected weapon." if weapon_selected else "Select the energy weapon first, then click the skiff to fire."
		else:
			subject.text = "Drifting wreck  /  %.0f m" % field_distance if hud.navigation.wreck_known and not s.shroud_unlocked else "Morrow  /  orbital flight"
			hud.action_state.text = "SALVAGING" if salvage_order and not navigating else ("APPROACHING" if salvage_order else ("DANGER" if field_distance < Model.HAZARD_RADIUS else "ORBIT"))
			explanation.text = "%d%% · stay near the wreck" % int(salvage_progress*100) if salvage_order and not navigating else ("Defense pulse repeats every 6 s." if field_distance < Model.HAZARD_WARNING else "Chart in Planet map; click the wreck to approach." if hud.navigation.wreck_known and not s.shroud_unlocked else "Click Morrow to descend.")
			use_button.text = "Cancel" if salvage_order else ("Salvage" if hud.navigation.wreck_known and not s.shroud_unlocked else "Use")
			use_button.disabled = paused or _inspection_open() or not hud.navigation.wreck_known or s.shroud_unlocked
			use_button.tooltip_text = "Approach the wreck; recovering its pulse ward takes 3 seconds and 20 energy." if not use_button.disabled else "Chart Morrow first to locate orbital salvage."
	else:
		var gap: float = ship.position.distance_to(_target_position())
		var reason: String = _tool_reason(tool,selected,0)
		subject.text = TITLES[selected]
		if approach_subject:
			hud.action_state.text = "APPROACHING"
			explanation.text = "Moving into tool range."
		elif held and not latched:
			hud.action_state.text = "OPERATING"
			explanation.text = "%s · %d%%" % [Equipment.title(tool),int(progress*100)]
		elif not operation_feedback.is_empty() and elapsed < operation_feedback_until:
			hud.action_state.text = operation_feedback
			if operation_feedback == "SECURED" and tool == "mine":
				explanation.text = "+1 Resonant glass · %d / %d remain" % [model.state.ore_remaining,Model.MINERAL_DEPOSIT_UNITS]
			else: explanation.text = "Survey recorded in the chronicle." if operation_feedback == "COMPLETE" and tool == "scan" else ("Operation complete." if operation_feedback == "COMPLETE" else "Orders cleared." if operation_feedback == "CANCELLED" else "Operation failed.")
		elif not reason.is_empty():
			hud.action_state.text = "UNAVAILABLE"
			explanation.text = _short_reason(reason)
		else:
			hud.action_state.text = "READY" if gap <= Equipment.reach(tool) else "OUT OF RANGE"
			explanation.text = ("%.0f m · %s energy · 1 cargo" % [gap,Equipment.amount(Equipment.energy(tool,model.installed_upgrades))]) if tool == "mine" and gap <= Equipment.reach(tool) else ("Click target to operate." if gap <= Equipment.reach(tool) else "Click target to approach." )
		use_button.tooltip_text = reason if not reason.is_empty() else "Approach and operate the selected tool."
	progress_bar.value = salvage_progress if orbital and orbital_target == "wreck" else progress
	if operation_feedback in ["COMPLETE","SECURED"] and elapsed < operation_feedback_until: progress_bar.value = 1
	if not orbital:
		use_button.text = "Cancel" if (held and not latched) or approach_subject else "Use"
		use_button.disabled = paused or _inspection_open()
		if not approach_subject and not (held and not latched):
			use_button.disabled = use_button.disabled or not _tool_reason(tool,selected,0).is_empty()
	if not orbital and rendered_planet != "morrow": objective.text = model.definition().name+" · survey local life or return to orbit"
	if orbital and not model.has_wreck() and orbital_target != "guardian":
		objective.text = "Chart this world, dock for services, or choose your next destination."
		subject.text = ""
		hud.action_state.text = ""
		explanation.text = ""
		use_button.disabled = true
	if orbital and not model.has_wreck() and orbital_target == "guardian" and model.has_guardian():
		objective.text = "Recover cargo or continue exploring." if s.guardian_disabled else "Hostile contact · dodge the marked strike or retreat."
	departure_button.disabled = paused or _inspection_open() or (orbital and model.definition().sites.is_empty())
	departure_button.text = ("Cancel approach" if landing else "Descend") if orbital else "Leave atmosphere"
	location_label.text = model.definition().name.capitalize()
	if kit_mode or deploy_order:
		objective.text = "Choose a clear surface site for your colony hub."
		subject.text = "Colony kit / landing footprint"
		hud.action_state.text = "APPROACHING" if deploy_order else "CHOOSE SITE"
		explanation.text = "Kit stays aboard until arrival. Stop to cancel." if deploy_order else "Click a green footprint. Red indicates unsuitable ground."
		use_button.text = "Cancel"
		use_button.disabled = paused or _inspection_open()
		use_button.tooltip_text = "Cancel deployment and keep the colony kit aboard."
		progress_bar.value = 0
	_refresh_surface_combat_ui()
	_refresh_fleet_ui()
	_refresh_climate_ui()
	if biosphere_view != null: biosphere_view.refresh_hud()
	if conflict_view != null: conflict_view.refresh_hud()
	if signal_view != null: signal_view.refresh_hud()
	if recognition_button != null:
		if _inspection_open() and recognition_notice != null: recognition_notice.hide()
		recognition_button.visible = campaign != null and not popup.visible and not planet_map.visible and not system_map.visible and not sector_map.visible
		if campaign != null:
			var tiers: Dictionary = campaign.commerce.state.badges
			recognition_button.text = ""
			var pin: String = campaign.recognition.state.pinned
			if not pin.is_empty():
				var tier: int = tiers[pin]; var badge: Dictionary = campaign.commerce.catalog.badges[pin]
				recognition_button.tooltip_text = "%s · %d points · %s %d/%d" % [campaign.Recognition.title(tiers),campaign.Recognition.points(tiers),badge.name,campaign.commerce.progress(campaign,pin),badge.levels[mini(tier,4)]]
			else:
				recognition_button.tooltip_text = "%s · %d points · badges and shop unlocks" % [campaign.Recognition.title(tiers),campaign.Recognition.points(tiers)]
	if system_map != null:
		system_map.locked = paused or popup.visible
		if system_map.visible: system_map.refresh()
	_layout_seam_context_card()
	var local_view: bool = not orbital and not (system_map != null and system_map.visible) and not (sector_map != null and sector_map.visible)
	hud.navigation.visible = local_view; hud.chart_backing.visible = local_view; hud.chart_heading.visible = local_view
	_update_guidance()
	var map_open: bool = planet_map.visible or system_map.visible or sector_map.visible
	var modal_open: bool = map_open or (popup.visible and popup_kind in ["contact","service"])
	hud.visible = not modal_open
	guide_arrow.visible = guide_arrow.visible and not modal_open
	guide_caption.visible = guide_caption.visible and not modal_open
	if contact_status_pod != null and contact_status_pod.visible and campaign != null:
		contact_status_pod.update_status(campaign.field.state.hull, campaign.field.max_capacity("hull"), campaign.field.state.energy, campaign.field.max_capacity("energy"), campaign.field.marks)

func _layout_seam_context_card() -> void:
	if not is_instance_valid(hud) or not is_instance_valid(hud.context_card): return
	var compact: bool = model.state.flight_mode != "orbit" and selected == "vein" and not _inspection_open()
	if not compact:
		hud.context_card.position = Vector2(450,744)
		hud.context_card.size = Vector2(290,117)
		hud.subject.position = Vector2(462,752); hud.subject.size = Vector2(164,22); hud.subject.add_theme_font_size_override("font_size",15)
		hud.action_state.position = Vector2(635,752); hud.action_state.size = Vector2(95,20); hud.action_state.add_theme_font_size_override("font_size",11)
		hud.explanation.position = Vector2(462,778); hud.explanation.size = Vector2(266,36); hud.explanation.add_theme_font_size_override("font_size",12)
		hud.use_button.position = Vector2(635,818); hud.use_button.size = Vector2(95,28); hud.use_button.add_theme_font_size_override("font_size",16)
		hud.progress_bar.position = Vector2(450,857); hud.progress_bar.size = Vector2(290,4)
		return
	var card_size := Vector2(252,80)
	var seam_at: Vector3 = _target_position("vein")
	if camera.is_position_behind(seam_at): return
	var anchor: Vector2 = camera.unproject_position(seam_at)
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	var card_at: Vector2 = Vector2(anchor.x-card_size.x*0.5,anchor.y+54.0)
	if card_at.y+card_size.y > 660.0: card_at.y = anchor.y-card_size.y-38.0
	card_at.x = clampf(card_at.x,300.0,view_size.x-card_size.x-20.0)
	card_at.y = clampf(card_at.y,140.0,580.0)
	hud.context_card.position = card_at
	hud.context_card.size = card_size
	hud.subject.position = card_at+Vector2(10,7); hud.subject.size = Vector2(150,19); hud.subject.add_theme_font_size_override("font_size",13)
	hud.action_state.position = card_at+Vector2(163,8); hud.action_state.size = Vector2(79,17); hud.action_state.add_theme_font_size_override("font_size",9)
	hud.explanation.position = card_at+Vector2(10,29); hud.explanation.size = Vector2(232,27); hud.explanation.add_theme_font_size_override("font_size",11)
	hud.use_button.position = card_at+Vector2(164,53); hud.use_button.size = Vector2(78,22); hud.use_button.add_theme_font_size_override("font_size",11)
	hud.progress_bar.position = card_at+Vector2(0,76); hud.progress_bar.size = Vector2(252,4)

func _flight_inventory_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	if campaign == null:
		return entries
	for item_id: String in campaign.climate.state.charges:
		var spec: Dictionary = Climate.data().tools[item_id]
		entries.append({"id":item_id,"title":str(spec.name),"count":int(campaign.climate.state.charges[item_id]),"icon":item_id})
	var cargo_totals: Dictionary = {}
	for lot: Dictionary in campaign.commerce.state.cargo:
		var item_id: String = str(lot.get("item", ""))
		if not item_id.is_empty() and campaign.commerce.catalog.goods.has(item_id):
			cargo_totals[item_id] = int(cargo_totals.get(item_id, 0)) + int(lot.get("quantity", 0))
	var cargo_ids: Array = cargo_totals.keys()
	cargo_ids.sort()
	for item_id: String in cargo_ids:
		entries.append({
			"id": "cargo:"+item_id,
			"title": str(campaign.commerce.catalog.goods[item_id].name),
			"count": int(cargo_totals[item_id]),
			"icon": "cargo"
		})
	if campaign.colonies.reserved_space() > 0:
		entries.append({"id":"cargo:colony_kit","title":"Colony landing kit","count":1,"icon":"badge_colonist"})
	var specimen_totals: Dictionary = campaign.biosphere.state.cargo
	var species_ids: Array = specimen_totals.keys()
	species_ids.sort()
	var species: Dictionary = Biosphere.data()
	for item_id: String in species_ids:
		var count: int = int(specimen_totals[item_id])
		if count > 0 and species.has(item_id):
			entries.append({
				"id": "specimen:"+item_id,
				"title": str(species[item_id].name),
				"count": count,
				"icon": "pod"
			})
	return entries

func _short_reason(reason: String) -> String:
	# Keep the full validated reason on hover; the instrument shows one short cause.
	if reason.begins_with("Already catalogued"): return "Survey recorded. Select another tool."
	if reason.begins_with("Sample cradle full"): return "Sample cradles full: 2 / 2."
	if reason.begins_with("Need ") and "energy" in reason: return "Insufficient energy: %s required." % Equipment.amount(Equipment.energy(tool,model.installed_upgrades))
	if reason.begins_with("The thermal tool"): return "Requires a cold mineral bed."
	if reason.begins_with("Sample the seed pods"): return "Requires a scanned lantern pod."
	if reason.begins_with("Keep the last native"): return "Native reserve protected."
	if reason.begins_with("The bed is warm"): return "Bed already warmed."
	if reason.begins_with("Already planted"): return "Specimen already deployed."
	return reason

func _update_guidance() -> void:
	if rendered_planet != "morrow":
		guide_arrow.hide()
		return
	if elapsed < 1 or paused or _inspection_open(): return
	var id: String = "survey"
	var line: String = "Captain, that relay is still transmitting. Click it and we'll approach for a scan."
	if model.state.flight_mode == "orbit":
		if model.state.survey_ticks < int(model.definition().survey_seconds):
			id = "orbit"
			line = "We're clear of the atmosphere. Chart Morrow in Planet map to locate signals."
		elif not model.state.guardian_disabled and model.state.guardian_alert > 0:
			id = "custodian"
			line = "A custodian skiff warns before firing. Leave its exclusion zone or click it to disable it with the arc lance."
		elif model.state.guardian_disabled and not model.state.shroud_unlocked:
			id = "safe_wreck"
			line = "The skiff is disabled, not destroyed. The pulse field remains. Click the wreck to recover its pulse ward."
		elif not model.state.shroud_unlocked:
			id = "wreck"
			line = "The chart found a wreck inside a repeating pulse field. A skiff guards it. Click the wreck to approach or disable the skiff first."
		else:
			id = "shroud"
			line = "The recovered pulse ward reduces orbital damage. Activate it in Equipment; it consumes 2 energy per second."
	elif model.state.landings > 0:
		id = "return"
		line = "Back in the basin. Your surveys are secure. You're free to explore."
	elif "relay" in model.state.scanned:
		id = "ascend"
		line = "The signal leads off-world. Pull the view back to ascend, or select Leave atmosphere."
	if heard_guides.has(id): return
	heard_guides[id] = true
	guide_caption.text = line
	caption_time = maxf(6,line.length()/14.0)
	audio.guide(id,line)

func _toast(text: String, item_icon: String = "") -> void:
	toast_item_icon = item_icon
	if is_instance_valid(status_icon):
		status_icon.visible = true
		status_icon.texture = preload("res://assets/ui/resonant-glass-v1.png") if item_icon == "glass" else TOAST_SIGNAL_ICON
		status_icon.modulate = Color.WHITE if item_icon == "glass" else Color("e9b72f")
		status_icon.position = Vector2(36,86)
		status_icon.size = Vector2(24,24)
		status_icon.custom_minimum_size = Vector2.ZERO
		status.position = Vector2(68,74)
		status.size = Vector2(168,48)
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		status_backing.position = Vector2(28,74)
		status_backing.size = Vector2(216,48)
		status_backing.show()
		status.show()
	status.text = text
	toast_time = 6

func _escape_menu() -> void:
	if popup.visible:
		if menu_return and popup_kind != "menu": _show_popup("menu")
		else: _close_popup()
	elif sector_map != null and sector_map.visible:
		if campaign != null and campaign.traveling(): _show_popup("menu")
		else: sector_map.hide()
	elif system_map != null and system_map.visible:
		if campaign != null and campaign.traveling(): _show_popup("menu")
		else: _close_system_view()
	elif planet_map.visible:
		planet_map.hide()
	else:
		menu_return = false
		_show_popup("menu")

func _close_popup() -> void:
	if territory_panel != null: territory_panel.confirm_refusal = false
	popup.hide()
	system_map.locked = paused
	menu_return = false
	contact_page = "home"
	audio.save_settings()
	audio.play("ui_close")

func _menu_page(kind: String) -> void:
	menu_return = true
	_show_popup(kind)

func flight_rebinding_ui_reset() -> void:
	flight_rebind_action = ""
	flight_binding_labels.clear()
	flight_rebind_buttons.clear()
	flight_rebind_status = null

func _flight_action_name(action: String) -> String:
	return {"flight_forward":"Forward","flight_back":"Back","flight_left":"Left","flight_right":"Right",
		"flight_rise":"Ascend","flight_descend":"Descend","flight_brake":"Brake"}.get(action,action)

func _start_flight_rebind(action: String) -> void:
	flight_rebind_action = action
	flight_rebind_status.text = "Press a key for %s · Esc cancels." % _flight_action_name(action)
	flight_rebind_buttons[action].text = "Press key…"

func _cancel_flight_rebind() -> void:
	var action := flight_rebind_action
	flight_rebind_action = ""
	flight_rebind_status.text = "Key capture cancelled."
	flight_rebind_buttons[action].text = "Set key"

func _capture_flight_key(event: InputEventKey) -> void:
	var action := flight_rebind_action
	var key := int(event.physical_keycode)
	var error := flight_input_settings.assign_key(action,key)
	if not error.is_empty():
		flight_rebind_status.text = error+" Try another key, or press Esc to cancel."
		return
	flight_rebind_action = ""
	flight_binding_labels[action].text = "%s  ·  %s" % [_flight_action_name(action),flight_input_settings.binding_text(action)]
	flight_rebind_buttons[action].text = "Set key"
	flight_rebind_status.text = "Saved. Built-in flight keys remain available."

func _reset_flight_rebinds() -> void:
	if not flight_rebind_action.is_empty(): _cancel_flight_rebind()
	var error: Error = flight_input_settings.reset()
	for action: String in FlightControls.BINDINGS:
		flight_binding_labels[action].text = "%s  ·  %s" % [_flight_action_name(action),flight_input_settings.binding_text(action)]
	if error == OK: flight_rebind_status.text = "Flight keys reset to defaults."
	else: flight_rebind_status.text = "Could not save reset flight keys."

func _inventory_action(action: String, panel: String) -> void:
	# The item invokes the same validated command; keep inventory open for feedback.
	if paused: return
	popup.hide()
	_hud_action(action)
	_show_popup(panel)

func _show_popup(kind: String) -> void:
	if not flight_rebind_action.is_empty(): _cancel_flight_rebind()
	var shop_actor: String = _service_representative() if kind == "service" else ""
	if kind not in ["contact","service"] or not popup.visible or (kind == "service" and shop_actor.is_empty()):
		_reset_contact_presentation()
	elif kind == "service" and is_instance_valid(contact_portrait) and contact_portrait.faction_id != shop_actor:
		_reset_contact_presentation()
	elif is_instance_valid(contact_portrait):
		# Keep the actor alive while rebuilding its surrounding controls.
		contact_portrait.reparent(self)
		contact_portrait.hide()
	_cancel_orders(true)
	if conflict_view != null: conflict_view.button.hide(); conflict_view.alert.hide()
	if signal_view != null: signal_view.signal_button.hide()
	if recognition_notice != null: recognition_notice.hide()
	if recognition_button != null: recognition_button.hide()
	# Remove the wide case/contact content before requesting a narrower panel.
	for child: Node in popup_body.get_children(): popup_body.remove_child(child); child.queue_free()
	popup_body.update_minimum_size(); popup.get_child(0).update_minimum_size(); popup.update_minimum_size()
	system_map.locked = true
	planet_map.hide()
	popup_kind = kind
	if kind == "menu": menu_return = false
	menu_shade.visible = kind == "menu" or menu_return
	popup.position = Vector2(522,165) if kind == "menu" else Vector2(1020,100)
	popup.size = Vector2(555,660 if kind in ["service","contact","freight"] and campaign != null else 595)
	if kind in ["contact","signals","conflict","territory"] and campaign != null:
		popup.position = Vector2(690,100)
		popup.size = Vector2(885,660)
	if kind == "service" and dock_page == "upgrades" and upgrade_family == "support":
		popup.position = Vector2(690,100); popup.size = Vector2(885,660)
	if kind == "service" and not shop_actor.is_empty():
		popup.position = Vector2(690,100); popup.size = Vector2(885,660)
	if kind == "badges": popup.position = Vector2(690,130); popup.size = Vector2(885,630)
	var instrument: bool = kind in ["contact","service"] and campaign != null
	if instrument:
		popup.position = Vector2(310,135); popup.size = Vector2(980,630)
		if kind == "contact" and contact_page == "home":
			popup.position = Vector2(310,170); popup.size = Vector2(980,560)
		var transparent := StyleBoxEmpty.new()
		transparent.set_content_margin(SIDE_LEFT,30); transparent.set_content_margin(SIDE_RIGHT,30)
		transparent.set_content_margin(SIDE_TOP,9); transparent.set_content_margin(SIDE_BOTTOM,32)
		popup.add_theme_stylebox_override("panel",transparent)
	else: popup.add_theme_stylebox_override("panel",_style(Color("242622")))
	popup.z_index = 30; menu_shade.z_index = 20
	popup.visible = true
	var header := HBoxContainer.new()
	popup_body.add_child(header)
	var titles := {"cargo":"EXPEDITION INVENTORY", "systems":"SHIP SYSTEMS", "audio":"AUDIO MIX", "controls":"FLIGHT CONTROLS", "journal":"EXPEDITION LOG", "contact":"VELL / TRADE", "service":"DOCK SERVICES", "menu":"GAME MENU"}
	if campaign != null: titles.contact = "COMMUNICATIONS"; titles.badges = "BADGES"; titles.colonies = "COLONY ADMINISTRATION"; titles.freight = "FREIGHT CONTRACTS"
	titles.fleet = "ALLIED FLEET"
	titles.signals = "ORBITAL SIGNALS"
	titles.conflict = "COLONY DEFENSE"
	titles.territory = "COLONY TERMS"
	titles.biosphere = "PLANET ECOSYSTEM"
	var title: Label = _label(titles.get(kind,"EXPEDITION"),12 if instrument else 22,Color("343b31") if instrument else Instruments.PAPER)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close: Button = _button("×",_escape_menu,header,"ui_close")
	if instrument:
		close.custom_minimum_size = Vector2(28,24)
		header.add_theme_constant_override("separation",10)
		for state: String in ["normal","hover","pressed","disabled","focus"]:
			var box := StyleBoxFlat.new()
			box.bg_color = Color("2e3a3c") if state == "hover" else Color("1a2224") if state == "pressed" else Color("20292b")
			box.border_color = Color("728688") if state == "hover" else Color("435153")
			box.border_width_left = 1; box.border_width_right = 1
			box.border_width_top = 1; box.border_width_bottom = 1
			box.corner_radius_top_left = 3; box.corner_radius_top_right = 3
			box.corner_radius_bottom_left = 3; box.corner_radius_bottom_right = 3
			close.add_theme_stylebox_override(state,box)
		close.add_theme_color_override("font_color",Color("dedad0"))
		close.add_theme_color_override("font_hover_color",Color.WHITE)
	else: popup_body.add_child(_label("INSPECTION PAUSED  ·  Esc to close",12,Instruments.GOLD))
	if kind == "menu":
		_button("Resume game",_close_popup,popup_body)
		_button("Save game",_save,popup_body)
		_button("Load game",func() -> void: _load(); _close_popup(),popup_body)
		_button("Chronicle",_menu_page.bind("journal"),popup_body)
		if campaign != null: _button("Badges",_menu_page.bind("badges"),popup_body)
		_button("Controls",_menu_page.bind("controls"),popup_body)
		_button("Audio settings",_menu_page.bind("audio"),popup_body)
		_button("Return to title",_exit_encounter,popup_body)
	elif kind == "territory" and territory_panel != null:
		territory_panel.build()
	elif kind == "conflict" and conflict_view != null:
		conflict_view.build_panel()
	elif kind == "signals" and signal_view != null:
		signal_view.build_panel()
	elif kind == "freight" and campaign != null:
		var panel := preload("res://scripts/freight_panel.gd").new()
		panel.campaign = campaign
		panel.source = selected_colony
		panel.locked = paused
		panel.committed.connect(func() -> void: audio.play("ui_confirm"); _save(false); _refresh_ui())
		popup_body.add_child(panel)
	elif kind == "cargo":
		_build_cargo_panel()
	elif kind == "biosphere" and biosphere_view != null:
		biosphere_view.build_ecosystem()
	elif kind == "systems":
		_build_systems_panel()
	elif kind == "service":
		_build_service_panel()
	elif kind == "badges" and campaign != null:
		_build_badges_panel()
	elif kind == "fleet" and campaign != null:
		_build_fleet_panel()
	elif kind == "colonies" and campaign != null:
		_build_colonies_panel()
	elif kind == "audio":
		for channel: String in ["sfx","music","voice"]:
			popup_body.add_child(_label({"sfx":"Effects and interface","music":"Music","voice":"Guide voice"}[channel],17))
			var slider := HSlider.new()
			slider.min_value = 0
			slider.max_value = 100
			slider.step = 1
			slider.value = float(audio.mix[channel])*100
			slider.custom_minimum_size = Vector2(460,30)
			slider.value_changed.connect(func(value: float) -> void: audio.set_volume(channel,value/100))
			slider.drag_ended.connect(func(_changed: bool) -> void: audio.save_settings(); audio.play("ui_confirm"))
			popup_body.add_child(slider)
		_button("Preview tools",_preview_tools,popup_body)
		var copy: Label = _label("Guide captions are available. Recorded guide voice is not installed. Effects and music have independent volume controls.",14,Color("a2bacb"))
		copy.custom_minimum_size.x = 460
		copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		popup_body.add_child(copy)
	elif kind == "controls":
		flight_rebinding_ui_reset()
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(470,440)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		popup_body.add_child(scroll)
		var content := VBoxContainer.new()
		content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content.add_theme_constant_override("separation",7)
		scroll.add_child(content)
		var copy: Label = _label("Click terrain: fly there\nClick subject: approach and use selected tool\nClick planet in orbit: approach and descend\nSelect Weapon, then click custodian: approach and fire\nClick wreck or Salvage: approach and recover pulse ward\n\nG: galaxy · M: planet overview\nWheel: camera zoom · Ctrl + wheel: altitude\nPull back past the surface limit to ascend\nScroll in during ascent to cancel; zoom toward the planet to land\nIn orbit, Descend begins approach; scroll out or Stop cancels\nRight drag: rotate camera\nTab / Shift-Tab: browse tool categories\n1–9: visible tool slots · Ctrl + 1–9: second row\nY: communicate · I: inventory · K: equipment\nF: optional tool hold\nSpace: pause · F5: save · F9: load\n\nMouse buttons follow Windows primary-button settings. Flight buttons also support mouse-only play.",15)
		copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		copy.custom_minimum_size.x = 450
		content.add_child(copy)
		content.add_child(_label("FLIGHT KEYS  ·  Add a key; built-in alternatives stay active",13,Color("a2bacb")))
		for action: String in FlightControls.BINDINGS:
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation",8)
			content.add_child(row)
			var binding_label: Label = _label("%s  ·  %s" % [_flight_action_name(action),flight_input_settings.binding_text(action)],13)
			binding_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			binding_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			row.add_child(binding_label)
			flight_binding_labels[action] = binding_label
			var bind_button := _button("Set key",_start_flight_rebind.bind(action),row,"")
			bind_button.custom_minimum_size = Vector2(110,30)
			flight_rebind_buttons[action] = bind_button
		flight_rebind_status = _label("",13,Color("d9bc85"))
		flight_rebind_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(flight_rebind_status)
		_button("Reset custom flight keys",_reset_flight_rebinds,content)
		_button("Audio settings",_show_popup.bind("audio"),popup_body)
	elif kind == "journal":
		if campaign != null:
			_build_chronicle_panel()
			return
		if campaign != null:
			var ledger: Dictionary = campaign.sector.state.get("ledger",{})
			popup_body.add_child(_label("Colony day %d · treasury %d Marks\nLatest day: tax %.1f · upkeep %.1f · exports %.1f" % [campaign.sector.state.tick,model.marks,ledger.get("tax",0),ledger.get("upkeep",0),ledger.get("exports",0)],14,Instruments.GOLD))
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(450,400)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		popup_body.add_child(scroll)
		var entries := VBoxContainer.new()
		entries.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entries.add_theme_constant_override("separation",16)
		scroll.add_child(entries)
		for entry: Dictionary in model.state.history:
			var text: Label = _label("%02d:%02d  %s" % [int(entry.time)/60,int(entry.time)%60,entry.text],16)
			text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			entries.add_child(text)
		if model.state.history.is_empty(): entries.add_child(_label("Your first discovery will appear here.",16))
	elif kind == "contact" and campaign != null:
		_build_contact_panel()
	else:
		_button("Local ship services",func() -> void: popup.hide(); _approach_service("orbit_tender" if model.state.flight_mode == "orbit" else "basin_port"),popup_body)
		var portrait := TextureRect.new()
		portrait.texture = load("res://assets/advisors/finance-v1.png")
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.custom_minimum_size = Vector2(450,180)
		popup_body.add_child(portrait)
		var copy: Label = _label("“Leave the wild pods for those hungry little bells. Grow your own, and the nursery will buy.”\n\n18 Marks per cultivated pod · %d of 6 still wanted.\nBed output: 1 / 12 seconds; storage: 8.\nStanding order: 1 / 12 seconds when available, with 1 pod kept locally. No freight fee in this isolated trial." % model.state.buyer_remaining,16)
		copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		popup_body.add_child(copy)
		_button("Sell one cultivated pod",func() -> void: _trade(false),popup_body)
		_button("Stop recurring deliveries" if model.state.route else "Agree recurring deliveries",func() -> void: _trade(true),popup_body)
	if instrument:
		preload("res://scripts/communicator_style.gd").apply(popup_body)
		title.add_theme_color_override("font_color",Color("343b31"))
	_sync_communicator_shell()

func _sync_communicator_shell() -> void:
	if communicator_shell == null or popup == null: return
	var show_shell: bool = popup.visible and popup_kind in ["contact","service"] and campaign != null
	communicator_shell.visible = show_shell
	communicator_shell.position = popup.position
	communicator_shell.size = popup.size
	if contact_status_pod != null:
		contact_status_pod.visible = show_shell
		if show_shell and campaign != null:
			contact_status_pod.update_status(campaign.field.state.hull, campaign.field.max_capacity("hull"), campaign.field.state.energy, campaign.field.max_capacity("energy"), campaign.field.marks)

func _inspection_open() -> bool:
	return popup.visible or (planet_map != null and planet_map.visible) or (sector_map != null and sector_map.visible) or (system_map != null and system_map.visible)

func _toggle_planet_map() -> void:
	if campaign != null and campaign.traveling(): return
	if sector_map != null: sector_map.hide()
	if system_map != null: system_map.hide()
	if planet_map.visible:
		planet_map.hide()
		audio.play("ui_close")
		return
	_cancel_orders(true)
	popup.hide()
	var location: Vector3 = Geography.site_direction(model.state.planet_id)
	if model.state.flight_mode == "orbit":
		location = orbit.planet.basis.inverse()*(ship.position-orbit.planet.position)
	planet_map.present(model.state,location,paused,model.survey_reason())
	if campaign != null and model.state.survey_ticks >= model.definition().survey_seconds:
		var conditions: Dictionary = campaign.climate.world(model.state.planet_id)
		planet_map.report.text += "\nT%d climate · temperature %.0f · atmosphere %.0f" % [Climate.score(conditions),conditions.temperature,conditions.atmosphere]
		if campaign.climate.state.worlds.has(model.state.planet_id): planet_map.report.text += "\nEcosystem growth capacity %d residents. Plant-complete tiers resist climate drift." % campaign.climate.effects(model.state.planet_id).population_cap

func _map_travel(site_id: String) -> void:
	if model.definition().sites.is_empty() or site_id != model.definition().sites[0].id or paused: return
	planet_map.hide()
	if model.state.flight_mode == "orbit": _begin_landing()
	else: _navigate(Vector3(0,8,12))

func _map_survey() -> void:
	if paused: return
	var reason: String = model.start_survey()
	if not reason.is_empty(): _toast(reason); audio.play("error"); return
	planet_map.hide()
	_toast("Orbital survey underway · 12 seconds")
	audio.play("target_lock")

func _toggle_drawer(kind: String) -> void:
	if popup.visible and popup_kind == kind:
		popup.visible = false
		audio.play("ui_close")
	else:
		audio.play("ui_open")
		_show_popup(kind)

func _panel_copy(text: String, tint: Color = Instruments.MUTED) -> Label:
	var copy: Label = _label(text,15,tint)
	copy.custom_minimum_size.x = 460
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	popup_body.add_child(copy)
	return copy

func _cargo_tab(location: String) -> void:
	cargo_location = location
	_show_popup("cargo")

func _build_cargo_panel() -> void:
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation",8)
	popup_body.add_child(tabs)
	for location: String in (["ship","specimens","surface"] if campaign != null else ["ship","surface"]):
		var tab: Button = _button("Onboard" if location == "ship" else "Specimens" if location == "specimens" else "Surface store",_cargo_tab.bind(location),tabs)
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		Instruments.instrument(tab,"cargo",Instruments.CARGO,cargo_location == location)
	if cargo_location == "specimens" and biosphere_view != null:
		biosphere_view.build_inventory(); return
	var onboard: bool = cargo_location == "ship"
	if onboard and campaign != null:
		_panel_copy("TERRAFORMING LOCKER · %d / 6" % campaign.climate.units(),Instruments.GOLD)
		for id: String in campaign.climate.state.charges:
			var count: int = campaign.climate.state.charges[id]
			if count == 0: continue
			var item: Button = _button("%s × %d" % [Climate.data().tools[id].name,count],func() -> void: _close_popup(); _select_climate(id),popup_body)
			item.icon = Instruments.icon(id); item.add_theme_constant_override("icon_max_width",32)
			item.tooltip_text = "Select this owned unit, then click the planet or terrain to deploy."
		_panel_copy("CARGO HOLD   %d / %d" % [campaign.commerce.used_space(campaign),campaign.commerce.capacity()],Instruments.CARGO)
		if campaign.colonies.reserved_space() > 0:
			_panel_copy("COLONY KIT × 1 · occupies four cargo spaces",Instruments.GOLD)
			var deploy: Button = _button("Deploy colony kit",_select_colony_kit,popup_body)
			deploy.icon = Instruments.icon("cargo")
			deploy.tooltip_text = campaign.colonies.deployment_reason(campaign)
			deploy.disabled = paused or not deploy.tooltip_text.is_empty()
		for lot: Dictionary in campaign.commerce.state.cargo:
			_panel_copy("%s × %d\nOrigin: %s" % [campaign.commerce.catalog.goods[lot.item].name,lot.quantity,Geography.definition(lot.origin).name],Instruments.PAPER)
		if campaign.commerce.used_space(campaign) == 0: _panel_copy("Empty. Load colony surplus or purchase goods at a dock.")
		_panel_copy("Specimens and ship supplies use separate compartments.")
	if onboard: _build_supply_inventory()
	if onboard and biosphere_view != null:
		_button("Specimens · %d / 12" % campaign.biosphere.used(),_cargo_tab.bind("specimens"),popup_body).icon = Instruments.icon("seed")
		if model.state.samples > 0: _panel_copy("Local nursery pods: %d / 2. Stored separately from expedition specimens." % model.state.samples)
		return
	var amount: int = model.state.samples if onboard else model.state.produce
	var capacity: int = 2 if onboard else 8
	cargo_quantity = _label("%d / %d  %s" % [amount,capacity,"SAMPLE CRADLES" if onboard else "SURFACE STORAGE UNITS"],17,Instruments.CARGO)
	popup_body.add_child(cargo_quantity)
	var slots := GridContainer.new()
	slots.columns = 4
	slots.add_theme_constant_override("h_separation",8)
	slots.add_theme_constant_override("v_separation",8)
	popup_body.add_child(slots)
	for index: int in range(capacity):
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(110,76)
		slot.add_theme_stylebox_override("panel",Instruments.box(Instruments.CARGO,index < amount))
		slots.add_child(slot)
		if index < amount:
			var pod := TextureRect.new()
			pod.texture = Instruments.icon("pod")
			pod.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pod.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			pod.modulate = Instruments.CARGO if onboard else COLORS[0]
			pod.tooltip_text = "Living wild seed · onboard" if onboard else "Cultivated pod · local surface stock"
			slot.add_child(pod)
		else:
			var empty: Label = _label("EMPTY",11,Instruments.MUTED)
			empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			slot.add_child(empty)
	popup_body.add_child(_label("LANTERN POD  /  "+("LIVING SPECIMEN" if onboard else "CULTIVATED PRODUCE"),16,COLORS[0]))
	if onboard:
		_panel_copy("Living lantern-pod specimens. Each living seed occupies one cradle. Surface harvests are stored separately.")
		var equip: Button = _button("Equip deployer",_equip_from_panel.bind("seed"),popup_body,"")
		equip.disabled = amount == 0
		equip.tooltip_text = "Collect a scanned wild pod first." if amount == 0 else Equipment.hint("seed")
		Instruments.instrument(equip,"seed",COLORS[3])
		_panel_copy("No specimens aboard. Scan a pod, then use the tractor." if amount == 0 else "Deployment needs a prepared bed. Selecting the tool does not consume the specimen.")
	else:
		_panel_copy("Location: this planet’s surface bed. This stock is not aboard your ship. Mature beds produce one unit every 12 seconds, up to eight stored units.")
		_panel_copy("Nursery demand: %d remaining · 18 Marks per unit\nStanding deliveries: %s" % [model.state.buyer_remaining,"active; one unit reserved" if model.state.route else "off"])
		Instruments.instrument(_button("Open nursery agreement",_show_popup.bind("nursery"),popup_body,"ui_open"),"comms",Instruments.COMMS)

func _build_supply_inventory() -> void:
	_panel_copy("SHIP SUPPLIES · energy %d / 3 · repair %d / 3" % [model.state.energy_packs,model.repair_pack_count()],Instruments.GOLD)
	for id: String in ["pack","repair_pack","mega_repair_pack"]:
		var entry: Dictionary = hud.Palette.entry(id)
		var count: int = model.state.energy_packs if id == "pack" else model.state.repair_packs[id]
		var reason: String = hud.Palette.unavailable(id,model)
		var item: Button = _button("%s × %d" % [entry.title,count],_inventory_action.bind(id,"cargo"),popup_body)
		item.icon = Instruments.icon(entry.icon)
		item.add_theme_constant_override("icon_max_width",38)
		item.set_meta("supply_id",id)
		item.tooltip_text = Instruments.tooltip(entry.hint+("\n"+reason if not reason.is_empty() else ""))
		item.disabled = paused or not reason.is_empty()

func _inspect_system(id: String) -> void:
	inspected_system = id
	_show_popup("systems")

func _build_systems_panel() -> void:
	if campaign != null:
		_panel_copy("CARGO  %d units · DRIVE  %d pc" % [campaign.commerce.capacity(),campaign.commerce.drive_range()],Instruments.CARGO)
		_button("Badges & upgrade eligibility",_show_popup.bind("badges"),popup_body)
	popup_body.add_child(_label("REACTOR  ·  %d / %d ENERGY" % [model.state.energy,model.max_capacity("energy")],17,Instruments.GOLD))
	system_energy = ProgressBar.new()
	system_energy.custom_minimum_size.y = 10
	system_energy.show_percentage = false
	system_energy.max_value = model.max_capacity("energy")
	system_energy.value = model.state.energy
	Instruments.meter(system_energy,Instruments.GOLD)
	popup_body.add_child(system_energy)
	_panel_copy("Energy does not regenerate. Carry reserve packs or dock for recharge. Homeworld recharge is free; other worlds charge local rates.")
	var modules := GridContainer.new()
	modules.columns = 2
	modules.add_theme_constant_override("h_separation",8)
	modules.add_theme_constant_override("v_separation",8)
	system_buttons.clear()
	_panel_copy("HULL  %d / %d · field repair restores 35 for 30 reactor energy outside a hazard. Repair cooldown: 20 s." % [model.state.hull,model.max_capacity("hull")])
	for id: String in Model.Support.catalog:
		var entry: Dictionary = hud.Palette.entry(id)
		var owned: bool = id in model.installed_upgrades
		var support_button: Button = _button(entry.title+(" · "+hud.Palette.count(id,model.state) if owned else " · purchase at a dock"),_inventory_action.bind(id,"systems"),popup_body)
		Instruments.instrument(support_button,id,entry.tint)
		support_button.set_meta("support_id",id)
		support_button.disabled = paused or not Model.Support.reason(model,id).is_empty()
		support_button.tooltip_text = Instruments.tooltip(entry.hint+"\n"+Model.Support.reason(model,id))
	_panel_copy("RECOVERED PULSE WARD (phase shroud)  %s · absorbs most pulse damage, drains 2 energy/s." % ("ACTIVE" if model.state.shroud_on else "INSTALLED" if model.state.shroud_unlocked else "NOT ACQUIRED"))
	if model.state.shroud_unlocked:
		var shield: Button = _button("Deactivate pulse ward" if model.state.shroud_on else "Activate pulse ward · 2 energy / second",_inventory_action.bind("shroud","systems"),popup_body)
		shield.disabled = paused or model.state.flight_mode != "orbit" or (not model.state.shroud_on and model.state.energy < 2)
	var repair: Button = _button("Field repair · 30 energy",_inventory_action.bind("repair","systems"),popup_body)
	repair.disabled = paused or not model.repair_reason(_wreck_distance()).is_empty()
	repair.tooltip_text = model.repair_reason(_wreck_distance())
	_panel_copy("ARC LANCE  installed · %d damage · 24 m · 10 energy/shot · 2 s recovery. Select it, then click a hostile ship." % model.lance_damage())
	popup_body.add_child(modules)
	for i: int in range(TOOLS.size()):
		var id: String = TOOLS[i]
		var button: Button = _button(Equipment.title(id),_inspect_system.bind(id),modules)
		button.custom_minimum_size = Vector2(232,62)
		button.add_theme_font_size_override("font_size",14)
		button.tooltip_text = Equipment.hint(id,model.installed_upgrades)
		Instruments.instrument(button,id,COLORS[i],inspected_system == id)
		system_buttons[id] = button
	var index: int = TOOLS.find(inspected_system)
	popup_body.add_child(_label(Equipment.title(inspected_system).to_upper(),18,COLORS[index]))
	_panel_copy(Equipment.hint(inspected_system),Instruments.PAPER)
	_panel_copy(str(Equipment.value(inspected_system,"acquisition")))
	_panel_copy("Cycle: %.1f seconds · installed\n%s" % [Equipment.seconds(inspected_system),"Currently selected in your hotbar." if tool == inspected_system else "Available to select in your hotbar."])
	var select: Button = _button("Select tool & return to flight",_equip_from_panel.bind(inspected_system),popup_body,"")
	Instruments.instrument(select,inspected_system,COLORS[index],true)

func _equip_from_panel(id: String) -> void:
	if id not in TOOLS or paused or model.state.flight_mode != "surface": return
	if id == "seed" and campaign != null: _cargo_tab("specimens"); return
	popup.visible = false
	_select_tool(id)
	_toast(Equipment.title(id)+" selected")

func _preview_tools() -> void:
	if previewing_audio: return
	previewing_audio = true
	for item: String in TOOLS:
		audio.play("equip_collect" if item == "mine" else "equip_"+item)
		await get_tree().create_timer(0.45).timeout
	previewing_audio = false

func _trade(recurring: bool) -> void:
	var error: String = model.set_route(not model.state.route) if recurring else model.sell()
	_toast(error if not error.is_empty() else ("Delivery agreement updated." if recurring else "Sold one pod for 18 Marks."))
	audio.play("error" if not error.is_empty() else "arrival")
	_show_popup("contact")

func _campaign_path(automatic: bool) -> String:
	return save_path.get_basename()+ ("_campaign_auto.fw" if automatic else "_campaign.fw")

func _save(notify: bool = true) -> void:
	if persistence_blocked:
		if notify: _toast("Saving disabled: the existing campaign could not be restored.")
		return
	model.state.position = [ship.position.x,ship.position.y,ship.position.z]
	if model.state.flight_mode == "surface": _sync_surface_pose()
	model.state.yaw = yaw
	var error: Error = campaign.save_to(_campaign_path(not notify)) if campaign != null else model.save_to(save_path if notify else save_path.replace(".json","_auto.json"))
	if notify: audio.play("saved" if error == OK else "error")
	if notify or error != OK: _toast("Expedition saved." if error == OK else "Could not save: "+error_string(error))

func _load() -> void:
	var error: Error = campaign.load_from(_campaign_path(false)) if campaign != null else model.load_from(save_path)
	if error == OK:
		persistence_blocked = false
		if model.state.planet_id != rendered_planet:
			call_deferred("_reload_destination")
			return
		_cancel_orders(true)
		_restore_ship()
		_apply_flight_mode()
		progress = 0
		held = false
		tick_clock = 0
		if campaign != null:
			sector_map.hide(); system_map.hide()
			if campaign.traveling(): _show_travel_view()
		if popup.visible: _show_popup(popup_kind)
		if planet_map.visible:
			planet_map.hide()
			_toggle_planet_map()
	_toast("Expedition restored." if error == OK else "Could not load field progress: "+error_string(error))
	audio.play("saved" if error == OK else "error")

func _restore_ship() -> void:
	var at: Array = model.state.position
	if model.state.flight_mode == "surface":
		var surface_at: Array = model.state.surface_position
		var offset: Vector2 = Geography.surface_local_position(world_definition,_saved_surface_up())
		ship.position = Vector3(offset.x,float(surface_at[1]),offset.y)
		ship.position.y = clampf(ship.position.y,terrain_height(ship.position.x,ship.position.z)+2.7,57)
		_refresh_surface_geography()
	else:
		ship.position = Vector3(at[0],at[1],at[2])
	yaw = model.state.yaw
	camera_focus = ship.position
	velocity = Vector3.ZERO

func _exit_encounter() -> void:
	audio.save_settings()
	_save(false)
	if leave.get_connections().is_empty(): get_tree().quit()
	else: leave.emit()

func _capture_flight(delta: float) -> void:
	capture_clock += delta
	if capture_clock < 2: return
	capture_clock = 0
	var path: String = ProjectSettings.globalize_path("user://flight_captures")
	DirAccess.make_dir_recursive_absolute(path)
	get_viewport().get_texture().get_image().save_png(path.path_join("flight_%d.png" % capture_step))
	capture_step += 1
	if capture_step == 1: _departure()
	elif capture_step == 5: _begin_landing()
	elif capture_step == 7: _show_popup("audio")
	elif capture_step == 8: get_tree().quit()

func _capture(delta: float) -> void:
	capture_clock += delta
	if capture_clock < 2: return
	capture_clock = 0
	var capture_dir: String = ProjectSettings.globalize_path("user://field_captures")
	DirAccess.make_dir_recursive_absolute(capture_dir)
	get_viewport().get_texture().get_image().save_png(capture_dir.path_join("field_%d.png" % capture_step))
	capture_step += 1
	if capture_step == 1:
		model.act("scan","pod",4)
		model.act("collect","pod",4)
		model.act("scan","bed",4)
		model.act("warm","bed",4)
		model.act("seed","bed",4)
		for i: int in range(21): model.tick()
		ship.position = Vector3(4,5,8)
		selected = "bed"
	elif capture_step == 2: _show_popup("contact")
	elif capture_step == 3:
		popup.visible = false
		ship.position = Vector3(-7,6,1)
		distance = 14
		pitch = 0.35
		selected = "grazer"
	else:
		var sorted: Array[float] = frame_samples.duplicate()
		sorted.sort()
		print("Field rendered sample: p50=%.2f ms p95=%.2f ms; draw calls=%d; triangles=%d" % [sorted[sorted.size()/2],sorted[int(sorted.size()*0.95)],Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
		get_tree().quit()

func _build_service_ports() -> void:
	for id: String in model.local_services():
		var port: Dictionary = model.local_services()[id]
		var parent: Node3D = orbit if port.mode == "orbit" else surface_root
		var at: Vector3 = Model.service_position(id)
		var pad := MeshInstance3D.new()
		var mesh := TorusMesh.new()
		mesh.inner_radius = 3.3
		mesh.outer_radius = 3.7
		mesh.rings = 48
		mesh.ring_segments = 8
		pad.mesh = mesh
		pad.position = at-Vector3(0,2.5,0)
		var pad_mat := StandardMaterial3D.new()
		pad_mat.albedo_color = Color("82d9c0", 0.4)
		pad_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pad_mat.emission_enabled = true
		pad_mat.emission = Color("82d9c0") * 0.35
		pad.material_override = pad_mat
		parent.add_child(pad)
		var label := Label3D.new()
		label.text = "HOME PORT" if model.state.planet_id == model.state.homeworld_id and id == "basin_port" else "SHIP SERVICES"
		label.position = at+Vector3(0,2,0)
		label.font_size = 18
		label.pixel_size = 0.012
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.modulate = Color("a2dec5", 0.75)
		parent.add_child(label)

func _approach_service(id: String) -> void:
	if paused or _inspection_open() or not model.local_services().has(id): return
	if model.local_services()[id].mode != model.state.flight_mode: return
	selected_service = id
	if ship.position.distance_to(Model.service_position(id)) <= float(model.local_services()[id].reach):
		_show_popup("service")
		return
	var route: Array[Vector3] = [Model.service_position(id)]
	if model.state.flight_mode == "orbit": route = FlightControls.landing_route(ship.position,Model.service_position(id),orbit.planet.position)
	_navigate(route.pop_front())
	service_waypoints = route
	service_order = id
	_toast("Approaching "+str(model.local_services()[id].name))

func _build_service_panel() -> void:
	var representative: String = _service_representative()
	if representative.is_empty():
		_build_service_contents()
		return
	contacted_faction = representative
	var start: int = popup_body.get_child_count()
	_build_service_contents()
	var contents: Array[Node] = popup_body.get_children().slice(start)
	var row := HBoxContainer.new()
	row.name = "ServiceContents"
	row.add_theme_constant_override("separation",18)
	var stage := VBoxContainer.new()
	stage.custom_minimum_size.x = 340
	row.add_child(stage)
	if not is_instance_valid(contact_portrait):
		contact_portrait = AlienPortrait.new()
		contact_portrait.faction_id = representative
		stage.add_child(contact_portrait)
	else: contact_portrait.reparent(stage)
	_frame_portrait(stage)
	contact_portrait.show()
	var identity: Label = _label(campaign.diplomacy.profiles[representative].speaker,20,Instruments.PAPER)
	stage.add_child(identity)
	_button("Communications",_show_popup.bind("contact"),stage)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(490,470)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(scroll)
	var goods := VBoxContainer.new()
	goods.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	goods.add_theme_constant_override("separation",8)
	scroll.add_child(goods)
	for child: Node in contents: child.reparent(goods)
	popup_body.add_child(row)
	var footer := HBoxContainer.new()
	popup_body.add_child(footer)
	if dock_page == "upgrades": _button("Badges",_show_popup.bind("badges"),footer)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)
	var undock: Button = _button("Undock",_close_popup,footer)
	undock.custom_minimum_size = Vector2(140,32)

func _service_representative() -> String:
	if campaign == null or not model.local_services().has(selected_service): return ""
	var owner: String = campaign.owner_of(model.state.planet_id)
	if owner.is_empty() or not campaign.diplomacy.profiles.has(owner): return ""
	return owner if campaign.sector.faction_by_id(owner).get("contacted",false) else ""

func _frame_portrait(stage: Control, height: float = 370) -> void:
	var chamber := preload("res://scripts/communicator_chamber.gd").new()
	chamber.custom_minimum_size = Vector2(340,height)
	stage.add_child(chamber)
	stage.move_child(chamber,0)
	contact_portrait.reparent(chamber)
	contact_portrait.custom_minimum_size = Vector2(316,height-24)

func _shop_tab(button: Button, selected: bool) -> void:
	button.disabled = selected
	button.set_meta("instrument_selected",selected)
	if selected:
		button.add_theme_stylebox_override("disabled",Instruments.box(Instruments.PAPER,true))
		button.add_theme_color_override("font_disabled_color",Instruments.PAPER)
		button.tooltip_text = "Current section: "+button.text

func _build_service_contents() -> void:
	if not model.local_services().has(selected_service):
		_panel_copy("No dock services are available at this location.",Instruments.PAPER)
		return
	var port: Dictionary = model.local_services()[selected_service]
	_panel_copy(port.name,Instruments.PAPER)
	if campaign != null:
		var balance := HBoxContainer.new()
		balance.add_theme_constant_override("separation",22)
		balance.add_child(preload("res://scripts/communicator_style.gd").money(int(model.marks),18))
		balance.add_child(_label("CARGO %d / %d" % [campaign.commerce.used_space(campaign),campaign.commerce.capacity()],15,Instruments.MUTED))
		popup_body.add_child(balance)
		var tabs := HFlowContainer.new()
		popup_body.add_child(tabs)
		for page: String in ["market","upgrades","energy","warehouse","fleet","climate"]:
			var tab: Button = _button("Supplies" if page == "energy" else page.capitalize(),func() -> void: dock_page = page; _show_popup("service"),tabs)
			_shop_tab(tab,dock_page == page)
		if dock_page == "market": _build_market_panel(); return
		if dock_page == "upgrades": _build_upgrade_shop(); return
		if dock_page == "warehouse": _build_warehouse_panel(); return
		if dock_page == "fleet": _build_fleet_panel(); return
		if dock_page == "climate": _build_climate_shop(); return
	_panel_copy("ENERGY  %d / %d · PACKS  %d / 3" % [model.state.energy,model.max_capacity("energy"),model.state.energy_packs],Instruments.GOLD)
	var price: int = model.recharge_price(selected_service)
	var charge_label: String = "Recharge to full · FREE / HOMEWORLD" if model.state.planet_id == model.state.homeworld_id else "Recharge to full · %d Marks" % price
	if model.state.energy >= model.max_capacity("energy"): charge_label = "Energy full"
	var charge: Button = _button(charge_label,_service_action.bind(false),popup_body)
	var reason: String = _dock_service_reason("recharge")
	charge.disabled = paused or not reason.is_empty()
	charge.tooltip_text = reason
	var pack: Button = _button("Buy energy pack · %d Marks" % int(port.pack_price),_service_action.bind(true),popup_body)
	pack.icon = Instruments.icon("energy_pack")
	pack.add_theme_constant_override("icon_max_width",38)
	reason = _dock_service_reason("pack")
	pack.disabled = paused or not reason.is_empty()
	pack.tooltip_text = reason
	_panel_copy("+50 energy · %d in stock · excess energy is lost." % model.state.service_stock[selected_service])
	_panel_copy("HULL  %d / %d · DOCK REPAIR" % [int(model.state.hull),int(model.max_capacity("hull"))],Color("a5e4c2"))
	var missing_hull: int = int(ceil(maxf(0.0,model.max_capacity("hull")-float(model.state.hull))))
	var repair_cost: int = model.repair_hull_price(selected_service)
	var repair_label: String = "Repair hull to full (+%d) · %d Marks" % [missing_hull,repair_cost] if missing_hull > 0 else "Hull sound"
	var repair_btn: Button = _button(repair_label,_dock_repair_action,popup_body)
	repair_btn.set_meta("dock_action","repair")
	var repair_reason: String = _dock_service_reason("repair")
	repair_btn.disabled = paused or not repair_reason.is_empty()
	repair_btn.tooltip_text = Instruments.tooltip("Restore missing hull to full capacity at dock facility."+("\n"+repair_reason if not repair_reason.is_empty() else ""))
	if not repair_reason.is_empty() and missing_hull > 0: _panel_copy(repair_reason)
	_panel_copy("REPAIR LOCKER  %d / 3 · shared 20 s repair cooldown" % model.repair_pack_count(),Color("a5e4c2"))
	for id: String in Model.repair_items():
		var item: Dictionary = Model.repair_items()[id]
		var button: Button = _button("%s · %d Marks" % [item.name,port.repair_prices[id]],_repair_purchase.bind(id),popup_body)
		button.icon = Instruments.icon(id)
		button.add_theme_constant_override("icon_max_width",38)
		button.set_meta("purchase_supply",id)
		var blocked: String = _dock_service_reason(id)
		button.disabled = paused or not blocked.is_empty()
		button.tooltip_text = Instruments.tooltip(item.description+("\n"+blocked if not blocked.is_empty() else ""))
		if not blocked.is_empty(): _panel_copy(blocked)
		_panel_copy("%d in stock · %s" % [model.state.repair_stock[selected_service][id],"Restores up to 75 hull." if id == "repair_pack" else "Restores all missing hull."])
	_button("Undock",func() -> void: popup.hide(); audio.play("ui_close"),popup_body)

func _dock_service_reason(action: String) -> String:
	if campaign != null: return campaign.service_reason(selected_service,ship.position,action)
	if action == "repair": return model.dock_repair_reason(selected_service,ship.position)
	return model.service_reason(selected_service,ship.position,action == "pack") if action in ["recharge","pack"] else model.repair_purchase_reason(selected_service,ship.position,action)

func _dock_repair_action() -> void:
	if paused: return
	var error: String = campaign.purchase_service(selected_service,ship.position,"repair") if campaign != null else model.dock_repair(selected_service,ship.position)
	_toast(error if not error.is_empty() else "Hull repaired to full capacity · %d hull" % int(model.max_capacity("hull")))
	audio.play("error" if not error.is_empty() else "cargo")
	if error.is_empty(): _save(false)
	_show_popup("service")

func _repair_purchase(item: String) -> void:
	if paused: return
	var error: String = campaign.purchase_service(selected_service,ship.position,item) if campaign != null else model.buy_repair_pack(selected_service,ship.position,item)
	_toast(error if not error.is_empty() else "Loaded "+str(Model.repair_items()[item].name))
	audio.play("error" if not error.is_empty() else "cargo")
	if error.is_empty(): _save(false)
	_show_popup("service")

func _service_action(purchase_pack: bool) -> void:
	if paused: return
	var error: String
	if campaign != null: error = campaign.purchase_service(selected_service,ship.position,"pack" if purchase_pack else "recharge")
	else: error = model.buy_energy_pack(selected_service,ship.position) if purchase_pack else model.recharge(selected_service,ship.position)
	_toast(error if not error.is_empty() else ("Reserve energy pack loaded" if purchase_pack else "Recharge complete · %d energy" % model.max_capacity("energy")))
	audio.play("error" if not error.is_empty() else "cargo")
	if error.is_empty(): _save(false)
	_show_popup("service")

func _toggle_sector_map() -> void:
	if campaign == null: _toast("Galaxy navigation requires a flight campaign."); return
	if sector_map.visible:
		if not campaign.traveling(): sector_map.hide()
		return
	_cancel_orders(true)
	popup.hide()
	planet_map.hide()
	if system_map != null: system_map.hide()
	sector_map.present(campaign)
	audio.play("ui_open")
	_refresh_ui()

func _show_travel_view() -> void:
	if campaign.sector.state.flagship.destination == campaign.sector.state.flagship.system: _open_system_view(campaign.sector.state.flagship.system)
	else: _toggle_sector_map()

func _toggle_system_view() -> void:
	if campaign == null: _toast("System navigation requires a flight campaign."); return
	if system_map.visible:
		if not campaign.traveling(): _close_system_view()
		return
	_open_system_view(campaign.sector.state.flagship.system)

func _open_system_view(id: String) -> void:
	if campaign == null: return
	if not system_map.present(campaign,id): _toast("Visit or chart this system first."); return
	_cancel_orders(true); popup.hide(); planet_map.hide(); sector_map.hide()
	system_map.locked = paused; system_map.refresh(); audio.play("ui_open"); _refresh_ui()

func _close_system_view() -> void:
	if campaign != null and campaign.traveling(): return
	system_map.hide(); audio.play("ui_close"); _refresh_ui()

func _launch_journey(id: String) -> void:
	if popup.visible: return
	if paused: _toast("Resume flight before departing."); return
	model.state.position = [ship.position.x,ship.position.y,ship.position.z]
	var error: String = campaign.begin_travel(id)
	if not error.is_empty(): _toast(error); audio.play("error"); return
	_cancel_orders()
	sector_map.refresh()
	if system_map.visible: system_map.refresh()
	audio.play("departure")
	_save(false)

func _commerce_action(action: String, item: String = "") -> void:
	if paused or campaign == null: return
	var error: String = ""
	match action:
		"buy", "sell": error = campaign.commerce.transact(campaign,selected_service,ship.position,item,trade_amount,action == "buy")
		"export": error = campaign.commerce.export_alloy(campaign,selected_service,ship.position,trade_amount)
		"upgrade": error = campaign.commerce.buy_upgrade(campaign,selected_service,ship.position,item)
		"kit": error = campaign.colonies.buy_kit(campaign,selected_service,ship.position)
		"collect": error = campaign.colonies.collect(campaign,selected_service,ship.position,item,trade_amount)
	_toast(error if not error.is_empty() else "Cargo loaded" if action in ["export","kit","collect"] else "Upgrade installed" if action == "upgrade" else "Trade complete")
	audio.play("error" if not error.is_empty() else "cargo")
	if error.is_empty(): _save(false)
	_show_popup("service")
	if is_instance_valid(contact_portrait): contact_portrait.respond(error.is_empty())

func _build_market_panel() -> void:
	var commerce: RefCounted = campaign.commerce
	var planet: String = model.state.planet_id
	var amounts := HBoxContainer.new()
	popup_body.add_child(amounts)
	amounts.add_child(_label("Units per trade",15))
	for amount: int in [1,4,8]:
		var choice: Button = _button(str(amount),func() -> void: trade_amount = amount; _show_popup("service"),amounts)
		_shop_tab(choice,trade_amount == amount)
	if planet == "morrow":
		var export_button: Button = _button("Load %d alloy · %d colony materials" % [trade_amount,trade_amount*4],_commerce_action.bind("export"),popup_body)
		var blocked: String = commerce.export_reason(campaign,selected_service,ship.position,trade_amount)
		export_button.disabled = paused or not blocked.is_empty()
		export_button.tooltip_text = blocked if not blocked.is_empty() else "Draws from your real colony stock; preserves 80 materials for construction."
		_panel_copy("Colony stock: %d materials · reserve 80" % campaign.sector.state.colonies.s0p0.materials)
	var shop := preload("res://scripts/commodity_shop.gd").new()
	shop.selected_id = commodity_preview
	shop.amount = trade_amount
	shop.locked = paused
	for item: String in commerce.catalog.goods:
		var good: Dictionary = commerce.catalog.goods[item]
		var offer: Dictionary = commerce.market(planet)[item]
		shop.offers.append({"id":item,"title":good.name,"description":good.description,"aboard":commerce.quantity(item),"stock":offer.stock,"demand":offer.demand,"buy":commerce.price(planet,item,true,campaign),"sell":commerce.price(planet,item,false,campaign),"buy_reason":commerce.reason(campaign,selected_service,ship.position,item,trade_amount,true),"sell_reason":commerce.reason(campaign,selected_service,ship.position,item,trade_amount,false)})
	shop.selected.connect(func(id: String) -> void: commodity_preview = id)
	shop.trade_requested.connect(_commerce_action)
	popup_body.add_child(shop)
	if _service_representative().is_empty(): _button("Undock",_close_popup,popup_body)

func _upgrade_requirements(id: String) -> String:
	var alternatives: PackedStringArray = []
	for badge: String in campaign.commerce.catalog.upgrades[id].requires:
		alternatives.append("%s %d" % [campaign.commerce.catalog.badges[badge].name,campaign.commerce.catalog.upgrades[id].requires[badge]])
	var prior: String = campaign.commerce.catalog.upgrades[id].get("prior", "")
	if campaign.commerce.catalog.upgrades[id].has("rank"):
		alternatives.append(str(campaign.Recognition.catalog.rank_names[int(campaign.commerce.catalog.upgrades[id].rank)-1])+" rank")
	var badges: String = " or ".join(alternatives)
	return badges if prior.is_empty() else "(%s) + %s installed" % [badges,campaign.commerce.catalog.upgrades[prior].name]

func _build_upgrade_shop() -> void:
	var families := HBoxContainer.new()
	popup_body.add_child(families)
	for family: String in ["ship","hull","energy","support"]:
		var tab: Button = _button({"ship":"Equipment","hull":"Hull","energy":"Reactor","support":"Support"}[family],func() -> void: upgrade_family = family; _show_popup("service"),families)
		_shop_tab(tab,family == upgrade_family)
		if not tab.disabled: tab.tooltip_text = "Compare installed equipment and available upgrades."
	var shop := preload("res://scripts/upgrade_shop.gd").new()
	shop.locked = paused
	shop.selected_id = upgrade_preview
	if upgrade_family == "ship":
		shop.offers.append({"id":"colony_kit","title":"Colony landing kit","price":300,"flavor":"A shelter and landing gear, folded into one freight cradle.","description":"Carries a new colony in four cargo spaces. Deploy on a surveyed, unclaimed surface; construction takes 18 colony days.","requirements":"Purchase includes the construction materials and supplies.","reason":campaign.colonies.buy_reason(campaign,selected_service,ship.position),"owned":false,"action":"kit","icon":"badge_colonist"})
	for id: String in campaign.commerce.catalog.upgrades:
		var upgrade: Dictionary = campaign.commerce.catalog.upgrades[id]
		if upgrade.get("acquisition","") == "glassworks" and id not in campaign.commerce.state.upgrades: continue
		if upgrade.get("family","ship") != upgrade_family: continue
		var symbol: String = id
		if id.begins_with("hull_"): symbol = "defense"
		elif id.begins_with("energy_"): symbol = "energy"
		elif id.begins_with("drive"): symbol = "planet_map"
		elif id == "emitter": symbol = "lance"
		elif id == "hold": symbol = "cargo"
		shop.offers.append({"id":id,"title":upgrade.name,"price":upgrade.price,"flavor":upgrade.get("flavor",""),"description":upgrade.description,"requirements":"Requires "+_upgrade_requirements(id),"reason":campaign.commerce.upgrade_reason(campaign,selected_service,ship.position,id),"owned":id in campaign.commerce.state.upgrades,"action":"upgrade","icon":symbol})
	for i: int in range(shop.offers.size()):
		if shop.offers[i].id == upgrade_preview:
			var target: Dictionary = shop.offers[i]
			shop.offers.remove_at(i)
			shop.offers.push_front(target)
			break
	shop.selected.connect(func(id: String) -> void: upgrade_preview = id)
	shop.purchase_requested.connect(_commerce_action)
	popup_body.add_child(shop)
	if _service_representative().is_empty(): _button("Badges",_show_popup.bind("badges"),popup_body)

func _build_badges_panel() -> void:
	var panel := preload("res://scripts/badge_case.gd").new(); panel.campaign = campaign
	panel.pinned.connect(func() -> void: audio.play("ui_confirm"); _refresh_ui(); _save(false))
	panel.shop_requested.connect(func(id: String) -> void:
		upgrade_preview = id; upgrade_family = campaign.commerce.catalog.upgrades[id].get("family","ship")
		dock_page = "upgrades"; _show_popup("service"))
	popup_body.add_child(panel)

func _contact_select(id: String) -> void:
	if id != contacted_faction: _reset_contact_presentation()
	contacted_faction = id
	contact_page = "home"
	contact_reply = ""
	_show_popup("contact")

func _contact_action(action: String) -> void:
	if paused or campaign == null: return
	var error: String = campaign.diplomacy.act(campaign,contacted_faction,action)
	contact_accepted = error.is_empty()
	var profile: Dictionary = campaign.diplomacy.profiles[contacted_faction]
	contact_reply = str(profile.get(action,profile.accepted)) if contact_accepted else str(profile.declined)+" "+error
	audio.play("ui_confirm" if contact_accepted else "error")
	if contact_accepted: _save(false)
	_show_popup("contact")
	if is_instance_valid(contact_portrait): contact_portrait.respond(contact_accepted)
	_refresh_ui()

func _reset_contact_presentation() -> void:
	if is_instance_valid(contact_portrait): contact_portrait.queue_free()
	contact_portrait = null
	contact_reply = ""
	contact_greeting = ""
	if contact_page.is_empty(): contact_page = "home"

func _build_contact_panel() -> void:
	var start: int = popup_body.get_child_count()
	_build_contact_contents()
	if not is_instance_valid(contact_portrait): return
	var contents: Array[Node] = popup_body.get_children().slice(start)
	var introduction: Node = popup_body.get_node("ContactIntroduction")
	var dialogue: Node = introduction.get_child(1)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",18)
	var stage := VBoxContainer.new()
	stage.custom_minimum_size.x = 340
	row.add_child(stage)
	contact_portrait.reparent(stage)
	_frame_portrait(stage,350 if contact_page == "home" else 370)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation",8)
	stage.add_child(navigation)
	contents[0].reparent(navigation)
	var open_signals: int = campaign.signals.open_ids().size() if campaign != null else 0
	contents[0].visible = open_signals > 0
	contents[0].text = "Orbital signals · %d" % open_signals
	contents[0].custom_minimum_size.y = 30
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(490,400 if contact_page == "home" else 490)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	row.add_child(scroll)
	var choices := VBoxContainer.new()
	choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choices.add_theme_constant_override("separation",8)
	scroll.add_child(choices)
	for child: Node in contents:
		if child == contents[0]: continue
		if child == introduction:
			dialogue.reparent(choices)
			popup_body.remove_child(introduction); introduction.queue_free()
		else: child.reparent(choices)
	popup_body.add_child(row)
	var footer := HBoxContainer.new()
	popup_body.add_child(footer)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)
	var goodbye: Button = _button("Goodbye",_close_popup,footer)
	goodbye.custom_minimum_size = Vector2(140,32)

func _build_contact_contents() -> void:
	var signal_button: Button = _button("Orbital signals · %d open" % campaign.signals.open_ids().size(),_show_popup.bind("signals"),popup_body)
	Instruments.instrument(signal_button,"signal",Instruments.GOLD)
	signal_button.tooltip_text = "Optional encounters, active commitments and their outcomes"
	var known: Array = []
	for f: Dictionary in campaign.sector.state.factions:
		if f.get("contacted",false): known.append(f.id)
	var local: String = campaign.owner_of(model.state.planet_id)
	if contacted_faction not in known: contacted_faction = local if local in known else str(known[0]) if not known.is_empty() else ""
	var roster := HBoxContainer.new()
	roster.visible = known.size() > 1
	popup_body.add_child(roster)
	for id: String in known:
		var button: Button = _button(campaign.diplomacy.profiles[id].speaker,_contact_select.bind(id),roster)
		_shop_tab(button,id == contacted_faction)
		button.tooltip_text = campaign.sector.faction_by_id(id).name
	if contacted_faction.is_empty():
		_panel_copy("No alien channels established. Explore inhabited systems to make first contact.",Instruments.PAPER)
	else:
		var f: Dictionary = campaign.sector.faction_by_id(contacted_faction)
		var profile: Dictionary = campaign.diplomacy.profiles[contacted_faction]
		var introduction := HBoxContainer.new()
		introduction.name = "ContactIntroduction"
		introduction.add_theme_constant_override("separation",18)
		popup_body.add_child(introduction)
		if is_instance_valid(contact_portrait) and contact_portrait.faction_id != contacted_faction:
			_reset_contact_presentation()
		if contact_greeting.is_empty():
			contact_greeting = campaign.diplomacy.greeting(campaign,contacted_faction)
			if campaign.diplomacy.answer(campaign,contacted_faction): _save(false)
		if not is_instance_valid(contact_portrait):
			contact_portrait = AlienPortrait.new()
			contact_portrait.custom_minimum_size = Vector2(320,250)
			contact_portrait.faction_id = contacted_faction
			contact_portrait.mood = "wary" if f.get("embargo",false) else "pleased" if f.relation >= 40 else "neutral"
			introduction.add_child(contact_portrait)
		else:
			contact_portrait.reparent(introduction)
		contact_portrait.custom_minimum_size = Vector2(320,250)
		contact_portrait.show()
		var dialogue := VBoxContainer.new()
		dialogue.add_theme_constant_override("separation",14)
		dialogue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		introduction.add_child(dialogue)
		var identity: Label = _label(profile.speaker,27,Instruments.PAPER)
		var identity_row := HBoxContainer.new()
		dialogue.add_child(identity_row)
		identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		identity.mouse_filter = Control.MOUSE_FILTER_PASS
		identity.tooltip_text = "%s · %s\nGovernment: %s\nPhilosophy: %s" % [profile.species,profile.role,f.government,f.philosophy]
		identity_row.add_child(identity)
		var status_box := VBoxContainer.new()
		status_box.alignment = BoxContainer.ALIGNMENT_CENTER
		status_box.add_theme_constant_override("separation",3)
		identity_row.add_child(status_box)
		var war: bool = campaign.conflict.at_war(contacted_faction)
		var attitude: String = "AT WAR" if war else "EMBARGO" if f.get("embargo",false) else "ALLIED" if contacted_faction+":alliance" in campaign.sector.state.agreements else "FRIENDLY" if f.relation >= 40 else "CORDIAL" if f.relation >= 0 else "WARY"
		var indicator: Label = _label(attitude,13,Color("df977c") if war or f.relation < 0 else Color("a9c9a5"))
		indicator.set_meta("semantic_color",true)
		indicator.mouse_filter = Control.MOUSE_FILTER_PASS
		indicator.tooltip_text = "Relations %+d\n%s" % [f.relation,f.reason]
		status_box.add_child(indicator)
		var relation_bar := Control.new()
		relation_bar.custom_minimum_size = Vector2(86, 7)
		var filled_segments: int = int(clampf((f.relation + 100) / 25.0, 0, 8))
		var is_hostile: bool = war or f.relation < 0
		var bar_tint: Color = Color("df977c") if is_hostile else Color("77aa8f")
		relation_bar.draw.connect(func() -> void:
			for i: int in range(8):
				var seg_color: Color = bar_tint if i < filled_segments else Color("303b3d")
				relation_bar.draw_rect(Rect2(i * 11, 0, 8, 6), seg_color)
		)
		status_box.add_child(relation_bar)
		_contact_copy(dialogue,f.name,Instruments.MUTED)
		var separator := HSeparator.new()
		dialogue.add_child(separator)
		_contact_copy(dialogue,"“%s”" % (contact_reply if not contact_reply.is_empty() else contact_greeting),Instruments.PAPER)
		var tabs := HBoxContainer.new()
		popup_body.add_child(tabs)
		tabs.visible = contact_page != "home"
		if contact_page != "home": _button("‹ Back",func() -> void: contact_page = "home"; _show_popup("contact"),tabs)
		for page: String in ["agreements","exchange","fleet","conflict"]:
			var tab: Button = _button(page.capitalize(),func() -> void: contact_page = page; _show_popup("contact"),tabs)
			_shop_tab(tab,contact_page == page)
		if contact_page == "home":
			var grid := GridContainer.new()
			grid.columns = 2
			grid.add_theme_constant_override("h_separation",10)
			grid.add_theme_constant_override("v_separation",10)
			popup_body.add_child(grid)
			_contact_tile("Trade","cargo",func() -> void:
				var dock: Dictionary = _contact_dock_context()
				if dock.docked and str(dock.reason).is_empty(): dock_page = "market"; _contact_dock()
				else: contact_page = "exchange"; _show_popup("contact"),grid)
			_contact_tile("Diplomacy","log",func() -> void: contact_page = "agreements"; _show_popup("contact"),grid)
			_contact_tile("Fleet","fleet",func() -> void: contact_page = "fleet"; _show_popup("contact"),grid)
			var dock: Dictionary = _contact_dock_context()
			var dock_tile: Button = _contact_tile("Dock services" if dock.docked else "Approach dock","repair_pack",_contact_dock,grid)
			dock_tile.disabled = not str(dock.reason).is_empty()
			dock_tile.tooltip_text = dock.reason if dock_tile.disabled else "Services at "+str(dock.name)
		elif campaign.conflict.at_war(contacted_faction) and contact_page in ["agreements","exchange"]:
			_panel_copy("Diplomatic agreements and exchanges are suspended during war.")
			var peace: Button = _button("Review war and peace",_show_popup.bind("conflict"),popup_body)
			Instruments.instrument(peace,"defense",Instruments.CARGO)
		elif contact_page == "agreements":
			var offers: Dictionary = {"trade":"Trade agreement · preferred market prices","non_aggression":"Non-aggression · guaranteed transit","alliance":"Alliance · charts and escort access"}
			var descriptions: Dictionary = {"trade":"Local buy prices 10% lower; sale prices 10% higher, rounded to Marks. Stock and demand stay finite.","non_aggression":"Allows passage through this nation's territory even during a commercial embargo. It does not reopen its markets.","alliance":"Shares nearby navigation charts and permits one loaned escort, subject to your fleet capacity. Request it in allied orbit. Charts do not count as visits."}
			for pact: String in offers:
				var active: bool = contacted_faction+":"+pact in campaign.sector.state.agreements
				var action: String = "cancel_"+pact if active else pact
				var blocked: String = campaign.diplomacy.reason(campaign,contacted_faction,action)
				var button: Button = _button(("Withdraw · "+pact.replace("_"," ")+" · −20 relations") if active else offers[pact],_contact_action.bind(action),popup_body)
				button.disabled = paused or not blocked.is_empty()
				button.tooltip_text = descriptions[pact]+("\n"+blocked if not blocked.is_empty() else "")
				if not active and not blocked.is_empty(): _panel_copy(blocked)
		elif contact_page == "conflict":
			var defense_button: Button = _button("Review threats, war and peace",_show_popup.bind("conflict"),popup_body)
			Instruments.instrument(defense_button,"defense",Instruments.CARGO)
		elif contact_page == "fleet":
			_build_fleet_panel(contacted_faction)
		else:
			var choices: Dictionary = {"gift":"Goodwill grant · 120 Marks · +15 trust","chart":"License current survey · +25 Marks / +8 trust","reconcile":"Reconciliation · 80 Marks · reset relations to 0"}
			for action: String in choices:
				var blocked: String = campaign.diplomacy.reason(campaign,contacted_faction,action)
				var button: Button = _button(choices[action],_contact_action.bind(action),popup_body)
				button.disabled = paused or not blocked.is_empty()
				button.tooltip_text = blocked if not blocked.is_empty() else "One goodwill grant per nation. Each completed chart can be licensed to one nation only."
			_panel_copy("A chart license is exclusive: choose which nation gains your findings.")
	if contact_page == "home": return
	var dock: Dictionary = _contact_dock_context()
	var dock_button: Button = _button(dock.label,_contact_dock,popup_body)
	dock_button.disabled = not str(dock.reason).is_empty()
	dock_button.tooltip_text = dock.reason if not str(dock.reason).is_empty() else "Local services at %s. Communications do not move your ship or grant remote market access." % dock.name
	if not str(dock.reason).is_empty(): _panel_copy(dock.reason)
	_button("Colony administration",_show_popup.bind("colonies"),popup_body)

func _contact_tile(caption: String, icon: String, action: Callable, parent: Control) -> Button:
	var button: Button = _button(caption,action,parent)
	button.set_meta("contact_action",caption)
	button.custom_minimum_size = Vector2(230,100)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.icon = preload("res://scripts/communicator_style.gd").action_icon(["cargo","log","fleet","repair_pack"].find(icon))
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width",84)
	button.add_theme_constant_override("h_separation",14)
	button.add_theme_font_size_override("font_size",19)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.tooltip_text = caption
	for state: String in ["normal","hover","pressed","disabled","focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color("2a3538") if state == "hover" else Color("1e2628") if state == "pressed" else Color("222a2c")
		box.border_color = Color("687e82") if state == "hover" else Color("3d4b4e")
		box.border_width_left = 1; box.border_width_right = 1
		box.border_width_top = 1; box.border_width_bottom = 2 if state == "hover" else 1
		box.corner_radius_top_left = 4; box.corner_radius_top_right = 4
		box.corner_radius_bottom_left = 4; box.corner_radius_bottom_right = 4
		box.content_margin_left = 14; box.content_margin_right = 14
		box.content_margin_top = 10; box.content_margin_bottom = 10
		button.add_theme_stylebox_override(state,box)
	return button

func _contact_dock_context() -> Dictionary:
	var result: Dictionary = {"id":"", "name":"", "label":"Dock unavailable", "reason":"No dock services at this location.", "docked":false}
	for id: String in model.local_services():
		var port: Dictionary = model.local_services()[id]
		if port.mode != model.state.flight_mode: continue
		result.id = id; result.name = port.name
		# Query access at the destination to distinguish a closed port from distance.
		# The real position is still validated before opening and on every purchase.
		result.reason = campaign.commerce.access(campaign,id,Model.service_position(id)) if campaign != null else ""
		if paused: result.reason = "Resume flight before using dock services."
		if not ship.position.is_finite(): result.reason = "Ship position unavailable."
		result.docked = ship.position.distance_to(Model.service_position(id)) <= float(port.reach)
		result.label = ("Dock services · " if result.docked else "Approach dock · ")+str(port.name)
		return result
	return result

func _contact_dock() -> void:
	# Re-evaluate when clicked; a previously rendered quote is not authorization.
	var dock: Dictionary = _contact_dock_context()
	if not str(dock.reason).is_empty():
		_toast(dock.reason)
		return
	if dock.docked:
		if campaign != null:
			var blocked: String = campaign.commerce.access(campaign,dock.id,ship.position)
			if not blocked.is_empty(): _toast(blocked); return
		selected_service = dock.id
		_show_popup("service")
	else:
		popup.hide()
		_approach_service(dock.id)

func _contact_copy(parent: Control, text: String, tint: Color) -> void:
	var label: Label = _label(text,16,tint)
	label.custom_minimum_size.x = 450
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)

func _refresh_fleet_ui() -> void:
	if fleet_strip == null: return
	var ids: Array = campaign.fleet.active_ids()
	fleet_strip.visible = not _inspection_open() and (campaign.fleet.capacity(campaign) > 0 or not ids.is_empty())
	fleet_button.text = "%d / %d" % [ids.size(),campaign.fleet.capacity(campaign)]
	fleet_button.tooltip_text = "Allied fleet · %s\nInspect hull, return escorts or arrange dock repairs." % ("assist attacks" if campaign.fleet.state.assist else "following, holding fire")
	for id: String in fleet_bars:
		var bar: ProgressBar = fleet_bars[id]
		bar.visible = id in ids
		if not bar.visible: continue
		bar.max_value = campaign.fleet.catalog[id].hull
		bar.value = campaign.fleet.state.ships[id].hull
		bar.tooltip_text = "%s · %s\nHull %d / %d" % [campaign.fleet.catalog[id].name,campaign.sector.faction_by_id(id).name,bar.value,bar.max_value]

func _select_climate(id: String) -> void:
	if paused or _inspection_open() or campaign == null or not Climate.data().tools.has(id): return
	if not campaign.climate.available(model,id).is_empty(): return
	_cancel_orders(); climate_tool = id; surface_weapon = ""; surface_selected = ""; weapon_selected = false
	hud.select_tool(id); audio.play("ui_confirm"); _refresh_ui()

func _apply_climate() -> void:
	if paused or _inspection_open() or campaign == null or climate_tool.is_empty(): return
	var blocked: String = campaign.climate.start(campaign,climate_tool,ship.position)
	_toast(blocked if not blocked.is_empty() else "Climate pulse deployed · eight seconds to settle")
	audio.play("error" if not blocked.is_empty() else "scan_complete")
	if blocked.is_empty(): _save(false)
	_refresh_ui()

func _refresh_climate_ui() -> void:
	if campaign == null or climate_chart == null: return
	var planet: String = model.state.planet_id
	var local: Dictionary = campaign.climate.world(planet)
	var active: bool = campaign.climate.state.worlds.has(planet)
	var baseline: Vector2 = Climate.baseline(planet)
	var signature: String = "%s:%.3f:%.3f:%s" % [planet,local.temperature,local.atmosphere,active]
	if signature != climate_signature:
		climate_signature = signature
		orbit.planet.set_climate(local,baseline,active)
		planet_map.globe.set_climate(local,baseline,active)
		ground_material.set_shader_parameter("climate_active",active)
		ground_material.set_shader_parameter("temperature",local.temperature)
		ground_material.set_shader_parameter("pressure",local.atmosphere)
		ground_material.set_shader_parameter("baseline_temperature",baseline.x)
		ground_material.set_shader_parameter("frozen",world_definition.archetype == "frozen")
		if active:
			surface_environment_resource.fog_density = float(local.atmosphere)*0.00006
			var sky: ProceduralSkyMaterial = surface_environment_resource.sky.sky_material
			sky.sky_top_color = Color("07101e").lerp(Color("516e96"),float(local.atmosphere)/100)
	climate_chart.visible = not _inspection_open() and (not climate_tool.is_empty() or not local.project.is_empty()) and model.state.survey_ticks >= model.definition().survey_seconds
	climate_chart.present(local,Climate.score(local))
	climate_ring.visible = not local.project.is_empty()
	if climate_ring.visible:
		climate_ring.rotation = Vector3(0.3,0,float(model.state.time)*0.2)
		climate_ring.material_override.albedo_color = Color(Climate.data().tools[local.project.tool].color)
		climate_ring.material_override.emission = climate_ring.material_override.albedo_color
	for id: String in Climate.data().tools:
		hud.count_labels[id].text = "× %d" % campaign.climate.state.charges[id] if Climate.data().tools[id].charge else ""
	if climate_tool.is_empty(): return
	var blocked: String = campaign.climate.reason(campaign,climate_tool,ship.position)
	subject.text = "T%d climate · %s" % [Climate.score(local),model.definition().name]
	explanation.text = blocked if not blocked.is_empty() else "Click planet or terrain · native climate changes can damage relations"
	hud.action_state.text = "SETTLING" if not local.project.is_empty() else "TERRAFORM"
	use_button.text = "Apply"; use_button.disabled = paused or _inspection_open() or not blocked.is_empty()
	use_button.tooltip_text = blocked if not blocked.is_empty() else hud.Palette.entry(climate_tool).hint
	objective.text = "Temperature %.0f · atmosphere %.0f · plants T%d" % [local.temperature,local.atmosphere,campaign.biosphere.plant_tier(planet)]

func _buy_climate(tool_id: String) -> void:
	if paused or campaign == null: return
	var blocked: String = campaign.climate.buy(campaign,selected_service,ship.position,tool_id)
	_toast(blocked if not blocked.is_empty() else "Terraforming unit loaded")
	audio.play("error" if not blocked.is_empty() else "cargo")
	if blocked.is_empty(): _save(false)
	_show_popup("service"); _refresh_ui()

func _build_climate_shop() -> void:
	_panel_copy("TERRAFORMING LOCKER · %d / 6" % campaign.climate.units(),Instruments.GOLD)
	for id: String in campaign.climate.state.charges:
		var spec: Dictionary = Climate.data().tools[id]
		var blocked: String = campaign.climate.buy_reason(campaign,selected_service,ship.position,id)
		var button: Button = _button("%s · %d Marks" % [spec.name,spec.price],_buy_climate.bind(id),popup_body)
		button.icon = Instruments.icon(id); button.add_theme_constant_override("icon_max_width",32)
		button.set_meta("climate_purchase",id)
		button.disabled = paused or not blocked.is_empty()
		button.tooltip_text = blocked if not blocked.is_empty() else hud.Palette.entry(id).hint
		_panel_copy("%d in stock · owned %d · %+d %s" % [campaign.climate.stock(model.state.planet_id,selected_service,id),campaign.climate.state.charges[id],spec.delta,spec.axis])
	_panel_copy("Units are consumed once. Permanent energy-powered versions are sold under Upgrades → Equipment. Unstabilized climate drifts toward native conditions.")

func _fleet_action(id: String, action: String) -> void:
	if paused or campaign == null: return
	var blocked: String = campaign.fleet.command(campaign,id,action,ship.position)
	_toast(blocked if not blocked.is_empty() else "Fleet order accepted")
	audio.play("error" if not blocked.is_empty() else "ui_confirm")
	if blocked.is_empty(): _save(false)
	_show_popup(popup_kind); _refresh_ui()

func _build_fleet_panel(only: String = "") -> void:
	var fleet: RefCounted = campaign.fleet
	_panel_copy("ALLIED FLEET · %d / %d slots" % [fleet.active_ids().size(),fleet.capacity(campaign)],Instruments.PAPER)
	var stance: Button = _button("Assist attacks" if fleet.state.assist else "Follow · hold fire",func() -> void:
		if paused: return
		fleet.set_assist(campaign,not fleet.state.assist); _save(false); _show_popup(popup_kind),popup_body)
	stance.icon = load("res://assets/ui/flight/fleet.svg"); stance.add_theme_constant_override("icon_max_width",28)
	stance.tooltip_text = "Toggle whether escorts fire on the target you engage. Following ships can still take enemy fire."
	stance.disabled = paused
	for id: String in fleet.catalog:
		if not only.is_empty() and id != only: continue
		if not campaign.sector.faction_by_id(id).get("contacted",false): continue
		var spec: Dictionary = fleet.catalog[id]
		var unit: Dictionary = fleet.state.ships.get(id,{})
		var status_text: String = unit.get("status","available")
		_panel_copy("%s · %s%s" % [spec.name,status_text," · %d / %d hull" % [unit.hull,spec.hull] if not unit.is_empty() else ""],Color(spec.color))
		var actions := HBoxContainer.new(); popup_body.add_child(actions)
		var choices: Array = ["dismiss","repair"] if status_text == "active" else ["recruit"]
		for action: String in choices:
			var blocked: String = fleet.reason(campaign,id,action,ship.position)
			var label: String = "Return ship" if action == "dismiss" else "Repair · %d Marks" % fleet.repair_cost(id) if action == "repair" else "Request replacement · 120 Marks" if status_text == "lost" else "Request escort"
			var button: Button = _button(label,_fleet_action.bind(id,action),actions)
			button.set_meta("fleet_action",id+":"+action)
			button.disabled = paused or not blocked.is_empty()
			button.tooltip_text = blocked if not blocked.is_empty() else "One loaned ship per ally. Hull damage persists after dismissal."
			if action == "recruit" and not blocked.is_empty(): _panel_copy(blocked)
	_panel_copy("One slot per highest Explorer, Merchant or Defender tier, up to three. Lost escorts cost trust (−7); replacements take 60 seconds and 120 Marks.")
	if only.is_empty(): _button("Communications",_show_popup.bind("contact"),popup_body)

func _build_chronicle_panel() -> void:
	var ledger: Dictionary = campaign.sector.state.get("ledger",{})
	_panel_copy("Colony day %d · treasury %d Marks\nLast day: tax %.1f · upkeep %.1f · exports %.1f" % [campaign.sector.state.tick,model.marks,ledger.get("tax",0),ledger.get("upkeep",0),ledger.get("exports",0)],Instruments.GOLD)
	var filters := HBoxContainer.new()
	popup_body.add_child(filters)
	for filter: String in ["all","diplomacy","trade","exploration","encounter","war","local"]:
		var button: Button = _button(filter.capitalize(),func() -> void: chronicle_filter = filter; chronicle_page = 0; _show_popup("journal"),filters)
		button.add_theme_font_size_override("font_size",13)
		button.disabled = chronicle_filter == filter
	var entries: Array = model.state.history.duplicate() if chronicle_filter == "local" else campaign.diplomacy.state.events.duplicate()
	if chronicle_filter == "diplomacy": entries = entries.filter(func(entry: Dictionary) -> bool: return entry.kind in ["diplomacy","contact"])
	elif chronicle_filter not in ["all","local"]: entries = entries.filter(func(entry: Dictionary) -> bool: return entry.kind == chronicle_filter)
	entries.reverse()
	chronicle_page = clampi(chronicle_page,0,maxi(0,(entries.size()-1)/15))
	var pager := HBoxContainer.new()
	popup_body.add_child(pager)
	_button("Newer",func() -> void: chronicle_page -= 1; _show_popup("journal"),pager).disabled = chronicle_page == 0
	pager.add_child(_label("%d events · page %d" % [entries.size(),chronicle_page+1],14))
	_button("Older",func() -> void: chronicle_page += 1; _show_popup("journal"),pager).disabled = (chronicle_page+1)*15 >= entries.size()
	for entry: Dictionary in entries.slice(chronicle_page*15,(chronicle_page+1)*15):
		if chronicle_filter == "local":
			_panel_copy("%02d:%02d · %s" % [int(entry.time)/60,int(entry.time)%60,entry.text],Instruments.PAPER)
			continue
		_panel_copy("%02d:%02d · %s · %s" % [int(entry.time)/60,int(entry.time)%60,entry.kind.capitalize(),Geography.definition(entry.location).name],Instruments.GOLD)
		_panel_copy(entry.summary,Instruments.PAPER)
		if entry.cause > 0:
			var cause: Dictionary = campaign.diplomacy.state.events[entry.cause-1]
			_panel_copy("Following: "+str(cause.summary))
	if entries.is_empty(): _panel_copy("Your discoveries and decisions will appear here. Earlier activity is preserved in Local.")

func _select_colony_kit() -> void:
	if paused or campaign == null: return
	var blocked: String = campaign.colonies.deployment_reason(campaign)
	if not blocked.is_empty(): _toast(blocked); return
	_cancel_orders()
	popup.hide()
	kit_mode = true
	_toast("Choose clear ground · green footprint is valid · Stop or Escape cancels")
	audio.play("ui_confirm")

func _surface_point(screen: Vector2) -> Variant:
	var from: Vector3 = camera.project_ray_origin(screen)
	var ray: Vector3 = camera.project_ray_normal(screen)
	for i: int in range(1,480):
		var at: Vector3 = from+ray*float(i)*0.5
		if at.y <= terrain_height(at.x,at.z): return Vector2(at.x,at.z)
	return null

func _order_deployment(at: Vector2) -> void:
	var blocked: String = campaign.colonies.deployment_reason(campaign)
	if blocked.is_empty(): blocked = campaign.colonies.site_reason(model.state.planet_id,at)
	if not blocked.is_empty(): _toast(blocked); audio.play("error"); return
	_navigate(Vector3(at.x,terrain_height(at.x,at.y)+7,at.y))
	deployment_site = at
	deploy_order = true
	_toast("Approaching colony site · kit remains aboard until unloading")

func _finish_deployment() -> void:
	var error: String = campaign.colonies.deploy(campaign,deployment_site,ship.position)
	_cancel_orders()
	_toast(error if not error.is_empty() else "Colony kit landed · construction has begun")
	audio.play("error" if not error.is_empty() else "cargo")
	if error.is_empty(): _save(false)

func _update_outpost_visual() -> void:
	if campaign == null: return
	if kit_marker == null:
		kit_marker = MeshInstance3D.new()
		var footprint := TorusMesh.new()
		footprint.inner_radius = 4.6; footprint.outer_radius = 4.8
		footprint.rings = 40; footprint.ring_segments = 6
		kit_marker.mesh = footprint
		kit_marker.material_override = _mat(Color("a4ddb1"),true)
		surface_root.add_child(kit_marker)
	kit_marker.visible = (kit_mode or deploy_order) and not _inspection_open() and model.state.flight_mode == "surface"
	if kit_marker.visible:
		var at: Variant = _surface_point(get_viewport().get_mouse_position()) if kit_mode else deployment_site
		if at is Vector2:
			kit_marker.position = Vector3(at.x,terrain_height(at.x,at.y)+0.35,at.y)
			var valid: bool = campaign.colonies.site_reason(model.state.planet_id,at).is_empty()
			kit_marker.material_override.albedo_color = Color("a4ddb1") if valid else Color("ed8a74")
		else: kit_marker.visible = false
	var id: String = campaign.colonies.strategic_id(model.state.planet_id)
	if campaign.territory.catalog.has(id) and campaign.territory.world(id).phase == "annexed":
		if outpost_visual != null: outpost_visual.queue_free(); outpost_visual = null
		return
	if not campaign.colonies.state.outposts.has(id):
		if outpost_visual != null: outpost_visual.queue_free(); outpost_visual = null
		outpost_signature = ""
		return
	var record: Dictionary = campaign.colonies.state.outposts[id]
	var phase: int = campaign.colonies.phase(campaign,id)
	var signature: String = "%s:%d:%s:%s" % [id,phase,record.module,str(record.site)]
	if signature != outpost_signature:
		if outpost_visual != null: outpost_visual.queue_free()
		outpost_visual = OutpostVisual.new()
		outpost_visual.position = Vector3(record.site[0],terrain_height(record.site[0],record.site[1]),record.site[1])
		surface_root.add_child(outpost_visual)
		outpost_visual.build(phase,record.module)
		outpost_signature = signature
	outpost_visual.caption.text = "Colony hub" if phase == 3 else "Hub · %d / 18 days" % (18-int(campaign.sector.state.settlements[id].remaining))
	var hub_at: Vector3 = outpost_visual.position+Vector3(0,2,0)
	outpost_visual.caption.visible = not _inspection_open() and not camera.is_position_behind(hub_at) and camera.unproject_position(hub_at).distance_to(get_viewport().get_mouse_position()) < 48

func _build_warehouse_panel() -> void:
	var id: String = campaign.colonies.strategic_id(model.state.planet_id)
	if not campaign.colonies.state.outposts.has(id):
		_panel_copy("No export outpost on this world. Load a colony kit through Upgrades at an established colony.")
		_button("Colony administration",_show_popup.bind("colonies"),popup_body)
		return
	var record: Dictionary = campaign.colonies.state.outposts[id]
	_panel_copy(record.status,Instruments.PAPER)
	_panel_copy("Warehouse holds 16 freight units total. Loading transfers actual local stock to your ship.")
	var amounts := HBoxContainer.new()
	popup_body.add_child(amounts)
	for amount: int in [1,4,8]:
		var choice: Button = _button("Load %d" % amount,func() -> void: trade_amount = amount; _show_popup("service"),amounts)
		choice.disabled = trade_amount == amount
	for item: String in record.stock:
		var blocked: String = campaign.colonies.collect_reason(campaign,selected_service,ship.position,item,trade_amount)
		var button: Button = _button("%s · %d stored · load %d" % [campaign.commerce.catalog.goods[item].name,record.stock[item],trade_amount],_commerce_action.bind("collect",item),popup_body)
		button.disabled = paused or not blocked.is_empty()
		button.tooltip_text = blocked
	_button("Colony administration",_show_popup.bind("colonies"),popup_body)
	_button("Undock",_close_popup,popup_body)

func _install_export(item: String) -> void:
	if paused or campaign == null: return
	var error: String = campaign.colonies.install(campaign,selected_colony,item)
	_toast(error if not error.is_empty() else "Export facility commissioned")
	audio.play("error" if not error.is_empty() else "ui_confirm")
	if error.is_empty(): _save(false)
	_show_popup("colonies")

func _fabricate_cutter_head() -> void:
	if paused or campaign == null: return
	var error: String = campaign.colonies.fabricate_cutter_head(campaign,selected_colony,ship.position)
	_toast(error if not error.is_empty() else "Resonance focusing head installed · mining now costs 5 energy")
	audio.play("error" if not error.is_empty() else "ui_confirm")
	if error.is_empty(): _save(false)
	_show_popup("colonies")

func _build_colonies_panel() -> void:
	var defense_button: Button = _button("Colony defense",_show_popup.bind("conflict"),popup_body)
	Instruments.instrument(defense_button,"defense",Instruments.CARGO)
	var freight_button: Button = _button("Freight contracts",_show_popup.bind("freight"),popup_body)
	Instruments.instrument(freight_button,"cargo",Instruments.CARGO)
	freight_button.tooltip_text = "Charter carriers, protect a warehouse reserve and manage automatic sales."
	if campaign.colonies.state.outposts.is_empty():
		_panel_copy("No expedition outposts yet. Load a colony kit at your home dock, survey an unclaimed world, descend and deploy it from Inventory.",Instruments.PAPER)
		return
	if not campaign.colonies.state.outposts.has(selected_colony): selected_colony = campaign.colonies.state.outposts.keys()[0]
	var tabs := HBoxContainer.new()
	popup_body.add_child(tabs)
	for id: String in campaign.colonies.state.outposts:
		var tab: Button = _button(campaign.sector.state.planets[id].name,func() -> void: selected_colony = id; _show_popup("colonies"),tabs)
		tab.disabled = id == selected_colony
	var record: Dictionary = campaign.colonies.state.outposts[selected_colony]
	_panel_copy(record.status,Instruments.PAPER)
	if campaign.sector.state.settlements.has(selected_colony):
		_panel_copy("%d / 18 colony days complete. Construction continues while you explore; inspection pauses time." % (18-int(campaign.sector.state.settlements[selected_colony].remaining)))
		return
	var colony: Dictionary = campaign.sector.state.colonies[selected_colony]
	_panel_copy("LOCAL RESERVES · %d materials · %d supplies\nInstalled: %s" % [colony.materials,colony.supplies,"none" if record.module.is_empty() else campaign.commerce.catalog.goods[record.module].name])
	_panel_copy("Choose one export facility. Installation or replacement: 60 Marks, 20 local materials, 10 local supplies. Warehouse stock is retained.")
	for item: String in ["alloy","water","glass"]:
		var output: int = campaign.colonies.yield_for(selected_colony,item,campaign)
		var blocked: String = campaign.colonies.install_reason(campaign,selected_colony,item)
		var button: Button = _button("%s · %d units / 2 days" % [campaign.commerce.catalog.goods[item].name,output],_install_export.bind(item),popup_body)
		button.disabled = paused or not blocked.is_empty()
		button.tooltip_text = blocked
	_panel_copy("Per production cycle: 0.5 local supplies and %d Marks. Output pauses when storage is full or reserves run short." % (2 if Geography.definition(selected_colony).archetype == "frozen" else 1))
	for item: String in record.stock: _panel_copy("%s: %d stored" % [campaign.commerce.catalog.goods[item].name,record.stock[item]])
	var head_installed: bool = "resonant_cutter_head" in campaign.commerce.state.upgrades
	if record.module == "glass" or head_installed:
		_panel_copy("GLASSWORKS FABRICATION · 2 Resonant glass + 2 Alloy billets + 1 local supply. The finished head lowers future seam cuts from 8 to 5 energy.",Instruments.PAPER)
		var head_reason: String = campaign.colonies.cutter_head_reason(campaign,selected_colony,ship.position)
		var head_button: Button = _button("Resonance focusing head · Installed" if head_installed else "Fabricate Resonance focusing head",_fabricate_cutter_head,popup_body)
		Instruments.instrument(head_button,"mine",Instruments.GOLD)
		head_button.disabled = paused or head_installed or not head_reason.is_empty()
		head_button.tooltip_text = head_reason if not head_reason.is_empty() else "Fabricates and installs the mined-crystal cutter upgrade."

func _reload_destination() -> void:
	var parent: Node = get_parent()
	var next: Node3D = load("res://scenes/encounter.tscn").instantiate()
	next.name = name
	next.campaign = campaign
	next.suspended_session = suspended_session
	next.paused = paused
	for connection: Dictionary in leave.get_connections(): next.leave.connect(connection.callable)
	var path: String = save_path
	suspended_session = null
	parent.remove_child(self)
	parent.add_child(next)
	next.save_path = path
	next.arrival_fade = 1.0
	next._save(false)
	if not campaign.diplomacy.unread().is_empty():
		var incoming: String = campaign.diplomacy.unread()[0]
		next._toast("Incoming transmission · "+str(campaign.sector.faction_by_id(incoming).name)+" · Communicate [Y]")
		next.audio.play("ui_open")
	if campaign.traveling(): next._show_travel_view()
	queue_free()
