extends Area3D

# Using exported files paths until Godot 4.4 is released. .4 will add support for choosing UIDs
@export_file("*.tscn") var _target_scene : String
@export_file("*.tscn") var _encounter_monster_roster_paths : Array[String] = []

var _entered = false
var _player : Player

func _ready():
	set_process(_entered)


func _process(delta: float) -> void:
	if _entered:
		if Input.is_action_just_pressed("ui_accept"):
			SceneSwitcher.goto_battle_scene(_target_scene,  _encounter_monster_roster_paths, _player.get_global_position())


func _on_body_entered(body: Node3D):	
	if(body is Player):
		_entered = true
		_player = body
		set_process(_entered)

func _on_body_exited(body: Node3D):
	if(body is Player):
		_entered = false
		set_process(_entered)
