extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _draw():
	var max_val = 1800 # Match this to your data logic
	var min_val = 500
	var steps = 5
	var increment = (max_val - min_val) / steps
	var font = preload("res://assets/at01.ttf")
	
	for i in range(0, steps + 1):
		var val = min_val + increment * i
		var y = 160.0 - (float(i) / steps * 160.0)
		draw_string(font, Vector2(0, y + 5), str(val), HORIZONTAL_ALIGNMENT_RIGHT, 20, 16)
		#print(Vector2(0, y + 5))
		# Small horizontal tick mark
		draw_line(Vector2(25, y), Vector2(35, y), Color.WHITE, 1.0)
