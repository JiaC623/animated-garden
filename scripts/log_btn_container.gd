extends VBoxContainer
#@onready var line_draw_ctl = $"../../VBoxContainer/HBoxContainer/ScrollContainer/LineChartDrawer"
var pixel_font = preload("res://assets/at01.ttf")
var check_data = 0


func create_log_btn():
	# Array of Dictionaries
	var existing_plotdata = Global.load_entries()
	if existing_plotdata.size() == 0: return
	print("this below is from chart_log_btn")
	print(existing_plotdata)
	for item in existing_plotdata:  # [0]["moist_points"] any object, int array
		print(item["moist_points"])
		var btn = Button.new()
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size.x = 60
		btn.text = item["date"]
		#btn.text = "this si long awnd wajiodjwaoij"
		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_font_override("font", pixel_font)
		btn.pressed.connect(self._on_generated_button_pressed.bind(item))
		add_child(btn)
		

func update_log_btn():
	for i in range(check_data+1, Global.plotdata_logs.size()+1):
		var btn = Button.new()
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size.x = 60
		btn.text = Global.plotdata_logs[i]["date"]
		#btn.text = "this si long awnd wajiodjwaoij"
		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_font_override("font", pixel_font)
		btn.pressed.connect(self._on_generated_button_pressed.bind(Global.plotdata_logs[i]))
		add_child(btn)
		

# signal declared in Global
func _on_generated_button_pressed(info):
	Global.data_submitted.emit(info)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_data = Global.plotdata_logs.size()
	create_log_btn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(Global.plotdata_logs.size())
	if check_data < Global.plotdata_logs.size(): 
		update_log_btn()
