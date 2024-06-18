extends LineEdit


var glyph_instance_scene = preload("../Glyphs/glyph_instance.tscn")
var glyphs = Glyph_List.glyphs
var test_instance = glyph_instance_scene.instantiate()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		var key = String.chr(event.unicode).to_lower()
		if not event.is_command_or_control_pressed() and len(key) == 1 and key != " ":
			append_text(key)
			Focus_Handler.push(self)
			set_caret_column(len(text))
			accept_event()

func _gui_input(event):
	var key_handled = false
	if event.is_action_pressed("ui_cancel"):
		key_handled = cancel_input()
	elif event.is_action_pressed("ui_accept"):
		key_handled = input_complete()
	
	if key_handled:
		# Prevents buttons from being pressed by enter or space if the gui buttons are focused
		accept_event()


func erase_all_text():
	text = ""

func append_text(new_text):
	if len(text) == 0:
		Event_Bus.search_resumed.emit()
	text += new_text

func backspace_input():
	text = text.left(len(text)-1)

func cancel_input():
	var key_handled = false
	if len(text) != 0:
		key_handled = true
	erase_all_text()
	Focus_Handler.pop()
	Event_Bus.search_halted.emit()
	return key_handled

func input_complete():
	var glyph_name = text
	var key_handled = false
	if glyph_name:
		key_handled = true
	if glyph_name in glyphs:
		Undo_Redo.create_action("Overwrite held glyph with search")
		var glyph_type = glyphs[glyph_name]
		var instance = glyph_instance_scene.instantiate()
		instance.init(glyph_type)
		Event_Bus.glyph_search_succeeded.emit(instance)
		Undo_Redo.commit_action()
	cancel_input()
	return key_handled
