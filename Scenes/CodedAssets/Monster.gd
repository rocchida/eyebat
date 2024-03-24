extends Node3D
class_name Monster


@export var texture: Sprite3D


func flip_sprite():
	var sprite3d : Sprite3D = $Sprite3D
	sprite3d.flip_h = true
