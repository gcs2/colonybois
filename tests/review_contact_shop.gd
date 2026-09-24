extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
func _initialize() -> void: call_deferred("run")
func catalogue(scene: Node) -> Node:
	for child: Node in scene.popup_body.find_children("*","HBoxContainer",true,false):
		if child.get_script() == preload("res://scripts/upgrade_shop.gd"): return child
	return null
func run() -> void:
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		var view := SubViewport.new()
		view.size = resolution; view.size_2d_override = Vector2i(1600,900)
		view.size_2d_override_stretch = true; view.own_world_3d = true
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		view.gui_disable_input = true
		root.add_child(view)
		var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
		scene.campaign = Session.new()
		scene.campaign.field.state.planet_id = "s7p0"
		scene.campaign.field.change_flight_mode("orbit")
		view.add_child(scene)
		scene.save_path = "res://artifacts/contact-shop-review.json"
		scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
		scene.set_process_input(false); scene.set_process_unhandled_input(false)
		scene.campaign.field.marks = 300
		scene.campaign.diplomacy.contact(scene.campaign,"consortium")
		scene.ship.position = scene.Model.service_position("orbit_tender")
		scene._contact_select("consortium")
		for frame: int in range(8): await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/contact-first-%d.png" % resolution.x)
		scene._contact_dock()
		scene._update_camera(1); scene._refresh_ui()
		for page: String in ["market","energy","upgrades"]:
			scene.dock_page = page; scene._show_popup("service")
			for frame: int in range(8): await process_frame
			await RenderingServer.frame_post_draw
			view.get_texture().get_image().save_png("res://artifacts/contact-shop-%s-%d.png" % [page,resolution.x])
			print("Shop capture ",page," ",resolution," popup ",scene.popup.get_global_rect())
			var row: Node = scene.popup_body.get_node("ServiceContents")
			var scroll: Control = row.get_child(1)
			var goods: Control = scroll.get_child(0)
			print("Columns: ",scroll.size," goods ",goods.size," minimum ",goods.get_combined_minimum_size())
			for child: Node in goods.get_children():
				if child is Label: assert(child.size.x <= goods.size.x,"Description exceeds commerce column")
		# Explicit progressed fixture: an earned Merchant tier and funded treasury.
		# The subsequent purchase is the real validated UI command.
		scene.campaign.commerce.state.badges.merchant = 1
		scene.campaign.field.marks = 1000
		scene.upgrade_preview = "hold"; scene._show_popup("service")
		scene._refresh_ui()
		for frame: int in range(8): await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/contact-shop-available-%d.png" % resolution.x)
		assert(not catalogue(scene).purchase_button.disabled)
		catalogue(scene).purchase_button.pressed.emit()
		scene._refresh_ui()
		for frame: int in range(8): await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/contact-shop-purchased-%d.png" % resolution.x)
		assert(catalogue(scene).purchase_button.disabled and scene.campaign.commerce.capacity() == 16)
		scene._show_popup("contact")
		for frame: int in range(8): await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/contact-portrait-%d.png" % resolution.x)
		scene._close_popup(); scene._contact_select("consortium")
		for frame: int in range(8): await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/contact-repeat-%d.png" % resolution.x)
		scene.campaign.conflict.command(scene.campaign,"consortium","declare")
		scene._close_popup(); scene._contact_select("consortium")
		for frame: int in range(8): await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/contact-war-%d.png" % resolution.x)
		scene.free(); view.free()
	quit()
