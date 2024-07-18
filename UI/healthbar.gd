extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar
var stats = PlayerStats
@export_enum("PlayerStats", "BossHealth") var stat_choice = "PlayerStats":
	set(value):
		match value:
			"PlayerStats":
				stats = PlayerStats
			
			"BossHealth":
				stats = BossHealth



func _ready():
	max_value = stats.max_health
	damage_bar.max_value = stats.max_health
	stats.health_changed.connect(start_timer)

func reinitialize():
	if stat_choice == "BossHealth":
		max_value = stats.max_health
	else:
		max_value = stats.max_health
	damage_bar.max_value = stats.max_health

func start_timer():
	value = stats.health
	timer.start()

func _on_timer_timeout():
	damage_bar.value = stats.health
