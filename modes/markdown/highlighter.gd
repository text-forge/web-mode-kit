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
			highlight_map[last_end] = { "color": Color.WHITE }

		highlight_map[start] = { "color": color }
		highlight_map[end] = {"color": Color.WHITE}
		last_end = end
	
	return highlight_map


func _generate_spans(line: int) -> Array[Dictionary]:
	var line_string: String = get_text_edit().get_line(line)
	var spans: Array[Dictionary] = []

	var patterns := [
		{ "regex": r"^>\s?.*", "color": Color.GRAY },
		{ "regex": r"^(#{1,6})\s+.*", "color": Color.CORAL },
		{ "regex": r"^(?:-{3,}|\*{3,})\s*$", "color": Color.MEDIUM_VIOLET_RED },
		{ "regex": r"\*\*\*(.+?)\*\*\*", "color": Color.RED },
		{ "regex": r"\*\*(.+?)\*\*", "color": Color.ORANGE_RED },
		{ "regex": r"\*(.+?)\*", "color": Color.INDIAN_RED },
		{ "regex": r"`(.+?)`", "color": Color.LIGHT_SLATE_GRAY },
		{ "regex": r"~~(.+?)~~", "color": Color.WEB_GRAY },
		{ "regex": r"!\[([^\]]*)\]\(([^)]+)\)", "color": Color.LIGHT_GREEN },
		{ "regex": r"\[([^\]]*)\]\(([^)]+)\)", "color": Color.LIGHT_SEA_GREEN },
		{ "regex": r"-\s\[(x|X)\]\s", "color": Color.SPRING_GREEN },
		{ "regex": r"-\s\[\s\]\s(.*)", "color": Color.TAN },
		{ "regex": r"https?://[^\s\)]+", "color": Color.LIGHT_SEA_GREEN }
	]

	for pattern in patterns:
		var regex := RegEx.new()
		regex.compile(pattern["regex"])
		var result := regex.search_all(line_string)
		for match in result:
			var start := match.get_start(0)
			var end := match.get_end(0)
			var overlaps := false
			for range in spans:
				if start < range["end"] and end > range["start"]:
					overlaps = true
					break
			
			if not overlaps:
				spans.append({
					"start": start,
					"end": end,
					"color": pattern["color"]
				})
	
	return spans
