extends TextForgeMode

var keyword_colors: Dictionary[Color, Array] = {
	Color.hex(0xffa6a6ff): ["html", "head", "body", "title", "meta", "link", "base", "style", "script"],
	Color.hex(0xccb3ffff): ["p", "br", "hr", "pre", "blockquote", "code", "kbd"],
	Color.hex(0x99ccffff): ["div", "span", "section", "article", "nav", "header", "footer", "main", "aside"],
	Color.hex(0xb3ffb3ff): ["ul", "ol", "li", "dl", "dt", "dd"],
	Color.hex(0xffcc80ff): ["h1", "h2", "h3", "h4", "h5", "h6"],
	Color.hex(0xffbfffff): ["form", "input", "textarea", "button", "label", "select", "option", "fieldset", "legend"],
	Color.hex(0xe6ff99ff): ["table", "thead", "tbody", "tfoot", "tr", "td", "th", "col", "colgroup", "caption"],
	Color.hex(0xd9e6ffff): ["img", "audio", "video", "source", "track", "iframe", "object", "embed"],
	Color.hex(0xb3d9f2ff): ["a", "details", "summary", "dialog", "menu", "menuitem"],
	Color.hex(0xd9f2ccff): ["href", "src", "alt", "id", "class", "type", "rel", "name", "value", "placeholder", "action", "method", "disabled", "checked", "selected"],
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
	syntax_highlighter.number_color = Color.hex(0xffbf66ff)
	syntax_highlighter.symbol_color = Color.hex(0x99d9ffff)
	syntax_highlighter.function_color = Color.hex(0xffffffff)
	syntax_highlighter.member_variable_color = Color.hex(0xff99d9ff)
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			syntax_highlighter.add_keyword_color(keyword, color)
	syntax_highlighter.add_color_region('"', '"', Color.hex(0xe6f2ffff), false)
	syntax_highlighter.add_color_region('<!--', '-->', Color.hex(0xb3e6ffff), false)
	syntax_highlighter.add_color_region('<!', '>', Color.hex(0xb3e6ffff), false)


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