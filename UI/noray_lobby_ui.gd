extends Control

@onready var oid_label: Label = $OID
@onready var oid_input = $"VBoxContainer/OID Input"
@onready var multiplayer_spawner: MultiplayerSpawner = $"../MultiplayerSpawner"

func _ready() -> void:
	pass

func _on_host_pressed() -> void:
	NorayMultiplayer.host()
	
	multiplayer.peer_connected.connect(
		func(pid): 
			print("Peer: %s has joined the game!" % pid)
			multiplayer_spawner.spawn(pid)
			#spawn the player
	)
	
	self.hide()
	get_parent().start_game()
	multiplayer_spawner.spawn(multiplayer.get_unique_id())


func _on_join_pressed() -> void:
	if oid_input.text == "":
		return
	NorayMultiplayer.join(oid_input.text)
	get_parent().start_game()
	self.hide()

func _on_copy_oid_pressed() -> void:
	DisplayServer.clipboard_set(Noray.oid)
