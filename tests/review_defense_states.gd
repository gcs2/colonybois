extends SceneTree
const Session=preload("res://scripts/expedition_session.gd")
const Field=preload("res://scripts/encounter_state.gd")
const OUT="res://artifacts/defense-review"
func _initialize() -> void: call_deferred("run")
func advance(game: RefCounted, seconds: int) -> void:
	# Explicit subsystem clock: exercise raid rules without unrelated economy ticks.
	for i: int in range(seconds):
		game.field.state.time+=1; game.conflict.tick(game)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var manifest: Array=[]
	var proposal: bool="--proposal" in OS.get_cmdline_user_args()
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		for tag: String in ["quiet","warning","inbound","attacking","damaged","disabled","repaired","battery","rearm-poor","rearmed","defended","peace-withdrawn"]:
			var game:=Session.new(); game.field.change_flight_mode("orbit"); game.field.marks=1000
			game.sector.state.colonies.s0p0.materials=500
			game.diplomacy.contact(game,"directorate")
			if tag=="warning":
				game.sector.faction_by_id("directorate").relation=-60; advance(game,1)
				assert(game.conflict.nation("directorate").warning==91 and not game.conflict.at_war("directorate"))
			if tag in ["battery","rearm-poor","rearmed","defended"]:
				assert(game.conflict.command(game,"s0p0","battery").is_empty())
				assert(game.field.marks==820 and game.sector.state.colonies.s0p0.materials==440)
			if tag in ["inbound","attacking","damaged","disabled","repaired","defended","peace-withdrawn"]:
				assert(game.conflict.command(game,"directorate","declare").is_empty()); advance(game,1)
				assert(game.conflict.state.raid.phase=="inbound")
				if tag!="inbound": advance(game,90)
				if tag in ["damaged","peace-withdrawn"]: advance(game,15); assert(game.conflict.site("morrow").integrity==80)
				if tag in ["disabled","repaired"]: advance(game,75); assert(game.conflict.site("morrow").integrity==0 and game.conflict.state.raid.is_empty())
				if tag=="repaired":
					assert(game.conflict.command(game,"s0p0","repair").is_empty())
					assert(game.field.marks==920 and game.sector.state.colonies.s0p0.materials==480 and game.conflict.site("morrow").integrity==100)
				if tag=="defended": advance(game,60); assert(game.conflict.state.raid.is_empty() and not game.conflict.state.defended.is_empty())
				if tag=="peace-withdrawn":
					assert(game.conflict.command(game,"directorate","peace").is_empty())
					assert(game.field.marks==750 and game.conflict.site("morrow").integrity==80 and game.conflict.state.raid.is_empty() and game.conflict.state.defended.is_empty())
			if tag in ["rearm-poor","rearmed"]:
				game.conflict.state.sites.s0p0.ammo=0 # Explicit depleted-ammunition fixture.
				if tag=="rearm-poor": game.field.marks=0
				else:
					assert(game.conflict.command(game,"s0p0","rearm").is_empty())
					assert(game.field.marks==760 and game.sector.state.colonies.s0p0.materials==420 and game.conflict.site("morrow").ammo==12)
			var reasons: Dictionary={}
			for action: String in ["battery","rearm","repair"]:
				reasons[action]=game.conflict.reason(game,"s0p0",action)
				if not reasons[action].is_empty():
					var before: Dictionary=game.snapshot()
					assert(game.conflict.command(game,"s0p0",action)==reasons[action] and game.snapshot()==before)
			var view:=SubViewport.new(); view.size=resolution; view.size_2d_override=Vector2i(1600,900); view.size_2d_override_stretch=true
			view.own_world_3d=true; view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
			var scene: Node3D=load("res://scenes/encounter.tscn").instantiate(); scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED
			view.add_child(scene); scene.audio.muted=true; scene.save_path=OUT+"/isolated-save.json"; scene.ship.position=Field.service_position("orbit_tender")
			scene.contacted_faction="directorate"; scene._show_popup("conflict"); scene._update_camera(1); scene._refresh_ui()
			if proposal:
				for child: Node in scene.get_children():
					if child is CanvasLayer: child.hide()
				view.size_2d_override=Vector2i(1920,1080)
				var overlay:=CanvasLayer.new(); view.add_child(overlay)
				var study:=preload("res://tests/defense_study_panel.gd").new()
				study.game=game; study.scene=scene; study.stage=tag; overlay.add_child(study)
			var stable: Dictionary=game.snapshot()
			for frame: int in range(5): await process_frame
			await RenderingServer.frame_post_draw
			assert(game.snapshot()==stable)
			assert(view.get_texture().get_image().save_png(OUT+"/%s-%s-%d.png" % ["proposal" if proposal else "actual",tag,resolution.y])==OK)
			var buttons: Array=[]
			for node: Node in scene.popup_body.find_children("*","Button",true,false): buttons.append({"text":node.text,"disabled":node.disabled,"tooltip":node.tooltip_text})
			manifest.append({"state":tag,"height":resolution.y,"reasons":reasons,"marks":game.field.marks,"materials":game.sector.state.colonies.s0p0.materials,"conflict":game.conflict.state.duplicate(true),"buttons":buttons})
			view.free()
	var file:=FileAccess.open(OUT+("/proposals.json" if proposal else "/baseline.json"),FileAccess.WRITE); file.store_string(JSON.stringify(manifest,"\t")); file.close()
	print("Defense baseline:24 captures; explicit raid clock, damage, finite ammo, costs, peace aftermath and refusal invariants verified. Not native play.")
	quit()
