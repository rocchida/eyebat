extends Node3D
class_name BattleScene

var _enemy_spawns : SpawnGroup
var _player_spawns : SpawnGroup
var _initiative : Array[Monster]
enum state {ENEMIES_AND_PLAYERS_ALIVE, ENEMIES_DEAD, PLAYERS_DEAD, ALL_DEAD}
var current_turn : int
@export var debug : bool

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
