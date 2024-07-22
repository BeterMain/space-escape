extends MeshInstance3D

# SFX
const VL_HUNGER_1 = preload("res://Audio/SFXs/Bosses/andhrimnir_hunger_1.mp3")
const VL_HUNGER_2 = preload("res://Audio/SFXs/Bosses/andhrimnir_hunger_2.mp3")
const VL_REVENGE_1 = preload("res://Audio/SFXs/Bosses/andhrimnir_revenge_1.mp3")
const VL_REVENGE_2 = preload("res://Audio/SFXs/Bosses/andhrimnir_revenge_2.mp3")
const VL_HALF_WAY = preload("res://Audio/SFXs/Bosses/andhrimnir_halfway.mp3")
const VL_OPENING_1 = preload("res://Audio/SFXs/Bosses/andhrimnir_opening_1.mp3")
const VL_OPENING_2 = preload("res://Audio/SFXs/Bosses/andhrimnir_opening_2.mp3")
const VL_OPENING_3 = preload("res://Audio/SFXs/Bosses/andhrimnir_opening_3.mp3")

@onready var sfx = $SFX
@onready var voice_line_sfx = $VoiceLineSFX

var opening_voice_lines = [VL_OPENING_1, VL_OPENING_2, VL_OPENING_3]

# Health
var stats = BossHealth # Health = num of secs (5 min -> 300 sec)
@export var max_health = 2.0

@onready var hurtbox = $HurtBox/CollisionShape3D

# Ability management
const VINES = preload("res://Enemies/Bosses/vines.tscn")

@onready var ability_timer = $AbilityTimer
var abilities = ["revenge", "hunger", "idle"] # 2 Abilities with 1 being a placeholder
var current_ability = null
var desperation_started = false

@export var hunger_duration = 5.0
@export var revenge_duration = 5.0

signal revenge
signal hunger
signal ability_changed
signal desperation
signal idle
signal dead
signal half_way

func _ready():
	randomize()
	choose_new_ability()
	
	# Choose opening vl
	opening_voice_lines.shuffle()
	play_voice_line(opening_voice_lines.pick_random())
	
	# Set stats
	stats.max_health = max_health
	stats.health = max_health
	stats.no_health.connect(die)

func _process(delta):
	# Manage Health
	stats.health -= 0.01 * delta
	
	if stats.health <= 0.15:
		desperation.emit()
		desperation_started = true
	
	if stats.health < max_health / 2.0:
		half_way.emit()
	
	# Manage current ability
	manage_abilities()

func manage_abilities():
	match current_ability:
		"hunger":
			hunger_ability()
		
		"revenge":
			revenge_ability()
		
		"idle":
			idle.emit()
			# Check if we can start the timer and if the final phase has started
			if ability_timer.time_left == 0 and not desperation_started:
				ability_timer.start(randi_range(3, 8))
			else:
				choose_new_ability()

# Misc funcs
func die():
	dead.emit()
	
	visible = false
	# Play anim
	queue_free()

func play_voice_line(sound):
	voice_line_sfx.stop()
	voice_line_sfx.stream = sound
	voice_line_sfx.play()

func play_sfx(sound):
	sfx.stop()
	sfx.stream = sound
	sfx.play()

# Ability funcs
func stop_abilities():
	ability_timer.stop()
	current_ability = "idle"

func choose_new_ability():
	# Emit and choose ability
	ability_changed.emit()
	current_ability = abilities.pick_random()
	# Play sfx
	match current_ability:
		"revenge":
			spawn_vines()
			var revenge_vls = [VL_REVENGE_1, VL_REVENGE_2]
			revenge_vls.shuffle()
			play_voice_line(revenge_vls.pick_random())
			
		"hunger":
			var hunger_vls = [VL_HUNGER_1, VL_HUNGER_2]
			hunger_vls.shuffle()
			play_voice_line(hunger_vls.pick_random())
	
	# Shuffle
	abilities.shuffle()

# revenge ability
func revenge_ability():
	revenge.emit()
	if ability_timer.time_left == 0:
		ability_timer.start(revenge_duration)

# hunger Ability
func hunger_ability():
	hunger.emit()
	if ability_timer.time_left == 0:
		ability_timer.start(hunger_duration)

func spawn_vines():
	var vines = VINES.instantiate()
	vines.position = get_parent().position
	get_parent().add_child(vines)

# Connect Funs
func _on_ability_timer_timeout():
	choose_new_ability()

func _on_hurt_box_area_entered(area):
	stats.health -= area.boss_damage
