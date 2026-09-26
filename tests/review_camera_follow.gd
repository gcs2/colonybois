extends SceneTree
## Synthetic ordinary-flight input review. Captures camera-follow evidence only;
## this is not native playtest, fun, or performance evidence.
const Model = preload("res://scripts/encounter_state.gd")
const SAMPLE_EVERY_FRAMES := 6
const DT := 1.0 / 60.0
var output_dir := ""

func _initialize() -> void:
	call_deferred("run")

func make_output_dir() -> void:
	var base := "res://artifacts/camera-follow-evidence-r2"
	var candidate := base
	var suffix := 2
	while DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(candidate)):
		candidate = "%s-%02d" % [base,suffix]
		suffix += 1
	output_dir = candidate
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

func write_sample(trace: FileAccess, scene: Node, group: String, phase: String, input_used: String, frame: int) -> void:
	var ship: Vector3 = scene.ship.global_position
	var focus: Vector3 = scene.camera_focus
	var camera_position: Vector3 = scene.camera.global_position
	var velocity: Vector3 = scene.velocity
	var viewport_size: Vector2i = root.get_visible_rect().size
	trace.store_line("%s,%s,%d,%.3f,%s,%s,true,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%d,%d" % [
		group,phase,frame,frame*DT,scene.model.state.flight_mode,input_used,
		ship.x,ship.y,ship.z,focus.x,focus.y,focus.z,
		camera_position.x,camera_position.y,camera_position.z,
		scene.distance,scene.camera_distance_target,velocity.x,velocity.y,velocity.z,
		viewport_size.x,viewport_size.y])

func advance_and_trace(scene: Node, trace: FileAccess, group: String, phase: String, input_used: String, count: int, first_frame: int) -> void:
	for local_frame: int in range(count):
		await process_frame
		if local_frame % SAMPLE_EVERY_FRAMES == 0:
			write_sample(trace,scene,group,phase,input_used,first_frame+local_frame)

func capture(scene: Node, group: String, phase: String) -> void:
	await RenderingServer.frame_post_draw
	var filename := "%s-%s.png" % [group,phase]
	var image: Image = root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(output_dir.path_join(filename)))

func run_group(scene: Node, trace: FileAccess, group: String, action: String, input_label: String, orbit_mode: bool) -> void:
	if orbit_mode:
		scene._change_flight_mode("orbit")
		scene.yaw = 0.3
		scene.pitch = 0.36
		scene.distance = 85.0
		scene.camera_distance_target = 85.0
	else:
		scene.yaw = 0.0
		scene.pitch = 0.36
		scene.distance = 32.0
		scene.camera_distance_target = 32.0
	scene._update_camera(1.0)
	await advance_and_trace(scene,trace,group,"before","none",72,0)
	write_sample(trace,scene,group,"before","none",72)
	await capture(scene,group,"before")

	Input.action_press(action)
	await advance_and_trace(scene,trace,group,"during",input_label,72,72)
	Input.action_release(action)
	write_sample(trace,scene,group,"during",input_label,144)
	await capture(scene,group,"during")

	await advance_and_trace(scene,trace,group,"after","released",90,144)
	write_sample(trace,scene,group,"after","released",234)
	await capture(scene,group,"after")

func run() -> void:
	root.size = Vector2i(1920,1080)
	root.content_scale_size = Vector2i(1920,1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.gui_disable_input = true
	make_output_dir()
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.model = Model.new()
	scene.save_path = output_dir.path_join("isolated-session.json")
	scene.audio.muted = true
	root.add_child(scene)
	await process_frame
	scene.audio.set_volume("voice",0.0)
	Input.release_all()
	var trace := FileAccess.open(ProjectSettings.globalize_path(output_dir.path_join("trace.csv")),FileAccess.WRITE)
	trace.store_line("group,phase,frame,seconds,mode,input,input_is_synthetic,ship_x,ship_y,ship_z,focus_x,focus_y,focus_z,camera_x,camera_y,camera_z,camera_distance,camera_target,velocity_x,velocity_y,velocity_z,viewport_width,viewport_height")
	await run_group(scene,trace,"surface","flight_forward","flight_forward: Input.action_press",false)
	await run_group(scene,trace,"orbit","flight_right","flight_right: Input.action_press",true)
	Input.release_all()
	trace.close()
	scene.free()
	print("Synthetic camera-follow evidence saved to ",output_dir)
	quit()
