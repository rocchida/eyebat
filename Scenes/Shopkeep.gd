extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_exited(body: Player):
	$"../UI".visible = false


func _on_body_entered(body: Player):
	$"../UI".visible = true
	$"../UI/Panel/Control/AnimationPlayer".play("shopkeep")
