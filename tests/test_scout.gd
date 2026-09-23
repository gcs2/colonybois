extends SceneTree
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)
func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	var spec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/specs/scout_v2.json"))
	var triangles: int = 0; var meshes: int = 0
	for node: Node in scene.ship.find_children("*","MeshInstance3D",true,false):
		# The gameplay shield ring is independent of the imported asset.
		if node == scene.shroud_ring: continue
		meshes += 1
		for index: int in range(node.mesh.get_surface_count()):
			var indices: int = node.mesh.surface_get_array_index_len(index)
			triangles += (indices if indices > 0 else node.mesh.surface_get_array_len(index))/3
	check(triangles <= int(spec.budgets.triangles_max) and meshes <= int(spec.budgets.mesh_instances_max),"Imported geometry stays within the authored render budget")
	for id: String in spec.sockets:
		check(scene.ship.find_child(id,true,false) != null,"Imported asset retains socket "+id)
	scene.ship.position = Vector3(3,8,13); scene.ship.rotation = Vector3(0.2,1.2,-0.1)
	for jet: CPUParticles3D in scene.effects.exhaust:
		check(jet.get_parent().name in ["PortExhaust","StarboardExhaust"] and jet.position.is_zero_approx() and jet.global_position.distance_to(scene.ship.global_position) > 2,"Exhaust follows its rotated engine socket, not the ship pivot")
	var before: Dictionary = scene.model.state.duplicate(true)
	scene.velocity = Vector3(12,2,-8); scene._update_flight_effects(0.5)
	var port: Node3D = scene.scout_motion.port
	var starboard: Node3D = scene.scout_motion.starboard
	check(absf(port.rotation.z) > 0.01 and absf(starboard.rotation.z) > 0.01 and absf(port.rotation.z) <= 0.26 and absf(starboard.rotation.z) <= 0.26,"Measured thrust drives bounded articulated shields")
	var frozen: Vector2 = Vector2(port.rotation.z,starboard.rotation.z)
	scene.paused = true; scene.velocity = Vector3.ZERO; scene._update_flight_effects(1)
	check(Vector2(port.rotation.z,starboard.rotation.z) == frozen,"Pause freezes the cosmetic control surfaces")
	scene.paused = false
	for i: int in range(12): scene._update_flight_effects(0.2)
	check(absf(port.rotation.z) < 0.001 and absf(starboard.rotation.z) < 0.001 and scene.model.state == before,"Stopping settles the rig without changing simulation state")
	scene._select_tool("scan"); scene.ship.position = scene._target_position("relay")+Vector3(0,4,3)
	scene._command_target("relay"); scene._operate(0.1)
	var origin: Vector3 = scene._ship_socket("ToolEmitter")
	check(scene.beam.visible and scene.beam.position.is_equal_approx((origin+scene._target_position())/2),"Surface tool beam connects the actual belly aperture to its target")
	scene._change_flight_mode("orbit"); scene.ship.position = scene.model.guardian_position()+Vector3(0,2,8)
	scene.ship.rotation.y = 1.1; scene._select_weapon(); scene._command_guardian(); scene._operate_attack()
	origin = scene._ship_socket("WeaponEmitter")
	check(scene.weapon_flash > 0 and scene.weapon_beam.position.is_equal_approx((origin+scene.model.guardian_position())/2),"Real weapon order fires from the transformed muzzle")
	check((scene.weapon_beam.position-scene.weapon_beam.basis.y*0.5).distance_to(origin) < 0.001 and (scene.weapon_beam.position+scene.weapon_beam.basis.y*0.5).distance_to(scene.model.guardian_position()) < 0.001,"Angled weapon geometry terminates at both muzzle and combat target")
	scene.free()
	print("Scout integration assertions: ",checks,"; failures: ",failures)
	quit(1 if failures else 0)
