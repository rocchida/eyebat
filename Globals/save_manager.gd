class_name SaveManager

## The name of the save slot that will appear in the pause menu save slot button
static var active_save_name : String

# Cached World State Dictionary, used for checks while game is running
static var _current_world_dict : Dictionary

# currently loaded states
static var _player_state : PlayerState
static var _scene_state : EvokerSceneState
static var save_data : SaveData

static var state_dir : String = "user://"

## Load the player state from disk
static func load_player_state(save_name : String) -> PlayerState:
	var player_state_file_path : String = get_saved_player_state_path(save_name)
	if ResourceLoader.exists(player_state_file_path):
		#Global.debug_log("SaveManager","Player state found for save name \""+ save_name + "\"")
		return ResourceLoader.load(player_state_file_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		Global.debug_log("SaveManager","No player state found for save name \""+ save_name + "\"")
		return null

## Load the save data from disk
static func load_save_data(save_name : String) -> SaveData:
	var save_data_file_path : String = get_saved_save_data_path(save_name)
	if ResourceLoader.exists(save_data_file_path):
		#Global.debug_log("SaveManager","Save data found for save name \""+ save_name + "\"")
		return ResourceLoader.load(save_data_file_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		Global.debug_log("SaveManager","No save data found for save name \""+ save_name + "\"")
		return null

static func get_saved_save_data_path(save_name : String) -> String:
	return Global.STATE_DIR + save_name + "/" + Global.save_data_prefix + ".res"

static func get_saved_player_state_path(save_name : String) -> String:
	return Global.STATE_DIR + save_name + "/" + Global.player_state_prefix + ".res"

static func get_saved_scene_state_path(save_name : String, scene_name: String) -> String:
	return Global.STATE_DIR + save_name + "/" + Global.scene_state_prefix + scene_name + ".res"

static func player_state_path_exists(save_name : String) -> bool:
	return ResourceLoader.exists(get_saved_player_state_path(save_name))

## Load the scene state from disk
static func load_scene_state(save_name : String, scene_name: String) -> EvokerSceneState:
	var scene_state_file : String = get_saved_scene_state_path(save_name, scene_name)
	#Global.debug_log("SaveManager","Looking for file: "+ scene_state_file)
	if ResourceLoader.exists(scene_state_file):
		#Global.debug_log("SaveManager","Existing scene state found for save name \"" + save_name + "\"")
		return ResourceLoader.load(scene_state_file, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		Global.debug_log("SaveManager","No existing scene state found for save name \""+ save_name + "\"")
		return null

## Load a saved game from disk
static func load_saved_game(scene_tree:SceneTree, save_name: String):
	Global.debug_log("SaveManager","SaveManager: Loading saved game from save name \""+ save_name + "\"")


	if save_data == null:
		Global.debug_log("SaveManager","SaveManager: No save data found for save name \""+ save_name + "\". Load aborted.")
		return
	_player_state = load_player_state(save_name)
	if _player_state == null:
		Global.debug_log("SaveManager","SaveManager: No player state found for save name \""+ save_name + "\" Load aborted.")
		return
	_scene_state = load_scene_state(save_name, _player_state.current_scene)
	save_data = load_save_data(save_name)
	active_save_name = save_data.save_name
	
	var load_mode = SceneSwitcher.SceneLoadMode.OVERWORLD
	SceneSwitcher.current_player_state = _player_state
	SceneSwitcher.overworld_scene_state = _scene_state
	SceneSwitcher.load_next_scene(_player_state.current_scene_path, load_mode) 

static func apply_loaded_states(player: Player, scene_tree: SceneTree):
	if _player_state:
		_player_state.apply(player)
	if _scene_state:
		_scene_state.apply(scene_tree)

## Save the player state to disk
static func save_player_state(current_scene_name:String, current_scene_path:String, player:Player, slot:String):
	_player_state = PlayerState.get_player_state(player, current_scene_name, current_scene_path)
	write_save_resource_to_disk(_player_state, slot, get_saved_player_state_path(slot))

## Save the scene state to disk
static func save_scene_state(scene_tree: SceneTree, slot: String):
	_scene_state = EvokerSceneState.get_scene_state(scene_tree)
	write_save_resource_to_disk(_scene_state, slot, get_saved_scene_state_path(slot, scene_tree.current_scene.name))

static func get_active_slot_screenshot() -> Image:
	if(save_data):
		return save_data.screenshot
	else:
		return null

static func save_save_data(current_scene_name:String, current_scene_path:String, screenshot:Image, slot:String):
	if !save_data:
		Global.debug_log("SaveManager","SaveManager: Save doesn't exist. Creating...")
		save_data = SaveData.new()

	save_data.current_scene_name = current_scene_name
	save_data.current_scene_path = current_scene_path

	# add screenshot save data
	if screenshot:
		save_data.screenshot = screenshot
	else:
		Global.debug_log("SaveManager","No screenshot to save was passed.")
	
	save_data.save_time = int(Time.get_unix_time_from_system())
	save_data.save_name = slot
			
	#save_data.write_to_disk(slot)
	write_save_resource_to_disk(save_data, slot, get_saved_save_data_path(slot))

static func delete_save(passed_slot: String) -> void:
	var dir_to_remove = Global.STATE_DIR + passed_slot
	OS.move_to_trash(ProjectSettings.globalize_path(dir_to_remove))
	Global.debug_log("SaveManager","Save file removed: "+ dir_to_remove)

## Save the passed save slot data to a temporary data file
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
	
## Copy the temporary save data to the passed save slot
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
	# delete the temp files when the game is closed
	if(what == NOTIFICATION_PREDELETE ):
		delete_temp_saves()
	
## Gets all save data from all saves
static func get_all_save_data() -> Array[SaveData]:
	var save_data_files : Array[SaveData] = []
	var dir : DirAccess = DirAccess.open(Global.STATE_DIR)
	if dir == null:
		return [];
	
	var outer_directories : PackedStringArray = dir.get_directories()
	for directory_name in outer_directories:
		if directory_name.substr(0,4) != "Save":
			continue
		#Global.debug_log("SaveManager","Directory found: " + directory_name)
		var inner_dir = DirAccess.open(Global.STATE_DIR + directory_name)
		var files : PackedStringArray = inner_dir.get_files()
		for file_name in files:
			#Global.debug_log("SaveManager","File found: " + file_name)
			if file_name.find(Global.save_data_prefix,0) != -1:
				var file_path = Global.STATE_DIR + directory_name + '/' + file_name
				Global.debug_log("SaveManager","Found save data file: " + file_path)
				var save_data_found = ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_IGNORE)
				save_data_files.append(save_data_found)

	# ensure the save data are sorted by save time
	save_data_files.sort_custom(func (a,b): 
		return a.save_time > b.save_time
	)
	
	return save_data_files

static func write_save_resource_to_disk(save_resource : Resource, save_name : String, file_path : String) -> void:
	var dir = DirAccess.open(Global.STATE_DIR)
	dir.make_dir(str(save_name))
	var save_resource_file = file_path
	ResourceSaver.save(save_resource, save_resource_file, ResourceSaver.FLAG_CHANGE_PATH)
	print("Save data saved as ", save_resource_file)
	# For debug save as .tres
	#var scene_state_file_tres = str(Global.STATE_DIR + state_slot + "/" + Global.scene_state_prefix + scene_name + ".tres")
	#ResourceSaver.save(self, scene_state_file_tres, ResourceSaver.FLAG_CHANGE_PATH | ResourceSaver.FLAG_RELATIVE_PATHS)
	#print("Scene state saved as .tres: ", scene_state_file_tres)

## Unload current save data and states
static func unload_save():
	Global.debug_log("SaveManager","SaveManager: Unloading save: \""+ active_save_name + "\"")

	_player_state = null
	_scene_state = null
	save_data = null
	active_save_name = "no save loaded"