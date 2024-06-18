class_name UNLWS_Canvas_Element extends Node2D

var real_parent # The semi-permanent parent, usually not the SelectedGlyphs node (or maybe something else that's temporary).
var is_on_canvas = false # False if the element has been "deleted", including if undo has been used until before it was created.

func set_real_parent(new_parent):
	real_parent = new_parent
func get_real_parent():
	return real_parent
func get_parent_after_placing():
	return null

func set_is_on_canvas(value):
	if is_on_canvas == value: return
	is_on_canvas = value

class SetParentCommand extends Command:
	var element # The node that has its parent set
	var new_parent # The node that the element will be reparented to on do
	var old_real_parent # The node that the element will be reparented to on undo
	var set_real_parent = false
	
	func _init(init_node, init_new_parent, init_set_real_parent = false):
		element = init_node
		new_parent = init_new_parent
		set_real_parent = init_set_real_parent
	
	func do():
		old_real_parent = element.get_real_parent()
		
		if new_parent == null:
			new_parent = element.get_parent_after_placing()
		
		if element.get_parent() == null:
			new_parent.add_child(element)
		else:
			element.reparent(new_parent)
		
		if set_real_parent:
			element.set_real_parent(new_parent)
	
	func undo():
		var new_parent = element.get_parent()
		
		if old_real_parent == null:
			if new_parent != null:
				new_parent.remove_child(element)
		
		else:
			if new_parent != null:
				element.reparent(old_real_parent)
			else:
				assert(false) # This is a strange case that probably shouldn't ever happen
				old_real_parent.add_child(element)
			
			if set_real_parent:
				element.set_real_parent(old_real_parent)

func get_set_parent_command(new_parent = null, set_real_parent = false):
	return SetParentCommand.new(self, new_parent, set_real_parent)
