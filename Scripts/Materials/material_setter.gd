extends Node3D

func set_color_recursive(color: Color):
	for child in get_children():
		var mat = child.get_active_material(0)
		mat.albedo_color = color
