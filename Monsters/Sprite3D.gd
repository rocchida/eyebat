extends Sprite3D


func _set_alpha_zero():
	#var shader_material : ShaderMaterial = material_override
	#shader_material.set_shader_parameter("shader_parameter/line_color",Color(1, 1, 1, 0))
	material_override.set_shader_parameter("line_color",Color(1, 1, 1, 0))
	#material_override.set_shader_parameter("shader_parameter/glowRadialCoverage",float(1))
	
func _set_alpha_one():
	#var shader_material : ShaderMaterial = material_override
	#shader_material.set_shader_parameter("shader_parameter/line_color",Color(1, 1, 1, 1))
	material_override.set_shader_parameter("line_color",Color(1, 1, 1, 1))
	#material_override.set_shader_parameter("shader_parameter/glowRadialCoverage",float(4))

func _set_outline_color(clr : Color):
	material_override.set_shader_parameter("line_color", clr)
