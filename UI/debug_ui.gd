extends CanvasLayer

@onready var fps_txt = $Control/FpsTxt

func _process(_delta):
	fps_txt.visible = Supervisor.display_fps
	
	if fps_txt.visible:
		fps_txt.text = "FPS: " + str(Engine.get_frames_per_second())
