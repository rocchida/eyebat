extends Node
class_name Attack_Scene

@export var damage : int = 2
@export var attack_name : String = "Attack"

#static func new_attack(attack_name: String = "atk", damage: int = 1) -> Attack:
	#var my_scene = load("res://Scenes/CodedAssets/Attacks/Attack.tscn")
	#var new_attack: Attack = my_scene.instantiate()
	#new_attack.set_attack_name(attack_name)
	#new_attack.damage = damage
	#return new_attack
	
	
	
func _init(attack_name: String, damage: int):
	self.damage = damage
	self.attack_name = attack_name

func get_damage():
	return damage

func get_attack_name():
	return attack_name

func set_attack_name(attack_name : String):
	self.attack_name = attack_name
