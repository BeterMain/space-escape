extends Node

var events = [
	"all_aliens",
	"tax_return",
	"ragnarok",
	"asteriod_belt",
	"powerup_frenzy",
	"nothing"
]

signal all_aliens
signal tax_return
signal ragnarok
signal asteriod_belt
signal powerup_frenzy
signal nothing

func _ready():
	randomize()
	

func pick_random_event():
	var current_event = "nothing"
	events.shuffle()
	current_event = events.pick_random()
	events.shuffle()
	
	match current_event:
		
		"all_aliens":
			all_aliens.emit()
		
		"tax_return":
			tax_return.emit()
		
		"ragnarok":
			ragnarok.emit()
		
		"asteriod_belt":
			asteriod_belt.emit()
		
		"powerup_frenzy":
			powerup_frenzy.emit()
		
		"nothing":
			nothing.emit()
	
