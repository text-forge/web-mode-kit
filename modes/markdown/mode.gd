extends TextForgeMode

func _initialize_mode() -> Error:
	syntax_highlighter = U.load_resource("user://modes/markdown/highlighter.gd").new()
	comment_delimiters.append({
		"start_key": "<!--",
		"end_key": "-->",
		"line_only": false,
	})

	return OK


func _generate_outline(text: String) -> Array:
	var outline := []
	var i: int = 0
	var stack := []
	for l in text.split("\n"):
		var regex := RegEx.new()
		regex.compile(r"^(#{1,6})\s+.*")
		if regex.search_all(l).is_empty():
			i += 1
			continue

		var level: int = l.split(" ")[0].strip_edges().length()
		var title: String = l.lstrip("#").strip_edges()
		if level == 1:
			if not stack.is_empty():
				outline.append(stack)
			stack = [title, i]
		elif level == 2:
			if stack.is_empty():
				stack = ["", i]
			stack.append([title, i])
		elif level == 3:
			if stack.is_empty():
				stack = ["", i, ["", i]]
			elif stack[-1] is int:
				stack.append(["", i])
			stack[-1].append([title, i])
		elif level == 4:
			if stack.is_empty():
				stack = ["", i, ["", i, ["", i]]]
			elif stack[-1] is int:
				stack.append(["", i, ["", i]])
			elif stack[-1][-1] is int:
				stack[-1].append(["", i])
			stack[-1][-1].append([title, i])
		elif level == 5:
			if stack.is_empty():
				stack = ["", i, ["", i, ["", i, ["", i]]]]
			elif stack[-1] is int:
				stack.append(["", i, ["", i, ["", i]]])
			elif stack[-1][-1] is int:
				stack[-1].append(["", i, ["", i]])
			elif stack[-1][-1][-1] is int:
				stack[-1][-1].append(["", i])
			stack[-1][-1][-1].append([title, i])
		elif level == 6:
			if stack.is_empty():
				stack = ["", i, ["", i, ["", i, ["", i, ["", i]]]]]
			elif stack[-1] is int:
				stack.append(["", i, ["", i, ["", i, ["", i]]]])
			elif stack[-1][-1] is int:
				stack[-1].append(["", i, ["", i, ["", i]]])
			elif stack[-1][-1][-1] is int:
				stack[-1][-1].append(["", i, ["", i]])
			elif stack[-1][-1][-1][-1] is int:
				stack[-1][-1][-1].append(["", i])
			stack[-1][-1][-1][-1].append([title, i])
		i += 1

	if not stack.is_empty():
		outline.append(stack)

	return outline
