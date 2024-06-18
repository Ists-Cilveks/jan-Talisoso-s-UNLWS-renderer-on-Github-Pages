extends GridContainer

func _ready():
	var lambda_self = self
	Settings_Handler.for_each_default_setting(func(section_name, setting_name, setting_label_text, _default_value):
		var get_new_value = func get_new_value():
			return Settings_Handler.get_setting(section_name, setting_name)
		var set_new_value = func set_new_value(new_value):
			Settings_Handler.set_setting(section_name, setting_name, new_value)
			Settings_Handler.save_settings()
		var row = Grid_Row_With_Check_Button.new(
			lambda_self,
			setting_name,
			setting_label_text,
			get_new_value,
			set_new_value
			)
		row.update_pressed()
		row.add_to_grid(lambda_self)
	)
