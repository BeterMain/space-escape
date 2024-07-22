extends CharacterBody3D

# Sfx
@export var sfx: AudioStreamPlayer
const ASTERIOD_EXPLOSION = preload("res://Audio/SFXs/Obstacle/asteriodExplosion.wav")
const ASTERIOD_HIT = preload("res://Audio/SFXs/Obstacle/asteriodHit.wav")

const COIN = preload("res://Pickups/coin.tscn")

# Effects
const EFFECT = preload("res://Obstacles/asteriod_effect.tscn")

# Health and Damage
var damage = 1
@onready var stats = $Stats
@onready var hitbox = $MainHitBox
@onready var hurtbox = $HurtBox

@onready var spin_pivot = $SpinPivot

# Trails
@onready var trail_hitbox = $TrailHitBox/CollisionShape3D
@onready var trail_mesh = $TrailHitBox/TrailMesh

# Movement
@export var SPEED_MAX = 150.0
var SPEED = SPEED_MAX

# Animation
@export var animation_player: AnimationPlayer

@onready var x_rotation = randi_range(-1, 1)
@onready var z_rotation = randi_range(-1, 1)
@onready var rotation_speed = randf_range(0.05, 0.15)
@export var spin_x = true
@export var spin_y = true
@export var spin_z = true

# Boss vars
var trail_active = false
var normal = true
var speed_increased = false

var value = 100

# Funcs
func _ready():
	randomize()
	
	hitbox.damage = stats.health
	hurtbox.damage = stats.health
	
	SPEED = randi_range(SPEED_MAX/2, SPEED_MAX)
	$SpeedParticles.emitting = speed_increased
	
func _physics_process(delta):
	
	if normal:
		velocity = Vector3.BACK * SPEED * delta
	else:
		# We calculate a forward velocity that represents the speed.
		velocity = Vector3.FORWARD * SPEED * delta
		
		# We then rotate the velocity vector based on the mob's Y rotation
		# in order to move in the direction the mob is looking.
		velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	if trail_active:
		trail_hitbox.disabled = false
		trail_mesh.visible = true
	else:
		trail_hitbox.disabled = true
		trail_mesh.visible = false
	
	if spin_x and spin_y and spin_z:
		spin_pivot.rotate(Vector3(x_rotation,1, z_rotation).normalized(), rotation_speed)
	elif spin_x:
		spin_pivot.rotate(Vector3(x_rotation, 0.1, 0.1).normalized(), rotation_speed)
	elif spin_z:
		spin_pivot.rotate(Vector3(0.1, 0.1, z_rotation).normalized(), rotation_speed)
	elif spin_y:
		spin_pivot.rotate(Vector3(0.1, x_rotation, 0.1).normalized(), rotation_speed)
	
	move_and_slide()

# Misc funcs
func initialize(start_position, player_position, chase=false):
	if chase:
		# We position the mob by placing it at start_position
		# and rotate it towards player_position, so it looks at the player.
		look_at_from_position(start_position, player_position + Vector3(randf_range(1, 2), 0, randf_range(1, 2)), Vector3.UP)
	
		normal = false
	else:
		# Go Down
		position = start_position
		normal = true

func hit(area):
	# Sfx
	if not area.get_parent().name.to_lower().contains("obstaclepit") and area.collision_layer != 8: # Checking if colliding with pit or asteriod
		if sfx:
			sfx.play()
	
	# Take damage
	if area.collision_layer != 8 :
		if animation_player:
			animation_player.play("flash")
		stats.health -= area.damage
	
	if area.collision_layer == 8 and global_position.z > -6.5:
		stats.health -= area.damage

func create_effect(using_sound=false):
	# Sfx
	var effect = EFFECT.instantiate()
	effect.position = global_position
	effect.using_sound = using_sound
	get_parent().add_child(effect)

func die():
	create_effect()
	
	var ran_index = randi_range(1,10)
	
	if ran_index < 2:
		var coin = COIN.instantiate()
		coin.value = value
		coin.position = global_position
		get_parent().add_child(coin)
	
	# Queue_free
	queue_free()

# Connect Funcs
func _on_hurt_box_area_entered(area):
	if not area.get_parent().name.to_lower().contains("obstaclepit"):
		hit(area)
	else:
		queue_free()

func _on_hit_box_area_entered(area):
	hit(area)

func _on_stats_no_health():
	die()
