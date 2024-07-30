extends Sprite3D

func _ready() -> void:
#	if not material_override:	
	_apply_material_override()
	
	_apply_texture()
	texture_changed.connect(_apply_texture)


func _apply_material_override():
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://Monsters/outline.gdshader")
	material_override = shader_material


func _apply_texture():
	var shader_material : ShaderMaterial = material_override
	shader_material.set_shader_parameter("sprite_texture", texture)

func _set_alpha_zero():
	var shader_material : ShaderMaterial = material_override
	shader_material.set_shader_parameter("shader_parameter/line_color",Vector4(1.0,1.0,1.0,0.0))
	
func _set_alpha_one():
	var shader_material : ShaderMaterial = material_override
	shader_material.set_shader_parameter("shader_parameter/line_color",Vector4(1.0,1.0,1.0,1.0))
