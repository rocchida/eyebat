extends Node3D
class_name BattleScene

var _enemy_spawns : SpawnGroup
var _player_spawns : SpawnGroup

func _prepare():
	_enemy_spawns = $EnemySpawns
	_player_spawns = $PlayerSpawns

func populate_spawns(enemy_monster_roster: Array[Monster], player_monster_roster: Array[Monster]):
	_prepare()
	_enemy_spawns.populate_spawns(enemy_monster_roster)
	_player_spawns.populate_spawns(player_monster_roster)
