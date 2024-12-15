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
	if is_enemy(initiative.front()): 
		perform_ai_turn(current_monster())
		UI.hide_buttons()
	UI.set_initiative_text(0, initiative, get_living_enemies())

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
	update_status_trackers()
	UI.hide_buttons()
	UI.debug(current_monster().name + " ends their turn \n")
	for m in initiative:
		m.toggle_off_shader()
	
	await get_tree().create_timer(4).timeout
	
	if(battle_is_over()):
		go_back_to_overworld()
	
	current_turn = current_turn + 1
	if current_turn >= initiative.size(): current_turn = 0
	while (initiative[current_turn].is_deadzo()):
		current_turn += 1
		if current_turn >= initiative.size(): current_turn = 0
	if current_turn >= initiative.size(): current_turn = 0
	UI.set_initiative_text(current_turn, initiative, get_living_enemies())
	
	currently_selected_button = -1
	if (current_monster() in get_all_goodguys()):
		UI.debug("Player's " + current_monster().name + " begins their turn")
	else:
		UI.debug("Enemy " + current_monster().name + " begins their turn")
	
	current_monster().toggle_on_shader()
	
	statuses_take_effect(current_monster())
	if (current_monster().is_deadzo()):
		UI.debug(current_monster().name + " is killed by its status!")
		current_monster().kill_monster()
		end_turn()
		return
	
	if (is_enemy(current_monster())):
		perform_ai_turn(current_monster())
	else:
		UI.show_buttons()
		UI.set_buttons(current_monster().get_attack_names())
		UI.set_current_monster_stats(current_monster())
		UI.set_attack_description(null, null)

func go_back_to_overworld():
	_scene_switcher.goto_overworld_scene("res://Scenes/world.tscn", get_all_goodguys())

func update_status_trackers():
	for m : Monster in initiative:
		m.update_status_tracker()

func statuses_take_effect(m : Monster):
	for status : Status in m.current_statuses_dict:
		if m.current_statuses_dict[status] <= 0:
			update_status_trackers()
			continue
		if status.gain_stack_on_turn: m.increment_status(UI, status)
		if status.dmg_is_heal: m.take_heal(UI, status.get_status_damage(UI, m))
		else: m.take_damage(status.get_status_damage(UI, m))
		get_tree().create_timer(4).timeout
		if status.lose_stack_on_turn: m.decrement_status(UI, status)
		update_status_trackers()

func battle_is_over():
	if get_living_enemies().size() <= 0 or get_living_goodguys().size() <= 0:
		return true
	return false

func monster_clicked(clicked_monster : Monster):
	if currently_selected_button == -1 or current_monster().mana < current_selected_attack().mana_cost:
		return
	
	var ms : Array[Monster] = get_attacks_possible_targets(current_selected_attack())
	if clicked_monster not in ms:
		return
	
	currently_targeted_monsters.append(clicked_monster)
	
	if (currently_targeted_monsters.size() == current_selected_attack().num_of_targets or current_selected_attack().randomly_choose_target):
		await run_attack(current_monster(), currently_targeted_monsters, current_selected_attack())
		currently_targeted_monsters.clear()
		end_turn()

func get_attacks_possible_targets(atk : Attack):
	match atk.target_type:
		Attack.target_types.ALL: return initiative
		Attack.target_types.ONLY_ALLIES: 
			if is_enemy(current_monster()): return get_living_enemies() 
			else: return get_living_goodguys()
		Attack.target_types.ONLY_ENEMIES: 
			if is_enemy(current_monster()): return get_living_goodguys()
			return get_living_enemies()
		Attack.target_types.ONLY_DEAD_MONSTERS:
			return get_all_dead_monsters()
		Attack.target_types.ONLY_SELF: 
			var ret : Array[Monster]
			ret.append(current_monster())
			return ret

func run_attack(attacker : Monster, receivers : Array[Monster], attack : Attack):
	attacker.run_attack_anim(is_enemy(attacker))
	attacker.drain_mana(attack.mana_cost)
	attacker.update_statuses_after_attacking(UI)
	for num in range(attack.num_of_targets):
		if(battle_is_over()):
			go_back_to_overworld()
			
		var receiver
		if attack.randomly_choose_target:
			receiver = choose_random_target(get_attacks_possible_targets(attack))
		else: receiver = receivers[num]
		
		receiver.receive_attack(UI, attack, attacker, $AudioStreamPlayer)
		if attack.num_of_targets > 1 : await get_tree().create_timer(3.5).timeout

func monster_hovered(monster : Monster):
	UI.set_hovered_monster_stats(monster)
	#if (currently_selected_button == -1):
		#monster.set_outline_color(Color.WHITE_SMOKE)
	#monster.set_outline_color(current_selected_attack().hover_target_outline_clr)

func monster_unhovered(monster : Monster):
	UI.set_hovered_monster_stats(monster)
	#if (monster != current_monster()):
		#monster.toggle_off_shader()
	#elif (currently_targeted_monsters.has(monster)): 
		#return
	#else:
		#monster.toggle_on_shader()

func _on_ui_button_clicked(i : int):
	if currently_selected_button != -1:
		current_monster().toggle_on_shader()
	currently_selected_button = i
	UI.set_attack_description(current_monster().attacks[i], current_monster())
	clear_all_monster_outlines()
	show_dead_monsters_if_targetable()
	outline_possible_targets()

func clear_all_monster_outlines():
	for m in initiative:
		if m != current_monster():
			m.toggle_off_shader()

func outline_possible_targets():
	var targets = get_attacks_possible_targets(current_selected_attack())
	for m : Monster in targets:
		m.set_outline_color(current_selected_attack().hover_target_outline_clr)
		
func show_dead_monsters_if_targetable():
	if current_selected_attack().target_type == Attack.target_types.ONLY_DEAD_MONSTERS:
		for m : Monster in initiative:
			if m.is_deadzo(): m.make_visible()
	else: 
		for m : Monster in initiative:
			if m.is_deadzo(): m.make_invisible()

func current_monster():
	return initiative[current_turn]

func current_selected_attack() -> Attack:
	return current_monster().attacks[currently_selected_button]

func is_enemy(m : Monster):
	return (m.get_parent().get_parent() == enemy_spawns)

func perform_ai_turn(m : Monster):
	print("ENEMY TURN")
	await get_tree().create_timer(3.5).timeout
	perform_ai_attack(current_monster())
	end_turn()

func perform_ai_attack(m : Monster):
	var chosen_attack = ai_choose_attack(m)
	var chosen_targets = choose_random_targets(get_attacks_possible_targets(chosen_attack), chosen_attack.num_of_targets)
	if (chosen_targets == null): return
	run_attack(m, chosen_targets, chosen_attack)

#func ai_choose_target():
	#var living_goodguys = get_attacks_possible_targets()
	#if (living_goodguys.size() <= 0): return null
	#var num = randi_range(0, living_goodguys.size() - 1)
	#var targets : Array[Monster]
	#targets.append(living_goodguys[num])
	#return targets

func choose_random_targets(monsters : Array[Monster], num_of_targets : int):
	var targets : Array[Monster]
	for i in num_of_targets:
		var num = randi_range(0, monsters.size() - 1)
		targets.append(monsters[num])
	return targets

func choose_random_target(monsters : Array[Monster]):
	return choose_random_targets(monsters, 1)[0]

func ai_choose_attack(m : Monster):
	var viable_attacks : Array[Attack]
	for atk in m.attacks:
		if atk.mana_cost <= m.mana:
			viable_attacks.append(atk)
	if viable_attacks.is_empty(): 
#	TODO struggle_atk is not loaded figure out how to load properly
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

func get_all_dead_monsters():
	var ret : Array[Monster]
	for m in initiative:
		if m.is_deadzo():
			ret.append(m)
	return ret
