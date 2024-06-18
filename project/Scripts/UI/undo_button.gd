extends Button

func _ready():
	Undo_Redo.out_of_undos.connect(disable)
	Undo_Redo.gained_undo.connect(enable)

func _on_pressed():
	Undo_Redo.undo()

func disable():
	disabled = true

func enable():
	disabled = false
