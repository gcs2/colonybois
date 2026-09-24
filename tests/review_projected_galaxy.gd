extends SceneTree
## Isolated review harness: production projection, proposed overlay, no saves/input.
const Session=preload("res://scripts/expedition_session.gd")
const Chart=preload("res://scripts/sector_chart.gd")
const OUT="res://artifacts/field-instruments-review/states"

class Overlay extends "res://tests/review_field_navigation.gd".Study:
	var graph: Control
	var game: RefCounted
	var known: bool=true
	var card: Rect2
	const SHIP_RECT=Rect2(1284,936,612,120)
	func _draw() -> void:
		label(Vector2(32,48),"Galaxy",30)
		label(Vector2(635,34),"REVIEW OVERLAY · ACTUAL GALAXY PROJECTION",16,Color("97aaa5"))
		label(Vector2(1750,48),"%d Marks" % game.field.marks,20)
		var system: Dictionary=game.sector.system_by_id("s1")
		var point: Vector2=graph.point(system)
		bracket(point,18,LIGHT)
		var height: float=64+system.planets.size()*36 if known else 96
		card=Rect2(Vector2(clampf(point.x+30,24,1576),clampf(point.y-30,100,880-height)),Vector2(320,height))
		housing(card,PAPER)
		housing(card.grow(-3),INK)
		var at: Vector2=card.position+Vector2(16,30)
		label(at,system.name if known else "Uncharted signal",23)
		if known:
			for i: int in range(system.planets.size()):
				var planet: Dictionary=Session.Geography.definition(Session.local_id(system.planets[i]))
				draw_circle(at+Vector2(9,29+i*36),7,Color("87b4b1") if i==0 else Color("cbaa78"))
				label(at+Vector2(28,36+i*36),planet.name,18)
		else: label(at+Vector2(0,36),"Worlds not yet charted",18,Color("a7b7b1"))
		housing(SHIP_RECT,PAPER)
		label(Vector2(1300,958),"EXPEDITION SHIP",14,INK)
		for i: int in range(4):
			var box:=Rect2(1300+i*58,975,50,58)
			housing(box,INK); draw_texture_rect(icons[i],box.grow(-8),false)
		for i: int in range(2):
			var y: float=971+i*40
			label(Vector2(1554,y),"HULL 100/100" if i==0 else "ENERGY %d/100" % game.field.state.energy,15,INK)
			draw_rect(Rect2(1554,y+9,322,8),INK)
			draw_rect(Rect2(1554,y+9,322*(1.0 if i==0 else game.field.state.energy/100.0),8),Color("cf8d64") if i==0 else GOLD)
		# Deliberately no local chart or unbound decorative navigation buttons.
		label(Vector2(32,1038),"Camera-angle fixture · controls not interactive",16,Color("97aaa5"))

func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var evidence: Array=[]
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		var viewport:=SubViewport.new(); viewport.size=resolution
		viewport.size_2d_override=Vector2i(1920,1080); viewport.size_2d_override_stretch=true
		viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS; viewport.gui_disable_input=true
		root.add_child(viewport)
		var background:=ColorRect.new(); background.color=Color("080e16"); background.size=Vector2(1920,1080); viewport.add_child(background)
		var game:=Session.new(); game.field.change_flight_mode("orbit"); game.field.state.energy=92
		var graph:=Chart.StarGraph.new(); graph.size=Vector2(1920,1080); graph.campaign=game
		viewport.add_child(graph); graph.make_dust(); graph.reset_view(); graph.magnification=2.4
		graph.selected_id="s0"; graph.hovered=""
		var overlay:=Overlay.new(); overlay.graph=graph; overlay.game=game; overlay.size=Vector2(1920,1080)
		viewport.add_child(overlay)
		for state: String in ["known","unknown","rotated","underside"]:
			overlay.known=state!="unknown"; game.sector.system_by_id("s1").charted=overlay.known
			graph.yaw=0.9 if state=="rotated" else 0.0
			graph.pitch=-0.58 if state=="underside" else 0.58
			graph.cache_stars(); graph.queue_redraw(); overlay.queue_redraw()
			for frame: int in range(3): await process_frame
			await RenderingServer.frame_post_draw
			var target: Vector2=graph.point(game.sector.system_by_id("s1"))
			var expected: Vector2=Chart.StarGraph.Galaxy.position(game.sector.system_by_id("s1"))
			assert(graph.world_at(target).distance_to(expected)<0.001)
			assert(overlay.SHIP_RECT.size.x/1920.0<=0.34 and overlay.SHIP_RECT.size.y/1080.0<=0.13)
			assert(not overlay.card.intersects(overlay.SHIP_RECT))
			var file: String="%s/projected-galaxy-%s-%d.png" % [OUT,state,resolution.x]
			assert(viewport.get_texture().get_image().save_png(file)==OK)
			evidence.append({"state":state,"resolution":[resolution.x,resolution.y],"image":file,"yaw":graph.yaw,"pitch":graph.pitch,"distance_pc":game.quote("s1p0").distance,"reach_pc":game.commerce.drive_range(),"target_screen":[target.x,target.y],"ship_housing_fraction":[612.0/1920,120.0/1080],"native_input":false})
		viewport.free()
	var record:=FileAccess.open(OUT+"/projected-galaxy-evidence.json",FileAccess.WRITE)
	record.store_string(JSON.stringify({"kind":"production galaxy renderer with review-only overlay","states":evidence},"\t"))
	print("Projected galaxy review: 8 captures, projection roundtrip and overlay bounds passed.")
	quit()
