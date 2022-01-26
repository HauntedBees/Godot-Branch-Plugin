tool
class_name BChoice
extends PanelContainer

signal view_source(func_info)
signal change_made
signal delete

enum { ALWAYS_SHOW, FUNCTION_CALL, VARIABLE_COMPARISON }

var text_node:BDeleteInput
var options_node:OptionButton
var func_node:BInnerFunction
var prop_node:VBoxContainer
var var_name_node:LineEdit
var var_node:BVarCompare

var text := "" setget set_text
var display_type := ALWAYS_SHOW setget set_display_type
var var_name := "" setget set_var_name

func _ready():
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(vb)
	vb.add_child(HSeparator.new())
	
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
	func_node.connect("change_made", self, "_on_change")
	func_node.connect("view_source", self, "_on_view_source")
	vb.add_child(func_node)
	
	prop_node = VBoxContainer.new()
	prop_node.visible = display_type == VARIABLE_COMPARISON
	prop_node.size_flags_horizontal = SIZE_EXPAND_FILL
	vb.add_child(prop_node)
	
	var_name_node = LineEdit.new()
	var_name_node.text = var_name
	var_name_node.placeholder_text = "Property Name"
	var_name_node.size_flags_horizontal = SIZE_EXPAND_FILL
	var_name_node.connect("text_changed", self, "_on_var_name_change")
	var_name_node.hint_tooltip = "The name of a property on the Parent Node to compare against."
	prop_node.add_child(var_name_node)
	
	var_node = BVarCompare.new()
	var_node.connect("change_made", self, "_on_change")
	prop_node.add_child(var_node)

func get_as_dictionary() -> Dictionary:
	var d := var_node.get_as_dictionary()
	d["property"] = var_name
	return {
		"text": text,
		"type": display_type,
		"func": func_node.get_as_dictionary(),
		"comparison": d
	}
func restore_from_dictionary(d:Dictionary):
	set_text(d["text"])
	set_display_type(d["type"])
	set_var_name(d["comparison"]["property"])
	func_node.restore_from_dictionary(d["func"])
	func_node.visible = display_type == FUNCTION_CALL
	prop_node.visible = display_type == VARIABLE_COMPARISON
	var_node.restore_from_dictionary(d["comparison"])

func set_text(s:String):
	text = s
	if text_node != null: text_node.text = s
func set_display_type(i:int):
	display_type = i
	if options_node != null:
		options_node.select(i)
		func_node.visible = display_type == FUNCTION_CALL
		prop_node.visible = display_type == VARIABLE_COMPARISON
func set_var_name(s:String):
	var_name = s
	if var_name_node != null: var_name_node.text = s
	
func _on_text_change(t:String):
	emit_signal("change_made")
	text = t
func _on_display_type_changed(i:int):
	display_type = i
	func_node.visible = display_type == FUNCTION_CALL
	prop_node.visible = display_type == VARIABLE_COMPARISON
	emit_signal("change_made")
func _on_var_name_change(s:String):
	var_name = s
	emit_signal("change_made")
func _on_change(): emit_signal("change_made")
func _on_delete(): emit_signal("delete")
func _on_view_source(func_info:Dictionary): emit_signal("view_source", func_info)
