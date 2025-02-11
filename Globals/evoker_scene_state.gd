class_name EvokerSceneState
extends Resource

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

static func get_scene_state(scene_tree : SceneTree) -> EvokerSceneState:
	var scene_state = EvokerSceneState.new()
	var persistent_nodes : Array[Node] = scene_tree.get_nodes_in_group("Persist")
	
	if persistent_nodes.size() > 0:
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
				scene_state.add_node_data_to_array(node_data)
			else:
				scene_state.add_node_data_to_array(node.save())

	# Saving states of objects
	var state_nodes : Array[Node] = scene_tree.get_nodes_in_group("save_object_state")
	
	if state_nodes.size() > 0:
		scene_state.clear_saved_states()
		
		for node in state_nodes:
			if !node.has_method("save"): # Check the node has a save function.
				Global.debug_log("evoker_scene_state","persistent node '%s' is missing a save() function, skipped" % node.name)
				continue
				
			scene_state.add_state_data_to_array(node.save())

	return scene_state

## Apply the scene state to the current scene.
## scene_tree: The SceneTree of the relevant scene.
func apply(scene_tree: SceneTree):
	Global.debug_log("EvokerSceneState","Applying scene state. Res: " + str(self))
	
	# Deleting all current nodes that are in the Persist group as to not clone objects.
	var save_nodes = scene_tree.get_nodes_in_group("Persist")
	for i in save_nodes:
		Global.debug_log("SaveManager","Deleting existing node: "+ i.name)
		i.queue_free()
		
	var array_of_node_data = saved_nodes
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
	var array_of_state_data = saved_states
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
		