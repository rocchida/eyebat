extends StaticBody3D

func clicked():
	print("clicked")
	var monster : Monster = get_parent().get_parent()
	var battleSpawn = get_parent().get_parent().get_parent()
	SceneTool.get_root().monster_clicked(monster)

func hovered():
	var monster : Monster = get_parent().get_parent()
	SceneTool.get_root().monster_hovered(monster)
