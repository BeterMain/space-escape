extends Node3D

@onready var particles = $GPUParticles3D

var value = 100

func _ready():
	particles.mesh.text = "+" + str(value)
	particles.emitting = true
	
func die():
	queue_free()

func _on_audio_stream_player_finished():
	die()
