extends Node3D
class_name BattleSpawn

@export var seeBarrel: bool = true
var _occupying_monster: Monster = null

func _ready():
	if(!seeBarrel): $barrel2.hide()

func set_occupying_monster(_monster: Monster, face_left: bool):
	_occupying_monster = _monster
	add_child(_monster)
	_monster.set_global_position(self.get_global_position())
	_monster.init_healthbar()
	if (face_left):
		_monster.flip_sprite()