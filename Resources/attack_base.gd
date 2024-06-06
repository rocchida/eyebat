extends Resource
class_name Attack

enum attack_type {STANDARD, STATUS, HEAL}
@export var type : attack_type = attack_type.STANDARD
@export var damage : int = 2
@export var name : String = "Spank"

func get_attack_name():
	return name

func get_type():
	return type

func get_damage(monster : Monster):
	return monster.strength
