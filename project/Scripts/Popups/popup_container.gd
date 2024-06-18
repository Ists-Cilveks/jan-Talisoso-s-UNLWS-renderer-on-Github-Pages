extends ColorRect
## A container that creates and deletes popups using signals.

func _enter_tree():
	Event_Bus.popup_closing.connect(delete_popup)
	Event_Bus.add_popup_signal.connect(learn_popup_signal)

func _ready():
	set_input_handling(false)

func learn_popup_signal(activation_signal, popup_scene):
	activation_signal.connect(func(): add_popup_scene(popup_scene))

func add_popup_scene(scene):
	set_input_handling(true)
	var instance = scene.instantiate()
	add_child(instance)
	Event_Bus.popup_opened.emit(instance)
	show()

func delete_popup(popup):
	set_input_handling(false)
	remove_child(popup)
	# Delete the popup by creating a delete_popup_deferred function, because
	# the popup emitted itself as a signal and can't immediately be freed.
	var delete_popup_deferred = func delete_popup_deferred(): popup.free()
	delete_popup_deferred.call_deferred()
	hide()

func set_input_handling(enabled):
	set_process_unhandled_input(enabled)
	# TODO: can still focus outside this element using tab

func _unhandled_input(_event):
	accept_event()
