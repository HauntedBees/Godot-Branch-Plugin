# Godot 3.4 *The Branch* Plugin
Dialog Trees, Decision Trees, Behavior Trees, Pine Trees... one plugin for all of the above.

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