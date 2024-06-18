extends Button

var settings_scene = preload("./settings.tscn")

func _ready():
	Event_Bus.add_popup_signal.emit(pressed, settings_scene)
