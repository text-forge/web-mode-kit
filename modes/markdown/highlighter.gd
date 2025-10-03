extends SyntaxHighlighter

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var spans: Array[Dictionary] = _generate_spans(line)
	var highlight_map := {}
	spans.sort_custom(func(a, b): return a["start"] < b["start"])

	var last_end: int = 0
	for span: Dictionary in spans:
		var start: int = span["start"]
		var end: int = span["end"]
		var color: Color = span["color"]

		if start > last_end:
			highlight_map[last_end] = { "color": U.get_syntax_color(U.SyntaxColors.DEFAULT) }

		highlight_map[start] = { "color": color }
		highlight_map[end] = {"color": U.get_syntax_color(U.SyntaxColors.DEFAULT)}
		last_end = end
	
	return highlight_map


func _generate_spans(line: int) -> Array[Dictionary]:
	var line_string: String = get_text_edit().get_line(line)
	var spans: Array[Dictionary] = []

	var patterns := [
		{ "regex": r"^>\s?.*", "color": U.get_syntax_color(U.SyntaxColors.COMMENT) },
		{ "regex": r"^(#{1,6})\s+.*", "color": U.get_syntax_color(U.SyntaxColors.KEYWORD_3) },
		{ "regex": r"^(?:-{3,}|\*{3,})\s*$", "color": U.get_syntax_color(U.SyntaxColors.KEYWORD_2) },
		{ "regex": r"\*\*\*(.+?)\*\*\*", "color": U.get_syntax_color(U.SyntaxColors.KEYWORD_1) },
		{ "regex": r"\*\*(.+?)\*\*", "color": U.get_syntax_color(U.SyntaxColors.KEYWORD_1) },
		{ "regex": r"\*(.+?)\*", "color": U.get_syntax_color(U.SyntaxColors.KEYWORD_1) },
		{ "regex": r"`(.+?)`", "color": U.get_syntax_color(U.SyntaxColors.STRING) },
		{ "regex": r"~~(.+?)~~", "color": U.get_syntax_color(U.SyntaxColors.COMMENT) },
		{ "regex": r"!\[([^\]]*)\]\(([^)]+)\)", "color": U.get_syntax_color(U.SyntaxColors.CUSTOM_5) },
		{ "regex": r"\[([^\]]*)\]\(([^)]+)\)", "color": U.get_syntax_color(U.SyntaxColors.FUNCTION_DEF) },
		{ "regex": r"-\s\[(x|X)\]\s", "color": U.get_syntax_color(U.SyntaxColors.TYPE_1) },
		{ "regex": r"-\s\[\s\]\s(.*)", "color": U.get_syntax_color(U.SyntaxColors.TYPE_3) },
		{ "regex": r"https?://[^\s\)]+", "color": U.get_syntax_color(U.SyntaxColors.FUNCTION_DEF) }
	]

	for pattern in patterns:
		var regex := RegEx.new()
		regex.compile(pattern["regex"])
		var result := regex.search_all(line_string)
		for match in result:
			var start := match.get_start(0)
			var end := match.get_end(0)
			var overlaps := false
			for r in spans:
				if start < r["end"] and end > r["start"]:
					overlaps = true
					break
			
			if not overlaps:
				spans.append({
					"start": start,
					"end": end,
					"color": pattern["color"]
				})
	
	return spans
