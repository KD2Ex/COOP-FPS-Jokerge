extends State
class_name PlayerState

var context: Player

func _enter_tree() -> void:
	context = get_parent().get_parent() as Player
