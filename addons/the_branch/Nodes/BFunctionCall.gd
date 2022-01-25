tool
class_name BFunctionCall
extends BaseBNode

func display_name() -> String: return "Function Call"
func hint() -> String: return "Executes the function on the parent node, then advances to the next node."

var function:BInnerFunction

func addtl_save(d:Dictionary) -> Dictionary:
	d["type"] = "BFunctionCall"
	d["func"] = function.get_as_dictionary()
	return d
func addtl_restore(d:Dictionary):
	function.restore_from_dictionary(d["func"])

func _ready():
	function = BInnerFunction.new()
	function.allow_delete = false
	add_child(function)
	set_slot(0, true, 0, SLOT_COLOR, true, 0, SLOT_COLOR)
