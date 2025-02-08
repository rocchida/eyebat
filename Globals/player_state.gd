class_name PlayerState
extends Resource

var player_state_dir : String = Global.STATE_DIR + Global.player_state_prefix

@export var version : int = 1
#@export var player_inventory : Inventory
@export var saved_wieldable_charges : Array

@export var current_scene : String
@export var current_scene_path : String
@export var position : Vector3
@export var sprite_direction : Vector2
# @export var rotation : Vector3
# @export var player_try_crouch : bool

#Using Vector2 for saving player attributes. X = current, Y = max.
@export var health: Vector2
@export var stamina : Vector2
@export var sanity : Vector2

#New way of saving player attributes
@export var attributes : Dictionary

# Saving currencies
@export var currencies : Dictionary

#Saving Monster roster
@export var monster_roster : Array[PackedScene]

# Saving world dict
@export var world_dictionary : Dictionary

#Saving parameters from the player interaction component
@export var interaction_component_state : Array

#Saving quests:
# @export var player_active_quests : Array[Quest]
# @export var player_completed_quests : Array[Quest]
# @export var player_failed_quests : Array[Quest]

# Functions for attributes
func add_player_attribute_to_state_data(name: String, attribute_data:Vector2):
	attributes[name] = attribute_data


func clear_saved_attribute_data():
	attributes.clear()


# Functions for currencies
func add_player_currency_to_state_data(name: String, currency_data:Vector2):
	currencies[name] = currency_data


func clear_saved_currency_data():
	currencies.clear()

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

static func get_player_state(player:Player, current_scene_name:String, current_scene_path:String) -> PlayerState:
	var _player_state = PlayerState.new()
	# Writing the save state from current player node.
	#_player_state.player_inventory = player.inventory_data #Saving player inventory
	
	# Saving current quests to player state.
	# _player_state.player_active_quests.clear()
	# for quest in QuestManager.active.quests:
	# 	_player_state.player_active_quests.append(quest)
		
	# _player_state.player_completed_quests.clear()
	# for quest in QuestManager.completed.quests:
	# 	_player_state.player_completed_quests.append(quest)
		
	# _player_state.player_failed_quests.clear()
	# for quest in QuestManager.failed.quests:
	# 	_player_state.player_completed_quests.append(quest)
	
	
	# _player_state.clear_saved_wieldable_charges()
	# for item_slot in player.inventory_data.inventory_slots:
	# 	if item_slot and item_slot.inventory_item and item_slot.inventory_item.has_method("update_wieldable_data"): #Checking for wieldables.
	# 		var item_save_data = item_slot.inventory_item.save()
	# 		_player_state.append_saved_wieldable_charges(item_save_data)
	# 		Global.debug_log("SaveManager","Saved charge for " + str(item_slot.inventory_item) )
	
	_player_state.current_scene = current_scene_name
	_player_state.current_scene_path = current_scene_path
	_player_state.position = player.global_position
	#print("Getting player position: ", player.global_position)
	_player_state.sprite_direction = player.get_current_sprite_direction()
	
	## Saving attributes:
	# _player_state.clear_saved_attribute_data()
	# for attribute in player.player_attributes:
	# 	var cur_value
	# 	if !player.player_attributes[attribute].dont_save_current_value:
	# 		cur_value = player.player_attributes[attribute].value_current
	# 	else:
	# 		cur_value = 0
	# 	var max_value = player.player_attributes[attribute].value_max
	# 	var attribute_data := Vector2(cur_value, max_value)
	# 	_player_state.add_player_attribute_to_state_data(attribute, attribute_data)
	
	## Saving currencies:
	# _player_state.clear_saved_currency_data()
	# for currency in player.player_currencies:
	# 	var cur_value
	# 	if !player.player_currencies[currency].dont_save_current_value:
	# 		cur_value = player.player_currencies[currency].value_current
	# 	else:
	# 		cur_value = 0
	# 	var max_value = player.player_currencies[currency].value_max
	# 	var currency_data := Vector2(cur_value, max_value)
	# 	_player_state.add_player_currency_to_state_data(currency, currency_data)

	## Saving monster roster
	_player_state.monster_roster = player.monster_roster
	
	## Saving world dictionary
	# var local_dict_copy : Dictionary = _current_world_dict.duplicate(true)
	# _player_state.clear_world_dictionary()
	# for entry in local_dict_copy:
	# 	print("SaveManager: World Dict: attemtping to save key: ", entry)
	# 	_player_state.add_to_world_dictionary(entry, local_dict_copy[entry])
	return _player_state

# func load_state(state_slot : String) -> PlayerState:
# 	#var player_state_file = str(player_state_dir + state_slot + ".res")
# 	var player_state_file = str(Global.STATE_DIR + state_slot + "/" + Global.player_state_prefix + ".res")
# 	return ResourceLoader.load(player_state_file, "", ResourceLoader.CACHE_MODE_IGNORE)

func apply(player : Player):
	Global.debug_log("PlayerState","Applying player state. Res: " + str(self))
	
	# Applying the save state to player node.
	#player.inventory_data = _player_state.player_inventory #Loading inventory data from saved player state to current player inventory.
	
	# Loading quests from player state:
	# QuestManager.active.clear_group()
	# for quest in _player_state.player_active_quests:
	# 	QuestManager.active.add_quest(quest)
	
	# QuestManager.completed.clear_group()
	# for quest in _player_state.player_completed_quests:
	# 	QuestManager.completed.add_quest(quest)
	
	# QuestManager.failed.clear_group()
	# for quest in _player_state.player_failed_quests:
	# 	QuestManager.failed.add_quest(quest)
	
	
	# Loading saved charges of wieldables
	# var array_of_wieldable_charges = _player_state.saved_wieldable_charges
	# for data in array_of_wieldable_charges:
	# 	if data == null:
	# 		continue
	# 	else:
	# 		for slot in player.inventory_data.inventory_slots:
	# 			if slot and slot.inventory_item and slot.inventory_item == data["resource"]:
	# 				Global.debug_log("SaveManager","Match found: " + str(slot.inventory_item))
	# 				slot.inventory_item.charge_current = data["charge_current"]
					
	# player.inventory_data.force_inventory_update()
	
	# Loading player attributes:
	# var loaded_attribute_data = _player_state.player_attributes
	# for attribute in loaded_attribute_data:
	# 	var attribute_data: Vector2 = loaded_attribute_data[attribute]
	# 	var cur_value = attribute_data.x
	# 	var max_value = attribute_data.y
	# 	player.player_attributes[attribute].set_attribute(cur_value, max_value)

	# Loading player currencies
	# var loaded_currency_data = _player_state.player_currencies
	# for currency in loaded_currency_data:
	# 	var currency_data: Vector2 = loaded_currency_data[currency]
	# 	var cur_value = currency_data.x
	# 	var max_value = currency_data.y
	# 	player.player_currencies[currency].set_currency(cur_value, max_value)

	# Loading world dictionary
	# var local_dict_copy : Dictionary = _player_state.world_dictionary.duplicate(true)
	# _current_world_dict.clear()
	# for entry in local_dict_copy:
	# 	_current_world_dict.get_or_add(entry, local_dict_copy[entry])

	# Loading player sprite positioning
	player.global_position = position
	#print("PlayerState: ","Applying player position: ", player.global_position)
	player.set_sprite_direction(sprite_direction)

	# Loading monster roster
	player.monster_roster = monster_roster

	#Loading player interaction component state
	# var player_interaction_component_state = _player_state.interaction_component_state
	# for state_data in player_interaction_component_state:
	# 	for data in state_data.keys():
	# 		player.player_interaction_component.set(data, state_data[data])
	# 	player.player_interaction_component.set_state.call_deferred() #Calling this deferred as some state calls need to make sure the scene is finished loading.
	
	player.player_state_loaded.emit()
