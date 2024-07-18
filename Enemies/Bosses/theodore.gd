extends MeshInstance3D

# SFXs
const VL_EXAM = preload("res://Audio/SFXs/Bosses/theodoreExam.mp3")
const VL_HALF_WAY = preload("res://Audio/SFXs/Bosses/theodoreHalfWay.mp3")
const VL_OPENING = preload("res://Audio/SFXs/Bosses/theodoreOpening.mp3")
const VL_REVIEW = preload("res://Audio/SFXs/Bosses/theodoreReview.mp3")
const VL_SCREAM = preload("res://Audio/SFXs/Bosses/theodoreScream.mp3")
const VL_WIN = preload("res://Audio/SFXs/Bosses/theodoreWin.mp3")

@onready var sfx = $SFX
var opening_finished = false

# Health
var stats = BossHealth # Health = num of secs (5 min -> 300 sec)
@export var max_health = 2.0

@onready var hurtbox = $HurtBox/CollisionShape3D

# Ability management
@onready var ability_timer = $AbilityTimer
@onready var scream_timer = $ScreamTimer

var abilities = ["review", "exam", "scream", "idle"] # 2 Abilities with 1 being a placeholder
var current_ability = null

@export var max_review_duration = 20
var review_duration = max_review_duration # value in seconds

@export var max_exam_duration = 20
var exam_duration = max_exam_duration

@export var scream_duration = 10
var screaming = false

var can_start = false
var desperation_started = false

# Signals
signal review
signal exam
signal scream
signal ability_change
signal idle
signal dead
signal half_way

func _ready():
	randomize()
	choose_new_ability()
	
	play_sfx(VL_OPENING)
	
	stats.health = max_health
	stats.max_health = max_health
	stats.no_health.connect(die)

func _process(delta):
	# Manage Health
	stats.health -= 0.01 * delta
	
	# Check if health is past desperation point
	if stats.health <= 0.15:
		# Make abilities change quicker
		review_duration = max_review_duration / 2.0
		exam_duration = max_exam_duration / 2.0
		# Remove idle
		desperation_started = true
		
		# Set scream to be ongoing
		scream_duration = 9999999999
		if abilities.has("scream"):
			current_ability = "scream"
	
	# Check if scream ability is activated
	if screaming:
		scream_ability()
	
	# Check if player reached halfway point
	if stats.health < max_health / 2.0:
		# Play sfx
		play_sfx(VL_HALF_WAY)
		
		# emit
		half_way.emit()
	
	# Manage current ability
	manage_abilities()

func manage_abilities():
	match current_ability:
		"review":
			review_ability()
		
		"exam":
			exam_ability()
		
		"scream":
			screaming = true
			choose_new_ability()
			if desperation_started:
				abilities.erase("scream")
		
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
	# PLay anim
	queue_free()

func play_sfx(sound):
	sfx.stop()
	sfx.stream = sound
	sfx.play()

# Ability funcs
func stop_abilities():
	ability_timer.stop()
	current_ability = "idle"

func choose_new_ability():
	ability_change.emit()
	
	current_ability = abilities.pick_random()
	
	if opening_finished:
		match current_ability:
			"review":
				play_sfx(VL_REVIEW)
			
			"exam":
				play_sfx(VL_EXAM)
			
			"scream":
				play_sfx(VL_SCREAM)
	
	abilities.shuffle()

# Review ability
func review_ability():
	# Emit
	review.emit()
	
	# Start timer
	if ability_timer.time_left == 0:
		ability_timer.start(review_duration)

# Exam ability 
func exam_ability():
	# Emit exam
	exam.emit()
	
	if ability_timer.time_left == 0:
		ability_timer.start(exam_duration)

# Scream ability
func scream_ability():
	# Emit
	scream.emit()
	
	# Start timer
	if scream_timer.time_left == 0:
		scream_timer.start(scream_duration)

# Connect Funs
func _on_ability_timer_timeout():
	choose_new_ability()

func _on_hurt_box_area_entered(area):
	stats.health -= area.boss_damage
	
func _on_scream_timer_timeout():
	screaming = false

func _on_sfx_finished():
	if sfx.stream == VL_OPENING:
		opening_finished = true
