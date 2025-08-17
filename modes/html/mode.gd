extends TextForgeMode

var keyword_colors: Dictionary[Color, Array] = {
	Color(1, 0.65, 0.65, 1): ["html", "head", "body", "title", "meta", "link", "base", "style", "script"],
	Color(0.8, 0.7, 1, 1): ["p", "br", "hr", "pre", "blockquote", "code", "kbd"],
	Color(0.6, 0.8, 1, 1): ["div", "span", "section", "article", "nav", "header", "footer", "main", "aside"],
	Color(0.7, 1, 0.7, 1): ["ul", "ol", "li", "dl", "dt", "dd"],
	Color(1, 0.8, 0.5, 1): ["h1", "h2", "h3", "h4", "h5", "h6"],
	Color(1, 0.75, 1, 1): ["form", "input", "textarea", "button", "label", "select", "option", "fieldset", "legend"],
	Color(0.9, 1, 0.6, 1): ["table", "thead", "tbody", "tfoot", "tr", "td", "th", "col", "colgroup", "caption"],
	Color(0.85, 0.9, 1, 1): ["img", "audio", "video", "source", "track", "iframe", "object", "embed"],
	Color(0.7, 0.85, 0.95, 1): ["a", "details", "summary", "dialog", "menu", "menuitem"],
	Color(0.85, 0.95, 0.8, 1): ["href", "src", "alt", "id", "class", "type", "rel", "name", "value", "placeholder", "action", "method", "disabled", "checked", "selected"],
}
var self_closing_tags := [
	"area", "base", "br", "col", "embed", "hr", "img", "input",
	"link", "meta", "param", "source", "track", "wbr"
]

func _initialize_mode() -> Error:
	_initialize_highlighter()
	comment_delimiters.append({
		"start_key": "<!--",
		"end_key": "-->",
		"line_only": false,
	})
	comment_delimiters.append({
		"start_key": "<!",
		"end_key": ">",
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
	
	_enable_auto_format_feature()
	
	return OK


func _auto_format(text: String) -> String:
	var indent_level := 0
	var indent_str := " ".repeat(Global.get_editor().indent_size) if Global.get_editor().indent_use_spaces else "\t"
	var formatted := []

	var raw_lines := text.split("\n", false)
	var lines := _merge_multiline_tags(raw_lines)

	for line in lines:
		var chunks := _split_tags(line)
		for chunk in chunks:
			if chunk == "":
				continue
			chunk = _clean_attribute_spacing(chunk)
			var tag_delta := _count_tag_diff(chunk)
			if tag_delta < 0:
				indent_level = max(0, indent_level + tag_delta)
			formatted.append(indent_str.repeat(indent_level) + chunk)
			if tag_delta > 0:
				indent_level += tag_delta

	return "\n".join(formatted)


func _update_code_completion_options(text: String) -> void:
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			if keyword in self_closing_tags:
				Global.get_editor().add_code_completion_option(CodeEdit.KIND_CLASS, "<" + keyword + "/>", keyword + "/>", color)
			else:
				Global.get_editor().add_code_completion_option(CodeEdit.KIND_CLASS, "<" + keyword + ">", keyword + ">\n\t\n</" + keyword + ">", color)


# TODO
func _generate_outline(text: String) -> Array:
	return Array()


# TODO
func _lint_file(text: String) -> Array[Dictionary]:
	return Array([], TYPE_DICTIONARY, "", null)


func _initialize_highlighter() -> void:
	syntax_highlighter = CodeHighlighter.new()
	syntax_highlighter.number_color = Color(1, 0.75, 0.4, 1)
	syntax_highlighter.symbol_color = Color(0.6, 0.85, 1, 1)
	syntax_highlighter.function_color = Color(1, 1, 1, 1)
	syntax_highlighter.member_variable_color = Color(1, 0.6, 0.85, 1)
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			syntax_highlighter.add_keyword_color(keyword, color)
	syntax_highlighter.add_color_region('"', '"', Color(0.9, 0.95, 1, 1), false)
	syntax_highlighter.add_color_region('<!--', '-->', Color(0.7, 0.9, 1, 1), false)
	syntax_highlighter.add_color_region('<!', '>', Color(0.7, 0.9, 1, 1), false)


func _split_tags(line: String) -> PackedStringArray:
	var result := []
	var regex := RegEx.new()
	regex.compile(r"(<[^>]+>)")
	var pos := 0
	for match in regex.search_all(line):
		if match.get_start() > pos:
			result.append(line.substr(pos, match.get_start() - pos).strip_edges())
		result.append(match.get_string().strip_edges())
		pos = match.get_end()
	if pos < line.length():
		result.append(line.substr(pos).strip_edges())
	return result


func _clean_attribute_spacing(line: String) -> String:
	var cleaned := line
	var regex := RegEx.new()
	regex.compile(r'\s*=\s*')
	cleaned = regex.sub(cleaned, '=', true)
	regex.compile(r'\s{2,}')
	cleaned = regex.sub(cleaned, ' ', true)
	return cleaned.strip_edges()


func _merge_multiline_tags(lines: PackedStringArray) -> PackedStringArray:
	var result := PackedStringArray()
	var buffer := ""
	var in_open_tag := false

	for line in lines:
		if not in_open_tag:
			buffer = line
			if line.count("<") > line.count(">") and not line.strip_edges().ends_with(">"):
				in_open_tag = true
			else:
				result.append(line)
		else:
			buffer += " " + line
			if ">" in line:
				result.append(buffer)
				buffer = ""
				in_open_tag = false

	if in_open_tag and buffer != "":
		result.append(buffer)

	return result


func _count_tag_diff(line: String) -> int:
	var diff := 0
	var regex := RegEx.new()
	regex.compile("<(/?)(\\w+)[^>]*?>")
	var matches := regex.search_all(line)
	for match in matches:
		var closing := match.get_string(1) == "/"
		var tag := match.get_string(2).to_lower()
		var self_closing := tag in self_closing_tags or match.get_string(0).ends_with("/>")
		if self_closing:
			continue
		elif closing:
			diff -= 1
		else:
			diff += 1
	return diff