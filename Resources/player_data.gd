extends Resource
class_name PlayerData

const SAVE_GAME_PATH := "user://save.tres"

@export var global_position := Vector3.ZERO

func write_save():
	ResourceSaver.save(self, SAVE_GAME_PATH)

static func load_save():
	if not ResourceLoader.has_cached(SAVE_GAME_PATH):
		return ResourceLoader.load(SAVE_GAME_PATH, "", 1)
