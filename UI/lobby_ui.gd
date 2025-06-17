extends Control

@export var manager: MultiplayerManager

func _ready():
	manager.on_game_start.connect(self.hide)

func _on_host_pressed() -> void:
	manager.start_host()
	manager.send_player_information("hostname", multiplayer.get_unique_id())


func _on_join_pressed() -> void:
	manager.join_host()

func _on_start_pressed() -> void:
	manager.start_game.rpc()
	#self.hide()
