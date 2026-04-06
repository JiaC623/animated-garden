extends Node2D
@onready var input_popup = $CanvasLayer/InputPopup
@onready var line_edit = $CanvasLayer/InputPopup/LineEdit
var custom_font = load("res://assets/at01.ttf")

# 1. When the main "Add" button is pressed
func _on_add_button_pressed():
	#input_popup.show()
	#line_edit.clear() # Clear previous text
	#line_edit.grab_focus() # Automatically puts the cursor in the box
	
	var dialog = AcceptDialog.new()
	dialog.min_size = Vector2i(200, 100)
	dialog.add_theme_font_override("title_font", custom_font)
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

func _on_submit_pressed() -> void:
	var user_text = line_edit.text
	
	if user_text != "":
		print("User entered: ", user_text)
		# Call your function to save this to JSON here
		
		input_popup.hide()
	else:
		print("Input is empty!")
