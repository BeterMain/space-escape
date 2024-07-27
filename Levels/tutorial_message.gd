extends CharacterBody3D

@export var SPEED = 150
@export var direction = Vector3.BACK
@export var text = ""

func _ready():
	$Message.mesh.text = text

func _physics_process(delta):
	if Input.is_action_just_pressed("cancel_input"):
		queue_free()
	
	velocity = direction * SPEED * delta
	
	move_and_slide()
	

func _on_hurt_box_area_entered(_area):
	queue_free()
