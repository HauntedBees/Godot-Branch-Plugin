class_name BParamHandler
extends Resource

var parameters := []
var parent_node:Node
var param_container:VBoxContainer

func configure(parent_container:Node, parent:Node, text := "Add Parameter", tooltip := "Add an argument to the function call."):
	parent_node = parent
	param_container = VBoxContainer.new()
	param_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var add_params_button := Button.new()
	add_params_button.text = text
	add_params_button.hint_tooltip = tooltip
	add_params_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_params_button.connect("pressed", self, "_add_parameter", [{}])
	
	parent_container.add_child(add_params_button)
	parent_container.add_child(param_container)

func get_params_dict_array() -> Array:
	var d_params := []
	for p in parameters:
		d_params.append((p as BParameter).get_as_dict())
	return d_params
func restore_params_from_dict_array(a:Array):
	for p in a:
		_add_parameter(p)

func _add_parameter(d:Dictionary):
	var param := BParameter.new()
	param.connect("delete_param", self, "_on_param_delete", [param])
	param.connect("change_made", parent_node, "_on_change")
	parameters.append(param)
	param_container.add_child(param)
	parent_node._on_change()
	if d.has("name"):
		param.field_name = d["name"]
		param.field_type = d["type"]
		param.set_value(d["value"])

func _on_param_delete(p:BParameter):
	parent_node._on_change_arg(p)
	parameters.erase(p)
	p.queue_free()
