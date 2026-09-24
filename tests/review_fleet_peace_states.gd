extends SceneTree
const Session=preload("res://scripts/expedition_session.gd")
const Field=preload("res://scripts/encounter_state.gd")
const OUT="res://artifacts/fleet-peace-review"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var manifest: Array=[]
	var proposal: bool="--proposal" in OS.get_cmdline_user_args()
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		for tag: String in ["no-alliance","no-slot","available","active","damaged","repair-poor","repaired","returned","lost-wait","replacement-poor","replaced","war-confirm","war","peace-poor","peace-paid"]:
			var game:=Session.new(); game.field.state=Field.fresh("s7p0"); game.field.bind_account(game.sector.state); game.configure_flagship()
			game.field.change_flight_mode("orbit"); game.field.marks=500
			game.diplomacy.contact(game,"consortium"); game.sector.faction_by_id("consortium").relation=60
			var at: Vector3=Field.service_position("orbit_tender")
			var conflict: bool=tag in ["war-confirm","war","peace-poor","peace-paid"]
			if tag!="no-alliance": assert(game.diplomacy.act(game,"consortium","alliance").is_empty())
			game.commerce.state.badges.explorer=0 if tag=="no-slot" else 1
			if tag in ["active","damaged","repair-poor","repaired","returned","lost-wait","replacement-poor","replaced"]:
				assert(game.fleet.command(game,"consortium","recruit",at).is_empty())
				assert(game.field.marks==500 and game.fleet.active_ids().size()==1)
			if tag in ["damaged","repair-poor","repaired","returned"]:
				game.fleet.state.ships.consortium.hull=37.0
				if tag=="repair-poor": game.field.marks=0
				if tag=="repaired":
					var cost: int=game.fleet.repair_cost("consortium")
					assert(game.fleet.command(game,"consortium","repair",at).is_empty())
					assert(game.field.marks==500-cost and game.fleet.state.ships.consortium.hull==game.fleet.catalog.consortium.hull)
				if tag=="returned":
					assert(game.fleet.command(game,"consortium","dismiss",at).is_empty())
					assert(game.fleet.state.ships.consortium.hull==37 and game.fleet.active_ids().is_empty())
			if tag in ["lost-wait","replacement-poor","replaced"]:
				game.fleet.hit_volume(game,at,1,10000)
				assert(game.fleet.state.ships.consortium.status=="lost" and game.sector.faction_by_id("consortium").relation==58)
				if tag!="lost-wait": game.field.state.time+=60
				if tag=="replacement-poor": game.field.marks=0
				if tag=="replaced":
					assert(game.fleet.command(game,"consortium","recruit",at).is_empty())
					assert(game.field.marks==380 and game.fleet.active_ids().size()==1)
			if conflict and tag!="war-confirm":
				assert(game.conflict.command(game,"consortium","declare").is_empty())
				assert("consortium:alliance" not in game.sector.state.agreements)
				if tag=="peace-poor": game.field.marks=0
				if tag=="peace-paid":
					assert(game.conflict.command(game,"consortium","peace").is_empty())
					assert(game.field.marks==250 and not game.conflict.at_war("consortium"))
					assert(game.conflict.nation("consortium").truce==game.field.state.time+300)
			var reasons: Dictionary={}
			for action: String in (["declare","peace"] if conflict else ["recruit","repair","dismiss"]):
				var reason: String=game.conflict.reason(game,"consortium",action) if conflict else game.fleet.reason(game,"consortium",action,at)
				reasons[action]=reason
				if not reason.is_empty():
					var before: Dictionary=game.snapshot()
					var result: String=game.conflict.command(game,"consortium",action) if conflict else game.fleet.command(game,"consortium",action,at)
					assert(result==reason and game.snapshot()==before)
			var view:=SubViewport.new(); view.size=resolution; view.size_2d_override=Vector2i(1600,900); view.size_2d_override_stretch=true
			view.own_world_3d=true; view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
			var scene: Node3D=load("res://scenes/encounter.tscn").instantiate(); scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED
			view.add_child(scene); scene.audio.muted=true; scene.save_path=OUT+"/isolated-save.json"; scene.ship.position=at
			if conflict:
				if tag=="war-confirm": scene.conflict_view.confirm_war="consortium"
				scene._show_popup("conflict")
			else:
				scene._contact_select("consortium"); scene.contact_page="fleet"; scene._show_popup("contact")
			scene._update_camera(1); scene._refresh_ui()
			if proposal:
				for child: Node in scene.get_children():
					if child is CanvasLayer: child.hide()
				view.size_2d_override=Vector2i(1920,1080)
				var overlay:=CanvasLayer.new(); view.add_child(overlay)
				var study:=preload("res://tests/fleet_peace_study_panel.gd").new()
				study.game=game; study.scene=scene; study.stage=tag; study.conflict=conflict; overlay.add_child(study)
			var stable: Dictionary=game.snapshot()
			for frame: int in range(5): await process_frame
			await RenderingServer.frame_post_draw
			assert(game.snapshot()==stable)
			assert(view.get_texture().get_image().save_png(OUT+"/%s-%s-%d.png" % ["proposal" if proposal else "actual",tag,resolution.y])==OK)
			var buttons: Array=[]
			for node: Node in scene.popup_body.find_children("*","Button",true,false): buttons.append({"text":node.text,"disabled":node.disabled,"tooltip":node.tooltip_text})
			manifest.append({"state":tag,"height":resolution.y,"reasons":reasons,"marks":game.field.marks,"fleet":game.fleet.state.duplicate(true),"nation":game.conflict.nation("consortium").duplicate(true),"buttons":buttons})
			view.free()
	var file:=FileAccess.open(OUT+("/proposals.json" if proposal else "/baseline.json"),FileAccess.WRITE); file.store_string(JSON.stringify(manifest,"\t")); file.close()
	print("Fleet/peace baseline:30 captures; costs, loss, replacement, preserved damage, truce and refusal invariants verified. Frozen fixtures; not native play.")
	quit()
