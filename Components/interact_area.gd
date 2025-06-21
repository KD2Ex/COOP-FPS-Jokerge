extends Area3D

signal interacted(player: Player)

@export var oneshot = true

var players: Array[Player]
var disabled = false

func interact(player: Player):
	if disabled: return
	
	interacted.emit(player)
	if oneshot:
		disabled = true

func _on_body_entered(body: Node3D) -> void:
	if disabled: return
	if body is not Player:
		return
	
	players.push_back(body)
	body.set_interact(self.interact.bind(body))

func _on_body_exited(body: Node3D) -> void:
	if body is not Player:
		return
	
	players.erase(body)
	body.set_interact(Callable())
