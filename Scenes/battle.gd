extends Node3D
class_name BattleScene

enum state {ENEMIES_AND_PLAYERS_ALIVE, ENEMIES_DEAD, PLAYERS_DEAD, ALL_DEAD}
enum turn_state {SELECTING_ACTION, ACTION_SELECTED}
var enemy_spawns : SpawnGroup
var player_spawns : SpawnGroup
var initiative : Array[Monster]
var current_turn_state : turn_state = turn_state.SELECTING_ACTION
var current_turn : int = 0
var currently_selected_button : int = -1
var struggle_atk = "res://Resources/Attacks/struggle.tres"
@export var debug : bool
@onready var UI = $Ui
var _scene_switcher
var currently_targeted_monsters : Array[Monster]

func _ready():
	_scene_switcher = get_node("/root/SceneSwitcher")
	SceneTool.set_root(self)
	UI.set_buttons(current_monster().get_attack_names())
	UI.set_current_monster_stats(current_monster())
	UI.set_initiative_board(initiative)
	if is_enemy(initiative.front()): perform_ai_turn(current_monster())

func _prepare():
	enemy_spawns = $EnemySpawns
	player_spawns = $PlayerSpawns

func populate_spawns(enemy_monster_roster: Array[Monster], player_monster_roster: Array[Monster]):
	_prepare()
	enemy_spawns.populate_spawns(enemy_monster_roster)
	player_spawns.populate_spawns(player_monster_roster)
	set_initiative(enemy_monster_roster, player_monster_roster)
	for m in initiative:
		m.toggle_off_shader()
	initiative[0].toggle_on_shader()
	
func set_initiative(enemy_monster_roster: Array[Monster], player_monster_roster: Array[Monster]):
	initiative.append_array(enemy_monster_roster)
	initiative.append_array(player_monster_roster)
	initiative.sort_custom(sort_by_speed)
	if (debug): for m in initiative: print(m.name + ", speed: " + str(m.get_speed()))

func sort_by_speed(a:Monster, b:Monster):
	if a.get_speed() > b.get_speed():
		return true
	return false

func end_turn():
	if (debug): print(current_monster().name + " ends their turn")
	for m in initiative:
		m.toggle_off_shader()
	
	if(battle_is_over()):
		_scene_switcher.goto_overworld_scene("res://Scenes/world.tscn", get_all_goodguys())
	
	current_turn = current_turn + 1
	if current_turn >= initiative.size(): current_turn = 0
	
	currently_selected_button = -1
	if (debug): print(current_monster().name + " begins their turn")
	current_monster().toggle_on_shader()
	
	if (is_enemy(current_monster())):
		perform_ai_turn(current_monster())
	else:
		UI.show_buttons()
		UI.set_buttons(current_monster().get_attack_names())
		UI.set_current_monster_stats(current_monster())
		UI.set_attack_description(null, null)

func battle_is_over():
	if get_living_enemies().size() <= 0 or get_living_goodguys().size() <= 0:
		return true
	return false

func monster_clicked(clicked_monster : Monster):
	if currently_selected_button == -1 or current_monster().mana < current_selected_attack().mana_cost:
		return
	
	var ms : Array[Monster] = get_attacks_possible_targets()
	if clicked_monster not in ms:
		return
	
	if (currently_targeted_monsters.has(clicked_monster)):
		currently_targeted_monsters.erase(clicked_monster)
		if (clicked_monster == current_monster()):
			clicked_monster.toggle_on_shader()
		else: clicked_monster.toggle_off_shader() 
	else: 
		currently_targeted_monsters.append(clicked_monster)
		clicked_monster.set_outline_color(Color.DARK_RED)
	
	if (currently_targeted_monsters.size() == current_selected_attack().num_of_targets):
		run_attack(current_monster(), currently_targeted_monsters, current_selected_attack())
		currently_targeted_monsters.clear()
		end_turn()

func get_attacks_possible_targets():
	match current_selected_attack().target_type:
		Attack.target_types.ALL: return initiative
		Attack.target_types.ONLY_ALLIES: return get_all_goodguys()
		Attack.target_types.ONLY_ENEMIES: return get_living_enemies()
		Attack.target_types.ONLY_SELF: 
			var ret : Array[Monster]
			ret.append(current_monster())
			return ret

func run_attack(attacker : Monster, receivers : Array[Monster], attack : Attack):
	attacker.run_attack_anim(is_enemy(attacker))
	attack.play_sound($AudioStreamPlayer)
	attacker.drain_mana(attack.mana_cost)
	for m in receivers:
		m.take_damage(attack.get_damage(attacker))

func monster_hovered(monster : Monster):
	UI.set_hovered_monster_stats(monster)

func _on_ui_button_clicked(i : int):
	currently_selected_button = i
	UI.set_attack_description(current_monster().attacks[i], current_monster())

func current_monster():
	return initiative[current_turn]

func current_selected_attack() -> Attack:
	return current_monster().attacks[currently_selected_button]

func is_enemy(m : Monster):
	return (m.get_parent().get_parent() == enemy_spawns)

func perform_ai_turn(m : Monster):
	print("ENEMY TURN")
	UI.hide_buttons()
	await get_tree().create_timer(3.5).timeout
	perform_ai_attack(current_monster())
	end_turn()

func perform_ai_attack(m : Monster):
	var chosen_target = ai_choose_target()
	if (chosen_target == null): return
	var chosen_attack = ai_choose_attack(m)
	run_attack(m, chosen_target, chosen_attack)

func ai_choose_target():
	var living_goodguys = get_living_goodguys()
	if (living_goodguys.size() <= 0): return null
	var num = randi_range(0, living_goodguys.size() - 1)
	var targets : Array[Monster]
	targets.append(living_goodguys[num])
	return targets

func ai_choose_attack(m : Monster):
	var viable_attacks : Array[Attack]
	for atk in m.attacks:
		if atk.mana_cost <= m.mana:
			viable_attacks.append(atk)
	if viable_attacks.is_empty(): 
		return struggle_atk
	
	var num = randi_range(0, viable_attacks.size() - 1)
	return viable_attacks[num]
	

func get_living_enemies():
	var ret : Array[Monster]
	for m in initiative:
		if is_enemy(m) and !m.is_deadzo():
			ret.append(m)
	return ret

func get_living_goodguys():
	var ret : Array[Monster]
	for m in initiative:
		if !is_enemy(m) and !m.is_deadzo():
			ret.append(m)
	return ret

func get_all_goodguys():
	var ret : Array[Monster]
	for m in initiative:
		if !is_enemy(m):
			ret.append(m)
	return ret


