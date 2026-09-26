extends SceneTree
## Synthetic ordinary-flight input review. Captures camera-follow evidence only;
## this is not native playtest, fun, or performance evidence.
## Usage: godot --path . -s tests/review_camera_follow.gd -- --mode=surface --frames=60
## Modes are surface (forward) and orbit (right); one mode, trace, and final frame per run.
const Model = preload("res://scripts/encounter_state.gd")
const SAMPLE_EVERY_FRAMES := 6
const DT := 1.0 / 60.0
const DEFAULT_MODE := "surface"
const DEFAULT_FRAMES := 60
const MAX_FRAMES := 600
var output_dir := ""
var review_mode := DEFAULT_MODE
var review_frames := DEFAULT_FRAMES

func _initialize() -> void:
	call_deferred("run")

func parse_arguments() -> bool:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mode="):
			review_mode = argument.trim_prefix("--mode=")
		elif argument.begins_with("--frames="):
			var value := argument.trim_prefix("--frames=")
			if not value.is_valid_int():
				push_error("--frames must be an integer from 1 to %d" % MAX_FRAMES)
				return false
			review_frames = value.to_int()
		else:
			push_error("Unknown argument: %s. Use --mode=surface|orbit --frames=N" % argument)
			return false
	if review_mode not in ["surface", "orbit"]:
		push_error("--mode must be surface or orbit")
		return false
	if review_frames < 1 or review_frames > MAX_FRAMES:
		push_error("--frames must be from 1 to %d" % MAX_FRAMES)
		return false
	return true

func make_output_dir() -> void:
	var base := "res://artifacts/camera-follow-evidence-r3-%s" % review_mode
	var candidate := base
	var suffix := 2
	while DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(candidate)):
		candidate = "%s-%02d" % [base,suffix]
		suffix += 1
	output_dir = candidate
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

func write_sample(trace: FileAccess, scene: Node, frame: int, phase: String, input_used: String) -> void:
	var ship: Vector3 = scene.ship.global_position
	var focus: Vector3 = scene.camera_focus
	var camera_position: Vector3 = scene.camera.global_position
	var velocity: Vector3 = scene.velocity
	var viewport_size: Vector2i = root.get_visible_rect().size
	trace.store_line("%s,%s,%d,%.3f,%s,%s,true,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%d,%d" % [
		review_mode,phase,frame,frame*DT,scene.model.state.flight_mode,input_used,
		ship.x,ship.y,ship.z,focus.x,focus.y,focus.z,
		camera_position.x,camera_position.y,camera_position.z,
		scene.distance,scene.camera_distance_target,velocity.x,velocity.y,velocity.z,
		viewport_size.x,viewport_size.y])

func advance_and_trace(scene: Node, trace: FileAccess, input_label: String) -> void:
	for frame: int in range(1, review_frames + 1):
		await process_frame
		if frame % SAMPLE_EVERY_FRAMES == 0 and frame < review_frames:
			write_sample(trace,scene,frame,"following",input_label)
	write_sample(trace,scene,review_frames,"final",input_label)

func capture_final_frame() -> void:
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(output_dir.path_join("%s-final.png" % review_mode)))

func run() -> void:
	if not parse_arguments():
		quit(2)
		return
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
	if review_mode == "orbit":
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
	var trace := FileAccess.open(ProjectSettings.globalize_path(output_dir.path_join("trace.csv")),FileAccess.WRITE)
	trace.store_line("mode,phase,frame,seconds,flight_mode,input,input_is_synthetic,ship_x,ship_y,ship_z,focus_x,focus_y,focus_z,camera_x,camera_y,camera_z,camera_distance,camera_target,velocity_x,velocity_y,velocity_z,viewport_width,viewport_height")
	var action := "flight_right" if review_mode == "orbit" else "flight_forward"
	var input_label := "%s: Input.action_press" % action
	Input.action_press(action)
	await advance_and_trace(scene,trace,input_label)
	Input.action_release(action)
	trace.close()
	await capture_final_frame()
	print("Synthetic %s camera-follow evidence saved to %s (%d frames, one trace, one 1920x1080 frame)" % [review_mode,output_dir,review_frames])
	scene.free()
	quit()
