extends Node3D
class_name Monster


@export var max_health: int = 120
@export var max_mana : int = 50
@export var health : int = 120
var healthbar
@export var atk : int = 5
@export var def : int = 5
@export var mana : int = 50
var manabar
@export var magic : int = 5
@export var res : int = 5
@export var spd : int = 5


@export var attacks : Array[Attack]
@export var portrait: PackedScene

@onready var status_tracker = $"Status Tracker"

var current_statuses_dict = {}


func _ready():
	healthbar = $HealthBar/SubViewport/HealthBar3D
	manabar = $ManaBar/SubViewport/ManaBar3D

func init_health_and_mana_bar():
	healthbar.set_max(float(max_health))
	healthbar.set_value(float(health))
	
	manabar.set_max(float(max_mana))
	manabar.set_value(float(mana))

func get_modded_atk():
	return get_stat_with_buffs_and_debuffs(atk, StatStatus.stats.ATK)

func get_modded_def():
	return get_stat_with_buffs_and_debuffs(def, StatStatus.stats.DEF)

func get_modded_magic():
	return get_stat_with_buffs_and_debuffs(magic, StatStatus.stats.MAGIC)

func get_modded_res():
	return get_stat_with_buffs_and_debuffs(res, StatStatus.stats.RES)

func get_modded_spd():
	return get_stat_with_buffs_and_debuffs(spd, StatStatus.stats.SPD)


func get_stat_with_buffs_and_debuffs(stat : int, statType : StatStatus.stats):
	var buff_mod : int = 0
	var debuff_mod : int = 0
	var buffs_debug : String = "BUFFS: "
	var debuffs_debug : String = "DEBUFFS: "
	for key : Status in current_statuses_dict:
		for statBuff : StatStatus in key.stat_buffs:
			if statBuff.stat == statType:
				buff_mod += (statBuff.percent_affected * stat)
				buffs_debug = buffs_debug + key.name + " adds " + str(statBuff.percent_affected * stat) + " to " + str(StatStatus.stats.keys()[statType]) + ". "
		for statDebuff : StatStatus in key.stat_debuffs:
			if statDebuff.stat == statType:
				debuff_mod += (statDebuff.percent_affected * stat)
				debuffs_debug = debuffs_debug + key.name + " subtracts " + str(statDebuff.percent_affected * stat) + " from " + str(StatStatus.stats.keys()[statType]) + ". "
	print(buffs_debug)
	print(debuffs_debug)
	print("Updated " + str(StatStatus.stats.keys()[statType]) + " value: Base(" + str(stat) + ") + Buff(" + str(buff_mod) + ") - Debuff(" + str(debuff_mod) + ") = "  + str(stat + buff_mod - debuff_mod))
	var updated_stat = stat + buff_mod + debuff_mod
	return updated_stat

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
	return spd

func get_attack_names():
	var names : Array[String]
	for attack in attacks:
		names.append(attack.name)
	return names

func is_deadzo():
	return health <= 0

func get_portrait():
	return portrait.instantiate() as Node2D

func has_status(status : Status):
	return current_statuses_dict.has(status)

func run_attack_anim(monster_is_ally):
	$AnimationPlayer.play("attack")
	$AnimationPlayer.queue("idle")
	
func run_damaged_anim():
	$AnimationPlayer.play("damaged")
	$AnimationPlayer.queue("idle")

func update_status_tracker():
	status_tracker.update_text(current_statuses_dict)
	
