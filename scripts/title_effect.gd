extends RichTextLabel

var time := 0.0
var text_src = "Rémanance"

func _ready():
	bbcode_enabled = true

func _process(delta):
	time += delta
	var result = ""
	
	for i in text_src.length():
		var hue = fmod((float(i) / text_src.length()) + time * 0.2, 1.0)
		var color = Color.from_hsv(hue, 0.9, 1.0)
		result += "[color=#%s]%s[/color]" % [color.to_html(false), text_src[i]]
	
	text = result
