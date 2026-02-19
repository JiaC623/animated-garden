extends Control
var point_spacing = 60.0 # Pixels between points
var data_points = [834, 756, 545] # Your data
var chart_height = 160.0
var pixel_font = preload("res://assets/at01.ttf")

@onready var http_point_update = $"../HTTPPointUpdate"
@onready var timer = $"../Timer"
var sensor_url = "https://esp32photo-1dc90-default-rtdb.firebaseio.com/sensor_data.json"


func _on_timer_timeout() -> void:
	http_point_update.request(sensor_url)


func _on_http_point_update_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var parse_result = json.get_data()
		var moist_data = parse_result["moist"]
		new_point_update(moist_data)

func new_point_update(value):
	data_points.append(value)
	update_chart_dimensions()
	await get_tree().process_frame
	scroll_bar_repos()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_chart_dimensions()
	# Wait for Godot to update the UI layout engine
	await get_tree().process_frame
	scroll_bar_repos()

func scroll_bar_repos():
	var scroll_bar = get_parent().get_h_scroll_bar()
	scroll_bar.value = scroll_bar.max_value	
	
func update_chart_dimensions():
	var total_width = data_points.size() * point_spacing
	custom_minimum_size = Vector2(total_width, chart_height)
	queue_redraw()
	
func _draw():
	var max_val = data_points.max() if data_points.max() > 0 else 400.0
	
	if data_points.size() < 2:
		return
	var points = []
	if max_val == 0: max_val = 1 # Avoid division by zero
	
	for i in range(data_points.size()):
		var x = i * point_spacing + 16
		var y = chart_height - ((data_points[i] - 500) / 1700.0 * chart_height) 
		points.append(Vector2(x, y))
	
		var p_top = Vector2(x, 0)
		var p_bottom = Vector2(x, chart_height)
		draw_line(p_top, p_bottom, Color(1, 1, 1, 0.2), 1.0)
		draw_string(pixel_font, p_bottom + Vector2(-15, 10), "Day " + str(i+1), HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
		
	draw_polyline(points, Color.CYAN, 0.5, true)
	for p in points:
		draw_circle(p, 3.0, Color.WHITE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
