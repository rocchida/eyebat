## This button holds save data and emits the save data when pressed.
class_name SaveSlotButton extends AnimatedButton

@onready var screenshot_spot: TextureRect = $MarginContainer/HBoxContainer/Screenshot_Spot
@onready var slot_name_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/SlotName
@onready var save_time_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/SaveTime

@export var empty_slot_screenshot : Texture2D

var _save_data : SaveData
## The save slot name
var save_slot_name : String
## The default save slot name for if the save data gets deleted
var default_save_slot_name : String

func _ready() -> void:
	pressed.connect(_on_save_slot_button_pressed)

	### BRINGING THIS OVER FROM AnimatedButton due to the override.
	#Attempt to make this work with focus
	self.focus_entered.connect(_on_focus_entered)
	self.focus_exited.connect(_on_focus_exited)
	self.pressed.connect(_on_pressed)
	
	# Duplicate the normal stylebox. We are going to use it as our base stylebox
	tween_stylebox = get_theme_stylebox('normal').duplicate()
	
	# Save the different styleboxes to be able to tween between their properties later
	styleboxes[BaseButton.DRAW_NORMAL] = get_theme_stylebox('normal').duplicate()
	styleboxes[BaseButton.DRAW_HOVER] = get_theme_stylebox('hover').duplicate()
	styleboxes[BaseButton.DRAW_PRESSED] = get_theme_stylebox('pressed').duplicate()
	styleboxes[BaseButton.DRAW_HOVER_PRESSED] = get_theme_stylebox('pressed').duplicate()
	
	# Override all the other styleboxes with our tween stylebox
	add_theme_stylebox_override('normal', tween_stylebox)
	add_theme_stylebox_override('hover', tween_stylebox)
	add_theme_stylebox_override('focus', tween_stylebox)
	add_theme_stylebox_override('pressed', tween_stylebox)

## Set the display and save data of the button. If save_data is null, will set it to a default state.
func set_save_data(save_data:SaveData):
	print("Save data: ", save_data)
	_save_data = save_data

	# set the default
	if _save_data == null:
		slot_name_label.text = "NEW GAME"
		save_time_label.text = ""
		screenshot_spot.texture = empty_slot_screenshot
		save_time_label.text = ""
		save_slot_name = default_save_slot_name
		return
	
	slot_name_label.text =  _save_data.save_name
	save_slot_name = _save_data.save_name
	var savetime : int
	savetime = _save_data.save_time
	var timeoffset = Time.get_time_zone_from_system().bias*60
	save_time_label.text = Time.get_datetime_string_from_unix_time(savetime+timeoffset,true)

	# Set screenshot
	var screenshot : Image = _save_data.screenshot
	if screenshot != null:
		screenshot_spot.texture = ImageTexture.create_from_image(screenshot)
	else:
		Global.debug_log("SaveSlotButton.gd","No screenshot for slot " + SaveManager.active_save_name + " found.")

func _on_save_slot_button_pressed() -> void:
	if _save_data:
		SaveManager.load_saved_game(get_tree(),save_slot_name)
	else:
		SceneSwitcher.start_new_game(save_slot_name);

func _on_delete_slot_pressed() -> void:
	if _save_data != null:
		SaveManager.delete_save(_save_data.save_name)
		set_save_data(null)