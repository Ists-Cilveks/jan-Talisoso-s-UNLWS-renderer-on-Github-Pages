extends Node2D

var binding_point_scene = preload("./binding_point.tscn")


func _ready():
	name = "BP-container-of-" + get_owner_glyph().get_name()


func set_visibility(enabled):
	if enabled:
		show()
	else:
		hide()

func map_over_children(function):
	for child in get_children():
		function.call(child)


func get_bp_restore_dicts():
	var res = []
	for bp in get_children():
		res.append(bp.get_copied_restore_dict())
	return res

func restore_bps_from_dicts(all_dicts):
	for dict in all_dicts:
		var bp = binding_point_scene.instantiate()
		bp.init(dict, true, self)
		add_child(bp)

func restore_bps_from_glyph_type(glyph_type):
	for name_of_bp_to_copy in glyph_type.binding_points:
		var new_bp = binding_point_scene.instantiate()
		var copied_restore_dict = glyph_type.binding_points[name_of_bp_to_copy].get_copied_restore_dict()
		copied_restore_dict["owner_glyph_name"] = str(get_owner_glyph().get_name())
		new_bp.init(copied_restore_dict, false, self)
		add_child(new_bp)


func has_child_with_bp_name(test_name):
	for child in get_children():
		if child.bp_name == test_name:
			return true
	return false

func create_default_bp(new_bp_property_adder = null):
	var new_bp = binding_point_scene.instantiate()
	var owner_glyph = get_owner_glyph()
	var owner_glyph_name = owner_glyph.get_name()
	var new_bp_name
	for i in range(100): # Find a unique name (a number)
		new_bp_name = str(i)
		if not has_child_with_bp_name(new_bp_name):
			break
	assert(not has_child_with_bp_name(new_bp_name))
	new_bp.init({
		"real_parent": self,
		"owner": new_bp,
		"owner_glyph_name": owner_glyph_name,
		"name": new_bp_name,
		})
	if new_bp_property_adder != null:
		new_bp_property_adder.call(new_bp)
	add_child(new_bp)


func delete_bp(bp):
	remove_child(bp)
	bp.free()


#region Parent getting functions
func get_UNLWS_canvas_root():
	return get_real_parent().get_UNLWS_canvas_root()

func get_real_parent():
	return get_owner_glyph()

func get_owner_glyph():
	return get_parent().get_parent()
#endregion
