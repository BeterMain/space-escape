extends CharacterBody3D

const BANANA_SPIN = preload("res://Audio/SFXs/Player/bananaSpin.wav")

# Movement
@export var max_speed = 250.0
@export var base_speed = 200
var speed = 5.0
@export var bounce_factor = 0.8 # Bounce strength

# Health and damage
@export var damage = 1.5
var health = damage
@onready var hurt_box = $HurtBox
@onready var hit_box = $HitBox

# Target vars
var current_target = null
var targets = []
var screen_bottom_position = 4
var screen_right_position = 4.2
var screen_left_position = -4.5
var screen_top_position = -6.5

func _ready():
	hurt_box.damage = damage
	hit_box.damage = damage

func _physics_process(delta):
	
	# Create speed that can be changed
	var new_speed = clamp(base_speed, speed, max_speed)
	
	# Check if we have a target
	if current_target != null and is_instance_valid(current_target):
		# Go to target
		var direction = position.direction_to(current_target.position).normalized()
		velocity = new_speed * direction * delta
		
		# Check if we are inside the target
		var outside_left_or_right = current_target.global_position.x > screen_right_position or current_target.global_position.x < screen_left_position
		if position.distance_to(current_target.position) < 0.2 or outside_left_or_right: 
			# Check if we have a next target and select it
			if targets.size() >= 1:
				targets.pop_front()
			else:
				# Set no target
				current_target = null
			# Look for another target
			choose_next_target()
	else:
		# Stop moving and look for another target
		velocity = velocity.move_toward(Vector3.ZERO, delta)
		
		choose_next_target()
		# Decrease speed multiplier while waiting
		speed -= 5 * delta
	
	if speed > max_speed:
		speed = max_speed
	
	move_and_slide_with_bounce()

func move_and_slide_with_bounce():
	var collision = move_and_collide(velocity * get_physics_process_delta_time())
	
	if collision:
		handle_collision(collision)

func handle_collision(collision):
	if collision:
		# Reflect velocity along the collision normal
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal) * bounce_factor

		# Prevent sticking to walls by slightly offsetting the character
		translate(normal * 0.1)

func choose_next_target():
	# Check if targets exists
	var closest_distance = INF
	var closest_middle_distance = INF
	# Calculate middle screen position
	var screen_middle_pos = Vector3(0, 0, screen_bottom_position + screen_top_position)
	# Check if targets array is populated
	if targets:
		# Iterate through targets and find closest target to banana and to middle
		for target in targets:
			if is_instance_valid(target) and target != current_target:
				var distance = global_position.distance_to(target.global_position)
				var distance_to_middle = target.global_position.distance_to(screen_middle_pos)
				if distance < closest_distance:
					closest_distance = distance
					if distance_to_middle < closest_middle_distance:
						closest_middle_distance = distance_to_middle
						current_target = target
			else:
				targets.erase(target)

func add_to_targets(body):
	if body.global_position.z > screen_top_position and body.global_position.z < screen_bottom_position:
		targets.append(body)

func die():
	queue_free()

# Connect funcs
func _on_hurt_box_area_entered(_area):
	die()

func _on_hit_box_area_entered(_area):
	# Look for next target and increase speed
	choose_next_target()
	speed += 15

func _on_detection_radius_body_entered(body):
	add_to_targets(body)

func _on_detection_radius_body_exited(body):
	if body in targets:
		targets.erase(body)
	else:
		add_to_targets(body)

func _on_life_duration_timeout():
	die()

func _on_sfx_finished():
	$SFX.play()
