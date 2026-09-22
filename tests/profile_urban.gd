extends SceneTree
## Manual rendered profile on the development machine; no universal FPS claim.

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene._start_mode("urban",false)
	scene._command("civic",{"choice":"public"})
	scene._set_speed(3)
	for i: int in range(60): await process_frame
	var durations: Array[float] = []
	var max_memory: float = 0
	var max_draws: float = 0
	var profile_started: int = Time.get_ticks_msec()
	while durations.size() < 600 or Time.get_ticks_msec()-profile_started < 6000:
		var start: int = Time.get_ticks_usec()
		await process_frame
		durations.append(float(Time.get_ticks_usec()-start)/1000.0)
		max_memory = maxf(max_memory,Performance.get_monitor(Performance.MEMORY_STATIC))
		max_draws = maxf(max_draws,Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	var mean: float = 0.0
	for duration: float in durations: mean += duration/float(durations.size())
	durations.sort()
	print("URBAN RENDER PROFILE: %d frames, 3x simulation, mean %.2f ms, p95 %.2f ms, max %.2f ms, peak tracked static memory %.1f MiB, peak draw calls %.0f, repair completed: %s" % [durations.size(),mean,durations[int(durations.size()*0.95)],durations[-1],max_memory/1048576.0,max_draws,str(scene.sim.state.urban.repaired)])
	print("RENDER CONTEXT: %s, %s; frame intervals include presentation/vsync and occasional UI/mesh refresh." % [RenderingServer.get_video_adapter_name(),RenderingServer.get_current_rendering_method()])
	quit()
