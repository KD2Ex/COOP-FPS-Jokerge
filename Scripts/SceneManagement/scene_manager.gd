extends Node3D

@export var player_scene: PackedScene
@export var training_dummies: PackedScene
@export var training_node: Node3D

@onready var shooting_dummies: Node3D = $ShootingDummies


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

func on_all_players_connected():
	print("GAME SHOULD START IN =")
	spawn_training_dummies()
	pass

func spawn_training_dummies():
	#shooting_dummies.spawn_all()
	shooting_dummies.spawn_rpc.rpc()
