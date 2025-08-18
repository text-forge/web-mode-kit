extends TextForgeMode

var keyword_colors: Dictionary[Color, Array] = {
	Color.hex(0xffb366ff): [ "var", "let", "const" ],
	Color.hex(0xcc99ffff): [ "if", "else", "switch", "case", "default" ],
	Color.hex(0xff9966ff): [ "for", "while", "do", "break", "continue" ],
	Color.hex(0x66e0ffff): [ "function", "return", "class", "extends", "constructor", "super" ],
	Color.hex(0x99ffccff): [ "true", "false", "null", "undefined" ],
	Color.hex(0xcc66ffff): [ "typeof", "instanceof", "in", "new", "delete", "void" ],
	Color.hex(0x66ccffff): [ "import", "export", "from", "as" ],
	Color.hex(0xff6699ff): [ "try", "catch", "finally", "throw" ],
	Color.hex(0xb3e6ffff): [ "this", "await", "async", "yield", "with", "debugger" ]
}
var code_regions: Array[Array] = [
	[Color.hex(0xfff0ccff), '"', '"', false],
	[Color.hex(0xfff0ccff), "'", "'", false],
	[Color.hex(0xfff0ccff), "`", "`", false],
	[Color.hex(0x999999ff), "//", "", true],
	[Color.hex(0x999999ff), "/*", "*/", false],
	[Color.hex(0xccccccff), "/**", "*/", false]
]

func _initialize_mode() -> Error:
	_initialize_highlighter()
	comment_delimiters.append({
		"start_key": "//",
		"end_key": "",
		"line_only": true,
	})
	comment_delimiters.append({
		"start_key": "/*",
		"end_key": "*/",
		"line_only": false,
	})
	comment_delimiters.append({
		"start_key": "/**",
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
	string_delimiters.append({
		"start_key": "`",
		"end_key": "`",
		"line_only": false,
	})
	
	return OK


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
	syntax_highlighter.number_color = Color.hex(0xff6666ff)
	syntax_highlighter.symbol_color = Color.hex(0xffe680ff)
	syntax_highlighter.function_color = Color.hex(0x66ccffff)
	syntax_highlighter.member_variable_color = Color.hex(0xccffccff)
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			syntax_highlighter.add_keyword_color(keyword, color)
	for region in code_regions:
		syntax_highlighter.add_color_region(region[1], region[2], region[0], region[3])
