extends MeshInstance3D

# SFX
const SFX_BURP = preload("res://Audio/SFXs/Bosses/dugBurp.mp3")
const SFX_FART = preload("res://Audio/SFXs/Bosses/dugFart.mp3")
const VL_HALF_WAY = preload("res://Audio/SFXs/Bosses/dugHalfWay.mp3")
const VL_OPENING_1 = preload("res://Audio/SFXs/Bosses/dugOpening_1.mp3")
const VL_OPENING_2 = preload("res://Audio/SFXs/Bosses/dugOpening_2.mp3")

@onready var sfx = $SFX
@onready var voice_line_sfx = $VoiceLineSFX

var opening_voice_lines = [VL_OPENING_1, VL_OPENING_2]

# Health
var stats = BossHealth # Health = num of secs (5 min -> 300 sec)
@export var max_health = 2.0

@onready var hurtbox = $HurtBox/CollisionShape3D

# Ability management
@onready var ability_timer = $AbilityTimer
var abilities = ["fart", "burp", "idle"] # 2 Abilities with 1 being a placeholder
var current_ability = null
var desperation_started = false

@export var max_fart_duration = 20
@export var max_burp_duration = 15
var fart_duration = 20 # value in seconds
var burp_duration = 15

signal fart
signal burp
signal ability_changed
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
		fart_duration = max_fart_duration / 2.0
		burp_duration = max_burp_duration / 2.0
		
		desperation_started = true
	
	if stats.health < max_health / 2.0:
		half_way.emit()
	
	# Manage current ability
	manage_abilities()

func manage_abilities():
	match current_ability:
		"fart":
			fart_ability()
		
		"burp":
			burp_ability()
		
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
	sfx.stop()
	sfx.stream = sound
	sfx.play()

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
		"fart":
			play_sfx(SFX_FART)
			
		"burp":
			play_sfx(SFX_BURP)
	
	# Shuffle
	abilities.shuffle()

# Fart ability
func fart_ability():
	fart.emit()
	if ability_timer.time_left == 0:
		ability_timer.start(fart_duration)

# Burp Ability
func burp_ability():
	burp.emit()
	if ability_timer.time_left == 0:
		ability_timer.start(burp_duration)

# Connect Funs
func _on_ability_timer_timeout():
	choose_new_ability()

func _on_hurt_box_area_entered(area):
	stats.health -= area.boss_damage
	

