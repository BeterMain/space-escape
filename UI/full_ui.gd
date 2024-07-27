extends CanvasLayer

const SELECT = preload("res://Audio/SFXs/UI/buttonSelected.wav")
const PRESSED = preload("res://Audio/SFXs/UI/buttonPressed.wav")

const HEALTH_AND_BOOST_UI = preload("res://UI/health_and_boost_ui.png")
const HEALTH_UI = preload("res://UI/health_ui.png")

# Onready vars
@onready var boss_health_txt = $Control/BossHealthTxt
@onready var boss_healthbar = $Control/BossHealthTxt/BossHealthbar
@onready var distance_txt = $Control/DistanceTxt
@onready var continue_btn = $Control/ContinuePrompt/PromptBG/Elements/Buttons/ContinueBtn
@onready var continue_prompt = $Control/ContinuePrompt
@onready var sfx = $Control/ContinuePrompt/SFX
@onready var panel_txt = $Control/ContinuePrompt/PromptBG/Elements/Events/CenterContainer/VBoxContainer/PanelTxt
@onready var death_prompt = $Control/DeathPrompt
@onready var death_back_btn = $Control/DeathPrompt/PromptBG/Elements/BackBtn
@onready var stats_txt = $Control/DeathPrompt/PromptBG/Elements/PanelContainer/StatsTxt
@onready var boost_bar = $Control/BoostBar
@onready var player_health = $Control/PlayerHealth
@onready var animation_player = $AnimationPlayer
@onready var player_healthbar = $Control/PlayerHealthbar
@onready var leaderboard_functions = $LeaderboardFunctions

# Boss Vars
var boss_active = false
var current_boss = "Boss"

func _process(_delta):
	
	if boost_bar.visible:
		player_health.texture = HEALTH_AND_BOOST_UI
	else:
		player_health.texture = HEALTH_UI
	
	if PlayerStats.health <= 1:
		animation_player.play("change_health")
	
	if continue_prompt.visible:
		if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
			sfx.stop()
			sfx.stream = SELECT
			sfx.play()

func display_boss_health():
	distance_txt.visible = false
	boss_healthbar.reinitialize()
	boss_health_txt.text = current_boss
	match current_boss:
		"Dug the World Eater":
			animation_player.play("dug")
		
		"Theodore Blackwood":
			animation_player.play("theodore")
		
		"Andhrímnir the Chef of the Gods":
			animation_player.play("andhrimnir")
	
	boss_health_txt.visible = true
	boss_active = true

func display_normal():
	distance_txt.visible = true
	boss_health_txt.visible = false
	boss_active = false
	continue_prompt.visible = false

func display_continue_prompt(upcoming_event):
	continue_prompt.visible = true
	panel_txt.text = upcoming_event
	continue_btn.grab_focus()
	leaderboard_functions._upload_score(Supervisor.highscore_distance)
	
	var position = len(Supervisor.code_collected)
	# Check if can add code key to collection
	if position < len(Supervisor.code_key):
		Supervisor.code_collected += Supervisor.code_key[position]

func display_death_prompt(distance):
	death_prompt.visible = true
	boss_health_txt.visible = false
	distance_txt.visible = false
	boss_active = false
	stats_txt.text = "Distance: " + str(int(distance)) + "m\nHighscore: " + str(int(Supervisor.highscore_distance)) + "m"
	leaderboard_functions._upload_score(Supervisor.highscore_distance)
	death_back_btn.grab_focus()

func _on_back_btn_pressed():
	sfx.stop()
	sfx.stream = PRESSED
	sfx.play()
	SceneManager.change_scene_to_file("res://Scenes/upgrade_screen.tscn", "fade")

func _on_continue_btn_pressed():
	sfx.stop()
	sfx.stream = PRESSED
	sfx.play()
	Supervisor.save_all()
	display_normal()
