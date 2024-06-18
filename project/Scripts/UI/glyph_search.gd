extends Control

func _ready():
	Event_Bus.search_resumed.connect(show)
	Event_Bus.search_halted.connect(hide)
