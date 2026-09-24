extends RefCounted
static var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/territories.json"))
static func profiles(id: String) -> Dictionary:
	if not catalog.has(id): return {}
	var result: Dictionary = {}
	for row: Array in [["civic","Civic hall","ground",[-6,-18],240,0],["housing","Habitation terraces","ground",[-13,-18],96,0],["industry","Export works","ground",[1,-18],96,0],["turret_a","Colony turret","ground",[-17,-11],64,16],["turret_b","Colony turret","ground",[5,-11],64,16],["patrol","Defense patrol","air",[-6,-26],48,14]]:
		result[row[0]] = {"name":row[1],"kind":row[2],"at":row[3],"hull":row[4],"damage":row[5],"range":30,"radius":4,"windup":2,"color":catalog[id].color,"goods":catalog[id].goods,"civilian":row[5] == 0}
	return result
