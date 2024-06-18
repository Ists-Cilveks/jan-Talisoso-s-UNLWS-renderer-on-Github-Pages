extends Node
## A global dictionary that has info about all glyphs.
## The dict is loaded from SVGs in multiple directories (see _init).

var glyphs = {}


func _init(folder_paths = [Global_Paths.glyph_save_folder, Global_Paths.input_folder, Global_Paths.default_glyphs_folder]): # TODO: after the files are re-saved in the Glyphs folder, i need to get rid of the Input folder links
	for path in folder_paths:
		add_new_glyphs_from_folder(path)


# Modified from https://gist.github.com/Sirosky/a60ae50a78a420bd9eaaff430a78fbcf
# Recursively find all files with the given extension in the given folder
func get_all_files(path: String, file_ext := "", files := []) -> Array: #Loops through an entire directory recursively, and pulls the full file paths
	if path[-1] != "/":
		path += "/"
	var dir = DirAccess.open(path)

	if dir != null:
		dir.list_dir_begin()

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir() + file_name, file_ext, files)
			else:
				if len(file_ext) == 0 or file_name.get_extension() == file_ext:
					files.append(path + file_name)

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)

	return files

func get_filename_from_path(path):
	return path.rsplit("/", true, 1)[1].rsplit(".", true, 1)[0]

# Go through all files in the given folder (recursively) and add each SVG as a Glyph_Type. If
func add_new_glyphs_from_folder(folder_path):
	var svg_paths = get_all_files(folder_path, "svg")
	
	for path in svg_paths:
		var glyph_name = get_filename_from_path(path)
		if not glyph_name in glyphs:
			glyphs[glyph_name] = Glyph_Type.new(glyph_name, path)

func save_all_to_folder(folder_path):
	if folder_path[-1] != "/":
		folder_path += "/"
	for glyph_name in glyphs:
		glyphs[glyph_name].save(folder_path+glyph_name+".svg")

