extends Node
#Loads options like volume and graphic options on game startup

var config = ConfigFile.new()

@onready var sfx_bus_index = AudioServer.get_bus_index(OptionsConstants.sfx_bus_name)
@onready var music_bus_index = AudioServer.get_bus_index(OptionsConstants.music_bus_name)

func _ready():
	load_settings()
	apply_fallback_keybindings()

# Loads settings from config file. Loads with standard values if settings not 
# existing
func load_settings():
	var err = config.load(OptionsConstants.config_file_name)
	
	if err != OK:
		return
	
	var sfx_volume = config.get_value(OptionsConstants.section_name, OptionsConstants.sfx_volume_key_name, 1)
	var music_volume = config.get_value(OptionsConstants.section_name, OptionsConstants.music_volume_key_name, 1)
	var window_mode = config.get_value(OptionsConstants.section_name, OptionsConstants.windowmode_key_name, 0)
	var resolution_index = config.get_value(OptionsConstants.section_name, OptionsConstants.resolution_index_key_name, 0)
	var render_scale = config.get_value(OptionsConstants.section_name, OptionsConstants.render_scale_key, 1)
	var gui_scale = config.get_value(OptionsConstants.section_name, OptionsConstants.gui_scale_key, 1)
	var vsync = config.get_value(OptionsConstants.section_name, OptionsConstants.vsync_key, true)
	var invert_y = config.get_value(OptionsConstants.section_name, OptionsConstants.invert_vertical_axis_key, true)
	var msaa_2d = config.get_value(OptionsConstants.section_name, OptionsConstants.msaa_2d_key, 0)
	var msaa_3d = config.get_value(OptionsConstants.section_name, OptionsConstants.msaa_3d_key, 0)
	
	AudioServer.set_bus_volume_db(sfx_bus_index, sfx_volume)
	AudioServer.set_bus_volume_db(music_bus_index, music_volume)
	
	match window_mode:
		0: #Full screen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: #Exclusive full screen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		2: #Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		3: #Borderless windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

	
	get_viewport().scaling_3d_scale = render_scale
	
	if vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
	set_msaa("msaa_2d", msaa_2d)
	set_msaa("msaa_3d", msaa_3d)

func set_msaa(mode, index):
	match index:
		0:
			get_viewport().set(mode, Viewport.MSAA_DISABLED)
		1:
			get_viewport().set(mode, Viewport.MSAA_2X)
		2:
			get_viewport().set(mode, Viewport.MSAA_4X)
		3:
			get_viewport().set(mode, Viewport.MSAA_8X)

# adds basic menu functionality if all keybindings are missing.
func apply_fallback_keybindings():
	if !InputMap.has_action("menu"):
		InputMap.add_action("menu")
	
	var key_event = InputEventKey.new()
	key_event.keycode = KEY_ESCAPE
	if !InputMap.action_has_event("menu", key_event):
		InputMap.action_add_event("menu", key_event)
	
	var gamepad_event = InputEventJoypadButton.new()
	gamepad_event.button_index = JOY_BUTTON_START
	if !InputMap.action_has_event("menu", gamepad_event):
		InputMap.action_add_event("menu", gamepad_event)
	
	gamepad_event = InputEventJoypadButton.new()
	gamepad_event.button_index = JOY_BUTTON_A
	if !InputMap.action_has_event("ui_accept", gamepad_event):
		InputMap.action_add_event("ui_accept", gamepad_event)

	gamepad_event = InputEventJoypadButton.new()
	gamepad_event.button_index = JOY_BUTTON_B
	if !InputMap.action_has_event("ui_cancel", gamepad_event):
		InputMap.action_add_event("ui_cancel", gamepad_event)

