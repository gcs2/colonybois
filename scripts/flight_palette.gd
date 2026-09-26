extends RefCounted
## Presentation entries only. Effects and ownership remain in EncounterState.
const Equipment = preload("res://scripts/equipment_catalog.gd")
const Model = preload("res://scripts/encounter_state.gd")
const Combat = preload("res://scripts/surface_combat.gd")
const Climate = preload("res://scripts/planet_climate.gd")
const COLUMNS := 6
const PAGE_SIZE := 12
const CATEGORY_ICONS := {"Main tools":"category_tools", "Environment":"category_life", "Weapons":"category_weapons", "Inventory":"inventory"}
static func slot_rect(slot: int) -> Rect2:
	return Rect2(766+(slot%COLUMNS)*59,748+(slot/COLUMNS)*56,56,54)
const GROUPS := {
	"Main tools": ["scan", "collect", "mine"],
	"Environment": ["heat_ray","cool_ray","cloud_accumulator","cloud_vacuum","heat_charge","cool_charge","atmosphere_charge","vacuum_charge","warm", "seed"],
	"Weapons": ["lance","surface_laser","seeker","ground_bomb","shield","rally_call"],
	"Inventory": ["pack","repair_pack","mega_repair_pack"],
}

static func entry(id: String) -> Dictionary:
	if Model.Support.catalog.has(id):
		var spec: Dictionary = Model.Support.catalog[id]
		return {"id":id,"title":spec.name,"icon":id,"tint":Color(spec.color),"kind":"ability","view":"both","summary":spec.description,"hint":"%s %d energy; %d seconds active; %d-second cooldown. Click to activate without changing your selected weapon." % [spec.description,spec.energy,spec.duration,spec.cooldown]}
	if Climate.data().tools.has(id):
		var spec: Dictionary = Climate.data().tools[id]
		return {"id":id,"title":spec.name,"icon":id,"tint":Color(spec.color),"kind":"tool","view":"both","summary":"%+d global %s · eight-second pulse" % [spec.delta,spec.axis],"hint":"%+d global %s over eight seconds. %s Click the planet or terrain. Unstabilized climate drifts toward native conditions." % [spec.delta,spec.axis,"Consumes one owned unit." if spec.charge else "%d energy per pulse." % spec.energy]}
	if Combat.data().weapons.has(id):
		var spec: Dictionary = Combat.data().weapons[id]
		return {"id":id,"title":spec.name,"icon":id,"tint":Color("eba66d"),"kind":"tool","view":"surface",
			"summary":spec.role,"hint":"%s %d damage; %d energy; %d m reach; %d s cycle." % [spec.role,spec.damage,spec.energy,spec.range,spec.cooldown]}
	if Equipment.has_tool(id):
		return {"id":id, "title":Equipment.title(id), "icon":id,
			"tint":Equipment.tint(id), "kind":"tool", "view":"surface",
			"summary":Equipment.summary(id), "hint":Equipment.hint(id)}
	if id == "lance":
		return {"id":id, "title":"Arc lance · energy weapon", "icon":"lance",
			"tint":Color("eba66d"), "kind":"tool", "view":"orbit",
			"summary":"Click an enemy · %d energy / shot · %d s cooldown" % [Model.LANCE_ENERGY,Model.LANCE_COOLDOWN],
			"hint":"Installed energy weapon. Select, then click an enemy. No ammunition. %d m reach; %d energy per shot; %d s cooldown." % [Model.LANCE_RANGE,Model.LANCE_ENERGY,Model.LANCE_COOLDOWN]}
	if id == "pack":
		return {"id":id, "title":"Energy pack", "icon":"energy_pack",
			"tint":Color("f3c567"), "kind":"consumable", "view":"both",
			"summary":"Use one owned pack · restores %d energy" % Model.PACK_ENERGY,
			"hint":"Inventory item. Use one pack to restore %d energy. Excess is lost. Buy packs through local ship services; %d s cooldown." % [Model.PACK_ENERGY,Model.PACK_COOLDOWN]}
	if Model.repair_items().has(id):
		var supply: Dictionary = Model.repair_items()[id]
		return {"id":id,"title":supply.name,"icon":id,"tint":Color("a5e4c2"),"kind":"consumable","view":"both",
			"summary":supply.description,"hint":"%s Consumes one owned pack, no energy. Shared repair cooldown: %d seconds. Three repair packs fit in the locker." % [supply.description,Model.REPAIR_COOLDOWN]}
	return {}

static func unavailable(id: String, model: RefCounted) -> String:
	var item: Dictionary = entry(id)
	if item.is_empty(): return "Unknown item"
	if item.view != "both" and item.view != model.state.flight_mode:
		return "Available in orbit" if item.view == "orbit" else "Enter the atmosphere to use this tool"
	if Combat.data().weapons.has(id) and not Combat.installed(model,id): return "Purchase this weapon at a dock."
	if Climate.data().tools.has(id): return "Requires the shared campaign." if model.planetary == null else model.planetary.available(model,id)
	if Model.Support.catalog.has(id): return Model.Support.reason(model,id)
	if id == "pack": return model.pack_reason()
	if Model.repair_items().has(id): return model.repair_pack_reason(id)
	return ""

static func count(id: String, state: Dictionary) -> String:
	if Model.Support.catalog.has(id):
		var entry: Dictionary = state.support[id]
		return "%ds" % (entry.until-state.time) if entry.until > state.time else "%ds" % (entry.ready-state.time) if entry.ready > state.time else ""
	if id == "pack": return "× %d" % state.energy_packs
	if Model.repair_items().has(id): return "× %d" % state.repair_packs[id]
	if id == "seed": return "× %d" % state.samples
	return ""
