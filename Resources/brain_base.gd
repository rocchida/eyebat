extends Resource
class_name Brain

@export_range(0,5) var threat_from_dmg : float
@export_range(0,5) var threat_from_healing : float
@export_range(0,5) var threat_from_missing_hp : float
@export_range(0,1) var threat_decay : float
@export var targeting_statuses : Array[Status]

var ranked_targets = {}

func choose_target():
	var target : Monster = null
	var target_threat = -1
	for m : Monster in ranked_targets.keys():
		if ranked_targets[m] > target_threat and !m.is_deadzo():
			target_threat = ranked_targets[m]
			target = m
	return target

func add_heal_threat(m : Monster, amount : int, flat_threat_added : int):
	ranked_targets[m] += (amount * threat_from_healing) + flat_threat_added

func add_dmg_threat(m : Monster, amount : int, flat_threat_added : int):
	ranked_targets[m] += (amount * threat_from_dmg) + flat_threat_added

func decrease_threat(m : Monster, amount : int):
	ranked_targets[m] = max(0, ranked_targets[m] - amount)

func add_to_threats(m : Monster):
	ranked_targets[m] = 0

func set_threats(ms : Array[Monster]):
	for m in ms:
		add_to_threats(m)


