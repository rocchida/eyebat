extends StaticBody3D

#func clicked():
	#print("clicked")
	#var monster : Monster = get_parent().get_parent()
	#var battleSpawn = get_parent().get_parent().get_parent()
	#SceneTool.get_root().monster_clicked(monster)

#func hovered():
	#var monster : Monster = get_parent().get_parent()
	#SceneTool.get_root().monster_hovered(monster)


func _on_mouse_entered():
	SceneTool.get_root().monster_hovered(get_parent().get_parent())

func _on_mouse_exited():
	SceneTool.get_root().monster_unhovered(get_parent().get_parent())

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		SceneTool.get_root().monster_clicked(get_parent().get_parent())
