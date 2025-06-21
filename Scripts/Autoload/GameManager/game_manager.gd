extends Node

var colors = preload("res://Player/multiplayer_colors.tres")
var remaining_colors = []

var players = {}
var client_authority_id: int

func _ready():
	refill_colors()

func refill_colors():
	for i in colors.items:
		print(colors.items[i])
		remaining_colors.push_back(colors.items[i])

func set_client_authority(id):
	client_authority_id = id
