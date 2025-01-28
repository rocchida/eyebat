extends Node

## List of connector nodes. These are used to place the Player in the correct position when they transition to this scene from a different scene. The Node name needs to match the passed string for this to work.
@export var connectors : Array[Node3D]

func move_player_to_connector(connector_name:String):
	for node in connectors:
		if node.get_name() == connector_name:
			Global.debug_log("Scene.gd", "Connector found, moving player to " + node.get_name() )
			PlayerGlobal.player.global_position = node.global_position
			PlayerGlobal.player.body.global_rotation = node.global_rotation
			return
	
	Global.debug_log("Scene.gd",  "No connector with name " + connector_name + " found.")

func _enter_tree() -> void:
	SceneSwitcher._current_scene_root_node = self
	Global.debug_log("Scene.gd", "Current scene root node set to " + SceneSwitcher._current_scene_root_node.name )
