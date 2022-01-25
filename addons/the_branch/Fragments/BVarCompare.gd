tool
class_name BVarCompare
extends HBoxContainer

signal change_made

enum { EQUALS, GTE, GT, LTE, LT, NOT, CONTAINS }
enum { STRING, INT, FLOAT, BOOL, VAR }

var var_name_node:LineEdit
var var_comparison_node:OptionButton
var var_val_node:LineEdit
var var_type_node:OptionButton

var var_comparison := EQUALS setget set_var_comparison
var var_val := "" setget set_var_val
var var_type := STRING setget set_var_type

func get_as_dictionary() -> Dictionary:
	return {
		"comparison": var_comparison,
		"value": var_val,
		"type": var_type
	}
func restore_from_dictionary(d:Dictionary):
	set_var_comparison(d["comparison"])
	set_var_val(d["value"])
	set_var_type(d["type"])

func _ready():
	size_flags_horizontal = SIZE_EXPAND_FILL
	var_comparison_node = OptionButton.new()
	var_comparison_node.add_item("==")
	var_comparison_node.add_item(">=")
	var_comparison_node.add_item(">")
	var_comparison_node.add_item("<=")
	var_comparison_node.add_item("<")
	var_comparison_node.add_item("!=")
	var_comparison_node.add_item("contains")
	var_comparison_node.select(var_comparison)
	var_comparison_node.connect("item_selected", self, "_on_var_comparison_change")
	var_comparison_node.hint_tooltip = "The comparison operator. \"contains\" only works if the above specified property is an array."
	add_child(var_comparison_node)
	
	var_val_node = LineEdit.new()
	var_val_node.text = var_val
	var_val_node.placeholder_text = "Value"
	var_val_node.size_flags_horizontal = SIZE_EXPAND_FILL
	var_val_node.connect("text_changed", self, "_on_var_val_change")
	var_val_node.hint_tooltip = "The value to compare the above property against, based on the specified comparison operator."
	add_child(var_val_node)
	
	var_type_node = OptionButton.new()
	var_type_node.add_item("String")
	var_type_node.add_item("int")
	var_type_node.add_item("float")
	var_type_node.add_item("bool")
	var_type_node.add_item("var")
	var_type_node.select(var_type)
	var_type_node.connect("item_selected", self, "_on_var_type_change")
	var_type_node.hint_tooltip = "The type of the specified comparison value. If \"var\" is selected, then this value is treated as the name of a property on the BranchController's parent."
	add_child(var_type_node)

func set_var_comparison(i:int):
	var_comparison = i
	if var_comparison_node != null: var_comparison_node.select(i)
func set_var_val(s:String):
	var_val = s
	if var_val_node != null: var_val_node.text = s
func set_var_type(i:int):
	var_type = i
	if var_type_node != null: var_type_node.select(i)

func _on_var_comparison_change(i:int):
	var_comparison = i
	emit_signal("change_made")
func _on_var_val_change(s:String):
	var_val = s
	emit_signal("change_made")
func _on_var_type_change(i:int):
	var_type = i
	emit_signal("change_made")
