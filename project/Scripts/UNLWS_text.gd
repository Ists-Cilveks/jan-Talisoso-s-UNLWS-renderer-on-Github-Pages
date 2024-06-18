class_name UNLWS_Text extends Object

var required_defs_names = []
var xml_node
var g_node
var svg_node
var defs_node


func _init():
	defs_node = XML_Node.new("defs")
	g_node = XML_Node.new("g")
	var svg_attributes = {}
	svg_node = XML_Node.new("svg", svg_attributes, [defs_node, g_node])
	xml_node = XML_Node.new(null, {}, [svg_node])

func add_required_def(id, g_node_copy):
	if not id in required_defs_names:
		required_defs_names.append(id)
		defs_node.add_child(g_node_copy)

func add_glyph(instance):
	var type_g_node = instance.glyph_type.xml_node.get_main_node_with_name("g").deep_copy()
	var glyph_name = instance.glyph_type.name
	add_required_def(glyph_name, type_g_node)
	#g_node.add_child(instance.glyph_type.xml_node.get_main_node_with_name("g"))
	var transform_string = instance.get_transform_string()
	g_node.add_child(XML_Node.new("use", {
		"href": "#"+glyph_name,
		"transform": transform_string
	}))
	g_node.set_attribute("id", instance.id)
