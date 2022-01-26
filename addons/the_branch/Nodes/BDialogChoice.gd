tool
class_name BDialogChoice
extends BDialog

func display_name() -> String: return "Dialog Choice"
func hint() -> String: return "This node is for entering text that will be displayed to the player and letting them choose a response."

var add_choice_button:Button
var choices := []
var num_elements := 0

func addtl_save(d:Dictionary) -> Dictionary:
	d["type"] = "BDialogChoice"
	d["text"] = value
	d["speaker"] = speaker
	d["params"] = param_info.get_params_dict_array()
	var d_choices := []
	for c in choices:
		d_choices.append((c as BChoice).get_as_dictionary())
	d["choices"] = d_choices
	return d
func addtl_restore(d:Dictionary):
	set_value(d["text"])
	set_speaker(d["speaker"])
	param_info.restore_params_from_dict_array(d["params"])
	for c in d["choices"]:
		_add_choice(c)

func _ready():
	add_choice_button = Button.new()
	add_choice_button.text = "Add Choice"
	add_choice_button.hint_tooltip = "Add some choices to this dialog node."
	add_choice_button.size_flags_horizontal = SIZE_EXPAND_FILL
	add_choice_button.connect("pressed", self, "_add_choice")
	add_child(add_choice_button)
	add_child(separator())
	set_slot(0, true, 0, SLOT_COLOR, false, 0, SLOT_COLOR)
	num_elements = get_child_count() - 1
func _add_choice(d:Dictionary = {}):
	var choice := BChoice.new()
	add_child(choice)
	if d.has("text"): choice.restore_from_dictionary(d)
	choices.append(choice)
	choice.connect("change_made", self, "_on_change")
	choice.connect("delete", self, "_on_choice_delete", [choice])
	choice.connect("view_source", self, "_on_view_source", [true])
	set_slot(num_elements + choices.size(), false, 0, SLOT_COLOR, true, 0, SLOT_COLOR)
	emit_signal("change_made")
func _on_choice_delete(c:BChoice):
	var idx := choices.find(c)
	emit_signal("change_made")
	emit_signal("delete_slot", name, idx)
	choices.erase(c)
	c.queue_free()
