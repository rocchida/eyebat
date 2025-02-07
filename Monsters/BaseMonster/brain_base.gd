extends Resource
class_name Brain

@export_range(0,5) var threat_from_dmg : float
@export_range(0,5) var threat_from_healing : float
@export_range(0,5) var threat_from_missing_hp : float
@export_range(0,1) var threat_decay : float
@export var threat_added_from_targeting_status : int = 80
@export var targeting_statuses : Array[Status]

var target_threat_dict = {}

func _ready():
	threat_added_from_targeting_status = 80

#func choose_target(possible_targets : Array[Monster], num_of_targets : int): 
	##// Attack hightest threat first if multiple targets then rest can be random if more targets than 1
	#var targets : Array[Monster]
	#targets.append(get_most_threatening_target())
	#var i = 1
	#while i < num_of_targets:
		

func get_most_threatening_target():
	var target : Monster = null
	var target_threat = -1
	for m : Monster in target_threat_dict.keys():
		if target_threat_dict[m] > target_threat and !m.is_deadzo():
			target_threat = target_threat_dict[m]
			target = m
	return target

func add_heal_threat(m : Monster, amount : int, flat_threat_added : int):
	var threat_added : int = (int)(amount * threat_from_healing) + flat_threat_added
	target_threat_dict[m] += threat_added
	return threat_added

func add_dmg_threat(m : Monster, amount : int, flat_threat_added : int):
	var threat_added : int = (int)(amount * threat_from_dmg) + flat_threat_added
	target_threat_dict[m] += threat_added
	return threat_added

func add_targeting_status_threat(m : Monster):
	target_threat_dict[m] += threat_added_from_targeting_status
	print("")

func decrease_threat(m : Monster, amount : int):
	target_threat_dict[m] = max(0, target_threat_dict[m] - amount)

func decay_threats():
	for monster in target_threat_dict.keys():
		decrease_threat(monster, target_threat_dict[monster] * threat_decay)

func set_threats(ms : Array[Monster]):
	for m in ms:
		target_threat_dict[m] = 0


