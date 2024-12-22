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
	for m in ranked_targets.keys():
		if ranked_targets[m] > target_threat:
			target_threat = ranked_targets[m]
			target = m
	return target
	

func add_threat(m : Monster, amount : int):
	ranked_targets[m] += amount

func decrease_threat(m : Monster, amount : int):
	ranked_targets[m] = max(0, ranked_targets[m] - amount)

func add_to_threats(m : Monster):
	ranked_targets[m] = 0


