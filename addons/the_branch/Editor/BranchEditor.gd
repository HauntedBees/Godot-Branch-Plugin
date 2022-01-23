tool
class_name BranchEditor
extends Control
signal open_file_dialog

func _on_CreateNewButton_pressed(): emit_signal("open_file_dialog")
func got_file_path(path:String):
	pass
