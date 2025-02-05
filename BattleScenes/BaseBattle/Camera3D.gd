extends Camera3D
var mouse = Vector2()


#func _input(event):
	#print(event)
	#if event is InputEventMouse:
		#mouse = event.position
		#hover_selection()
	#if event is InputEventMouseButton and event.pressed:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#click_selection()

#func hover_selection():
	#var worldspace = get_world_3d().direct_space_state
	#var start = project_ray_origin(mouse)
	#var end = project_position(mouse,1000)
	#var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start,end))
	#if result and result.collider.has_method("hovered"):
		#result.collider.hovered()

#func click_selection():
	#var worldspace = get_world_3d().direct_space_state
	#var start = project_ray_origin(mouse)
	#var end = project_position(mouse,1000)
	#var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(
#start,end))
	#if result and result.collider.has_method("clicked"):
		#result.collider.clicked()


