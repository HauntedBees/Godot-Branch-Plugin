tool
class_name BStartNode
extends BaseBNode

func display_name() -> String: return "Start"
func hint() -> String: return "This is the starting point."

func addtl_save(dict:Dictionary) -> Dictionary:
	dict["type"] = "BStartNode"
	return dict

func _ready():
	add_child(separator())
	var label := Label.new()
	label.text = "Start"
	add_child(label)
	add_child(separator())
	set_slot(1, false, 0, SLOT_COLOR, true, 0, SLOT_COLOR)
