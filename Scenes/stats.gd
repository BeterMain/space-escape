extends Node

@export var max_health = 1.0
var health: set = set_health

signal no_health
signal health_changed(value)

func _ready():
	self.health = max_health

func set_health(value):
	health = value
	emit_signal("health_changed")
	if health <= 0:
		emit_signal("no_health")
