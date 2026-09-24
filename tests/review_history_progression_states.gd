extends SceneTree
const Session=preload("res://scripts/expedition_session.gd")
const Recognition=preload("res://scripts/expedition_progression.gd")
const OUT="res://artifacts/history-progression-review"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var manifest: Array=[]
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		for tag: String in ["history-empty","history-populated","history-diplomacy","history-filter-empty","history-page-two","badges-fresh","badges-earned","upgrade-eligible-poor","upgrade-installed","notice-enter","notice-settled","notice-dismissed"]:
			var game:=Session.new()
			if tag in ["history-populated","history-diplomacy","history-filter-empty","history-page-two"]:
				game.diplomacy.contact(game,"consortium"); game.sector.faction_by_id("consortium").relation=60
				assert(game.diplomacy.act(game,"consortium","trade").is_empty())
				assert(game.diplomacy.act(game,"consortium","alliance").is_empty())
				if tag=="history-page-two":
					for i: int in range(20): game.diplomacy.record(game,"exploration","Review fixture observation %d" % (i+1),"",{"fixture":true})
			if tag in ["badges-earned","upgrade-eligible-poor","upgrade-installed"]:
				for id: String in ["moss_lantern","ribbon_bush","hollow_crown"]: assert(game.biosphere.act(game,id,"scan",game.biosphere.site("morrow",id)).is_empty())
				assert(game.commerce.state.badges.naturalist==1 and game.commerce.eligible("hold") and game.commerce.state.upgrades.is_empty())
				game.recognition.state.pinned="naturalist"; game.field.marks=0
				var before: Dictionary=game.snapshot(); game.commerce.update_badges(game); assert(game.snapshot()==before)
				if tag=="upgrade-installed":
					game.field.marks=120
					assert(game.commerce.buy_upgrade(game,"basin_port",game.field.service_position("basin_port"),"hold").is_empty())
					assert(game.field.marks==0 and game.commerce.capacity()==16)
			if tag.begins_with("notice"):
				# Explicit visited-system fixture triggers the real recognition award.
				for i: int in range(3): game.sector.state.systems[i].visited=true
				game.commerce.update_badges(game); assert(game.commerce.state.badges.explorer>=1)
			var view:=SubViewport.new(); view.size=resolution; view.size_2d_override=Vector2i(1600,900); view.size_2d_override_stretch=true
			view.own_world_3d=true; view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
			var scene: Node3D=load("res://scenes/encounter.tscn").instantiate(); scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED
			view.add_child(scene); scene.audio.muted=true; scene.save_path=OUT+"/isolated-save.json"; scene.ship.position=game.field.service_position("basin_port")
			if tag.begins_with("history"):
				scene.chronicle_filter="diplomacy" if tag=="history-diplomacy" else "war" if tag=="history-filter-empty" else "all"
				scene.chronicle_page=1 if tag=="history-page-two" else 0; scene._show_popup("journal")
			elif tag.begins_with("notice"):
				scene._close_popup(); scene.recognition_notice.present({"kind":"badge","id":"explorer","tier":1},game)
				scene.recognition_notice.advance(0.15 if tag=="notice-enter" else 0.6 if tag=="notice-settled" else 4.1,false)
				assert(scene.recognition_notice.visible==(tag!="notice-dismissed"))
			elif tag=="upgrade-eligible-poor":
				scene.selected_service="basin_port"; scene.dock_page="upgrades"; scene.upgrade_preview="hold"; scene._show_popup("service")
			else: scene._show_popup("badges")
			scene._update_camera(1); scene._refresh_ui()
			var stable: Dictionary=game.snapshot()
			for frame: int in range(5): await process_frame
			await RenderingServer.frame_post_draw
			assert(game.snapshot()==stable)
			assert(view.get_texture().get_image().save_png(OUT+"/actual-%s-%d.png" % [tag,resolution.y])==OK)
			var labels: Array=[]
			for node: Node in scene.popup_body.find_children("*","Label",true,false): labels.append(node.text)
			manifest.append({"state":tag,"height":resolution.y,"events":game.diplomacy.state.events.duplicate(true),"badges":game.commerce.state.badges.duplicate(),"upgrades":game.commerce.state.upgrades.duplicate(),"marks":game.field.marks,"labels":labels,"notice_visible":scene.recognition_notice.visible,"notice_alpha":scene.recognition_notice.modulate.a})
			view.free()
	var file:=FileAccess.open(OUT+"/baseline.json",FileAccess.WRITE); file.store_string(JSON.stringify(manifest,"\t")); file.close()
	print("History/progression:24 captures; earned eligibility, paid installation, repeat-award invariance and sampled notice lifecycle. Frozen render; not native play.")
	quit()
