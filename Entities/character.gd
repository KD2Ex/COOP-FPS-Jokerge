extends CharacterBody3D

@export var color: Color

@onready var health_component: HealthComponent = $HealthComponent
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready():
	var material: Material = mesh.get_active_material(0)
	material.albedo_color = color

func take_damage(msg: DamageMessage):
	health_component.update_value(-msg.damage)
	if health_component.value <= 0:
		die.rpc()

@rpc("any_peer", "call_local")
func die():
	queue_free()
