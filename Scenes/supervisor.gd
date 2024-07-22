extends Node

# Upgrade vars
var bubble_active = false
var bubble_shockwave = false
var bubble_health = 0

var distance_skip = 0

var health_increase = 0
var health_buff_activated = false

var boost_active = false
var max_boost_uses = 0
var boosts_left = max_boost_uses
var boost_invincible = false

var current_cash = 0
var current_distance = 0
var highscore_distance = 0

var blaster_unlocked = false
var blaster_cost = 10000

# Level vars
var next_event = ""

var max_level = 3

var bubble_level = 0
var bubble_next_cost = 500

var distance_level = 0
var distance_next_cost = 500

var health_level = 0
var health_next_cost = 1500

var boost_level = 0
var boost_next_cost = 250

var code_key = ""
var num_code_inputs = 12
var code_collected = ""

var version = 0.5
var winner = false

# Debug/Setting vars
var fullscreen_on = true
var current_resolution = "1152x648"
var display_fps = true
var shader_cached = false
var master_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
var bgm_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGMs"))
var sfx_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound Effects"))
var vl_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Voice Lines"))

func _ready():
	Save.data_loaded.connect(load_all)

func set_master_db(value):
	var bus_index = AudioServer.get_bus_index("Master")
	master_db = value
	AudioServer.set_bus_volume_db(bus_index, value)

func set_bgm_db(value):
	var bus_index = AudioServer.get_bus_index("BGMs")
	bgm_db = value
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func set_sfx_db(value):
	var bus_index = AudioServer.get_bus_index("Sound Effects")
	sfx_db = value
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func set_vl_db(value):
	var bus_index = AudioServer.get_bus_index("Voice Lines")
	vl_db = value
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func save_all():
	var data = [
	version, fullscreen_on, 
	master_db, bgm_db, vl_db, sfx_db, 
	current_resolution, current_cash, bubble_level, 
	bubble_next_cost, distance_level, distance_next_cost,
	health_level, health_next_cost, boost_level, boost_next_cost,
	blaster_unlocked, highscore_distance, code_collected, code_key,
	display_fps, winner, shader_cached
	]
	var game_data_keys = Save.game_data.keys()
	for i in range(len(game_data_keys)):
		Save.game_data[game_data_keys[i]] = data[i]
	
	Save.save_data()

func load_all():
	# Setting data
	fullscreen_on = Save.game_data["fullscreen_on"]
	if Save.game_data["fullscreen_on"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	set_master_db(Save.game_data["master_vol"])
	set_bgm_db(Save.game_data["bgm_vol"])
	set_vl_db(Save.game_data["vl_vol"])
	set_sfx_db(Save.game_data["sfx_vol"])
	
	current_resolution = Save.game_data["resolution"]
	
	# check if in windowed mode
	if not fullscreen_on:
		# Split the string and gather the width and height
		var split = current_resolution.split("x")
		var width = int(split[0])
		var height = int(split[1])
		DisplayServer.window_set_size(Vector2i(width, height))
	
		# Center the screen
		var center_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size()/2
		var window_size = get_window().get_size_with_decorations()
		get_window().set_position(center_screen - window_size/2)
	
	# Level/Player data
	current_cash = Save.game_data["coins"]
	bubble_level = Save.game_data["bubble_lvl"]
	bubble_next_cost = Save.game_data["bubble_next_cost"]
	distance_level = Save.game_data["distance_level"]
	distance_next_cost = Save.game_data["distance_next_cost"]
	health_level = Save.game_data["health_level"]
	health_next_cost = Save.game_data["health_next_cost"]
	boost_level = Save.game_data["boost_level"]
	boost_next_cost = Save.game_data["boost_next_cost"]
	blaster_unlocked = Save.game_data["blaster_unlocked"]
	display_fps = Save.game_data["display_fps"]
	winner = Save.game_data["winner"]
	shader_cached = Save.game_data["shader_cached"]
	highscore_distance = Save.game_data["highscore"]
	code_collected = Save.game_data["code_collected"]
	code_key = Save.game_data["code_key"]
	
	check_upgrades()
	
	
func is_shader_cached() -> bool:
	return  FileAccess.file_exists("user://shader_cache")

func set_distance(distance):
	current_distance = distance
	if current_distance > highscore_distance:
		highscore_distance = distance

func generate_new_code():
	var inputs = ["←", "→", "↑", "↓"]
	code_key = ""
	for i in range(12):
		inputs.shuffle()
		code_key += inputs.pick_random()
	
# Upgrade functions
func check_upgrades():
	# Checking boost levels
	match boost_level:
		1: 
			# Allow player to press lshift to boost in a direction 2 times
			boost_active = true
			max_boost_uses = 2
			boost_next_cost = 800
		2: 
			boost_active = true
			# Allow them to boost 5 times
			max_boost_uses = 5
			boost_next_cost = 1500
		3:
			boost_active = true
			# Allow them to be invincible while in their boost
			max_boost_uses = 10
			boost_invincible = true
			boost_next_cost = 0
		
	boosts_left = max_boost_uses
	
	# Checking health level
	match health_level:
		1: 
			# increase base health to 5
			PlayerStats.max_health += 2
			health_next_cost = 2000
		2: 
			# Increase base health to 8
			PlayerStats.max_health += 3
			health_next_cost = 2500
		3:
			# Increase base health to 10 and increase speed by 1.3x
			PlayerStats.max_health += 2
			health_next_cost = 0
			health_buff_activated = true

	# Check distance skip
	match distance_level:
		1: 
			# skips 1/5 of the distance cap
			distance_skip = 0.2
			distance_next_cost = 700
		2: 
			# skips 2/5
			distance_skip = 0.4
			distance_next_cost = 1800
		3:
			# skips 2/3 and spawn gives raises the chance to get an epic powerup
			distance_skip = 0.66
			distance_next_cost = 0
	
	# Check bubble
	match bubble_level:
			1: 
				bubble_active = true
				bubble_health = 1
				bubble_next_cost = 1200
			2: 
				bubble_active = true
				bubble_health = 2
				bubble_next_cost = 2000
			3:
				bubble_active = true
				bubble_shockwave = true
				bubble_health = 3
				bubble_next_cost = 0
	
func upgrade_boost():
	# Increment level
	if current_cash >= boost_next_cost:
		boost_level += 1
		
		if boost_level > max_level:
			boost_level = max_level
		else:
			current_cash -= boost_next_cost
	
		# Change player stats based on level
		match boost_level:
			1: 
				# Allow player to press lshift to boost in a direction 2 times
				boost_active = true
				max_boost_uses = 2
				boost_next_cost = 1000
			2: 
				# Allow them to boost 5 times
				max_boost_uses = 5
				boost_next_cost = 1500
			3:
				# Allow them to be invincible while in their boost
				boost_invincible = true
				boost_next_cost = 0
		
		boosts_left = max_boost_uses
		
		return true
		
	return false

func upgrade_health():
	# Increment level
	if current_cash >= health_next_cost:
		health_level += 1
		
		if health_level > max_level:
			health_level = max_level
		else:
			current_cash -= health_next_cost
		
		# Change player stats based on level
		match health_level:
			1: 
				# increase base health to 5
				PlayerStats.max_health += 2
				health_next_cost = 2000
			2: 
				# Increase base health to 8
				PlayerStats.max_health += 3
				health_next_cost = 3000
			3:
				# Increase base health to 10 and increase speed by 1.3x
				PlayerStats.max_health += 2
				health_next_cost = 0
				health_buff_activated = true
		
		return true
		
	return false

func upgrade_d_boost():
	# Increment level
	if current_cash >= distance_next_cost:
		distance_level += 1
		
		if distance_level > max_level:
			distance_level = max_level
		else:
			current_cash -= distance_next_cost
		
		# Change stats based on level
		match distance_level:
			1: 
				# skips 1/5 of the distance cap
				distance_skip = 0.16
				distance_next_cost = 1000
			2: 
				# skips 2/5
				distance_skip = 0.33
				distance_next_cost = 1500
			3:
				# skips 2/3
				distance_skip = 0.5
				distance_next_cost = 0
			
		return true
		
	return false

func upgrade_bubble():
	# Increment level
	if current_cash >= bubble_next_cost:
		bubble_level += 1
		
		if bubble_level > max_level:
			bubble_level = max_level
		else:
			current_cash -= bubble_next_cost
		
		# Change stats based on level
		match bubble_level:
			1: 
				bubble_active = true
				bubble_health = 1
				bubble_next_cost = 1200
			2: 
				bubble_health = 2
				bubble_next_cost = 2500
			3:
				bubble_shockwave = true
				bubble_health = 3
				bubble_next_cost = 0
		
		return true
		
	return false

func upgrade_blaster():
	if current_cash >= blaster_cost:
		Supervisor.blaster_unlocked = true
		current_cash -= blaster_cost
		
		return true
	return false
