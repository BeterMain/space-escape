extends Node3D

@onready var loading_bar = $UI/Control/CenterContainer/VBoxContainer/LoadingBar
@onready var timer = $Timer
@onready var death_particles = $Camera3D/Player/DeathParticles

var count_down = 2
var previous_db = 0
var bus_index = AudioServer.get_bus_index("Master")

func _ready():
	death_particles.emitting = true
	loading_bar.value = 0
	previous_db = AudioServer.get_bus_volume_db(bus_index)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(0))

func _process(_delta):
	
	if count_down > 0:
		count_down -= 1
		
	loading_bar.value += 0.1
	
	if loading_bar.value == loading_bar.max_value:
		SceneManager.change_scene_to_file("res://Levels/level.tscn", "fade")

func _on_timer_timeout():
	Supervisor.shader_cached = true
	loading_bar.value = loading_bar.max_value
