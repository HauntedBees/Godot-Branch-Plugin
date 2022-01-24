class_name BParamHandler
extends Resource

var parameters := []
var param_container:VBoxContainer

func get_params_button(parent:Node, text := "Add Parameter", tooltip := "Add an argument to the function call.") -> Button:
	param_container = VBoxContainer.new()
	param_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
#	param_container = container
	var add_params_button := Button.new()
	add_params_button.text = text
	add_params_button.hint_tooltip = tooltip
	add_params_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_params_button.connect("pressed", self, "_add_parameter", [{}, parent])
	
	
	return add_params_button

func get_params_dict_array() -> Array:
	var d_params := []
	for p in parameters:
		d_params.append((p as BParameter).get_as_dict())
	return d_params
func restore_params_from_dict_array(a:Array, signal_holder:Node):
	for p in a:
		_add_parameter(p, signal_holder)

func _add_parameter(d:Dictionary, signal_holder:Node):
	var param := BParameter.new()
	param.connect("delete_param", self, "_on_param_delete", [param, signal_holder])
	param.connect("change_made", signal_holder, "_on_change")
	parameters.append(param)
	param_container.add_child(param)
	if d.has("name"):
		param.field_name = d["name"]
		param.field_type = d["type"]
		param.set_value(d["value"])

func _on_param_delete(p:BParameter, signal_holder:Node):
	signal_holder.emit_signal("change_made")
	parameters.erase(p)
	p.queue_free()
