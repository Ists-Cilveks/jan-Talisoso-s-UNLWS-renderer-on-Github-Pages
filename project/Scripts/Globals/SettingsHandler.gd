extends Node

var settings = ConfigFile.new()

func _ready():
	# Set default values for all settings
	for_each_default_setting(func(section, setting, _label, value):
		set_setting(section, setting, value)
	)
	
	# Load user settings file (if it exists) and overwrite settings with them.
	# Allowed to fail (file may have been deleted)
	settings.load(Global_Paths.user_settings_folder+"settings.cfg")

func save_settings():
	DirAccess.make_dir_absolute(Global_Paths.user_settings_folder)
	var error = settings.save(Global_Paths.user_settings_folder+"settings.cfg")
	if error != OK:
		assert(false)
		return

func get_setting(section, setting_name):
	return settings.get_value(section, setting_name)

func set_setting(section, setting_name, value):
	settings.set_value(section, setting_name, value)


func for_each_default_setting(lambda):
	for section in default_settings:
		var section_name = section["section_name"]
		for setting_arr in section["settings"]:
			var setting_name = setting_arr[0]
			var label_text = setting_arr[1]
			var default_value = setting_arr[2]
			lambda.call(section_name, setting_name, label_text, default_value)

var default_settings = [
	{
		"section_name": "glyph editing",
		"settings": [
			["allow_editing_multiple_glyphs", "Allow editing multiple glyphs at once", false],
		]
	},
	{
		"section_name": "text creation",
		"settings": [
			["deselect_glyphs_after_placing", "Deselect glyphs as soon as they are placed", false],
		]
	},
]
