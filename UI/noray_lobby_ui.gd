extends Control

@onready var oid_label: Label = $OID
@onready var oid_input = $"VBoxContainer/OID Input"


func _on_host_pressed() -> void:
	NorayMultiplayer.host()
	
	multiplayer.peer_connected.connect(
		func(pid): 
			print("Peer: %s has joined the game!" % pid)
			#spawn the player
	)
	
	self.hide()


func _on_join_pressed() -> void:
	NorayMultiplayer.join(oid_input.text)
	self.hide()

func _on_copy_oid_pressed() -> void:
	DisplayServer.clipboard_set(Noray.oid)
