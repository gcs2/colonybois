extends SceneTree
## Actual release UI baseline and command/state audit. No player saves or autonomous ticks.
const Session=preload("res://scripts/expedition_session.gd")
const OUT="res://artifacts/release-review"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var records: Array=[]
	for stage: String in ["armed","approach","beam","released","duplicate","no-food","no-energy","cancelled"]:
		var game:=Session.new(); game.field.state.energy=40
		game.field.state.survey_ticks=game.field.definition().survey_seconds
		var id: String="moss_lantern" if stage=="duplicate" else "snow_bell" if stage=="no-food" else "glass_moss"
		game.biosphere.state.cargo[id]=1; game.biosphere.state.catalogued.append(id)
		if stage=="no-energy": game.field.state.energy=4
		var ground:=Vector3(8,0,4)
		ground.y=game.biosphere.Geography.surface_height(game.field.definition(),ground.x,ground.z)+1.5
		var ship_at:=ground+Vector3(0,5,3)
		game.fleet.prepare(game,ship_at)
		var before: Dictionary=game.snapshot().duplicate(true)
		var view:=SubViewport.new(); view.size_2d_override=Vector2i(1600,900); view.size_2d_override_stretch=true
		view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
		var scene: Node3D=load("res://scenes/encounter.tscn").instantiate()
		scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED; view.add_child(scene); scene.audio.muted=true
		scene.ship.position=ship_at; scene.destination=ship_at; scene.navigating=false
		scene.biosphere_view.select_specimen(id)
		assert(scene.biosphere_view.deploy_id==id)
		assert(before==game.snapshot(),"Arming release must not spend resources")
		var why: String=game.biosphere.reason(game,id,"release",ship_at,ground)
		if stage in ["duplicate","no-food","no-energy"]:
			assert(not why.is_empty())
			scene.biosphere_view.order(id,"release",ground)
			assert(scene.biosphere_view.deploy_id.is_empty() and scene.biosphere_view.action.is_empty())
			assert(scene.biosphere_view.selected==id,"Baseline refusal retains stale specimen selection")
			assert(game.biosphere.act(game,id,"release",ship_at,ground)==why)
			assert(before==game.snapshot(),"Refusal must preserve campaign")
		elif stage=="cancelled":
			scene._select_tool("scan")
			assert(scene.biosphere_view.deploy_id.is_empty() and scene.biosphere_view.selected.is_empty())
		elif stage!="armed":
			assert(why.is_empty())
			scene.biosphere_view.order(id,"release",ground)
			assert(scene.biosphere_view.action=="release" and scene.navigating)
			assert(before==game.snapshot(),"Approach must not spend resources")
			if stage=="beam": scene.navigating=false; scene.biosphere_view.progress=0.75
			if stage=="released":
				assert(game.biosphere.act(game,id,"release",ship_at,ground).is_empty())
				assert(game.field.state.energy==35 and game.biosphere.used()==0)
				assert(game.biosphere.world("morrow").stock[id]==1 and game.biosphere.site("morrow",id)==ground)
				scene.navigating=false; scene.biosphere_view.action=""; scene.biosphere_view.progress=0
				scene._toast(game.biosphere.data()[id].name+" established")
		if stage!="released": assert(before==game.snapshot(),"Uncommitted release states and cancellation must preserve campaign")
		var rendered_snapshot: Dictionary=game.snapshot().duplicate(true)
		scene.biosphere_view.refresh(0,true); scene._update_camera(1); scene._refresh_ui()
		for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
			view.size=resolution
			for frame: int in range(3): await process_frame
			await RenderingServer.frame_post_draw
			assert(view.get_texture().get_image().save_png(OUT+"/current-%s-%d.png" % [stage,resolution.y])==OK)
		assert(rendered_snapshot==game.snapshot(),"Capture must not tick or mutate campaign")
		records.append({"state":stage,"species":id,"reason":why,"energy":game.field.state.energy,"cargo":game.biosphere.used(),"armed":scene.biosphere_view.deploy_id,"selected":scene.biosphere_view.selected,"action":scene.biosphere_view.action,"hud_state":scene.hud.action_state.text})
		view.free()
	var file:=FileAccess.open(OUT+"/evidence.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"kind":"Actual UI with synthetic fixtures; direct selection/order and model success; midpoint beam; no native input, elapsed action or audio proof","states":records},"\t"))
	print("Release baseline:16 captures; arming/approach/refusal/cancellation resource invariants and successful release debits verified.")
	quit()
