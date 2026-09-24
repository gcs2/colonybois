extends "res://tests/review_field_inventory.gd".InventoryStudy
## Review-only service layout. Drawn controls are not integrated transactions.
const TAVI=preload("res://assets/aliens/tavi-portrait-v1.png")
var game: RefCounted
var scene: Node3D
var stage: String
var selected: String="pack"
var purchase_reason: String=""
var recharge_reason: String=""
var shown_price: int=0
var named_regions: Dictionary={}
func _ready() -> void:
	size=Vector2(1920,1080)
	for key: String in ["energy_pack","repair_pack","mega_repair_pack","cargo","category_tools","housing","fleet","heat_ray","comms"]:
		icons[key]=load("res://assets/ui/flight/%s.svg" % key)
func _draw() -> void:
	panel(Rect2(24,20,1000,36),DARK)
	text(Vector2(38,45),"SERVICE STUDY · PROPOSED UI / ACTUAL STATE · STATIC CONTROLS",18)
	var home: bool=game.field.state.planet_id==game.field.state.homeworld_id
	var gx: float=580 if home else 680
	var dx: float=gx+310
	var width: float=430 if home else 480
	var left: float=550 if home else 400
	var right: float=dx+width+30
	var port: Dictionary=game.field.local_services().orbit_tender
	panel(Rect2(left,230,right-left,570),IVORY)
	text(Vector2(left+24,267),str(port.name).to_upper(),24,DARK)
	text(Vector2(right-235,267),"%d Marks" % game.field.marks,23,DARK)
	text(Vector2(gx,306),"HULL %d / 100     ENERGY %d / 100" % [game.field.state.hull,game.field.state.energy],19,DARK)
	if not home:
		panel(Rect2(420,294,230,350),DARK)
		var fit: float=minf(214.0/TAVI.get_width(),310.0/TAVI.get_height())
		var extent: Vector2=TAVI.get_size()*fit
		draw_texture_rect(TAVI,Rect2(Vector2(535,463)-extent*0.5,extent),false)
		text(Vector2(435,631),"Tavi Rill",21)
		text(Vector2(424,674),"Local ship supplies",18,DARK)
	# Refueling acts now. Consumables below are bought for later inventory use.
	panel(Rect2(gx,326,right-gx-24,99),DARK)
	var refill: int=game.field.recharge_price("orbit_tender")
	recharge_reason=game.service_reason("orbit_tender",scene.ship.position,"recharge")
	text(Vector2(gx+16,354),"DOCK REFUEL · "+("FREE AT HOME" if home else "%d Marks" % refill),21)
	text(Vector2(gx+16,382),"Restore reactor energy to full now.",18)
	text(Vector2(gx+16,408),recharge_reason if not recharge_reason.is_empty() else "Available at this dock",17,AMBER)
	panel(Rect2(right-177,342,137,34),IVORY if recharge_reason.is_empty() else Color("727c75"))
	text(Vector2(right-163,366),"Refuel",18,DARK)
	text(Vector2(gx,452),"BUY SUPPLIES",18,DARK)
	var ids: Array[String]=["pack","repair_pack","mega_repair_pack"]
	for i: int in range(3):
		var id: String=ids[i]
		var r:=Rect2(gx+(i%2)*132,468+(i/2)*116,116,104)
		panel(r,DARK)
		icon("energy_pack" if id=="pack" else id,Rect2(r.position+Vector2(26,12),Vector2(64,64)))
		var count: int=game.field.state.energy_packs if id=="pack" else game.field.state.repair_packs[id]
		text(r.position+Vector2(10,94),"Aboard %d" % count,16)
		if id==selected: corners(r.grow(3),AMBER)
		if not game.service_reason("orbit_tender",scene.ship.position,id).is_empty(): text(r.position+Vector2(95,22),"!",18,AMBER)
		named_regions["Energy pack" if id=="pack" else game.field.repair_items()[id].name]=r
	var energy: bool=selected=="pack"
	var title: String="Energy pack" if energy else game.field.repair_items()[selected].name
	var stock: int=game.field.state.service_stock.orbit_tender if energy else game.field.state.repair_stock.orbit_tender[selected]
	shown_price=int(port.pack_price if energy else port.repair_prices[selected])
	purchase_reason=game.service_reason("orbit_tender",scene.ship.position,selected)
	panel(Rect2(dx,440,width,264),DARK)
	text(Vector2(dx+18,470),title,24)
	text(Vector2(dx+18,501),"Restore up to 50 energy." if energy else "Restore up to 75 hull." if selected=="repair_pack" else "Restore all missing hull.",19)
	text(Vector2(dx+18,530),"Buy now; use from Inventory when needed.",18)
	text(Vector2(dx+18,559),"%d in stock · %d Marks each" % [stock,shown_price],18,AMBER)
	text(Vector2(dx+18,588),"Energy locker %d / 3" % game.field.state.energy_packs if energy else "Shared cooldown after use: 20 s",17)
	if not energy: text(Vector2(gx,716),"Repair locker %d / 3" % game.field.repair_pack_count(),16,DARK)
	# A bounded two-line reason keeps the purchase anchor stable across restrictions.
	var lines: PackedStringArray=wrap_reason(purchase_reason if not purchase_reason.is_empty() else "Available")
	for i: int in range(lines.size()): text(Vector2(dx+18,615+i*21),lines[i],17,AMBER)
	panel(Rect2(dx+width-160,654,140,34),IVORY if purchase_reason.is_empty() else Color("727c75"))
	text(Vector2(dx+width-144,679),"Buy · %d" % shown_price,18,DARK)
	var feedback: String="Purchased packs go to Inventory; buying restores no hull or energy."
	if stage=="repair-purchased": feedback="Repair pack purchased · open Inventory to use it."
	elif stage=="repair-used": feedback="Repair pack used · hull restored · energy unchanged."
	elif stage in ["recharged","home-recharged"]: feedback="Refueling complete · energy restored to full."
	text(Vector2(gx,736),feedback,18,DARK)
	var tabs: Array= [["Market","cargo"],["Upgrades","category_tools"],["Supplies","energy_pack"],["Warehouse","housing"],["Fleet","fleet"],["Climate","heat_ray"]]
	for i: int in range(tabs.size()):
		var r:=Rect2(gx+i*48,751,38,31)
		panel(r,DARK); icon(tabs[i][1],r.grow(-5)); named_regions[tabs[i][0]]=r
		if tabs[i][0]=="Supplies": corners(r,AMBER)
	if not home:
		var comms:=Rect2(430,701,38,31)
		panel(comms,DARK); icon("comms",comms.grow(-5)); named_regions["Communications"]=comms
	panel(Rect2(right-164,750,140,32),DARK)
	text(Vector2(right-139,774),"Undock",18)
func _get_tooltip(at: Vector2) -> String:
	for title: String in named_regions:
		if named_regions[title].has_point(at): return title
	return ""
func wrap_reason(value: String) -> PackedStringArray:
	if value.length()<=43: return PackedStringArray([value])
	var split: int=value.rfind(" ",43)
	return PackedStringArray([value.substr(0,split),value.substr(split+1)])
