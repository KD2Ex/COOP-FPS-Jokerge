extends Node3D

@export var ammo_value: int = 30

func pickup(player: Player):
	player.pickup_ammo(ammo_value)
	player.interact_action = Callable()
	on_pikcup.rpc()

@rpc("any_peer", "call_local", "reliable")
func on_pikcup():
	queue_free()
