extends Node3D

@export var start_level: PackedScene
@export var player: PackedScene 
@export var inst_start_level: bool = false

@onready var noray_ui = $NorayLobbyUI
@onready var noray_oid_label = $NorayLobbyUI/OID
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner


var peer = ENetMultiplayerPeer.new()

func _enter_tree():
	if inst_start_level:
		var inst = start_level.instantiate()
		add_child(inst)
		GameManager.players[1] = {
			"id": 1,
			"name": "local",
			"color": Color.REBECCA_PURPLE
		}
	

func _ready():
	multiplayer_spawner.spawn_function = add_player
	await NorayMultiplayer.noray_connected
	
	noray_oid_label.text = Noray.oid

func start_game():
	var inst: Node3D = start_level.instantiate()
	add_child(inst)
	
	multiplayer_spawner.spawn_path = inst.get_path()
	#multiplayer_spawner.spawn(multiplayer.get_unique_id())

@rpc("any_peer", "call_local")
func spawn_start_level():
	var inst: Node3D = start_level.instantiate()
	add_child(inst)
	multiplayer_spawner.spawn_path = inst.get_path()


func add_player(pid):
	var player = self.player.instantiate()
	player.name = str(pid)
	
	return player 
