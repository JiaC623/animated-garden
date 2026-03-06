extends Node

var img_log_entries: Array = []

var http_request: HTTPRequest
var sensor_url = "https://esp32photo-1dc90-default-rtdb.firebaseio.com/sensor_data.json"
var repeat_timer: Timer
var total_time_passed: float = 0.0
const MAX_DURATION: float = 60.0  # 1 min for example
var check_num = 6
var is_prev_loaded = false

var plot_date_arr: Array = []
var sorted_timestamp_arr:Array = []
var plotdata_logs:Array = []
var raw_stamps_arr:Array = []
var sorted_raw_stamps: Array = []

# emitter in log_btn, listener in line_chart
signal data_submitted(data)

var latest_quantity = 0

func start_new_log():
	#var date_time = Time.get_datetime_string_from_system(false,true)
	repeat_timer.start()
	
	# test code only
	#var moist = 510
	#var bright = 700
	#var timestamp = "2026-03-01 23:30"
	#var date_change = 31
	#var ini_sec = 13
	#for i in range(0,6):
		#create_json_obj_list(timestamp, str(ini_sec), moist, bright, plot_date_arr)
		#moist += 50
		#bright += 100
		#ini_sec += 3
		#if i % 2 == 0:
			#var format_date = "2026-03-01 23:%d" % [date_change]
			#timestamp = format_date
			#date_change += 1
		##print(moist, bright, timestamp)
		#sort_timestamp()
		#create_log_with_list()
		#save_entries(plotdata_logs)

func conserve_old_entries():
	plotdata_logs += load_entries()

func save_entries(data_array:Array):
	var file = FileAccess.open("user://data_log.json", FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data_array)
		file.store_string(json_string)
		file.close()
		
func load_entries() -> Array:
	if not FileAccess.file_exists("user://data_log.json"):
		return [] 
	
	var file = FileAccess.open("user://data_log.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		return json.data # This will be your Array of Dictionaries
	else:
		return []
		
func load_img_entries() -> Array:
	if not FileAccess.file_exists("user://img_log.json"):
		return [] 
	
	var file = FileAccess.open("user://img_log.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		return json.data # This will be your Array of Dictionaries
	else:
		return []
	

func add_img_entry(pair_obj: Dictionary, count: int):
	if count <= 0:
		img_log_entries += load_img_pairs()
		is_prev_loaded = true
	img_log_entries.append(pair_obj)
	
	var file = FileAccess.open("user://json_pairs.json", FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(img_log_entries)
		file.store_string(json_string)
		file.close()

func load_img_pairs():
	if not FileAccess.file_exists("user://json_pairs.json"):
		return [] 
	
	var file = FileAccess.open("user://json_pairs.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		return json.data # This will be your Array of Dictionaries
	else:
		return []

func create_json_obj_list(date:String, second: String, moist:int, bright:int, collection:Array):
	var data_set = {
		"date": date,
		"ini_sec": second,
		"moist": moist,
		"bright": bright
	}
	collection.append(data_set)


func create_log_with_list():
	if plot_date_arr.size() == 0: return
	var latest_data = plot_date_arr[plot_date_arr.size() - 1]
	var time = latest_data["date"]
	#var moist_plot_entries = []
	#var bright_plot_entries = []
	
	# get rid of this for loop
	#for time in sorted_timestamp_arr:
		#moist_plot_entries = []
		#bright_plot_entries = []
		#for item in plot_date_arr:
			#if item["date"] == time:
				## loop thru every item to append all values
				#moist_plot_entries.append(item["moist"])
				#bright_plot_entries.append(item["bright"])
	# ---------------
	var existing_entry = null
	# Check if we already have a log entry for this date
	for entry in plotdata_logs:
		if entry["date"] == time:
			# existing_entry now points to entry address
			existing_entry = entry
			break
	
	if existing_entry:
		#print(existing_entry)
		# changing existing entry
		existing_entry["moist_points"].append(latest_data["moist"])
		existing_entry["bright_points"].append(latest_data["bright"])
	# ---------------
			# following is for list of points
			#for point in moist_plot_entries:
				#existing_entry["moist_points"].append(point)
			#for point in bright_plot_entries:
				#existing_entry["bright_points"].append(point)
	# ---------------
	else:
		# Create new entry
		var new_obj = {}
		new_obj["date"] = time
		new_obj["ini_sec"] = latest_data["ini_sec"]
		new_obj["moist_points"] = [latest_data["moist"]]
		new_obj["bright_points"] = [latest_data["bright"]]
		plotdata_logs.append(new_obj)
	# ---------------
		# outside item loop, then put the list for its corresp time
		#if plotdata_logs.size() <= 0:
			#obj["date"] = time
			#obj["moist_points"] = moist_plot_entries.duplicate()
			#obj["bright_points"] = bright_plot_entries.duplicate()
			#plotdata_logs.append(obj.duplicate())
			#moist_plot_entries = []
			#bright_plot_entries = []
			#obj = {}
		#else:
			#for entry in plotdata_logs:
				#if entry.has("date") and entry["date"] == time:
					#entry["moist_points"] = moist_plot_entries.duplicate()
					#entry["bright_points"] = bright_plot_entries.duplicate()
				## new date and its points
				#else:
					#obj["date"] = time
					#obj["moist_points"] = moist_plot_entries.duplicate()
					#obj["bright_points"] = bright_plot_entries.duplicate()
					#plotdata_logs.append(obj.duplicate())
			#moist_plot_entries = []
			#bright_plot_entries = []
			#obj = {}

	#print("the following is from Global")
	#print(plotdata_logs)
	save_entries(plotdata_logs)

func live_checking() -> bool:
	if latest_quantity < plotdata_logs[-1]["moist_points"].size():
		latest_quantity = plotdata_logs[-1]["moist_points"].size()
		return true
	return false


func sort_timestamp():
	#print("it is run here")
	var timestamp_arr = []
	# plot_date_arr is raw datapoint obj array
	# loop thru raw to append all date, doesnt matter repeated
	for item in plot_date_arr:
		timestamp_arr.append(item["date"])
	#print(timestamp_arr)
	for item in timestamp_arr:
		if not sorted_timestamp_arr.has(item):
			sorted_timestamp_arr.append(item)
	#var ref_item = ""
	#if sorted_timestamp_arr.size() <= 0:
		##sorted_timestamp_arr.append(ref_item)
		#sorted_timestamp_arr.append(timestamp_arr[0])
		#ref_item = timestamp_arr[0]
	#for item in timestamp_arr:
		#if item != ref_item:
			#sorted_timestamp_arr.append(item)
			#ref_item = item
	#print("sorted timestamp array is")
	#print(sorted_timestamp_arr)	

#func sort_raw_stamps():
	#for item in raw_stamps_arr:
		#if not sorted_raw_stamps.has(item):
			#sorted_raw_stamps.append(item)
	

# this is for sensor data storage
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200: print("Global water request successful")
	var json = JSON.parse_string(body.get_string_from_utf8())
	#var group_num = json["group"]
	#if group_num < check_num:
		#print(check_num)
		#print(group_num)
	# --------------
	var timestamp = Time.get_datetime_string_from_system().left(16).replace("T", " ")
	var ini_sec = Time.get_datetime_string_from_system().substr(16, 5)
	var moist = json["moist"]
	var bright = json["bright"]
	# append dictionary to array
	create_json_obj_list(timestamp, ini_sec, moist, bright, plot_date_arr)
		#check_num -= 1
		#print("small gnum, run")
		
		#print("all js objs are")
		#print(plot_date_arr)
	sort_timestamp()
	create_log_with_list()

func _on_timer_timeout():
	total_time_passed += repeat_timer.wait_time
	if total_time_passed >= MAX_DURATION:
		repeat_timer.stop()
		print("1 minutes reached. Stopping requests.")
		check_num = 5
		total_time_passed = 0.0
	else:
		http_request.request(sensor_url)
		print("water button sensor requested")


func _ready() -> void:
	conserve_old_entries()
	latest_quantity = plotdata_logs[-1]["moist_points"].size()
	
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	repeat_timer = Timer.new()
	repeat_timer.wait_time = 10.0
	#repeat_timer.autostart = false
	add_child(repeat_timer)
	repeat_timer.timeout.connect(_on_timer_timeout)




## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
