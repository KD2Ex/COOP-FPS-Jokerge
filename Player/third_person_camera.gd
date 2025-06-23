extends Camera3D

var og

func _ready():
	og = global_position

func _process(delta: float) -> void:
	return
	global_rotation = Vector3.ZERO
	
