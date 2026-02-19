extends Node

var log_entries: Array = []
var date_entries: Array = []

func add_entry(new_text: PackedByteArray):
	log_entries.append(new_text)
	
	var datetime = Time.get_date_string_from_system()
	date_entries.append(datetime)


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
