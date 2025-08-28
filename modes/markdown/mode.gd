extends TextForgeMode

func _initialize_mode() -> Error:
	syntax_highlighter = Global.load_resource("user://modes/markdown/highlighter.gd").new()
	comment_delimiters.append({
		"start_key": "<!--",
		"end_key": "-->",
		"line_only": false,
	})
	
	return OK


# TODO
func _generate_preview(text: String) -> String:
	return String()


# TODO
func _generate_outline(text: String) -> Array:
	return Array()
