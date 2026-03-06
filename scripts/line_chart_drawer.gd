extends Control
#@onready var log_btn_signal_receiver = $LogBtns
#var log_btn_signal = false

var point_spacing = 60.0 # Pixels between points
var data_points = [] # Your data
var bright_data_points = []
var chart_height = 160.0
var pixel_font = preload("res://assets/at01.ttf")

var secstr = ""

@onready var http_point_update = $"../HTTPPointUpdate"
@onready var timer = $"../Timer"
var sensor_url = "https://esp32photo-1dc90-default-rtdb.firebaseio.com/sensor_data.json"


func _on_timer_timeout() -> void:
	#http_point_update.request(sensor_url)
	pass


func _on_http_point_update_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var parse_result = json.get_data()
		var moist_data = parse_result["moist"]
		new_point_update(moist_data)


func new_point_update(value):
	# old version
	data_points.append(value)
	update_chart_dimensions()
	await get_tree().process_frame
	scroll_bar_repos()

func new_bright_points_update(value):
	bright_data_points.append(value)
	await get_tree().process_frame

# data = Global.plotdata_logs[i]
func _on_data_received(data):  # dictionary value, array of int
	print("LOG signal received in CHART")
	data_points = data["moist_points"]
	bright_data_points = data["bright_points"]
	secstr = data["ini_sec"]
	update_chart_dimensions()
	await get_tree().process_frame
	scroll_bar_repos()
	# old version
	#for point in data["moist_points"]:  
		#new_point_update(point)
	#for bpoint in data["bright_points"]:
		#new_bright_points_update(bpoint)	

#func _on_update_notice_received():
	#log_btn_signal = true

func _ready() -> void:
	# this stupid but signal from log_btn_container, reload plotdata_logs appended vals, and redraw
	Global.data_submitted.connect(_on_data_received)
	#log_btn_signal_receiver.live_plot_update.connect(_on_update_notice_received)
	
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
	if data_points.size() <= 0: 
		return
	var max_val = data_points.max() if data_points.max() > 0 else 800.0
	
	var points = []
	var measure_gap = 10
	var secint = int(secstr)
	if max_val == 0: max_val = 1 # Avoid division by zero
	
	for i in range(data_points.size()):
		if data_points[i] >= 2500:
			data_points[i] = 2050
		if data_points[i] <= 400:
			data_points[i] = 450
		var x = i * point_spacing + 16
		var y = chart_height - ((data_points[i] - 400) / 2100.0 * chart_height) 
		#print("remap is: " + str((data_points[i] - 400)))
		#print("data_point percentage: " + str((data_points[i] - 400) / 2100.0))
		points.append(Vector2(x, y))
	
		var p_top = Vector2(x, 0)
		var p_bottom = Vector2(x, chart_height)
		draw_line(p_top, p_bottom, Color(1, 1, 1, 0.2), 1.0)
		draw_string(pixel_font, p_bottom + Vector2(-15, 10), "Sec " + str(secint), HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
		secint += measure_gap
		
	draw_polyline(points, Color.WHITE, 0.5, true)
	for p in points:
		draw_circle(p, 3.0, Color.DARK_CYAN)
		
		
	if bright_data_points.size() >= 2:
		var b_points = []
		for i in range(bright_data_points.size()):
			if bright_data_points[i] >= 1900:
				bright_data_points[i] = 1350
			if bright_data_points[i] <= 500:
				bright_data_points[i] = 550
			var x = i * point_spacing + 16
			var y = chart_height - ((bright_data_points[i] - 500) / 1400.0 * chart_height)
			b_points.append(Vector2(x, y))
		
		# Draw the line in Yellow
		draw_polyline(b_points, Color.YELLOW, 0.5, true)
		for p in b_points:
			draw_circle(p, 3.0, Color.GREEN_YELLOW)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
