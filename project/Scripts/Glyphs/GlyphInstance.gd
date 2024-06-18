class_name Glyph_Instance extends UNLWS_Canvas_Element
## An instance of a glyph with a certain name, position etc.
## To instance it, load the glyph_instance.tscn scene, do not just call new()

## name and id: each glyph instance must have a unique id which is also its name.
## The name is used to find the node in the tree

var sprite_shader = preload("./glyph_instance_sprite.gdshader")
#var self_scene = preload("./glyph_instance.tscn") # Causes the scene to be invalid because then the scene needs itself to be loaded in order to load.
var self_scene
var sprite_material = ShaderMaterial.new()

var glyph_type
var id
var holdable_type = "glyph"

var style_dict = {}

var instance_g_node
var focus_bp_name
var focus_bp
@export var focused_on_bp_node: Node2D
@export var bp_container_node: Node2D
@export var sprite_node: Sprite2D

var base_rotation

var binding_point_visibility = true
var editing_enabled = false
var is_selected = false


#region Initialization
@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
func _init(glyph_type = null, focus_bp_name = null, position = Vector2(), rotation = 0):
	if glyph_type:
		init(glyph_type, focus_bp_name, position, rotation)

@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
func init(glyph_type, focus_bp_name = null, position = Vector2(), rotation = 0, id = null, bp_list = null):
	#self_scene = load("res://Scripts/Glyphs/glyph_instance.tscn")
	self_scene = load("res://Scripts/Glyphs/glyph_instance.tscn")
	
	set_glyph_type(glyph_type)
	self.instance_g_node = glyph_type.xml_node.get_main_node_with_name("g").deep_copy()
	
	if id:
		self.name = id
	else:
		self.name = glyph_type.get_new_id()
	self.id = self.name
	
	if bp_container_node != null: # TODO: Might bp_container_nodebe good to always or never have access to a BPContainer object rather than it depending on whether this script is part of a glyph_instance.tscn scene.
		if bp_list == null: # Use the default BPs defined in the glyph type
			bp_container_node.restore_bps_from_glyph_type(glyph_type)
		else: # Restore BPs from a dictionary
			bp_container_node.restore_bps_from_dicts(bp_list)
	
	if sprite_node != null: # TODO: Might be good to always or never have access to a Sprite object rather than it depending on whether this script is part of a glyph_instance.tscn scene.
		var texture = glyph_type.get_texture()
		sprite_node.texture = texture
		sprite_node.set_material(sprite_material)
		sprite_material.set_shader(sprite_shader)
	
	set_glyph_position(position, false)
	set_glyph_rotation(rotation, false)

	set_focus_bp(focus_bp_name)


@warning_ignore("shadowed_variable")
func set_focus_bp(focus_bp_name, update=true):
	if not focus_bp_name in glyph_type.binding_points:
		var bp_names = glyph_type.binding_points.keys()
		if len(bp_names) > 0:
			focus_bp_name = bp_names[0]
	self.focus_bp_name = focus_bp_name
	if focus_bp_name in glyph_type.binding_points:
		self.focus_bp = glyph_type.binding_points[focus_bp_name]
	else:
		self.focus_bp = Binding_Point.new({}) # TODO: maybe change this so that Glyph_Type makes sure there is always at least a fallback BP, instead of that being taken care of in Glyph_Instance
	
	if focused_on_bp_node:
		focused_on_bp_node.position = -focus_bp.position
	
	if update:
		update_rotation()
		update_node_transform()
#endregion


#region Input
func _unhandled_input(event):
	if event is InputEventMouseButton \
		and event.is_pressed() \
		and event.button_index == MOUSE_BUTTON_LEFT:

		var local_pos = sprite_node.to_local(get_viewport().get_canvas_transform().affine_inverse() * event.position)

		if sprite_node.is_pixel_opaque(local_pos):
			var lambda_viewport = get_viewport()
			var if_successful = func if_glyph_selection_is_successful():
				lambda_viewport.set_input_as_handled()
			if event.is_ctrl_pressed():
				Event_Bus.glyph_extra_selection_attempted.emit(self, if_successful)
			else:
				Event_Bus.glyph_selection_attempted.emit(self, if_successful)
#endregion

func add_style(new_dict):
	for glyph_name in new_dict:
		style_dict[glyph_name] = new_dict[glyph_name]

func get_style_dict():
	return style_dict


#region Getters and setters
func set_instance_attribute(attribute_name, value):
	instance_g_node.set_attribute(attribute_name, value)

func get_instance_attribute(attribute_name):
	return instance_g_node.get_attribute(attribute_name)

func get_displayable_attributes():
	return instance_g_node.attributes_dict


func set_glyph_type(new_type):
	if glyph_type != null:
		assert(false) # TODO: handle removing the old glyph type (signals, etc.(?))
	glyph_type = new_type
	glyph_type.changed.connect(func(): pass) # TODO: what to connect this to?

func set_glyph_position(new_position, update=true):
	position = new_position
	if update:
		update_node_transform()

func set_glyph_rotation(new_rotation, update=true):
	base_rotation = new_rotation
	if update:
		update_rotation()
		update_node_transform()

func update_rotation(): # TODO: rename update_rotation and set_glyph_rotation to something more desciptive/intuitive
	rotation = deg_to_rad(base_rotation) - focus_bp.rotation


func update_node_transform():
	instance_g_node.set_attribute("transform", get_transform_string())

func get_transform_string():
	var res = ""
	res += "translate("+str(position.x)+" "+str(position.y)+")\n"
	res += "translate("+str(-focus_bp.position.x)+" "+str(-focus_bp.position.y)+")\n"
	res += "rotate("+str(rotation_degrees)+" "+str(focus_bp.position.x)+" "+str(focus_bp.position.y)+")\n"
	res = res.left(len(res)-1)
	return res


func set_binding_point_visibility(enabled):
	binding_point_visibility = enabled
	bp_container_node.set_visibility(enabled)

func set_editing_mode(enabled):
	editing_enabled = enabled
	bp_container_node.map_over_children(update_bp_state)


func permanent_reparent(new_parent, keep_global_transform = false):
	reparent(new_parent, keep_global_transform)
	set_real_parent(new_parent)


func get_UNLWS_canvas_root():
	return get_parent().get_UNLWS_canvas_root()


func custom_set_position(new_position):
	set_position(new_position)
#endregion


#region Binding point actions
func show_binding_points():
	if bp_container_node != null:
		bp_container_node.show_all()
func hide_binding_points():
	if bp_container_node != null:
		bp_container_node.hide_all()

func delete_bp(bp):
	bp_container_node.delete_bp(bp)

func create_binding_point():
	bp_container_node.create_default_bp(update_bp_state)

func update_bp_state(bp):
	# Called on a BP that needs to update whether the glyph is being held, selected etc.
	bp.set_editing_mode(editing_enabled)
#endregion


#region Save/restore with a dict
#func get_restore_dict(preserve_id = true):
	#var res = {
		#glyph_type = glyph_type,
		#focus_bp_name = focus_bp_name,
		#position = position, # TODO: is this passed by reference? it probably shouldn't be
		#rotation = base_rotation,
		#real_parent = real_parent,
		#binding_point_dicts = bp_container_node.get_bp_restore_dicts(),
	#}
	#if preserve_id:
		#res["id"] = id
	#return res
#
#func get_restore_function():
	#var lambda_self_scene = self_scene
	#var restore_dict = get_restore_dict()
	#return func restore_glyph_instance():
		#var res = lambda_self_scene.instantiate()
		#res.restore_from_dict(restore_dict)
		#return res
#
#func restore_from_dict(dict):
	#init(dict["glyph_type"], dict["focus_bp_name"], dict["position"], dict["rotation"], dict["id"], dict["binding_point_dicts"])
	##set_is_selected(dict["is_selected"])
	#set_real_parent(dict["real_parent"])
#endregion


#region Glyph_Type creation and data access needed for it
func overwrite_own_glyph_type():
	glyph_type.save_from_instance(self)

func get_binding_points():
	return bp_container_node.get_children()
#endregion


#region Selection and holding
func get_keep_global_transform():
	return false


func get_keep_selected():
	var keep_selected = not Settings_Handler.get_setting("text creation", "deselect_glyphs_after_placing")
	return keep_selected

func get_is_selected():
	return is_selected

func set_is_selected(enabled):
	if is_selected == enabled: return
	is_selected = enabled
	if is_selected:
		sprite_material.set_shader_parameter('difference', 0.5)
	else:
		sprite_material.set_shader_parameter('difference', 0)


func start_hold():
	pass
func stop_hold():
	pass
#endregion
