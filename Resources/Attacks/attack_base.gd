extends Resource
class_name Attack

enum target_types {ALL, ONLY_ALLIES, ONLY_ENEMIES, ONLY_SELF}
@export var num_of_targets : int = 1
@export var hover_target_outline_clr : Color = Color.DARK_RED
@export var target_type : target_types = target_types.ALL
@export var name : String = "Default Attack Name"
@export var sound : AudioStream

@export var dex : bool = false
@export var str : bool = false
@export var will : bool = false
@export var cha : bool = false
@export var intl : bool = false

@export var mana_cost : int = 0

@export var d4s : int = 0
@export var d6s : int = 0
@export var d8s : int = 0
@export var d10s : int = 0
@export var d12s : int = 0
@export var d20s : int = 0
@export var percent_buffed : float = 1
@export var percent_nerfed : float = 1
@export var attack_status : Status

func get_damage(monster : Monster):
	var damage = 0
	
	if (dex): damage += monster.dex
	if (str): damage += monster.str
	if (will): damage += monster.will
	if (cha): damage += monster.cha
	if (intl): damage += monster.intl
	
	damage += add_rolls(d4s, 4)
	damage += add_rolls(d6s, 6)
	damage += add_rolls(d8s, 8)
	damage += add_rolls(d10s, 10)
	damage += add_rolls(d12s, 12)
	damage += add_rolls(d20s, 20)
	
	return damage

func inflict_statuses(m: Monster):
	if !status_succeeded(attack_status.chance_to_hit):
		return
	if (m.current_statuses_dict.has(attack_status)):
		m.current_statuses_dict[attack_status] += attack_status.stacks_on_hit
		m.current_statuses_dict[attack_status] = min(m.current_statuses_dict[attack_status], attack_status.max_stacks_possible)
		return name + " is affected by " + attack_status.name + " again from attack"
	else: m.current_statuses_dict[attack_status] = attack_status.stacks_on_hit
	return m.name + " recieves " + attack_status.name + " from attack"

func add_rolls(num_of_die: int, die: int):
	var ret = 0
	for n in num_of_die:
		ret += roll_die(die)
	return ret

func roll_die(die: int):
	return randi_range(1, die)

func get_damage_formula(m : Monster):
	var ret = ""
	if (dex): ret += "+DEX(" + str(m.dex) + ")"
	if (str): ret += " +STR(" +str( m.str) + ")"
	if (will): ret += " +WILL(" + str(m.will) + ")"
	if (cha): ret += " +CHA(" + str(m.cha) + ")"
	if (intl): ret += " +INTL(" + str(m.intl) + ")"
	
	if (d4s > 0): ret += " +" + str(d4s) + "d4 "
	if (d6s > 0): ret += " +" + str(d6s) + "d6 "
	if (d8s > 0): ret += " +" + str(d8s) + "d8 "
	if (d10s > 0): ret += " +" + str(d10s) + "d10 "
	if (d12s > 0): ret += " +" + str(d12s) + "d12 "
	if (d20s > 0): ret += " +" + str(d20s) + "d20 "
	
	return ret

func get_attack_name():
	return name

func play_sound(audio_player: AudioStreamPlayer):
	if sound != null:
		audio_player.stream = sound
		audio_player.play()

func status_succeeded(chance : int):
	if (chance == 100): return true
	if (chance == 0): return false
	var chance_roll = randi_range(1,100)
	if (chance_roll < chance): 
		print('STATUS SUCCEEDED, CHANCE:' + str(chance) + '   ROLL:' + str(chance_roll))
		return true
	print('STATUS FAILED, CHANCE:' + str(chance) + '   ROLL:' + str(chance_roll))
	return false
