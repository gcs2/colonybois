extends SceneTree
const Session=preload("res://scripts/expedition_session.gd")
const Field=preload("res://scripts/encounter_state.gd")
const OUT="res://artifacts/diplomacy-review"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var manifest: Array=[]
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		for tag: String in ["first","repeat","agreements","trade-signed","alliance-ready","alliance-signed","withdrawn","embargo","exchange-poor","gift-spent","chart-own-territory","war"]:
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
			var stable: Dictionary=game.snapshot()
			for frame: int in range(5): await process_frame
			await RenderingServer.frame_post_draw
			assert(game.snapshot()==stable,"Rendering advanced campaign")
			assert(view.get_texture().get_image().save_png(OUT+"/actual-%s-%d.png" % [tag,resolution.y])==OK)
			var buttons: Array=[]
			for node: Node in scene.popup_body.find_children("*","Button",true,false): buttons.append({"text":node.text,"disabled":node.disabled,"tooltip":node.tooltip_text})
			manifest.append({"state":tag,"height":resolution.y,"page":page,"greeting":scene.contact_greeting,"relation":faction.relation,"marks":game.field.marks,"agreements":game.sector.state.agreements.duplicate(),"reasons":reasons,"buttons":buttons})
			view.free()
	var file:=FileAccess.open(OUT+"/baseline.json",FileAccess.WRITE); file.store_string(JSON.stringify(manifest,"\t")); file.close()
	print("Diplomacy baseline:24 captures; actual command outcomes, refused-command invariants and frozen rendering verified. No native input or acting acceptance.")
	quit()
