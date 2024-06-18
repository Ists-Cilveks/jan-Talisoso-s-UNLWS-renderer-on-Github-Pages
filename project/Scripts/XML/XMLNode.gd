class_name XML_Node extends Object

var children = []
var node_type
var node_name
var attributes_dict = {}
var node_full_text = "" # If the node can't be parsed, then its data will be stored directly so it can be inserted into a different XML file

const my_namespace = "unlws-renderer"

# NOTE: This may modify the arguments
@warning_ignore("shadowed_variable")
func _init(name, attributes_dict={}, children=[], type=XMLParser.NODE_ELEMENT):
	self.node_type = type
	self.node_name = name
	self.attributes_dict = attributes_dict
	add_my_default_attributes()
	self.children = children


func get_string():
	var res = ""
	#print("num children:", len(children))
	#if len(children) == 1 :
		#print("num grandchildren:", len(children[0].children))
	for child in children:
		if child.node_type == XMLParser.NODE_ELEMENT:
			res += "<" + child.node_name
			var has_children = (len(child.children) != 0)
			if len(child.attributes_dict) != 0:
				var attributes_string = child.get_attributes_string()
				if attributes_string[-1] == "\n": # Get rid of trailing newline
					attributes_string = attributes_string.left(len(attributes_string)-1)
				res += "\n" + attributes_string.indent("\t")
			if !has_children: # child is self-closing
				res += " /"
			res += ">\n"
			res += child.get_string().indent("\t")
			if has_children: # child needs a closing tag
				res += "</"+child.node_name+">\n"
		else:
			if len(child.node_full_text) > 0:
				res += child.node_full_text + "\n"
	return res

func get_attributes_string():
	var res = ""
	for attribute_name in attributes_dict:
		res += attribute_name + "=\"" + str(attributes_dict[attribute_name]).xml_escape() + "\"\n"
		# TODO: is xml_escape appropriate here? does it escape the attribute values correctly or just xml tags?
	return res


func get_main_node_with_name(name): # This node or the first descendant that has the given name
	if node_name == name:
		return self
	var num_children_with_main_nodes = 0
	var previous_main_node
	for child in children:
		var potential_main_node = child.get_main_node_with_name(name)
		if potential_main_node:
			previous_main_node = potential_main_node
			num_children_with_main_nodes += 1
	if num_children_with_main_nodes == 1:
		return previous_main_node
	elif num_children_with_main_nodes > 1:
		print("UNSUPPORTED SVG: There's a ", node_name, " node that has ", num_children_with_main_nodes, " children that each have a descendant that is a ", name," node.")


func deep_copy(): # TODO: I haven't really checked this and don't know how to 😬
	var new_attributes_dict = {}
	for name in attributes_dict:
		new_attributes_dict[name] = attributes_dict[name]
	var new_children = []
	for child in children:
		new_children.append(child.deep_copy())
	return XML_Node.new(node_name, new_attributes_dict, new_children, node_type)


func set_attribute(name, value):
	attributes_dict[name] = value

func get_attribute(name):
	return attributes_dict[name]

func add_my_default_attributes():
	if node_name == "svg":
		set_attribute("xmlns", "http://www.w3.org/2000/svg")
		set_attribute("xmlns:"+my_namespace, "https://github.com/Ists-Cilveks/UNLWS-renderer")

func add_child(child):
	children.append(child)
func remove_child(child):
	assert(child in children)
	children.erase(child)

func get_children_with_name(name):
	var res = []
	for child in children:
		if child.node_name == name:
			res.append(child)
	return res
