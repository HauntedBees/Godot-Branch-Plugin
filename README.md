# Godot 3.4 *The Branch* Plugin
Dialog Trees, Decision Trees, Behavior Trees, Pine Trees... one plugin for all of the above.

# Use Cases
*The Branch* Plugin is largely made for building general-purpose trees for workflows such as cutscene scripts, NPC/enemy decision making, dialog, and so on. If your primary goal is to build dialog systems, this plugin is probably overengineered for your use case, and also underengineered, as it does not provide an actual dialog engine, just the logic for moving through dialog trees - the UI must be developed separately. However, if you have a dialog system that is part of a larger workflow that you want to represent in tree form (i.e. "have this NPC walk up to the player" node connects to a dialog node of them saying "hey what's up?"), don't want to combine multiple plugins for several slightly-different systems, and are willing to write some GDScript, this plugin might be for you.

# Installation
Copy `addons/the_branch` into your project (final path should be `res://addons/the_branch`). In the Godot Editor, go to **Project Settings > Plugins** and enable the **The Branch** plugin. You can now add **BranchController** nodes to your project and modify them with the **Branch Editor**.

# BranchController
Add a **BranchController** Node as a child to any Node you want to have some sort of branching behavior - dialog trees, movement plans, decision trees, enemy AI, whatever. Set the **File Path** in the **Inspector Tab** or just switch to the **Branch Editor** tab and click the **Create new Branch JSON File** button. Once you have a Branch JSON file, you can start adding nodes. The Node your **BranchController** is a child of will be referred to as the **Parent Node** in the rest of the documentation.

## Node Types

### Start Node
Your tree behinds here. Every time.

### Function Call
This node will call a function on the **Parent Node**, passing along any specified parameters.

### Function Sequence
This node will call all specified functions on the **Parent Node** in sequential order from the top down.

### Variable Assignment
This node will set the value of a variable on the **Parent Node** to the specified value.

### Boolean Function
This node will call a function on the **Parent Node** that should return either `true` or `false`. The branch will advanced based on the returned value of the function.

### Boolean Sequence
This node will begin calling the specified functions on the **Parent Node** from the top down until one of them returns `true`. The branch will advance based on the first function to return `true`. If all functions return `false`, then the **else** branch will be taken.

### Variable Comparison
This node will compare the value of a variable on the **Parent Node** with the specified values, using the specified comparison operators, advancing based on the first one in the list to evaluate to `true`. If all comparisons evaluate to `false`, then the **else** branch will be taken.

### Random Condition
This node will pick a random number between 0 and 1 and then advance to one of the given branches based on the return. By default, each branch has an equal chance of being reached, but if you toggle the **Weighted** switch you can specify individual weights for each branch.

### Dialog
Specify a dialog message and an optional speaker, plus any other parameters you wish to include for your dialog system. Dialog system not included.

### Dialog Choice
Specify a dialog message and an optional speaker and one or more choices for the user to select. Choices can be configured to only show up when certain conditions are met, such as a certain function returning `true` or a certain variable comparison being met. Dialog system not included.

### End
The end of the tree.

### Restart
Advances to the Start Node to do the whole thing over.

### Comment
Notes. Comments. You know 'em. You love 'em. They can be useful.

### Template
You can save pretty much any node as a *template*, giving it a name and optional group. By doing so, you can then create an identical node from the **Template** menu button. This can be useful if you have a complex node (such as a function call that has a lot of parameters with specific types) that you intend to use in a lot of places. You can also copy and paste individual nodes to duplicate them in the same graph, but templates span your entire project. 

## Node Parts

### Function Calls
A function call requires the name of a **function** on the **Parent Node** and zero or more **parameters**. Each **parameter** can have a name (which is used for reference in the graph view only) and a type - *String*, *int*, *float*, *bool*, or *var*. If *var* is selected, the specified value will be treated as the name of a variable on the **Parent Node** and when this function is executed, the variable's value will be passed to the function. Otherwise, the literal value you specify for this parameter will be passed. Clicking the **View Source** will bring you to the function definition in the **Script Editor** if it exists. If the function does not exist, it will try to create a skeleton function with a signature matching the specified parameters.

### Variables
In the case of the **Variable Assignment** and **Variable Comparison** Nodes, and anywhere you can specify *var* as a parameter/variable type, the name of a variable on the **Parent Node** can be specified, which will be assigned/evaluated when the node is reached. Some flexibility is allowed, so you can access array parts like `arr[5]` or dictionary values like `dict["key"]`.

# Usage
Once you've added a **BranchController** as a child to your **Parent Node** and created a **Branch JSON** file, you'll probably want to do something with it. The **BranchController** has several properties and functions for your usage.

## Methods

### get_next_dialog(stop_at_loop:bool = false) -> Dictionary
Moves to the next available dialog (or dialog choice) node, evaluating and branching through any non-dialog nodes in the process.
#### stop_at_loop
If you have **Restart Nodes** in your dialog tree, setting this argument to `true` will treat them as **End Nodes** and halt iteration. If there's a chance your tree could lead to an infinite loop, set this to `true`.
#### Response
The response will be the dictionary `{"end": true}` if there are no dialog nodes left, or a dictionary with the following keys:
 - **speaker**:String
 - **text**:String
 - **choices** - an array of applicable choices as strings
 - **aparams** - any provided parameters in an array, ordered based on the order they were given in
 - **dparams** - any provided parameters in a dictionary, with the specified parameter names being the dictionary keys

### get_dialog_info() -> Dictionarry
Returns a dictionary in the same format described for `get_next_dialog` for the current node. If the current node is *not* a **Dialog** or **Dialog Choice** node, this returns the dictionary `{"error": true}`.

### get_dialog_choices() -> Array
Returns an array of all applicable choices for the current node as strings. If the current node is not a **Dialog Choice** node this returns an empty array.

### make_dialog_choice(idx:int, stop_at_loop:bool = false)
Chooses the dialog choice in index `idx` in the current **Dialog Choice** node and then advances based on that. `stop_at_loop` behaves the same as it does in `get_next_dialog`. Evaluates until the next dialog node is reached.
#### Response
Returns `false` if you provided an invalid index value (less than 0 or greater than or equal to the choice array's size). Otherwise returns the next dialog node (with the same format described in `get_next_dialog`) or `{"end": true}` if there are none left.

### reset(advance_past_start_node:bool = true):
Moves back to the **Start Node**. If `advance_past_start_node` is `true`, the `current_node` value will be the node immediately *after* the **Start Node**. If `false`, the `current_node` will be the **Start Node** itself.

### complete()
**Immediately** evaluates and moves through nodes until an **End Node** or a node with no successors is reached. **Warning:** this can lead to an infinite loop if you have a **Reset Node**.

### get_current_node() -> Dictionary:
Returns the `current_node` value.

### is_complete() -> bool:
Returns `true` if the `current_node` is an **End Node** or has no successors. Returns `false` if it s a **Reset Node** or the node has successors.

### step(stop_at_loop:bool = false) -> bool:
Executes any actions on the current node and moves on to the next node based its results. Returns `false` if this is the last node in the branch, `true` otherwise.

## Properties

### nodes
A dictionary of all of the tree's nodes. Not recommended to use unless you really want to get into the weeds of it.

### current_node
A dictionary of the currently active node's information. *Also* not recommended to use unless all of the functions above are insufficient for what you need.

# Example Scenes

### AllExample.tscn
A scene with a **BranchController** that contains every non-dialog node in it. For seeing how they work.

### Example.tscn
A basic game with NPCs using multiple **BranchController**s for controlling movement and dialog respectively.

# License

Copyleft, but, like, whatever. If you've read this far and you're some new indie gamedev or something who really thinks this code will help you but for some reason you're very determined not to open source your game for whatever reason, I think that's weird but realistically don't care. If your game or project makes less than $1,000 or something, you can interpret this as me granting you a license to use this code in your proprietary game (with credit). If your project makes more than that, either release its source under a license compatible with the AGPLv3, take my code out of your project, or send me ten bucks.