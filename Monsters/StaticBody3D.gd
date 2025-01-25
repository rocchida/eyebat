extends StaticBody3D

#func clicked():
	#print("clicked")
	#var monster : Monster = get_parent().get_parent()
	#var battleSpawn = get_parent().get_parent().get_parent()
	#SceneSwitcher.current_scene.monster_clicked(monster)

#func hovered():
	#var monster : Monster = get_parent().get_parent()
	#SceneSwitcher.current_scene.monster_hovered(monster)

func _ready():
	pass


func _on_mouse_entered():
	SceneSwitcher.current_scene.monster_hovered(get_parent().get_parent())

func _on_mouse_exited():
	SceneSwitcher.current_scene.monster_unhovered(get_parent().get_parent())

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		SceneSwitcher.current_scene.monster_clicked(get_parent().get_parent())
