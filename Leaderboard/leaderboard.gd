extends Control

# Sounds
const PRESSED = preload("res://Audio/SFXs/UI/buttonPressed.wav")
const SELECT = preload("res://Audio/SFXs/UI/buttonSelected.wav")

# Onready
@onready var name_text_edit = $Control/HBoxContainer/NameSubmittion/NameTextEdit
@onready var info = $Control/HBoxContainer/Panel/Table/Info
@onready var functions = $Functions
@onready var welcome_text = $Control/WelcomeText
@onready var error_txt = $Control/HBoxContainer/NameSubmittion/ErrorTxt
@onready var back_btn = $Control/BackBtn
@onready var sfx = $SFX
@onready var submit_btn = $Control/HBoxContainer/NameSubmittion/SubmitBtn

var banned_names = ["ASS", "FAG", "NIG", "KKK"]

signal hiding

func show_self():
	visible = true
	functions._upload_score(Supervisor.highscore_distance)
	if functions.authentication_failed:
		welcome_text.text = "Leaderboard Servers Are Under Maintenance...\nScores will not be saved...\nSorry"
		submit_btn.disabled = true
	back_btn.grab_focus()

func hide_self():
	# Hide
	visible = false
	functions._upload_score(Supervisor.highscore_distance)
	hiding.emit()

func play_sfx(sound):
	sfx.stop()
	sfx.stream = sound
	sfx.play()

func _on_functions_leaderboard_changed():
	info.text = functions.leaderboard

func _on_submit_btn_pressed():
	var safe_name = true
	# grab text from ui and make it have no spaces or tabs
	var player_name = name_text_edit.text.to_upper().strip_edges(true,true).strip_escapes()
	# only allow 3 character in a player name
	player_name = player_name.erase(3, player_name.length())
	# Check if name is a banned name
	if player_name in banned_names:
		safe_name = false
	
	# Apply name to player account on LootLocker
	if not player_name.is_empty() and safe_name:
		functions._change_player_name(player_name)
		name_text_edit.clear()
		submit_btn.text = "Submit Name"
		error_txt.text = ""
	else:
		submit_btn.text = "Failed, Try Again"
		error_txt.text = "Name is not allowed"

func _on_functions_player_name_changed():
	welcome_text.text = "Welcome " + functions.player

func _on_functions_error():
	if not functions.error_message.is_empty():
		error_txt.text = functions.error_message

func _on_back_btn_pressed():
	play_sfx(PRESSED)
	hide_self()
