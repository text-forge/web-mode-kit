extends TextForgeMode

var keyword_colors: Dictionary[Color, Array] = {
	Color.hex(0xd88c8cff): [ "var", "let", "const" ],
	Color.hex(0xb38cc4ff): [ "if", "else", "switch", "case", "default" ],
	Color.hex(0xc48c6bff): [ "for", "while", "do", "break", "continue" ],
	Color.hex(0x8cc4c4ff): [ "function", "return", "class", "extends", "constructor", "super" ],
	Color.hex(0x99b38cff): [ "true", "false", "null", "undefined" ],
	Color.hex(0xa38cc4ff): [ "typeof", "instanceof", "in", "new", "delete", "void" ],
	Color.hex(0x8cb3c4ff): [ "import", "export", "from", "as" ],
	Color.hex(0xc48ca3ff): [ "try", "catch", "finally", "throw" ],
	Color.hex(0xa3c4c4ff): [ "this", "await", "async", "yield", "with", "debugger" ]
}

var code_regions: Array[Array] = [
	[Color.hex(0xf2e6ccff), '"', '"', false],
	[Color.hex(0xf2e6ccff), "'", "'", false],
	[Color.hex(0xf2e6ccff), "`", "`", false],
	[Color.hex(0x999999ff), "//", "", true],
	[Color.hex(0x999999ff), "/*", "*/", false],
	[Color.hex(0xbfbfbfff), "/**", "*/", false]
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
	syntax_highlighter.number_color = Color.hex(0xcc6666ff)
	syntax_highlighter.symbol_color = Color.hex(0xcccc99ff)
	syntax_highlighter.function_color = Color.hex(0x99ccccff)
	syntax_highlighter.member_variable_color = Color.hex(0xb3d9b3ff)
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			syntax_highlighter.add_keyword_color(keyword, color)
	for region in code_regions:
		syntax_highlighter.add_color_region(region[1], region[2], region[0], region[3])
