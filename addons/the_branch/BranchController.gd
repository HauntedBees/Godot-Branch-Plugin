tool
class_name BranchController
extends Node

export (String, FILE, "*.json") var file_path setget _set_file_path
var not_in_scene := false

var parent:Node
var nodes:Dictionary = {}
var current_node:Dictionary = {}

func _set_file_path(p:String):
	file_path = p
	if !Engine.editor_hint: return
	if !is_inside_tree(): return
	get_tree().call_group("graph_editor_parent", "_on_selection_changed")

func _ready():
	if Engine.editor_hint: return
	if file_path == "": return
	if not_in_scene: return
	parent = get_parent()
	var f := File.new()
	f.open(file_path, File.READ)
	var json_string := f.get_as_text()
	f.close()
	var json:Array = parse_json(json_string)
	if json.size() == 0: return
	for c in json:
		if c.has("is_connection_list"):
			(c["connections"] as Array).sort_custom(self, "_sort_connections")
			for cn in c["connections"]: nodes[cn["from"]]["out"].append(cn["to"])
		elif c["type"] == "BCommentNode":
			continue
		else:
			c.erase("pos_x")
			c.erase("pos_y")
			c.erase("rect_x")
			c.erase("rect_y")
			c["out"] = []
			nodes[c["node_name"]] = c
	reset()

## Advances to the next dialog or dialog_choice node and returns its text and available choices, if applicable, as a dictionary with text:String and choices:Array entries.
## If there no more dialog or dialog_choice nodes remain, returns {"end":true}.
func get_next_dialog(stop_at_loop:bool = false) -> Dictionary:
	step()
	while current_node["type"] != "BDialog" && current_node["type"] != "BDialogChoice":
		if !step(stop_at_loop): return {"end": true}
	return get_dialog_info()

## Returns the text and available choices of the current dialog or dialog_choice node, if applicable, as a dictionary with text:String and choices:Array entries.
## If the current node is not a dialog or dialog_choice node, returns {"error":true}.
func get_dialog_info() -> Dictionary:
	var type:String = current_node["type"]
	if type != "BDialog" && type != "BDialogChoice": return {"error": true}
	var params_arr := []
	var params_dict := {}
	for p in current_node["params"]:
		params_arr.append(p["value"])
		params_dict[p["name"]] = p["value"]
	return {
		"speaker": current_node["speaker"],
		"text": current_node["text"],
		"choices": get_dialog_choices(),
		"aparams": params_arr,
		"dparams": params_dict
	}

## Returns the available choices of the current dialog_choice node, or an empty array if the current node is not a dialog_choice node.
func get_dialog_choices() -> Array:
	if current_node["type"] != "BDialogChoice": return []
	var available_choices := []
	for c in current_node["choices"]:
		match c["condition"]:
			0: available_choices.append(c["text"])
			1: if _call_function(c["func"]): available_choices.append(c["text"])
			2: if _compare_variables(_get_variable(c["comparison"]["property"]), c["comparison"]): available_choices.append(c["text"])
	return available_choices

func make_dialog_choice(idx:int, stop_at_loop:bool = false):
	var next_arr:Array = current_node["out"]
	if next_arr.size() <= idx: return false
	current_node = nodes[next_arr[idx]]
	var current_text := get_dialog_info()
	if current_text.has("error"): return get_next_dialog(stop_at_loop)
	else: return current_text

## Returns flow to the StartNode so the chain can start again.
func reset(advance_past_start_node:bool = true) -> void:
	current_node = nodes["StartNode"]
	if advance_past_start_node: _advance_forward()

## Executes all nodes in sequence until the end of the chain is reached.
func complete() -> void: while step(): pass

## Returns whether or not the chain is complete.
func is_complete() -> bool:
	if current_node["type"] == "BEndNode": return true
	if current_node["type"] == "BRepeatNode": return false
	return current_node["out"].size() == 0

## Returns the current node dictionary in case you want to do something fancy with it.
func get_current_node() -> Dictionary: return current_node

## Advances to the next node.
## Returns false if there are no nodes left.
func step(stop_at_loop:bool = false) -> bool:
	match current_node["type"]:
		"BStartNode": return _advance_forward()
		"BRepeatNode":
			if stop_at_loop: return false
			else: return _advance_repeat()
		"BEndNode": return false
		"BFunctionCall": return _advance_function()
		"BFunctionSequence": return _advance_functions()
		"BVarAssignment": return _assign_variable()
		"BBoolFunction": return _advance_bool()
		"BBoolSequence": return _advance_bools()
		"BRandom": return _advance_rand()
		"BVarComparison": return _advance_var_compare()
		"BDialog": return _advance_forward()
		"BDialogChoice": return _advance_forward()
	return false

# BFunctionCall
func _advance_function() -> bool:
	_call_function(current_node["func"])
	return _advance_forward()
# BFunctionSequence
func _advance_functions() -> bool:
	for f in current_node["functions"]: _call_function(f)
	return _advance_forward()
# BVarAssignment
func _assign_variable() -> bool:
	_set_variable(current_node["name"], current_node["value"])
	return _advance_forward()
# BBoolFunction
func _advance_bool() -> bool:
	var next_arr:Array = current_node["out"]
	if next_arr.size() != 2: return false
	if _call_function(current_node["func"]): current_node = nodes[next_arr[0]]
	else: current_node = nodes[next_arr[1]]
	return true
# BBoolSequence
func _advance_bools() -> bool:
	var next_arr:Array = current_node["out"]
	var options:Array = current_node["functions"]
	if next_arr.size() != (options.size() + 1): return false
	for i in options.size():
		var success:bool = _call_function(options[i])
		if success:
			current_node = nodes[next_arr[i]]
			return true
	current_node = nodes[next_arr[next_arr.size() - 1]]
	return true
# BRandom
func _advance_rand() -> bool:
	var next_arr:Array = current_node["out"]
	var r := randf()
	var counter := 0.0
	for i in current_node["amounts"].size():
		counter += current_node["amounts"][i]
		if r < counter:
			current_node = nodes[next_arr[i]]
			return true
	current_node = nodes[next_arr[next_arr.size() - 1]]
	return true
# BVarComparison
func _advance_var_compare() -> bool:
	var next_arr:Array = current_node["out"]
	var options:Array = current_node["comparisons"]
	if next_arr.size() != (options.size() + 1): return false
	var value = _get_variable(current_node["name"])
	for i in options.size():
		if _compare_variables(value, options[i]):
			current_node = nodes[next_arr[i]]
			return true
	current_node = nodes[next_arr[next_arr.size() - 1]]
	return true
# BRepeatNode
func _advance_repeat() -> bool:
	current_node = nodes["StartNode"]
	return _advance_forward()

func _advance_forward() -> bool:
	var next_arr:Array = current_node["out"]
	if next_arr.size() == 0: return false
	current_node = nodes[next_arr[0]]
	return true
func _call_function(f:Dictionary):
	var func_name:String = f["name"]
	var params_dict:Array = f["params"]
	var params := []
	for p in params_dict: params.append(_get_param(p))
	return parent.callv(func_name, params)
func _get_param(p:Dictionary):
	if p["type"] == 4: return _get_variable(p["value"])
	else: return p["value"]
func _compare_variables(value, compar:Dictionary) -> bool:
	var compare_val = _get_variable(compar["value"]) if compar["type"] == 4 else compar["value"]
	match int(compar["comparison"]):
		0: return value == compare_val
		1: return value >= compare_val
		2: return value > compare_val
		3: return value <= compare_val
		4: return value < compare_val
		5: return value != compare_val
		6: return (value as Array).find(compare_val) >= 0
	return false
func _get_variable(v:String):
	var var_parts := v.split(".")
	var current_var = parent
	for vp in var_parts:
		var vps := vp as String
		if vps.find("[") >= 0:
			var array_or_dict_name := vps.substr(0, vps.find("["))
			var bsix := vps.find("[") + 1
			var bracket_contents = vps.substr(bsix, vps.find("]") - bsix)
			if bracket_contents.find("\"") >= 0:
				current_var = current_var.get(array_or_dict_name)[bracket_contents.replace("\"", "")]
			else:
				current_var = current_var.get(array_or_dict_name)[int(bracket_contents)]
		else: current_var = current_var.get(vp)
	return current_var
func _set_variable(v:String, value):
	var var_parts := v.split(".")
	var current_var = parent
	for i in var_parts.size():
		var vps := var_parts[i] as String
		var is_last:bool = (i+1) == var_parts.size()
		if vps.find("[") >= 0:
			var array_or_dict_name := vps.substr(0, vps.find("["))
			var bsix := vps.find("[") + 1
			var bracket_contents = vps.substr(bsix, vps.find("]") - bsix)
			if bracket_contents.find("\"") >= 0:
				if is_last: current_var.get(array_or_dict_name)[bracket_contents.replace("\"", "")] = value
				else: current_var = current_var.get(array_or_dict_name)[bracket_contents.replace("\"", "")]
			else:
				if is_last: current_var.get(array_or_dict_name)[int(bracket_contents)] = value
				else: current_var = current_var.get(array_or_dict_name)[int(bracket_contents)]
		else:
			if is_last: current_var.set(vps, value)
			else: current_var = current_var.get(vps)
func _sort_connections(a:Dictionary, b:Dictionary) -> bool:
	if a["from_port"] == b["from_port"]: return a["to_port"] < b["to_port"]
	else: return a["from_port"] < b["from_port"]
