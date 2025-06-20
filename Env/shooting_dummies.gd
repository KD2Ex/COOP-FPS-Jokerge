extends Node3D

@export var dummy: PackedScene
@export var spawn_points: Array[Node3D]

@onready var respawn_timer: Timer = $Timer

var spawned: Dictionary[Vector3, Node3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !is_multiplayer_authority(): return
	spawn_all.rpc()

@rpc("authority", "call_local")
func spawn_all():
	for p in spawn_points:
		var inst = spawn_dummy(p.global_position)
		spawned[p.global_position] = inst

func spawn_dummy(pos: Vector3):
	var inst: Node3D = dummy.instantiate()
	add_child(inst)
	inst.global_position = pos
	
	inst.tree_exited.connect(respawn.bind(pos))
	
	return inst

func respawn(pos: Vector3):
	var timer = get_tree().create_timer(2)
	
	await timer.timeout
	
	spawn_dummy(pos)
