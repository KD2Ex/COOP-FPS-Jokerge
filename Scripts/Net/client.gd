extends Node
class_name ClientRTC

var peer = WebSocketMultiplayerPeer.new()
var id = 0
var rtc_peer: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var host_id: int 
var lobby_id: String = ""

func _ready():
	NetUtils.Message.lobby

func _process(delta: float) -> void:
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var data_string = packet.get_string_from_utf8()
			var data = JSON.parse_string(data_string)
			#var data = bytes_to_var_with_objects(packet)
			print("Got at client: %s" % data)
			if data.message == NetUtils.Message.id:
				data.id = int(data.id)
				id = int(data.id)
				#print("Id is: " + str(id))
				host_id = data.host
				lobby_id = data.lobby_id
			if data.message == NetUtils.Message.userConnected:
				#GameManager.players[data.id] = data.player
				create_peer(data.id)
			
			if data.message == NetUtils.Message.lobby:
				GameManager.players = JSON.parse_string(data.players)
				print(data.players)

func create_peer(id):
	if id != self.id:
		var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
		peer.initialize({
			"iceServers": [{ "urls": ["stun:stun.l.google.com:19302"] }]
		})
		print("binding id: " + str(id) + " my id is " + str(self.id))
		
		peer.session_description_created.connect(self.offer_created.bind(id))
		peer.ice_candidate_created.connect(self.ice_candidate_created.bind(id))
		rtc_peer.add_peer(peer, id)
		
		if host_id < rtc_peer.get_unique_id():
			peer.create_offer()
		
	pass

func offer_created(type, data, id):
	if !rtc_peer.has_peer(id):
		return
	
	rtc_peer.get_peer(id).connection.set_local_description(type, data)
	
	if type == "offer":
		send_offer(id, data)
	else:
		send_answer(id, data)
	pass


func send_offer(id, data):
	var message = {
		"peer": id,
		"og_peer": self.id,
		"message": NetUtils.Message.offer,
		"data": data,
		"lobby": lobby_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func send_answer(id, data):
	var message = {
		"peer": id,
		"og_peer": self.id,
		"message": NetUtils.Message.answer,
		"data": data,
		"lobby": lobby_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func ice_candidate_created(mid_name, index_name, sdp_name, id):
	var message = {
		"peer": id,
		"og_peer": self.id,
		"message": NetUtils.Message.candidate,
		"mid": mid_name,
		"index": index_name,
		"sdp": sdp_name,
		"lobby": lobby_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
func connect_to_server(ip):
	peer.create_client("ws://127.0.0.1:8915")
	print("Started Client")
