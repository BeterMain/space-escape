extends Node

# Const vars
const ASTERIOD = preload("res://Obstacles/asteriod.tscn")
const UFO = preload("res://Obstacles/ufo.tscn")
const FRYING_PAN = preload("res://Obstacles/frying_pan.tscn")
const KNIFE = preload("res://Obstacles/knife.tscn")
const COIN = preload("res://Pickups/coin.tscn")
const BOAR = preload("res://Enemies/boar.tscn")

# Onready vars
@onready var obstacle_spawn_timer = $ObstacleSpawnTimer
@onready var obstacles = $Obstacles
@onready var player = $"../Player"
@onready var obstacle_spawn_location = $ObstacleSpawnPath/ObstacleSpawnLocation

# Export vars
@export var max_interval = 1
@export var default_min_interval = 0.2
var min_interval = 0.2
@export var spawn_offset = 4

# Vars
var interval = max_interval

var double_speed = false
var trail_active = false
var chase_active = false
var boss_started = false
var event_ragnarok = false
var can_spawn_boar = false
var num_boar = 0

var only_ufo = false
var only_asteriod = false
var double_money = false

var stopped = true

var obstacle_choices = [ASTERIOD, ASTERIOD, ASTERIOD, ASTERIOD, ASTERIOD, ASTERIOD, ASTERIOD, UFO]
var ragnarok_obstacle_choices = [KNIFE, FRYING_PAN]

func _process(_delta):
	
	if obstacle_spawn_timer.time_left == 0 and not stopped:
		obstacle_spawn_timer.start(interval)
		interval -= 0.01
	
	interval = clamp(interval, min_interval, max_interval)

func spawn_obstacle():
	var spawn_index = randi_range(0, 6/interval)
	var OBSTACLE = null
	
	if not event_ragnarok:
		if spawn_index == 0 and not boss_started:
			OBSTACLE = COIN
		else:
			if only_ufo:
				OBSTACLE = UFO
			elif only_asteriod:
				OBSTACLE = ASTERIOD
			else:
				OBSTACLE = obstacle_choices.pick_random()
				obstacle_choices.shuffle()
	else:
		if spawn_index == 0 and not boss_started:
			OBSTACLE = COIN
		else:
			OBSTACLE = ragnarok_obstacle_choices.pick_random()
			ragnarok_obstacle_choices.shuffle()
	
	var obstacle = OBSTACLE.instantiate()
	
	# Change speed if needed
	if double_speed and OBSTACLE in obstacle_choices:
		obstacle.SPEED *= 2
		obstacle.speed_increased = true
	# Add trail if needed
	if trail_active and OBSTACLE in obstacle_choices:
		obstacle.trail_active = true
	
	if double_money:
		obstacle.value *= 3
	
	# Set position and spawn
	obstacle_spawn_location.progress_ratio = randf()
	var obstacle_position = obstacle_spawn_location.position
	# Change scale to randomize if obstacle
	if OBSTACLE in obstacle_choices:
		obstacle.scale = Vector3.ONE * randf_range(0.33, 0.66)
		obstacle.initialize(obstacle_position, player.position, chase_active)
	else:
		obstacle.position = obstacle_position
	
	if OBSTACLE != COIN:
		obstacles.add_child(obstacle)
	else:
		add_child(obstacle)

func clear_obstacles():
	var obstacle_array = obstacles.get_children()
	for obstacle in obstacle_array:
		obstacle.die()

func start_spawning():
	interval = max_interval
	obstacle_spawn_timer.start()
	stopped = false

func stop_spawning():
	min_interval = default_min_interval
	obstacle_spawn_timer.stop()
	stopped = true

# Funcs for events
func set_ragnarok(value):
	event_ragnarok = value

func set_spawn_boar(active):
	if active and not can_spawn_boar:
		can_spawn_boar = active
		spawn_boar()
	else:
		can_spawn_boar = active

func spawn_boar():
	var boar = BOAR.instantiate()
	obstacle_spawn_location.progress_ratio = randf()
	boar.position = obstacle_spawn_location.position
	boar.direction = Vector3.BACK
	add_child(boar)

func set_only_ufos(value):
	# Set to value
	only_ufo = value
	# Change other variables to be false
	if value:
		double_money = false
		only_asteriod = false
		double_speed = false

func set_only_asteriods(value):
	# Set to value
	only_asteriod = value
	double_speed = true
	# Change other variables to be false
	if value:
		double_money = false
		only_ufo = false

func set_double_money(value):
	# Set to value
	double_money = value
	# Change other variables to be false
	if value:
		only_asteriod = false
		only_ufo = false
		double_speed = false
	
# Connected funcs to main level script for boss
func activate_chase():
	chase_active = true

func shorten_spawn_rate():
	min_interval = 0.15

func stop_interferences():
	trail_active = false
	double_speed = false
	chase_active = false

func boss_activated():
	boss_started = true

func boss_deactivated():
	boss_started = false

func activate_trail():
	trail_active = true

func activate_double_speed():
	double_speed = true

# Connect funcs
func _on_obstacle_spawn_timer_timeout():
	spawn_obstacle()
