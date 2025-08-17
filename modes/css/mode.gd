extends TextForgeMode

var keyword_colors: Dictionary[Color, Array] = {
	Color(0.9, 0.55, 0.55, 1): ["inherit", "initial", "unset", "revert"],
	Color(0.8, 0.65, 1, 1): ["auto", "block", "inline", "flex", "grid", "none"]
}
var code_regions: Array[Array] = [
	[Color(0.95, 0.95, 0.8, 1), '"', '"', false],
	[Color(0.95, 0.95, 0.8, 1), "'", "'", false],
	[Color(0.7, 1, 0.95, 1), "/*", "*/", false],
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
	syntax_highlighter.number_color = Color(0.9, 0.7, 0.5, 1)
	syntax_highlighter.symbol_color = Color(0.5, 0.8, 1, 1)
	syntax_highlighter.function_color = Color(1, 0.8, 0.5, 1)
	syntax_highlighter.member_variable_color = Color(0.7, 1, 0.85, 1)
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			syntax_highlighter.add_keyword_color(keyword, color)
	for region in code_regions:
		syntax_highlighter.add_color_region(region[1], region[2], region[0], region[3])
