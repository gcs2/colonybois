extends Control
## Authored vector busts with bounded gaze, breathing, blink and response poses.
## Presentation clock only; never advances the campaign while a conversation is open.
const FILES := {"consortium":"oolun-delegate","directorate":"veyri-commissioner","commune":"velith-envoy"}
const EYES := {"consortium":[Vector2(159,119),Vector2(231,116)],"directorate":[Vector2(163,129),Vector2(232,124)],"commune":[Vector2(172,122),Vector2(222,122),Vector2(196,152)]}
var faction_id: String = "consortium"
var mood: String = "neutral"
var clock: float = 0.0
var speaking: float = 0.0
var texture: Texture2D
func _ready() -> void:
	if custom_minimum_size == Vector2.ZERO: custom_minimum_size = Vector2(460,200)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture = load("res://assets/aliens/"+str(FILES[faction_id])+".svg")
	queue_redraw()
func respond(accepted: bool) -> void:
	mood = "pleased" if accepted else "wary"
	speaking = 2.2
func _process(delta: float) -> void:
	clock += delta
	speaking = maxf(0,speaking-delta)
	queue_redraw()
func _draw() -> void:
	if texture == null: return
	var factor: float = minf(size.x/400.0,size.y/300.0)
	var bob: float = sin(clock*1.5)*1.4
	var origin := Vector2((size.x-400*factor)*0.5,bob)
	draw_set_transform(origin,0,Vector2.ONE*factor)
	draw_texture_rect(texture,Rect2(0,0,400,300),false)
	var blink: float = 1.0-clampf((0.13-absf(fmod(clock+0.7,4.9)-0.13))/0.13,0,1)
	for eye: Vector2 in EYES[faction_id]:
		var radius: float = 11.0 if faction_id == "commune" else 16.0
		var opening: float = maxf(0.05,blink)*(0.68 if mood == "wary" else 1.0)
		draw_set_transform(origin+eye*factor,0,Vector2(factor,factor*opening))
		draw_circle(Vector2.ZERO,radius+3,Color("35384b"),true,-1,true)
		draw_circle(Vector2.ZERO,radius,Color("eadfbd"),true,-1,true)
		var gaze := Vector2(sin(clock*0.43)*2,-1)
		draw_circle(gaze,radius*0.68,Color("233b49"),true,-1,true)
		draw_circle(gaze+Vector2(-3,-4),3.2,Color("fbf1d2"),true,-1,true)
	draw_set_transform(origin,0,Vector2.ONE*factor)
	var mouth := Vector2(195,151) if faction_id == "consortium" else Vector2(201,181)
	if speaking > 0:
		draw_set_transform(origin+mouth*factor,0,Vector2(factor,factor*(0.35+absf(sin(clock*7))*0.45)))
		draw_circle(Vector2.ZERO,9,Color("473549"),true,-1,true)
	else:
		draw_arc(mouth+Vector2(0,5) if mood == "wary" else mouth-Vector2(0,5),11,PI+0.2 if mood == "wary" else 0.2,TAU-0.2 if mood == "wary" else PI-0.2,20,Color("634e60"),3,true)
	draw_set_transform(Vector2.ZERO)
