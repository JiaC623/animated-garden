extends Sprite2D
@onready var water_drop = $"../Waterdrop"

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


func start_watering_sequence():
	is_dragging = false
	var tween = create_tween()
	
	tween.tween_property(self, "rotation_degrees", -45, 1)
	
	tween.tween_callback(func():
		water_drop.position = Vector2(240, 154) # Adjust this to match your spout
		water_drop.modulate.a = 1.0           # Make it fully opaque
		water_drop.visible = true
	)
	tween.tween_property(water_drop, "position:y", water_drop.position.y+10, 0.8) # Fall 20 pixels
	tween.parallel().tween_property(water_drop, "modulate:a", 0.0, 0.6) # Fade out
	
	tween.tween_property(self, "rotation_degrees", 0, 1)
	tween.tween_callback(func(): water_drop.visible = false)
	
	tween.set_loops(2)
	tween.finished.connect(func(): position = can_home_pos)

func _on_button_button_up() -> void:
	# 200 - 280 x, 87 - 195 y
	if position.x > 200.0 and position.x < 280.0:
		if position.y > 87.0 and position.y < 195.0:
			water_plant()
			start_watering_sequence()
			return
			#print("watercan script water_plant() is called")

	is_dragging = false
	position = can_home_pos
