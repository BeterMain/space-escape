extends AudioStreamPlayer

const OPENING_BGM = preload("res://Audio/BGM/Through_Space(Opening).wav")
const BGM = preload("res://Audio/BGM/Through_Space.wav")

var exiting = false

func _process(_delta):
	# Handle BGM
	if volume_db < -0.95 and not exiting:
		volume_db += 0.1
	
	if exiting:
		volume_db -= 0.2
	
	# Lower speed gradually when paused
	if get_tree().paused and pitch_scale > 0.9:
		pitch_scale -= 0.01
	
	# Raise speed to normal after unpause
	if not get_tree().paused and pitch_scale < 1:
		pitch_scale += 0.1
		
	if pitch_scale > 1:
		pitch_scale = 1

func restart_bgm():
	stop()
	stream = OPENING_BGM
	play()

func _on_finished():
	if stream == OPENING_BGM:
		stream = BGM
		play()
	
	play()
