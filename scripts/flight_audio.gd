extends "res://scripts/audio_feedback.gd"
## Event-driven cockpit audio. Mix settings are user preferences, not simulation state.
signal cue_requested(name: String)
const CUSTOM_CUES := ["ui_hover","ui_confirm","ui_open","ui_close","equip_scan","equip_collect","equip_warm","equip_seed","target_lock","navigation","cancel","scan_complete","cargo","departure","entry","saved","achievement"]
var mix: Dictionary = {"sfx":0.8,"music":0.45,"voice":0.75}
var settings_path: String = "user://flight_audio.cfg"
var engine := AudioStreamPlayer.new()
var ambience := AudioStreamPlayer.new()
var music := AudioStreamPlayer.new()
var voice := AudioStreamPlayer.new()
var thrust: float = 0.0
var hover_time: int = -1000
var local_voice: String = ""
var quiet: bool = false
var voice_supported: bool = false

func _ready() -> void:
	super._ready()
	if "--script" in OS.get_cmdline_args(): settings_path = "res://artifacts/test_flight_audio.cfg"
	var config := ConfigFile.new()
	if config.load(settings_path) == OK:
		for channel: String in mix:
			var value: Variant = config.get_value("mix",channel,mix[channel])
			if (value is float or value is int) and is_finite(float(value)): mix[channel] = clampf(value,0,1)
	for cue: String in CUSTOM_CUES: cues[cue] = load("res://assets/audio/"+cue+".wav")
	_setup_loop(engine,"engine")
	_setup_loop(ambience,"surface_air")
	_setup_loop(music,"morrow_drift")
	add_child(voice)
	voice_supported = DisplayServer.get_name() != "headless" and DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH)
	if voice_supported:
		var available: PackedStringArray = DisplayServer.tts_get_voices_for_language("en")
		if not available.is_empty(): local_voice = available[0]
	update_flight(0,0,false,false)

func _setup_loop(player: AudioStreamPlayer, id: String) -> void:
	var stream: AudioStreamWAV = load("res://assets/audio/"+id+".wav").duplicate()
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = int(stream.get_length()*stream.mix_rate)
	player.stream = stream
	player.volume_db = -80
	add_child(player)
	if DisplayServer.get_name() != "headless": player.play()

func play(name: String) -> void:
	if not cues.has(name): return
	if name == "ui_hover":
		var now: int = Time.get_ticks_msec()
		if now-hover_time < 90: return
		hover_time = now
	cue_requested.emit(name)
	if muted or float(mix.sfx) <= 0: return
	for player: AudioStreamPlayer in voices:
		player.volume_db = -12+linear_to_db(float(mix.sfx))+(-12 if name == "ui_hover" else 0)
	super.play(name)

func update_flight(delta: float, speed: float, orbital: bool, stopped: bool) -> void:
	quiet = stopped
	thrust = lerpf(thrust,0 if stopped else clampf(speed/16,0,1),minf(1,delta*5))
	var silenced: bool = muted or stopped
	engine.volume_db = -80 if silenced or thrust < 0.005 or float(mix.sfx) <= 0 else -22+linear_to_db(thrust*float(mix.sfx))
	engine.pitch_scale = 0.8+thrust*0.65
	ambience.volume_db = -80 if silenced or orbital or float(mix.sfx) <= 0 else -24+linear_to_db(float(mix.sfx))
	var talking: bool = voice.playing or (voice_supported and DisplayServer.tts_is_speaking())
	var music_target: float = -80 if muted or float(mix.music) <= 0 else -13+linear_to_db(float(mix.music))-(9 if talking else 0)-(5 if stopped else 0)
	music.volume_db = lerpf(music.volume_db,music_target,minf(1,delta*4))
	voice.volume_db = -80 if muted or float(mix.voice) <= 0 else linear_to_db(float(mix.voice))-3

func set_volume(channel: String, value: float) -> void:
	if not mix.has(channel) or not is_finite(value): return
	mix[channel] = clampf(value,0,1)
	if channel == "voice" and value <= 0: stop_voice()
	if channel == "sfx" and value <= 0:
		for player: AudioStreamPlayer in voices: player.stop()

func save_settings() -> Error:
	var config := ConfigFile.new()
	for channel: String in mix: config.set_value("mix",channel,mix[channel])
	return config.save(settings_path)

func guide(id: String, text: String) -> void:
	if muted or float(mix.voice) <= 0: return
	# Licensed/acted recordings can replace scratch speech without changing gameplay.
	var recording: String = "res://assets/audio/voice/"+id+".wav"
	if ResourceLoader.exists(recording):
		stop_voice()
		voice.stream = load(recording)
		voice.play()
	elif not local_voice.is_empty():
		DisplayServer.tts_speak(text,local_voice,int(float(mix.voice)*100),1.0,1.0,0,true)

func stop_voice() -> void:
	voice.stop()
	if voice_supported: DisplayServer.tts_stop()

func suspend_voice(suspended: bool) -> void:
	voice.stream_paused = suspended
	if voice_supported:
		if suspended: DisplayServer.tts_pause()
		else: DisplayServer.tts_resume()

func _exit_tree() -> void:
	stop_voice()
	for player: AudioStreamPlayer in [engine,ambience,music,voice]: player.stop()
	super._exit_tree()
