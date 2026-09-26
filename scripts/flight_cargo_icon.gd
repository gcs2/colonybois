extends RefCounted
## Resolves the painted cargo and specimen portraits used by the flight HUD.

const SPECIMEN_TEXTURES: Dictionary = {
	"moss_lantern": preload("res://assets/specimens/moss_lantern.png"),
	"ribbon_bush": preload("res://assets/specimens/ribbon_bush.png"),
	"hollow_crown": preload("res://assets/specimens/hollow_crown.png"),
	"pocket_manta": preload("res://assets/specimens/pocket_manta.png"),
	"button_strider": preload("res://assets/specimens/button_strider.png"),
	"veil_maw": preload("res://assets/specimens/veil_maw.png"),
	"glass_moss": preload("res://assets/specimens/glass_moss.png"),
	"chime_reed": preload("res://assets/specimens/chime_reed.png"),
	"sleeper_tree": preload("res://assets/specimens/sleeper_tree.png"),
	"snow_bell": preload("res://assets/specimens/snow_bell.png"),
	"velvet_skate": preload("res://assets/specimens/velvet_skate.png"),
	"lantern_jaw": preload("res://assets/specimens/lantern_jaw.png"),
	"ember_button": preload("res://assets/specimens/ember_button.png"),
	"sail_thistle": preload("res://assets/specimens/sail_thistle.png"),
	"cup_spire": preload("res://assets/specimens/cup_spire.png"),
	"dune_hopper": preload("res://assets/specimens/dune_hopper.png"),
	"sun_kite": preload("res://assets/specimens/sun_kite.png"),
	"hush_beak": preload("res://assets/specimens/hush_beak.png"),
}

static func texture_for(entry_id: String) -> Texture2D:
	if entry_id.begins_with("cargo:"):
		var item_id: String = entry_id.trim_prefix("cargo:")
		if item_id in ["alloy", "water", "glass", "colony_kit"]:
			return preload("res://scripts/communicator_style.gd").equipment_icon(item_id)
		return null

	if entry_id.begins_with("specimen:"):
		var species_id: String = entry_id.trim_prefix("specimen:")
		return SPECIMEN_TEXTURES.get(species_id) as Texture2D

	return null
