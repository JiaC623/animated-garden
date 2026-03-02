extends Sprite2D

var is_dragging = false
var drag_offset = Vector2(0,0)
var cam_home_pos = Vector2(37,244)

signal take_pic_in_area(bool_val)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dragging:
		position = get_global_mouse_position() - drag_offset

# just emitter func, not used anywhere
func take_photo():
	take_pic_in_area.emit(true)
	#print("cam signal emitted")


func _on_button_button_down() -> void:
	is_dragging = true
	drag_offset = get_global_mouse_position() - global_position


func _on_button_button_up() -> void:
	# 200 - 280 x, 87 - 195 y
	if position.x > 200.0 and position.x < 280.0:
		if position.y > 87.0 and position.y < 195.0:
			take_photo()
			#print("cam script take_photo() is called")

	is_dragging = false
	position = cam_home_pos
