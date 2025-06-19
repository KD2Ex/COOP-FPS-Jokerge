extends Node3D

@export var player_scene: PackedScene

func _ready():
	# DEPRECATED, USE MULTIPLAYER SPAWNER INSTEAD
	var index = 0
	for i in GameManager.players:
		var inst = player_scene.instantiate()
		inst.name = str(GameManager.players[i].id)
		add_child(inst)
		
		var points = get_tree().get_nodes_in_group("SpawnPoints")
		var node = points[0].get_children()[index]
		var pos = node.global_position
		inst.global_position = pos
		
		index += 1
