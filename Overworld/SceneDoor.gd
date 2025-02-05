extends Area3D


@export var _target_scene : String
@export var _encounter_monster_roster : Array[PackedScene]
var _entered = false
var _player : Player

func _ready():
	pass


func _process(delta):
	if _entered:
		if Input.is_action_just_pressed("ui_accept"):
			SceneSwitcher.goto_battle_scene(_target_scene,  _encounter_monster_roster, _player.get_global_position())


func _on_body_entered(body: Node3D):	
	if(body is Player):
		_entered = true
		_player = body

func _on_body_exited(body: Node3D):
	if(body is Player):
		_entered = false
