extends CharacterBody3D

# SFX
@onready var sfx = $SFX

# VFX
@onready var thruster_particles = $MeshPivot/blockbench_export/ThrusterParticles

# Movement
@export var speed = 5.0
var direction = Vector3.FORWARD

# Damage and health
@export var damage = 2
var health = damage

func _ready():
	for i in range(thruster_particles.get_child_count()):
		thruster_particles.get_child(i).emitting = true
	
func _physics_process(delta):
	# Handle movement
	velocity = speed * direction * delta
	
	# Handle Health
	if health <= 0:
		queue_free()
	
	move_and_slide()

func _on_hit_box_area_entered(area):
	health -= area.damage

func _on_hurt_box_area_entered(_area):
	queue_free()

