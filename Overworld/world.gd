extends Node3D
class_name World

@onready var player : Player = $player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_player_monsters(roster : Array[Monster]):
	for m in roster:
		self.add_child(m)
	player.set_monster_roster(roster)
	

