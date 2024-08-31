extends Resource
class_name Status

@export var name : String
@export_range (0, 100) var chance_to_hit: int
@export_range (0, 100) var max_stacks_possible: int
@export_range (0, 10) var stacks_on_hit: int
@export_range (0, 1) var percent_dmg_max_hp_per_turn : float
@export_range (0, 1) var percent_dmg_current_hp_per_turn : float
@export_range (0, 100) var flat_dmg_per_turn : int
@export var stat_debuffs : Array[StatStatus]
@export var stat_buffs : Array[StatStatus]

var stacks_remaining : int = stacks_on_hit
