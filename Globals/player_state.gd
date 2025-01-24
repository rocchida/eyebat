class_name PlayerState
extends Resource

var player_state_dir : String = Global.STATE_DIR + SaveManager.player_state_prefix

@export var version : int = 1
#@export var player_inventory : Inventory
@export var saved_wieldable_charges : Array

@export var player_current_scene : String
@export var player_current_scene_path : String
@export var player_position : Vector3
@export var player_rotation : Vector3
@export var player_try_crouch : bool

#Using Vector2 for saving player attributes. X = current, Y = max.
@export var player_health: Vector2
@export var player_stamina : Vector2
@export var player_sanity : Vector2

#New way of saving player attributes
@export var player_attributes : Dictionary

# Saving currencies
@export var player_currencies : Dictionary

#Saving Monster roster
@export var player_monster_roster : Array[PackedScene]

# Saving world dict
@export var world_dictionary : Dictionary

#Saving parameters from the player interaction component
@export var interaction_component_state : Array

#Saving quests:
# @export var player_active_quests : Array[Quest]
# @export var player_completed_quests : Array[Quest]
# @export var player_failed_quests : Array[Quest]

#Saving some extra data for save game management/UI
@export var player_state_screenshot_file : String
@export var player_state_savetime : int
@export var player_state_slot_name : String


# Functions for attributes
func add_player_attribute_to_state_data(name: String, attribute_data:Vector2):
	player_attributes[name] = attribute_data


func clear_saved_attribute_data():
	player_attributes.clear()


# Functions for currencies
func add_player_currency_to_state_data(name: String, currency_data:Vector2):
	player_currencies[name] = currency_data


func clear_saved_currency_data():
	player_currencies.clear()

# Functions for Monster roster
func add_player_monster_roster_to_state_data(monster:PackedScene):
	player_monster_roster.append(monster)


func clear_saved_player_monster_roster_data():
	player_monster_roster.clear()


# Functions for world dictionary
func add_to_world_dictionary(world_property_name: String, world_property_data):
	if world_dictionary.has(world_property_name):
		world_dictionary[world_property_name] = world_property_data
		print("PlayerState: world dict key found and value saved: ", world_property_name, world_property_data)
	else:
		world_dictionary.get_or_add(world_property_name)
		world_dictionary[world_property_name] = world_property_data
		print("PlayerState: world dict key not found. Added and value saved: ", world_property_name, world_property_data)


func clear_world_dictionary():
	world_dictionary.clear()


func add_interaction_component_state_data_to_array(state_data):
	interaction_component_state.append(state_data)


func clear_saved_interaction_component_state():
	interaction_component_state.clear()


func append_saved_wieldable_charges(saved_item_data):
	saved_wieldable_charges.append(saved_item_data)

func clear_saved_wieldable_charges():
	saved_wieldable_charges.clear()


func write_state(state_slot : String) -> void:
	var dir = DirAccess.open(Global.STATE_DIR)
	dir.make_dir(str(state_slot))
	var player_state_file = str(Global.STATE_DIR + state_slot + "/" + Global.player_state_prefix + ".res")
	#var player_state_file = str(player_state_dir + state_slot + ".res")
	ResourceSaver.save(self, player_state_file, ResourceSaver.FLAG_CHANGE_PATH)
	print("Player state saved as ", player_state_file)
	
	## For debug save as .tres
	#var player_state_file_tres = str(Global.STATE_DIR + state_slot + "/" + SceneManager.player_state_prefix + ".tres")
	#ResourceSaver.save(self, player_state_file_tres, ResourceSaver.FLAG_CHANGE_PATH | ResourceSaver.FLAG_RELATIVE_PATHS)
	#print("Scene state saved as .tres: ", player_state_file_tres)


func state_exists(state_slot : String) -> bool:
	#var player_state_file = str(player_state_dir + state_slot + ".res")
	var player_state_file = str(Global.STATE_DIR + state_slot + "/" + Global.player_state_prefix + ".res")
	return ResourceLoader.exists(player_state_file)
 

func load_state(state_slot : String) -> Resource:
	#var player_state_file = str(player_state_dir + state_slot + ".res")
	var player_state_file = str(Global.STATE_DIR + state_slot + "/" + Global.player_state_prefix + ".res")
	return ResourceLoader.load(player_state_file, "", ResourceLoader.CACHE_MODE_IGNORE)
