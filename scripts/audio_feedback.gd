extends Node
## Small original synthesized UI and world cues. Generated once, never per frame.
var cues: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var muted: bool = false
var cursor: int = 0

func _ready() -> void:
	muted = DisplayServer.get_name() == "headless"
	for i: int in range(4):
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -19
		add_child(voice)
		voices.append(voice)
	for name: String in ["tap","build","launch","arrival","error"]:
		cues[name] = _synthesize(name)

func _exit_tree() -> void:
	for voice: AudioStreamPlayer in voices:
		voice.stop()
		voice.stream = null
	cues.clear()

func play(name: String) -> void:
	if muted or not cues.has(name) or voices.is_empty(): return
	var voice: AudioStreamPlayer = voices[cursor%voices.size()]
	cursor += 1
	voice.stream = cues[name]
	voice.play()

func _synthesize(name: String) -> AudioStreamWAV:
	var duration: float = 0.08 if name == "tap" else (0.85 if name == "launch" else 0.38)
	var rate: int = 22050
	var bytes := PackedByteArray()
	bytes.resize(int(duration*rate)*2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	for i: int in range(bytes.size()/2):
		var t: float = float(i)/rate
		var u: float = t/duration
		var frequency: float = 560
		if name == "build": frequency = 180+250*u
		elif name == "launch": frequency = 75+150*u*u
		elif name == "arrival": frequency = [440.0,554.37,659.25][mini(2,int(u*3))]
		elif name == "error": frequency = 170-65*u
		var envelope: float = minf(1.0,t/0.008)*pow(1.0-u,2.0)
		var wave: float = sin(TAU*frequency*t)*0.65+sin(TAU*frequency*2*t)*0.18
		if name == "launch" or name == "build": wave += rng.randf_range(-0.15,0.15)
		bytes.encode_s16(i*2,int(clampf(wave*envelope,-1,1)*24000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = bytes
	return stream
