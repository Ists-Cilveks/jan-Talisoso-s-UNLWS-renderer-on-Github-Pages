extends Node

var glyph_save_folder = "res://Glyphs/"
var input_folder = "res://Input/"
var output_folder = "res://Output/"
var default_glyphs_folder = "res://Images/Default glyphs/"
var user_settings_folder = "res://Settings/"

func _ready():
	var folders_to_make = [
		glyph_save_folder,
		input_folder,
		output_folder,
		]
	for path in folders_to_make:
		DirAccess.make_dir_absolute(path)
