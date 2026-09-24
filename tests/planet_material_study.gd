extends "res://scripts/planet_generator.gd"
## Review-only albedo separation. Geographic samples and gameplay remain unchanged.
func surface_color(cell: Dictionary) -> Color:
	var unshaded: Dictionary=cell.duplicate()
	unshaded.ruggedness=1.0
	var base: Color=super.surface_color(unshaded)
	if recipe.get("archetype","")!="frozen" or cell.temperature_c>=0: return base
	if cell.elevation<0:
		# Broad dark ocean and smooth sea ice remain distinct from land snow.
		var water: Color=palette.deep_ocean.lerp(palette.shallow_ocean,smoothstep(-0.20,0.0,cell.elevation))
		var cover: float=(1.0-smoothstep(-22,-5,cell.temperature_c))*0.84
		return water.lerp(palette.ice.darkened(.14),cover)
	var snow: Color=palette.ice.darkened(.13).lerp(palette.lowland,.12+cell.moisture*.12)
	var exposure: float=smoothstep(.08,.36,cell.elevation)*(.3+.7*smoothstep(.32,.66,cell.moisture))
	return snow.lerp(palette.highland,exposure*.68)
