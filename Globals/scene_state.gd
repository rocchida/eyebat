class_name EvokerSceneState
extends Resource

var scene_state_dir : String = Global.STATE_DIR + Global.scene_state_prefix

@export var saved_nodes : Array
@export var saved_states : Array


func clear_saved_nodes():
	saved_nodes.clear()


func clear_saved_states():
	saved_states.clear()


func add_node_data_to_array(node_data):
	saved_nodes.append(node_data)


func add_state_data_to_array(state_data):
	saved_states.append(state_data)


func write_state(save_name : String, scene_name : String) -> void:
	var dir = DirAccess.open(Global.STATE_DIR)
	dir.make_dir(str(save_name))
	var scene_state_file = str(Global.STATE_DIR + save_name + "/" + Global.scene_state_prefix + scene_name + ".res")
	ResourceSaver.save(self, scene_state_file, ResourceSaver.FLAG_CHANGE_PATH)
	print("Scene state saved as ", scene_state_file)
	# For debug save as .tres
	#var scene_state_file_tres = str(Global.STATE_DIR + state_slot + "/" + Global.scene_state_prefix + scene_name + ".tres")
	#ResourceSaver.save(self, scene_state_file_tres, ResourceSaver.FLAG_CHANGE_PATH | ResourceSaver.FLAG_RELATIVE_PATHS)
	#print("Scene state saved as .tres: ", scene_state_file_tres)


# func load_state(save_name : String, scene_name : String) -> EvokerSceneState:
# 	var scene_state_file = str(Global.STATE_DIR + save_name + "/" + Global.scene_state_prefix + scene_name + ".res")
# 	return ResourceLoader.load(scene_state_file, "", ResourceLoader.CACHE_MODE_IGNORE)
