extends Node

enum SceneLoadMode {
	TEMP, ## Reading world scene state + player state from temp save on disk
	OVERWORLD, ## Reading world scene state + player state from scene_switcher
	BATTLE, ## Reading player state from scene_switcher
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

var current_player_state : PlayerState = null
var overworld_scene_state : EvokerSceneState = null
var current_scene : Node = null
var _new_scene : Node = null
var _next_scene_path : String
var _passed_slot : String
var _load_mode : SceneSwitcher.SceneLoadMode
var _new_scene_monster_roster_scene_paths : Array[String]

func _ready():
	set_process(false) # we only want to process when we are loading a scene
	process_mode = Node.PROCESS_MODE_ALWAYS # we will pause the game while the scene loads
	current_scene = get_tree().current_scene;
	instantiate_fade_panel()
	#print("SceneSwitcher.gd: " + current_scene.to_string() + " - current scene")

func _process(_delta):
	# on each process frame, check if the background thread has finished loading the next scene
	# if it has, then load the scene and free the loading screen

	# check if all resources have been loaded
	var all_resources_loaded = true;
	if ResourceLoader.load_threaded_get_status(_next_scene_path) != ResourceLoader.THREAD_LOAD_LOADED:
		all_resources_loaded = false
	else:
		for m in _new_scene_monster_roster_scene_paths:
			if ResourceLoader.load_threaded_get_status(m) != ResourceLoader.THREAD_LOAD_LOADED:
				all_resources_loaded = false
	
	if all_resources_loaded:
		#Global.debug_log("scene_switcher.gd", "Loaded " + _next_scene_path)
		set_process(false) # don't loop again
		
		var new_scene_packed: PackedScene = ResourceLoader.load_threaded_get(_next_scene_path)
		var new_scene_node : Node = new_scene_packed.instantiate()

		get_tree().get_root().add_child(new_scene_node) # this must be called AFTER adding monsters to the scene
		
		if(_load_mode == SceneLoadMode.BATTLE): 
			if(new_scene_node is BattleScene):
				var enemy_monster_roster : Array[PackedScene] = []
				for m in _new_scene_monster_roster_scene_paths:
					enemy_monster_roster.append(ResourceLoader.load_threaded_get(m))
				new_scene_node.initialize(enemy_monster_roster)
		elif(_load_mode == SceneSwitcher.SceneLoadMode.OVERWORLD):
			current_player_state.apply(PlayerGlobal.player)
			overworld_scene_state.apply(get_tree())
		
		fade_in()

		# preserve the old scene to use its nodes before freeing
		var old_scene : Node = get_tree().current_scene; 

		# change the current scene to the new scene, and unpause it
		get_tree().current_scene = new_scene_node
		SceneSwitcher.current_scene = new_scene_node
		get_tree().paused = false
		
		old_scene.queue_free()

func goto_overworld_scene_from_battle(path: String, player_monster_roster: Array[Monster] = []):
	# TODO: apply the results of the battle to the player's state
	# convert monster roster to an Array of PackedScenes
	var monster_roster : Array[PackedScene] = []
	for monster in player_monster_roster:
		var monster_packed : PackedScene = PackedScene.new()
		monster_packed.pack(monster)
		monster_roster.append(monster_packed)
	current_player_state.monster_roster = monster_roster
	#print(current_player_state.monster_roster)

	SceneSwitcher.fade_out()
	await SceneSwitcher.fade_finished	
	SceneSwitcher.load_next_scene(path, SceneSwitcher.SceneLoadMode.OVERWORLD)
	

func goto_battle_scene(path: String, enemy_monster_roster_paths : Array[String]):
	print("SceneSwitcher.gd: Now switching from current scene: " + str(get_tree().current_scene) + ", to battle scene: " + path)
	#print("Enter battle position: ", PlayerGlobal.player.global_position)
	current_player_state = PlayerState.get_player_state(PlayerGlobal.player, current_scene.name, current_scene.scene_file_path)
	overworld_scene_state = EvokerSceneState.get_scene_state(get_tree())
	load_next_scene(path, SceneLoadMode.BATTLE, enemy_monster_roster_paths)


func detatch_monsters_from_scene(monsters: Array):
	for m in monsters:
		m.get_parent().remove_child(m)

## Start a new game
func start_new_game(save_slot_name : String):
	Global.debug_log("SceneSwitcher","Starting a new game.")
	SaveManager.active_save_name = save_slot_name
	load_next_scene(Global.new_game_scene_path, SceneLoadMode.RESET)

## Load & transition to another scene
func load_next_scene(scene_path : String, load_mode: SceneLoadMode, monster_roster_paths : Array[String] = []) -> void:
	
	get_tree().paused = true
	_next_scene_path = scene_path
	_load_mode = load_mode
	_new_scene_monster_roster_scene_paths = monster_roster_paths

	# To debug scene switching
	# print("Tree Scene: ", get_tree().current_scene)
	# print("Current Scene: ", current_scene)

	# add the loading screen to the scene tree, triggering it to display and processing the logic on that scene
	if(use_loading_screen):
		var loading_screen = preload("res://Menus/Loading/LoadingScene.tscn").instantiate()
		get_tree().current_scene.add_child(loading_screen)
	# else:
	# 	fade_out() # currently not working as expected

	# load the battle scene and each monster scene with ResourceLoader.load_threaded_request
	ResourceLoader.load_threaded_request(_next_scene_path) # Start loading the next scene
	for m in _new_scene_monster_roster_scene_paths:
		ResourceLoader.load_threaded_request(m) # Start loading the monster scenes
	

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
