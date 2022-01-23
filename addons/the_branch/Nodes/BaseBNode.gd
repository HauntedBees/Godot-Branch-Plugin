tool
class_name BaseBNode
extends GraphNode

func save() -> Dictionary:
	var save_dict := {
		"name": name,
		"type": "node",
		"filename": get_filename(),
		"pos_x": offset.x,
		"pos_y": offset.y,
		"rect_x": rect_size.x,
		"rect_y": rect_size.y
	}
	return addtl_save(save_dict)
func addtl_save(dict:Dictionary) -> Dictionary: return dict

func restore(dict:Dictionary):
	name = dict["name"]
	offset = Vector2(dict["pos_x"], dict["pos_y"])
	rect_size = Vector2(dict["rect_x"], dict["rect_y"])
	addtl_restore(dict)
func addtl_restore(dict:Dictionary): return
