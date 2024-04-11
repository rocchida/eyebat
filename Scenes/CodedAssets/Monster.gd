extends Node3D
class_name Monster


@export var texture: Sprite3D
@export var max_health: int = 12
@export var strength: int = 5
@export var speed : int = 5
var health : int = 10
var healthbar
var root : BattleScene

func _ready():
	healthbar = $HealthBar/SubViewport/HealthBar3D


func init_healthbar():
	healthbar.set_max(float(max_health))
	healthbar.set_value(float(health))

func take_damage():
	if healthbar.get_value() > 0:
		health -= 1
		healthbar.set_value(health)
		get_parent().get_parent().get_parent().end_turn()
	

func flip_sprite():
	var sprite3d : Sprite3D = $Sprite3D
	sprite3d.flip_h = true

func toggle_selector():
	var selector : Sprite3D = $Selector
	selector.visible = not selector.visible

func get_speed():
	return speed
