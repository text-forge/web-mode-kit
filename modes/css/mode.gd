extends TextForgeMode

var keyword_colors: Dictionary[Color, Array] = {
	U.get_syntax_color(U.SyntaxColors.BUILTIN): [ "word", "letter", "line", "spacing", "size", "text", "font", "family", "border", "radius", "box", "shadow", "margin", "padding", "width", "height", "border", "background", "color", "transition", "animation", "name", "duration", "iteration", "count", "direction", "timing", "function", "keyframes" ],
	U.get_syntax_color(U.SyntaxColors.KEYWORD_1): [ "inherit", "initial", "unset", "revert" ],
	U.get_syntax_color(U.SyntaxColors.KEYWORD_2): [ "repeat", "no-repeat", "repeat", "x", "y", "space", "round", "cover", "contain", "auto", "block", "inline", "flex", "grid", "none" ],
	U.get_syntax_color(U.SyntaxColors.KEYWORD_3): [ "px", "em", "rem", "%", "vh", "vw", "vmin", "vmax", "ch", "ex", "cm", "mm", "in", "pt", "pc" ],
	U.get_syntax_color(U.SyntaxColors.CUSTOM_2): [ "bold", "normal", "italic", "oblique", "small-caps", "uppercase", "lowercase", "capitalize" ],
	U.get_syntax_color(U.SyntaxColors.CUSTOM_3): [ "rotate", "scale", "skew", "translate", "rotateX", "rotateY", "translateX", "translateY" ],
	U.get_syntax_color(U.SyntaxColors.CUSTOM_5): [ "transparent", "currentColor" ],
	U.get_syntax_color(U.SyntaxColors.TYPE_1): [ "filter", "hue-rotate", "blur", "brightness", "contrast", "drop", "shadow", "grayscale", "invert", "opacity", "saturate", "sepia" ],
	U.get_syntax_color(U.SyntaxColors.TYPE_2): [ "ease", "linear", "in", "out", "infinite", "forwards", "backwards", "alternate" ],
	U.get_syntax_color(U.SyntaxColors.TYPE_3): [ "left", "right", "top", "bottom", "center", "start", "end" ],
}
var code_regions: Array[Array] = [
	[U.get_syntax_color(U.SyntaxColors.STRING), '"', '"', false],
	[U.get_syntax_color(U.SyntaxColors.STRING), "'", "'", false],
	[U.get_syntax_color(U.SyntaxColors.COMMENT), "/*", "*/", false],
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
	var _indent_size := Global.get_editor().indent_size
	var indent_str := " ".repeat(_indent_size) if Global.get_editor().indent_use_spaces else "\t"

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
