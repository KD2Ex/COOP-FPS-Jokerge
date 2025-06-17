extends CharacterBody3D
class_name Player

@export var crouching_depth = .5
@export_subgroup("Movement")
@export var walking_speed: float = 5.0
@export var sprinting_speed: float = 8.0
@export var crouchin_speed: float = 3.0
@export_subgroup("Jumping")
@export var jump_force: float = 7.0
@export_subgroup("Sensitivity")
@export var mouse_sens: float = .4


@onready var current_speed = walking_speed
@onready var head = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var standing_collider = $StandingCollider
@onready var crouching_collider = $CrouchingCollider
@onready var ray_cast_3d: RayCast3D = $CrouchRayCast
@onready var label: Label = $Control/Label
@onready var state_machine: Node = $StateMachine
@onready var hand_container: Node3D = $Head/Camera/SubViewportContainer/SubViewport/Camera/HandContainer
@onready var ranged_weapon_controller: RangedWeaponController = $RangedWeaponController
@onready var mesh: MeshInstance3D = $MeshInstance3D

@onready var half_w_speed = walking_speed / 2

var movement_lerp_accel = 10.0
var air_lerp_speed = 3.0
var movement_input = Vector2.ZERO
var movement_direction = Vector3.ZERO

var sprint_input = false
var crouch_input = false
var jump_input = false

var head_og: float
var target_head_pos: float
var head_rotation_target: Vector3
var shooting_aimpunch_tween: Tween

@onready var hand_container_offset = hand_container.position
@onready var camera_og = $Head/Camera.position
@onready var camera_og_rotation = $Head/Camera.rotation

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_captured = true

func _ready():
	var id = multiplayer.get_unique_id()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	head_og = head.position.y
	target_head_pos = head_og - crouching_depth
	
	var weapon_model = hand_container.get_child(0)
	var color = GameManager.players[id].color
	weapon_model.set_color_recursive(color)
	mesh.get_active_material(0).albedo_color = color
	

func _process(delta: float):
	label.text = state_machine.current_state.name

func _physics_process(delta: float) -> void:
	
	action_shoot()
	
	sprint_input = Input.is_action_pressed("sprint")
	crouch_input = Input.is_action_pressed("crouch")
	
	hand_container.position = lerp(hand_container.position, hand_container_offset, delta * 5)
	camera.rotation.x = lerp_angle(camera.rotation.x, 0, delta * 10)
	camera.rotation.z = lerp_angle(camera.rotation.z, 0, delta * 10)
	camera.rotation.y = lerp_angle(camera.rotation.y, 0, delta * 10)
	
	if jump_input:
		if is_on_floor():
			state_machine.change_state("jump")
			jump_input = false
	if crouch_input and is_on_floor():
		crouch(delta)
	elif !ray_cast_3d.is_colliding():
		stand(delta)
		#if sprint_input:
			#current_speed = sprinting_speed
		#else:
			#current_speed = walking_speed
			
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = jump_force
	return
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	
	#get_movement_input()
	#update_movement_direction(delta)
	#apply_velocity()
	#move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_input = true
	if event.is_action_released("jump"):
		jump_input = false
	if event.is_action_pressed("escape"):
		toggle_mouse_mode()
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		var head_rot = deg_to_rad(-event.relative.y * mouse_sens)
		head.rotate_x(head_rot)
		head.rotation_degrees.x = clampf(head.rotation_degrees.x, -88, 90)
		
		head_rotation_target = head.rotation_degrees

func toggle_mouse_mode():
	if mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_captured = !mouse_captured

func get_movement_input():
	movement_input = Input.get_vector("left", "right", "forward", "backward")
	return movement_input

func update_movement_direction(delta: float, lerp_speed: float):
	var input_v3 = Vector3(movement_input.x, 0.0, movement_input.y).normalized()
	var target_direction = (transform.basis * input_v3)
	movement_direction = lerp(movement_direction, target_direction, lerp_speed * delta);

func apply_velocity():
	if movement_direction:
		velocity.x = movement_direction.x * current_speed
		velocity.z = movement_direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed / 2)
		velocity.z = move_toward(velocity.z, 0.0, current_speed / 2)

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta
		return true
	return false

func set_current_move_speed(speed: float):
	current_speed = speed

func crouch(delta: float):
	head.position.y = lerp(head.position.y, target_head_pos, delta * 10)
	crouching_collider.disabled = false
	standing_collider.disabled = true

func stand(delta: float):
	crouching_collider.disabled = true
	standing_collider.disabled = false
	head.position.y = lerp(head.position.y, head_og, delta * 10)

func is_standing():
	return abs(head.position.y - head_og) < 0.01

func jump():
	velocity.y = jump_force

func action_shoot():
	
	if Input.is_action_pressed("fire"):
		var shot = ranged_weapon_controller.shoot()
		if !shot: return
		
		hand_container.position.z += 0.25
		camera.rotation.x += 0.025
		#camera.rotation.y += randf_range(-0.02, 0.02)
		#camera.rotation.z += randf_range(-0.02, 0.02)
		


func shooting_aimpunch():
	if shooting_aimpunch_tween:
		shooting_aimpunch_tween.kill()
	
	shooting_aimpunch_tween = get_tree().create_tween()
	shooting_aimpunch_tween.tween

func take_damage(msg: DamageMessage):
	pass
