extends VBoxContainer

#func _ready() -> void:
	#pass # Replace with function body.

#func _process(delta: float) -> void:
	#pass

func _draw():
	draw_set_transform(Vector2(0, 6), 0, Vector2(1, 1))
	var max_val = 100 # Match this to your data logic  3500,500
	var min_val = 0
	var steps = 5
	var increment = (max_val - min_val) / steps
	var font = preload("res://assets/at01.ttf")
	
	for i in range(0, steps + 1):
		var val = 100 - increment * i
		var y = float(i) / steps * 154.0
		#upside down
		#var val = max_val - increment * i
		#var y = 160.0 - (float(i) / steps * 160.0)
		draw_string(font, Vector2(0, y + 5), "%d%%" % val, HORIZONTAL_ALIGNMENT_RIGHT, 25, 16)
		#print(Vector2(0, y + 5))
		# Small horizontal tick mark
		draw_line(Vector2(25, y), Vector2(35, y), Color.WHITE, 1.0)
