class_name Monster extends Node3D

enum ShaderState { NORMAL, HOVERED, SELECTED }

signal sprite_hovered(monster : Monster)
signal sprite_unhovered(monster : Monster)
signal sprite_clicked(monster : Monster)

var healthbar : ProgressBar
var manabar : ProgressBar
var status_tracker : StatusTracker
var sprite : MonsterSprite
var shader_state : ShaderState = ShaderState.NORMAL

@export var max_health: int = 120
@export var max_mana : int = 50
@export var health : int = 120
@export var atk : int = 5
@export var def : int = 5
@export var mana : int = 50
@export var magic : int = 5
@export var res : int = 5
@export var spd : int = 5

@export var attacks : Array[Attack]
@export var brain : Brain

var current_statuses_dict = {}


func _ready():
	sprite = $Sprite3D

func prepare_ui():
	healthbar = $HealthBar/SubViewport/HealthBar3D
	manabar = $ManaBar/SubViewport/ManaBar3D
	status_tracker = $"Status Tracker"

func init_health_and_mana_bar():
	prepare_ui()
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
				buff_mod += (int)(statBuff.percent_affected * stat)
				buffs_debug = buffs_debug + key.name + " adds " + str(statBuff.percent_affected * stat) + " to " + str(StatStatus.stats.keys()[statType]) + ". "
		for statDebuff : StatStatus in key.stat_debuffs:
			if statDebuff.stat == statType:
				debuff_mod += (int)(statDebuff.percent_affected * stat)
				debuffs_debug = debuffs_debug + key.name + " subtracts " + str(statDebuff.percent_affected * stat) + " from " + str(StatStatus.stats.keys()[statType]) + ". "
	print(buffs_debug)
	print(debuffs_debug)
	var updated_stat = stat + buff_mod - debuff_mod
	print("Updated " + str(StatStatus.stats.keys()[statType]) + " value: Base(" + str(stat) + ") + Buff(" + str(buff_mod) + ") - Debuff(" + str(debuff_mod) + ") = "  + str(updated_stat))
	return updated_stat


func take_blockable_damage(ui : UI, damage : int, is_magic : bool):
	#// TODO come back to this.. In current state we may need boolean to check if a move is only a status inflicter
	if damage == 0:
		return 0
	
	var first_blocking_status : Status = get_first_status_with_blocking()
	if first_blocking_status != null:
		ui.debug("Damaged blocked by " + first_blocking_status.name + " status!")
		if first_blocking_status.lose_stack_when_damaged: 
			decrement_status(ui, first_blocking_status)
		return 0
	
	var damage_after_block
	if is_magic:
		damage_after_block = max(damage - get_modded_res(), 0)
		ui.debug("DMG(" + str(damage) + ") - RES(" + str(get_modded_res()) + ") = " + str(damage_after_block))
	else:
		damage_after_block = max(damage - get_modded_def(), 0)
		ui.debug("DMG(" + str(damage) + ") - DEF(" + str(get_modded_def()) + ") = " + str(damage_after_block))
	
	if damage_after_block != 0: take_damage(damage_after_block)
	if damage > 0: update_statuses_after_taking_damage(ui)
	return damage

func take_damage(damage : int):
	run_damaged_anim()
	if healthbar.get_value() > 0:
		health = max(health - damage, 0)
		healthbar.set_value(health)

func take_heal(ui : UI, amount : int):
	ui.debug(name + " healed for " + str(amount))
	health = min(health + amount, max_health)
	healthbar.set_value(health)
	return amount

func drain_mana(m : int):
	if manabar.get_value() > 0:
		mana -= m
		manabar.set_value(mana)

func flip_sprite():
	sprite.flip_h = true
	
func toggle_on_shader():
	sprite.set_alpha_one()

func toggle_off_shader():
	sprite.set_alpha_zero()

func set_outline_color(clr : Color):
	sprite.set_outline_color(clr)

func set_shader_state(state : ShaderState):
	match state:
		ShaderState.NORMAL:
			sprite.set_alpha_zero()
		ShaderState.HOVERED:
			sprite.set_alpha_one()
		ShaderState.SELECTED:
			sprite.set_alpha_one()
	shader_state = state


func get_speed():
	return spd

func get_attack_names():
	var names : Array[String]
	for attack in attacks:
		names.append(attack.name)
	return names

func is_deadzo():
	return health <= 0

#func get_portrait():
	#return portrait.instantiate() as Node2D

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

func kill_monster():
	self.visible = false
	current_statuses_dict.clear()

func make_visible():
	self.visible = true

func make_invisible():
	self.visible = false

func decrement_status(ui : UI, status : Status):
	var stacks_were : String = str(current_statuses_dict[status])
	if current_statuses_dict[status] == 1: 
		ui.debug(name + " wears off status " + status.name)
	current_statuses_dict[status] -= 1
	if current_statuses_dict[status] <= 0: 
		current_statuses_dict.erase(status)
	else: ui.debug("(" + name  + "'s " + status.name +  " Stacks were: " + stacks_were + ", now are: " + str(current_statuses_dict[status]) + ")")
	update_status_tracker()

func increment_status(ui : UI, status : Status):
	var stacks_were : String = str(current_statuses_dict[status])
	current_statuses_dict[status] += 1
	ui.debug("(" + name  + "'s " + status.name +  " Stacks were: " + stacks_were + ", now are: " + str(current_statuses_dict[status]) + ")")
	update_status_tracker()

func update_statuses_after_attacking(ui : UI):
	for status in current_statuses_dict:
		if status.lose_stack_when_attacking:
			ui.debug("Status stack decrements from attack")
			decrement_status(ui, status)
		if status.gain_stack_when_attacking:
			ui.debug("Status stack increments from attack")
			increment_status(ui, status)

func update_statuses_after_taking_damage(ui : UI):
	for status : Status in current_statuses_dict:
		if status.lose_stack_when_damaged:
			ui.debug("Status stack decrements from receiving damage")
			decrement_status(ui, status)
		if status.gain_stack_when_damaged:
			ui.debug("Status stack increments from receiving damage")
			increment_status(ui, status)

func get_first_status_with_blocking():
	for status in current_statuses_dict:
		if current_statuses_dict[status] > 0 and status.block_all_dmg:
			return status
	return null

func get_brain() -> Brain:
	return brain

func has_status_as_threatening(status : Status):
	return get_brain().targeting_statuses.has(status)

func has_monster_as_threat(monster : Monster):
	return get_brain().target_threat_dict.keys().has(monster)
