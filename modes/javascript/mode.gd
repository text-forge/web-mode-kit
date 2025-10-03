extends TextForgeMode

var keyword_colors: Dictionary[Color, Array] = {
	U.get_syntax_color(U.SyntaxColors.KEYWORD_1): [ "this", "import", "export", "from", "as", "typeof", "instanceof", "in", "new", "delete", "void", "var", "let", "const", "true", "false", "null", "undefined", "function", "class", "extends", "constructor", "super" ],
	U.get_syntax_color(U.SyntaxColors.KEYWORD_2): [ "if", "else", "switch", "case", "default", "for", "while", "do", "break", "continue", "return" ],
	U.get_syntax_color(U.SyntaxColors.KEYWORD_3): [ "try", "catch", "finally", "throw", "await", "async", "yield", "with", "debugger" ],
}

var code_regions: Array[Array] = [
	[U.get_syntax_color(U.SyntaxColors.STRING), '"', '"', false],
	[U.get_syntax_color(U.SyntaxColors.STRING), "'", "'", false],
	[U.get_syntax_color(U.SyntaxColors.STRING), "`", "`", false],
	[U.get_syntax_color(U.SyntaxColors.COMMENT), "//", "", true],
	[U.get_syntax_color(U.SyntaxColors.COMMENT), "/*", "*/", false],
	[U.get_syntax_color(U.SyntaxColors.DOC_COMMENT), "/**", "*/", false]
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
	syntax_highlighter.number_color = U.get_syntax_color(U.SyntaxColors.NUMBER)
	syntax_highlighter.symbol_color = U.get_syntax_color(U.SyntaxColors.SYMBOL)
	syntax_highlighter.function_color = U.get_syntax_color(U.SyntaxColors.FUNCTION)
	syntax_highlighter.member_variable_color = U.get_syntax_color(U.SyntaxColors.MEMBER)
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			syntax_highlighter.add_keyword_color(keyword, color)
	for region in code_regions:
		syntax_highlighter.add_color_region(region[1], region[2], region[0], region[3])
