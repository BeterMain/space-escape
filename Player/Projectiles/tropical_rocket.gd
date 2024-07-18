extends CharacterBody3D

@onready var hit_box = $HitBox
@onready var hurt_box = $HurtBox

# Movement
@export var speed = 250

# Damage
@export var damage = 10000000.0
@export var boss_damage = 2.5

var direction = Vector3.FORWARD

func _ready():
	hit_box.boss_damage = boss_damage
	
func _physics_process(delta):
	# Move
	velocity = direction * speed * delta
	
	move_and_slide()

func die():
	queue_free()

func _on_hurt_box_area_entered(_area):
	die()
