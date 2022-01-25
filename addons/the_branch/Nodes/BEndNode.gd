tool
class_name BEndNode
extends BaseBNode

func display_name() -> String: return "End"
func hint() -> String: return "A nice little end to your branching journey :)."

func addtl_save(dict:Dictionary) -> Dictionary:
	dict["type"] = "BEndNode"
	return dict

func _ready():
	add_child(separator())
	var label := Label.new()
	label.text = "End"
	add_child(label)
	add_child(separator())
	set_slot(1, true, 0, SLOT_COLOR, false, 0, SLOT_COLOR)
