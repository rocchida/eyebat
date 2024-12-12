extends Resource
class_name Status

@export var name : String
@export_range (0, 100) var chance_to_hit: int
@export_range (0, 100) var max_stacks_possible: int
@export_range (0, 10) var stacks_on_hit: int
@export_range (0, 1) var percent_dmg_max_hp_per_turn : float
@export_range (0, 1) var percent_dmg_current_hp_per_turn : float
@export_range (0, 100) var flat_dmg_per_turn : int
@export var dmg_is_heal : bool

@export var lose_stack_on_turn : bool
@export var gain_stack_on_turn : bool
@export var lose_stack_when_attacking : bool
@export var gain_stack_when_attacking : bool
@export var lose_stack_when_damaged : bool
@export var gain_stack_when_damaged : bool

@export var block_all_dmg : bool

@export var stat_debuffs : Array[StatStatus]
@export var stat_buffs : Array[StatStatus]

var stacks_remaining : int = stacks_on_hit

func get_status_damage(ui : UI, m : Monster):
	var dmg = 0
	var healed_or_damaged = "damaged"
	if dmg_is_heal: healed_or_damaged = "healed"
	
	if (percent_dmg_current_hp_per_turn != 0):
		var percent_dmg = int(percent_dmg_current_hp_per_turn * float(m.max_health))
		ui.debug(m.name + " is " + healed_or_damaged + " by " + name + ", it does " + str(percent_dmg_current_hp_per_turn) + "% of current hp (" + str(m.health) + ") for a total of " + str(percent_dmg))
		dmg += percent_dmg
	if (percent_dmg_max_hp_per_turn != 0):
		var percent_dmg = int(percent_dmg_max_hp_per_turn * float(m.max_health))
		ui.debug(m.name + " is " + healed_or_damaged + " by " + name + ", it does " + str(percent_dmg_max_hp_per_turn) + "% of max hp (" + str(m.max_health) + ") for a total of " + str(percent_dmg))
		dmg += percent_dmg
	if (flat_dmg_per_turn != 0):
		var percent_dmg = int(flat_dmg_per_turn * float(m.max_health))
		ui.debug(m.name + " is " + healed_or_damaged + " by " + name + ", it does " + str(flat_dmg_per_turn) + " HP")
		#if dmg_is_heal: ui.debug("HP: " + str(m.health) + " -> NEW HP: " + str(m.health + flat_dmg_per_turn))
		#else: ui.debug("HP: " + str(m.health) + " -> NEW HP: " + str(m.health - flat_dmg_per_turn))
		dmg += flat_dmg_per_turn
	return dmg
