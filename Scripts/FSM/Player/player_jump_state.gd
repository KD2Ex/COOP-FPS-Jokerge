extends PlayerState

var jump_name = "8 way Rifle Locomotion/Jump Start"
var add_spd: float

func enter():
	context.jump()
	context.animation_player.play(jump_name)
	#add_spd += .3
	#context.animation_player.play_section(jump_name, 0.3)
	#context.update_animation_position.rpc(jump_name, 0.3)

func update(delta: float):
	if context.is_on_floor() and context.velocity.y <= 0:
		if context.is_standing():
			change.emit("idle")
		else:
			change.emit("crouch")
	
	if context.velocity.y < 0:
		if context.animation_player.current_animation.get_basename() != "Rifle Jump Start":
			context.animation_player.play("IdleFall/Falling Loop")
			#context.animation_player.play("Jump Landing")

func physics_update(delta: float):
	var input = context.get_movement_input()
	if input:
		context.update_movement_direction(delta, context.air_lerp_speed)
	context.apply_gravity(delta)
	context.apply_velocity(add_spd)
	context.move_and_slide()
