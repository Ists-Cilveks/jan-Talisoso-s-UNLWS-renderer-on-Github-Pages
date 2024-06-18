extends Node
## A singleton that contains signals about global events like inputs

signal glyph_placed(glyph)
signal glyph_search_succeeded(glyph_instance)

signal request_to_be_held(node, on_success)
signal started_holding_glyphs(children)
signal stopped_holding_glyphs()

signal started_selecting_glyphs(children)
signal stopped_selecting_glyphs()

signal popup_opened(popup)
signal popup_closing(popup)

signal search_halted()
signal search_resumed()

signal add_popup_signal(activation_signal, popup_scene)

signal glyph_selection_attempted(glyph_instance, if_successful)
signal glyph_extra_selection_attempted(glyph_instance, if_successful)

signal glyph_editing_requested()
signal stop_glyph_editing()
signal glyph_editing_started()
signal glyph_editing_stopped()
signal became_able_to_start_glyph_editing()
signal became_unable_to_start_glyph_editing()

signal glyph_type_saving_attemped()

signal create_binding_point()
