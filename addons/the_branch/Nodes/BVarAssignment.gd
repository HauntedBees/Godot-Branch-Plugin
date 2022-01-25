tool
class_name BVarAssignment
extends BaseBNode

func display_name() -> String: return "Variable Assignment"
func hint() -> String: return "Assigns a property on the parent node to the provided value."

var name_node:LineEdit
var val_node:BTypedInput
var var_name := ""

func addtl_save(d:Dictionary) -> Dictionary:
	d["type"] = "BVarAssignment"
	d["name"] = var_name
	d["value"] = val_node.value
	d["var_type"] = val_node.type
	return d
func addtl_restore(d:Dictionary):
	var_name = d["name"]
	name_node.text = var_name
	val_node.type = d["var_type"]
	val_node.value = d["value"]

func _ready():
	var vb := VBoxContainer.new()
	add_child(vb)
	
	name_node = LineEdit.new()
	name_node.text = var_name
	name_node.placeholder_text = "Variable Name"
	name_node.hint_tooltip = "The name of a Property on the parent node that will be reassigned."
	name_node.size_flags_horizontal = SIZE_EXPAND_FILL
	name_node.connect("text_changed", self, "_on_name_change")
	vb.add_child(name_node)
	
	val_node = BTypedInput.new()
	val_node.size_flags_horizontal = SIZE_EXPAND_FILL
	val_node.connect("change_made", self, "_on_change")
	vb.add_child(val_node)
	
	set_slot(0, true, 0, SLOT_COLOR, true, 0, SLOT_COLOR)

func _on_name_change(s:String):
	emit_signal("change_made")
	var_name = s
