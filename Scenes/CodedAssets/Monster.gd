extends Node3D
class_name Monster


@export var texture: Sprite3D
@export var max_health: int = 12
@export var strength: int = 5
@export var speed : int = 5


func flip_sprite():
	var sprite3d : Sprite3D = $Sprite3D
	sprite3d.flip_h = true

func get_speed():
	return speed
