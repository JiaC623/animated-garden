extends Sprite2D
@onready var flash_light = $Flashlight
@onready var shines = [$"../albumjump/Sparkle", $"../albumjump/Sparkle2", $"../albumjump/Sparkle3"]

var is_dragging = false
var drag_offset = Vector2(0,0)
var cam_home_pos = Vector2(37,244)

signal take_pic_in_area(bool_val)

func _ready() -> void:
	flash_light.show_behind_parent = true

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


func play_sparkle_effect():
	for s in shines:
		var delay = randf_range(0.0, 1)
		var t = create_tween().set_parallel(true)
		s.scale = Vector2.ZERO
		t.tween_interval(delay)
		t.chain().tween_property(s, "scale", Vector2(0.8, 0.8), 1)
		t.chain().tween_property(s, "scale", Vector2.ZERO, 0.3)


func start_camera_sequence():
	is_dragging = false
	flash_light.visible = false
	# relative coordinates as child
	flash_light.position = Vector2(8, -9)
	var main_tween = create_tween()
	main_tween.tween_callback(func(): start_flicker())
	# mainly used for camera to stay put for 5 sec
	main_tween.tween_interval(1.0)
	main_tween.tween_callback(func(): 
		flash_light.visible = true
		flash_light.scale = Vector2(1.1, 1.1)
	)
	# a bit longer flash
	main_tween.tween_interval(0.8)
	main_tween.tween_callback(func(): 
		flash_light.visible = false
		flash_light.scale = Vector2(1, 1)
		play_sparkle_effect()
	)
	main_tween.tween_property(self, "position", cam_home_pos, 0.5)


func start_flicker():
	var flicker_tween = create_tween()
	flicker_tween.set_loops(3)
	
	flicker_tween.tween_callback(func(): flash_light.visible = true)
	flicker_tween.tween_interval(0.1) # Duration of the light burst
	flicker_tween.tween_callback(func(): flash_light.visible = false)
	flicker_tween.tween_interval(0.1) # Wait before next flash

func _on_button_button_up() -> void:
	# 200 - 280 x, 87 - 195 y
	if position.x > 200.0 and position.x < 280.0:
		if position.y > 87.0 and position.y < 195.0:
			take_photo()
			start_camera_sequence()
			return
			#print("cam script take_photo() is called")

	is_dragging = false
	position = cam_home_pos
