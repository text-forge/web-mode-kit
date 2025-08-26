extends TextForgeMode

var code_regions: Array[Array] = [
    [Color.hex(0xb6f1bbff), "`", "`", false],
    [Color.hex(0xb6f1bbff), "```", "```", false],
]

func _initialize_mode() -> Error:
    _initialize_highlighter()
    comment_delimiters.append({
        "start_key": "<!--",
        "end_key": "-->",
        "line_only": false,
    })
    
    return OK


# TODO
func _generate_preview(text: String) -> String:
    return String()


# TODO
func _generate_outline(text: String) -> Array:
    return Array()


func _initialize_highlighter() -> void:
    syntax_highlighter = CodeHighlighter.new()
    syntax_highlighter.number_color = Color.hex(0xb0e0f6ff)
    syntax_highlighter.symbol_color = Color.hex(0xd8b6f6ff)
    syntax_highlighter.function_color = Color.hex(0xffffffff)
    syntax_highlighter.member_variable_color = Color.hex(0xffffffff)
    for region in code_regions:
        syntax_highlighter.add_color_region(region[1], region[2], region[0], region[3])
