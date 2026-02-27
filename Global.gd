extends Node

var log_entries: Array = []
var date_entries: Array = []


var http_request: HTTPRequest
var sensor_url = "https://esp32photo-1dc90-default-rtdb.firebaseio.com/sensor_data.json"
var repeat_timer: Timer
var total_time_passed: float = 0.0
const MAX_DURATION: float = 36.0  # 1 min for example
var check_num = 6

var plot_date_arr: Array = []
var sorted_timestamp_arr:Array = []
var plotdata_logs:Array = []

signal data_submitted(data)

func start_new_log():
	#var date_time = Time.get_datetime_string_from_system(false,true)
	repeat_timer.start()


func add_entry(new_text: PackedByteArray):
	log_entries.append(new_text)
	
	var datetime = Time.get_date_string_from_system()
	date_entries.append(datetime)

func create_json_obj_list(date:String, moist:int, bright:int, collection:Array):
	var data_set = {
		"date": date,
		"moist": moist,
		"bright": bright
	}
	collection.append(data_set)


func create_log_with_list():
	var moist_plot_entries = []
	var bright_plot_entries = []
	var obj = {}
	
	
	for time in sorted_timestamp_arr:
		for item in plot_date_arr:
			if item["date"] == time:
				# loop thru every item to append all values
				moist_plot_entries.append(item["moist"])
				bright_plot_entries.append(item["bright"])
		# outside item loop, then put the list for its corresp time
		if plotdata_logs.size() <= 0:
			obj["date"] = time
			obj["moist_points"] = moist_plot_entries.duplicate()
			obj["bright_points"] = bright_plot_entries.duplicate()
			plotdata_logs.append(obj.duplicate())
			moist_plot_entries = []
			bright_plot_entries = []
			obj = {}
		else:
			for entry in plotdata_logs:
				if entry.has("date") and entry["date"] == time:
					entry["moist_points"] = moist_plot_entries.duplicate()
					entry["bright_points"] = bright_plot_entries.duplicate()
				# new date and its points
				else:
					obj["date"] = time
					obj["moist_points"] = moist_plot_entries.duplicate()
					obj["bright_points"] = bright_plot_entries.duplicate()
					plotdata_logs.append(obj.duplicate())
			moist_plot_entries = []
			bright_plot_entries = []
			obj = {}

	print("the following is from Global")
	print(plotdata_logs)



func sort_timestamp():
	#print("it is run here")
	var timestamp_arr = []
	for item in plot_date_arr:
		timestamp_arr.append(item["date"])
	#print(timestamp_arr)
	var ref_item = timestamp_arr[0]
	if sorted_timestamp_arr.size() <= 0:
		sorted_timestamp_arr.append(ref_item)
	for item in timestamp_arr:
		if item != ref_item:
			sorted_timestamp_arr.append(item)
			ref_item = item
	#print(sorted_timestamp_arr)

# this is for sensor data storage
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var group_num = json["group"]
	if group_num < check_num:
		#print(check_num)
		#print(group_num)
		var timestamp = Time.get_datetime_string_from_system().left(13).replace("T", " ")
		var moist = json["moist"]
		var bright = json["bright"]
		create_json_obj_list(timestamp, moist, bright, plot_date_arr)
		check_num -= 1
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
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	repeat_timer = Timer.new()
	repeat_timer.wait_time = 3.0
	#repeat_timer.autostart = false
	add_child(repeat_timer)
	repeat_timer.timeout.connect(_on_timer_timeout)




## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
