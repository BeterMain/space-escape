extends Node

const SAVEFILE = "user://SAVEFILE.save"

var game_data = {}
var first_load = true
signal data_loaded
signal reset_save

func _ready():
	load_data()

func load_data():
	# Check if save exists
	if not FileAccess.file_exists(SAVEFILE):
		clear_save()
	else:
		var file = FileAccess.open(SAVEFILE, FileAccess.READ)
		
		game_data = file.get_var()
		first_load = file.get_var()
		
		if game_data["version"] != Supervisor.version:
			clear_save()
		else:
			data_loaded.emit()
	
		file.close()

func clear_save():  
	Supervisor.generate_new_code()
	game_data = {
		"version": Supervisor.version,
		"fullscreen_on": true,
		"master_vol": -1.5,
		"bgm_vol": 2.6,
		"vl_vol": 1.3,
		"sfx_vol": 0.5,
		"resolution": "1152x648",
		"coins": 0,
		"bubble_lvl": 0,
		"bubble_next_cost": 500,
		"distance_level": 0,
		"distance_next_cost": 300,
		"health_level": 0,
		"health_next_cost": 1500,
		"boost_level": 0,
		"boost_next_cost": 250,
		"blaster_unlocked": false,
		"highscore": 0,
		"code_collected": "",
		"code_key": Supervisor.code_key,
		"display_fps": true,
		"winner": false
		}
	first_load = true
	
	if not Supervisor.shader_cached:
		game_data["shader_cached"] = false
	else:
		game_data["shader_cached"] = true
	
	save_data()
	reset_save.emit()

func save_data():
	var file = FileAccess.open(SAVEFILE, FileAccess.WRITE)
	
	file.store_var(game_data)
	file.store_var(first_load)
	file.close()
