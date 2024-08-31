extends Node3D
class_name Monster


@export var monster_name : String = "Monster"
@export var max_health: int = 12
@export var max_mana : int = 5
@export var dex : int = 5
@export var str : int = 5
@export var will : int = 5
@export var cha : int = 5
@export var intl : int = 5

@export var attacks : Array[Attack]
@export var portrait: PackedScene

@export var health : int = max_health
var healthbar
@export var mana : int = 5
var manabar

var current_statuses : Array[Status]


func _ready():
	healthbar = $HealthBar/SubViewport/HealthBar3D
	manabar = $ManaBar/SubViewport/ManaBar3D

#func statuses_take_effect():
	#for status : Status in current_statuses:
		#if (status.percent_dmg_max_hp_per_turn != 0):
			#var percent_dmg = int(status.percent_dmg_max_hp_per_turn * float(max_health))
			#print("(" + name + ") STATUS " + status.name + " inflicts " + str(status.percent_dmg_max_hp_per_turn) + " percent of max hp (" + str(max_health) + ") for a total of " + str(percent_dmg))
			#await get_tree().create_timer(3.5).timeout
			#take_damage(percent_dmg)
#
		##take_damage(int(status.percent_dmg_current_hp_per_turn * float(health)))
		##take_damage(status.flat_dmg_per_turn)
		#status.stacks_remaining -= 1
	#
	#current_statuses = current_statuses.filter(func(status : Status): return status.stacks_remaining > 0)

func init_health_and_mana_bar():
	healthbar.set_max(float(max_health))
	healthbar.set_value(float(health))
	
	manabar.set_max(float(max_mana))
	manabar.set_value(float(mana))

func take_damage(damage : int):
	run_damaged_anim()
	if healthbar.get_value() > 0:
		health -= damage
		healthbar.set_value(health)

func drain_mana(m : int):
	if manabar.get_value() > 0:
		mana -= m
		manabar.set_value(mana)

func flip_sprite():
	var sprite3d : Sprite3D = $Sprite3D
	sprite3d.flip_h = true
	
func toggle_on_shader():
	$Sprite3D._set_alpha_one()

func toggle_off_shader():
	$Sprite3D._set_alpha_zero()

func set_outline_color(clr : Color):
	$Sprite3D._set_outline_color(clr)

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
	$AnimationPlayer.play("attack")
	$AnimationPlayer.queue("idle")
	
func run_damaged_anim():
	$AnimationPlayer.play("damaged")
	$AnimationPlayer.queue("idle")


