extends Button

func _on_pressed():
	Event_Bus.create_binding_point.emit()
