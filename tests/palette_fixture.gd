extends RefCounted
## Dense layout fixture only. These are NOT playable equipment or inventory grants.
static func populate(hud: Control) -> void:
	var names := ["planet_map","communicator","category_tools","category_life","category_weapons","inventory","subsystems","scan","collect","warm","seed","energy_pack"]
	for index: int in range(25):
		var id: String = "layout_fixture_%02d" % index
		var item := {"title":"Layout specimen %02d · preview only" % index,"icon":names[index%names.size()],"tint":Color.from_hsv(index/25.0,0.35,0.95),"hint":"Layout fixture, not implemented content"}
		hud._make_item(id,item)
		hud.GROUPS["Main tools"].append(id)
		hud.count_labels[id].text = "× %d" % (index*3+1)
	hud.show_group("Main tools")
