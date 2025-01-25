extends Node

var current_scene : Node = null
var new_scene : Node = null
var scene_parameters: Dictionary
var last_player_location : Vector3

#Load_mode TEMP = Reading state from temporary storage
#Load_mode RESET = No state loaded
#Load_Mode LOAD_SAVE - Loading state from a save slot
enum SceneLoadMode {TEMP, LOAD_SAVE, RESET}

@export var scene_load_mode: SceneLoadMode


func _ready():
	current_scene = get_tree().current_scene;
	print("SceneSwitcher.gd: " + current_scene.to_string() + " - current scene")

func goto_overworld_scene(path: String, player_monster_roster: Array[Monster]):
	print("SceneSwitcher.gd: Now switching from current scene: " + str(get_tree().current_scene) + ", to overworld scene: " + path)
	(func():
		detatch_monsters_from_scene(player_monster_roster)
		new_scene.free()
		
		var s = ResourceLoader.load(path)
		new_scene = s.instantiate()

		get_tree().root.add_child(new_scene)
		get_tree().current_scene = new_scene
		current_scene = new_scene
		#new_scene.set_player_monsters(player_monster_roster)
		var player : Player = new_scene.get_node("player")
		player.set_global_position(last_player_location)
		
		# convert monster roster to an Array of PackedScenes and set it to the global player monster list
		var monster_roster : Array[PackedScene] = []
		for m in player_monster_roster:
			monster_roster.append(m.get_scene())
		PlayerGlobal.monster_list = monster_roster
	).call_deferred();
	

func goto_battle_scene(path: String, enemy_monster_roster : Array[PackedScene], player_location : Vector3):
	print("SceneSwitcher.gd: Now switching from current scene: " + str(get_tree().current_scene) + ", to battle scene: " + path)
	last_player_location = player_location
	(func():
		# current_scene.free()	
		# var s = ResourceLoader.load(path)
		# new_scene = s.instantiate()
		# get_tree().current_scene = new_scene
		# new_scene.populate_spawns(enemy_monster_roster)
		# get_tree().root.add_child(new_scene)
		# current_scene = new_scene
		load_next_scene(path, "", "temp", SceneLoadMode.RESET, enemy_monster_roster)
	).call_deferred();


func detatch_monsters_from_scene(monsters: Array):
	for m in monsters:
		m.get_parent().remove_child(m)

# Transition to another scene via the loading screen.
func load_next_scene(scene_path : String, connector_name: String, passed_slot: String, load_mode: SceneLoadMode, new_scene_monster_roster : Array[PackedScene] = []) -> void:
	# fade_out()
	
	var loading_screen = preload("res://Menus/Loading/LoadingScene.tscn").instantiate()
	loading_screen.next_scene_path = scene_path
	loading_screen.connector_name = connector_name
	loading_screen.passed_slot = passed_slot
	loading_screen.load_mode = load_mode
	loading_screen.new_scene_monster_roster = new_scene_monster_roster

	# To debug scene switching
	# print("Tree Scene: ", get_tree().current_scene)
	# print("Current Scene: ", current_scene)

	get_tree().current_scene.add_child(loading_screen)


