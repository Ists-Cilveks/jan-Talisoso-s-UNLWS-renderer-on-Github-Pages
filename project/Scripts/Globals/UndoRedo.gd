extends Node
## A singleton for undo and redo actions.
## In order to update button styling, call the custom functions
## (commit_action_with_signals instead of commit_action etc.)
## which send custom signals.

var undo_redo = UndoRedo.new()
# It would be nicer if this script extended UndoRedo istead of having an instance of UndoRedo,
# but to make it a singleton it needs to extend Node

signal undo_pressed
signal out_of_undos
signal gained_undo
signal redo_pressed
signal out_of_redos
signal gained_redo

func create_action(action_name, merge_mode=0, backward_undo_ops=false):
	undo_redo.create_action(action_name, merge_mode, backward_undo_ops)

func commit_action():
	#undo_redo.add_do_method(send_do_signals)
	#undo_redo.add_undo_method(send_undo_signals)
	undo_redo.commit_action()
	send_do_signals()

func add_do_method(callable):
	undo_redo.add_do_method(callable)
func add_undo_method(callable):
	undo_redo.add_undo_method(callable)

func add_command(command: Command):
	undo_redo.add_do_method(func(): command.do())
	undo_redo.add_undo_method(func(): command.undo())

func add_do_property(object, property, value):
	undo_redo.add_do_property(object, property, value)
func add_undo_property(object, property, value):
	undo_redo.add_undo_property(object, property, value)

func undo():
	if undo_redo.has_undo():
		undo_redo.undo()
		send_undo_signals()

func redo():
	if undo_redo.has_redo():
		undo_redo.redo()
		send_do_signals()


func send_do_signals():
	gained_undo.emit()
	if not undo_redo.has_redo():
		out_of_redos.emit()

func send_undo_signals():
	gained_redo.emit()
	if not undo_redo.has_undo():
		out_of_undos.emit()
