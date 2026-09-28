extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const FoundingScreen = preload("res://scripts/expedition_founding_screen.gd")
const EncounterScript = preload("res://scripts/encounter.gd")
const MainScript = preload("res://scripts/main.gd")
var checks: int = 0
var failures: int = 0

func _initialize() -> void: call_deferred("run")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: "+title)

func run() -> void:
	var scientist := Session.new()
	check(not Session.valid_captain_name("  ") and not Session.valid_captain_name("line\nbreak"),"Captain name rejects empty and control-character input")
	check(scientist.found_captain("  Mira  ","unknown") != "" and scientist.captain.philosophy == "unrecorded","Invalid philosophy does not create identity")
	check(scientist.found_captain("  Mira  ","scientist").is_empty() and scientist.captain.name == "Mira","New flight accepts and trims captain name")
	check(scientist.diplomacy.state.events.size() == 1 and scientist.diplomacy.state.events[0].kind == "captain","Founding choice is recorded once in the campaign chronicle")
	check(not scientist.found_captain("Again","knight").is_empty(),"An established captain cannot be silently replaced")
	check(scientist.field.change_flight_mode("orbit") and scientist.field.start_survey().is_empty(),"Scientist commitment starts through the existing orbital survey")
	for _tick: int in range(int(scientist.field.definition().survey_seconds)+1): scientist.tick()
	check(scientist.captain.commitment_complete,"Completing Morrow's real orbital survey fulfills the Scientist commitment")
	var survey_event: Dictionary = scientist.diplomacy.state.events.filter(func(event: Dictionary) -> bool: return event.kind == "exploration").back()
	var scientist_completions: Array = scientist.diplomacy.state.events.filter(func(event: Dictionary) -> bool: return event.kind == "captain" and event.outcome.get("action","") == "orbital_survey")
	var scientist_completion: Dictionary = scientist_completions.back() if not scientist_completions.is_empty() else {}
	check(not scientist_completion.is_empty() and scientist_completion.cause == survey_event.id,"Scientist completion links to the survey in campaign history")
	var restored := Session.new()
	var scientist_snapshot: Dictionary = scientist.snapshot()
	check(restored.restore_snapshot(scientist_snapshot) == OK and restored.snapshot() == scientist_snapshot,"Captain identity and completed commitment persist in a campaign round trip")
	var invalid: Dictionary = scientist_snapshot.duplicate(true)
	invalid.captain.founding_event = 999
	check(restored.restore_snapshot(invalid) != OK and restored.snapshot() == scientist_snapshot,"Invalid captain references cannot partially replace a saved campaign")

	var zealot := Session.new()
	zealot.found_captain("Sola","zealot")
	check(not zealot.report_captain_action("species_release",{"planet":"morrow","species":"moss_lantern"},zealot.captain.founding_event),"Zealot commitment requires moving life beyond its home world")
	var release_event: int = zealot.diplomacy.record(zealot,"ecology","Introduced Moss Lantern at a new world.","",{"planet":"s1p0","species":"moss_lantern","action":"release"})
	check(zealot.report_captain_action("species_release",{"planet":"s1p0","species":"moss_lantern"},release_event) and zealot.captain.commitment_complete,"A successful cross-world species release fulfills the Zealot commitment")
	check(zealot.diplomacy.state.events.back().cause == release_event,"Zealot completion links to the ecological action")

	var knight := Session.new()
	knight.found_captain("Tarin","knight")
	check(not knight.report_captain_action("custodian_neutralized",{"planet":"s1p0"}),"Knight commitment is specific to Morrow's custodian")
	var combat_event: int = knight.diplomacy.record(knight,"combat","Neutralized Morrow's custodian.","",{"planet":"morrow"})
	check(knight.report_captain_action("custodian_neutralized",{"planet":"morrow"},combat_event) and knight.captain.commitment_complete,"Neutralizing Morrow's existing custodian fulfills the Knight commitment")

	var legacy := Session.new().snapshot()
	legacy.version = 24
	legacy.erase("captain")
	var legacy_restore := Session.new()
	check(legacy_restore.restore_snapshot(legacy) == OK and legacy_restore.captain.philosophy == "unrecorded" and legacy_restore.diplomacy.state.events.is_empty(),"Version 24 saves migrate without fabricating a captain or founding event")
	var rolled_back := Session.new()
	rolled_back.found_captain("Mira","scientist")
	rolled_back.rollback_captain_foundation()
	check(rolled_back.captain.philosophy == "unrecorded" and rolled_back.diplomacy.state.events.is_empty(),"A failed first save can roll back the unstarted founder event")
	var screen := FoundingScreen.new()
	get_root().add_child(screen)
	var selection: Array = []
	screen.connect("begin_requested",func(captain_name: String, philosophy: String) -> void: selection.append([captain_name,philosophy]))
	screen.call("_begin")
	check(selection.is_empty() and not str(screen.get("error_label").text).is_empty(),"Founding screen requires a name before beginning")
	screen.get("name_entry").text = "Nia"
	screen.set("selected","knight")
	screen.call("_begin")
	check(selection == [["Nia","knight"]],"Founding screen emits the selected captain identity")
	screen.queue_free()
	check(EncounterScript != null and MainScript != null,"Encounter and menu launch scripts load with the founding flow")

	print("Captain founding: %d checks, %d failures" % [checks,failures])
	quit(1 if failures > 0 else 0)
