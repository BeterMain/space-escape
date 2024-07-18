extends Control

const PRESSED = preload("res://Audio/SFXs/UI/buttonPressed.wav")
const SELECT = preload("res://Audio/SFXs/UI/buttonSelected.wav")

@onready var master_volume = $CenterContainer/VBoxContainer/Volume/VolumeSliders/MasterVolume
@onready var bgm_volume = $CenterContainer/VBoxContainer/Volume/VolumeSliders/BGMVolume
@onready var sfx_volume = $CenterContainer/VBoxContainer/Volume/VolumeSliders/SFXVolume
@onready var voice_line_volume = $CenterContainer/VBoxContainer/Volume/VolumeSliders/VoiceLineVolume
@onready var resolutions = $CenterContainer/VBoxContainer/ScreenResolution/ResolutionOptions/Resolutions
@onready var back_button = $BackButton
@onready var sfx = $SFX
@onready var clear_button = $ClearButton
@onready var confirm_button = $ConfirmButton
@onready var fps_checkbox = $CenterContainer/VBoxContainer/ScreenResolution/ResolutionOptions/FPSCheckbox

signal hiding

@export var right_stick_speed = 2.0

func _ready():
	master_volume.value = Supervisor.master_db
	Supervisor.set_master_db(master_volume.value)
	
	bgm_volume.value = Supervisor.bgm_db
	Supervisor.set_bgm_db(bgm_volume.value)
	
	sfx_volume.value = Supervisor.sfx_db
	Supervisor.set_sfx_db(sfx_volume.value)
	
	voice_line_volume.value = Supervisor.vl_db
	Supervisor.set_vl_db(voice_line_volume.value)
	
	resolutions.disabled = Supervisor.fullscreen_on

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		hide_self()
	
	# Right stick movement
	'''
	if is_controller_connected():
		var right_stick_value = Vector2(
				Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
				Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
			)
		
		# Apply right stick movement
		if master_volume.has_focus():
			master_volume.value += right_stick_value.x * right_stick_speed * delta
			# Clamp the slider value to its min and max
			master_volume.value = clamp(master_volume.value, master_volume.min_value, master_volume.max_value)
		if bgm_volume.has_focus():
			bgm_volume.value += right_stick_value.x * right_stick_speed * delta
			# Clamp the slider value to its min and max
			bgm_volume.value = clamp(bgm_volume.value, bgm_volume.min_value, bgm_volume.max_value)
		if sfx_volume.has_focus():
			sfx_volume.value += right_stick_value.x * right_stick_speed * delta
			# Clamp the slider value to its min and max
			sfx_volume.value = clamp(sfx_volume.value, sfx_volume.min_value, sfx_volume.max_value)
		if voice_line_volume.has_focus():
			voice_line_volume.value += right_stick_value.x * right_stick_speed * delta
			# Clamp the slider value to its min and max
			voice_line_volume.value = clamp(voice_line_volume.value, voice_line_volume.min_value, voice_line_volume.max_value)
		
	'''
		

	
func center_window():
	var center_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size()/2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(center_screen - window_size/2)

func is_controller_connected() -> bool:
	var device_count = Input.get_connected_joypads().size()
	return device_count > 0

func show_self():
	visible = true
	back_button.grab_focus()

func play_sfx(sound):
	sfx.stop()
	sfx.stream = sound
	sfx.play()

func reset_ui():
	back_button.grab_focus()
	
	resolutions.disabled = true
	
	master_volume.value = Supervisor.master_db
	Supervisor.set_master_db(master_volume.value)
	
	bgm_volume.value = Supervisor.bgm_db
	Supervisor.set_bgm_db(bgm_volume.value)
	
	sfx_volume.value = Supervisor.sfx_db
	Supervisor.set_sfx_db(sfx_volume.value)
	
	voice_line_volume.value = Supervisor.vl_db
	Supervisor.set_vl_db(voice_line_volume.value)
	
	resolutions.selected = resolutions.get_item_id(3)
	$CenterContainer/VBoxContainer/ScreenResolution/ResolutionOptions/FullScreenCheckbox.button_pressed = true
	$CenterContainer/VBoxContainer/ScreenResolution/ResolutionOptions/FPSCheckbox.button_pressed = true

func reset_buttons():
	clear_button.visible = true
	clear_button.disabled = false
	confirm_button.visible = false
	confirm_button.disabled = true

func hide_self():
	# save
	Supervisor.save_all()
	
	# Hide
	visible = false
	hiding.emit()
	reset_buttons()

func _on_resolutions_item_selected(index):
	play_sfx(PRESSED)
	
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		3:
			DisplayServer.window_set_size(Vector2i(1152, 648))
		
	center_window()

func _on_full_screen_checkbox_toggled(toggled_on):
	play_sfx(SELECT)
	
	resolutions.disabled = toggled_on
	Supervisor.fullscreen_on = toggled_on
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_master_volume_value_changed(value):
	if value == master_volume.min_value:
		Supervisor.set_master_db(-72)
	else:
		Supervisor.set_master_db(value)
	
	play_sfx(SELECT)

func _on_bgm_volume_value_changed(value):
	Supervisor.set_bgm_db(value)
	play_sfx(SELECT)

func _on_sfx_volume_value_changed(value):
	Supervisor.set_sfx_db(value)
	play_sfx(SELECT)
	
func _on_voice_line_volume_value_changed(value):
	Supervisor.set_vl_db(value)
	play_sfx(SELECT)

func _on_back_button_pressed():
	hide_self()
	
	play_sfx(PRESSED)

func _on_clear_button_pressed():
	clear_button.visible = false
	clear_button.disabled = true
	
	confirm_button.visible = true
	confirm_button.disabled = false
	confirm_button.grab_focus()

func _on_confirm_button_pressed():
	reset_buttons()
	Save.clear_save()
	Supervisor.load_all()
	reset_ui()
	
func _on_fps_checkbox_toggled(toggled_on):
	Supervisor.display_fps = toggled_on
