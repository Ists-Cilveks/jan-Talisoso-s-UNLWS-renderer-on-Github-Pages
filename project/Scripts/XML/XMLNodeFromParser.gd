class_name XML_Node_From_Parser extends XML_Node

@warning_ignore("shadowed_variable")
func _init(parser):
	var node_type = parser.get_node_type()
	var attributes_dict = {}
	
	# TODO: Make sure there is a main g node so that it can be added to refs etc. If multiple children are g nodes, make a parent g node.
	
	if node_type == XMLParser.NODE_ELEMENT:
		node_name = parser.get_node_name()
		#if not parser.is_empty():
			#print("<"+node_name+">")
		#else:
			#print("<"+node_name+" />")
		attributes_dict = create_attributes_dict(parser)
	elif node_type == XMLParser.NODE_ELEMENT_END:
		#print(node_name, "==", parser.get_node_name())
		#assert(node_name == parser.get_node_name()) # TODO: there should be a check of this kind so that closing tags fit their opening tags
		#node_name = parser.get_node_name()
		#node_full_text = "</" + node_name + ">"
		#print(node_full_text)
		pass
	else:
		node_full_text = "" # TODO: how to actually extract source text from the parser?
	
	# Parse children
	var children = []
	if not parser.is_empty() and node_type in [XMLParser.NODE_ELEMENT, XMLParser.NODE_NONE]: # The only nodes that need to be checked for children are the start node and elements that aren't empty (<element />)
		while parser.read() != ERR_FILE_EOF:
			if parser.get_node_type() == XMLParser.NODE_TEXT:# TODO: I'm not sure this is reliable. Does this get rid of all the nodes that are unneeded (there could be other types)? Are there text nodes (and info in them) that are necessary?
				continue
			var potential_child = XML_Node_From_Parser.new(parser)
			#print(potential_child.node_type)
			if potential_child.node_type == XMLParser.NODE_ELEMENT_END:
				break
			elif !is_node_worth_storing(potential_child):
				continue
			else:
				children.append(potential_child)
	
	super(node_name, attributes_dict, children, node_type)

func is_attribute_worth_storing(name):
	if ":" in name:
		if name.begins_with(my_namespace+":"):
			return true
		else:
			return false
	elif name == "id":
		return false # TODO: This is temporary. I should retain the existing ids, maybe adding something to them, and generate my own ids so that they avoid the existing ones.
	else:
		return true

func is_node_worth_storing(node):
	if node.node_name:
		var name = node.node_name
		if ":" in name:
			if name.begins_with(my_namespace+":"):
				return true
			else:
				return false
		elif name == "defs" and len(node.children) == 0:
			return false
		else:
			return true
	else:
		return true

func create_attributes_dict(parser):
	var dict = {}
	for idx in range(parser.get_attribute_count()):
		var attribute_name = parser.get_attribute_name(idx)
		# NOTE: The attributes could be cleaned in the parent class, but I'm assuming that the XMLNodes that are getting passed around will already be clean
		if is_attribute_worth_storing(attribute_name):
			dict[attribute_name] = parser.get_attribute_value(idx)
	add_my_default_attributes()
	return dict

func add_my_default_attributes():
	super()
	#if node_type == XMLParser.NODE_NONE:
		#var g_node = get_main_node_with_name("g")
		#if g_node:
			#g_node.add_attribute("id", ) # During parsing this node doesn't know what its source file is named, and maybe it shouldn't.

