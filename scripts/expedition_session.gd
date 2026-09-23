extends RefCounted
## Campaign ownership boundary: one treasury, fixed clock and atomic save for both models.
## Local encounter rules still describe Morrow; other landable worlds come next.
const Sector = preload("res://scripts/simulation.gd")
const Field = preload("res://scripts/encounter_state.gd")
const VERSION := 1
const SECONDS_PER_DAY := 30
const HEADER := "FWEXP001"
var sector := Sector.new()
var field := Field.new()
var sector_clock: int = 0

func _init() -> void:
	sector.new_game()
	# A new flight campaign keeps the existing zero-Mark start. No migration windfall.
	sector.state.credits = field.marks
	sector.state.planets.s0p0.name = "Morrow"
	field.bind_account(sector.state)

func tick(threat_distance: float = INF) -> String:
	var result: String = field.tick(threat_distance)
	sector_clock += 1
	if sector_clock >= SECONDS_PER_DAY:
		sector_clock = 0
		sector.tick()
	return result

func import_legacy(path: String) -> Error:
	var imported := Field.new()
	var error: Error = imported.load_from(path)
	if error != OK: return error
	# Never combine balances from unrelated strategic and field campaigns.
	sector.state.credits = imported.marks
	field = imported
	field.bind_account(sector.state)
	sector_clock = 0
	return OK

static func newest_save(manual: String, automatic: String) -> String:
	if not FileAccess.file_exists(manual): return automatic if FileAccess.file_exists(automatic) else ""
	if not FileAccess.file_exists(automatic): return manual
	return automatic if FileAccess.get_modified_time(automatic) > FileAccess.get_modified_time(manual) else manual

func snapshot() -> Dictionary:
	return {"version":VERSION,"sector_clock":sector_clock,
		"sector":sector.state.duplicate(true),"field":field.state.duplicate(true)}

func save_to(path: String) -> Error:
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_buffer(HEADER.to_utf8_buffer())
	file.store_var(snapshot(),false)
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK: return error
	return DirAccess.rename_absolute(path+".tmp",path)

func load_from(path: String) -> Error:
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null: return FileAccess.get_open_error()
	if file.get_buffer(8).get_string_from_utf8() != HEADER: return ERR_FILE_UNRECOGNIZED
	if file.get_length() < 16: return ERR_INVALID_DATA
	var payload_size: int = file.get_32()
	if payload_size < 4 or payload_size != file.get_length()-12: return ERR_INVALID_DATA
	file.seek(8)
	return restore_snapshot(file.get_var(false))

func restore_snapshot(source: Variant) -> Error:
	if not source is Dictionary or not source.has_all(["version","sector_clock","sector","field"]): return ERR_INVALID_DATA
	if source.version != VERSION or not source.sector_clock is int or source.sector_clock < 0 or source.sector_clock >= SECONDS_PER_DAY: return ERR_INVALID_DATA
	if not source.sector is Dictionary or not source.field is Dictionary: return ERR_INVALID_DATA
	var bank: Variant = source.sector.get("credits")
	if not (bank is float or bank is int) or not is_finite(float(bank)) or bank < 0: return ERR_INVALID_DATA
	# Detached candidates keep failed loads from half-replacing a live campaign.
	var candidate_sector := Sector.new()
	var error: Error = candidate_sector.restore_snapshot(source.sector)
	if error != OK: return error
	var candidate_field := Field.new()
	var field_data: Dictionary = source.field.duplicate(true)
	if field_data.has("marks"): return ERR_INVALID_DATA
	field_data["marks"] = 0
	error = candidate_field.restore_snapshot(field_data)
	if error != OK: return error
	sector.state = candidate_sector.state
	field.state = candidate_field.state
	field.bind_account(sector.state)
	sector_clock = source.sector_clock
	return OK
