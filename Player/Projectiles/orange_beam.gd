extends CharacterBody3D

# Onready
@onready var hit_box = $HitBox

# Vars
@export var grow_percentage = 10
@export var boss_damage = 1.0
@export var damage = 100000

var scale_max = 11

func _ready():
	hit_box.damage = damage
	hit_box.boss_damage = boss_damage

func _physics_process(delta):
	
	if scale.y < scale_max:
		scale.y += grow_percentage * delta
	else:
		scale.y = scale_max

func die():
	queue_free()

func _on_life_timer_timeout():
	$SFX.stop()
	die()
