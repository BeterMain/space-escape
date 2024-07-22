extends Node

# Const
const POWERUP_BLOCK = preload("res://Pickups/powerup_block.tscn")
const APPLE_ROCKET = preload("res://Player/Projectiles/apple_rocket.tscn")
const BANANA_PROJECTILE = preload("res://Player/Projectiles/banana_projectile.tscn")
const ORANGE_BEAM = preload("res://Player/Projectiles/orange_beam.tscn")
const TROPICAL_ROCKET = preload("res://Player/Projectiles/tropical_rocket.tscn")
const BLASTER_PROJECTILE = preload("res://Player/Projectiles/blaster_projectile.tscn")

const TROPICAL_SHOOT = preload("res://Audio/SFXs/Player/tropicalShoot.wav")
const PLAYER_SHOOT = preload("res://Audio/SFXs/Player/playerShootDefault.wav")

# Onready
@onready var spawn_location = $PowerupSpawnPath/PowerupSpawnLocation
@onready var powerup_timer = $PowerupTimer

@onready var player = $"../Player"
@onready var fire_rate = $FireRate

@onready var sfx = $SFX

# Export
@export var common_duration = 20
@export var uncommon_duration = 15
@export var rare_duration = 10
@export var epic_duration = 10

@export var apple_fire_rate = 0.5

# Vars
var current_powerup = null
var next_powerup = null
var common_powerups = ["apple"]
var uncommon_powerups = ["banana"]
var rare_powerups = ["orange"]
var epic_powerups = ["tropical"]

var can_shoot = true

# Funcs
func _process(_delta):
	# Check if there is a current powerup
	if not current_powerup and player:
		player.erase_topper()
		if Input.is_action_just_pressed("shoot") and Supervisor.blaster_unlocked and fire_rate.time_left == 0:
			sfx.stream = PLAYER_SHOOT
			sfx.play()
			
			var offset = 0.25
			for i in range(2):
				shoot(BLASTER_PROJECTILE, 0.2, false, Vector3(offset, 0, 0.2))
				offset += -0.5
	
	# Handle powerup management
	
	match current_powerup:
		# Common powerups
		"apple":
			apple_powerup()
		
		# Uncommon powerups
		"banana":
			banana_powerup()
		
		# Rare Powerups
		"orange":
			orange_powerup()

		# Epic Powerups
		"tropical":
			tropical_powerup()
		
		# Default
		_:
			delete_current_powerup()

# Misc funcs
func delete_current_powerup():
	# Check for player in scene
	if player:
		# Check if player has projectiles
		if player.projectiles.get_child_count() > 0:
			# Iterate through each child and delete them
			for i in range(player.projectiles.get_child_count()):
				player.projectiles.get_child(i).queue_free()


# Apple Powerup
func apple_powerup():
	if player:
		# Erase current topper
		player.erase_topper()
		# Activate topper
		player.activate_apple()
		# Activate ability
		if Input.is_action_just_pressed("shoot") and can_shoot:
			shoot(APPLE_ROCKET, apple_fire_rate)

# Banana Powerup
func banana_powerup():
	if player:
		# Erase current topper
		player.erase_topper()
		# Activate topper
		player.activate_banana()
		# Activate ability
		if Input.is_action_just_pressed("shoot") and can_shoot:
			shoot(BANANA_PROJECTILE, 0)

# Orange Powerup
func orange_powerup():
	if player:
		# Erase current topper
		player.erase_topper()
		# Activate topper
		player.activate_orange()
		# Activate ability
		if can_shoot:
			shoot(ORANGE_BEAM, 0, true, Vector3(0, 0, -6.0))

# Tropical Powerup
func tropical_powerup():
	if player:
		# Activate topper
		player.activate_tropical(epic_duration)
		# Activate ability
		if Input.is_action_just_pressed("shoot") and can_shoot:
			# Shoot in three directions
			var rotation = 45
			var direction = Vector3(-0.5, 0, -0.5)
			for i in range(2):
				shoot_tropical(rotation, direction.normalized())
				rotation -= 45
				direction.x += 0.5
				direction.z -= 0.5
			shoot_tropical(-45, Vector3(direction.x + 0.5, 0, direction.z + 0.5).normalized())

func shoot_tropical(rotation, direction):
	# SFX
	sfx.stream = PLAYER_SHOOT
	sfx.play()
	
	# Check if player can shoot
	can_shoot = false
	
	var projectile = TROPICAL_ROCKET.instantiate()
	
	# Check for player
	if player:
		projectile.position = player.projectile_spawn.global_position
	else:
		projectile.position = Vector3.ZERO
	
	# Rotate projectile
	projectile.rotation = Vector3(0, rotation, 0)
	
	# Set its direction
	projectile.direction = direction
	
	# Add object
	add_child(projectile)
	
	fire_rate.start(1)

# Shooting funcs
func shoot(PROJECTILE: PackedScene, fire_cooldown: float, track: bool=false, offset: Vector3=Vector3.ZERO):
	# SFX
	sfx.stream = PLAYER_SHOOT
	sfx.play()
	
	# Check if player can shoot
	can_shoot = false
	
	var projectile = PROJECTILE.instantiate()
	
	# Check for player
	if player and not track:
		projectile.position = player.projectile_spawn.global_position + offset
	else:
		projectile.position = Vector3.ZERO + offset
	
	# Check if projectile needs to stay attached to player
	if player and track:
		player.add_child(projectile)
	else:
		# Add object
		add_child(projectile)
	
	# Check if projectile needs to have a cooldown
	if fire_cooldown > 0:
		fire_rate.start(fire_cooldown)

# Powerblock funcs
func spawn_powerupblock():
	# Randomize location
	spawn_location.progress_ratio = randf()
	
	# Instantiate
	var powerup_block = POWERUP_BLOCK.instantiate()
	powerup_block.position = spawn_location.position
	# Connect signals
	powerup_block.common_chosen.connect(common_roll)
	powerup_block.uncommon_chosen.connect(uncommon_roll)
	powerup_block.rare_chosen.connect(rare_roll)
	powerup_block.epic_chosen.connect(epic_roll)
	
	add_child(powerup_block)
	
func common_roll():
	if current_powerup == "orange":
		return
	
	# Erase current topper
	player.erase_topper()
	
	# Randomly choose common powerup
	current_powerup = common_powerups.pick_random()
	powerup_timer.start(common_duration)
	can_shoot = true

func uncommon_roll():
	if current_powerup == "orange":
		return 
	# Erase current topper
	player.erase_topper()
	
	# Randomly choose uncommonpowerup
	current_powerup = uncommon_powerups.pick_random()
	uncommon_powerups.shuffle()
	powerup_timer.start(uncommon_duration)
	can_shoot = true

func rare_roll():
	# Erase current topper
	player.erase_topper()
	
	# Randomly choose rare powerup
	var ran_powerup = rare_powerups.pick_random()
	if ran_powerup == "orange":
		current_powerup = ran_powerup
	elif ran_powerup != "orange" and current_powerup != "orange":
		current_powerup = ran_powerup
	else:
		return 
	rare_powerups.shuffle()
	powerup_timer.start(rare_duration)
	can_shoot = true

func epic_roll():
	if current_powerup == "orange":
		return 
	
	# Erase current topper
	player.erase_topper()
	
	# Randomly choose epic powerup
	current_powerup = epic_powerups.pick_random()
	epic_powerups.shuffle()
	powerup_timer.start(epic_duration)
	can_shoot = true

# Connection Funcs
func _on_powerup_spawner_timeout():
	current_powerup = null

func _on_fire_rate_timeout():
	can_shoot = true
