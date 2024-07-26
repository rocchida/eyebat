extends Node3D
class_name Monster


@export var max_health: int = 12
@export var max_mana : int = 5
@export var dex : int = 5
@export var str : int = 5
@export var will : int = 5
@export var cha : int = 5
@export var intl : int = 5

@export var attacks : Array[Attack]
@export var portrait: PackedScene

var health : int 
var healthbar
var mana : int
var manabar
#var root : BattleScene

func _ready():
	healthbar = $HealthBar/SubViewport/HealthBar3D
	manabar = $ManaBar/SubViewport/ManaBar3D

func init_health_and_mana_bar():
	healthbar.set_max(float(max_health))
	healthbar.set_value(float(max_health))
	health = max_health
	
	manabar.set_max(float(max_mana))
	manabar.set_value(float(max_mana))
	mana = max_mana

func take_damage(damage : int):
	run_damaged_anim()
	if healthbar.get_value() > 0:
		print(health)
		health -= damage
		print(health)
		healthbar.set_value(health)
		#SceneTool.get_root().end_turn()

func drain_mana(m : int):
	if manabar.get_value() > 0:
		mana -= m
		manabar.set_value(mana)

func flip_sprite():
	var sprite3d : Sprite3D = $Sprite3D
	sprite3d.flip_h = true

func toggle_selector():
	var selector : Sprite3D = $Selector
	selector.visible = not selector.visible

func get_speed():
	return dex

func get_attack_names():
	var names : Array[String]
	for attack in attacks:
		names.append(attack.name)
	return names

func is_deadzo():
	return health <= 0

func get_portrait():
	return portrait.instantiate() as Node2D

func run_attack_anim(monster_is_ally):
	if monster_is_ally:
		$AnimationPlayer.play("attack_good")
	else:
		$AnimationPlayer.play("attack_bad")
	$AnimationPlayer.queue("idle")
	
func run_damaged_anim():
	$AnimationPlayer.play("damaged")
	$AnimationPlayer.queue("idle")
	
