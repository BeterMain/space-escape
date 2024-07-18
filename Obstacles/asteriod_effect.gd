extends Node3D

var using_sound = false

func _ready():
	$Particles.emitting = true
	if using_sound:
		$SFX.play()

func die():
	queue_free()

func _on_particles_finished():
	die()
