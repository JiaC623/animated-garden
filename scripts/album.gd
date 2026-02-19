extends Node2D
@onready var displayLabel = $Label
@onready var photo_textrec = $MarginContainer/HBoxContainer/TextureRect
@onready var log_container = $MarginContainer/HBoxContainer/LogContainer
@onready var date_display_label = $MarginContainer/HBoxContainer/PicInfoContainer/Date
@onready var weather_display_label = $MarginContainer/HBoxContainer/PicInfoContainer/Weather
var pixel_font = preload("res://assets/at01.ttf")

var btn_spacing = 16
var log_row_cnt = 0
var log_col_cnt = 0

func load_all_pictures():
	var cnt = 0
	for entry in Global.log_entries:
		var btn = Button.new()
		btn.text = "Log " + str(cnt)
		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_font_override("font", pixel_font)
		btn.custom_minimum_size = Vector2(16, 10)
		
		log_container.add_child(btn)
		btn.global_position = Vector2(10 + 10*log_col_cnt, 10 + 16*log_row_cnt)
		log_row_cnt += 1
		btn.pressed.connect(self._on_dynamic_button_pressed.bind(entry, Global.date_entries[cnt]))
		cnt += 1
		
		
func display_date(date_data):
	date_display_label.add_theme_font_override("font", pixel_font)
	date_display_label.add_theme_font_size_override("font_size", 16)
	date_display_label.text = date_data

#func create_btn(image_data):
	#var btn = Button.new()
	#btn.text = "Log " + str(existing_log_cnt)
	#existing_log_cnt += 1
	#print(log_col_cnt)
	#btn.add_theme_font_size_override("font_size", 16)
	#btn.add_theme_font_override("font", pixel_font)
	#btn.custom_minimum_size = Vector2(60, 24)
	#
	#$CanvasLayer.add_child(btn)
	#if log_row_cnt >= 3:
		#log_col_cnt += 1
		#log_row_cnt = 0
	#if log_col_cnt >= 3:
		#log_col_cnt = 0
		#log_row_cnt = 0
	#btn.global_position = Vector2(800+62*log_col_cnt, 480+26*log_row_cnt)
	##print(btn.global_position)
	#btn.pressed.connect(self._on_dynamic_button_pressed.bind(image_data))
	#
	#all_buttons.append(btn)
	#update_page_visibility()

func _on_dynamic_button_pressed(image_data, date_data):
	display_photo(image_data)
	display_date(date_data)
	#print("display log")

func display_photo(image_data):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(image_data)
	if error != OK:
		error = image.load_png_from_buffer(image_data)
	var texture = ImageTexture.create_from_image(image)
	photo_textrec.texture = texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_all_pictures()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
