extends Control

# Sfx
const PRESSED = preload("res://Audio/SFXs/UI/buttonPressed.wav")
const SELECT = preload("res://Audio/SFXs/UI/buttonSelected.wav")
@onready var sfx = $SFX

# Onready vars
@onready var resume_btn = $Buttons/ResumeBtn
@onready var main_menu_btn = $Buttons/MainMenuBtn
@onready var settings_btn = $Buttons/SettingsBtn
@onready var animation_player = $AnimationPlayer
@onready var settings_menu = $SettingsMenu
@onready var buttons = $Buttons
@onready var hint_txt = $CodeHints/HintTxt

# Vars
var already_played = false

var is_paused = false : set = set_is_paused

func _process(_delta):
	
	# Allow ui interaction if game is paused
	if is_paused:
		# Check if pressing left
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			# Sfx
			play_sfx(SELECT)
	
	# Check if for pause input
	if Input.is_action_just_pressed("pause"):
		self.is_paused = !is_paused
		if is_paused: 
			resume_btn.grab_focus()
			hint_txt.text = Supervisor.code_collected

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	
	animation_player.play("default")
	animation_player.play("glow")

func play_sfx(sound):
	sfx.stop()
	sfx.stream = sound
	sfx.play()
	
func _on_resume_btn_pressed():
	play_sfx(PRESSED)
	
	self.is_paused = false

func _on_main_menu_btn_pressed():
	play_sfx(PRESSED)
	
	SceneManager.change_scene_to_file("res://Scenes/upgrade_screen.tscn", 'fade')
	self.is_paused = false
	
func _on_quit_btn_pressed():
	play_sfx(PRESSED)
	buttons.visible = false
	settings_menu.show_self()
	

func _on_settings_menu_hiding():
	resume_btn.grab_focus()
	buttons.visible = true
