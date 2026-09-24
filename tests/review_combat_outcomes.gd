extends SceneTree
## Frozen actual HUD outcomes; explicit scene ticks, isolated fixture, no user saves.
const Session=preload("res://scripts/expedition_session.gd")
const Field=preload("res://scripts/encounter_state.gd")
const Combat=preload("res://scripts/surface_combat.gd")
const Study=preload("res://tests/combat_outcome_study.gd")
const Capacity=preload("res://tests/review_field_capacity.gd")
const OUT="res://artifacts/combat-review"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var records: Array=[]
	var proposal: bool="--proposal" in OS.get_cmdline_user_args()
	var stages: Array[String]=["surface-hit","surface-evaded","surface-tow","civilian-wreck","orbital-target","orbital-low-energy","orbital-cooldown","orbital-disabled","orbital-full-hold","orbital-recovered","morrow-disabled"]
	for stage: String in stages:
		var orbital: bool=stage.begins_with("orbital") or stage=="morrow-disabled"
		var planet: String="morrow" if stage=="morrow-disabled" else "s6p0" if stage=="civilian-wreck" else "s1p0"
		var game:=Session.new(); game.field.state=Field.fresh(planet); game.field.bind_account(game.sector.state); game.configure_flagship()
		game.sector.system_by_id(game.system_of(planet)).visited=true
		if orbital: game.field.change_flight_mode("orbit")
		var id: String="civic" if stage=="civilian-wreck" else "watcher"
		var at: Vector3=game.field.guardian_position()+Vector3(-5,0,5) if orbital else Combat.home(planet,id)+Vector3(-5,3,4)
		if not orbital: game.combat.state.worlds[planet]=game.combat.world(planet)
		if stage=="civilian-wreck":
			game.combat._damage(game,planet,id,1000)
		if stage=="surface-tow": game.field.state.hull=1.0
		var view:=SubViewport.new(); view.size_2d_override=Vector2i(1920,1080) if proposal else Vector2i(1600,900); view.size_2d_override_stretch=true
		view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
		var scene: Node3D=load("res://scenes/encounter.tscn").instantiate()
		scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED; view.add_child(scene)
		scene.audio.muted=true; scene.save_path=OUT+"/isolated-outcomes.json"
		scene.ship.position=at; scene.destination=at
		var reason: String=""
		if orbital:
			scene.weapon_selected=true; scene.hud.select_tool("lance"); scene.orbital_target="guardian"
			if stage in ["orbital-disabled","orbital-full-hold","orbital-recovered","morrow-disabled"]:
				while not game.field.state.guardian_disabled:
					assert(game.fire_weapon(at).is_empty())
					game.tick(); game.tick()
				if stage=="orbital-full-hold":
					game.commerce.add_cargo("alloy",game.commerce.capacity(),planet)
					var before: Dictionary=game.snapshot()
					reason=game.salvage_enemy(at)
					assert(not reason.is_empty() and before==game.snapshot())
					scene._command_guardian(); scene._operate_attack()
				elif stage=="orbital-recovered":
					assert(game.salvage_enemy(at).is_empty())
					assert(game.field.state.guardian_salvaged and game.commerce.used_space(game)==2)
				elif stage=="morrow-disabled":
					reason=game.salvage_enemy(at)
					assert(reason=="No recoverable enemy cargo here.")
			elif stage=="orbital-low-energy":
				game.field.state.energy=9
				var before: Dictionary=game.snapshot()
				scene._command_guardian(); reason=game.field.lance_reason(at)
				assert(not reason.is_empty() and before==game.snapshot())
			elif stage=="orbital-cooldown":
				scene._command_guardian(); scene._operate_attack()
				reason=game.field.lance_reason(at)
				assert(reason=="Arc lance recharging." and game.field.state.energy==90)
		else:
			scene._select_surface_weapon("surface_laser"); scene.surface_selected=id
			if stage=="civilian-wreck":
				var before: Dictionary=game.snapshot()
				reason=game.combat.salvage(game,id,at)
				assert(reason=="Civil infrastructure is not ship salvage." and before==game.snapshot())
			else:
				assert(game.combat.step(game,at)=="aim")
				if stage=="surface-evaded": scene.ship.position+=Vector3.UP*16
				for tick: int in range(3):
					scene._process(1.0)
					if game.field.state.tow_count>0: break
				if stage=="surface-evaded": assert(game.field.state.hull==100)
				elif stage=="surface-hit": assert(game.field.state.hull<100 and game.field.state.tow_count==0)
				else: assert(game.field.state.tow_count==1 and game.field.state.hull==35 and game.field.state.energy<=15)
		var frozen: Dictionary=game.snapshot().duplicate(true)
		scene._update_camera(1); scene._refresh_ui(); scene._update_visuals()
		if not orbital: scene.surface_combat_visual.refresh(game,id,0.35,0.1,false)
		var study: Control=null
		if proposal:
			for child: Node in scene.get_children():
				if child is CanvasLayer: child.hide()
			var overlay:=CanvasLayer.new(); view.add_child(overlay)
			study=Study.new(); study.game=game; study.scene=scene; study.stage=stage; study.refusal=reason
			if not orbital:
				study.chart=scene.hud.navigation; study.chart.get_parent().remove_child(study.chart)
				scene.surface_combat_visual.labels[id].hide()
			overlay.add_child(study)
			var palette:=Capacity.Study.new(); palette.hud=scene.hud; palette.model=game.field; palette.embedded=true
			scene.hud.palette_expanded=false; overlay.add_child(palette); palette.prepare()
		for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
			view.size=resolution
			for frame: int in range(3): await process_frame
			if proposal:
				study.target_screen=scene.camera.unproject_position(game.field.guardian_position() if orbital else Combat.position(game.combat.world(planet).units[id].at))
				study.wreck_screen=scene.camera.unproject_position(Field.WRECK_POSITION)
				study.ship_screen=scene.camera.unproject_position(scene.ship.position); study.queue_redraw()
				await process_frame
			await RenderingServer.frame_post_draw
			assert(view.get_texture().get_image().save_png(OUT+"/%s-%s-%d.png" % ["proposal" if proposal else "current",stage,resolution.y])==OK)
		assert(frozen==game.snapshot(),"Capture cannot advance the campaign")
		records.append({"stage":stage,"planet":planet,"reason":reason,"hud":scene.hud.action_state.text,"detail":scene.explanation.text,"button":scene.use_button.text,"disabled":scene.use_button.disabled,"status":scene.status.text,"hull":game.field.state.hull,"energy":game.field.state.energy,"tow_count":game.field.state.tow_count,"cargo":game.commerce.used_space(game)})
		if proposal: records.back().merge({"proposed_heading":study.heading,"proposed_action":study.action,"proposed_action_enabled":study.action_enabled})
		view.free()
	var file:=FileAccess.open(OUT+("/outcome-proposals.json" if proposal else "/outcomes.json"),FileAccess.WRITE); file.store_string(JSON.stringify(records,"\t"))
	print("Combat outcomes:22 %s captures; hit/evasion/tow/refusal and salvage semantics verified. No native play or audio acceptance." % ("proposed" if proposal else "actual"))
	quit()
