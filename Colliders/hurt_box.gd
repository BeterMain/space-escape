extends Area3D

const HIT_EFFECT = null

# damage
@export var damage = 0.0
@export var boss_damage = 0.0

@onready var invincibility_timer = $InvincibilityTimer
@onready var collision_shape = $CollisionShape3D

signal invincibility_started
signal invincibility_ended

var invincible = false: set = set_invincibility

func set_invincibility(value):
	invincible = value
	if invincible == true:
		invincibility_started.emit()
	else:
		invincibility_ended.emit()

func start_invincibilty(duration):
	self.invincible = true
	invincibility_timer.start(duration)

func _on_invincibility_timer_timeout():
	self.invincible = false

func _on_invincibility_started():
	set_deferred("monitoring", false)

func _on_invincibility_ended():
	set_deferred("monitoring", true)
