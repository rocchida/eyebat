extends StaticBody3D

#func clicked():
	#print("clicked")
	#var monster : Monster = get_parent().get_parent()
	#var battleSpawn = get_parent().get_parent().get_parent()
	#SceneSwitcher.current_scene.monster_clicked(monster)

#func hovered():
	#var monster : Monster = get_parent().get_parent()
	#SceneSwitcher.current_scene.monster_hovered(monster)

var monster : Monster

func _ready():
	monster = get_parent().get_parent()
	if(monster == null || monster is not Monster):
		Global.debug_log("ClickableObject","Clickable must be the child of a Monster node")


func _on_mouse_entered():
	monster.sprite_hovered.emit(monster)

func _on_mouse_exited():
	monster.sprite_unhovered.emit(monster)

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		monster.sprite_clicked.emit(monster)
