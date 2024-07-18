extends CharacterBody3D

@onready var sfx = $SFX

@onready var hit_box = $HitBox
@onready var hurt_box = $HurtBox

# Movement
@export var speed = 250

# Damage
@export var damage = 0.5
var health = damage
@export var boss_damage = 0

var direction = Vector3.FORWARD

func _ready():
	hit_box.damage = damage
	hit_box.boss_damage = boss_damage
	hurt_box.damage = damage
	
func _physics_process(delta):
	# Move
	velocity = direction * speed * delta
	
	if health <= 0:
		die()
	
	move_and_slide()

func die():
	queue_free()

func _on_hurt_box_area_entered(_area):
	die()

func _on_hit_box_area_entered(area):
	health -= area.damage
