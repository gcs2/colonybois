extends RefCounted
## Resolves the painted cargo and specimen portraits used by the flight HUD.

static func texture_for(entry_id: String) -> Texture2D:
	if entry_id.begins_with("cargo:"):
		var item_id: String = entry_id.trim_prefix("cargo:")
		if item_id in ["alloy", "water", "glass", "colony_kit"]:
			return preload("res://scripts/communicator_style.gd").equipment_icon(item_id)
		return null

	if entry_id.begins_with("specimen:"):
		var species_id: String = entry_id.trim_prefix("specimen:")
		if species_id.is_empty() or species_id.contains("/") or species_id.contains("\\") or species_id.contains(".."):
			return null
		var portrait_path: String = "res://assets/specimens/%s.png" % species_id
		if not ResourceLoader.exists(portrait_path, "Texture2D"):
			return null
		return load(portrait_path) as Texture2D

	return null
