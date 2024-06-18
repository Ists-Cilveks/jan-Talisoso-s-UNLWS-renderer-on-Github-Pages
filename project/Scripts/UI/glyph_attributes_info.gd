extends GridContainer

var rows = []
var glyph_instance


func update(new_instance):
	create_attribute_list_from_instance(new_instance)

func erase_data():
	destroy_attribute_list()


func create_attribute_list_from_instance(new_instance):
	destroy_attribute_list()
	
	if new_instance.holdable_type != "glyph":
		return
	
	glyph_instance = new_instance
	create_attribute_list()

func create_attribute_list():
	var attributes = glyph_instance.get_displayable_attributes()
	for attribute_name in attributes:
		add_simple_attribute_row(attribute_name)

func destroy_attribute_list():
	for row in rows:
		row.free_children()
		row.free()
	rows = []


func add_simple_attribute_row(attribute_name):
	var get_new_value = func get_new_value():
		return self.glyph_instance.get_instance_attribute(attribute_name)
	var on_change = func on_change(new_text):
		self.glyph_instance.set_instance_attribute(attribute_name, new_text)
		return true
	var new_row = Grid_Row_With_Line_Edit.new(self, attribute_name, get_new_value, on_change)
	
	new_row.add_to_grid(self)
	new_row.update_text()
	rows.append(new_row)


#func _on_container_glyph_instance_set(new_instance):
	#glyph_instance = new_instance
	#create_attribute_list()
	#for row in rows:
		#row.update_text()
