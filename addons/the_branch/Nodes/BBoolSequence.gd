tool
class_name BBoolSequence
extends BaseBNode

func display_name() -> String: return "Boolean Sequence"
func hint() -> String: return "Executes all of the functions on the parent node in order, then advances to the next node."

var functions := []
var num_elements := 0

func addtl_save(d:Dictionary) -> Dictionary:
	d["type"] = "BFunctionSequence"
	var funcs := []
	for f in functions:
		funcs.append((f as BInnerFunction).get_as_dictionary())
	d["functions"] = funcs
	return d
func addtl_restore(d:Dictionary):
	for f in d["functions"]:
		_on_add_function(f)
	
func _ready():
	var func_button := Button.new()
	func_button.text = "Add Function"
	func_button.hint_tooltip = "Add a new function to the sequence."
	func_button.connect("pressed", self, "_on_add_function")
	add_child(func_button)
	add_child(separator())
	num_elements = get_child_count() - 1
	set_slot(0, true, 0, SLOT_COLOR, false, 0, SLOT_COLOR)

func _on_add_function(d:Dictionary = {}):
	emit_signal("change_made")
	var func_node := BInnerFunction.new()
	add_child(func_node)
	if d.has("name"): func_node.restore_from_dictionary(d)
	functions.append(func_node)
	func_node.connect("change_made", self, "_on_change")
	func_node.connect("delete", self, "_on_delete_function", [func_node])
	set_slot(num_elements + functions.size(), false, 0, SLOT_COLOR, true, 0, SLOT_COLOR)

func _on_delete_function(f:BInnerFunction):
	var idx := functions.find(f)
	emit_signal("change_made")
	emit_signal("delete_slot", name, idx)
	functions.erase(f)
	f.queue_free()
