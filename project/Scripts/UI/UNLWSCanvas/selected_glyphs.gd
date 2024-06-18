extends UNLWS_Canvas_Container
## A container of all glyphs that are currently selected

var is_holding_glyphs = false
var is_selecting_glyphs = false

var editing_enabled = false


func _ready():
	super()
	Event_Bus.glyph_editing_requested.connect(func(): attempt_to_set_editing_mode(true))
	Event_Bus.stop_glyph_editing.connect(func(): attempt_to_set_editing_mode(false))
	Event_Bus.glyph_type_saving_attemped.connect(attempt_to_save_glyph_type)
	Event_Bus.request_to_be_held.connect(overwrite_hold)
	#Event_Bus.request_to_be_held.connect(func(node): overwrite_hold(node, false))
	Event_Bus.create_binding_point.connect(create_binding_point)

# Track the mouse position
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		update_mouse_position()

func update_mouse_position():
	if not is_selecting_glyphs:
		set_position(get_global_mouse_position())


#func set_by_name(glyph_name):
	#remove_all()
	#if glyph_name in Glyph_List.glyphs:
		#var glyph_type = Glyph_List.glyphs[glyph_name]
		#var node = glyph_instance_scene.instantiate()
		#node.init(glyph_type)
		#add_child(node)


func signal_stop_holding_child(child):
	var lambda_self = self
	Undo_Redo.add_do_method(func stop_holding_child():
		if lambda_self.get_child_count() == 0:
			lambda_self.signal_stop_holding()
		)
	Undo_Redo.add_do_method(child.stop_hold)
	Undo_Redo.add_undo_method(lambda_self.signal_start_holding)
	Undo_Redo.add_undo_method(child.start_hold)

func signal_start_holding_child(child):
	var lambda_self = self
	Undo_Redo.add_do_method(lambda_self.signal_start_holding)
	Undo_Redo.add_do_method(child.start_hold)
	Undo_Redo.add_undo_method(func undo_start_holding_child():
		if lambda_self.get_child_count() == 0:
			lambda_self.signal_stop_holding()
		)
	Undo_Redo.add_undo_method(child.stop_hold)

func signal_stop_holding():
	is_holding_glyphs = false
	Event_Bus.stopped_holding_glyphs.emit()

func signal_start_holding():
	is_holding_glyphs = true
	Event_Bus.started_holding_glyphs.emit(self.get_children())



func remove_all():
	#Undo_Redo.add_do_method(deselect_all) # Won't work if using the inherited remove_all, because this already removes all children
	Undo_Redo.add_do_method(set_all_as_deselected) # To make sure that the glyphs don't appear selected. TODO: there's gotta be a prettier way than having a separate function to set children's state
	Undo_Redo.add_undo_method(deselect_all)
	super()
	var lambda_self = self
	if is_holding_glyphs:
		Undo_Redo.add_do_property(self, "is_holding_glyphs", false)
		Undo_Redo.add_undo_property(self, "is_holding_glyphs", true)
		Undo_Redo.add_do_method(func(): Event_Bus.stopped_holding_glyphs.emit())
		Undo_Redo.add_undo_method(func(): Event_Bus.started_holding_glyphs.emit(lambda_self.get_children()))
	if is_selecting_glyphs:
		Undo_Redo.add_do_property(self, "is_selecting_glyphs", false)
		Undo_Redo.add_undo_property(self, "is_selecting_glyphs", true)
		Undo_Redo.add_do_method(func(): Event_Bus.stopped_selecting_glyphs.emit())
		Undo_Redo.add_undo_method(func(): Event_Bus.started_selecting_glyphs.emit(lambda_self.get_children()))
		# Also restore this node's position so the selection appears in the right place on undo.
		var lambda_position = Vector2(position)
		Undo_Redo.add_undo_property(self, "position", lambda_position)



func place_child(child, new_parent, actually_reparent = true):
	var parent_after_placing = child.get_parent_after_placing()
	var keep_global_transform = child.get_keep_global_transform()
	if parent_after_placing != null:
		new_parent = parent_after_placing
	#var lambda_self = self
	#assert(child.get_parent() == lambda_self)
	#assert(actually_reparent)
	##Undo_Redo.add_do_method(func(): child.reparent(new_parent, keep_global_transform))
	##Undo_Redo.add_undo_method(func(): child.reparent(lambda_self, keep_global_transform))
	##Undo_Redo.add_do_method(func(): child.reparent(new_parent, false))
	#Undo_Redo.add_do_method(func():
		#child.reparent(new_parent, false)
		#print(child, new_parent)
		#print("new ", child.get_parent())
		#)
	#Undo_Redo.add_undo_method(func(): child.reparent(lambda_self, false))
	##change_node_parent_by_name(child, new_parent, actually_reparent, keep_global_transform)
	var set_parent_command = child.get_set_parent_command(new_parent, true)
	Undo_Redo.add_command(set_parent_command)
	signal_stop_holding_child(child)

func place_all(new_parent):
	var lambda_self = self
	#Undo_Redo.add_do_method(func():
		#print("post ", lambda_self.get_children())
		#)
	Undo_Redo.add_undo_method(deselect_all)
	for child in get_children():
		place_child(child, new_parent, true)
		var keep_selected = false
		if child.has_method("get_keep_selected"):
			keep_selected = child.get_keep_selected()
		if keep_selected:
			# TODO: using call_deferred here to get around the "delay" in Undo_Redo is not great.
			# It could be avoided, but it looks like several other functions would need reworking.
			select_instance.call_deferred(child)
	
	#print("pre ", $"eat-instance-2")
	#print("pre ", lambda_self.get_children())
	#Undo_Redo.add_do_method(func(): print("post ", lambda_self.get_children()))



#func overwrite_hold(new_instance, make_self_parent = true):
func overwrite_hold(new_instance):
	Undo_Redo.add_do_method(deselect_all)
	Undo_Redo.add_undo_method(deselect_all)
	if is_holding_glyphs:
		remove_all()
	#if new_instance.get_keep_global_transform():
		#change_node_parent_by_name(new_instance, self, true, true)
		##var lambda_self = self
		###assert(actually_reparent)
		##Undo_Redo.add_do_method(func(): lambda_self.add_child(new_instance))
		##Undo_Redo.add_undo_method(func(): lambda_self.remove_child(new_instance))
	#else:
		#restore_child(new_instance, make_self_parent)
		##(func(): new_instance.free()).call_deferred() # TODO: should this be called always?
	
	#var lambda_self = self
	## TODO: i'm assuming here that a node that had a parent will also need one after undoing and vice versa. is that safe?
	#if new_instance.get_parent() == null:
		#Undo_Redo.add_do_method(func(): lambda_self.add_child(new_instance))
		#Undo_Redo.add_undo_method(func(): lambda_self.remove_child(new_instance))
	#else:
		#var instance_real_parent = new_instance.get_real_parent()
		#Undo_Redo.add_do_method(func(): new_instance.reparent(lambda_self))
		#Undo_Redo.add_undo_method(func(): new_instance.reparent(instance_real_parent))
	Undo_Redo.add_command(new_instance.get_set_parent_command(self))
	signal_start_holding_child(new_instance)


#func change_node_parent_by_name(node, new_parent, actually_reparent = true, keep_global_transform = false):
	## If not actually_reparent, the child's real_parent will be set but it won't physically be reparented.
	#assert(node != null)
	#assert(new_parent != null)
	#
	#var canvas_root = get_UNLWS_canvas_root()
	#var node_name = node.get_name()
	#var old_parent = node.get_parent()
	#var node_real_parent = node.get_real_parent()
	#if node_real_parent == null:
		#if new_parent != self:
			#node_real_parent = new_parent
		#else:
			#node_real_parent = old_parent
#
	#var old_position = Vector2(node.get_position())
	#var old_real_parent = node.get_real_parent()
	#var has_old_real_parent = false
	#var old_real_parent_name
	#if old_real_parent != null:
		#has_old_real_parent = true
		#old_real_parent_name = old_real_parent.get_name()
	#
	#var new_parent_name = new_parent.get_name()
	#var old_parent_name = old_parent.get_name()
	#
	#var new_position
	#var new_rotation
	#if keep_global_transform:
		#new_position = Vector2()
	#else:
		#new_position = new_parent.to_local(node.global_position)
		#new_rotation = node.get_rotation()
	#
	#var is_being_added_to_selected_glyphs = new_parent == self
	#
	## Find the new_position that needs to be set when doing or redoing
	#if keep_global_transform and not is_being_added_to_selected_glyphs:
		## TODO: This is lazy, since the node doesn't need to be reparented at this point.
		## The necessary new_position and new_rotation should be figured out without actually reparenting.
		#assert(actually_reparent, "Unexpected case of reparenting")
		#node.permanent_reparent(new_parent, true)
		#new_position = node.get_position()
		#new_rotation = node.get_rotation()
	#
	#var do_method = func do_method():
		#var do_node = canvas_root.get_descendant_element_by_unique_name(node_name)
		#var do_new_parent = canvas_root.get_descendant_element_by_unique_name(new_parent_name)
		#assert(do_node != null)
		#assert(do_new_parent != null)
		#if is_being_added_to_selected_glyphs:
			#do_node.reparent(do_new_parent, keep_global_transform)
			#do_node.custom_set_position(new_position)
		#else:
			#if actually_reparent:
				#assert(do_new_parent != null)
				#do_node.permanent_reparent(do_new_parent)
				#do_node.custom_set_position(new_position)
				#do_node.set_rotation(new_rotation)
			#else:
				#do_node.set_real_parent(do_new_parent)
	#Undo_Redo.add_do_method(do_method)
	#if is_being_added_to_selected_glyphs:
		#Undo_Redo.add_do_method(update_mouse_position)
	#
	#var undo_method = func undo_method():
		#var undo_node = canvas_root.get_descendant_element_by_unique_name(node_name)
		#var undo_old_parent = canvas_root.get_descendant_element_by_unique_name(old_parent_name)
		#assert(undo_node != null)
		#assert(undo_old_parent != null)
		#if has_old_real_parent:
			#var undo_old_real_parent = canvas_root.get_descendant_element_by_unique_name(old_real_parent_name)
			#undo_node.set_real_parent(undo_old_real_parent)
		#undo_node.reparent(undo_old_parent)
		#undo_node.set_position(old_position)
	#Undo_Redo.add_undo_method(undo_method)


#region Glyph selection methods
func deselect_instance(child):
	var nodes_real_parent = child.get_real_parent()
	if nodes_real_parent != null:
		child.reparent(nodes_real_parent)
		child.set_is_selected(false)
	else:
		remove_child_without_undo_redo(child, false)
	if get_child_count() == 0:
		Event_Bus.stopped_selecting_glyphs.emit(get_children())
		is_selecting_glyphs = false
	else:
		Event_Bus.started_selecting_glyphs.emit(get_children())
		# TODO: maybe use a separate signal instead of reusing this even when going from 2 to 1 children

func select_instance(child):
	child.reparent(self)
	child.set_is_selected(true)
	Event_Bus.started_selecting_glyphs.emit(get_children())
	is_selecting_glyphs = true

func deselect_all():
	if not is_selecting_glyphs: return
	attempt_to_set_editing_mode(false)
	is_selecting_glyphs = false
	for child in get_children():
		deselect_instance(child)

func set_all_as_deselected():
	for child in get_children():
			child.set_is_selected(false)


func attempt_to_overwrite_selection(new_instance):
	if is_holding_glyphs: return false
	if is_selecting_glyphs:
		deselect_all()
	select_instance(new_instance)
	is_selecting_glyphs = true
	Event_Bus.started_selecting_glyphs.emit(get_children())
	return true

func attempt_to_select_extra_instance(new_instance):
	if is_holding_glyphs: return false
	if new_instance.get_is_selected():
		deselect_instance(new_instance)
	else:
		select_instance(new_instance)
	return true
#endregion


func attempt_to_set_editing_mode(enabled):
	if editing_enabled == enabled:
		return
	if enabled and not can_start_editing_mode():
		return
	editing_enabled = enabled
	for child in get_children():
		child.set_editing_mode(editing_enabled)
	if editing_enabled:
		Event_Bus.glyph_editing_started.emit()
	else:
		Event_Bus.glyph_editing_stopped.emit()

func can_start_editing_mode():
	if ((Settings_Handler.get_setting("glyph editing", "allow_editing_multiple_glyphs") \
		and get_child_count() > 0) \
		or get_child_count() == 1) \
		and not is_holding_glyphs:
		return true
	return false

func signal_ability_to_start_editing_mode():
	if can_start_editing_mode():
		Event_Bus.became_able_to_start_glyph_editing.emit()
	else:
		Event_Bus.became_unable_to_start_glyph_editing.emit()

func _on_child_order_changed():
	signal_ability_to_start_editing_mode.call_deferred()

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			attempt_to_set_editing_mode(true)


#region Save glyph types
func attempt_to_save_glyph_type():
	if get_child_count() != 1:
		return
	var instance = get_child(0)
	instance.overwrite_own_glyph_type()
#endregion


func create_binding_point():
	assert(get_child_count() == 1)
	var child = get_child(0)
	assert(child.holdable_type == "glyph")
	child.create_binding_point()
