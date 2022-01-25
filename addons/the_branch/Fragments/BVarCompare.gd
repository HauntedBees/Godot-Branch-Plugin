tool
class_name BVarCompare
extends HBoxContainer

signal change_made

enum { EQUALS, GTE, GT, LTE, LT, NOT, CONTAINS }

var comparison_node:OptionButton
var value_node:BTypedInput
var comparison := EQUALS setget set_comparison

func get_as_dictionary() -> Dictionary:
	return {
		"comparison": comparison,
		"value": value_node.value,
		"type": value_node.type
	}
func restore_from_dictionary(d:Dictionary):
	set_comparison(d["comparison"])
	value_node.set_type(d["type"])
	value_node.set_value(d["value"])

func _ready():
	size_flags_horizontal = SIZE_EXPAND_FILL
	comparison_node = OptionButton.new()
	comparison_node.add_item("==")
	comparison_node.add_item(">=")
	comparison_node.add_item(">")
	comparison_node.add_item("<=")
	comparison_node.add_item("<")
	comparison_node.add_item("!=")
	comparison_node.add_item("contains")
	comparison_node.select(comparison)
	comparison_node.connect("item_selected", self, "_on_comparison_change")
	comparison_node.hint_tooltip = "The comparison operator. \"contains\" only works if the above specified property is an array."
	add_child(comparison_node)
	
	value_node = BTypedInput.new()
	value_node.connect("change_made", self, "_on_change_made")
	add_child(value_node)

func set_comparison(i:int):
	comparison = i
	if comparison_node != null: comparison_node.select(i)
func _on_comparison_change(i:int):
	comparison = i
	emit_signal("change_made")
func _on_change_made(): emit_signal("change_made")
