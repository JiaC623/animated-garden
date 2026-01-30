extends Node2D
@onready var http_animation = $CanvasLayer/logbook/Button/HTTPRequest
@onready var http_photo = $CanvasLayer/logbook/TakePhoto/HTTPRequest
@onready var photo_textrec = $CanvasLayer/logbook/PhotoTextRec
@onready var moist = $CanvasLayer/logbook/moist
@onready var bright = $CanvasLayer/logbook/bright
@onready var update_point_arr = $Path2D/PathFollow2D

var day_count = 3
var step_distance = 35.0 # Pixels between Day 1, Day 2, etc.
var next_label_x = 77.0 # the 3rd label initial
var spawn_buffer = 100.0 # How far ahead of the camera to spawn
var active_labels = []
var pixel_font = preload("res://assets/at01.ttf")
@onready var data_plot = $dataplot
@onready var camera = $Camera2D

var cnt = 0 # bc 7+35*2 = 77
var log_row_cnt = 0
var log_col_cnt = 0
var existing_log_cnt = 0
var all_buttons = []
var current_page = 0
var items_per_page = 9

var url1 = "https://esp32photo-1dc90-default-rtdb.firebaseio.com/sensor_data.json"
var url2 = "https://esp32photo-1dc90-default-rtdb.firebaseio.com/camera.json"

func _ready():
	$CanvasLayer/logbook/TakePhoto.pressed.connect(_on_button_pressed.bind("photobuttn"))
	
func _process(_delta):
	var camera_right_edge = camera.global_position.x + (get_viewport().size.x / 2)
	if camera_right_edge + spawn_buffer > next_label_x:
		spawn_next_day_label()
	
	var camera_left_edge = camera.global_position.x - (get_viewport().size.x / 2)
	cleanup_old_labels(camera_left_edge)
	
func spawn_next_day_label():
	var label = Label.new()
	var settings = LabelSettings.new()
	settings.font = pixel_font
	settings.font_size = 16
	settings.font_color = Color.WHITE
	label.label_settings = settings
	
	label.text = "Day" + str(day_count)
	#label.global_position = Vector2(next_label_x, 80) 
	label.position = Vector2(next_label_x, 160)
	
	#if day_count == 5:
		#print(label.position.x)
	
	data_plot.add_child(label)
	#add_sibling(label)
	active_labels.append(label)
	next_label_x += step_distance
	day_count += 1
	
func cleanup_old_labels(left_boundary):
	if active_labels.size() > 1:
		var first_label = active_labels[0]
		if first_label.global_position.x < left_boundary - 50: # margin
			active_labels.pop_front()
			first_label.queue_free()
			print("Deleted old Day label to save memory")

func _on_button_pressed(button_name: String) -> void:
	#print(button_name)
	if button_name == "infobuttn":
		#print("infobutton pressed!")
		http_animation.request(url1)
	elif button_name == "photobuttn":
		#print("photobutton pressed!")
		http_photo.request(url2)
	
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, type: String) -> void:
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var parse_result = json.get_data()
		match type:
			"infobuttn":
				var moist_data = parse_result["moist"]
				var bright_data = parse_result["bright"]
				moist.text = str(moist_data)
				bright.text = str(bright_data)
				# -70 to 50, simulated  remap(value, istart, istop, ostart, ostop)
				var moist_adjust = remap(moist_data, 0, 300, -70, 50)
				#print(moist_adjust)
				#print(typeof(moist_adjust))
				if moist_adjust <= -35.0:
					http_photo.request(url2)
				var points: Array[Vector2] = [(Vector2(-65+33*cnt, moist_adjust))]
				# test continuing plot
				#var points: Array[Vector2] = [Vector2(-53, 16), Vector2(-10, -55), Vector2(30, -60), Vector2(60, 16), Vector2(90, 12), Vector2(110, -40)]
				send_data(points)
				cnt += 1
				#if moist_data < 300:
					#myplant.play_animation("falling")
					
			"photobuttn":
				var image_data = Marshalls.base64_to_raw(parse_result)
				display_photo(image_data)
				create_btn(image_data)
				log_row_cnt += 1

	else:
		print("Failed to connect. Response code: ", response_code)

func display_photo(image_data):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(image_data)
	if error != OK:
		error = image.load_png_from_buffer(image_data)
	var texture = ImageTexture.create_from_image(image)
	photo_textrec.texture = texture

func create_btn(image_data):
	var btn = Button.new()
	btn.text = "Log " + str(existing_log_cnt)
	existing_log_cnt += 1
	print(log_col_cnt)
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_font_override("font", pixel_font)
	btn.custom_minimum_size = Vector2(60, 24)
	
	$CanvasLayer.add_child(btn)
	if log_row_cnt >= 3:
		log_col_cnt += 1
		log_row_cnt = 0
	if log_col_cnt >= 3:
		log_col_cnt = 0
		log_row_cnt = 0
	btn.global_position = Vector2(800+62*log_col_cnt, 480+26*log_row_cnt)
	#print(btn.global_position)
	btn.pressed.connect(self._on_dynamic_button_pressed.bind(image_data))
	
	all_buttons.append(btn)
	update_page_visibility()
	
func update_page_visibility():
	var start = current_page * items_per_page
	var end = start + items_per_page
	for i in range(all_buttons.size()):
		all_buttons[i].visible = (i >= start and i < end)
		
#func _on_next_page():
	#pass
	
	
func _on_dynamic_button_pressed(image_data):
	display_photo(image_data)
	print("display log")

func send_data(points:Array[Vector2]):
	get_node("Path2D/PathFollow2D").update_point_array(points)

func _on_timer_timeout() -> void:
	http_animation.request(url1) # Replace with function body.
