extends Node2D
@onready var http_lamp = $lampTogggle/HTTPRequest
@onready var http_prephoto = $snaphoto/HTTPRequest
@onready var http_syncheck = $snaphoto/HTTPRequest2
@onready var http_disphoto = $snaphoto/HTTPDisplay
@onready var popup_window = $popup
@onready var actual_picture = $popup/actualPhoto
@onready var ok_button = $popup/okbutton

var normal_cursor = load("res://assets/pointer.png")
var active_mode_cursor = load("res://assets/cam.png")
var hover_confirm_cursor = load("res://assets/spark.png")
var is_in_selection_mode = false

var lampOnQuery = JSON.stringify({"lamp_sta": 1})
var lampOffQuery = JSON.stringify({"lamp_sta": 0})
var lampHeaders = ["Content-Type: application/json"]
const LIGHT_REQ = "https://esp32photo-1dc90-default-rtdb.firebaseio.com/photo_request.json"

var last_sync_time = 0
var query = JSON.stringify({"action_req": 1})
var phoHeaders = ["Content-Type: application/json"]
const PHOREQ_URL = "https://esp32photo-1dc90-default-rtdb.firebaseio.com/photo_request.json"
const SYNC_URL = "https://esp32photo-1dc90-default-rtdb.firebaseio.com/last_update.json"
const PHOGET_URL = "https://esp32photo-1dc90-default-rtdb.firebaseio.com/camera.json"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(normal_cursor)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_page_jump_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/data_plot.tscn") # Replace with function body.


func _on_lamp_togggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		http_lamp.request(LIGHT_REQ, lampHeaders, HTTPClient.METHOD_PATCH, lampOnQuery)
		print("The light is now ON")
	else:
		http_lamp.request(LIGHT_REQ, lampHeaders, HTTPClient.METHOD_PATCH, lampOffQuery)
		print("light is OFF")


func _finish_action():
	is_in_selection_mode = false
	Input.set_custom_mouse_cursor(normal_cursor)
	print("Action complete: Cursor reset.")

func _on_snaphoto_pressed() -> void:
	if is_in_selection_mode:
		_finish_action()
	else:
		return
		
	http_prephoto.request(PHOREQ_URL, phoHeaders, HTTPClient.METHOD_PATCH, query)
	await http_prephoto.request_completed
	var photo_ready = false
	while not photo_ready:
		await get_tree().create_timer(0.5).timeout
		http_syncheck.request(SYNC_URL)
		var resSync = await http_syncheck.request_completed
		var new_time = int(resSync[3].get_string_from_utf8())
		
		if new_time > last_sync_time:
			last_sync_time = new_time
			photo_ready = true
	http_disphoto.request(PHOGET_URL + "?t=" + str(Time.get_ticks_msec()))

func display_photo(image_data):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(image_data)
	if error != OK:
		error = image.load_png_from_buffer(image_data)
	var texture = ImageTexture.create_from_image(image)
	actual_picture.texture = texture
	#fade-in effect
	var tween = create_tween()
	tween.tween_property(actual_picture, "modulate:a", 1.0, 0.5)
	#the close button
	popup_window.visible = true
	ok_button.visible = true
	ok_button.modulate.a = 1.0
	
	Global.add_entry(image_data)

func _on_okbutton_toggled(toggled_on: bool) -> void:
	#print("toggled button")
	var tween = create_tween()
	tween.tween_property(actual_picture, "modulate:a", 0.0, 0.1)
	tween.tween_property(ok_button, "modulate:a", 0.0, 0.1)
	tween.finished.connect(func():
		#print("triggered tween finish")
		ok_button.visible = false
		popup_window.visible = false
	)
		

func _on_http_display_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var parse_result = json.get_data()
		var image_data = Marshalls.base64_to_raw(parse_result)
		display_photo(image_data)


func _on_change_coursor_cam_pressed() -> void:
	is_in_selection_mode = true
	Input.set_custom_mouse_cursor(active_mode_cursor)


func _on_snaphoto_mouse_entered() -> void:
	if is_in_selection_mode:
		Input.set_custom_mouse_cursor(hover_confirm_cursor)

func _on_snaphoto_mouse_exited() -> void:
	if is_in_selection_mode:
		Input.set_custom_mouse_cursor(active_mode_cursor)


func _on_albumjump_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/album.tscn")
