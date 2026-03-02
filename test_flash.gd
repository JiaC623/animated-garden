extends Node2D
@onready var event_timer = $Timer

var save_list = [
	{
		"date": "2026-03-01",
		"yellow": [10, 20, 30],
		"green": [1, 2, 3]
	},
	{
		"date": "2026-03-02",
		"yellow": [40, 50, 60],
		"green": [4, 5, 6]
	}
]


func save_function(data_array: Array):
	var file = FileAccess.open("user://data_log.json", FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data_array)
		file.store_string(json_string)
		file.close()


func load_entries() -> Array:
	if not FileAccess.file_exists("user://data_log.json"):
		return [] # Return empty array if no file exists
	
	var file = FileAccess.open("user://data_log.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		return json.data # This will be your Array of Dictionaries
	else:
		return []


#func _ready() -> void:
	#pass
	#save_function(save_list)

#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


#func _on_timer_timeout() -> void:
	#var get_file = load_entries()
	#var new_entry = {
		#"date": "2026-04-09",
		#"yellow": [34,677,34],
		#"green": [90,23,1]
	#}
	#get_file.append(new_entry)
	#save_function(get_file)
	#print(load_entries())
