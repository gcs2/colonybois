extends RefCounted
const City = preload("res://scripts/city_rules.gd")
const PORTRAITS: Dictionary = {
	"finance":preload("res://assets/advisors/finance-v1.png"),
	"works":preload("res://assets/advisors/works-v1.png"),
	"safety":preload("res://assets/advisors/safety-v1.png")
}

static func tabs(app: Node3D) -> void:
	var row := HBoxContainer.new()
	app.right_box.add_child(row)
	for section: String in ["overview","ledger","services"]:
		var button: Button = app._button(section.capitalize(),func() -> void: app.city_section = section; app._refresh_right(),row,true)
		button.button_pressed = app.city_section == section
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

static func advisor(app: Node3D, who: String, title: String, message: String) -> void:
	var portrait := TextureRect.new()
	portrait.texture = PORTRAITS[who]
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(0,165)
	app.right_box.add_child(portrait)
	app._text(app.right_box,title,18,app.WHITE)
	app._text(app.right_box,message,15,app.MUTED)

static func draw(app: Node3D, colony: Dictionary) -> void:
	var box: Control = app.right_box
	if app.city_section == "ledger":
		var ledger: Dictionary = app.sim.state.get("ledger",{})
		advisor(app,"finance","Vell · Treasury", "High taxes bring more income but slow residential development. Police coverage reduces lost revenue." )
		app._text(box,"TREASURY · ALL COLONIES",12,app.MINT)
		app._text(box,"%.2f Marks" % app.sim.state.credits,25,app.WHITE)
		if ledger.is_empty(): app._text(box,"Run one day to open the daily ledger. Construction materials and supplies are separate physical accounts.")
		else:
			for entry: Array in [["Taxes","tax",1],["Exports","exports",1],["Crime losses","crime_loss",-1],["Utilities & services","upkeep",-1],["Sponsor agreement","sponsor",-1],["Treasury floor adjustment","adjustment",1]]:
				var row := HBoxContainer.new()
				box.add_child(row)
				var label: Label = app._label(entry[0],14,app.WHITE)
				row.add_child(label)
				label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				row.add_child(app._label("%+.2f" % (float(ledger.get(entry[1],0))*int(entry[2])),14,app.MINT if int(entry[2]) > 0 else app.GOLD))
			app._text(box,"Daily balance  %+.2f Marks" % ledger.net,20,app.MINT if ledger.net >= 0 else app.GOLD)
			app._text(box,"Opening %.2f → closing %.2f\nDaily operations only; construction and project payments occur when ordered." % [ledger.opening,ledger.closing],13)
		app._text(box,"LOCAL TAX POLICY · %.0f%%" % (100*float(colony.get("tax_rate",1))),12,app.MINT)
		var choices := HBoxContainer.new()
		box.add_child(choices)
		for rate: float in [0.75,1.0,1.25]:
			var button: Button = app._button("%d%%" % int(rate*100),app._command.bind("city_policy",{"planet":app.planet_id,"action":"tax","rate":rate}),choices)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.custom_minimum_size.x = 80
		app._text(box,"Materials  %.1f (%+.2f/day)\nSupplies  %.1f (%+.2f/day)" % [colony.materials,colony.material_rate,colony.supplies,colony.supply_rate],16,app.WHITE)
		return
	var unsafe: bool = float(colony.fire_risk) > 35 or float(colony.crime) > 30
	advisor(app,"safety" if unsafe else "works","Siv · Civic safety" if unsafe else "Orro · Public works","Unprotected industry can burn. Fires halt output for 12 days; emergency repairs restore it sooner. Crime costs revenue and can trigger supply theft." if unsafe else "Place two powered shuttle stops on the connected road network. Their catchments support longer commutes. Clinics improve local productivity.")
	app._text(box,"Crime  %.0f / 100\nFire risk  %.0f / 100" % [colony.crime,colony.fire_risk],20,app.GOLD)
	for kind: String in ["police","fire","clinic","transit"]:
		var covered: int = 0
		var total: int = 0
		for key: String in colony.cells:
			var cell: Dictionary = colony.cells[key]
			if cell.type not in City.ZONES or int(cell.level) == 0: continue
			total += City.area(cell)
			if City.coverage(colony,kind,Vector2(app.sim.cell_position(key))) > 0.15: covered += City.area(cell)
		app._button("%s · %d%% lot coverage" % [kind.capitalize(),100*covered/maxi(1,total)],app._set_overlay.bind(kind),box)
	for key: String in colony.cells:
		if int(colony.cells[key].get("damaged_until",0)) > app.sim.state.tick:
			app._button("Repair %s · 25 Marks / 10 materials" % key,app._command.bind("city_policy",{"planet":app.planet_id,"action":"repair","tile":key}),box)
	app._text(box,"Services need roads and sufficient power. Coverage fades with distance. Shuttle service needs at least two operating stops.",13)
	for event: Dictionary in app.sim.state.log.slice(maxi(0,app.sim.state.log.size()-3)): app._text(box,str(event.get("text","")),13)

static func layer_color(app: Node3D, x: int, z: int) -> Color:
	var colony: Dictionary = app.sim.state.colonies[app.planet_id]
	var key: String = str(colony.occupied.get(app.sim.key(x,z),app.sim.key(x,z)))
	if app.overlay == "access": return app.MINT if colony.connected.has(key) else Color("763f50")
	if app.overlay == "suitability": return Color("ac565b").lerp(Color("75dab5"),app.sim.suitability(app.planet_id,x,z))
	if app.overlay in ["crime","fire"]:
		if not colony.risks.has(key): return Color("233942")
		return Color("65cdb4").lerp(Color("e46b62"),float(colony.risks[key][app.overlay])/100.0)
	if City.SERVICES.has(app.overlay): return Color("543d55").lerp(Color("69e3c0"),City.coverage(colony,app.overlay,Vector2(x,z)))
	return Color("738d8a")

static func legend(layer: String) -> String:
	if layer in ["crime","fire"]: return layer.to_upper()+"   MINT: SAFE   /   RED: HIGH RISK"
	if layer == "access": return "ROAD ACCESS   MINT: CONNECTED   /   RED: DISCONNECTED"
	return layer.to_upper()+"   PURPLE: NONE   /   MINT: STRONG"
