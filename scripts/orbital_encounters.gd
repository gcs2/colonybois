extends RefCounted
## Authored encounters, separate from government/species. Raiders are not an empire.
static var catalog: Dictionary = {}
static func profile(planet: String) -> Dictionary:
	if catalog.is_empty(): catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/orbital_encounters.json"))
	return catalog.get(planet,{})
static func hull(planet: String) -> float:
	return float(profile(planet).get("hull",66))
