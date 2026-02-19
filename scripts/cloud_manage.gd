extends Node2D

@export var cloud_scene: PackedScene
@export var spawn_delay: Vector2 = Vector2(2.0, 8.0)
@export var speed_range: Vector2 = Vector2(20.0, 70.0)
@export var y_range: Vector2 = Vector2(25.0, 110.0)

var start_x: float = 450.0
var end_x: float = -40.0
#@export var cloud_start_pos: Vector2 = Vector2(450, 55)
#@export var cloud_end_pos: Vector2 = Vector2(-40, 55)

func spawn_cloud_loop():
	while true:
		start_cloud_movement()
		# Wait for a random amount of time before the next cloud
		await get_tree().create_timer(randf_range(spawn_delay.x, spawn_delay.y)).timeout
		

func start_cloud_movement():
	var new_cloud = cloud_scene.instantiate()
	
	new_cloud.position = Vector2(start_x, randf_range(y_range.x, y_range.y))
	new_cloud.speed = randf_range(speed_range.x, speed_range.y)
	new_cloud.end_x = end_x
	
	add_child(new_cloud)
	#print("Cloud spawned at: ", new_cloud.global_position)
	#print("Cloud created at path: ", new_cloud.get_path())
	
	#var tween = create_tween()
	#var duration = cloud_start_pos.distance_to(cloud_end_pos) / cloud_speed
	#tween.tween_property(self, "position", cloud_end_pos, duration)
	#tween.finished.connect(start_cloud_movement)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_cloud_loop()
