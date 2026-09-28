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
const TOOL_ATLAS_IDS: Dictionary = {
	"heat_ray":"heat_ray",
	"cool_ray":"cool_ray",
	"cloud_accumulator":"cloud_accumulator",
	"cloud_vacuum":"cloud_vacuum",
	"lance":"emitter",
	"seeker":"seeker",
	"ground_bomb":"ground_bomb",
	"shield":"shield",
	"rally_call":"rally_call",
}
## Exact visual matches for the three surface exploration actions.
const ACTION_TEXTURES: Dictionary = {
	"scan": preload("res://art/visual-canon/ui-element-candidates/pictorial-cutouts-v5/field-survey-scanner-v1.png"),
	"collect": preload("res://art/visual-canon/ui-element-candidates/pictorial-cutouts-v5/field-sampling-cradle-v1.png"),
	"mine": preload("res://art/visual-canon/ui-element-candidates/pictorial-cutouts-v5/ore-seam-cutter-v1.png"),
}
## Tight visible-alpha bounds measured inside equipment-objects-v1.png cells.
## The atlas contains soft transparent edge pixels outside these bounds; using
## the opaque artwork bounds lets the existing slot aperture show more of each
## item without changing slot size, texture tint, or source art.
const EQUIPMENT_VISIBLE_BOUNDS: Dictionary = {
	"colony_kit": Rect2(44, 85, 265, 228),
	"shield": Rect2(36, 79, 269, 234),
	"rally_call": Rect2(58, 50, 195, 263),
	"heat_ray": Rect2(4, 105, 283, 208),
	"cool_ray": Rect2(39, 84, 274, 198),
	"cloud_accumulator": Rect2(0, 0, 284, 314),
	"cloud_vacuum": Rect2(73, 0, 156, 314),
	"seeker": Rect2(14, 0, 267, 307),
	"ground_bomb": Rect2(38, 49, 275, 224),
	"hold": Rect2(0, 27, 305, 286),
	"emitter": Rect2(23, 0, 271, 313),
	"drive": Rect2(22, 34, 271, 247),
	"hull": Rect2(36, 6, 277, 232),
	"energy": Rect2(0, 0, 255, 250),
	"water": Rect2(63, 0, 250, 247),
	"alloy": Rect2(0, 25, 289, 211),
}

static func tool_texture_for(tool_id: String) -> Texture2D:
	var action_texture := ACTION_TEXTURES.get(tool_id) as Texture2D
	if action_texture != null:
		return action_texture
	if tool_id == "pack":
		# Use the visible canister rather than scaling its large transparent canvas.
		# Ownership and stack count still come from EncounterState.
		var picture := AtlasTexture.new()
		picture.atlas = preload("res://art/visual-canon/ui-element-candidates/pictorial-cutouts-v4/energy-pack-v2.png")
		picture.region = Rect2(423, 130, 540, 895)
		return picture
	# Use only exact semantic matches from the documented painted equipment atlas.
	# Actions without a suitable authored picture retain their own current fallback.
	if not TOOL_ATLAS_IDS.has(tool_id):
		return null
	var atlas_id := str(TOOL_ATLAS_IDS[tool_id])
	return _trim_equipment_texture(atlas_id)

static func texture_for(entry_id: String) -> Texture2D:
	if entry_id.begins_with("cargo:"):
		var item_id: String = entry_id.trim_prefix("cargo:")
		if item_id in ["alloy", "water", "glass", "colony_kit"]:
			return _trim_equipment_texture(item_id)
		return null

	if entry_id.begins_with("specimen:"):
		var species_id: String = entry_id.trim_prefix("specimen:")
		return SPECIMEN_TEXTURES.get(species_id) as Texture2D

	return null

static func _trim_equipment_texture(item_id: String) -> Texture2D:
	var texture: Texture2D = preload("res://scripts/communicator_style.gd").equipment_icon(item_id)
	if not texture is AtlasTexture or not EQUIPMENT_VISIBLE_BOUNDS.has(item_id):
		return texture
	var atlas_texture := texture as AtlasTexture
	var bounds: Rect2 = EQUIPMENT_VISIBLE_BOUNDS[item_id]
	var cropped := AtlasTexture.new()
	cropped.atlas = atlas_texture.atlas
	var crop_size := Vector2(
		minf(bounds.size.x, atlas_texture.region.size.x - bounds.position.x),
		minf(bounds.size.y, atlas_texture.region.size.y - bounds.position.y)
	)
	cropped.region = Rect2(atlas_texture.region.position + bounds.position, crop_size)
	cropped.filter_clip = true
	return cropped
