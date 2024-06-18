extends Node

var glyph_save_folder = "user://Glyphs/"
var input_folder = "user://Input/"
var output_folder = "user://Output/"
var default_glyphs_folder = "res://Images/Default glyphs/"
var user_settings_folder = "user://Settings/"

func _ready():
	var folders_to_make = [
		glyph_save_folder,
		input_folder,
		output_folder,
		]
	for path in folders_to_make:
		DirAccess.make_dir_absolute(path)
