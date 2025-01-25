extends Node

var player_state_prefix : String = "Evoker_player_state_"
var scene_state_prefix : String = "Evoker_scene_state_"
var default_transition_duration : float = .4
var STATE_DIR : String = "user://"

func debug_log(_class: String, _message: String) -> void:
		print(_class, ": ", _message)