tool
class_name BVarComparison
extends BaseBNode

func display_name() -> String: return "Variable Comparison"
func hint() -> String: return "Compares a Property on the Parent Node and then advances based on the first matching condition."

var var_name_node:LineEdit
var comparisons := []
var var_name := ""

func addtl_save(d:Dictionary) -> Dictionary:
	d["name"] = var_name
	d["type"] = "BVarComparison"
	var comps := []
	for c in comparisons:
		comps.append((c as BVarCompare).get_as_dictionary())
	d["comparisons"] = comps
	return d
func addtl_restore(d:Dictionary):
	var_name = d["name"]
	var_name_node.text = var_name
	for c in d["comparisons"]:
		_on_add_comparison(c)
	
func _ready():
	var top := VBoxContainer.new()
	add_child(top)
	
	top.add_child(separator())
	var_name_node = LineEdit.new()
	var_name_node.text = var_name
	var_name_node.hint_tooltip = "The name of the Property you want to compare."
	var_name_node.placeholder_text = "Variable Name"
	var_name_node.connect("text_changed", self, "_on_var_name_changed")
	top.add_child(var_name_node)
	top.add_child(separator())
	
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
	comp_node.allow_delete = true
	add_child(comp_node)
	if d.has("value"): comp_node.restore_from_dictionary(d)
	comparisons.append(comp_node)
	comp_node.connect("change_made", self, "_on_change")
	comp_node.connect("delete", self, "_on_delete_comparison", [comp_node])
	move_child(comp_node, comparisons.size())
	set_slot(comparisons.size() + 1, false, 0, SLOT_COLOR, true, 0, SLOT_COLOR)
	emit_signal("insert_slot", name, comparisons.size() - 1)
func _on_delete_comparison(c:BVarCompare):
	emit_signal("change_made")
	var idx := comparisons.find(c)
	emit_signal("delete_slot", name, idx)
	comparisons.erase(c)
	c.queue_free()

func _on_var_name_changed(s:String):
	emit_signal("change_made")
	var_name = s
