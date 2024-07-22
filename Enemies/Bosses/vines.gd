extends Node3D

const GOAT = preload("res://Enemies/goat.tscn")

signal ended

@onready var left_pos = $LeftPos
@onready var right_pos = $RightPos
@onready var animation_player = $AnimationPlayer

var goat_1 = null
var goat_2 = null

func spawn_goats():
	# Spawn left goat
	var l_goat = GOAT.instantiate()
	l_goat.position = left_pos.position
	l_goat.target_position = Vector3(-right_pos.position.x, 0, left_pos.position.z)
	l_goat.direction = Vector3.RIGHT
	l_goat.died.connect(end_ability)
	goat_1 = l_goat
	add_child(l_goat)
	
	# Spawn right goat
	var r_goat = GOAT.instantiate()
	r_goat.position = right_pos.position
	r_goat.target_position = Vector3(right_pos.position.x + 5, 0, right_pos.position.z)
	r_goat.direction = Vector3.LEFT
	r_goat.died.connect(end_ability)
	goat_2 = r_goat
	add_child(r_goat)

func end_ability():
	if goat_1:
		goat_1.queue_free()
	if goat_2:
		goat_2.queue_free()
	animation_player.play("vines_exit")

func exit_finished():
	ended.emit()
	queue_free()
