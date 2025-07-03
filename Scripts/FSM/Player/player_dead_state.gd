extends PlayerState

var anim_name = "8 way Rifle Locomotion/Dying"
var played_once = false

func enter():
	context.animation_player.play(anim_name)
	print("From Dead State: %s" % context.animation_player)
	print(context.animation_player.current_animation)

func update(delta: float):
	if context.animation_player.current_animation != anim_name and !played_once:
		context.animation_player.play("8 way Rifle Locomotion/Dying")
		print("Player from Dead state update")
		played_once = true
