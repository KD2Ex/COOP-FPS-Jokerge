extends Control

@onready var oid_label: Label = $OID
@onready var oid_input = $"VBoxContainer/OID Input"
@onready var multiplayer_spawner: MultiplayerSpawner = $"../MultiplayerSpawner"

func _ready() -> void:
	pass

func _on_host_pressed() -> void:
	NorayMultiplayer.host()
	
	var host_color = GameManager.remaining_colors.pop_front()
	GameManager.players[1] = { "id": 1, "color": host_color }
	
	multiplayer.peer_connected.connect(
		func(pid): 
			print("Peer: %s has joined the game!" % pid)
			var player = multiplayer_spawner.spawn(pid)
			#spawn the player
			var color = GameManager.remaining_colors.pop_front()
			GameManager.players[pid] = { "id": pid, "color": color}
			#on_player_entered.rpc_id(pid, pid, color)
			var data = GameManager.players
			#on_player_entered.rpc_id(pid, data)
			on_player_entered.rpc(pid, data)
	)
	
	self.hide()
	get_parent().start_game()
	var node = multiplayer_spawner.spawn(multiplayer.get_unique_id())
	node.current_color = host_color


func _on_join_pressed() -> void:
	if oid_input.text == "":
		return
	NorayMultiplayer.join(oid_input.text)
	get_parent().start_game()
	self.hide()

func _on_copy_oid_pressed() -> void:
	DisplayServer.clipboard_set(Noray.oid)

@rpc("any_peer", "reliable")
func on_player_entered(pid, data):
	#GameManager.players[player].node.current_color = color
	GameManager.players = data
	
	var players = get_tree().get_nodes_in_group("Players")
	var pl = players.find_custom(func(p):
		#print("On player entered 'p': %s" % p)
		return p.name == str(pid))
	
	if pl == -1: return
	
	players[pl].current_color = data[pid].color
	print(multiplayer.get_unique_id())
