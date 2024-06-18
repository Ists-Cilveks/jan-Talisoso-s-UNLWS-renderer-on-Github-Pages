extends GridContainer

var bp_info_grid_scene = preload("./bp_info_grid.tscn")

var bp_infos = []
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
	var bp_list = glyph_instance.get_binding_points()
	for bp in bp_list:
		add_binding_point_info_grid(bp)

func destroy_attribute_list():
	for bp_info in bp_infos:
		#bp_info.free_children()
		#bp_info.free()
		bp_info.propagate_call("queue_free", [])
	bp_infos = []


func delete_bp_info(old_bp_info):
	bp_infos.erase(old_bp_info)


func add_binding_point_info_grid(bp):
	var new_grid = bp_info_grid_scene.instantiate()
	new_grid.init(bp, glyph_instance)
	
	bp_infos.append(new_grid)
	add_child(new_grid)


#func _on_container_glyph_instance_set(new_instance):
	#glyph_instance = new_instance
	#create_attribute_list()
	#for grid in bp_infos:
		#grid.update_text()
