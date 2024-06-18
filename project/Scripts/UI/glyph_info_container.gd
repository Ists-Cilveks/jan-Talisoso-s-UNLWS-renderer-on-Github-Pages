extends GridContainer

var updatable_children

func _ready():
	updatable_children = [
		$GlyphAttributes,
		$AllBindingPointInfo,
		$FileData/PathLineEdit,
	]
	Event_Bus.started_holding_glyphs.connect(update_children)
	Event_Bus.stopped_holding_glyphs.connect(update_children)
	Event_Bus.started_selecting_glyphs.connect(update_children)
	Event_Bus.stopped_selecting_glyphs.connect(update_children)

func update_children(children = null):
	var should_show = false
	var instance
	if children != null and len(children) == 1:
		instance = children[0]
		if instance.holdable_type == "glyph":
			should_show = true
	if should_show:
		for child in updatable_children:
			child.update(instance)
		show()
	else:
		for child in updatable_children:
			child.erase_data()
		hide()
