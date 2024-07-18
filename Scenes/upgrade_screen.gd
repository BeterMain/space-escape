extends Node3D

# SFX
const PRESSED = preload("res://Audio/SFXs/UI/buttonPressed.wav")
const DENY = preload("res://Audio/SFXs/UI/buttonDeny.wav")
const SELECT = preload("res://Audio/SFXs/UI/buttonSelected.wav")

# Onready
@onready var play_btn = $UI/RestartPanel/HBoxContainer/ContinueBtn
@onready var particles = $SubViewportContainer/SubViewport/Particles

@onready var event_txt = $UI/MoneyPanel/HBoxContainer/EventTxt
@onready var money_txt = $UI/MoneyPanel/HBoxContainer/MoneyTxt
@onready var health_txt = $UI/UpgradePanel/CenterContainer/Upgrades/HealthUpgrade/HealthTxt
@onready var boost_txt = $UI/UpgradePanel/CenterContainer/Upgrades/BoostUpgrade/BoostTxt
@onready var bubble_txt = $UI/UpgradePanel/CenterContainer/Upgrades/BubbleUpgrade/BubbleTxt
@onready var distance_txt = $UI/UpgradePanel/CenterContainer/Upgrades/DistanceUpgrade/DistanceTxt

@onready var bubble_cost_txt = $UI/UpgradePanel/CenterContainer/Upgrades/BubbleUpgrade/BubbleCostTxt
@onready var distance_cost_txt = $UI/UpgradePanel/CenterContainer/Upgrades/DistanceUpgrade/DistanceCostTxt
@onready var health_cost_txt = $UI/UpgradePanel/CenterContainer/Upgrades/HealthUpgrade/HealthCostTxt
@onready var boost_cost_txt = $UI/UpgradePanel/CenterContainer/Upgrades/BoostUpgrade/BoostCostTxt

@onready var bubble_btn = $UI/UpgradePanel/CenterContainer/Upgrades/BubbleUpgrade/BubbleBtn
@onready var distance_btn = $UI/UpgradePanel/CenterContainer/Upgrades/DistanceUpgrade/DistanceBtn
@onready var health_btn = $UI/UpgradePanel/CenterContainer/Upgrades/HealthUpgrade/HealthBtn
@onready var boost_btn = $UI/UpgradePanel/CenterContainer/Upgrades/BoostUpgrade/BoostBtn

@onready var blaster_txt = $UI/UpgradePanel/CenterContainer/Upgrades/BlasterUpgrade/BlasterTxt
@onready var blaster_cost_txt = $UI/UpgradePanel/CenterContainer/Upgrades/BlasterUpgrade/BlasterCostTxt
@onready var blaster_btn = $UI/UpgradePanel/CenterContainer/Upgrades/BlasterUpgrade/BlasterBtn
@onready var ui_animation_player = $UIAnimationPlayer

@onready var upgrade_bgm = $UpgradeBGM
@onready var sfx = $SFX
var exiting = false

@onready var events_manager = $SubViewportContainer/SubViewport/EventsManager

func _ready():
	play_btn.grab_focus()
	particles.emitting = true
	
	events_manager.pick_random_event()
	
	update_text()
	if Supervisor.blaster_unlocked:
		blaster_txt.text = "Rainbow Pizza Blaster"
		blaster_cost_txt.text = "OBTAINED"
		ui_animation_player.play("obtained_blaster")
		blaster_btn.disabled = true
	else:
		blaster_txt.text = "??????????????"
		blaster_cost_txt.text = str(Supervisor.blaster_cost)
	

func _process(_delta):
	# TODO: Add ability to have player model react to upgrades
	
	if Input.is_action_just_pressed("test"):
		Supervisor.current_cash += 5000
		update_text()
	
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		sfx.stream = SELECT
		sfx.play()
	
	# Handle BGM
	if upgrade_bgm.volume_db < -0.95 and not exiting:
		upgrade_bgm.volume_db += 0.1
	
	if exiting:
		upgrade_bgm.volume_db -= 0.2

func update_text():
	# Cheese Coins management
	money_txt.text = "Cheese Coins: $" + str(Supervisor.current_cash)
	
	# Upgrade text management
	bubble_txt.text = "Bubble Shield: LVL " + str(Supervisor.bubble_level)
	distance_txt.text = "Distance Skip LVL: " + str(Supervisor.distance_level)
	health_txt.text = "Health LVL: " + str(Supervisor.health_level)
	boost_txt.text = "Boost Gauge LVL: " + str(Supervisor.boost_level)
	
	# Upgrade cost text Management
	if Supervisor.bubble_next_cost != 0:
		bubble_cost_txt.text = "$" + str(Supervisor.bubble_next_cost)
	else:
		bubble_cost_txt.text = "MAX LEVEL"
		bubble_btn.disabled = true
	
	if Supervisor.health_next_cost != 0:
		health_cost_txt.text = "$" + str(Supervisor.health_next_cost)
	else:
		health_cost_txt.text = "MAX LEVEL"
		health_btn.disabled = true
	
	if Supervisor.distance_next_cost != 0:
		distance_cost_txt.text = "$" + str(Supervisor.distance_next_cost)
	else:
		distance_cost_txt.text = "MAX LEVEL"
		distance_btn.disabled = true
	
	if Supervisor.boost_next_cost != 0:
		boost_cost_txt.text = "$" + str(Supervisor.boost_next_cost)
	else:
		boost_cost_txt.text = "MAX LEVEL"
		boost_btn.disabled = true

func play_sfx(sound):
	sfx.stop()
	sfx.stream = sound
	sfx.play()

func _on_continue_btn_pressed():
	# SFX
	play_sfx(PRESSED)
	# Change scene
	SceneManager.change_scene_to_file("res://Levels/level.tscn", 'fade')
	exiting = true

func _on_main_menu_btn_pressed():
	# SFX
	play_sfx(PRESSED)
	# Change scene
	SceneManager.change_scene_to_file("res://Scenes/main_menu.tscn", 'fade')
	exiting = true

func _on_bubble_btn_pressed():
	# Change scene
	if Supervisor.upgrade_bubble():
		# SFX
		play_sfx(PRESSED)
		# Update
		update_text()
	else:
		play_sfx(DENY)

func _on_distance_btn_pressed():
	# Change scene
	if Supervisor.upgrade_d_boost():
		# SFX
		play_sfx(PRESSED)
		# Update
		update_text()
	else:
		play_sfx(DENY)

func _on_health_btn_pressed():
	# Change scene
	if Supervisor.upgrade_health():
		# SFX
		play_sfx(PRESSED)
		# Update
		update_text()
	else:
		play_sfx(DENY)

func _on_boost_btn_pressed():
	# Change scene
	if Supervisor.upgrade_boost():
		# SFX
		play_sfx(PRESSED)
		# Update
		update_text()
	else:
		play_sfx(DENY)

func _on_upgrade_bgm_finished():
	upgrade_bgm.play()

func _on_events_manager_all_aliens():
	event_txt.text = "Event: Oops All Aliens!"
	Supervisor.next_event = "all_aliens"

func _on_events_manager_asteriod_belt():
	event_txt.text = "Event: Asteriod Belt"
	Supervisor.next_event = "asteriod_belt"

func _on_events_manager_nothing():
	event_txt.text = "Event: Nothing"
	Supervisor.next_event = "nothing"

func _on_events_manager_powerup_frenzy():
	event_txt.text = "Event: Powerup Frenzy"
	Supervisor.next_event = "powerup_frenzy"

func _on_events_manager_ragnarok():
	event_txt.text = "Event: Ragnarök"
	Supervisor.next_event = "ragnarok"

func _on_events_manager_tax_return():
	event_txt.text = "Event: Tax Return"
	Supervisor.next_event = "tax_return"

func _on_blaster_btn_pressed():
	if Supervisor.upgrade_blaster():
		play_sfx(PRESSED)
		update_text()
		blaster_txt.text = "Rainbow Pizza Blaster"
		blaster_cost_txt.text = "OBTAINED"
		ui_animation_player.play("obtained_blaster")
		blaster_btn.disabled = true
	else:
		play_sfx(DENY)
