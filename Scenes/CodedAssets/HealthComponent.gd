extends Node3D
class_name HealthComponent

@export var MAX_HEALTH := 10
var health : int

func _ready():
	health = MAX_HEALTH

