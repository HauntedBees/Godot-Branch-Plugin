tool
class_name BRepeatNode
extends BaseBNode

func display_name() -> String: return "Restart"
func hint() -> String: return "When this node is reached, the flow will return to the Start Node."

func addtl_save(dict:Dictionary) -> Dictionary:
	dict["type"] = "BRepeatNode"
	return dict

func _ready():
	add_child(separator())
	var label := Label.new()
	label.text = "Restart"
	add_child(label)
	add_child(separator())
	set_slot(1, true, 0, SLOT_COLOR, false, 0, SLOT_COLOR)
