extends CharacterBody3D

# Sfx
@onready var sfx = $SFX

# Movement
@export var SPEED_MAX = 150.0
var SPEED = SPEED_MAX
var direction = 1

# Powerup signals
signal common_chosen
signal uncommon_chosen
signal rare_chosen
signal epic_chosen
signal collected

func _ready():
	randomize()
	# Get direction for movement
	var ran_index = randi_range(0, 1)
	if ran_index == 0:
		direction = 1
	else:
		direction = -1
		
	# Get speed for movement
	SPEED = randi_range(SPEED_MAX/2, SPEED_MAX)

func _physics_process(delta):
	
	velocity.z = SPEED * delta
	velocity.x = SPEED * direction * delta
	
	move_and_slide()

func roll_powerup():
	var ran_index = randi_range(1, 100)
	
	# 55% chance for common powerup
	if ran_index >= 45:
		common_chosen.emit()
	# 30% chance for uncommon powerup
	elif ran_index < 45 and ran_index >= 15:
		uncommon_chosen.emit()
	# 13% chance for rare powerup
	elif ran_index < 15 and ran_index > 2:
		rare_chosen.emit()
	# 2% chance for epic powerup
	else:
		epic_chosen.emit()

func die():
	# After end of animation emit signal
	collected.emit()
	
	# Delete Self
	visible = false

func _on_hurt_box_body_entered(body):
	# Check for interaction with player
	if body.name == "Player":
		# Play Collect Animation
		sfx.play()
		# Signal Powerup
		roll_powerup()
		# Die
		die()
	
	if body.name == "L_Wall" or body.name == "R_Wall":
		direction *= -1
	
func _on_hurt_box_area_entered(_area):
	die()

func _on_sfx_finished():
	queue_free()
