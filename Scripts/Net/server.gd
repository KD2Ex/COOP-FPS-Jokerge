extends Node
class_name ServerRTC

var peer = WebSocketMultiplayerPeer.new()
var port = 8915
var users = {}
var lobbies = {}

var characters = "0123456789"

func _ready():
	peer.connect("peer_connected", peer_connected)
	peer.connect("peer_disconnected", peer_disconnected)

func _process(delta: float) -> void:
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var data_string = packet.get_string_from_utf8()
			var data = JSON.parse_string(data_string)
			print(data)
			
			if data.message == NetUtils.Message.lobby:
				data.id = int(data.id)
				join_lobby(data)
				
			if (data.message == NetUtils.Message.offer ||
			data.message == NetUtils.Message.candidate ||
			data.message == NetUtils.Message.answer):
				print("source id is: %s Message Data %s" % [data.og_peer, data.data])
				send_to_player(data.id, data)
				

func peer_connected(id):
	print("Peer Connected: " + str(id))
	var int_id = int(id)
	users[int_id] = {
		"id": int_id,
		"message": NetUtils.Message.id
	}
	send_to_player(id, users[int_id])
	#peer.get_peer(int_id).put_packet(JSON.stringify(users[int_id]).to_utf8_buffer())

func peer_disconnected(id):
	pass

func join_lobby(user):
	if user.lobbyId == "":
		user.lobbyId = genetrate_random_string() 
		lobbies[user.lobbyId] = Lobby.new(user.id)
	print(user.lobbyId)
	var player = lobbies[user.lobbyId].add_player(user.id, user.name)
	
	for p in lobbies[user.lobbyId].players:
		
		var data = {
			"message": NetUtils.Message.userConnected,
			"id": user.id
		}
		
		var playersJSON = JSON.stringify(lobbies[user.lobbyId].players)
		var lobby_info = {
			"message": NetUtils.Message.lobby,
			"players": playersJSON
		}
		
		send_to_player(p, lobby_info)
	
	var data = {
		"message": NetUtils.Message.userConnected,
		"id": user.id,
		"host": lobbies[user.lobbyId].host_id,
		"player": lobbies[user.lobbyId].players[user.id],
		"lobby_id": user.lobbyId
	}
	
	send_to_player(user.id, data)
	

func send_to_player(userId, data):
	peer.get_peer(userId).put_packet(JSON.stringify(data).to_utf8_buffer())
	#peer.get_peer(userId).put_packet(var_to_bytes_with_objects(data))

func genetrate_random_string():
	var result = ""
	for i in range(16):
		var random_index = randi() % characters.length()
		result += characters[random_index]
	return result

func start_server():
	peer.create_server(port)
	print("Started Server")
