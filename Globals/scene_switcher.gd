extends Node

enum SceneLoadMode {
	TEMP, ## Reading state from temporary storage
	LOAD_SAVE, ## Loading state from a save slot
	RESET ## No state loaded
	}

## Emitted when a fade finishes
signal fade_finished

@onready var default_fade_duration : float = Global.default_transition_duration
@export var fade_panel : Panel = null

## if false, does not display a loading screen
@export var use_loading_screen : bool = true
## Adds a forced wait time when loading. Used to avoid loading screen flickering if load time is too short.
@export var forced_delay : float = 0.5

var current_scene : Node = null
var _new_scene : Node = null
var _scene_parameters: Dictionary
var _last_player_location : Vector3
var _next_scene_path : String
var _connector_name : String
var next_scene_name : String
var _passed_slot : String
var _load_mode : SceneSwitcher.SceneLoadMode
var _new_scene_monster_roster : Array[PackedScene]

func _ready():
	set_process(false) # we only want to process when we are loading a scene
	process_mode = Node.PROCESS_MODE_ALWAYS # we will pause the game while the scene loads
	current_scene = get_tree().current_scene;
	instantiate_fade_panel()
	#print("SceneSwitcher.gd: " + current_scene.to_string() + " - current scene")

func _process(_delta):
	# on each process frame, check if the background thread has finished loading the next scene
	# if it has, then load the scene and free the loading screen
	if ResourceLoader.load_threaded_get_status(_next_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
		#Global.debug_log("scene_switcher.gd", "Loaded " + _next_scene_path)
		set_process(false) # don't loop again
		
		var new_scene_packed: PackedScene = ResourceLoader.load_threaded_get(_next_scene_path)
		var new_scene_node : Node = new_scene_packed.instantiate()

		if(_load_mode == SceneSwitcher.SceneLoadMode.RESET):
			if(new_scene_node is BattleScene):
				new_scene_node.instantiate_monsters(_new_scene_monster_roster)

		get_tree().get_root().add_child(new_scene_node) # Adds the instatiated new scene as a node.

		if(_load_mode == SceneSwitcher.SceneLoadMode.RESET):
			if(new_scene_node is BattleScene):
				new_scene_node.populate_spawns()
		
		#Global.debug_log("scene_switcher.gd", "Load_mode is " + SceneSwitcher.SceneLoadMode.find_key(_load_mode) )
		
		#If _load_mode asks for it, scene state will be loaded.
		if _load_mode != SceneSwitcher.SceneLoadMode.RESET: #RESET would ignore scene states.
			
			next_scene_name = new_scene_node.get_name()
			
			if _load_mode == SceneSwitcher.SceneLoadMode.LOAD_SAVE:
				#Global.debug_log("scene_switcher.gd", "Attempting to load a save for Slot: " + _passed_slot)
				SaveManager.load_saved_game(get_tree(), _passed_slot)
			elif _load_mode == SceneSwitcher.SceneLoadMode.TEMP:
				#Global.debug_log("scene_switcher.gd", "Attempting to load scene state: " + next_scene_name)
				SaveManager.apply_scene_state(get_tree(),"temp", next_scene_name) # Loading temp scene state
				SaveManager.apply_player_state(PlayerGlobal.player,"temp") # Loading temp player state.
		
		fade_in()

		# preserve the old scene to use its nodes before freeing
		var old_scene : Node = get_tree().current_scene; 

		# change the current scene to the new scene, and unpause it
		get_tree().current_scene = new_scene_node
		SceneSwitcher.current_scene = new_scene_node
		get_tree().paused = false
		
		#If a connector name has been passed, move the player to it. This requires the target scene to have a custom scene script attached to it's root scene node.
		if _connector_name != "": 
			new_scene_node.move_player_to_connector(_connector_name)

		old_scene.queue_free()

func goto_overworld_scene(path: String, player_monster_roster: Array[Monster]):
	print("SceneSwitcher.gd: Now switching from current scene: " + str(get_tree().current_scene) + ", to overworld scene: " + path)
	detatch_monsters_from_scene(player_monster_roster)
	_new_scene.free()
	
	var s = ResourceLoader.load(path)
	_new_scene = s.instantiate()

	get_tree().root.add_child(_new_scene)
	get_tree().current_scene = _new_scene
	current_scene = _new_scene
	#_new_scene.set_player_monsters(player_monster_roster)
	var player : Player = _new_scene.get_node("player")
	player.set_global_position(_last_player_location)
	
	# convert monster roster to an Array of PackedScenes and set it to the global player monster list
	var monster_roster : Array[PackedScene] = []
	for m in player_monster_roster:
		monster_roster.append(m.get_scene())
	PlayerGlobal.monster_list = monster_roster
	

func goto_battle_scene(path: String, enemy_monster_roster : Array[PackedScene], player_location : Vector3):
	print("SceneSwitcher.gd: Now switching from current scene: " + str(get_tree().current_scene) + ", to battle scene: " + path)
	_last_player_location = player_location
	load_next_scene(path, "", "temp", SceneLoadMode.RESET, enemy_monster_roster)


func detatch_monsters_from_scene(monsters: Array):
	for m in monsters:
		m.get_parent().remove_child(m)

## Load & transition to another scene
func load_next_scene(scene_path : String, connector_name: String, passed_slot: String, load_mode: SceneLoadMode, new_scene_monster_roster : Array[PackedScene] = []) -> void:
	
	get_tree().paused = true
	_next_scene_path = scene_path
	_connector_name = connector_name
	_passed_slot = passed_slot
	_load_mode = load_mode
	_new_scene_monster_roster = new_scene_monster_roster

	# To debug scene switching
	# print("Tree Scene: ", get_tree().current_scene)
	# print("Current Scene: ", current_scene)

	# add the loading screen to the scene tree, triggering it to display and processing the logic on that scene
	if(use_loading_screen):
		var loading_screen = preload("res://Menus/Loading/LoadingScene.tscn").instantiate()
		get_tree().current_scene.add_child(loading_screen)
	# else:
	# 	fade_out() # currently not working as expected

	ResourceLoader.load_threaded_request(_next_scene_path) # Start loading the next scene

	# minimum time
	if(forced_delay > 0.0):
		await get_tree().create_timer(forced_delay).timeout
		#await SaveManager.fade_finished

	set_process(true) # Start processing the scene loading logic

### FUNCTIONS TO HANDLE SCREEN FADING
func instantiate_fade_panel() -> void:
	fade_panel = Panel.new()
	
	var black_stylebox := StyleBoxFlat.new()
	black_stylebox.bg_color = Color.BLACK
	
	fade_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_panel.focus_mode = Control.FOCUS_NONE
	fade_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_panel.set_modulate(Color.TRANSPARENT)
	fade_panel.add_theme_stylebox_override("panel", black_stylebox)
	
	add_child(fade_panel)


func fade_in(fade_duration:float = default_fade_duration) -> void:
	fade_panel.set_modulate(Color.BLACK)
	var fade_tween = get_tree().create_tween()
	
	fade_tween.tween_property(fade_panel, "modulate", Color.TRANSPARENT, fade_duration).set_trans(Tween.TRANS_CUBIC)
	await fade_tween.finished
	fade_finished.emit()


func fade_out(fade_duration:float = default_fade_duration) -> void:
	fade_panel.set_modulate(Color.TRANSPARENT)
	var fade_tween : Tween = get_tree().create_tween()	
	fade_tween.tween_property(fade_panel, "modulate", Color.BLACK, fade_duration).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(fade_duration).timeout
	fade_finished.emit()

## example of transitioning to a scene from another scene
func transition_to_next_scene(next_scene_name: String, battle_scene_monster_roster : Array[PackedScene] = []):
	var scene_tree = get_tree()
	var current_scene_name = scene_tree.get_current_scene().get_name()
	var current_scene_path = get_tree().current_scene.scene_file_path
	if(!battle_scene_monster_roster.is_empty()):
		SaveManager.save_player_state(current_scene_name, current_scene_path, PlayerGlobal.player, null, "temp")
		SaveManager.save_scene_state(scene_tree,"temp")
	else:
		SaveManager.apply_player_state(PlayerGlobal.player, "temp")	
		SaveManager.apply_scene_state(scene_tree,"temp",next_scene_name)
	fade_out()
	await fade_finished	
	SceneSwitcher.load_next_scene(next_scene_name, "", "temp", SceneSwitcher.SceneLoadMode.TEMP, battle_scene_monster_roster)
