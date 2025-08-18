extends TextForgeMode

var keyword_colors: Dictionary[Color, Array] = {
	Color.hex(0xe68c8cff): ["inherit", "initial", "unset", "revert"],
	Color.hex(0xcca6ffff): ["auto", "block", "inline", "flex", "grid", "none"]
}
var code_regions: Array[Array] = [
	[Color.hex(0xf2f2ccff), '"', '"', false],
	[Color.hex(0xf2f2ccff), "'", "'", false],
	[Color.hex(0xb3fff2ff), "/*", "*/", false],
]

func _initialize_mode() -> Error:
	_initialize_highlighter()
	comment_delimiters.append({
		"start_key": "/*",
		"end_key": "*/",
		"line_only": false,
	})
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
	
	_enable_auto_indent_feature()
	
	return OK


func _auto_indent(text: String) -> String:
	var lines := text.split("\n", false)
	var formatted := []
	var indent_level := 0
	var indent_size := Global.get_editor().indent_size
	var indent_str := " ".repeat(indent_size) if Global.get_editor().indent_use_spaces else "\t"

	for line in lines:
		var stripped := line.strip_edges()
		if stripped.ends_with("}"):
			indent_level = max(0, indent_level - 1)

		formatted.append(indent_str.repeat(indent_level) + stripped)

		if stripped.ends_with("{"):
			indent_level += 1

	return "\n".join(formatted)


func _update_code_completion_options(text: String) -> void:
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			Global.get_editor().add_code_completion_option(CodeEdit.KIND_CLASS, keyword, keyword, color)


# TODO
func _generate_outline(text: String) -> Array:
	return Array()


# TODO
func _lint_file(text: String) -> Array[Dictionary]:
	return Array([], TYPE_DICTIONARY, "", null)


func _initialize_highlighter() -> void:
	syntax_highlighter = CodeHighlighter.new()
	syntax_highlighter.number_color = Color.hex(0xe6b380ff)
	syntax_highlighter.symbol_color = Color.hex(0x80ccffff)
	syntax_highlighter.function_color = Color.hex(0xffcc80ff)
	syntax_highlighter.member_variable_color = Color.hex(0xb3ffd9ff)
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			syntax_highlighter.add_keyword_color(keyword, color)
	for region in code_regions:
		syntax_highlighter.add_color_region(region[1], region[2], region[0], region[3])
