extends SceneTree
var checks: int = 0
var failures: int = 0
var events: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)

func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	var audio: Node = scene.audio
	audio.cue_requested.connect(func(name: String) -> void: events.append(name))
	for i: int in range(scene.toolbar.size()):
		events.clear()
		scene.toolbar[i].pressed.emit()
		check(events == ["equip_"+scene.TOOLS[i]],"Hotbar selection emits one distinct equip cue, no generic double-click")
	var distinct: Dictionary = {}
	for id: String in ["scan","collect","warm","seed"]:
		var stream: AudioStreamWAV = audio.cues["equip_"+id]
		distinct[hash(stream.data)] = true
	check(distinct.size() == 4,"Four tool cues contain different audio samples")
	events.clear()
	audio.hover_time = -1000
	scene.toolbar[0].mouse_entered.emit()
	scene.toolbar[1].mouse_entered.emit()
	check(events == ["ui_hover"],"Rapid hover is rate limited instead of chattering")
	events.clear()
	scene._select_tool("scan")
	scene.selected = "relay"
	scene._activate_selected()
	check("target_lock" in events,"Valid target acquisition has audible feedback")
	scene._stop()
	check(events.back() == "cancel","Cancelling a command has a distinct cue")
	scene._navigate(Vector3(20,8,20))
	check(events.back() == "navigation","A movement command has confirmation")
	audio.muted = false
	audio.mix = {"sfx":0.8,"music":0.45,"voice":0.75}
	audio.update_flight(1,16,false,false)
	var running_gain: float = audio.engine.volume_db
	check(running_gain > -60 and audio.engine.pitch_scale > 1,"Thrust intensity drives engine gain and pitch")
	audio.update_flight(1,0,false,true)
	check(audio.engine.volume_db == -80 and audio.ambience.volume_db == -80,"Pause silences thrust and planetary ambience")
	audio.update_flight(1,10,true,false)
	check(audio.ambience.volume_db == -80,"Planetary air cannot play in orbit")
	audio.set_volume("sfx",0)
	audio.update_flight(1,16,false,false)
	check(audio.engine.volume_db == -80 and audio.ambience.volume_db == -80,"Effects slider mutes continuous sounds as well as UI cues")
	audio.set_volume("voice",NAN)
	check(audio.mix.voice == 0.75,"Invalid volume cannot corrupt the mix")
	audio.set_volume("music",0.27)
	audio.settings_path = "res://artifacts/audio_roundtrip.cfg"
	check(audio.save_settings() == OK,"User mix saves independently of the expedition")
	var config := ConfigFile.new()
	check(config.load(audio.settings_path) == OK and is_equal_approx(config.get_value("mix","music"),0.27),"Saved music level round trips")
	check(audio.music.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and audio.music.stream.get_length() >= 47,"Original music is loaded as a continuous track")
	scene._show_popup("audio")
	var sliders: int = 0
	for child: Node in scene.popup_body.get_children():
		if child is HSlider: sliders += 1
	check(sliders == 3,"Audio panel exposes independent effects, music and voice sliders")
	scene.free()
	print("Audio assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
