extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(3):
		var btn = Button.new()
		btn.custom_minimum_size.y = 10
		btn.text = "damn %d" % [i]
		add_child(btn)
		print("working")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
