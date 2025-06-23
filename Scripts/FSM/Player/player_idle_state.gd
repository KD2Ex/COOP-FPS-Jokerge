extends PlayerState

var input: Vector2

func enter():
	if context.animation_player == null:
		return
	context.animation_player.play("IdleFall/Rifle Idle")

func update(delta: float): 
	if context.crouch_input:
		change.emit("Crouch")
		return
	if input != Vector2.ZERO:
		if context.sprint_input:
			change.emit("Sprint")
			return
		if context.crouch_input:
			change.emit("Crouch")
			return
		change.emit("Walk")
	pass

func physics_update(delta: float):
	input = context.get_movement_input()
	context.update_movement_direction(delta, context.movement_lerp_accel)
	context.apply_velocity()
	var on_floor = context.apply_gravity(delta)
	context.move_and_slide()
