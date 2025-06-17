extends Node
class_name MultiplayerManager

signal on_game_start

@export var address = "127.0.0.1"
@export var port = 8910

var peer

func _ready() -> void:
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

func player_connected(id):
	print("Player connected: %s" % id)

func player_disconnected(id):
	print("Player disconnected: %s" % id)

func connected_to_server():
	print("connected!")
	send_player_information.rpc_id(1, "", multiplayer.get_unique_id())

func connection_failed():
	print("Connect Fail")

func start_host():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 8)
	
	if error != OK:
		print("cannot host: " + error)
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("waiting for players")
	send_player_information("hostname", multiplayer.get_unique_id())

func join_host():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://Levels/test_level.tscn").instantiate()
	get_tree().root.add_child(scene)
	on_game_start.emit()

@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name": name,
			"id": id,
			"score": 0,
			"color": GameManager.colors.items[len(GameManager.players)]
		}
	
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i].name, i)
