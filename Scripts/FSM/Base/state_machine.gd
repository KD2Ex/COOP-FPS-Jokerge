extends Node

@export var initial_state: State
@export var is_disabled: bool = false

var current_state: State 
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_state = initial_state
	current_state.enter()
	
	for state: State in get_children():
		state.change.connect(change_state)
	
	set_process(false)
	set_physics_process(false)


func _on_player_character_spawned() -> void:
	player = get_parent()
	set_process(true)
	set_physics_process(true)

func _process(delta: float) -> void:
	if !player && !player.get_authoriy(): return
	if is_disabled: 
		return
	current_state.update(delta)

func _physics_process(delta: float) -> void:
	if !player && !player.get_authoriy(): return
	if is_disabled: 
		return
	current_state.physics_update(delta)

func change_state(to: String):
	if !player.get_authoriy(): return
	if is_disabled:
		return
	current_state.exit()
	var name = to.to_lower()
	var new_state = get_children().find_custom(func(i): return i.name.to_lower() == name)
	
	#print(to, name, new_state)
	if new_state == -1:
		return
	
	current_state = get_children()[new_state]
	current_state.enter()
