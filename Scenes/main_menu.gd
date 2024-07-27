extends Node3D

# SFX
const PRESSED = preload("res://Audio/SFXs/UI/buttonPressed.wav")
const SELECT = preload("res://Audio/SFXs/UI/buttonSelected.wav")
const START_PRESSED = preload("res://Audio/SFXs/UI/playPressed.wav")

@onready var main_menu_bgm = $MainMenuBGM
@onready var sfx = $SFX
var exiting = false

@onready var start_btn = $"DebugUI/UI/CenterContainer/VBoxContainer/Start&Quit/StartBtn"
@onready var ui = $DebugUI/UI
@onready var settings_menu = $DebugUI/SettingsMenu
@onready var version_txt = $DebugUI/UI/VersionTxt
@onready var winner_pivot = $Pivot
@onready var particles = $SubViewportContainer/SubViewport/Particles
@onready var cutscene_animation_player = $CutsceneAnimationPlayer
@onready var opening_animation_player = $DebugUI/UI/Opening/OpeningAnimationPlayer
@onready var leaderboard = $DebugUI/Leaderboard

var opening_finished = false

func _ready():
	randomize()
	version_txt.text = "v" + str(Supervisor.version)
	
	winner_pivot.visible = Supervisor.winner

	particles.draw_pass_1.material.albedo_color = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))

func _process(_delta):
	# Raise volume of bgm when entering the scene
	if main_menu_bgm.volume_db < -0.95 and not exiting:
		main_menu_bgm.volume_db += 0.1
	
	
	if Input.is_action_just_pressed("cancel_input") and not opening_finished:
		start_cutscene()
	
	# Look for selection input
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
		sfx.stream = SELECT
		sfx.play()
	
	# Lower volume when exiting the scene
	if exiting:
		main_menu_bgm.volume_db -= 0.2

func start_cutscene():
	opening_animation_player.stop()
	$DebugUI/UI/Opening.visible = false
	opening_finished = true
	cutscene_animation_player.play("fly_in")
	start_btn.grab_focus()
	main_menu_bgm.play(26.80)

func start_scene_music():
	main_menu_bgm.play(15.93)

func _on_start_btn_pressed():
	exiting = true
	# Play sfx
	sfx.stream = PRESSED
	sfx.play()
	# Go to gameplay
	if Supervisor.shader_cached:
		if Save.first_load:
			SceneManager.change_scene_to_file("res://Levels/level.tscn", 'fade') 
		else:
			SceneManager.change_scene_to_file("res://Scenes/upgrade_screen.tscn", 'fade') 
	else:
		SceneManager.change_scene_to_file("res://Scenes/shader_cache.tscn", "fade")

func _on_quit_btn_pressed():
	# Quit
	Supervisor.save_all()
	leaderboard.functions._upload_score(Supervisor.highscore_distance)
	start_btn.disabled = true
	$"DebugUI/UI/CenterContainer/VBoxContainer/Start&Quit/QuitBtn".disabled = true
	
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func _on_main_menu_bgm_finished():
	main_menu_bgm.play()

func _on_settings_btn_pressed():
	sfx.stream = PRESSED
	sfx.play()
	ui.visible = false
	settings_menu.show_self()

func _on_settings_menu_hiding():
	start_btn.grab_focus()
	ui.visible = true

func _on_cutscene_animation_player_animation_finished(anim_name):
	if anim_name == "fly_in":
		cutscene_animation_player.play("float")
		start_btn.grab_focus()

func _on_leaderboard_pressed():
	sfx.stream = PRESSED
	sfx.play()
	ui.visible = false
	leaderboard.show_self()

func _on_leaderboard_hiding():
	start_btn.grab_focus()
	ui.visible = true
