extends Sprite2D

var speed: float = 0.0
var end_x: float = 0.0

func _process(delta):
	position.x -= speed * delta
	
	# Self-destruct once it's off-screen/past the window
	if position.x < end_x:
		queue_free()
