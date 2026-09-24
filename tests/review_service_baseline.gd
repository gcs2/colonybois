extends SceneTree
## Actual dock supplies and inventory recovery, isolated campaigns; no user saves.
const Session=preload("res://scripts/expedition_session.gd")
const Field=preload("res://scripts/encounter_state.gd")
const OUT="res://artifacts/service-review"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var records: Array=[]
	for stage: String in ["home-free","home-recharged","away-paid","unaffordable","energy-full","pack-sold-out","pack-locker-full","out-of-range","embargo","repair-locked","recharged","repair-purchased","repair-used"]:
		var game:=Session.new()
		var planet: String="morrow" if stage.begins_with("home-") else "s7p0"
		game.field.state=Field.fresh(planet); game.field.bind_account(game.sector.state); game.configure_flagship()
		game.field.change_flight_mode("orbit"); game.field.state.energy=15.0; game.field.state.hull=35.0; game.field.marks=500
		if planet!="morrow": game.diplomacy.contact(game,"consortium")
		var at: Vector3=Field.service_position("orbit_tender")
		var action: String="recharge"
		if stage=="unaffordable": game.field.marks=0
		if stage=="energy-full": game.field.state.energy=100.0
		if stage=="pack-sold-out": game.field.state.service_stock.orbit_tender=0; action="pack"
		if stage=="pack-locker-full": game.field.state.energy_packs=3; action="pack"
		if stage=="out-of-range": at+=Vector3(0,0,20)
		if stage=="embargo": game.sector.faction_by_id("consortium").embargo=true
		if stage=="repair-locked": action="mega_repair_pack"
		if stage in ["repair-purchased","repair-used"]: action="repair_pack"
		var before: Dictionary=game.snapshot()
		var quote: int=game.field.recharge_price("orbit_tender")
		var reason: String=game.service_reason("orbit_tender",at,action)
		var transaction: bool=stage in ["home-recharged","recharged","repair-purchased","repair-used"]
		if not reason.is_empty():
			assert(game.purchase_service("orbit_tender",at,action)==reason and before==game.snapshot())
		elif transaction:
			assert(game.purchase_service("orbit_tender",at,action).is_empty())
			if action=="recharge":
				assert(game.field.state.energy==100 and game.field.marks==before.sector.credits-quote)
			else:
				assert(game.field.state.hull==35 and game.field.state.repair_packs.repair_pack==1)
				assert(game.field.marks==before.sector.credits-game.field.local_services().orbit_tender.repair_prices.repair_pack)
			if stage=="repair-used":
				assert(game.field.use_repair_pack("repair_pack").is_empty())
				assert(game.field.state.hull==100 and game.field.state.energy==15 and game.field.state.repair_packs.repair_pack==0)
		var view:=SubViewport.new(); view.size_2d_override=Vector2i(1600,900); view.size_2d_override_stretch=true
		view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
		var scene: Node3D=load("res://scenes/encounter.tscn").instantiate(); scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED
		view.add_child(scene); scene.audio.muted=true; scene.save_path=OUT+"/isolated-review.json"
		scene.ship.position=at; scene.selected_service="orbit_tender"; scene.dock_page="energy"
		scene._update_camera(1); scene._refresh_ui(); scene._show_popup("cargo" if stage=="repair-used" else "service")
		var frozen: Dictionary=game.snapshot().duplicate(true)
		for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
			view.size=resolution
			for frame: int in range(5): await process_frame
			if stage=="repair-locked":
				for control: Node in scene.popup_body.find_children("*","ScrollContainer",true,false): control.scroll_vertical=99999
				await process_frame
			await RenderingServer.frame_post_draw
			assert(view.get_texture().get_image().save_png(OUT+"/current-%s-%d.png" % [stage,resolution.y])==OK)
		assert(frozen==game.snapshot(),"Rendering cannot advance or spend campaign resources")
		var buttons: Array=[]
		for control: Node in scene.popup_body.find_children("*","Button",true,false):
			buttons.append({"text":control.text,"disabled":control.disabled,"tooltip":control.tooltip_text})
		records.append({"stage":stage,"planet":planet,"action":action,"reason":reason,"quoted_refuel":quote,"transaction":transaction,"marks_before":before.sector.credits,"marks_after":game.field.marks,"hull":game.field.state.hull,"energy":game.field.state.energy,"repair_packs":game.field.state.repair_packs.duplicate(),"buttons":buttons})
		view.free()
	var file:=FileAccess.open(OUT+"/baseline.json",FileAccess.WRITE); file.store_string(JSON.stringify(records,"\t"))
	print("Service baseline:26 captures; atomic refusals, free/paid recharge, separate pack purchase/use and immutable render verified.")
	quit()
