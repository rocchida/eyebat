extends Node3D
class_name BattleScene

var _enemy_spawns : SpawnGroup
var _player_spawns : SpawnGroup
var _initiative : Array[Monster]
enum state {ENEMIES_AND_PLAYERS_ALIVE, ENEMIES_DEAD, PLAYERS_DEAD, ALL_DEAD}
enum turn_state {SELECTING_ACTION, ACTION_SELECTED}
var current_turn_state : turn_state = turn_state.SELECTING_ACTION
var current_turn : int = 0
var currently_selected_button : int = -1
@export var debug : bool
@onready var UI = $Ui

func _ready():
	SceneTool.set_root(self)
	UI.set_buttons(_initiative[current_turn].get_attack_names())
	UI.set_current_monster_stats(_initiative[current_turn])
	UI.set_initiative_board(_initiative)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		end_turn()

func _prepare():
	_enemy_spawns = $EnemySpawns
	_player_spawns = $PlayerSpawns

func populate_spawns(enemy_monster_roster: Array[Monster], player_monster_roster: Array[Monster]):
	_prepare()
	_enemy_spawns.populate_spawns(enemy_monster_roster)
	_player_spawns.populate_spawns(player_monster_roster)
	set_initiative(enemy_monster_roster, player_monster_roster)
	for m in _initiative:
		m.toggle_selector()
	_initiative[0].toggle_selector()
	
func set_initiative(enemy_monster_roster: Array[Monster], player_monster_roster: Array[Monster]):
	_initiative.append_array(enemy_monster_roster)
	_initiative.append_array(player_monster_roster)
	_initiative.sort_custom(sort_by_speed)
	if (debug): for m in _initiative: print(m.name + ", speed: " + str(m.get_speed()))

func sort_by_speed(a:Monster, b:Monster):
	if a.get_speed() > b.get_speed():
		return true
	return false

func end_turn():
	if (debug): print(_initiative[current_turn].name + " ends their turn")
	_initiative[current_turn].toggle_selector()
	current_turn = current_turn + 1
	if current_turn >= _initiative.size(): current_turn = 0
	if (debug): print(_initiative[current_turn].name + " begins their turn")
	_initiative[current_turn].toggle_selector()
	UI.set_buttons(_initiative[current_turn].get_attack_names())
	UI.set_current_monster_stats(_initiative[current_turn])
	UI.set_attack_description(null, null)
	currently_selected_button = -1

func monster_clicked(monster : Monster):
	if currently_selected_button != -1 and _initiative[current_turn].mana >= _initiative[current_turn].attacks[currently_selected_button].mana_cost:
		_initiative[current_turn].run_attack_anim(_player_spawns.contains(_initiative[current_turn]))
		_initiative[current_turn].attacks[currently_selected_button].play_sound($AudioStreamPlayer)
		_initiative[current_turn].drain_mana(_initiative[current_turn].attacks[currently_selected_button].mana_cost)
		monster.take_damage(_initiative[current_turn].attacks[currently_selected_button].get_damage(_initiative[current_turn]))

func monster_hovered(monster : Monster):
	UI.set_hovered_monster_stats(monster)

func _on_ui_button_clicked(i : int):
	currently_selected_button = i
	UI.set_attack_description(_initiative[current_turn].attacks[i], _initiative[current_turn])

