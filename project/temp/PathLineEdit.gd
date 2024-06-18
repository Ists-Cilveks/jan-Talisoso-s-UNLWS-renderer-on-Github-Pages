extends LineEdit

func update(new_instance):
	assert(new_instance.get("glyph_type") != null)
	set_text(new_instance.glyph_type.sprite_path)

func erase_data():
	set_text("")
