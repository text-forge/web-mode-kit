extends TextForgeMode

var keyword_colors: Dictionary[Color, Array] = {
	Color.hex(0xbe8cd8ff): [ "true", "false", "null"],
}

var code_regions: Array[Array] = [
	[Color.hex(0xf2e6ccff), '"', '"', false],
	[Color.hex(0xf2e6ccff), "'", "'", false],
]

func _initialize_mode() -> Error:
	_initialize_highlighter()
	string_delimiters.append({
		"start_key": '"',
		"end_key": '"',
		"line_only": false,
	})
	string_delimiters.append({
		"start_key": "'",
		"end_key": "'",
		"line_only": false,
	})
	_enable_auto_format_feature()
	return OK


func _update_code_completion_options(text: String) -> void:
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			Global.get_editor().add_code_completion_option(CodeEdit.KIND_CLASS, keyword, keyword, color)


func _auto_format(text: String) -> String:
	var data = JSON.parse_string(text)
	var indent = " ".repeat(Global.get_editor().indent_size) if Global.get_editor().indent_use_spaces else "\t"
	if data == null:
		Global.send_notification(Global.Notification.ERROR, "JSON parse error!", "Auto format failed.")
		return text
	var formatted := JSON.stringify(data, indent)
	return formatted


func _initialize_highlighter() -> void:
	syntax_highlighter = CodeHighlighter.new()
	syntax_highlighter.number_color = Color.SKY_BLUE
	syntax_highlighter.symbol_color = Color.PALE_GOLDENROD
	syntax_highlighter.function_color = Color.WHITE
	syntax_highlighter.member_variable_color = Color.WHITE
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			syntax_highlighter.add_keyword_color(keyword, color)
	for region in code_regions:
		syntax_highlighter.add_color_region(region[1], region[2], region[0], region[3])
