extends RefCounted
class_name Lobby

var host_id: int
var players: Dictionary = {}

func _init(id: int) -> void:
	host_id = id

func add_player(id: int, name: String):
	players[id] = {
		"name": name,
		"id": id,
		"index": players.size() + 1
	}
	return players[id]
