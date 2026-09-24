extends "res://tests/review_field_inventory.gd".InventoryStudy
## Static proposal only. Retained selection after refusal is not production behavior.
var game: RefCounted
var stage: String
var specimen: String
var target: Vector2
var slot: Array
func _ready() -> void:
	icons[specimen]=load("res://assets/specimens/%s.png" % specimen)
func _draw() -> void:
	panel(Rect2(24,20,665,36),DARK)
	text(Vector2(38,45),"RELEASE STUDY · PROPOSED UI / STATIC STATES",18)
	text(Vector2(28,94),"Morrow",30)
	var blocked: bool=stage in ["duplicate","no-food","no-energy"]
	var accent: Color=Color("e3a077") if blocked else Color("95c8ae")
	if stage!="cancelled":
		draw_arc(target,26,0,TAU,48,DARK,5,true)
		draw_arc(target,26,0,TAU,48,accent,2,true)
		if blocked:
			draw_line(target-Vector2(8,8),target+Vector2(8,8),accent,3,true)
			draw_line(target+Vector2(-8,8),target+Vector2(8,-8),accent,3,true)
	panel(Rect2(1180,856,716,200),IVORY)
	panel(Rect2(1192,868,100,110),DARK)
	icon(specimen,Rect2(1199,875,86,78))
	text(Vector2(1210,972),"× %d" % game.biosphere.state.cargo.get(specimen,0),22)
	text(Vector2(1310,891),game.biosphere.data()[specimen].name,25,DARK)
	var title: String={"armed":"Choose ground to release","approach":"Moving into range","beam":"Releasing specimen","released":"Established on Morrow","duplicate":"Already established","no-food":"Food supply incomplete","no-energy":"Not enough energy","cancelled":"Release cancelled"}[stage]
	text(Vector2(1310,922),title,21,DARK)
	var detail: String={"armed":"1 specimen + 5 energy on success","approach":"No resources spent until release completes","beam":"1 specimen + 5 energy on success","released":"1 specimen released · 5 energy used","duplicate":"This species already occupies an ecological slot.","no-food":"T2 needs small, medium and large plants first.","no-energy":"Requires 5 energy; you have 4. Use a pack or dock.","cancelled":"Specimen kept · no energy spent"}[stage]
	text(Vector2(1310,951),detail,18,DARK)
	if not slot.is_empty() and not blocked and stage!="cancelled":
		text(Vector2(1310,979),"T%d · Small plant %s" % [slot[0]+1,"filled" if stage=="released" else "slot available"],18,DARK)
	if stage=="beam":
		draw_rect(Rect2(1310,988,555,4),Color("9b9d91"))
		draw_rect(Rect2(1310,988,277,4),DARK)
	draw_line(Vector2(1198,1002),Vector2(1878,1002),Color("989b91"))
	text(Vector2(1204,1033),"ENERGY  %d" % game.field.state.energy,19,DARK)
	var hint: String="Choose another specimen" if stage in ["released","cancelled"] else "Selection kept · resolve cause, then click ground" if blocked else "Release in progress · Cancel release" if stage=="beam" else "Approaching target · Cancel release" if stage=="approach" else "Click ground · Cancel release"
	text(Vector2(1395,1033),hint,17,DARK)
	if blocked:
		panel(Rect2(1494,792,197,48),DARK,IVORY)
		panel(Rect2(1699,792,197,48),DARK,IVORY)
		text(Vector2(1510,823),"Choose specimen",19)
		text(Vector2(1720,823),"Cancel release",19)

