extends Node2D
@onready var plant_name = $MarginContainer/HBoxContainer/HBoxContainer/VBoxContainer/PlantName2
@onready var water_freq = $MarginContainer/HBoxContainer/HBoxContainer/VBoxContainer/WaterFreq2
@onready var tot_days = $MarginContainer/HBoxContainer/HBoxContainer/VBoxContainer/TotDays2
@onready var issue_box = $MarginContainer/HBoxContainer/HBoxContainer/VBoxContainer/IssueScroll/HBoxContainer
@onready var soil_box = $MarginContainer/HBoxContainer/HBoxContainer/VBoxContainer/SoilScroll/HBoxContainer
@onready var pest_box = $MarginContainer/HBoxContainer/HBoxContainer/VBoxContainer/PestScroll/HBoxContainer
@onready var plant_box = $MarginContainer/HBoxContainer/HBoxContainer/HFlowContainer
const JSON_PLANT_PATH = "user://plant_data.json"
var pixel_font = preload("res://assets/at01.ttf")
var plant_data_prep = []
var curr_cnt = 0
var selected_index = null

var soil_input: LineEdit
var day_input: LineEdit

var init_data = [
	{
		"plantName": "Rubber Plant",
		"waterFreq": "every 1 - 2 weeks",
		"totDays": 5,
		"issueIden": [],
		"soil": ["Peat moss", "Perlite"],
		"pests": ["Aphids"]
	},
	{
		"plantName": "Spider Plant",
		"waterFreq": "every 1 week",
		"totDays": 0,
		"issueIden": [],
		"soil": [],
		"pests": []
	},
	{
		"plantName": "Monstera Leaf",
		"waterFreq": "every 10 days",
		"totDays": 2,
		"issueIden": ["Yellow leaves"],
		"soil": ["Pine bark"],
		"pests": []
	}
]


func get_plant_data() -> Array:
	var file = FileAccess.open(JSON_PLANT_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		if typeof(json.data) == TYPE_ARRAY:
			return json.data
		else:
			print("JSON data is not an array.")
			return []
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return []


func add_new_plant(new_plant_data: Dictionary):
	plant_data_prep.append(new_plant_data)
	
	var all_plants = []
	if FileAccess.file_exists(JSON_PLANT_PATH):
		var file = FileAccess.open(JSON_PLANT_PATH, FileAccess.READ)
		var json = JSON.new()
		var parse_err = json.parse(file.get_as_text())
		file.close()
		
		if parse_err == OK:
			all_plants = json.data # Get the current list
		else:
			print("Error parsing existing JSON: ", json.get_error_message())
		
		all_plants.append(new_plant_data)
		var file_write = FileAccess.open(JSON_PLANT_PATH, FileAccess.WRITE)
		if file_write:
			var json_string = JSON.stringify(all_plants, "\t")
			file_write.store_string(json_string)
			file_write.close()
			print("New plant appended and file saved.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not FileAccess.file_exists(JSON_PLANT_PATH):
		var json_string = JSON.stringify(init_data)
		var file = FileAccess.open(JSON_PLANT_PATH, FileAccess.WRITE)
		if file:
			file.store_string(json_string)
			file.close()
			print("Initialization: New JSON file created at ", JSON_PLANT_PATH)
	else:
		plant_data_prep = get_plant_data()
		curr_cnt = plant_data_prep.size()
		print("File already exists, stores %d plants." % plant_data_prep.size())
		if curr_cnt > 3:
			for i in range(3, plant_data_prep.size()):
				create_custom_texture_button(i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if curr_cnt < plant_data_prep.size():
		for i in range(curr_cnt, plant_data_prep.size()):
			print("new added plant index is " + str(i))
			create_custom_texture_button(i)
		curr_cnt = plant_data_prep.size()


func _on_add_button_pressed() -> void:
	var dialog = AcceptDialog.new()
	dialog.min_size = Vector2i(200, 100)
	dialog.add_theme_font_override("title_font", pixel_font)
	dialog.title = "Enter Plant Name"
	
	# Create the input space
	var input = LineEdit.new()
	dialog.add_child(input)
	
	# Connect the 'confirmed' signal (when OK is pressed)
	dialog.confirmed.connect(self._on_dialog_confirmed.bind(input))
	
	add_child(dialog)
	dialog.popup_centered()

func _on_dialog_confirmed(input_node):
	print("Saved: ", input_node.text)
	if input_node.text.is_empty():
		return 
	var new_plant = {
		"plantName": input_node.text,
		"waterFreq": "",
		"soil": [],
		"totDays": 0,
		"issueIden": [],
		"pests": []
	}
	add_new_plant(new_plant)
	input_node.clear()

func create_custom_texture_button(index: int):
	var btn = TextureButton.new()
	var my_texture = load("res://assets/rand plant.png")
	btn.texture_normal = my_texture
	btn.pressed.connect(_on_button_pressed.bind(index))
	plant_box.add_child(btn)

func _on_button_pressed(button_index: int):
	selected_index = button_index
	clear_children(issue_box)
	clear_children(soil_box)
	clear_children(pest_box)
	plant_name.text = plant_data_prep[button_index].plantName
	water_freq.text = plant_data_prep[button_index].waterFreq
	tot_days.text = str(plant_data_prep[button_index].totDays)
	var issue_items = plant_data_prep[button_index].issueIden
	for issue in issue_items:
		create_label("%s" % issue, issue_box)
	var soil_items = plant_data_prep[button_index].soil
	for s in soil_items:
		create_label("%s" % s, soil_box)
	var pest_items = plant_data_prep[button_index].pests
	for p in pest_items:
		create_label("%s" % p, pest_box)


func _on_edit_button_pressed() -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Edit Plant Info"
	dialog.size = Vector2i(300, 200)
	
	var vbox = VBoxContainer.new()
	dialog.add_child(vbox)
	day_input = create_input(vbox, "Days: ")
	soil_input = create_input(vbox, "Soil Type: ")
	dialog.confirmed.connect(_on_dialog_submitted)
	add_child(dialog)
	dialog.popup_centered()

func create_input(parent, label_text):
	var label = Label.new()
	label.text = label_text
	parent.add_child(label)
	
	var input = LineEdit.new()
	parent.add_child(input)
	return input

func _on_dialog_submitted():
	plant_data_prep[selected_index].soil.append(soil_input.text)
	plant_data_prep[selected_index].totDays = day_input.text
	update_plant_dictionary()

func update_plant_dictionary():
	var json_string = JSON.stringify(plant_data_prep)
	var file = FileAccess.open(JSON_PLANT_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
	
	tot_days.text = str(plant_data_prep[selected_index].totDays)
	create_label(soil_input.text, soil_box)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func create_label(text_content: String, box):
	var new_label = Label.new()
	new_label.text = text_content
	new_label.add_theme_font_size_override("font_size", 16)
	new_label.add_theme_font_override("font", pixel_font)
	new_label.add_theme_color_override("font_color", Color("1a642d"))
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color("dc8d7eff") # Your background color
	stylebox.content_margin_left = 3   # Padding
	stylebox.content_margin_right = 3
	
	# Apply it to the 'normal' style of the label
	new_label.add_theme_stylebox_override("normal", stylebox)
	box.add_child(new_label)


func clear_children(node: Node):
	for child in node.get_children():
		child.queue_free()


func _on_rubber_plant_pressed() -> void:
	selected_index = 0
	clear_children(issue_box)
	clear_children(soil_box)
	clear_children(pest_box)
	plant_name.text = plant_data_prep[0].plantName
	water_freq.text = plant_data_prep[0].waterFreq
	tot_days.text = str(plant_data_prep[0].totDays)
	var issue_items = plant_data_prep[0].issueIden
	for issue in issue_items:
		create_label("%s" % issue, issue_box)
	var soil_items = plant_data_prep[0].soil
	for s in soil_items:
		create_label("%s" % s, soil_box)
	var pest_items = plant_data_prep[0].pests
	for p in pest_items:
		create_label("%s" % p, pest_box)

func _on_spider_plant_pressed() -> void:
	selected_index = 1
	clear_children(issue_box)
	clear_children(soil_box)
	clear_children(pest_box)
	plant_name.text = plant_data_prep[1].plantName
	water_freq.text = plant_data_prep[1].waterFreq
	tot_days.text = str(plant_data_prep[1].totDays)
	var issue_items = plant_data_prep[1].issueIden
	for issue in issue_items:
		create_label("%s" % issue, issue_box)
	var soil_items = plant_data_prep[1].soil
	for s in soil_items:
		create_label("%s" % s, soil_box)
	var pest_items = plant_data_prep[1].pests
	for p in pest_items:
		create_label("%s" % p, pest_box)

func _on_monstera_plant_pressed() -> void:
	selected_index = 2
	clear_children(issue_box)
	clear_children(soil_box)
	clear_children(pest_box)
	plant_name.text = plant_data_prep[2].plantName
	water_freq.text = plant_data_prep[2].waterFreq
	tot_days.text = str(plant_data_prep[2].totDays)
	var issue_items = plant_data_prep[2].issueIden
	for issue in issue_items:
		create_label("%s" % issue, issue_box)
	var soil_items = plant_data_prep[2].soil
	for s in soil_items:
		create_label("%s" % s, soil_box)
	var pest_items = plant_data_prep[2].pests
	for p in pest_items:
		create_label("%s" % p, pest_box)
