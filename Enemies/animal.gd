extends CharacterBody3D

const DEATH_EFFECT = preload("res://Enemies/animal_effect.tscn")

@export var SPEED = 250
@export var direction = Vector3.FORWARD
var target_position = null

@export var health_gain = 0.1
@export var flash_animation_player : AnimationPlayer
@export var stats : Node
@export var animal_sound_effect: AudioStreamPlayer
@onready var sfx : AudioStreamPlayer

signal died

func _ready():
	if animal_sound_effect:
		animal_sound_effect.pitch_scale = randf_range(0.75, 1.5)
		animal_sound_effect.play()
	
	if target_position:
		look_at_from_position(position, target_position, Vector3.UP)

func _physics_process(delta):
	
	velocity = direction * SPEED * delta
	
	move_and_slide()

func die(using_sound):
	died.emit()
	var effect = DEATH_EFFECT.instantiate()
	effect.position = global_position
	effect.using_sound = using_sound
	get_parent().add_child(effect)
	
	queue_free()
	

func hit(area):
	stats.health -= area.damage
	if sfx:
		sfx.play()
	flash_animation_player.play("flash")

func _on_stats_no_health():
	die(true)

func _on_hit_box_area_entered(area):
	if area.collision_layer == 256:
		hit(area)
	elif area.collision_layer == 32:
		die(false)

func _on_hurt_box_area_entered(area):
	if area.collision_layer == 32:
		die(false)
	if area.collision_layer == 2048:
		BossHealth.health += BossHealth.max_health * 0.05
	hit(area)
