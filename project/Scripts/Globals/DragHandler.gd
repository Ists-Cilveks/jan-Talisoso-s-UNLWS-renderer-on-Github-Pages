extends Node

# To differentiate drags from simple presses, a press has a certain time that the mouse can be pressed for and a certain distance that the mouse can travel from the starting point.
var MAX_PRESS_TIME = 0.2 # sec
var MAX_PRESS_DISPLACEMENT = 10 # px

var is_dragging = false
var drag_is_currently_short
var global_mouse_start_pos
var local_mouse_start_pos
var local_node_start_pos
var local_node_start_rotation
var node_center_local_pos
var node
var is_changing_rotation # true: a node's rotation is being changed; false: position


func process_input_event(event):
	if is_dragging:
		if event is InputEventMouseMotion:
			var global_displacement = global_mouse_start_pos - event.get_global_position()
			if drag_is_currently_short and \
				global_displacement.length() >= MAX_PRESS_DISPLACEMENT:
				drag_is_currently_short = false
			var canvas_transform = node.get_viewport().get_canvas_transform()
			
			# TODO: these are really complicated solutions, there's probably an easier way to get the position and rotation.
			# More accurately, I have no idea why this works.
			if is_changing_rotation:
				var mouse_position_on_canvas = canvas_transform.affine_inverse() * event.get_position()
				var mouse_position_on_container = node.get_parent().to_local(mouse_position_on_canvas)
				var new_rotation = (mouse_position_on_container - node_center_local_pos).angle()
				node.update_drag_rotation(new_rotation)
			else:
				var local_mouse_pos = node.get_parent().to_local(event.get_global_position())
				var mouse_offset = local_mouse_pos - local_mouse_start_pos
				var inverse_canvas_transform = Transform2D(canvas_transform.x, canvas_transform.y, Vector2.ZERO).affine_inverse()
				var node_offset = inverse_canvas_transform * mouse_offset
				var new_position = local_node_start_pos + node_offset
				node.update_drag_position(new_position)
		if event is InputEventMouseButton \
			and event.is_released() \
			and event.button_index == MOUSE_BUTTON_LEFT:
			end_drag()


func end_drag():
	if drag_is_currently_short:
		node.end_short_drag_press()
	else:
		node.end_drag()
	is_dragging = false
	drag_is_currently_short = null
	global_mouse_start_pos = null
	local_mouse_start_pos = null
	local_node_start_pos = null
	local_node_start_rotation = null
	node = null
	is_changing_rotation = null

func start_drag(event, new_node, rotation_drag = false):
	node = new_node
	var lambda_self = self
	drag_is_currently_short = true
	get_tree().create_timer(MAX_PRESS_TIME).timeout.connect(func(): lambda_self.drag_is_currently_short = false)
	global_mouse_start_pos = event.get_global_position()
	local_mouse_start_pos = node.get_parent().to_local(event.get_global_position())
	local_node_start_pos = node.get_parent().to_local(node.get_global_position())
	
	node_center_local_pos = node.get_position()
	
	is_dragging = true
	if rotation_drag:
		is_changing_rotation = true
		local_node_start_rotation = node.get_rotation()
	else:
		is_changing_rotation = false

# Given an event and a node that can be dragged and is hovered,
# determine if the event should start a drag, and if so, start it.
func start_drag_if_possible(event, check_node, set_event_as_handled = false, rotation_drag = false):
	if is_dragging: return # Don't drag multiple nodes at once
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.is_pressed():
			if set_event_as_handled:
				check_node.get_viewport().set_input_as_handled()
			check_node.start_drag()
			start_drag(event, check_node, rotation_drag)
