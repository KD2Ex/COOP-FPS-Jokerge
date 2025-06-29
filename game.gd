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
	var index = len(GameManager.players)
	var color = GameManager.remaining_colors[0]
	
	print("Player added: %s" % player.name)
	
	#if pid == 1:
		
	var key = multiplayer.get_unique_id()
	#
	#GameManager.players.get_or_add(pid, {
		#"id": pid,
		#"name": "",
		#"color": color,
		#"node": player
	#})
	
	#send_player_info.rpc(pid, pid, "", color, player)
	return player 

@rpc("any_peer", "call_local")
func send_player_info(key, id, p_name, color, player):
	#var clr = GameManager.remaining_colors.pop_front()
	GameManager.players[key] = {
		"id": id,
		"name": p_name,
		"color": color,
		"node": player
	}

@rpc("any_peer", "reliable")
func on_player_entered(color):
	return
	print(multiplayer.get_unique_id())
