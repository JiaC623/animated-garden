extends Area2D
var has_mouse_focus = false

func _on_mouse_entered():
	print("Cursor entered the area!")

func _on_mouse_exited():
	print("Cursor left the area!")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
