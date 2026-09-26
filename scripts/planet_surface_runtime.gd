extends RefCounted
## Small runtime boundary over a saved recipe's spherical sampler and bounded surface query.
## Scale values are provisional tuning inputs, not permanent planet or region contracts.

const PlanetGenerator = preload("res://scripts/planet_generator.gd")
const Coordinates = preload("res://scripts/planet_surface_coordinates.gd")
const SurfaceWindow = preload("res://scripts/planet_surface_window.gd")

const PROVISIONAL_PLANET_RADIUS_M: float = SurfaceWindow.DEFAULT_PLANET_RADIUS_M
const PROVISIONAL_REGION_SIZE_M: float = SurfaceWindow.DEFAULT_REGION_SIZE_M
const PROVISIONAL_FEATURE_WINDOW_RADIUS_M: float = 1500.0
const PROVISIONAL_HEIGHT_SCALE_M: float = 34.0

var recipe: Dictionary
var generator: Object
var planet_radius_m: float:
	get: return _planet_radius_m
var region_size_m: float:
	get: return _region_size_m
var view_radius_m: float:
	get: return _view_radius_m
var _planet_radius_m: float
var _region_size_m: float
var _view_radius_m: float

static func normalized_recipe(source_recipe: Dictionary) -> Dictionary:
	var climate: Variant = source_recipe.get("climate", {})
	var sites: Variant = source_recipe.get("sites", [])
	var basins: Variant = source_recipe.get("basins", [])
	var waterbodies: Variant = source_recipe.get("waterbodies", [])
	return {
		"id": str(source_recipe.get("id", source_recipe.get("planet_id", ""))).to_lower(),
		"geography_seed": int(source_recipe.get("geography_seed", source_recipe.get("seed", 0))),
		"generator_version": int(source_recipe.get("generator_version", 1)),
		"archetype": str(source_recipe.get("archetype", "temperate")),
		"climate": climate.duplicate(true) if climate is Dictionary else {},
		"sites": sites.duplicate(true) if sites is Array else [],
		"basins": basins.duplicate(true) if basins is Array else [],
		"waterbodies": waterbodies.duplicate(true) if waterbodies is Array else []
	}

func _init(
		source_recipe: Dictionary,
		planet_radius: float = PROVISIONAL_PLANET_RADIUS_M,
		region_size: float = PROVISIONAL_REGION_SIZE_M,
		view_radius: float = PROVISIONAL_FEATURE_WINDOW_RADIUS_M
	) -> void:
	assert(is_finite(planet_radius) and planet_radius > 0.0, "planet_radius must be a positive finite scale")
	assert(is_finite(region_size) and region_size > 0.0, "region_size must be a positive finite scale")
	assert(is_finite(view_radius) and view_radius > 0.0, "view_radius must be a positive finite scale")
	_planet_radius_m = planet_radius
	_region_size_m = region_size
	_view_radius_m = view_radius
	recipe = normalized_recipe(source_recipe)
	generator = PlanetGenerator.new(recipe)

func matches_recipe(source_recipe: Dictionary) -> bool:
	var source_id: String = str(source_recipe.get("id", source_recipe.get("planet_id", ""))).to_lower()
	var climate: Variant = source_recipe.get("climate", {})
	var sites: Variant = source_recipe.get("sites", [])
	var basins: Variant = source_recipe.get("basins", [])
	var waterbodies: Variant = source_recipe.get("waterbodies", [])
	if not climate is Dictionary: climate = {}
	if not sites is Array: sites = []
	if not basins is Array: basins = []
	if not waterbodies is Array: waterbodies = []
	return (
		recipe.id == source_id
		and int(recipe.geography_seed) == int(source_recipe.get("geography_seed", source_recipe.get("seed", 0)))
		and int(recipe.generator_version) == int(source_recipe.get("generator_version", 1))
		and str(recipe.archetype) == str(source_recipe.get("archetype", "temperate"))
		and recipe.climate == climate
		and recipe.sites == sites
		and recipe.basins == basins
		and recipe.waterbodies == waterbodies
	)

func sample(up: Vector3) -> Dictionary:
	return generator.sample(up)

func surface_color(up: Vector3) -> Color:
	return generator.surface_color(sample(up))

func advance(up: Vector3, east_m: float, north_m: float) -> Vector3:
	return Coordinates.advance(up, east_m, north_m, _planet_radius_m)

func window(center_up: Vector3) -> Dictionary:
	return SurfaceWindow.build(recipe, center_up, _planet_radius_m, _region_size_m, _view_radius_m)

func region_id(up: Vector3) -> String:
	var grid: Dictionary = SurfaceWindow._grid(_planet_radius_m, _region_size_m)
	var cell: Vector2i = SurfaceWindow._cell_for_up(up, grid)
	return SurfaceWindow._region_id(recipe, grid, cell.x, cell.y)

func local_offset(origin_up: Vector3, target_up: Vector3) -> Vector2:
	return Coordinates.local_offset(origin_up, target_up, _planet_radius_m)
