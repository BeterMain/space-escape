extends CharacterBody3D

# Bubble Effect
const BUBBLE_EFFECT = preload("res://Player/bubble_shockwave.tscn")

# SFX
@onready var sfx = $SFX
const PLAYER_HIT = preload("res://Audio/SFXs/Player/playerHit.wav")
const PLAYER_DEATH = preload("res://Audio/SFXs/Player/playerDeath.wav")
const DODGE = preload("res://Audio/SFXs/Player/dodge.wav")
const PLAYER_SHOOT = preload("res://Audio/SFXs/Player/playerShootDefault.wav")

# Movement
@export var MAX_SPEED = 5.0
@export var ACCELERATION = 5.0
var SPEED = MAX_SPEED
const FRICTION = 20.0

@export var beam_repel_force = 5
var beam_repel = 0
var speed_multiplier = 1
@export var health_buff = 1.3

# Onready 
@onready var player_model = $blockbench_export
@onready var animation_tree = $AnimationTree
@onready var topper_animation_player = $TopperAnimationPlayer
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var animation_player = $AnimationPlayer
@onready var hurt_box = $HurtBox
@onready var hurtbox_collision = $HurtBox/CollisionShape3D
@onready var stats = PlayerStats
@onready var death_particles = $DeathParticles

@onready var shoot_text = $ShootText
@onready var tutorial_animation_player = $TutorialAnimationPlayer

# Boost
@export var boost_speed = 10
var boost_dir = Vector3.FORWARD 
@onready var boost_active = Supervisor.boost_active
@onready var boost_invincible = Supervisor.boost_invincible
@onready var max_boost_uses = Supervisor.max_boost_uses

# Bubble shield 
@onready var bubble_shield = $BubbleShield
@onready var bubble_health = Supervisor.bubble_health
@onready var bubble_shockwave = Supervisor.bubble_shockwave

# Powerup vars
@onready var apple_topper = $blockbench_export/AppleTopper
@onready var banana_topper = $blockbench_export/BananaTopper
@onready var orange_topper = $blockbench_export/OrangeTopper
@onready var tropical_topper = $blockbench_export/TropicalPivot

var is_tropical = false

@onready var projectile_spawn = $ProjectileSpawn
@onready var projectiles = $Projectiles

# Health
@export var invincibility_duration = 1.0

# Animation vars
var rotation_dir = Vector2.ZERO
var is_dead = false
@export var rotation_speed = 0.5

@onready var thruster_particles = $blockbench_export/ThrusterParticles
@onready var thruster_sfx = $ThrusterSFX
var speed_lowered = false
var input_locked = false
@onready var flash_animation_player = $FlashAnimationPlayer

# State
enum {
	move,
	boost,
	dead
}
var state = move

# Functions
func _ready():
	animation_tree.active = true
	animation_tree.set("parameters/Move/blend_position", 0)
	
	stats.no_health.connect(die)
	stats.health = stats.max_health
	
	Supervisor.boosts_left = max_boost_uses
	
	bubble_shield.visible = Supervisor.bubble_active
	hurtbox_collision.disabled = false
	
	shoot_text.visible = Supervisor.blaster_unlocked

func _physics_process(delta):
	# Show if speed is lowered
	$SpeedParticles.emitting = speed_lowered
	
	if shoot_text.visible:
		tutorial_animation_player.play("show_shoot_control")
		if Input.is_action_just_pressed("shoot"):
			tutorial_animation_player.stop()
			shoot_text.visible = false
	
	# Death management
	if is_dead:
		set_thruster_strength(0.1)
		state = dead
	
	if not input_locked:
		# State Management
		match state:
			move:
				animation_state.travel("Move")
				move_state(delta)
			boost:
				boost_state()
			dead:
				# Make player fall slowly
				velocity = velocity.move_toward(Vector3(boost_dir.x, -1, 0), FRICTION * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, FRICTION * delta * speed_multiplier)
		
	move_and_slide()

# State Funcs
func move_state(delta):
	thruster_sfx.pitch_scale = 1
	
	hurtbox_collision.disabled = false
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if is_controller_connected():
		input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Change rotation in animation when moving
	rotation_dir.x = clamp(rotation_dir.x, -1, 1)
	rotation_dir.y = clamp(rotation_dir.y, -1, 1)
	
	if input_dir.x > 0.01:
		rotation_dir.x += rotation_speed
	elif input_dir.x < -0.01:
		rotation_dir.x -= rotation_speed
	else:
		rotation_dir.x = move_toward(rotation_dir.x, 0, 0.05)
	
	if input_dir.y > 0.01:
		rotation_dir.y += rotation_speed
	elif input_dir.y < -0.01:
		rotation_dir.y -= rotation_speed
	else:
		rotation_dir.y = move_toward(rotation_dir.y, 0, 0.05)
	
	animation_tree.set("parameters/Move/blend_position", rotation_dir)
	
	# Check for health buff for speed
	if Supervisor.health_buff_activated:
		speed_multiplier = health_buff
	
	if orange_topper.visible:
		beam_repel = beam_repel_force
	else:
		beam_repel = 0
	
	# Handle Movement
	if direction:
		# Thruster management
		if thruster_sfx.volume_db < 3:
			thruster_sfx.volume_db += 0.1
		
		if thruster_sfx.volume_db > 3:
			thruster_sfx.volume_db -= 1
		
		if direction.z > 0:
			set_thruster_strength(0.1)
		else:
			set_thruster_strength(1)
		
		# Set boost direction and animation position
		boost_dir = Vector3(input_dir.x, 0, input_dir.y)
		
		velocity.x = move_toward(velocity.x, direction.x * (SPEED * speed_multiplier), (ACCELERATION * speed_multiplier) * delta)
		velocity.z = move_toward(velocity.z, direction.z * (SPEED * speed_multiplier), (ACCELERATION * speed_multiplier) * delta)
		
	else:
		# Thruster management
		if thruster_sfx.volume_db > -5:
			thruster_sfx.volume_db -= 0.1
		set_thruster_strength(0.2)
		
		velocity = velocity.move_toward(Vector3.ZERO, FRICTION * delta * speed_multiplier)
	
	# Subtract beam repel to make player go backwards
	velocity.z -= beam_repel * Vector3.FORWARD.z * delta
	
	# Check for boost
	if Input.is_action_just_pressed("boost") and boost_active and Supervisor.boosts_left > 0:
		Supervisor.boosts_left -= 1
		
		if boost_dir.x > 0:
			animation_state.travel("dodge_right")
		elif boost_dir.x < 0:
			animation_state.travel("dodge_left")
		else:
			animation_state.travel("dodge_right")
		
		sfx.stop()
		sfx.stream = DODGE
		sfx.play()
		
		if boost_invincible:
			bubble_health += 1
			bubble_shield.visible = true
		
		state = boost
	
func is_controller_connected() -> bool:
	var device_count = Input.get_connected_joypads().size()
	return device_count > 0

func boost_state():
	# Thruster Management
	set_thruster_strength(1)
	if thruster_sfx.volume_db < 4:
		thruster_sfx.volume_db += 1
	
	thruster_sfx.pitch_scale = randi_range(1, 2)
	
	hurtbox_collision.disabled = true
	
	velocity = boost_dir * boost_speed

# Misc funcs
func die():
	# death effect
	hit_stop(0.08, 1.0)
	flash_animation_player.stop()
	player_model.visible = false
	death_particles.emitting = true
	# SFX
	sfx.stream = PLAYER_DEATH
	sfx.play()
	# Queue_free
	Supervisor.current_distance = 0
	Supervisor.save_all()
	is_dead = true

func hit_stop(time_scale, duration):
	Engine.time_scale = time_scale
	await(get_tree().create_timer(duration * time_scale).timeout)
	Engine.time_scale = 1.0

func set_thruster_strength(value):
	if thruster_particles.get_child(0).amount_ratio == value:
		return
		
	for i in range(thruster_particles.get_child_count()):
		thruster_particles.get_child(i).amount_ratio = value

func dodge_animation_finished():
	state = move

# Powerup funcs
func activate_apple():
	apple_topper.visible = true

func activate_orange():
	orange_topper.visible = true

func activate_banana():
	banana_topper.visible = true

func activate_tropical(duration):
	if not is_tropical:
		is_tropical = true
		tropical_topper.visible = true
		
		hurt_box.start_invincibilty(duration)
		
		topper_animation_player.play("tropical_topper_spin")

func erase_topper():
	apple_topper.visible = false
	orange_topper.visible = false
	banana_topper.visible = false
	tropical_topper.visible = false
	
	if is_tropical:
		is_tropical = false
		
		topper_animation_player.stop()

func lock_movement():
	input_locked = true

func unlock_movement():
	input_locked = false

func hit():
	# SFX
	sfx.stream = PLAYER_HIT
	sfx.play()
	# Check if bubble still alive
	
	if bubble_health <= 0:
		hit_stop(0.5, 0.5)
		# Play flash animation
		hurt_box.start_invincibilty(invincibility_duration)
		$FlashAnimationPlayer.play("flash")
		# Decrement health
		stats.health -= 1
	
	# Decrement bubble health
	if bubble_health > 0:
		flash_animation_player.play("bubble_flash")
		bubble_health -= 1
		bubble_shield.visible = bubble_health > 0
	
	if bubble_health > 0 and bubble_shockwave:
		var bubble_effect = BUBBLE_EFFECT.instantiate()
		bubble_effect.position = bubble_shield.global_position
		get_parent().add_child(bubble_effect)
		bubble_shockwave = false

# Connection funcs
func _on_hurt_box_area_entered(_area):
	hit()

func _on_thruster_sfx_finished():
	thruster_sfx.play()
