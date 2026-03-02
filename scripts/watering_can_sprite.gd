extends Sprite2D

var is_dragging = false
var drag_offset = Vector2(0,0)
var can_home_pos = Vector2(336,183)

signal water_can_in_area(water_yes)

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dragging:
		position = get_global_mouse_position() - drag_offset

# drag water can
# enter area2d
# mouse up
# within area2d -> send signal
func water_plant():
	water_can_in_area.emit(true)
	#print("water signal emitted")

func _on_button_button_down() -> void:
	is_dragging = true
	drag_offset = get_global_mouse_position() - global_position


func _on_button_button_up() -> void:
	# 200 - 280 x, 87 - 195 y
	if position.x > 200.0 and position.x < 280.0:
		if position.y > 87.0 and position.y < 195.0:
			water_plant()
			#print("watercan script water_plant() is called")

	is_dragging = false
	position = can_home_pos
