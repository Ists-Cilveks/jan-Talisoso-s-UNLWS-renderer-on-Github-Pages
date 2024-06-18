extends Control

func _ready():
	Focus_Handler.push($Container/CloseButton)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		remove()

func _on_close_button_pressed():
	remove()

func remove():
	Event_Bus.popup_closing.emit(self)
	Focus_Handler.pop()
	# TODO: un-hide the mouse cursor if it was hidden on a lower layer (and remember to re-hide it)
