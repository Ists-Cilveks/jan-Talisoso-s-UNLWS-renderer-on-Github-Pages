class_name Glyph_Type extends Object

signal changed()

var name
var sprite_path
var texture_is_loaded = false
var texture
var xml_node
var binding_points = {}
var num_instances = 0 # Used to quickly create unique IDs for Glyph_Instances


func _init(init_name, init_sprite_path):
	name = init_name
	sprite_path = init_sprite_path
	xml_node = get_xml_node_from_svg_path(sprite_path)
	var g_node = xml_node.get_main_node_with_name("g")
	binding_points = get_bp_dict_from_xml_node(g_node)

## Modified from https://github.com/godotengine/godot-docs/issues/2148 by Justo Delgado (mrcdk)
#func get_external_texture(path):
	#if !texture_is_loaded:
		#var img = Image.new()
		#img.load(path)
		#texture = ImageTexture.new()
		#texture = texture.create_from_image(img)
		#texture_is_loaded = true
	#return texture

#func get_texture_from_external_svg(path):
func get_texture():
	if !texture_is_loaded:
		var buffer = FileAccess.get_file_as_bytes(sprite_path)
		var img = Image.new()
		img.load_svg_from_buffer(buffer, 25.0)
		texture = ImageTexture.new()
		texture = texture.create_from_image(img)
		texture_is_loaded = true
	return texture

#func get_xml_node_from_svg_path(svg_string):
func get_xml_node_from_svg_path(svg_path):
	# Modified from https://docs.godotengine.org/en/stable/classes/class_xmlparser.html [accessed 2024-01-21]
	var parser = XMLParser.new()
	parser.open(svg_path)
	
	var new_xml_node = XML_Node_From_Parser.new(parser)
	var g_node = new_xml_node.get_main_node_with_name("g")
	assert(g_node, "UNSUPPORTED SVG: There isn't a single main <g> element")
	g_node.set_attribute("id", name)
	
	#print(new_xml_node.get_string())
	#print(new_xml_node.deep_copy().get_string() == new_xml_node.get_string())
	#print(new_xml_node.get_main_node_with_name("g"))
	
	#var test_file = FileAccess.open(
		#"res://Images/Output/"+svg_path.rsplit("/", true, 1)[1],
		#FileAccess.WRITE)
	#test_file.store_string(new_xml_node.get_string())
	
	return new_xml_node

func save(path):
	var test_file = FileAccess.open(
		path,
		FileAccess.WRITE)
	test_file.store_string(xml_node.get_string())


func set_bp_info(bp_name, position, angle):
	var bp_attributes_dict = {
		"name": bp_name,
		"x": position.x,
		"y": position.y,
		"angle": angle,
	}
	var new_bp
	if bp_name in binding_points:
		new_bp = binding_points[bp_name]
		new_bp.init(bp_attributes_dict)
	else:
		new_bp = Binding_Point.new(bp_attributes_dict)
		binding_points[bp_name] = new_bp
	
	set_bp_node(new_bp)

func set_bp_node(new_bp):
	var g_node = xml_node.get_main_node_with_name("g")
	var bp_node_name = g_node.my_namespace+":bp"
	var existing_bp_nodes = g_node.get_children_with_name(bp_node_name)
	# Find the bp node called bp_name or create one if it doesn't exist
	# TODO: use get_bp_node
	var needed_bp_node
	for bp in existing_bp_nodes:
		if "name" in bp.attributes_dict \
		and "name" in new_bp.dict \
		and bp.attributes_dict["name"] == new_bp.dict["name"]:
			needed_bp_node = bp
			break
	if !needed_bp_node:
		needed_bp_node = XML_Node.new(bp_node_name)
		g_node.add_child(needed_bp_node)
	
	for attribute_name in new_bp.dict:
		needed_bp_node.set_attribute(
			attribute_name,
			str(new_bp.dict[attribute_name]))
	
	new_bp.dict["xml_node"] = needed_bp_node

# Find the bp node called bp_name
# TODO: untested
func get_bp_node(bp_name):
	var g_node = xml_node.get_main_node_with_name("g")
	var bp_node_name = g_node.my_namespace+":bp"
	var existing_bp_nodes = g_node.get_children_with_name(bp_node_name)
	var needed_bp_node
	for bp in existing_bp_nodes:
		if "name" in bp.attributes_dict \
		and bp.attributes_dict["name"] == bp_name:
			needed_bp_node = bp
			break
	assert(needed_bp_node != null)
	return needed_bp_node

func delete_bp(bp_key):
	var bp = binding_points[bp_key]
	var bp_node = get_bp_node(bp.get_attribute("name"))
	var g_node = xml_node.get_main_node_with_name("g")
	g_node.remove_child(bp_node)
	

func get_bp_dict_from_xml_node(g_node):
	var res = {}
	for bp_node in g_node.get_children_with_name(g_node.my_namespace+":bp"):
		var new_name = bp_node.attributes_dict["name"]
		assert(new_name, "UNSUPPORTED SVG: There is a <"+g_node.my_namespace+":bp> node with no \"name\" attribute")
		var new_bp = Binding_Point.new(bp_node.attributes_dict.duplicate())
		res[new_name] = new_bp
		new_bp.set_attribute("xml_node", bp_node)
		# TODO: The get_string function of the bp nodes could be overridden so that it gets the values from the Binding_Point instead of constantly needing to be synced.
		## TODO: will this accomplish that? (ETA: no.)
		#var get_attributes_string = func():
			#var res2 = ""
			#for attribute_name in new_bp.dict:
				#res2 += attribute_name + "=\"" + new_bp.dict[attribute_name].xml_escape() + "\"\n"
			#return res2
		#bp_node.get_attributes_string = get_attributes_string
	return res


func get_new_id():
	var new_id = name + "-instance-" + str(num_instances)
	num_instances += 1
	return new_id


func update_from_instance(instance):
	for bp_name in binding_points:
		delete_bp(bp_name)
	binding_points = {}
	
	var instance_binding_points = instance.get_binding_points()
	for bp in instance_binding_points:
		set_bp_info(bp.get_attribute("name"), bp.get_bp_position(), bp.get_attribute("angle"))
	
	changed.emit()

func save_from_instance(instance):
	update_from_instance(instance)
	DirAccess.make_dir_absolute(Global_Paths.glyph_save_folder)
	save(Global_Paths.glyph_save_folder+name+".svg")
