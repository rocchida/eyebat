class_name PauseMenu
extends Control

## You can override this class to add buttons to your pause menu
## look at the function open_options_menu for an example of showing a submenu
## also remember to add a hide call for your menu in _input

signal resume
signal back_to_main_pressed

#region Variables
@export var canvas_layer : CanvasLayer
@export var nodes_to_focus: Array[Control]
@export var sound_hover : AudioStream
@export var sound_click : AudioStream
@export var empty_slot_texture : Texture

var playback : AudioStreamPlaybackPolyphonic
var temp_screenshot : Image

@onready var resume_game_button: Button = %ResumeGameButton
@onready var save_button: AnimatedButton = %SaveButton
@onready var load_button: AnimatedButton = %LoadButton
@onready var label_active_slot: Label = %Label_ActiveSlot
@onready var options_tab_menu: OptionsTabMenu = $Content/OptionsTabMenu
@onready var game_menu: MarginContainer = $Content/GameMenu
#endregion

func _ready():
	game_menu.hide()
	canvas_layer.hide();

	# no saving during battle
	if(get_parent() is BattleScene):
		save_button.disabled = true

	# connect to options menu back button pressed
	options_tab_menu.back_button_pressed.connect(_go_back_to_pause_menu)

func _enter_tree() -> void:
	# Create an audio player
	var player = AudioStreamPlayer.new()
	add_child(player)

	# Create a polyphonic stream so we can play sounds directly from it
	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	player.stream = stream
	player.play()
	# Get the polyphonic playback stream to play sounds
	playback = player.get_stream_playback()

	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node:Node) -> void:
	if node is Button:
		# If the added node is a button we connect to its mouse_entered and pressed signals
		# and play a sound
		node.mouse_entered.connect(_play_hover)
		node.focus_entered.connect(_play_hover)
		node.pressed.connect(_play_pressed)


func _play_hover() -> void:
	playback.play_stream(sound_hover, 0, 0, 1)


func _play_pressed() -> void:
	playback.play_stream(sound_click, 0, 0, 1)


func open_pause_menu():
	#Stops game and shows pause menu
	get_tree().paused = true
	label_active_slot.text = "Current Slot: " + SaveManager.active_save_name
	temp_screenshot = grab_temp_screenshot()
	load_current_slot_data()
	_go_back_to_pause_menu()

func _go_back_to_pause_menu():
	canvas_layer.show()
	game_menu.show()
	options_tab_menu.hide()
	resume_game_button.grab_focus.call_deferred()


func open_options_menu():
	options_tab_menu.show()
	options_tab_menu.load_options(true)
	options_tab_menu.have_options_changed = false
	options_tab_menu.tab_container.nodes_to_focus[0].grab_focus.call_deferred()
	game_menu.hide()


func grab_temp_screenshot() -> Image:
	return get_viewport().get_texture().get_image()


func load_current_slot_data():
	# Load screenshot
	var screenshot : Image = SaveManager.get_active_slot_screenshot()
	if screenshot != null:
		var texture = ImageTexture.create_from_image(screenshot)
		%Screenshot_Spot.texture = texture
	else:
		%Screenshot_Spot.texture = empty_slot_texture
		print("No screenshot for slot ", SaveManager.active_save_name, " found.")
		
	# Load save state time
	var savetime : int
	if SaveManager.save_data:
		savetime = SaveManager.save_data.save_time
	if savetime == null or typeof(savetime) != TYPE_INT or savetime == 0:
		%Label_SaveTime.text = ""
	else:
		var timeoffset = Time.get_time_zone_from_system().bias*60
		var save_time_string = Time.get_datetime_string_from_unix_time(savetime+timeoffset,true)
		
		%Label_SaveTime.text = save_time_string


func close_pause_menu():
	get_tree().paused = false
	canvas_layer.hide()
	game_menu.hide()
	resume.emit()


func _on_resume_game_button_pressed():
	close_pause_menu()


func _on_quit_button_pressed():
	SaveManager.delete_temp_saves()
	get_tree().quit()


func _on_back_to_menu_button_pressed():
	close_pause_menu()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	back_to_main_pressed.emit()
	SaveManager.unload_save()


func _input(event):
	var pause_pressed = event.is_action_pressed("ui_cancel") or event.is_action_pressed("menu");

	if pause_pressed and options_tab_menu.visible:
		accept_event()
		_go_back_to_pause_menu()
		return

	if pause_pressed and !game_menu.visible:
		accept_event()
		open_pause_menu()
		return
		
	if pause_pressed and visible:
		accept_event()
		close_pause_menu()
		return

	# used for debugging menu visibility
	# if event is not InputEventMouseMotion:
	# 	print("Pause Menu: Menu Input: ", event, "\nMain menu visible: ", game_menu.visible, "\nPause menu visible: ", visible)


func _on_save_button_pressed() -> void:
	var current_scene_name = get_tree().get_current_scene().get_name()
	var current_scene_path = get_tree().current_scene.scene_file_path
	var screenshot_to_save = temp_screenshot
	SaveManager.save_player_state(current_scene_name, current_scene_path,PlayerGlobal.player, SaveManager.active_save_name)
	SaveManager.save_scene_state(get_tree(),SaveManager.active_save_name)
	SaveManager.save_save_data(current_scene_name, current_scene_path, screenshot_to_save,SaveManager.active_save_name)
	_on_resume_game_button_pressed()


func _on_load_button_pressed() -> void:
	# For optionally storing data on disk rather than memory. Not using unless we have to.
	#SaveManager.delete_temp_saves()
	#SaveManager.copy_slot_saves_to_temp(get_tree(), SaveManager._active_save_name)

	# Load game and resume
	SaveManager.load_saved_game(get_tree(),SaveManager.active_save_name)
	_on_resume_game_button_pressed()
