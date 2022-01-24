tool
class_name BDialogChoice
extends BDialog

func display_name() -> String: return "Dialog Choice"
func hint() -> String: return "This node is for entering text that will be displayed to the player and letting them choose a response."

var add_choice_button:Button
var choices := []

func addtl_save(d:Dictionary) -> Dictionary:
	d["type"] = "BDialogChoice"
	d["text"] = value
	d["speaker"] = speaker
	d["params"] = param_info.get_params_dict_array()
	var d_choices := []
	for c in choices:
		pass # TODO
	d["choices"] = d_choices
	return d
func addtl_restore(d:Dictionary):
	set_value(d["text"])
	set_speaker(d["speaker"])
	param_info.restore_params_from_dict_array(d["params"], param_container, self)
	for c in d["choices"]:
		pass # TODO

func _ready():
	add_choice_button = Button.new()
	add_choice_button.text = "Add Choice"
	add_choice_button.hint_tooltip = "Add some optional metadata to this dialog node."
	add_choice_button.size_flags_horizontal = SIZE_EXPAND_FILL
	add_choice_button.connect("pressed", self, "_add_choice")
	add_child(add_choice_button)
	add_child(separator())
	set_slot(0, true, 0, SLOT_COLOR, false, 0, SLOT_COLOR)

func _add_choice():
	print("fuck you cashew")
