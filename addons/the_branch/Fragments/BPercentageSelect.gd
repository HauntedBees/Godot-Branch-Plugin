tool
class_name BPercentageSelect
extends HBoxContainer

signal change_made
signal delete

var num_edit:SpinBox
var value := 0.0 setget set_value
var weighted := false setget set_weighted

func _ready():
	var delete_button := Button.new()
	delete_button.icon = preload("res://addons/the_branch/Icons/Remove.svg")
	delete_button.hint_tooltip = "Delete this value."
	delete_button.connect("pressed", self, "_on_delete")
	add_child(delete_button)
	
	num_edit = SpinBox.new()
	num_edit.step = 0
	num_edit.min_value = 0
	num_edit.max_value = 1
	num_edit.value = value
	num_edit.editable = weighted
	num_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	num_edit.connect("value_changed", self, "_on_edit_value")
	add_child(num_edit)

func set_value(s:float):
	value = s
	if num_edit != null: num_edit.value = s
func set_weighted(b:bool):
	weighted = b
	if num_edit != null: num_edit.editable = weighted

func _on_delete(): emit_signal("delete")
func _on_edit_value(s:float):
	value = s
	emit_signal("change_made")
