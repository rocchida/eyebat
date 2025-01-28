class_name SaveManager

# Used to set active save slot. This could be set/modified, when selecting a save slot from the MainMenu.
static var _active_save_name : String = "A"

# Cached World State Dictionary, used for checks while game is running
static var _current_world_dict : Dictionary

# Variables for player state
static var _player_state : PlayerState
# Used to pass a screenshot to the player state when saved. This is created by the TabMenu/PauseMenu
static var _scene_state : EvokerSceneState

static var state_dir : String = "user://"

static func _init() -> void:
	_player_state = load_player_state(_active_save_name) #Setting active slot (per default it's A)
	if(_player_state):
		_scene_state = load_scene_state(_active_save_name, _player_state.current_scene)

	reset_scene_states()
	


static func switch_active_slot_to(save_name:String):
	_player_state = null
	_player_state = load_player_state(save_name)
	#if !_player_state:
		#Global.debug_log("SaveManager","Player state for slot \"" + slot_name + "\" not found.")
	_active_save_name = save_name
	#Global.debug_log("SaveManager","Active slot switched to " + _active_save_name)


static func load_player_state(save_name : String) -> PlayerState:
	var player_state_file_path : String = get_saved_player_state_path(save_name)
	if ResourceLoader.exists(player_state_file_path):
		Global.debug_log("SaveManager","Player state found for save name \""+ save_name + "\"")
		return ResourceLoader.load(player_state_file_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		Global.debug_log("SaveManager","No player state found for save name \""+ save_name + "\"")
		return null

static func get_saved_player_state_path(save_name : String) -> String:
	return Global.STATE_DIR + save_name + "/" + Global.player_state_prefix + ".res"

static func get_saved_scene_state_path(save_name : String, scene_name: String) -> String:
	return Global.STATE_DIR + save_name + "/" + Global.scene_state_prefix + scene_name + ".res"

static func player_state_path_exists(save_name : String) -> bool:
	return ResourceLoader.exists(get_saved_player_state_path(save_name))

static func load_scene_state(save_name : String, scene_name: String) -> EvokerSceneState:
	var scene_state_file : String = get_saved_scene_state_path(save_name, scene_name)
	#Global.debug_log("SaveManager","Looking for file: "+ scene_state_file)
	if ResourceLoader.exists(scene_state_file):
		Global.debug_log("SaveManager","Existing scene state found for save name \"" + save_name + "\"")
		return ResourceLoader.load(scene_state_file, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		Global.debug_log("SaveManager","No existing scene state found for save name \""+ save_name + "\"")
		return null


static func load_saved_game(scene_tree:SceneTree, save_name: String):
	Global.debug_log("SaveManager","SaveManager: Loading saved game from save name \""+ save_name + "\"")

	_player_state = load_player_state(save_name)

	# Check if player is currently in the same scene as in the game that is being attempted to load:
	if scene_tree.current_scene.name == _player_state.current_scene:
		Global.debug_log("SaveManager","Player state for save name \""+ save_name+ "\" is from current scene.")
		apply_scene_state(scene_tree,_player_state.current_scene, save_name)
		apply_player_state(PlayerGlobal.player, save_name)
	else:
		# Transition to target scene and then attempt to load the saved game again.
		Global.debug_log("SaveManager","Player state for save name \""+ save_name + "\" is in different scene (" + _player_state.current_scene + "). Transitioning...")
		var load_mode : SceneSwitcher.SceneLoadMode
		if(save_name == "temp"):
			load_mode = SceneSwitcher.SceneLoadMode.TEMP
		else: 
			load_mode = SceneSwitcher.SceneLoadMode.LOAD_SAVE
		SceneSwitcher.load_next_scene(_player_state.current_scene_path, "", save_name, load_mode) 


#region PLAYER SAVE HANDLING
static func apply_player_state(player : Player, save_name:String):
	#Global.debug_log("SaveManager","Loading player state...")
	if !_player_state:
		_player_state = load_player_state(save_name)
	if _player_state:
		Global.debug_log("SaveManager","Applying loaded player state from save: \"" + save_name + "\". Res: " + str(_player_state))
		
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
		
		# New way of loading player attributes:
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


		player.global_position = _player_state.position
		player.set_sprite_direction(_player_state.sprite_direction)
		
		#Loading player interaction component state
		# var player_interaction_component_state = _player_state.interaction_component_state
		# for state_data in player_interaction_component_state:
		# 	for data in state_data.keys():
		# 		player.player_interaction_component.set(data, state_data[data])
		# 	player.player_interaction_component.set_state.call_deferred() #Calling this deferred as some state calls need to make sure the scene is finished loading.
		
		player.player_state_loaded.emit()
		


static func save_player_state(current_scene_name:String, current_scene_path:String, player:Player, screenshot:Image, slot:String):
	if !_player_state:
		Global.debug_log("SaveManager","State doesn't exist. Creating for slot \"" + slot + "\"...")
		_player_state = PlayerState.new()
	
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
	Global.debug_log("SaveManager","Save_player_state(): setting player_current_scene to " + current_scene_name)
	_player_state.current_scene_path = current_scene_path
	_player_state.position = player.global_position
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
	_player_state.clear_saved_player_monster_roster_data()
	for monster in player.monster_roster:
		_player_state.add_player_monster_roster_to_state_data(monster)
	
	
	## Saving world dictionary
	# var local_dict_copy : Dictionary = _current_world_dict.duplicate(true)
	# _player_state.clear_world_dictionary()
	# for entry in local_dict_copy:
	# 	print("SaveManager: World Dict: attemtping to save key: ", entry)
	# 	_player_state.add_to_world_dictionary(entry, local_dict_copy[entry])

	## Adding a screenshot
	if screenshot:
		var screenshot_path : String = str(_player_state.player_state_dir + _active_save_name + ".png")
		screenshot.save_png(screenshot_path)
		_player_state.save_screenshot_path = screenshot_path
	else:
		Global.debug_log("SaveManager","No screenshot to save was passed.")
	
	## Getting time of saving
	_player_state.save_time = int(Time.get_unix_time_from_system())
	_player_state.save_name = _active_save_name

	#Writing the state from current player interaction component:
	# var current_player_interaction_component = player.player_interaction_component
	# _player_state.clear_saved_interaction_component_state()
	# _player_state.add_interaction_component_state_data_to_array(current_player_interaction_component.save())
	
	#_player_state.write_state(slot)
	_player_state.write_state("temp")
#endregion


static func get_active_slot_player_state_screenshot_path() -> String:
	if(_player_state):
		return _player_state.save_screenshot_path
	else:
		return ""


static func apply_scene_state(scene_tree: SceneTree, save_name:String, scene_name:String):
	if !_scene_state:
		_scene_state = load_scene_state(save_name, scene_name)
	if _scene_state:
		Global.debug_log("SaveManager","Applying loaded scene state... Res: " + str(_scene_state))
		
		# Deleting all current nodes that are in the Persist group as to not clone objects.
		var save_nodes = scene_tree.get_nodes_in_group("Persist")
		for i in save_nodes:
			Global.debug_log("SaveManager","Deleting existing node: "+ i.name)
			i.queue_free()
			
		var array_of_node_data = _scene_state.saved_nodes
		for node_data in array_of_node_data:
			var new_object = load(node_data["filename"]).instantiate()
			if scene_tree.current_scene.get_node(node_data["parent"]):
				scene_tree.current_scene.get_node(node_data["parent"]).add_child(new_object)
				Global.debug_log("SaveManager","Adding to scene: "+ new_object.get_name())
				
			new_object.position = Vector3(node_data["pos_x"],node_data["pos_y"],node_data["pos_z"])
			new_object.rotation = Vector3(node_data["rot_x"],node_data["rot_y"],node_data["rot_z"])
			# Restore physics properties if it's a RigidBody3D
			if new_object is RigidBody3D:
				if "linear_velocity_x" in node_data and "linear_velocity_y" in node_data and "linear_velocity_z" in node_data:
					new_object.linear_velocity = Vector3(node_data["linear_velocity_x"], node_data["linear_velocity_y"], node_data["linear_velocity_z"])
				if "angular_velocity_x" in node_data and "angular_velocity_y" in node_data and "angular_velocity_z" in node_data:
					new_object.angular_velocity = Vector3(node_data["angular_velocity_x"], node_data["angular_velocity_y"], node_data["angular_velocity_z"])
			# Set the remaining variables.
			for data in node_data.keys():
				if data == "filename" or data == "parent" or data == "pos_x" or data == "pos_y" or data == "pos_z" or data == "rot_x" or data == "rot_y" or data == "rot_z" or data == "item_charge":
					continue
				new_object.set(data, node_data[data])
			
			if new_object.has_method("update_wieldable_data"): #Check if item is wieldable
				Global.debug_log("SaveManager","Setting charge of "+ new_object+ " to "+ node_data["item_charge"])
				new_object.slot_data.inventory_item.charge_current = node_data["item_charge"]
				
			new_object.set_state.call_deferred()
		
		
		#Loading states of objects in save_object_state
		var array_of_state_data = _scene_state.saved_states
		for state_data in array_of_state_data:
			var node_to_set = scene_tree.current_scene.get_node(state_data["node_path"])
			# Set variables here
			node_to_set.position = Vector3(state_data["pos_x"],state_data["pos_y"],state_data["pos_z"])
			node_to_set.rotation = Vector3(state_data["rot_x"],state_data["rot_y"],state_data["rot_z"])
			for data in state_data.keys():
				if data == "filename" or data == "parent" or data == "pos_x" or data == "pos_y" or data == "pos_z" or data == "rot_x" or data == "rot_y" or data == "rot_z":
					continue
				node_to_set.set(data, state_data[data])
			node_to_set.set_state()
		
		#Global.debug_log("SaveManager","SaveManager: Loading scene state finished.")
			
	else:
		Global.debug_log("SaveManager","SaveManager: Scene state doesn't exist.")


static func save_scene_state(scene_tree: SceneTree, slot: String):
	if !_scene_state:
		Global.debug_log("SaveManager","SaveManager: Save doesn't exist. Creating...")
		_scene_state = EvokerSceneState.new()
		
	var persistent_nodes : Array[Node] = scene_tree.get_nodes_in_group("Persist")
	
	if persistent_nodes.size() > 0:
		_scene_state.clear_saved_nodes()
	
		for node in persistent_nodes:
			if node.scene_file_path.is_empty(): # Check the node is an instanced scene so it can be instanced again during load.
				Global.debug_log("SaveManager","persistent node '%s' is not an instanced scene, skipped" % node.name)
				continue

			if !node.has_method("save"): # Check the node has a save function.
				Global.debug_log("SaveManager","persistent node '%s' is missing a save() function, skipped" % node.name)
				continue
				
			# If the node is a RigidBody3D, then save the physics properties
			if node is RigidBody3D:
				var node_data = node.save()
				node_data["linear_velocity_x"] = node.linear_velocity.x
				node_data["linear_velocity_y"] = node.linear_velocity.y
				node_data["linear_velocity_z"] = node.linear_velocity.z
				node_data["angular_velocity_x"] = node.angular_velocity.x
				node_data["angular_velocity_y"] = node.angular_velocity.y
				node_data["angular_velocity_z"] = node.angular_velocity.z
				_scene_state.add_node_data_to_array(node_data)
			else:
				_scene_state.add_node_data_to_array(node.save())
		
	
	# Saving states of objects
	var state_nodes : Array[Node] = scene_tree.get_nodes_in_group("save_object_state")
	
	if state_nodes.size() > 0:
		_scene_state.clear_saved_states()
		
		for node in state_nodes:
			if !node.has_method("save"): # Check the node has a save function.
				Global.debug_log("SaveManager","persistent node '%s' is missing a save() function, skipped" % node.name)
				continue
				
			_scene_state.add_state_data_to_array(node.save())
			
	_scene_state.write_state(slot, scene_tree.current_scene.name)

static func delete_save(passed_slot: String) -> void:
	#var file_to_remove = Global.STATE_DIR + player_state_prefix + passed_slot + ".res"
	var dir_to_remove = Global.STATE_DIR + passed_slot
	OS.move_to_trash(ProjectSettings.globalize_path(dir_to_remove))
	Global.debug_log("SaveManager","Save file removed: "+ dir_to_remove)
	
	#var scene_to_remove = Global.STATE_DIR + cogito_scene_state_prefix + passed_slot + ".res"


static func copy_slot_saves_to_temp(scene_tree:SceneTree,passed_slot:String) -> bool:
	#Global.debug_log("SaveManager","Copying files from slot " + passed_slot + " to temp.")
	var files : Dictionary
	var slot_dir = DirAccess.open(Global.STATE_DIR + passed_slot)
	
	DirAccess.open(Global.STATE_DIR).make_dir("temp")

	if slot_dir:
		slot_dir.list_dir_begin()
		var file_name = slot_dir.get_next()
		
		while file_name != "":
			Global.debug_log("SaveManager","Copying file to temp: "+ file_name)
			if slot_dir.copy(str(Global.STATE_DIR + passed_slot + "/" + file_name), str(Global.STATE_DIR + "temp/" + file_name), -1) != OK:
				Global.debug_log("SaveManager","Copying file "+ file_name + " failed.")
				return false
			# iterate to next file
			file_name = slot_dir.get_next()
	
	#Global.debug_log("SaveManager", "Copying files to temp finished.")
	
	return true
	
	
	
static func copy_temp_saves_to_slot(passed_slot:String) -> bool:
	#Global.debug_log("SaveManager","Copying files from temp to slot " + passed_slot)
	
	var temp_dir = DirAccess.open(Global.STATE_DIR + "temp")
	
	DirAccess.open(Global.STATE_DIR).make_dir(passed_slot)

	if temp_dir:
		temp_dir.list_dir_begin()
		var file_name = temp_dir.get_next()
		
		while file_name != "":
			Global.debug_log("SaveManager","Copying file to temp: "+ file_name)
			if temp_dir.copy(str(Global.STATE_DIR + "temp/" + file_name), str(Global.STATE_DIR + passed_slot + "/" + file_name), -1) != OK:
				Global.debug_log("SaveManager","Copying file " + file_name + " failed.")
				return false
			# iterate to next file
			file_name = temp_dir.get_next()
	
	#Global.debug_log("SaveManager","Copying temp files to slot " + passed_slot + " finished.")
	return true


static func delete_temp_saves():
	#Global.debug_log("SaveManager","Deleting temp saves...")
	
	#var scene_temp_files : Dictionary
	var dir = DirAccess.open(Global.STATE_DIR + "temp/")

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			Global.debug_log("SaveManager","Deleting file: " + file_name)
			if dir.remove(file_name) != OK:
				Global.debug_log("SaveManager","Deleting file " + file_name + " failed.")
			# iterate to next file
			file_name = dir.get_next()
	
	var dir2 = DirAccess.open(Global.STATE_DIR)
	if dir2:
		dir2.list_dir_begin()
		var file_name = dir2.get_next()
		while file_name != "":
			if dir2.current_is_dir():
				#Global.debug_log("SaveManager","Deleting temp saves: Detected dir = " + file_name)
				if file_name == "temp":
					Global.debug_log("SaveManager","Deleting temp directory: " + file_name)
					if dir2.remove(file_name) != OK:
						Global.debug_log("SaveManager","Deleting temp dir failed.")
			file_name = dir2.get_next()


static func reset_scene_states():
	#var scene_state_files : Dictionary

	var dir = DirAccess.open(Global.STATE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# if dir.current_is_dir():
			# 	Global.debug_log("SaveManager","Found directory: " + file_name + ". skipping ahead.")

			# Look for _temp_ files
			if file_name.find(Global.scene_state_prefix,0) != -1:
				Global.debug_log("SaveManager","Found scene state file file: " + file_name)
				if file_name.find("temp",0) != -1:
					Global.debug_log("SaveManager","This file is a temp scene state.")
					# DELETE HERE
			
			# iterate to next file
			file_name = dir.get_next()
			
	else:
		Global.debug_log("SaveManager","An error occurred when trying to access the path.")


func _notification(what:int) -> void:
	if(what == NOTIFICATION_PREDELETE ):
		delete_temp_saves()
	