extends Node3D

@export var start_level: PackedScene
@export var inst_start_level: bool = false

@onready var noray_ui = $NorayLobbyUI
@onready var noray_oid_label = $NorayLobbyUI/OID

var peer = ENetMultiplayerPeer.new()

func _enter_tree():
	if inst_start_level:
		var inst = start_level.instantiate()
		add_child(inst)
		GameManager.players[1] = {
			"id": 1,
			"name": "local",
			"color": Color.REBECCA_PURPLE
		}
	

func _ready():
	
	await NorayMultiplayer.noray_connected
	
	noray_oid_label.text = Noray.oid
