extends SceneTree
const Session=preload("res://scripts/expedition_session.gd")
const OUT="res://artifacts/pause-settings-review"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var manifest: Array=[]
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		for tag: String in ["menu","controls","audio","audio-muted","save-success","load-success","load-missing","load-corrupt"]:
			var game:=Session.new()
			var view:=SubViewport.new(); view.size=resolution; view.size_2d_override=Vector2i(1600,900); view.size_2d_override_stretch=true
			view.own_world_3d=true; view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
			var scene: Node3D=load("res://scenes/encounter.tscn").instantiate(); scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED
			view.add_child(scene); scene.audio.muted=true
			scene.save_path=OUT+"/"+tag+".json"; scene.audio.settings_path=OUT+"/isolated-audio.cfg"
			# Explicit review mix; never inherit a previous test run's preferences.
			scene.audio.mix={"sfx":0.8,"music":0.45,"voice":0.75}
			scene._show_popup("menu")
			assert(scene._inspection_open())
			if tag in ["controls","audio","audio-muted"]:
				scene._menu_page("controls" if tag=="controls" else "audio")
				assert(scene.menu_return)
				if tag=="audio-muted":
					for slider: Node in scene.popup_body.find_children("*","HSlider",true,false): slider.value=0
					assert(scene.audio.mix.sfx==0 and scene.audio.mix.music==0 and scene.audio.mix.voice==0)
					assert(scene.audio.save_settings()==OK)
					var config:=ConfigFile.new(); assert(config.load(scene.audio.settings_path)==OK)
					assert(config.get_value("mix","music")==0)
			elif tag=="save-success":
				scene._save(); assert(FileAccess.file_exists(scene._campaign_path(false)))
			elif tag=="load-success":
				scene._save(); var saved: Dictionary=game.snapshot()
				game.field.marks+=123; scene._load(); scene._close_popup()
				assert(game.snapshot()==saved)
			elif tag in ["load-missing","load-corrupt"]:
				var path: String=scene._campaign_path(false)
				if FileAccess.file_exists(path): assert(DirAccess.remove_absolute(path)==OK)
				if tag=="load-corrupt":
					var broken:=FileAccess.open(path,FileAccess.WRITE); broken.store_string("Invalid review fixture"); broken.close()
				var before: Dictionary=game.snapshot()
				# Same calls as the actual menu's Load callback; captures its close-on-failure behavior.
				scene._load(); scene._close_popup(); assert(game.snapshot()==before)
			scene._update_camera(1); scene._refresh_ui()
			scene.status.visible=scene.toast_time>0
			var stable: Dictionary=game.snapshot()
			for frame: int in range(5): await process_frame
			await RenderingServer.frame_post_draw
			assert(game.snapshot()==stable)
			assert(view.get_texture().get_image().save_png(OUT+"/actual-%s-%d.png" % [tag,resolution.y])==OK)
			var labels: Array=[]
			for node: Node in scene.popup_body.find_children("*","Label",true,false): labels.append(node.text)
			manifest.append({"state":tag,"height":resolution.y,"labels":labels,"popup_visible":scene.popup.visible,"status":scene.status.text,"mix":scene.audio.mix.duplicate()})
			if tag in ["controls","audio","audio-muted"]:
				scene._escape_menu(); assert(scene.popup.visible and scene.popup_kind=="menu")
				scene._escape_menu(); assert(not scene.popup.visible)
			view.free()
	var file:=FileAccess.open(OUT+"/baseline.json",FileAccess.WRITE); file.store_string(JSON.stringify(manifest,"\t")); file.close()
	print("Pause/settings:16 captures; isolated saves, failed-load invariance, successful restore, audio settings and Escape return checked. No native input or audio listening proof.")
	quit()
