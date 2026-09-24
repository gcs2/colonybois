extends SceneTree
## Layout proposal only. Isolated campaign data, static concept world, provisional art.
const Session = preload("res://scripts/expedition_session.gd")
const Base = preload("res://tests/review_field_inventory.gd")
const OUT = "res://artifacts/cargo-review"

class Study extends Base.InventoryStudy:
	var game: RefCounted
	var section := "freight"
	var selected := 0
	var page := 0
	var entries: Array = []
	var detail := ""
	var action := ""
	var refusal := ""
	var caption := ""
	func _ready() -> void:
		for key: String in ["cargo", "energy_pack", "category_life", "housing", "heat_charge", "pod", "repair_pack", "mega_repair_pack"]:
			icons[key] = load("res://assets/ui/flight/%s.svg" % key)
		for key: String in ["alloy", "water", "glass", "colony_kit"]:
			icons[key] = preload("res://scripts/communicator_style.gd").equipment_icon(key)
		icons.housing = load("res://assets/ui/flight/planet_map.svg")
		for id: String in game.biosphere.state.cargo:
			icons[id] = load("res://assets/specimens/%s.png" % id)
		var atlas := ImageTexture.create_from_image(Image.load_from_file("res://artifacts/field-instruments-review/supply-portraits-v1.png"))
		for i: int in range(3):
			var tile := AtlasTexture.new()
			tile.atlas = atlas
			tile.region = Rect2(Vector2(i * atlas.get_width() / 3.0, 0), Vector2(atlas.get_width()/3.0, atlas.get_height()))
			icons[["energy_pack", "repair_pack", "mega_repair_pack"][i]] = tile
	func lines(value: String, at: Vector2, width: float, color: Color = LIGHT) -> void:
		var label := Label.new()
		label.position = at
		label.size = Vector2(width, 150)
		label.text = value
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_override("font", FONT)
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", color)
		add_child(label)
	func prepare() -> void:
		if section == "freight":
			caption = "%d / %d freight spaces" % [game.commerce.used_space(game), game.commerce.capacity()]
			for lot: Dictionary in game.commerce.state.cargo:
				var item: Dictionary = game.commerce.catalog.goods[lot.item]
				entries.append({"name":item.name, "icon":lot.item, "count":lot.quantity})
			if game.colonies.reserved_space() > 0:
				entries.append({"name":"Colony kit", "icon":"colony_kit", "count":1})
				selected = entries.size()-1
				detail = "Occupies 4 freight spaces.\n\nUnloads a landing hub for a new colony. Construction continues after deployment."
				action = "Select landing site"
				refusal = game.colonies.deployment_reason(game)
			elif not entries.is_empty():
				detail = game.commerce.catalog.goods.alloy.description + "\n\nOrigin: Morrow\n2 units · 2 freight spaces"
				refusal = "Trade these goods at a dock."
		elif section == "supplies":
			caption = "Energy %d / 3   ·   Repair %d / 3 shared" % [game.field.state.energy_packs, game.field.repair_pack_count()]
			entries = [{"name":"Energy pack", "icon":"energy_pack", "count":game.field.state.energy_packs},
				{"name":"Repair pack", "icon":"repair_pack", "count":game.field.state.repair_packs.repair_pack},
				{"name":"Full repair pack", "icon":"mega_repair_pack", "count":game.field.state.repair_packs.mega_repair_pack}]
			detail = "Restores up to %d energy.\n\nEnergy %d / %d\nConsumes one pack. No passive recharge." % [game.field.PACK_ENERGY, game.field.state.energy, game.field.max_capacity("energy")]
			action = "Use one pack"
			refusal = game.field.pack_reason()
		elif section == "specimens":
			caption = "%d / 12 living specimens" % game.biosphere.used()
			for id: String in game.biosphere.state.cargo:
				entries.append({"name":game.biosphere.data()[id].name, "icon":id, "count":game.biosphere.state.cargo[id]})
			if not entries.is_empty():
				var id: String = game.biosphere.state.cargo.keys()[selected]
				detail = str(game.biosphere.data()[id].role).capitalize() + "\n\nArm release to close inspection. Then click a valid surface target.\n\nRelease uses 5 energy and one specimen; arming uses neither."
				action = "Arm release & close"
		elif section == "surface":
			caption = "%d / 8 local units · Morrow" % game.field.state.produce
			if game.field.state.produce > 0: entries = [{"name":"Cultivated lantern pods", "icon":"pod", "count":game.field.state.produce}]
			detail = "Stored at Morrow’s surface bed. Not aboard the ship.\n\nMature beds produce one unit every 12 seconds, up to 8 units."
			action = "View nursery agreement"
		if entries.is_empty():
			detail = "Load colony surplus or buy goods at a dock." if section == "freight" else "No cultivated produce stored on this world." if section == "surface" else "Scan a lifeform, then collect it with the tractor."
			lines(detail, Vector2(1510,435), 326)
		else:
			lines(detail, Vector2(1510,420), 326)
			if not refusal.is_empty(): lines(refusal, Vector2(1510,644),326,AMBER)
	func _draw() -> void:
		draw_texture_rect(background,Rect2(0,0,1920,1080),false)
		text(Vector2(32,48),"Morrow",32)
		text(Vector2(32,79),"CARGO DESIGN STUDY · STATIC WORLD · PROVISIONAL ICONS",16)
		var shell := Rect2(914,198,966,622)
		panel(Rect2(shell.position+Vector2(0,5),shell.size),Color("64685f"))
		panel(shell,IVORY,Color("a0a496"))
		text(Vector2(944,240),"EXPEDITION STORES",25,DARK)
		text(Vector2(1752,238),"Esc  ×",20,DARK)
		var tabs := ["freight", "supplies", "specimens", "surface"]
		var symbols := ["cargo", "energy_pack", "category_life", "housing"]
		for i: int in range(4):
			var r := Rect2(938+i*224,259,214,55)
			if section == tabs[i]: panel(r,DARK)
			icon(symbols[i],Rect2(r.position+Vector2(10,9),Vector2(36,36)),DARK if i==0 and section!="freight" else Color.WHITE)
			text(r.position+Vector2(54,35),tabs[i].capitalize(),21,LIGHT if section==tabs[i] else DARK)
		text(Vector2(942,349),caption,20,DARK)
		panel(Rect2(938,365,542,397),DARK)
		panel(Rect2(1494,365,362,397),DARK)
		for i: int in range(page*8,mini(entries.size(),page*8+8)):
			var e: Dictionary = entries[i]
			var index: int = i-page*8
			var r := Rect2(954+(index%4)*130,385+int(index/4)*143,116,127)
			draw_rect(r,Color("333b37"))
			icon(e.icon,Rect2(r.position+Vector2(12,7),Vector2(92,92)))
			text(r.position+Vector2(76,117),"×%d" % e.count,21)
			if selected == i: corners(r.grow(3),AMBER)
		if entries.size()>8:
			var pages: int = ceili(entries.size()/8.0)
			text(Vector2(1108,739),"‹",26,LIGHT if page>0 else Color("647168"))
			text(Vector2(1150,739),"%d / %d" % [page+1,pages],20)
			text(Vector2(1220,739),"›",26,LIGHT if page+1<pages else Color("647168"))
		if entries.is_empty():
			text(Vector2(974,422),"Nothing stored here",23)
			text(Vector2(1510,402),"Empty compartment",23)
		else:
			text(Vector2(1510,402),entries[selected].name,23)
		if not action.is_empty() and not entries.is_empty():
			var r := Rect2(1510,709,330,38)
			panel(r,Color("58685b") if refusal.is_empty() else Color("454b45"))
			text(r.position+Vector2(12,26),action,19,LIGHT if refusal.is_empty() else Color("b5b9ad"))
		text(Vector2(942,795),"Climate locker %d / 6  ·  separate storage" % game.climate.units(),17,DARK)
		text(Vector2(1496,795),"Inspection pauses simulation",17,DARK)

func _initialize() -> void: call_deferred("run")
func run() -> void:
	var bg := "res://artifacts/field-instruments-review/surface-review-background-v1.png"
	for path: String in [bg,"res://artifacts/field-instruments-review/supply-portraits-v1.png"]:
		if not FileAccess.file_exists(path): push_error("Missing local review asset: "+path); quit(1); return
	DirAccess.make_dir_recursive_absolute(OUT)
	var records: Array = []
	for state: String in ["freight", "empty", "kit", "supplies", "full-energy", "specimens", "empty-specimens", "surface", "empty-surface", "full-specimens", "specimens-page2"]:
		var game := Session.new()
		game.field.state.energy = 100 if state=="full-energy" else 40
		game.field.state.energy_packs = 2
		game.field.state.repair_packs = {"repair_pack":1, "mega_repair_pack":1}
		game.field.state.produce = 0 if state=="empty-surface" else 5
		if state != "empty":
			game.commerce.add_cargo("alloy",2,"morrow")
			game.commerce.add_cargo("water",1,"s1p0")
			game.commerce.add_cargo("glass",1,"s2p0")
		if state == "kit": game.colonies.state.kit_source = "morrow"
		if state != "empty-specimens": game.biosphere.state.cargo = {"moss_lantern":3,"pocket_manta":2,"veil_maw":1}
		if state in ["full-specimens", "specimens-page2"]:
			game.biosphere.state.cargo.clear()
			for id: String in game.biosphere.data().keys().slice(0,12): game.biosphere.state.cargo[id]=1
		var before: Dictionary = game.snapshot().duplicate(true)
		for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
			var view := SubViewport.new()
			view.size=resolution; view.size_2d_override=Vector2i(1920,1080); view.size_2d_override_stretch=true
			view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; view.gui_disable_input=true
			root.add_child(view)
			var study := Study.new()
			study.game=game; study.background=ImageTexture.create_from_image(Image.load_from_file(bg))
			study.section = "freight" if state in ["empty","kit"] else "supplies" if state=="full-energy" else "specimens" if state in ["empty-specimens","full-specimens","specimens-page2"] else "surface" if state=="empty-surface" else state
			if state=="specimens-page2": study.page=1; study.selected=8
			view.add_child(study); study.prepare(); study.queue_redraw()
			for i: int in range(3): await process_frame
			await RenderingServer.frame_post_draw
			var path: String = OUT+"/mock-%s-%d.png" % [state,resolution.y]
			assert(view.get_texture().get_image().save_png(path)==OK)
			records.append({"state":state,"width":resolution.x,"path":path,"action":study.action,"refusal":study.refusal})
			view.free()
		assert(before==game.snapshot())
	var file := FileAccess.open(OUT+"/mock-evidence.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"kind":"layout proposal; no native input; no production changes", "captures":records},"\t"))
	print("Cargo mock: 22 captures; eleven immutable campaign fixtures.")
	quit()
