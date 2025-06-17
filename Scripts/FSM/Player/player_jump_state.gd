extends PlayerState

func enter():
	context.jump()

func update(delta: float):
	if context.is_on_floor() and context.velocity.y <= 0:
		if context.is_standing():
			change.emit("idle")
		else:
			change.emit("crouch")

func physics_update(delta: float):
	var input = context.get_movement_input()
	if input:
		context.update_movement_direction(delta, context.air_lerp_speed)
	context.apply_gravity(delta)
	context.apply_velocity()
	context.move_and_slide()
