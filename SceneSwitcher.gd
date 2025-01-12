extends Node

var current_scene = null
var new_scene = null
var scene_parameters: Dictionary
var last_player_location : Vector3


func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	print("SceneSwitcher.gd: " + current_scene.to_string() + " - current scene")

func goto_overworld_scene(path: String, player_monster_roster: Array[PackedScene]):
	print("SceneSwitcher.gd: Now switching from current scene: " + str(get_tree().current_scene) + ", to overworld scene: " + path)
	call_deferred("_deferred_goto_overworld_scene", path, player_monster_roster)
	

func goto_battle_scene(path: String, player_monster_roster : Array[PackedScene], enemy_monster_roster : Array[PackedScene], player_location : Vector3):
	print("SceneSwitcher.gd: Now switching from current scene: " + str(get_tree().current_scene) + ", to battle scene: " + path)
	last_player_location = player_location
	call_deferred("_deferred_goto_battle_scene", path, player_monster_roster, enemy_monster_roster)

# This method was found from an online resource. I'm keeping it here as a referecne
func _deferred_goto_overworld_scene(path, player_monster_roster : Array[PackedScene]):  
	
	#detatch_monsters_from_scene(player_monster_roster)
	new_scene.free()
	
	var s = ResourceLoader.load(path)
	new_scene = s.instantiate()

	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene = new_scene
	#new_scene.set_player_monsters(player_monster_roster)
	var player : Player = new_scene.get_node("player")
	player.set_global_position(last_player_location)
	player.monster_roster = player_monster_roster
	
	
func _deferred_goto_battle_scene(path : String, player_monster_roster : Array[PackedScene], enemy_monster_roster : Array[PackedScene]):
	#detatch_monsters_from_scene(player_monster_roster)
	#detatch_monsters_from_scene(enemy_monster_roster)
	
	current_scene.free()
	
	var s = ResourceLoader.load(path)
	#get_tree().change_scene_to_file(path)
	new_scene = s.instantiate()
	get_tree().current_scene = new_scene
	new_scene.populate_spawns(enemy_monster_roster, player_monster_roster)
	get_tree().root.add_child(new_scene)
	current_scene = new_scene


func detatch_monsters_from_scene(monsters: Array):
	for m in monsters:
		m.get_parent().remove_child(m)


