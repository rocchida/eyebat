extends Node3D
class_name SpawnGroup

@export var spawn_points_4: Array[BattleSpawn]
@export var face_left: bool


func populate_spawns(monsters : Array[Monster]):
	for m in monsters.size():
		spawn_points_4[m].set_occupying_monster(monsters[m], face_left)

func contains(m: Monster):
	for s in spawn_points_4:
		if s.get_occupying_monster() == m:
			return true
	return false

func _on_battle_spawn_monster_clicked():
	pass # Replace with function body.
