extends RigidBody3D


func pickup(player: Player):
	player.pickup
	player.interact_action = Callable()
	on_pikcup.rpc()
	

@rpc("any_peer", "call_local", "reliable")
func on_pikcup():
	queue_free()
