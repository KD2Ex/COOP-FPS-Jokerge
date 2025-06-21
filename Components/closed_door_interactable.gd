extends Interactable

@export var requiered_item_id: int = 0

func interact(player: Player):
	super(player)
	
	if !player.items.has(requiered_item_id):
		return
	
	open.rpc()

@rpc("any_peer", "call_local", "reliable")
func open():
	get_parent().queue_free()
