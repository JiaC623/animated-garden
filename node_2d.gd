extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var date_time = Time.get_datetime_string_from_system(false,true)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
