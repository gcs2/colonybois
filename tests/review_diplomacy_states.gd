extends SceneTree
const Session=preload("res://scripts/expedition_session.gd")
const Field=preload("res://scripts/encounter_state.gd")
const OUT="res://artifacts/diplomacy-review"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var manifest: Array=[]
	var proposal: bool="--proposal" in OS.get_cmdline_user_args()
	var fidelity: bool="--fidelity" in OS.get_cmdline_user_args()
	var detail: bool="--globe-detail" in OS.get_cmdline_user_args()
	var relief: bool="--relief-study" in OS.get_cmdline_user_args()
	var materials: bool="--material-study" in OS.get_cmdline_user_args()
	assert(not materials or relief,"Material comparison requires the relief fixture")
	assert(not detail or fidelity,"Globe comparison requires the fixed fidelity camera")
	assert(not relief or detail,"Relief comparison requires the detail texture fixture")
	var map_width: int=1024 if relief else 2048 if detail else 512
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		for tag: String in ["first","repeat","agreements","trade-signed","alliance-ready","alliance-signed","withdrawn","embargo","exchange-poor","gift-spent","chart-own-territory","war"]:
			if fidelity and tag not in ["first","agreements"]: continue
			if detail and tag!="first": continue
			var game:=Session.new(); game.field.state=Field.fresh("s7p0"); game.field.bind_account(game.sector.state); game.configure_flagship()
			game.field.change_flight_mode("orbit"); game.field.marks=300
			game.diplomacy.contact(game,"consortium")
			var faction: Dictionary=game.sector.faction_by_id("consortium")
			faction.relation=0; faction.embargo=false
			var page: String="home" if tag in ["first","repeat"] else "exchange" if tag in ["exchange-poor","gift-spent","chart-own-territory"] else "agreements"
			if tag!="first": game.diplomacy.answer(game,"consortium")
			if tag in ["alliance-ready","alliance-signed","withdrawn"]: faction.relation=40
			if tag=="embargo": faction.relation=-25; faction.embargo=true
			if tag=="exchange-poor": game.field.marks=0
			if tag=="war": assert(game.conflict.command(game,"consortium","declare").is_empty())
			var action: String="trade" if tag=="trade-signed" else "alliance" if tag in ["alliance-signed","withdrawn"] else "gift" if tag=="gift-spent" else ""
			if not action.is_empty(): assert(game.diplomacy.act(game,"consortium",action).is_empty())
			if tag=="withdrawn":
				assert(game.diplomacy.act(game,"consortium","cancel_alliance").is_empty())
				assert(faction.relation==25 and "consortium:alliance" not in game.sector.state.agreements)
			if tag=="gift-spent": assert(game.field.marks==180 and faction.relation==15)
			var reasons: Dictionary={}
			for choice: String in game.diplomacy.ACTIONS:
				reasons[choice]=game.diplomacy.reason(game,"consortium",choice)
				if not reasons[choice].is_empty():
					var before: Dictionary=game.snapshot()
					assert(game.diplomacy.act(game,"consortium",choice)==reasons[choice])
					assert(game.snapshot()==before,"Refused diplomacy changed the campaign")
			var view:=SubViewport.new(); view.size=resolution; view.size_2d_override=Vector2i(1600,900); view.size_2d_override_stretch=true
			view.own_world_3d=true; view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
			var scene: Node3D=load("res://scenes/encounter.tscn").instantiate(); scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED
			view.add_child(scene); scene.audio.muted=true; scene.save_path=OUT+"/isolated-save.json"
			scene.ship.position=Field.service_position("orbit_tender"); scene._contact_select("consortium")
			scene.contact_page=page; scene._show_popup("contact"); scene._update_camera(1); scene._refresh_ui()
			var generation_ms: int=0
			if detail:
				var globe: Node3D=scene.orbit.planet
				var bake: RefCounted=preload("res://tests/planet_material_study.gd").new(globe.planet_definition) if materials else globe.generator
				if materials:
					for latitude: float in [-75,-45,-15,15,45,75]:
						for longitude: float in [-150,-90,-30,30,90,150]:
							var direction: Vector3=globe.generator.direction(latitude,longitude)
							assert(bake.sample(direction)==globe.generator.sample(direction),"Material review altered geography")
				# Parent cache keys do not encode subclass color policy. Isolate the review bake.
				if materials: bake.map_cache.clear()
				var maps: Dictionary=bake.maps(map_width)
				generation_ms=maps.generation_ms
				if relief:
					var shader:=Shader.new()
					# Review-only reduction: retain the exact geographic normal map and coastlines.
					shader.code=globe.material.shader.code.replace("vec3 relief_normal=normalize(texture(normal_map,coord).rgb*2.0-1.0);","vec3 relief_normal=normalize(mix(p,normalize(texture(normal_map,coord).rgb*2.0-1.0),0.25));")
					globe.material.shader=shader
				for pair: Array in [["surface_map","albedo"],["substrate_map","substrate"],["condition_map","conditions"],["normal_map","normals"],["recovered_map","albedo"]]: globe.material.set_shader_parameter(pair[0],maps[pair[1]])
				globe.clouds.material_override.set_shader_parameter("condition_map",maps.conditions)
			if proposal or fidelity:
				for child: Node in scene.get_children():
					if child is CanvasLayer: child.hide()
				view.size_2d_override=Vector2i(1920,1080)
				var overlay:=CanvasLayer.new(); view.add_child(overlay)
				var study: Control=load("res://tests/communicator_fidelity_study.gd" if fidelity else "res://tests/diplomacy_study_panel.gd").new()
				study.game=game; study.scene=scene; study.page=page; overlay.add_child(study)
				if fidelity:
					# Explicit review camera only: bring the real planet into frame, no simulated travel.
					scene.camera.position=scene.orbit.planet.position+Vector3(20,8,44)
					scene.camera.look_at(scene.orbit.planet.position+Vector3(24,0,0))
			var stable: Dictionary=game.snapshot()
			for frame: int in range(5): await process_frame
			await RenderingServer.frame_post_draw
			assert(game.snapshot()==stable,"Rendering advanced campaign")
			assert(view.get_texture().get_image().save_png(OUT+"/%s-%s-%d.png" % ["material" if materials else "relief" if relief else "detail" if detail else "fidelity" if fidelity else "proposal" if proposal else "actual",tag,resolution.y])==OK)
			var buttons: Array=[]
			for node: Node in scene.popup_body.find_children("*","Button",true,false): buttons.append({"text":node.text,"disabled":node.disabled,"tooltip":node.tooltip_text})
			manifest.append({"state":tag,"height":resolution.y,"texture_width":map_width,"normal_strength":0.25 if relief else 1.0,"generation_ms":generation_ms,"page":page,"greeting":scene.contact_greeting,"relation":faction.relation,"marks":game.field.marks,"agreements":game.sector.state.agreements.duplicate(),"reasons":reasons,"buttons":buttons})
			view.free()
	var file:=FileAccess.open(OUT+("/material.json" if materials else "/relief.json" if relief else "/detail.json" if detail else "/fidelity.json" if fidelity else "/proposals.json" if proposal else "/baseline.json"),FileAccess.WRITE); file.store_string(JSON.stringify(manifest,"\t")); file.close()
	print("Diplomacy review:%d captures; actual command outcomes, refused-command invariants and frozen rendering verified. No native input or acting acceptance." % manifest.size())
	quit()
