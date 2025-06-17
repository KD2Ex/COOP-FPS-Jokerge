extends PlayerState

var input: Vector2
var stand = false

func enter():
	context.set_current_move_speed(context.crouchin_speed)

func update(delta: float):
	if !context.crouch_input and !context.ray_cast_3d.is_colliding():
		if input == Vector2.ZERO:
			change.emit("idle")
		else:
			change.emit("walk")

func physics_update(delta: float):
	input = context.get_movement_input()
	context.update_movement_direction(delta, context.movement_lerp_accel)
	context.apply_velocity()
	context.apply_gravity(delta)
	context.move_and_slide()
