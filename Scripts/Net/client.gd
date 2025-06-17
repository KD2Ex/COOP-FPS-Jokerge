extends Node
class_name ClientRTC

var peer = WebSocketMultiplayerPeer.new()
var id = 0

func _ready():
	NetUtils.Message.lobby

func _process(delta: float) -> void:
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var data_string = packet
			#var data = JSON.parse_string(data_string)
			var data = bytes_to_var_with_objects(packet)
			print("Got at client: %s" % data)
			if data.message == NetUtils.Message.id:
				data.id = int(data.id)
				id = int(data.id)
				print("Id is: " + str(id))

func connect_to_server(ip):
	peer.create_client("ws://127.0.0.1:8915")
	print("Started Client")
