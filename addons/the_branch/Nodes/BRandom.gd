tool
class_name BRandom
extends BaseBNode

func display_name() -> String: return "Random Condition"
func hint() -> String: return "Picks a random number between 0 and 1 and then advances based on the result."

var weighted_button:CheckButton
var weighted := false
var amounts := []

func addtl_save(d:Dictionary) -> Dictionary:
	d["type"] = "BRandom"
	d["weighted"] = weighted
	var amount_floats := []
	for a in amounts:
		amount_floats.append((a as BPercentageSelect).value)
	d["amounts"] = amount_floats
	return d
func addtl_restore(d:Dictionary):
	_on_toggle_weighted(d["weighted"])
	for a in d["amounts"]:
		_on_add_output(a)

func _ready():
	var top := VBoxContainer.new()
	add_child(top)
	
	weighted_button = CheckButton.new()
	weighted_button.text = "Weighted?"
	weighted_button.pressed = weighted
	weighted_button.hint_tooltip = "Enable this to specify manual weights for each option instead of giving each an equal chance of being picked."
	weighted_button.connect("toggled", self, "_on_toggle_weighted")
	top.add_child(weighted_button)
	
	var add_button := Button.new()
	add_button.text = "Add Output"
	add_button.hint_tooltip = "Add a new random chance slot."
	add_button.connect("pressed", self, "_on_add_output")
	top.add_child(add_button)
	top.add_child(separator())
	
	set_slot(0, true, 0, SLOT_COLOR, false, 0, SLOT_COLOR)

func _on_toggle_weighted(v:bool):
	weighted = v
	weighted_button.pressed = v
	emit_signal("change_made")
	for a in amounts:
		(a as BPercentageSelect).weighted = v

func _on_add_output(r := 0.0):
	emit_signal("change_made")
	var a := BPercentageSelect.new()
	a.weighted = weighted
	if r > 0.0: a.value = r
	a.connect("change_made", self, "_on_change")
	a.connect("delete", self, "_on_output_remove", [a])
	amounts.append(a)
	add_child(a)
	set_slot(amounts.size(), false, 0, SLOT_COLOR, true, 0, SLOT_COLOR)
	if !weighted:
		var amount := 1.0 / amounts.size()
		for aa in amounts:
			(aa as BPercentageSelect).value = amount
func _on_output_remove(a:BPercentageSelect):
	emit_signal("change_made")
	var idx := amounts.find(a)
	emit_signal("delete_slot", name, idx)
	amounts.erase(a)
	a.queue_free()
	if !weighted && amounts.size() > 0:
		var amount := 1.0 / amounts.size()
		for aa in amounts:
			(aa as BPercentageSelect).value = amount
