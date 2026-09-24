extends SceneTree
## Actual game-scene fixtures; not native-input acceptance or final art approval.
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Combat = preload("res://scripts/surface_combat.gd")
func _initialize() -> void: call_deferred("run")
func capture(scene: Node3D, label: String) -> void:
	scene._update_visuals(); scene._update_camera(1); scene._refresh_ui()
	scene.surface_combat_visual.refresh(scene.campaign,"civic",0,0,true)
	await process_frame; await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/territory-"+label+"-"+str(root.size.x)+".png")
func hit(game: RefCounted, times: int) -> void:
	var at: Vector3 = Combat.home("s7p0","civic")+Vector3(0,7,8)
	for i: int in range(times):
		game.combat.fire(game,"surface_laser","civic",Combat.home("s7p0","civic"),at); game.tick()
func run() -> void:
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		root.size = resolution
		var game := Session.new(); game.field.state = Field.fresh("s7p0"); game.field.bind_account(game.sector.state); game.configure_flagship(); game.field.marks = 900
		game.diplomacy.contact(game,"consortium")
		var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = game; root.add_child(scene)
		scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true; scene.save_path = "res://artifacts/territory-review.fw"
		scene.ship.position = Combat.home("s7p0","civic")+Vector3(0,7,14)
		scene.distance = 48; scene.camera_distance_target = 48; scene.pitch = 0.9; scene.yaw = -0.2
		await capture(scene,"settlement")
		game.conflict.command(game,"consortium","declare"); hit(game,10)
		scene._show_popup("territory"); await capture(scene,"surrender")
		var pending: Dictionary = game.snapshot()
		scene._close_popup(); game.territory.command(game,"s7p0","annex",scene.ship.position)
		await capture(scene,"annexed")
		scene._show_popup("territory"); await capture(scene,"terms")
		scene._close_popup(); game.restore_snapshot(pending); scene.model = game.field
		game.territory.command(game,"s7p0","refuse",scene.ship.position); hit(game,5)
		await capture(scene,"ruin")
		scene.free()
	print("Territory captures complete at 1080p/1440p."); quit()
