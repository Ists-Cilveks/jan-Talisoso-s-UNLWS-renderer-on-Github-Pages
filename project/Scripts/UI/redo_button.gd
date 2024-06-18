extends Button

func _ready():
	Undo_Redo.out_of_redos.connect(disable)
	Undo_Redo.gained_redo.connect(enable)

func _on_pressed():
	Undo_Redo.redo()

func disable():
	disabled = true

func enable():
	disabled = false
