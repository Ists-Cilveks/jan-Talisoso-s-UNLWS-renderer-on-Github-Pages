extends Node
## A singleton to save and restore which element was in focus.
## Useful when there's something like a popup that takes focus and then gives it back.

## When you open a new layer (that takes away control from everything else), call push to grab focus.
## When you close the layer, call pop to release focus and let the previous element grab it.

var focus_stack = []

func push(new_element = null):
	var element = release_current_focus()
	if element != null:
		focus_stack.append(element)
	
	if new_element != null:
		new_element.grab_focus()

func pop():
	release_current_focus()
	
	if len(focus_stack) > 0:
		var popped_element = focus_stack.pop_back()
		popped_element.grab_focus()


func release_current_focus():
	var element = get_viewport().gui_get_focus_owner()
	if element != null:
		element.release_focus()
	return element
