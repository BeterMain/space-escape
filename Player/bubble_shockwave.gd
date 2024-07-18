extends Node3D

@onready var bubble_shield = $BubbleShield

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	scale += Vector3(0.1, 0.1, 0.1)
	
	if scale.x > 20:
		queue_free()
