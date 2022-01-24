tool
class_name BInnerFunction
extends PanelContainer

signal delete
signal view_source

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
	hb.add_child(function_node)
	
	var source_button := Button.new()
	source_button.icon = preload("res://addons/the_branch/Icons/CodeEdit.svg")
	source_button.hint_tooltip = "View this function."
	source_button.connect("pressed", self, "_on_view_source")
	hb.add_child(source_button)
	
	param_info = BParamHandler.new()
	
	var add_params_button := Button.new()
	add_params_button.text = "Add Parameter"
	add_params_button.hint_tooltip = "Add an argument to the function call."
	add_params_button.size_flags_horizontal = SIZE_EXPAND_FILL
	add_params_button.connect("pressed", self, "_add_parameter")
	vb.add_child(add_params_button)

func _on_delete(): emit_signal("delete")
func _on_view_source(): emit_signal("view_source")

func set_allow_delete(b:bool):
	allow_delete = b
	if delete_button != null: delete_button.visible = allow_delete
func set_function_name(s:String):
	function_name = s
	if function_node != null: function_node.text = function_name
