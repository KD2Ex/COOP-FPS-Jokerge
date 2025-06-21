extends CharacterBody3D

@export var color: Color

@onready var health_component: HealthComponent = $HealthComponent
@onready var mesh: MeshInstance3D = $MeshInstance3D

@export var remover: Node3D

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

func _ready():
	var material: Material = mesh.get_active_material(0)
	material.albedo_color = color
	
	var authority_id = GameManager.client_authority_id#get_multiplayer_authority()
	print(authority_id)
	#multiplayer_synchronizer.set_multiplayer_authority(authority_id)

func take_damage(msg: DamageMessage):
	health_component.update_value.rpc(-msg.damage)
	print("New health: %s" % health_component.value)
	if health_component.value <= 0:
		die.rpc()
		if is_multiplayer_authority():
			return
			if remover.has_method("remove"):
				remover.remove(global_position)

@rpc("any_peer", "call_local", "reliable" )
func die():
	queue_free()
