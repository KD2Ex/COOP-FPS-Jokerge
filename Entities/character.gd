extends CharacterBody3D

@export var color: Color

@onready var health_component: HealthComponent = $HealthComponent
@onready var mesh: MeshInstance3D = $MeshInstance3D

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

@rpc("any_peer", "call_local", "reliable" )
func die():
	queue_free()
