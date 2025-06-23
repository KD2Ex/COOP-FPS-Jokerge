extends PlayerState

var input: Vector2

func enter():
	context.set_current_move_speed(context.sprinting_speed)

func update(delta: float):
	if input == Vector2.ZERO:
		change.emit("idle")
		return
	context.play_sprint_animation(context.movement_input)
	if !context.sprint_input:
		change.emit("walk")
		return
	if context.crouch_input:
		change.emit("crouch")
		return


func physics_update(delta: float):
	input = context.get_movement_input()
	context.update_movement_direction(delta, context.movement_lerp_accel)
	context.apply_velocity()
	context.apply_gravity(delta)
	context.move_and_slide()
