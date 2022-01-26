extends Panel

onready var write_output := $WriteOutput
onready var branchie := $BranchController
onready var node_info := $CurrentNodeInfo
onready var is_end := $IsEnd

var some_string := "Change me!"
var some_int := 0 setget set_some_int

func _ready():
	branchie.reset()
	_show_current_node()
func _on_StepButton_pressed():
	_show_current_node()
	is_end.pressed = !branchie.step()
func _on_RestartButton_pressed():
	branchie.reset()
	_show_current_node()
	write_output.text = ""
	is_end.pressed = false

func _on_SomeString_text_changed(new_text:String): some_string = new_text
func _on_SomeInt_value_changed(value:int): some_int = value
func _show_current_node(): node_info.text = JSON.print(branchie.get_current_node(), "\t")

# Functions called from the BranchController:
func write_message(text:String): write_output.text = text
func set_some_int(v:int):
	some_int = v
	$SomeInt.value = v
func is_int_big_and_string_long() -> bool: return some_int > 50 && some_string.length() > 10
func is_int_big() -> bool: return some_int > 50
func is_string_long() -> bool: return some_string.length() > 10
