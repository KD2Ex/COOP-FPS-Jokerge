extends Node
class_name Interactable

func interact(player: Player):
	print("%s interacted with %s" % [player.name, get_parent().name])
	pass
