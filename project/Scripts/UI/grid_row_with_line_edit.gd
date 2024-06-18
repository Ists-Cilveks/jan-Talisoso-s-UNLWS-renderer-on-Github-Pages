class_name Grid_Row_With_Line_Edit extends Object

var parent
var label = Label.new()
var line_edit = LineEdit.new()
var get_new_value
var on_change
var on_change_connected = false

func _init(init_parent, label_name, init_get_new_value = null, init_on_change = null):
	parent = init_parent
	
	label.name = label_name+"Label"
	label.text = label_name
	label.clip_text = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	line_edit.name = label_name+"LineEdit"
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	set_get_new_value(init_get_new_value)
	set_on_change(init_on_change)


func set_get_new_value(new_get_new_value):
	get_new_value = new_get_new_value
	if not get_new_value:
		get_new_value = func get_empty_string(): return ""

func set_on_change(new_on_change):
	if on_change_connected:
		# TODO: test/use this
		line_edit.text_changed.disconnect(on_change)
		on_change_connected = false
	on_change = new_on_change
	if on_change != null:
		line_edit.text_changed.connect(on_change)
		on_change_connected = true
		line_edit.editable = true
	else:
		line_edit.editable = false
	


func add_to_grid(grid):
	grid.add_child(label)
	grid.add_child(line_edit)

func update_text():
	line_edit.text = str(get_new_value.call())


func free_children():
	label.free()
	line_edit.free()
