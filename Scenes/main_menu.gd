extends Node3D

# SFX
const PRESSED = preload("res://Audio/SFXs/UI/buttonPressed.wav")
const SELECT = preload("res://Audio/SFXs/UI/buttonSelected.wav")
const START_PRESSED = preload("res://Audio/SFXs/UI/playPressed.wav")

@onready var main_menu_bgm = $MainMenuBGM
@onready var sfx = $SFX
var exiting = false

@onready var start_btn = $DebugUI/UI/CenterContainer/VBoxContainer/HBoxContainer/StartBtn
@onready var ui = $DebugUI/UI
@onready var settings_menu = $DebugUI/SettingsMenu
@onready var version_txt = $DebugUI/UI/VersionTxt
@onready var winner_pivot = $Pivot

func _ready():
	version_txt.text = "v" + str(Supervisor.version)
	
	winner_pivot.visible = Supervisor.winner
	
	start_btn.grab_focus()

func _process(_delta):
	
	
	# Raise volume of bgm when entering the scene
	if main_menu_bgm.volume_db < -0.95 and not exiting:
		main_menu_bgm.volume_db += 0.1
	
	# Look for selection input
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
		sfx.stream = SELECT
		sfx.play()
	
	# Lower volume when exiting the scene
	if exiting:
		main_menu_bgm.volume_db -= 0.2

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
