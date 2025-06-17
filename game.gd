extends Node3D

@export var start_level: PackedScene
@export var inst_start_level: bool = false

func _enter_tree():
	if inst_start_level:
		var inst = start_level.instantiate()
		add_child(inst)
		GameManager.players[1] = {
			"id": 1,
			"name": "local",
			"color": Color.REBECCA_PURPLE
		}
	
	
