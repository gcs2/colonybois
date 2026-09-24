extends SceneTree
## Synthetic pointer evidence against real contact controls; not human playtest acceptance.
const Session = preload("res://scripts/expedition_session.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = Session.new()
	scene.save_path = "res://artifacts/tooltip-review.json"
	root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false)
	scene.set_process_input(false); scene.set_process_unhandled_input(false)
	scene.audio.muted = true
	scene.campaign.diplomacy.contact(scene.campaign,"consortium")
	scene._contact_select("consortium")
	for frame: int in range(5): await process_frame
	var tiles: Array = scene.popup_body.find_children("*","Button",true,false).filter(func(button: Node) -> bool: return button.has_meta("contact_action"))
	assert(tiles.size() == 4)
	var target: Button = tiles[0]
	var motion := InputEventMouseMotion.new()
	motion.position = target.get_global_rect().get_center()
	var started: int = Time.get_ticks_usec()
	root.push_input(motion)
	for frame: int in range(3): await process_frame
	var found: bool = false
	for child: Node in root.find_children("*","Label",true,false):
		if child.text == target.tooltip_text and child.is_visible_in_tree(): found = true
	print("Immediate tooltip visible: ",found," after ",(Time.get_ticks_usec()-started)/1000.0," ms / 3 frames. Configured delay: ",ProjectSettings.get_setting("gui/timers/tooltip_delay_sec"))
	assert(found,"Actual contact tooltip must appear after synthetic hover without clicking")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/immediate-contact-tooltip.png")
	quit()
