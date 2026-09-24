extends SceneTree
## Actual surface UI with isolated synthetic states. No autosave or autonomous simulation.
const Session=preload("res://scripts/expedition_session.gd")
const Field=preload("res://scripts/encounter_state.gd")
const Combat=preload("res://scripts/surface_combat.gd")
const Study=preload("res://tests/combat_study_panel.gd")
const Capacity=preload("res://tests/review_field_capacity.gd")
const OUT="res://artifacts/combat-review"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var records: Array=[]
	for stage: String in ["selected","cooldown","no-energy","wrong-target","incoming","hit","disabled","salvaging","full-hold","salvaged"]:
		var game:=Session.new(); game.field.state=Field.fresh("s1p0"); game.field.bind_account(game.sector.state); game.configure_flagship()
		game.field.marks=1200; game.commerce.state.badges.explorer=2; game.commerce.state.badges.merchant=2
		assert(game.commerce.buy_upgrade(game,"basin_port",Field.service_position("basin_port"),"seeker").is_empty())
		var id: String="sentry_a" if stage=="wrong-target" else "watcher"
		var at: Vector3=Combat.home("s1p0",id)+Vector3(-8,3,8)
		game.combat.state.worlds.s1p0=game.combat.world("s1p0"); game.fleet.prepare(game,at)
		if stage=="no-energy": game.field.state.energy=4
		if stage=="cooldown": game.combat.state.ready=game.field.state.time+1
		if stage in ["disabled","salvaging","full-hold","salvaged"]:
			game.combat._damage(game,"s1p0",id,1000)
			at=Combat.position(game.combat.world("s1p0").units[id].at)+Vector3(-5,4,3)
		if stage=="full-hold": game.commerce.add_cargo("alloy",game.commerce.capacity(),"s1p0")
		var view:=SubViewport.new(); view.size_2d_override=Vector2i(1920,1080); view.size_2d_override_stretch=true
		view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
		var scene: Node3D=load("res://scenes/encounter.tscn").instantiate(); scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED
		view.add_child(scene); scene.audio.muted=true; scene.ship.position=at; scene.destination=at
		scene._select_surface_weapon("seeker" if stage=="wrong-target" else "surface_laser")
		scene.surface_selected=id
		var before: Dictionary=game.snapshot().duplicate(true)
		var why: String=""
		if stage in ["cooldown","no-energy","wrong-target"]:
			why=game.combat.reason(game,scene.surface_weapon,id,Vector3.ZERO,at)
			assert(not why.is_empty()); scene._order_surface_attack(id,Combat.home("s1p0",id))
			assert(before==game.snapshot())
		elif stage=="incoming":
			assert(game.combat.step(game,at)=="aim")
		elif stage=="hit":
			assert(game.combat.fire(game,"surface_laser",id,Vector3.ZERO,at).is_empty())
			assert(game.field.state.energy==before.field.energy-5)
			assert(game.combat.world("s1p0").units[id].hull==48)
		elif stage in ["salvaging","full-hold"]:
			scene.surface_weapon=""; scene._order_surface_attack(id,Combat.position(game.combat.world("s1p0").units[id].at))
			why=game.combat.salvage(game,id,at) if stage=="full-hold" else ""
			assert(before==game.snapshot())
			if stage=="full-hold":
				assert(not why.is_empty() and game.combat.salvage(game,id,at)==why and before==game.snapshot())
		elif stage=="salvaged":
			assert(game.combat.salvage(game,id,at).is_empty() and game.commerce.quantity("glass")==1)
		var frozen: Dictionary=game.snapshot().duplicate(true)
		scene.surface_combat_visual.refresh(game,id,0.35,0.1,false); scene._update_camera(1); scene._refresh_ui()
		scene.surface_combat_visual.labels[id].hide()
		for child: Node in scene.get_children():
			if child is CanvasLayer: child.hide()
		var overlay:=CanvasLayer.new(); view.add_child(overlay)
		var study:=Study.new(); study.game=game; study.scene=scene; study.stage=stage; study.target_id=id; study.chart=scene.hud.navigation
		if game.combat.world("s1p0").units[id].hull<=0:
			var probe:=Session.new()
			# Copy synthetic fixture state, not a save-load acceptance test.
			probe.field.state=game.field.state.duplicate(true)
			probe.combat.state=game.combat.state.duplicate(true)
			probe.commerce.state=game.commerce.state.duplicate(true)
			study.salvage_reason=probe.combat.salvage(probe,id,at)
		study.chart.get_parent().remove_child(study.chart); overlay.add_child(study)
		var palette:=Capacity.Study.new(); palette.hud=scene.hud; palette.model=game.field; palette.embedded=true
		scene.hud.palette_expanded=false; overlay.add_child(palette); palette.prepare()
		for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
			view.size=resolution
			for frame: int in range(3): await process_frame
			study.target_screen=scene.camera.unproject_position(Combat.position(game.combat.world("s1p0").units[id].at)); study.ship_screen=scene.camera.unproject_position(scene.ship.position); study.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			assert(view.get_texture().get_image().save_png(OUT+"/proposal-%s-%d.png" % [stage,resolution.y])==OK)
		assert(frozen==game.snapshot(),"Rendering must not tick combat/economy")
		records.append({"stage":stage,"reason":why,"actual_hud":scene.hud.action_state.text,"proposed_state":study.presented_state,"proposed_reason":study.current_reason,"detail":scene.explanation.text,"button":scene.use_button.text,"disabled":scene.use_button.disabled,"energy":game.field.state.energy,"target_hull":game.combat.world("s1p0").units[id].hull})
		view.free()
	var file:=FileAccess.open(OUT+"/proposal.json",FileAccess.WRITE); file.store_string(JSON.stringify(records,"\t"))
	print("Combat proposal:20 captures; command refusals/cost/damage/salvage and immutable capture verified. Native motion/audio not tested.")
	quit()
