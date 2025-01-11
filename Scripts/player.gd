extends CharacterBody3D
class_name Player

@export var monster_roster : Array[PackedScene] 
@onready var _playerBody = $"."
const _SPEED = 5.0
const _JUMP_VELOCITY = 4.5
var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	print("")
	
# _physics_process is a function provided by Godot. TLDR - It runs like once a frame
# I used this as a main method and broke down all logic into smaller functions for readability
func _physics_process(delta):
	_handle_gravity_and_jumping(delta)
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	_update_animations(input_dir)
	_move_player(direction)
	move_and_slide()
			
func _handle_gravity_and_jumping(delta):
	if not is_on_floor():
		velocity.y -= _gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = _JUMP_VELOCITY
	
func _update_animations(direction):
	if (direction == Vector2.ZERO): 
		$AnimationTree.get("parameters/playback").travel("idle")
	else:
		$AnimationTree.get("parameters/playback").travel("walk")
		$AnimationTree.set("parameters/idle/blend_position", direction)
		$AnimationTree.set("parameters/walk/blend_position", direction)
	
func _move_player(direction):
	if direction:
		velocity.x = direction.x * _SPEED
		velocity.z = direction.z * _SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, _SPEED)
		velocity.z = move_toward(velocity.z, 0, _SPEED)

func set_monster_roster(roster : Array[Monster]):
	monster_roster.clear()
	for m in roster:
		monster_roster.append(m)
	
