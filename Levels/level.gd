extends Node3D

# Sound vars
const SHOWDOWN = preload("res://Audio/BGM/Showdown.wav")
const SELECT = preload("res://Audio/SFXs/UI/buttonSelected.wav")
const FAIL_INPUT = preload("res://Audio/SFXs/UI/failInput.wav")
const CORRECT = preload("res://Audio/SFXs/UI/playPressed.wav")
const INPUT_GATHERED = preload("res://Audio/SFXs/UI/inputGathered.wav")
@onready var bgm = $BGM
@onready var sfx = $SFX
@onready var voice_lines = $VoiceLines

# Boss scenes
const DUG = preload("res://Enemies/Bosses/dug.tscn")
const THEODORE = preload("res://Enemies/Bosses/theodore.tscn")

# Onready vars
@onready var full_ui = $FullUI
@onready var distance_txt = $FullUI/Control/DistanceTxt
@onready var upgrade_btn = $FullUI/PauseMenu/Buttons/MainMenuBtn

@onready var space_particles = $SubViewportContainer/SubViewport/SpaceParticles

@onready var powerup_manager = $SubViewportContainer/SubViewport/PowerupManager
@onready var gap_timer = $SubViewportContainer/SubViewport/PowerupManager/GapTimer

@onready var boss_spawn_loc = $SubViewportContainer/SubViewport/BossSpawnLoc

@onready var spawner = $SubViewportContainer/SubViewport/Spawner
@onready var animation_player = $AnimationPlayer
@onready var player = $SubViewportContainer/SubViewport/Player
@onready var input_timer = $SubViewportContainer/SubViewport/InputTimer
@onready var code_inputs = $FullUI/Control/CodeInputs

@onready var events_manager = $SubViewportContainer/SubViewport/EventsManager

# Export vars
@export var level_speed = 0.01 # the lower the number the faster the level
@export var growth_offset = 2500.0 # target for the level

var bosses = [THEODORE, DUG]
var boss_scene = null
@export var required_wins = 3
var bosses_beat = 0

# vars
@onready var distance = Supervisor.current_distance + (growth_offset * Supervisor.distance_skip)
var target = 0
var distance_multiplier = 0.5

var default_powerupblock_threshold = growth_offset * 0.2 
var powerupblock_threshold = default_powerupblock_threshold  # Spawn power block at 1/5 intervals of the cap

var boss_started = false
var stop_level = false
var can_input_code = true
var matched = false
var inputs = ""
var current_event = "nothing"

func _ready():
	randomize()
	# Check if first load
	Save.first_load = false
	Save.save_data()
	
	# Connect signals
	Supervisor.check_upgrades()
	full_ui.continue_btn.connect("pressed", start_level)
	PlayerStats.no_health.connect(player_death)
	# Set increasing target
	target = Supervisor.current_distance + growth_offset
	# Check if distance was saved
	if int(distance) == int(target):
		target += growth_offset
	# Set vol and start star particles
	Supervisor.set_master_db(Supervisor.master_db)
	space_particles.emitting = true
	
	# Activating current event
	current_event = Supervisor.next_event 
	match current_event:
		
		"all_aliens":
			event_all_aliens()
		"tax_return":
			event_tax_return()
		"asteriod_belt":
			event_asteriod_belt()
		"powerup_frenzy":
			event_powerup_frenzy()
		"ragnarok":
			event_ragnarok()
		"nothing":
			event_nothing()
		_:
			event_nothing()

func _process(delta):
	upgrade_btn.disabled = bosses_beat < 1
	code_inputs.visible = can_input_code 
	# Handle Distance Calculation/Bosses
	if distance <= target:
		boss_started = false
		# Check for code inputs
		# ↑↓→←
		if can_input_code and len(inputs) <= len(Supervisor.code_key):
			if Input.is_action_just_pressed("ui_up"):
				inputs += "↑" 
				play_sfx(INPUT_GATHERED)
			elif Input.is_action_just_pressed("ui_down"):
				inputs += "↓"
				play_sfx(INPUT_GATHERED)
			elif Input.is_action_just_pressed("ui_left"):
				inputs += "←"
				play_sfx(INPUT_GATHERED)
			elif Input.is_action_just_pressed("ui_right"):
				inputs += "→"
				play_sfx(INPUT_GATHERED)
				
			code_inputs.text = inputs
			if inputs == Supervisor.code_key:
				spawn_final_boss()
		else:
			if input_timer.time_left != 0 and not matched:
				play_sfx(FAIL_INPUT)
				can_input_code = false
				spawner.start_spawning()
				bgm.restart_bgm()
				input_timer.stop()
				animation_player.play("normal_speed")
				
			# Run level
			if not stop_level:
				run_level(delta)
	else:
		if not boss_started:
			
			# Play boss bgm
			bgm.stop()
			bgm.stream = SHOWDOWN
			bgm.play()
			
			# Change scene for boss
			space_particles.speed_scale = 0.75
			
			spawner.clear_obstacles()
			spawner.boss_activated()
			
			spawner.interval = spawner.min_interval
			boss_started = true
			# Spawn Boss
			bosses.shuffle()
			boss_scene = bosses.pick_random()
			match boss_scene:
				THEODORE:
					spawn_theodore()
				
				DUG:
					spawn_dug()

# Boss funcs
func start_level():
	target += growth_offset
	distance = target * Supervisor.distance_skip
	distance_multiplier = 0.5
	boss_started = false
	stop_abilities()
	spawner.start_spawning()
	player.unlock_movement()
	bgm.restart_bgm()
	animation_player.play("normal_speed")

func spawn_final_boss():
	print("TODO: Make final boss")
	can_input_code = false
	matched = true
	play_sfx(CORRECT)
	SceneManager.change_scene_to_file("res://UI/win_screen.tscn", "fade")
	'''
	spawner.start_spawning()
	bgm.restart_bgm()
	'''

func spawn_dug():
	var boss = boss_scene.instantiate()
	boss.position = boss_spawn_loc.position
	
	full_ui.current_boss = "Dug"
	full_ui.display_boss_health()
	
	# Connect ability signals
	boss.fart.connect(spawner.activate_trail)
	boss.burp.connect(spawner.activate_double_speed)
	boss.idle.connect(stop_abilities)
	boss.ability_changed.connect(stop_abilities)
	boss.dead.connect(reset)
	boss.half_way.connect(spawn_halfway_box)
	
	# add to scene
	boss_spawn_loc.add_child(boss)

func spawn_theodore():
	var boss = boss_scene.instantiate()
	boss.position = boss_spawn_loc.position
	
	full_ui.current_boss = "Theodore Blackwood"
	full_ui.display_boss_health()
	
	# Connect ability signals
	boss.review.connect(spawner.activate_chase)
	boss.scream.connect(spawner.activate_double_speed)
	boss.exam.connect(slow_player)
	boss.ability_change.connect(stop_abilities)
	
	boss.half_way.connect(shorten_spawn_rate)
	boss.idle.connect(stop_abilities)
	boss.dead.connect(reset)
	
	# add to scene
	boss_spawn_loc.add_child(boss)

# theodore Ability funcs
func shorten_spawn_rate():
	spawner.shorten_spawn_rate()
	spawn_halfway_box()

func kill_boss():
	if boss_scene == THEODORE and boss_started:
		voice_lines.play()
	
	if boss_spawn_loc.get_child_count() > 0:
		boss_spawn_loc.get_child(0).queue_free()

func slow_player():
	if player:
		player.speed_lowered = true
		player.SPEED = player.MAX_SPEED / 2

# dug Ability funcs
func spawn_halfway_box():
	if gap_timer.time_left == 0:
		# Spawn Powerup Block
		powerup_manager.spawn_powerupblock()
		gap_timer.start(10)

func reset(player_dead=false):
	# Reset spawner
	spawner.clear_obstacles()
	spawner.stop_spawning()
	stop_abilities()
	
	# stop bgm
	bgm.stop()
	
	player.lock_movement()
	
	animation_player.play("to_default")
	if not player_dead:
		$SubViewportContainer/SubViewport/WaitTimer.start()
		Supervisor.set_distance(distance)
	else:
		stop_level = true

func stop_abilities():
	player.speed_lowered = false
	player.SPEED = player.MAX_SPEED
	
	spawner.stop_interferences()

# Misc funcs
func run_level(delta):
	# Increase distance count
	distance += distance_multiplier * delta
	distance_txt.text = str(int(distance)) + "m"
	distance_multiplier += level_speed 
	
	# Check for guaranteed powerup block 
	if int(distance+1) % int(powerupblock_threshold) == 0 and gap_timer.time_left == 0:
		# Spawn Powerup Block
		powerup_manager.spawn_powerupblock()
		gap_timer.start(0.5)

func play_sfx(sound):
	sfx.stop()
	sfx.stream = sound
	sfx.play()

func player_death():
	$SubViewportContainer/SubViewport/DeathTimer.start()
	kill_boss()
	
	reset(true) # Reset with no timer to restart
	
	if distance > Supervisor.highscore_distance:
		Supervisor.highscore_distance = distance

func activate_powerup_frenzy():
	powerupblock_threshold = 50

func deactivate_powerup_frenzy():
	powerupblock_threshold = default_powerupblock_threshold

# Connect Funcs
func _on_tree_exiting():
	space_particles.speed_scale = 0.5
	bgm.exiting = true

func _on_wait_timer_timeout():
	# Reset ui
	bosses_beat += 1
	if bosses_beat % required_wins == 0:
		events_manager.pick_random_event()
		full_ui.display_continue_prompt(current_event)
	else:
		full_ui.display_normal()
		start_level()

func _on_input_timer_timeout():
	can_input_code = false
	spawner.start_spawning()
	play_sfx(FAIL_INPUT)
	bgm.restart_bgm()
	animation_player.play("normal_speed")
	

# Event manager funcs
func event_all_aliens():
	current_event = "Oops All Aliens!"
	
	spawner.set_only_ufos(true)
	deactivate_powerup_frenzy()

func event_asteriod_belt():
	current_event = "Asteroid Belt"
	
	spawner.set_only_asteriods(true)
	deactivate_powerup_frenzy()

func event_nothing():
	current_event = "Nothing"
	
	spawner.set_double_money(false)
	spawner.set_only_asteriods(false)
	spawner.set_only_ufos(false)
	deactivate_powerup_frenzy()

func event_powerup_frenzy():
	current_event = "Powerup Frenzy"
	
	spawner.set_double_money(false)
	spawner.set_only_asteriods(false)
	spawner.set_only_ufos(false)
	activate_powerup_frenzy()

func event_ragnarok():
	current_event = "Ragnarök"
	
	print("TODO: Add another boss")
	spawner.set_double_money(false)
	spawner.set_only_asteriods(false)
	spawner.set_only_ufos(false)
	deactivate_powerup_frenzy()

func event_tax_return():
	current_event = "Tax Return"
	
	spawner.set_double_money(true)
	deactivate_powerup_frenzy()

func _on_events_manager_all_aliens():
	event_all_aliens()

func _on_events_manager_asteriod_belt():
	event_asteriod_belt()

func _on_events_manager_nothing():
	event_nothing()

func _on_events_manager_powerup_frenzy():
	event_powerup_frenzy()

func _on_events_manager_ragnarok():
	event_ragnarok()

func _on_events_manager_tax_return():
	event_tax_return()

# Death delay
func _on_death_timer_timeout():
	full_ui.display_death_prompt(distance)
