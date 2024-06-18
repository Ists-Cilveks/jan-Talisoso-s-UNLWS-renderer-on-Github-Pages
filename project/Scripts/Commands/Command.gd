class_name Command extends RefCounted

#var do_callable
#var undo_callable

#func _init(do_func, undo_func):
	#do_callable = do_func
	#undo_callable = undo_func

#func do():
	#do_callable.call()
#func undo():
	#undo_callable.call()

func do(): return
func undo(): return
