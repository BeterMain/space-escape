extends CanvasLayer


@onready var AnimationN = $Control/AnimationPlayer
var scene : String

func change_scene_to_file(diff_scene, anim):
	scene = diff_scene 
	AnimationN.play(anim)

func new_scene():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file(scene)
