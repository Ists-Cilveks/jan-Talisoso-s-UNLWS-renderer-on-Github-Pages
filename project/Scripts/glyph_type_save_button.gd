extends Button

func _on_pressed():
	Event_Bus.glyph_type_saving_attemped.emit()
