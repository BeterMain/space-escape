extends CharacterBody3D

# Effect
const EFFECT = preload("res://Pickups/coin_effect.tscn")

# Movement vars
@export var SPEED_MAX = 150.0
var SPEED = SPEED_MAX
var direction = 1

var player = null

@export var value = 100

func _ready():
	# Get direction for movement
	var ran_index = randi_range(0, 1)
	if ran_index == 0:
		direction = 1
	else:
		direction = -1
		
	# Get speed for movement
	SPEED = randi_range(SPEED_MAX/2, SPEED_MAX)

func _physics_process(delta):
	if not player:
		velocity.z = SPEED * delta
		velocity.x = SPEED * direction * delta
	else:
		direction = position.direction_to(player.position).normalized()
		velocity = SPEED * direction * delta

	move_and_slide()

func spawn_effect():
	var effect = EFFECT.instantiate()
	effect.value = value
	effect.position = global_position
	get_parent().add_child(effect)

func die():
	# Delete Self
	queue_free()

func _on_hurt_box_body_entered(body):
	# Check for interaction with player
	if body.name == "Player":
		# Add currency for upgrades
		Supervisor.current_cash += value
		spawn_effect()
		die()
	
	if body.name == "L_Wall" or body.name == "R_Wall":
		direction *= -1
	
func _on_hurt_box_area_entered(_area):
	die()

func _on_detection_radius_body_entered(body):
	player = body
	SPEED *= 1.5
