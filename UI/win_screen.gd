extends Control

func _ready():
	Supervisor.winner = true

func _on_main_menu_btn_pressed():
	Supervisor.save_all()
	SceneManager.change_scene_to_file("res://Scenes/main_menu.tscn", "fade")


func _on_bgm_finished():
	$BGM.play()
