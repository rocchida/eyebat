extends Node3D
class_name BattleScene

enum state {ENEMIES_AND_PLAYERS_ALIVE, ENEMIES_DEAD, PLAYERS_DEAD, ALL_DEAD}
enum turn_state {SELECTING_ACTION, ACTION_SELECTED}
var enemy_spawns : SpawnGroup
var player_spawns : SpawnGroup
var enemy_monsters : Array[Monster]
var player_monsters : Array[Monster]
var initiative : Array[Monster]
var current_turn_state : turn_state = turn_state.SELECTING_ACTION
var current_turn : int = 0
var currently_selected_button : int = -1
var struggle_atk = "res://Resources/Attacks/struggle.tres"
var current_monster : Monster:
	get:
		return initiative[current_turn]

## If On, will print extra debug messages
@export var debug_mode : bool

@onready var UI : UI = $UI
var currently_targeted_monsters : Array[Monster]

func _ready():
	UI.set_ability_buttons(current_monster.attacks)
	UI.set_current_monster_stats(current_monster)

	# connect monster signals
	for monster in player_monsters:
		monster.sprite_clicked.connect(monster_clicked)
		monster.sprite_hovered.connect(monster_hovered)
		monster.sprite_unhovered.connect(monster_unhovered)
	for monster in enemy_monsters:
		monster.sprite_clicked.connect(monster_clicked)
		monster.sprite_hovered.connect(monster_hovered)
		monster.sprite_unhovered.connect(monster_unhovered)
	
	#UI.set_initiative_board(initiative)
	print("Initiative (Ready): ", initiative)

func _prepare():
	enemy_spawns = $EnemySpawns
	player_spawns = $PlayerSpawns

func instantiate_monsters(enemy_monster_roster: Array[PackedScene]):
	# unpack the enemy_monster_roster
	for ps : PackedScene in enemy_monster_roster:
		enemy_monsters.append(ps.instantiate() as Monster)

	# unpack the player_monster_roster
	for ps : PackedScene in PlayerGlobal.monster_list:
		player_monsters.append(ps.instantiate() as Monster)

	# instantiate initiative
	set_initiative(enemy_monsters, player_monsters)

	#print("Initiative: (Insantiated)", initiative)

func populate_spawns():
	_prepare()
	enemy_spawns.populate_spawns(enemy_monsters)
	player_spawns.populate_spawns(player_monsters)
	for m in initiative:
		m.toggle_off_shader()
	initiative[0].toggle_on_shader()

	# first turn logic here so that it happens only after spawns are populated
	# may want to move it somewhere else
	if is_enemy(initiative.front()): 
		perform_ai_turn(current_monster)
		UI.hide_buttons()
	UI.set_initiative_text(0, initiative, get_living_enemies())
	for m in initiative:
		m.brain = m.get_brain().duplicate()
		if is_enemy(m):
			m.get_brain().set_threats(get_living_goodguys())
		else: m.get_brain().set_threats(get_living_enemies())
	
func set_initiative(enemy_monster_roster: Array[Monster], player_monster_roster: Array[Monster]):
	initiative.append_array(enemy_monster_roster)
	initiative.append_array(player_monster_roster)
	initiative.sort_custom(sort_by_speed)
	if (debug_mode): for m in initiative: print(m.name + ", speed: " + str(m.get_speed()))

func sort_by_speed(a:Monster, b:Monster):
	if a.get_speed() > b.get_speed():
		return true
	return false

func end_turn():
	current_monster.get_brain().decay_threats()
	update_status_trackers()
	UI.hide_buttons()
	UI.debug(current_monster.name + " ends their turn \n")
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
	if (current_monster in get_all_goodguys()):
		UI.debug("Player's " + current_monster.name + " begins their turn")
	else:
		UI.debug("Enemy " + current_monster.name + " begins their turn")
	
	current_monster.toggle_on_shader()
	
	statuses_take_effect(current_monster)
	if (current_monster.is_deadzo()):
		UI.debug(current_monster.name + " is killed by its status!")
		current_monster.kill_monster()
		end_turn()
		return
	
	if (is_enemy(current_monster)):
		perform_ai_turn(current_monster)
	else:
		UI.show_buttons()
		UI.set_ability_buttons(current_monster.attacks)
		UI.set_current_monster_stats(current_monster)
		UI.set_attack_description(null, null)

func go_back_to_overworld():
	var current_scene_name = get_tree().get_current_scene().get_name()
	var current_scene_path = get_tree().current_scene.scene_file_path
	SaveManager.save_scene_state(get_tree(), "temp")
	SaveManager.save_player_state(current_scene_name, current_scene_path,PlayerGlobal.player, null, "temp")	
	SceneSwitcher.fade_out()
	await SceneSwitcher.fade_finished	
	SceneSwitcher.load_next_scene("res://Scenes/world.tscn", "", "temp", SceneSwitcher.SceneLoadMode.TEMP)
	

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

func battle_is_over() -> bool:
	if get_living_enemies().size() <= 0 or get_living_goodguys().size() <= 0:
		return true
	return false

func monster_clicked(clicked_monster : Monster):
	if currently_selected_button == -1 or current_monster.mana < current_selected_attack().mana_cost:
		return
	
	var ms : Array[Monster] = get_attacks_possible_targets(current_selected_attack())
	if clicked_monster not in ms:
		return
	
	currently_targeted_monsters.append(clicked_monster)
	
	if (currently_targeted_monsters.size() == current_selected_attack().num_of_targets or current_selected_attack().randomly_choose_target):
		UI.hide_buttons()
		await run_attack(current_monster, currently_targeted_monsters, current_selected_attack())
		currently_targeted_monsters.clear()
		end_turn()

func get_attacks_possible_targets(atk : Attack):
	match atk.target_type:
		Attack.target_types.ALL: return initiative
		Attack.target_types.ONLY_ALLIES: 
			if is_enemy(current_monster): return get_living_enemies() 
			else: return get_living_goodguys()
		Attack.target_types.ONLY_ENEMIES: 
			if is_enemy(current_monster): return get_living_goodguys()
			return get_living_enemies()
		Attack.target_types.ONLY_DEAD_MONSTERS:
			return get_all_dead_monsters()
		Attack.target_types.ONLY_SELF: 
			var ret : Array[Monster]
			ret.append(current_monster)
			return ret
		Attack.target_types.ONLY_DEAD_ALLIES:
			if is_enemy(current_monster): return get_dead_enemies()
			else: return get_dead_goodguys()
		Attack.target_types.ONLY_DEAD_ENEMIES:
			if is_enemy(current_monster): return get_dead_goodguys()
			else: return get_dead_enemies()

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
		
		var team = "EVOKER'S "
		if is_enemy(receiver): team = "ENEMY "
		UI.debug(attacker.name + " uses " + attack.name + " on " + team + receiver.name)
		var threat_generated : int = await receive_attack(UI, attack, receiver, attacker, $AudioStreamPlayer)
		if !on_same_team(attacker, receiver):
			generate_threat_from_attack(threat_generated, attacker, receiver, attack)
		if attack.num_of_targets > 1 : await get_tree().create_timer(3.5).timeout

func receive_attack(ui : UI, attack : Attack, receiver : Monster, attacker : Monster, audioPlayer : AudioStreamPlayer) -> int:
	var threat_generated : int = 0
	for atk in attack.attacks_x_times:
		if atk > 0: 
			await get_tree().create_timer(2.5).timeout
			ui.debug(name + " recieves hit #" + str(atk + 1) + " from " + attack.name)
		attack.play_sound(audioPlayer)
		if attack.is_heal:
			threat_generated += receiver.take_heal(ui, attack.get_damage(ui, attacker))
		else:
			var dmg_done = receiver.take_blockable_damage(ui, attack.get_damage(ui, attacker), attack.is_magic_dmg)
			threat_generated += dmg_done
			if attack.percent_dmg_lifesteal != 0 and dmg_done != 0:
				ui.debug("Attacking " + attacker.name + " is healed " + str(attack.percent_dmg_lifesteal) + " from lifesteal!")
				attacker.take_heal(ui, attack.percent_dmg_lifesteal * dmg_done)
		if (receiver.is_deadzo()):
			ui.debug(name + " was killed by " + attack.name + "!")
			receiver.kill_monster()
			return threat_generated
		if attack.attack_statuses != null and attack.attack_statuses.size() > 0:
			var inflicted_statuses : Array[Status] = attack.inflict_statuses(ui, receiver)
			if !inflicted_statuses.is_empty(): generate_threat_for_inflicted_statuses(receiver, inflicted_statuses)
			receiver.update_status_tracker()
	return threat_generated

func generate_threat_from_attack(threat_generated : int, attacker : Monster, receiver : Monster, attack : Attack) -> void:
	var threatened_monsters : Array[Monster]
	
	if attack.threatens_all_enemies:
		if is_enemy(attacker):
			threatened_monsters = get_all_goodguys()
		else:
			threatened_monsters = get_living_enemies()
	else: threatened_monsters.append(receiver)
	
	for m in threatened_monsters:
		var total_threat_added : int = 0
		if attack.is_heal:
			total_threat_added += m.get_brain().add_heal_threat(attacker, threat_generated, attack.flat_threat_added)
		else: total_threat_added += m.get_brain().add_dmg_threat(attacker, threat_generated, attack.flat_threat_added)
		UI.debug(attacker.name + " threat level increased by " + str(total_threat_added) + " for " + m.name + " when they used " + attack.name)

func generate_threat_for_inflicted_statuses(status_inflicted_monster : Monster, new_statuses : Array[Status]) -> void:
	for m : Monster in initiative:
		for status : Status in new_statuses:
			if m.has_status_as_threatening(status) and m.has_monster_as_threat(status_inflicted_monster):
				m.get_brain().add_targeting_status_threat(status_inflicted_monster)
	

func monster_hovered(monster : Monster):
	# do a white smoke outline if no ability is selected
	if (currently_selected_button == -1):
		monster.set_outline_color(Color.WHITE_SMOKE)
	#elif(selected ability is offensive and monster is enemy)
	else:
		monster.set_outline_color(current_selected_attack().hover_target_outline_clr)
	pass

func monster_unhovered(monster : Monster):
	#if (monster != current_monster):
		#monster.toggle_off_shader()
	#elif (currently_targeted_monsters.has(monster)): 
		#return
	#else:
		#monster.toggle_on_shader()
	var clear = Color(0, 0, 0, 0)
	monster.set_outline_color(clear)
	pass

func _on_ui_button_clicked(i : int):
	if currently_selected_button != -1:
		current_monster.toggle_on_shader()
	currently_selected_button = i
	UI.set_attack_description(current_monster.attacks[i], current_monster)
	clear_all_monster_outlines()
	show_dead_monsters_if_targetable()
	outline_possible_targets()

func clear_all_monster_outlines():
	for m in initiative:
		if m != current_monster:
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

func current_selected_attack() -> Attack:
	return current_monster.attacks[currently_selected_button]

func is_enemy(m : Monster) -> bool:
	return (m.get_parent().get_parent() == enemy_spawns)

func perform_ai_turn(m : Monster) -> void:
	print("ENEMY TURN")
	await get_tree().create_timer(3.5).timeout
	await perform_ai_attack(current_monster)
	end_turn()

func perform_ai_attack(m : Monster):
	var chosen_attack : Attack = ai_choose_attack(m)
	var chosen_targets : Array[Monster]
	if chosen_attack.is_heal:
		chosen_targets = choose_random_targets(get_attacks_possible_targets(chosen_attack), chosen_attack.num_of_targets)
	else:
		chosen_targets.append(m.get_brain().get_most_threatening_target())
		if chosen_attack.num_of_targets > 1:
			chosen_targets.append_array(choose_random_targets(get_attacks_possible_targets(chosen_attack), chosen_attack.num_of_targets - 1))
	if (chosen_targets == null): return
	await run_attack(m, chosen_targets, chosen_attack)

func choose_random_targets(monsters : Array[Monster], num_of_targets : int) -> Array[Monster]:
	var targets : Array[Monster]
	for i in num_of_targets:
		var num = randi_range(0, monsters.size() - 1)
		targets.append(monsters[num])
	return targets

func choose_random_target(monsters : Array[Monster]) -> Monster:
	return choose_random_targets(monsters, 1)[0]

func ai_choose_attack(m : Monster) -> Attack:
	var viable_attacks : Array[Attack]
	for atk in m.attacks:
		if atk.mana_cost <= m.mana:
			viable_attacks.append(atk)
	
	# default to Struggle if no viable attacks
	if viable_attacks.is_empty(): 
		viable_attacks.append(struggle_atk) # TODO struggle_atk is not loaded figure out how to load properly
	
	var random_attack_index = randi_range(0, viable_attacks.size() - 1)
	return viable_attacks[random_attack_index]
	

func get_living_enemies() -> Array[Monster]:
	var ret : Array[Monster]
	for m in initiative:
		if is_enemy(m) and !m.is_deadzo():
			ret.append(m)
	return ret

func get_living_goodguys() -> Array[Monster]:
	var ret : Array[Monster]
	for m in initiative:
		if !is_enemy(m) and !m.is_deadzo():
			ret.append(m)
	return ret

func get_all_goodguys() -> Array[Monster]:
	var ret : Array[Monster]
	for m in initiative:
		if !is_enemy(m):
			ret.append(m)
	return ret

func get_all_dead_monsters() -> Array[Monster]:
	var ret : Array[Monster]
	for m in initiative:
		if m.is_deadzo():
			ret.append(m)
	return ret

func get_dead_goodguys() -> Array[Monster]:
	var ret : Array[Monster]
	for m in initiative:
		if !is_enemy(m) and m.is_deadzo():
			ret.append(m)
	return ret

func get_dead_enemies() -> Array[Monster]:
	var ret : Array[Monster]
	for m in initiative:
		if is_enemy(m) and m.is_deadzo():
			ret.append(m)
	return ret

func on_same_team(m1 : Monster, m2 : Monster) -> bool:
	if (is_enemy(m1) and is_enemy(m2)) or (!is_enemy(m1) and !is_enemy(m2)): return true
	else: return false
	
