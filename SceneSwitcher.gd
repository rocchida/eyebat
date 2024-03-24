extends Node

var current_scene = null
var new_scene = null
var scene_parameters: Dictionary

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	print("SceneSwitcher.gd: " + current_scene.to_string() + " - current scene")

func goto_overworld_scene(path: String):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.
	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	print("SceneSwitcher.gd: Now switching from current scene: " + current_scene.to_string() + ", to overworld scene: " + path)
	call_deferred("_deferred_goto_overworld_scene", path)
	

func goto_battle_scene(path: String, player_monster_roster : Array[Monster], enemy_monster_roster : Array[Monster]):
	print("SceneSwitcher.gd: Now switching from current scene: " + current_scene.to_string() + ", to battle scene: " + path)
	call_deferred("_deferred_goto_battle_scene", path, player_monster_roster, enemy_monster_roster)

# This method was found from an online resource. I'm keeping it here as a referecne
func _deferred_goto_overworld_scene(path):  
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
	
func _deferred_goto_battle_scene(path : String, player_monster_roster : Array[Monster], enemy_monster_roster : Array[Monster]):
	_detatch_monsters_from_scene(player_monster_roster)
	_detatch_monsters_from_scene(enemy_monster_roster)
	
	current_scene.free()
	var s = ResourceLoader.load(path)
	new_scene = s.instantiate()
	new_scene.populate_spawns(enemy_monster_roster, player_monster_roster)
	get_tree().root.add_child(new_scene)

func _detatch_monsters_from_scene(monsters: Array):
	for m in monsters:
		m.get_parent().remove_child(m)

