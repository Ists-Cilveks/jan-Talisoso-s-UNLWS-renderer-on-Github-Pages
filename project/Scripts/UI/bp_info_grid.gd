extends VBoxContainer

var rows = []
var bp
var glyph_instance


func init(new_bp, new_glyph_instance):
	glyph_instance = new_glyph_instance
	create_attribute_list_from_bp(new_bp)
	assert("name" in new_bp)
	var bp_name = new_bp.dict["name"]
	$HBoxContainer/Label.set_text(bp_name)


func create_attribute_list_from_bp(new_bp):
	destroy_attribute_list()
	
	# TODO: Find some way to check if the received child is a Glyph_Instance or some other not-yet-implemented class (like a rel line)
	#if not new_instance.is_class("Glyph_Instance"): return
	bp = new_bp
	create_attribute_list()

func create_attribute_list():
	var attribute_dict = bp.get_displayable_attributes()
	for attribute_name in attribute_dict:
		add_simple_attribute_row(attribute_name)

func destroy_attribute_list():
	for row in rows:
		row.free_children()
		row.free()
	rows = []


func add_simple_attribute_row(attribute_name):
	var get_new_value = func get_new_value():
		#return bp.get_instance_attribute(attribute_name)
		return bp.dict[attribute_name]
	#var on_change = func on_change(new_text):
		#bp.set_instance_attribute(attribute_name, new_text)
		#return true
	#var new_row = Grid_Row_With_Line_Edit.new(self, attribute_name, get_new_value, on_change)
	var new_row = Grid_Row_With_Line_Edit.new(self, attribute_name, get_new_value)
	
	new_row.add_to_grid($Attributes)
	new_row.update_text()
	rows.append(new_row)


#func _on_container_glyph_instance_set(new_instance):
	#glyph_instance = new_instance
	#create_attribute_list()
	#for row in rows:
		#row.update_text()

func free_children():
	for row in rows:
		row.free_children()
		row.free()
	rows = []


func delete_bp():
	# TODO: Make this undo-able
	get_parent().delete_bp_info(self)
	glyph_instance.delete_bp(bp)
	#destroy_attribute_list()
	propagate_call("queue_free", [])
