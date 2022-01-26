tool
class_name BInnerFunction
extends PanelContainer

signal delete
signal view_source
signal change_made

var delete_button:Button
var function_node:LineEdit

var allow_delete := true setget set_allow_delete
var function_name := "" setget set_function_name
var param_info:BParamHandler

func _ready():
	size_flags_horizontal = SIZE_EXPAND_FILL
	
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(vb)
	
	var hb := HBoxContainer.new()
	hb.size_flags_horizontal = SIZE_EXPAND_FILL
	vb.add_child(hb)
	
	delete_button = Button.new()
	delete_button.icon = preload("res://addons/the_branch/Icons/Remove.svg")
	delete_button.hint_tooltip = "Delete this function."
	delete_button.visible = allow_delete
	delete_button.connect("pressed", self, "_on_delete")
	hb.add_child(delete_button)
	
	function_node = LineEdit.new()
	function_node.size_flags_horizontal = SIZE_EXPAND_FILL
	function_node.placeholder_text = "Function Name"
	function_node.text = function_name
	function_node.hint_tooltip = "The name of a function in the BranchController's parent."
	function_node.connect("text_changed", self, "_on_text_change")
	hb.add_child(function_node)
	
	var source_button := Button.new()
	source_button.icon = preload("res://addons/the_branch/Icons/CodeEdit.svg")
	source_button.hint_tooltip = "View this function's source code."
	source_button.connect("pressed", self, "_on_view_source")
	hb.add_child(source_button)
	
	param_info = BParamHandler.new()
	param_info.configure(vb, self)

func get_as_dictionary() -> Dictionary:
	return {
		"name": function_name,
		"params": param_info.get_params_dict_array()
	}
func restore_from_dictionary(d:Dictionary):
	set_function_name(d["name"])
	param_info.restore_params_from_dict_array(d["params"])

func _on_change(): emit_signal("change_made")
func _on_change_arg(_v): emit_signal("change_made")
func _on_delete(): emit_signal("delete")
func _on_view_source(): emit_signal("view_source", get_as_dictionary())
func _on_text_change(t:String):
	function_name = t
	emit_signal("change_made")

func set_allow_delete(b:bool):
	allow_delete = b
	if delete_button != null: delete_button.visible = allow_delete
func set_function_name(s:String):
	function_name = s
	if function_node != null: function_node.text = function_name
