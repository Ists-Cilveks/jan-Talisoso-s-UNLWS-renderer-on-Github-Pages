extends Button

func _ready():
	Event_Bus.glyph_editing_started.connect(func(): set_button_pressed(true))
	Event_Bus.glyph_editing_stopped.connect(func(): set_button_pressed(false))
	Event_Bus.became_able_to_start_glyph_editing.connect(func(): set_button_disabled(false))
	Event_Bus.became_unable_to_start_glyph_editing.connect(func(): set_button_disabled(true))

func _on_pressed():
	if button_pressed: # Pressing a button
		Event_Bus.glyph_editing_requested.emit()
	else: # Releasing a pressed button
		Event_Bus.stop_glyph_editing.emit()

func set_button_pressed(enabled):
	button_pressed = enabled

func set_button_disabled(new_disabled):
	disabled = new_disabled
