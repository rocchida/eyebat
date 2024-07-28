extends Node3D
class_name World

@onready var player : Player = $player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# I used this to rotate the skybox. If the rotation goes above 360, I rese the value to 0
func _process(_delta):
	$WorldEnvironment.environment.sky_rotation.y += 0.0005
	if ($WorldEnvironment.environment.sky_rotation.y > 359.9995):
		$WorldEnvironment.environment.sky_rotation.y == 0

func set_player_monsters(roster : Array[Monster]):
	for m in roster:
		self.add_child(m)
	player.set_monster_roster(roster)
	

