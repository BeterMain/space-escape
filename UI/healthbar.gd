extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var stats = PlayerStats
@export_enum("PlayerStats", "BossHealth", "Boost") var stat_choice = "PlayerStats":
	set(value):
		match value:
			"PlayerStats":
				stats = PlayerStats
			
			"BossHealth":
				stats = BossHealth
			
			"Boost":
				stats = null

var can_decrease = false

func _ready():
	if stats:
		max_value = stats.max_health
		damage_bar.max_value = stats.max_health
		stats.health_changed.connect(start_timer)
	else:
		max_value = Supervisor.max_boost_uses
		damage_bar.max_value = Supervisor.max_boost_uses
		damage_bar.value = damage_bar.max_value
		visible = Supervisor.boost_active

func _process(_delta):
	if not stats:
		check_boost_val_change()
		max_value = Supervisor.max_boost_uses
		value = Supervisor.boosts_left
		
	if int(value) == damage_bar.value:
		can_decrease = false
	
	if int(value) < damage_bar.value and can_decrease:
		damage_bar.value -= 0.01
	
func check_boost_val_change():
	var previous_value = Supervisor.boosts_left
	if previous_value != value:
		start_timer()

func reinitialize():
	if stats:
		if stat_choice == "BossHealth":
			max_value = stats.max_health
		else:
			max_value = stats.max_health
		damage_bar.max_value = stats.max_health

func start_timer():
	if stats:
		value = stats.health
	timer.start()

func _on_timer_timeout():
	if value != 0:
		can_decrease = true
	else:
		damage_bar.value = value
	
