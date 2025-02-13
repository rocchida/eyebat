class_name Player extends CharacterBody3D

#signals
signal player_state_loaded()

@export var monster_roster : Array[PackedScene] 
#@export var inventory_data : Inventory
@onready var _playerBody = $"."
const _SPEED = 5.0
const _JUMP_VELOCITY = 4.5
var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	PlayerGlobal.player = self
	
# _physics_process is a function provided by Godot. TLDR - It runs like once a frame
# I used this as a main method and broke down all logic into smaller functions for readability
func _physics_process(delta : float):
	_handle_gravity_and_jumping(delta)
	var input_dir : Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	_update_animations(input_dir)
	_move_player(direction)
	move_and_slide()
			
func _handle_gravity_and_jumping(delta : float):
	if not is_on_floor():
		velocity.y -= _gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = _JUMP_VELOCITY
	
func _update_animations(_direction: Vector2):
	if (_direction == Vector2.ZERO): 
		$AnimationTree.get("parameters/playback").travel("idle")
	else:
		$AnimationTree.get("parameters/playback").travel("walk")
		$AnimationTree.set("parameters/idle/blend_position", _direction)
		$AnimationTree.set("parameters/walk/blend_position", _direction)

func get_current_sprite_direction():
	return $AnimationTree.get("parameters/idle/blend_position")

func set_sprite_direction(_direction : Vector2):
	$AnimationTree.set("parameters/idle/blend_position", _direction)
	
func _move_player(_direction : Vector3):
	if _direction:
		velocity.x = _direction.x * _SPEED
		velocity.z = _direction.z * _SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, _SPEED)
		velocity.z = move_toward(velocity.z, 0, _SPEED)

func set_monster_roster(roster : Array[Monster]):
	monster_roster.clear()
	for m in roster:
		monster_roster.append(m)
	
func _on_player_state_loaded():
	# apply custom logic, like resetting parameters that weren't saved
	pass