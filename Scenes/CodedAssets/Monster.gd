extends Node3D
class_name Monster


@export var max_health: int = 12
@export var strength: int = 5
@export var speed : int = 5
@export var mana : int = 5
@export var intelligence : int = 5

@export var attacks : Array[Attack]
@export var portrait: PackedScene

var health : int 
var healthbar
var root : BattleScene

func _ready():
	healthbar = $HealthBar/SubViewport/HealthBar3D

func init_healthbar():
	healthbar.set_max(float(max_health))
	healthbar.set_value(float(max_health))
	health = max_health

func take_damage(damage : int):
	if healthbar.get_value() > 0:
		print(health)
		health -= damage
		print(health)
		healthbar.set_value(health)
		SceneTool.get_root().end_turn()

func flip_sprite():
	var sprite3d : Sprite3D = $Sprite3D
	sprite3d.flip_h = true

func toggle_selector():
	var selector : Sprite3D = $Selector
	selector.visible = not selector.visible

func get_speed():
	return speed

func get_attack_names():
	var names : Array[String]
	for attack in attacks:
		names.append(attack.name)
	return names

func get_portrait():
	return portrait.instantiate() as Node2D
