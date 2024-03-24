extends Monster

func flip_sprite():
	var sprite3d : Sprite3D = $Sprite3D
	sprite3d.flip_h = !sprite3d.flip_h

