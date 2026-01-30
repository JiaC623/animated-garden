extends PathFollow2D
@onready var wait_timer = $Timer
@onready var myplant = $pplant
@onready var trail_line = get_parent().get_node("Line2D")
@export var scroll_threshold = 15.0
@onready var camera = get_parent().get_parent().get_node("Camera2D")

var speed = 100
var is_waiting = false
var check_sta = false
var check_anim = false
var curr_pos = Vector2(0,0)
var anim_name = null
var tar_pos = Vector2(100,100)

var starting_index = 0

func _process(delta):
	update_camera_scroll()
	
	if is_waiting:
		return
		
	progress += speed * delta
	if progress_ratio >= 0.98:
		speed = 0
		return
	else:
		speed = 100
	#speed = 0 if progress_ratio >= 0.98 else 100
	#print(global_position)
	trail_line.add_point(global_position)
	if trail_line.get_point_count() > 600:
		trail_line.remove_point(0)
		
	if not check_sta:
		find_animated_point()
		return
	if not check_anim:
		curr_pos = myplant.get_curr_pos()
		if curr_pos.distance_to(tar_pos) <= 10.0:
			trigger_animation_sequence()
			
	#if not check_anim:
		#curr_pos = myplant.get_curr_pos()
		#waiting_animation(anim_name, tar_pos, curr_pos)
		#
	#if check_sta and check_anim:
		#await get_tree().create_timer(1.0).timeout
		#anim_name = "default"
		#check_anim = not check_anim
		#check_sta = not check_sta
func update_camera_scroll():
	if global_position.x > scroll_threshold:
		var target_x = global_position.x
		camera.global_position.x = lerp(camera.global_position.x, target_x, 0.1)
		
func trigger_animation_sequence():
	is_waiting = true
	myplant.play(anim_name)
	
	print("Animation Started: ", anim_name)
	await myplant.animation_finished
	print("Animation Finished")
	
	check_anim = true
	
	await get_tree().create_timer(1.0).timeout
	
	anim_name = "default"
	check_anim = false
	check_sta = false
	is_waiting = false
	
func update_point_array(new_points: Array[Vector2]):
	if myplant.is_playing():
		await myplant.animation_finished
	var path_node = get_parent()
	for point in new_points:
		var aligned_point = path_node.to_local(point)
		path_node.curve.add_point(aligned_point)
	#print(path_node.curve.point_count)
	#check_and_update(new_points)
	
func check_and_update(new_points: Array[Vector2]):
	if is_waiting:
		var path_node = get_parent()
		for point in new_points:
			path_node.curve.add_point(point)

func find_animated_point():
	var curve_points = get_all_curve_points()
	#print(curve_points.size())
	if starting_index >= curve_points.size()-1:
		print(starting_index, curve_points.size())
		check_sta = true
		return
	for i in range(starting_index, curve_points.size()-1):
		#  and curve_points[i].y > -35
		if curve_points[i].y < 22:
			if curve_points[i+1].y > 22:
				anim_name = "falling"
				tar_pos = curve_points[i+1]
				check_sta = true
				starting_index = i+1
				print("falling anim")
				return
				#
		elif curve_points[i].y > 22:
			if curve_points[i+1].y < 22:
				anim_name = "growing"
				tar_pos = curve_points[i+1]
				check_sta = true
				starting_index = i+1
				print("growing anmi")
				return
		
		#else:
			#starting_index = 99
			#return
	
func waiting_animation(anim_name: String, tar_pos: Vector2, curr_pos: Vector2):
	print("trigger wait anim")
	print(tar_pos)
	print(curr_pos)
	if curr_pos.distance_to(tar_pos) <= 10.0:
		print("in scope")
		#pause_movement(3.0)
		#is_playing = true
		is_waiting = true
		myplant.play(anim_name)
		await myplant.animation_finished
		print("finish anim")
		check_anim = true
		is_waiting = false
			
func get_all_curve_points() -> Array[Vector2]:
	var path_node = get_parent() # This is the Path2D
	var points: Array[Vector2] = []
	# point_count tells you how many points exist
	for i in range(path_node.curve.point_count):
		points.append(path_node.curve.get_point_position(i))
	#print(points)
	return points
			
#func pause_movement(duration: float):
	#is_waiting = true
	#wait_timer.start(duration)
	#print("Stopping...")

#func _on_timer_timeout():
	#is_waiting = false
	#print("Resuming!")


func _on_pplant_animation_finished() -> void:
	pass # Replace with function body.
