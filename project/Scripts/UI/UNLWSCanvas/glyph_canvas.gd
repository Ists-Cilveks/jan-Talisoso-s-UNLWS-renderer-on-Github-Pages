extends UNLWS_Canvas_Container


func _ready():
	Event_Bus.glyph_search_succeeded.connect(hold_instance)
	Event_Bus.glyph_selection_attempted.connect(select_instance)
	Event_Bus.glyph_extra_selection_attempted.connect(select_extra_instance)
	

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if $SelectedGlyphs.is_holding_glyphs:
				Undo_Redo.create_action("Place held glyphs")
				place_selected_glyphs()
				Undo_Redo.commit_action()
	if event is InputEventKey and event.pressed:
		if $SelectedGlyphs.is_holding_glyphs:
			if event.is_action_pressed("ui_text_delete") or event.is_action_pressed("ui_cancel"):
				Undo_Redo.create_action("Delete held glyphs")
				delete_selected_or_held_glyphs()
				Undo_Redo.commit_action()
		if $SelectedGlyphs.is_selecting_glyphs:
			if event.is_action_pressed("ui_text_delete"):
				Undo_Redo.create_action("Delete selected glyphs")
				delete_selected_or_held_glyphs()
				Undo_Redo.commit_action()
			elif event.is_action_pressed("ui_cancel"):
				#Undo_Redo.create_action("Deselect glyphs")
				deselect_selected_glyphs()
				#Undo_Redo.commit_action()


func place_selected_glyphs():
	$SelectedGlyphs.place_all($Glyphs)

func deselect_selected_glyphs():
	$SelectedGlyphs.deselect_all()

func delete_selected_or_held_glyphs():
	$SelectedGlyphs.remove_all()

func hold_instance(new_instance):
	$SelectedGlyphs.overwrite_hold(new_instance)


func select_instance(new_instance, if_successful):
	var successful = $SelectedGlyphs.attempt_to_overwrite_selection(new_instance)
	if successful:
		if_successful.call()

func select_extra_instance(new_instance, if_successful):
	var successful = $SelectedGlyphs.attempt_to_select_extra_instance(new_instance)
	if successful:
		if_successful.call()


func get_UNLWS_canvas_root():
	return self

func get_descendant_element_by_unique_name(node_name):
	return find_child(node_name, true, false)
