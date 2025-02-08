extends Area3D

## If On, will automatically change scenes when player enters the range of the portal's collision shape.
@export var _forced_entry : bool = false
# Using exported files paths until Godot 4.4 is released (.4 will add support for choosing UIDs), 
# or until we change to using Resources with scene metadata.
## The Battle Scene the portal will transition to.
@export_file("*.tscn") var _target_scene : String
## The monster roster the player will face in battle.
@export_file("*.tscn") var _encounter_monster_roster_paths : Array[String] = []

var _entered = false
var _player : Player

func _ready():
	set_process(_entered)


func _process(delta: float) -> void:
	if _entered:
		if _forced_entry or Input.is_action_just_pressed("ui_accept"):
			SceneSwitcher.goto_battle_scene(_target_scene,  _encounter_monster_roster_paths)


func _on_body_entered(body: Node3D):	
	if(body is Player):
		_entered = true
		_player = body
		set_process(_entered)

func _on_body_exited(body: Node3D):
	if(body is Player):
		_entered = false
		set_process(_entered)
