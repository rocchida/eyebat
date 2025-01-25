extends CanvasLayer
# Loading screen script is heavily dependent on Cogito Scene Manager and scene states.

## Adds a forced wait time to the loading screen. Used to avoid loading screen flickering if load time is too short.
@export var forced_delay : float = 0.5

var next_scene_path : String
var connector_name : String
var next_scene_state_filename : String
var passed_slot : String
var load_mode : SceneSwitcher.SceneLoadMode
var new_scene_monster_roster : Array[PackedScene]

func _ready():
	ResourceLoader.load_threaded_request(next_scene_path) # Start loading the next scene


func _process(_delta):
	if ResourceLoader.load_threaded_get_status(next_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
		Global.debug_log("loading_screen.gd", "Attempting to load " + next_scene_path)
		set_process(false)
		await get_tree().create_timer(forced_delay).timeout

		# Load the next scene. This will freeze the game for a moment
		var new_scene_packed: PackedScene = ResourceLoader.load_threaded_get(next_scene_path)


		var new_scene_node = new_scene_packed.instantiate()

		if(load_mode == SceneSwitcher.SceneLoadMode.RESET):
			if(new_scene_node is BattleScene):
				new_scene_node.instantiate_monsters(new_scene_monster_roster)

		get_tree().get_root().add_child(new_scene_node) # Adds the instatiated new scene as a node.

		if(load_mode == SceneSwitcher.SceneLoadMode.RESET):
			if(new_scene_node is BattleScene):
				new_scene_node.populate_spawns()
		
		Global.debug_log("loading_screen.gd", "Load_mode is " + SceneSwitcher.SceneLoadMode.find_key(load_mode) )
		
		#If load_mode asks for it, scene state will be loaded.
		if load_mode != SceneSwitcher.SceneLoadMode.RESET: #RESET would ignore scene states.
			
			next_scene_state_filename = new_scene_node.get_name()
			
			if load_mode == SceneSwitcher.SceneLoadMode.LOAD_SAVE:
				Global.debug_log("loading_screen.gd", "Attempting to load a save for passsed_slot " + passed_slot)
				SaveManager._current_scene_name = new_scene_node.name #Manually setting new scene name
				SaveManager.loading_saved_game(passed_slot)
			elif load_mode == SceneSwitcher.SceneLoadMode.TEMP:
				Global.debug_log("loading_screen.gd", "Attempting to load scene state: " + next_scene_state_filename)
				SaveManager.load_scene_state(next_scene_state_filename,"temp") # Loading temp scene state
				SaveManager.load_player_state(SaveManager._current_player_node,"temp") # Loading temp player state.
		
		# preserve the old scene to use its nodes before freeing
		var old_scene = get_tree().current_scene; 

		# change the current scene to the new scene
		get_tree().current_scene = new_scene_node
		SceneSwitcher.current_scene = new_scene_node
		
		if connector_name != "": #If a connector name has been passed, move the player to it. This requires the target scene to have a custom scene script attached to it's root scene node.
			new_scene_node.move_player_to_connector(connector_name)

		old_scene.queue_free() # Removing previous scene.

		
