extends Control

@onready var client: ClientRTC = $Client
@onready var server: ServerRTC = $Server

@onready var lobby_id: LineEdit = $LobbyId


func _on_start_client_pressed() -> void:
	client.connect_to_server("")

func _on_start_server_pressed() -> void:
	server.start_server()

func _on_test_pressed() -> void:
	var message = {
		"message": NetUtils.Message.join,
		"data": "test"
	}
	
	var messageBytes = JSON.stringify(message).to_utf8_buffer()
	
	client.peer.put_packet(messageBytes)
	pass # Replace with function body.


func _on_join_lobby_pressed() -> void:
	var msg = {
		"id": client.id,
		"message": NetUtils.Message.lobby,
		"name": "",
		"lobbyId": lobby_id.text
	}
	client.peer.put_packet(JSON.stringify(msg).to_utf8_buffer())
	pass # Replace with function body.
