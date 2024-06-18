extends Node2D
## An object that follows the mouses movements to display a cursor

func _ready():
	Event_Bus.started_holding_glyphs.connect(hide_cursor)
	Event_Bus.stopped_holding_glyphs.connect(show_cursor)

# Track the mouse position
func _input(event):
	if event is InputEventMouseMotion:
		position = get_global_mouse_position()


func hide_cursor(_children):
	$Cursor.hide()

func show_cursor():
	$Cursor.show()
