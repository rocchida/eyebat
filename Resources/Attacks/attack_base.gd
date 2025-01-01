extends Resource
class_name Attack

enum target_types {ALL, ONLY_ALLIES, ONLY_ENEMIES, ONLY_SELF, ONLY_DEAD_MONSTERS}
@export var num_of_targets : int = 1
@export var hover_target_outline_clr : Color = Color.DARK_RED
@export var target_type : target_types = target_types.ALL
@export var randomly_choose_target : bool = false
@export var threatens_all_enemies : bool = false
@export var flat_threat_added : int = 0
@export var name : String = "Default Attack Name"
@export var sound : AudioStream

@export var is_heal : bool = false
@export var is_magic_dmg : bool = false
@export_range(0, 1) var percent_dmg_lifesteal : float = 0
@export_range(0, 100) var crit_chance : int = 0

@export var atk : bool = false
@export var def : bool = false
@export var magic : bool = false
@export var res : bool = false
@export var spd : bool = false

@export var mana_cost : int = 0

@export var d4s : int = 0
@export var d6s : int = 0
@export var d8s : int = 0
@export var d10s : int = 0
@export var d12s : int = 0
@export var d20s : int = 0
@export var attacks_x_times : int = 1
@export var attack_statuses : Array[Status]

func get_damage(ui : UI, monster : Monster):
	var damage = 0
	
	if (atk): damage += monster.get_modded_atk()
	if (def): damage += monster.get_modded_def()
	if (magic): damage += monster.get_modded_magic()
	if (res): damage += monster.get_modded_res()
	if (spd): damage += monster.get_modded_spd()
	
	damage += add_rolls(d4s, 4)
	damage += add_rolls(d6s, 6)
	damage += add_rolls(d8s, 8)
	damage += add_rolls(d10s, 10)
	damage += add_rolls(d12s, 12)
	damage += add_rolls(d20s, 20)
	
	if is_crit():
		ui.debug("CRITICAL HIT!! POWER " + str(damage) + " -> " + str(floor(damage * 1.5)))
		damage = floor(damage * 1.5)
	
	return damage

func inflict_statuses(ui : UI, m: Monster):
	for attack_status in attack_statuses:
		ui.debug(inflict_status(m, attack_status))

func inflict_status(m : Monster, attack_status : Status):
	if !status_succeeded(attack_status.chance_to_hit):
		return m.name + " resists against the " + attack_status.name + " status effect"
	if (m.current_statuses_dict.has(attack_status)):
		var stacks_were : String = str(m.current_statuses_dict[attack_status])
		m.current_statuses_dict[attack_status] += attack_status.stacks_on_hit
		m.current_statuses_dict[attack_status] = min(m.current_statuses_dict[attack_status], attack_status.max_stacks_possible)
		if (m.current_statuses_dict[attack_status] == attack_status.max_stacks_possible):
			return name + " is affected by " + attack_status.name + ", stacks are at max value! " + stacks_were_and_are(stacks_were, str( m.current_statuses_dict[attack_status])) 
		return name + " is affected by " + attack_status.name + " again from attack" + stacks_were_and_are(stacks_were, str(m.current_statuses_dict[attack_status]))
	else: m.current_statuses_dict[attack_status] = attack_status.stacks_on_hit
	return m.name + " recieves " + attack_status.name + " from attack (" + str(attack_status.stacks_on_hit) + " stacks)"

func stacks_were_and_are(were : String, are : String):
	return "(Stacks were: " + were + ", now are: " + are + ")"

func add_rolls(num_of_die: int, die: int):
	var ret = 0
	for n in num_of_die:
		ret += roll_die(die)
	return ret

func roll_die(die: int):
	return randi_range(1, die)

func get_damage_formula(m : Monster):
	var ret = ""
	if (atk): ret += "+ATK(" + str(m.get_modded_atk()) + ")"
	if (def): ret += " +DEF(" +str( m.get_modded_def()) + ")"
	if (magic): ret += " +MAGIC(" + str(m.get_modded_magic()) + ")"
	if (res): ret += " +RES(" + str(m.get_modded_res()) + ")"
	if (spd): ret += " +SPD(" + str(m.get_modded_spd()) + ")"
	
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

func is_crit():
	var chance_roll = randi_range(1,100)
	if (chance_roll < crit_chance): 
		return true
	else: return false

func status_succeeded(chance : int):
	if (chance == 100): return true
	if (chance == 0): return false
	var chance_roll = randi_range(1,100)
	if (chance_roll < chance): 
		print('STATUS SUCCEEDED, CHANCE:' + str(chance) + '   ROLL:' + str(chance_roll))
		return true
	print('STATUS FAILED, CHANCE:' + str(chance) + '   ROLL:' + str(chance_roll))
	return false
