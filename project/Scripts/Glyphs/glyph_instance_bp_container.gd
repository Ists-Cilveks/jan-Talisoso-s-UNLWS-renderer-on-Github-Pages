extends Node2D

func hide_all():
	for bp in get_children():
		bp.hide()

func show_all():
	for bp in get_children():
		bp.show()
