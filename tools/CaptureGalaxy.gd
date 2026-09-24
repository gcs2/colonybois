extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Chart = preload("res://scripts/sector_chart.gd")
func _initialize() -> void: call_deferred("run")
func capture(label: String) -> void:
	await process_frame; await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/galaxy-"+label+"-"+str(root.size.x)+".png")
func run() -> void:
	var game := Session.new(); game.field.change_flight_mode("orbit")
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		root.size = resolution
		var chart := Chart.new(); root.add_child(chart); chart.present(game)
		chart.select_system("s1"); await capture("local")
		chart.graph.overview(); await capture("overview")
		chart.graph.yaw = 1.1; chart.graph.pitch = -0.36; chart.graph.overview(); await capture("underside")
		if resolution.x == 1920:
			var timings: Array[float] = []
			var cpu: Array[float] = []
			for i: int in range(120):
				var start: int = Time.get_ticks_usec()
				chart.graph.yaw += 0.003; chart.graph.queue_redraw()
				await process_frame; await RenderingServer.frame_post_draw
				timings.append((Time.get_ticks_usec()-start)/1000.0)
				cpu.append(chart.graph.draw_ms)
			timings.sort(); cpu.sort()
			print("Visible rotating galaxy frame interval median ms: ",timings[60],"; p95 ms: ",timings[114],"; draw submission CPU median ms: ",cpu[60])
		chart.free()
	print("Galaxy render captures complete; static memory bytes: ",OS.get_static_memory_usage()); quit()
