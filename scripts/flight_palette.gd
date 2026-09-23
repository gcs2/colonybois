extends RefCounted
## Presentation entries only. Effects and ownership remain in EncounterState.
const Equipment = preload("res://scripts/equipment_catalog.gd")
const Model = preload("res://scripts/encounter_state.gd")
const PAGE_SIZE := 18
const CATEGORY_ICONS := {"Main tools":"category_tools", "Environment":"category_life", "Weapons":"category_weapons", "Inventory":"inventory"}
static func slot_rect(slot: int) -> Rect2:
	return Rect2(766+(slot%9)*59,748+(slot/9)*56,56,54)
const GROUPS := {
	"Main tools": ["scan", "collect"],
	"Environment": ["warm", "seed"],
	"Weapons": ["lance"],
	"Inventory": ["pack"],
}

static func entry(id: String) -> Dictionary:
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
	return {}

static func unavailable(id: String, model: RefCounted) -> String:
	var item: Dictionary = entry(id)
	if item.is_empty(): return "Unknown item"
	if item.view != "both" and item.view != model.state.flight_mode:
		return "Available in orbit" if item.view == "orbit" else "Enter the atmosphere to use this tool"
	if id == "pack": return model.pack_reason()
	return ""

static func count(id: String, state: Dictionary) -> String:
	if id == "pack": return "× %d" % state.energy_packs
	if id == "seed": return "× %d" % state.samples
	return ""
