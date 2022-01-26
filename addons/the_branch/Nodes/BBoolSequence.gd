tool
class_name BBoolSequence
extends BaseBNode

func display_name() -> String: return "Boolean Sequence"
func hint() -> String: return "Executes all of the functions on the parent node in order, then advances based on the first function to return \"true.\""

var functions := []

func addtl_save(d:Dictionary) -> Dictionary:
	d["type"] = "BBoolSequence"
	var funcs := []
	for f in functions:
		funcs.append((f as BInnerFunction).get_as_dictionary())
	d["functions"] = funcs
	return d
func addtl_restore(d:Dictionary):
	for f in d["functions"]:
		_on_add_function(f)
	
func _ready():
	var top := VBoxContainer.new()
	add_child(top)
	var func_button := Button.new()
	func_button.text = "Add Function"
	func_button.hint_tooltip = "Add a new function to the sequence."
	func_button.connect("pressed", self, "_on_add_function")
	top.add_child(func_button)
	top.add_child(separator())
	set_slot(0, true, 0, SLOT_COLOR, false, 0, SLOT_COLOR)
	
	var bottom := VBoxContainer.new()
	add_child(bottom)
	bottom.add_child(separator())
	var else_label := Label.new()
	else_label.align = Label.ALIGN_RIGHT
	else_label.text = "else"
	bottom.add_child(else_label)
	set_slot(1, false, 0, SLOT_COLOR, true, 0, SLOT_COLOR)
	bottom.add_child(separator())

func _on_add_function(d:Dictionary = {}):
	emit_signal("change_made")
	var func_node := BInnerFunction.new()
	add_child(func_node)
	if d.has("name"): func_node.restore_from_dictionary(d)
	functions.append(func_node)
	func_node.connect("change_made", self, "_on_change")
	func_node.connect("delete", self, "_on_delete_function", [func_node])
	func_node.connect("view_source", self, "_on_view_source", [true])
	move_child(func_node, functions.size())
	set_slot(functions.size() + 1, false, 0, SLOT_COLOR, true, 0, SLOT_COLOR)
	emit_signal("insert_slot", name, functions.size() - 1)

func _on_delete_function(f:BInnerFunction):
	emit_signal("change_made")
	var idx := functions.find(f)
	emit_signal("delete_slot", name, idx)
	functions.erase(f)
	f.queue_free()
