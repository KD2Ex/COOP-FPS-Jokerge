extends Node3D

@export var dummy: PackedScene
@export var spawn_points: Array[Node3D]

@onready var respawn_timer: Timer = $Timer
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

var spawned: Dictionary[Vector3, Node3D]
var index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in spawn_points:
		spawned[i.global_position] = null
	multiplayer_spawner.spawn_function = spawn_dummy
	#if !is_multiplayer_authority(): return
	#spawn_rpc.rpc()
	

@rpc("authority", "call_local")
func spawn_rpc():
	
	spawn_all()


func spawn_all():
	print(multiplayer_spawner.spawn_function)
	for p in spawn_points:
		
		var inst = spawn_dummy()
		#var inst = multiplayer_spawner.spawn()
		spawned[p.global_position] = inst

@rpc("any_peer", "call_local", "reliable")
func spawn_dummy_rpc():
	spawn_dummy()

func spawn_dummy():
	var pos = get_empty_spot()
	if pos == Vector3.ZERO:
		return
	
	var inst: Node3D = dummy.instantiate()
	inst.remover = self
	add_child(inst, true)
	
	spawned[pos] = inst
	inst.global_position = pos
	
	if is_multiplayer_authority():
		inst.tree_exited.connect(respawn.bind(pos))

	index += 1
	return inst

func respawn(pos: Vector3):
	spawned[pos] = null
	
	var timer = get_tree().create_timer(2)
	await timer.timeout
	
	spawn_dummy_rpc.rpc()

func get_empty_spot():
	var index = 0
	for i in spawn_points:
		var node = spawned[i.global_position]
		if node == null:
			return i.global_position
	return Vector3.ZERO
	#if

func remove(key_pos: Vector3):
	
	remove_rpc_char.rpc(key_pos)

@rpc("any_peer", "call_local")
func remove_rpc_char(key_pos: Vector3):
	var character = spawned[key_pos]
	if !character:
		return
	character.queue_free()
