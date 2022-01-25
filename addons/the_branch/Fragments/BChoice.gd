tool
class_name BChoice
extends PanelContainer

signal change_made
signal delete

enum { ALWAYS_SHOW, FUNCTION_CALL, VARIABLE_COMPARISON }
enum { EQUALS, GTE, GT, LTE, LT, NOT, CONTAINS }
enum { STRING, INT, FLOAT, BOOL, VAR }

var text_node:BDeleteInput
var options_node:OptionButton
var func_node:BInnerFunction

var prop_node:VBoxContainer
var var_compare_name_node:LineEdit
var var_compare_comparison_node:OptionButton
var var_compare_val_node:LineEdit
var var_compare_type_node:OptionButton

var text := "" setget set_text
var display_type := ALWAYS_SHOW setget set_display_type
var var_compare_name := "" setget set_var_compare_name
var var_compare_comparison := EQUALS setget set_var_compare_comparison
var var_compare_val := "" setget set_var_compare_val
var var_compare_type := STRING setget set_var_compare_type

func _ready():
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(vb)
	
	text_node = BDeleteInput.new()
	text_node.placeholder = "Choice"
	text_node.text = text
	text_node.size_flags_horizontal = SIZE_EXPAND_FILL
	text_node.connect("change_made", self, "_on_text_change")
	text_node.connect("delete", self, "_on_delete")
	vb.add_child(text_node)
	
	options_node = OptionButton.new()
	options_node.add_item("Always Show")
	options_node.add_item("Function Call")
	options_node.add_item("Variable Comparison")
	options_node.select(display_type)
	options_node.size_flags_horizontal = SIZE_EXPAND_FILL
	options_node.hint_tooltip = "Choose whether this dialog choice is always available to the player, or if it is only avaible if a certain condition is met."
	options_node.connect("item_selected", self, "_on_display_type_changed")
	vb.add_child(options_node)
	
	func_node = BInnerFunction.new()
	func_node.allow_delete = false
	func_node.visible = display_type == FUNCTION_CALL
	func_node.size_flags_horizontal = SIZE_EXPAND_FILL
	vb.add_child(func_node)
	
	prop_node = VBoxContainer.new()
	prop_node.visible = display_type == VARIABLE_COMPARISON
	prop_node.size_flags_horizontal = SIZE_EXPAND_FILL
	vb.add_child(prop_node)
	
	var_compare_name_node = LineEdit.new()
	var_compare_name_node.text = var_compare_name
	var_compare_name_node.placeholder_text = "Property Name"
	var_compare_name_node.size_flags_horizontal = SIZE_EXPAND_FILL
	var_compare_name_node.connect("text_changed", self, "_on_var_compare_name_change")
	var_compare_name_node.hint_tooltip = "The name of a property on the BranchController's parent to compare against."
	prop_node.add_child(var_compare_name_node)
	
	var hb := HBoxContainer.new()
	prop_node.add_child(hb)
	var_compare_comparison_node = OptionButton.new()
	var_compare_comparison_node.add_item("==")
	var_compare_comparison_node.add_item(">=")
	var_compare_comparison_node.add_item(">")
	var_compare_comparison_node.add_item("<=")
	var_compare_comparison_node.add_item("<")
	var_compare_comparison_node.add_item("!=")
	var_compare_comparison_node.add_item("contains")
	var_compare_comparison_node.select(var_compare_comparison)
	var_compare_comparison_node.connect("item_selected", self, "_on_var_compare_comparison_change")
	var_compare_comparison_node.hint_tooltip = "The comparison operator. \"contains\" only works if the above specified property is an array."
	hb.add_child(var_compare_comparison_node)
	
	var_compare_val_node = LineEdit.new()
	var_compare_val_node.text = var_compare_val
	var_compare_val_node.placeholder_text = "Value"
	var_compare_val_node.size_flags_horizontal = SIZE_EXPAND_FILL
	var_compare_val_node.connect("text_changed", self, "_on_var_compare_val_change")
	var_compare_val_node.hint_tooltip = "The value to compare the above property against, based on the specified comparison operator."
	hb.add_child(var_compare_val_node)
	
	var_compare_type_node = OptionButton.new()
	var_compare_type_node.add_item("String")
	var_compare_type_node.add_item("int")
	var_compare_type_node.add_item("float")
	var_compare_type_node.add_item("bool")
	var_compare_type_node.add_item("var")
	var_compare_type_node.select(var_compare_type)
	var_compare_type_node.connect("item_selected", self, "_on_var_compare_type_change")
	var_compare_type_node.hint_tooltip = "The type of the specified comparison value. If \"var\" is selected, then this value is treated as the name of a property on the BranchController's parent."
	hb.add_child(var_compare_type_node)

func get_as_dictionary() -> Dictionary:
	return {
		"text": text,
		"type": display_type,
		"func": func_node.get_as_dictionary(),
		"comparison": {
			"property": var_compare_name,
			"comparison": var_compare_comparison,
			"value": var_compare_val,
			"type": var_compare_type
		}
	}
func restore_from_dictionary(d:Dictionary):
	set_text(d["text"])
	set_display_type(d["type"])
	func_node.restore_from_dictionary(d["func"])
	func_node.visible = display_type == FUNCTION_CALL
	prop_node.visible = display_type == VARIABLE_COMPARISON

func set_text(s:String):
	text = s
	if text_node != null: text_node.text = s
func set_display_type(i:int):
	display_type = i
	if options_node != null:
		options_node.select(i)
		func_node.visible = display_type == FUNCTION_CALL
		prop_node.visible = display_type == VARIABLE_COMPARISON
func set_var_compare_name(s:String):
	var_compare_name = s
	if var_compare_name_node != null: var_compare_name_node.text = s
func set_var_compare_comparison(i:int):
	var_compare_comparison = i
	if var_compare_comparison_node != null: var_compare_comparison_node.select(i)
func set_var_compare_val(s:String):
	var_compare_val = s
	if var_compare_val_node != null: var_compare_val_node.text = s
func set_var_compare_type(i:int):
	var_compare_type = i
	if var_compare_type_node != null: var_compare_type_node.select(i)

func _on_text_change(t:String):
	emit_signal("change_made")
	text = t
func _on_var_compare_name_change(s:String):
	var_compare_name = s
	emit_signal("change_made")
func _on_var_compare_comparison_change(i:int):
	var_compare_comparison = i
	emit_signal("change_made")
func _on_var_compare_val_change(s:String):
	var_compare_val = s
	emit_signal("change_made")
func _on_var_compare_type_change(i:int):
	var_compare_type = i
	emit_signal("change_made")

func _on_display_type_changed(i:int):
	display_type = i
	func_node.visible = display_type == FUNCTION_CALL
	prop_node.visible = display_type == VARIABLE_COMPARISON
	emit_signal("change_made")
func _on_change(i): emit_signal("change_made")
func _on_delete(): emit_signal("delete")
