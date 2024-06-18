class_name Grid_Row_With_Check_Button extends Object

var parent
var label = Label.new()
var check_button = CheckButton.new()
var get_new_value
var on_change
var on_change_connected = false

func _init(init_parent, label_name, label_text, init_get_new_value = null, init_on_change = null):
	parent = init_parent
	
	label.name = label_name+"Label"
	label.text = label_text
	
	check_button.name = label_name+"CheckButton"
	check_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	set_get_new_value(init_get_new_value)
	set_on_change(init_on_change)


func set_get_new_value(new_get_new_value):
	get_new_value = new_get_new_value
	if not get_new_value:
		get_new_value = func get_empty_string(): return ""

func set_on_change(new_on_change):
	if on_change_connected:
		# TODO: test/use this
		check_button.toggled.disconnect(on_change)
		on_change_connected = false
	on_change = new_on_change
	if on_change:
		check_button.toggled.connect(on_change)
		on_change_connected = true
	


func add_to_grid(grid):
	grid.add_child(label)
	grid.add_child(check_button)

func update_pressed():
	check_button.set_pressed(get_new_value.call())


func free_children():
	label.free()
	check_button.free()
