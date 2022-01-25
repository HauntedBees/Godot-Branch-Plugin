tool
class_name BVarComparison
extends BaseBNode

func display_name() -> String: return "Variable Comparison"
func hint() -> String: return "Executes all of the functions on the parent node in order, then advances to the next node."

var comparisons := []

func addtl_save(d:Dictionary) -> Dictionary:
	d["type"] = "BVarComparison"
	var comps := []
	for c in comparisons:
		comps.append((c as BVarCompare).get_as_dictionary())
	d["comparisons"] = comps
	return d
func addtl_restore(d:Dictionary):
	for c in d["comparisons"]:
		_on_add_comparison(c)
	
func _ready():
	var top := VBoxContainer.new()
	add_child(top)
	# TODO: the fucking variable
	
	var comp_button := Button.new()
	comp_button.text = "Add Comparison"
	comp_button.hint_tooltip = "Add a comparison slot."
	comp_button.connect("pressed", self, "_on_add_comparison")
	top.add_child(comp_button)
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

func _on_add_comparison(d:Dictionary = {}):
	emit_signal("change_made")
	var comp_node := BVarCompare.new()
	add_child(comp_node)
	if d.has("value"): comp_node.restore_from_dictionary(d)
	comparisons.append(comp_node)
	comp_node.connect("change_made", self, "_on_change")
	#comp_node.connect("delete", self, "_on_delete_function", [comp_node]) # TODO: this
	move_child(comp_node, comparisons.size())
	set_slot(comparisons.size() + 1, false, 0, SLOT_COLOR, true, 0, SLOT_COLOR)
	emit_signal("insert_slot", name, comparisons.size() - 1)

func _on_delete_function(c:BVarCompare):
	emit_signal("change_made")
	var idx := comparisons.find(c)
	emit_signal("delete_slot", name, idx)
	comparisons.erase(c)
	c.queue_free()
