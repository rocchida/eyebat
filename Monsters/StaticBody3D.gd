extends StaticBody3D


func clicked():
	print("clicked")
	get_parent().get_parent().take_damage()
