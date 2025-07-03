extends CharacterBody3D
class_name Player

signal spawned

const crouch_animations: Dictionary[Vector2, String] = {
	Vector2(0, -1.0): "Crouch Walk Forward",
	Vector2(0, 1): "Crouch Walk Backward",
	Vector2(-1, 0): "Crouch Walk Left",
	Vector2(1, 0): "Crouch Walk Right",
	Vector2(0.7, -0.7): "Crouch Walk Forward Right",
	Vector2(-0.7, -0.7): "Crouch Walk Left",
	Vector2(0.7, 0.7): "Crouch Walk Backward Right",
	Vector2(-0.7, 0.7): "Crouch Walk Backward Left"
}

@export var crouching_depth = .5
@export_subgroup("Movement")
@export var walking_speed: float = 5.0
@export var sprinting_speed: float = 8.0
@export var crouchin_speed: float = 3.0
@export_subgroup("Jumping")
@export var jump_force: float = 7.0
@export_subgroup("Sensitivity")
@export var mouse_sens: float = .4

@export var hands_viewport_scene: PackedScene

@onready var current_speed = walking_speed
@onready var head = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var standing_collider = $StandingCollider
@onready var crouching_collider = $CrouchingCollider
@onready var ray_cast_3d: RayCast3D = $CrouchRayCast
@onready var label: Label = $Control/Label
@onready var state_machine: Node = $StateMachine
@onready var player_HUD: Control = $Control
@onready var health_label: RichTextLabel = $Control/VBoxContainer/HBoxContainer/HealthLabel
@onready var health_bar: TextureProgressBar = $Control/VBoxContainer/TextureProgressBar
@onready var ammo_label: RichTextLabel = $Control/VBoxContainer/HBoxContainer/AmmoLabel

@onready var ranged_weapon_controller: RangedWeaponController = $RangedWeaponController
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var health: HealthComponent = $HealthComponent

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

@onready var half_w_speed = walking_speed / 2
@onready var debug_label: Label = $Control/DebugLabel

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

@onready var camera_og = $Head/Camera.position
@onready var camera_og_rotation = $Head/Camera.rotation
@onready var visuals: Node3D = $Visuals
@onready var pickup_ray: ShapeCast3D = $Head/Camera/PickupRay

var animation_player: AnimationPlayer 

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_captured = true

var m_id: int
var hands_viewport_inst: SubViewportContainer
var hand_container: Node3D
var hand_container_offset: Vector3 

var interact_action: Callable

var items: Array[int] = []

var surface_mesh: MeshInstance3D
var joints_mesh: MeshInstance3D

var is_dead = false

var current_color: Color: 
	set(color):
		current_color = color
		
		if !surface_mesh or !joints_mesh: return
		
		surface_mesh.get_active_material(0).albedo_color = color
		joints_mesh.get_active_material(0).albedo_color = color
		
		if !hand_container: return
		var weapon_model = hand_container.get_child(0)
		weapon_model.set_color_recursive(current_color)
		#mesh.get_active_material(0).albedo_color = color

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
	var meshes = $Visuals/Armature/Skeleton3D.get_children()
	joints_mesh = meshes[0]
	surface_mesh = meshes[1]
	
	surface_mesh.get_active_material(0).albedo_color = current_color
	joints_mesh.get_active_material(0).albedo_color = current_color
	

func _ready():
	InputMap.load_from_project_settings()
	animation_player = visuals.get_node("AnimationPlayer")
	
	multiplayer_synchronizer.set_multiplayer_authority(str(name).to_int())
	m_id = multiplayer.get_unique_id()
	#current_color = GameManager.players[m_id].color
	#print(GameManager.players[m_id].color)
	#weapon_model.set_color_recursive(current_color)
	print("M_id: %s" % m_id)
	if !is_multiplayer_authority(): 
	#if multiplayer_synchronizer.get_multiplayer_authority() != m_id: 
		$ThirdPersonView.queue_free()
		camera.current = false
		debug_label.hide()
		player_HUD.hide()
		print("not an authority, disabling camera. From: %s. Client authority: %s" % [name, multiplayer_synchronizer.get_multiplayer_authority()])
		return
	
	debug_label.show()
	GameManager.set_client_authority(str(name).to_int())
	
	#visuals.hide()
	
	var hands_viewport_inst = hands_viewport_scene.instantiate()
	$Head/Camera.add_child(hands_viewport_inst)
	hand_container = hands_viewport_inst.get_child(0).get_child(0).get_child(0)
	hand_container_offset = hand_container.position
	
	#var color = GameManager.remaining_colors.pop_front()
	#var color = GameManager.get_player_color()
	
	
	camera.current = true
	print(name + " ready")
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	head_og = head.position.y
	target_head_pos = head_og - crouching_depth
	
	#mesh.get_active_material(0).albedo_color = color
	
	for i:MeshInstance3D in $Visuals/Armature/Skeleton3D.find_children("*", "MeshInstance3D"):
		#i.get_active_material(0).albedo_color = current_color
		i.layers = 4
	
	#current_color = color
	
	
	#set_color.rpc()#_id(MultiplayerPeer.TARGET_PEER_SERVER)
	if name == "1":
		items.push_back(0)
	
	spawned.emit()

func _process(delta: float):
	if multiplayer_synchronizer.get_multiplayer_authority() != m_id: return
	if !is_multiplayer_authority(): return
	label.text = state_machine.current_state.name
	rotation.y = lerp_angle(rotation.y, head_rotation_target.y, delta * 30)
	
	debug_label.text = "FP Camera: %s\nauthority id: %s\n" % [camera.current, get_multiplayer_authority()]
	#debug_label.text += "Sync Authoriry: %s\nm_id form the ready: %s\nM_get_u_id: %s" % [multiplayer_synchronizer.get_multiplayer_authority(), m_id, multiplayer.get_unique_id()]
	debug_label.text += str(health.value)
	debug_label.text += animation_player.current_animation.get_basename()
	debug_label.text += "\n%s\n" % velocity 
	
	health_label.text = str(health.value)
	health_bar.ratio = health.get_ratio()
	
	
	camera.current = true # wtf, other clients can disable camera of the other clients
	# i think i've messed up authority staff, but i have no clue what's the problem
	
	if pickup_ray.is_colliding():
		var item = pickup_ray.get_collider(0)
		if !item: return 
		debug_label.text += "Looking at: %s \n" % item.name
		interact_action = item.get_parent().pickup.bind(self)
	
	
	if health.value <= 0 and state_machine.current_state.name != "Dead":
		state_machine.change_state("dead")
	

func _physics_process(delta: float) -> void:
	
	if multiplayer_synchronizer.get_multiplayer_authority() != m_id: return
	if is_dead: return
	action_shoot()
	
	update_third_person_camera(delta)
	
	sprint_input = Input.is_action_pressed("sprint")
	crouch_input = Input.is_action_pressed("crouch")
	
	hand_container.position = lerp(hand_container.position, hand_container_offset, delta * 5)
	camera.rotation.x = lerp_angle(camera.rotation.x, 0, delta * 25)
	camera.rotation.z = lerp_angle(camera.rotation.z, 0, delta * 25)
	camera.rotation.y = lerp_angle(camera.rotation.y, 0, delta * 25)
	
	
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
	if !is_multiplayer_authority():
		return
	
	if event.is_action_pressed("escape"):
		toggle_mouse_mode()
	
	if is_dead: return
	
	if event is InputEventMouseMotion:
		pass
		#visuals.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
	
	if event.is_action_pressed("start_game"):
		camera.current = false
		if multiplayer.is_server() and is_multiplayer_authority():
			get_parent().on_all_players_connected()
	if event.is_action_pressed("interact"):
		if interact_action != Callable():
			interact_action.call()
	if event.is_action_pressed("jump"):
		jump_input = true
	if event.is_action_released("jump"):
		jump_input = false
	
	if event is InputEventMouseMotion:
		#rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		var mouse_delta = -event.relative.y * mouse_sens
		var head_rot = deg_to_rad(mouse_delta)
		head.rotate_x(head_rot)
		head.rotation_degrees.x = clampf(head.rotation_degrees.x, -88, 90)
		
		
		head_rotation_target.x -= event.relative.y * mouse_sens
		head_rotation_target.y -= event.relative.x / 400
		

@rpc("call_local")
func set_color():
	current_color = GameManager.players[m_id].color
	
	print(m_id, current_color)
	var weapon_model = hand_container.get_child(0)
	weapon_model.set_color_recursive(current_color)

func toggle_mouse_mode():
	if multiplayer_synchronizer.get_multiplayer_authority() != m_id: return
	if mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_captured = !mouse_captured

func get_movement_input():
	if multiplayer_synchronizer.get_multiplayer_authority() != m_id: return
	
	movement_input = Input.get_vector("left", "right", "forward", "backward")
	return movement_input

func update_movement_direction(delta: float, lerp_speed: float):
	if multiplayer_synchronizer.get_multiplayer_authority() != m_id: return
	var input_v3 = Vector3(movement_input.x, 0.0, movement_input.y).normalized()
	var target_direction = (transform.basis * input_v3)
	movement_direction = lerp(movement_direction, target_direction, lerp_speed * delta);

func apply_velocity(additive_spd: float = 0):
	if multiplayer_synchronizer.get_multiplayer_authority() != m_id: return
	if movement_direction:
		velocity.x = movement_direction.x * (current_speed + additive_spd)
		velocity.z = movement_direction.z * (current_speed + additive_spd)
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed / 2)
		velocity.z = move_toward(velocity.z, 0.0, current_speed / 2)

func apply_gravity(delta: float):
	if multiplayer_synchronizer.get_multiplayer_authority() != m_id: return
	if not is_on_floor():
		velocity.y -= gravity * delta
		return true
	return false

func set_current_move_speed(speed: float):
	if multiplayer_synchronizer.get_multiplayer_authority() != m_id: return
	current_speed = speed

func crouch(delta: float):
	if multiplayer_synchronizer.get_multiplayer_authority() != m_id: return
	head.position.y = lerp(head.position.y, target_head_pos, delta * 10)
	crouching_collider.disabled = false
	standing_collider.disabled = true

func stand(delta: float):
	if multiplayer_synchronizer.get_multiplayer_authority() != m_id: return
	crouching_collider.disabled = true
	standing_collider.disabled = false
	head.position.y = lerp(head.position.y, head_og, delta * 10)

func is_standing():
	return abs(head.position.y - head_og) < 0.01

func jump():
	if multiplayer_synchronizer.get_multiplayer_authority() != m_id: return
	velocity.y = jump_force

func action_shoot():
	
	if Input.is_action_pressed("fire"):
		var shot = ranged_weapon_controller.shoot()
		if !shot: return
		
		hand_container.position.z += 0.25
		camera.rotation.x += 0.025
		#ammo_label.text = "%s/%s" % [ranged_weapon_controller.current_ammo, ranged_weapon_controller.current_ammo_pack]
		#camera.rotation.y += randf_range(-0.02, 0.02)
		#camera.rotation.z += randf_range(-0.02, 0.02)
		


func shooting_aimpunch():
	if shooting_aimpunch_tween:
		shooting_aimpunch_tween.kill()
	
	shooting_aimpunch_tween = get_tree().create_tween()
	shooting_aimpunch_tween.tween

func take_damage(msg: DamageMessage):
	if health.value <= 0:
		return
	health.update_value.rpc(-msg.damage)
	#var label = player_HUD.get_node("VBoxContainer/HealthLabel")
	#label.text = str(health.value)
	#update_taking_damage.rpc_id()
	if health.value <= 0:
		die.rpc()
		#queue_free()

@rpc("authority", "call_remote", "reliable")
func update_taking_damage():
	var label = player_HUD.get_node("VBoxContainer/HealthLabel")
	label.text = str(health.value)

@rpc("any_peer", "call_local", "reliable")
func die():
	#current_color = Color.BLACK
	standing_collider.disabled = true
	crouching_collider.disabled = true
	is_dead = true

func get_authoriy():
	return multiplayer_synchronizer.get_multiplayer_authority() == m_id

func set_interact(method: Callable):
	interact_action = method

func play_sprint_animation(dir: Vector2):
	if dir == Vector2.ZERO:
		return
	var anim_name = "Run Forward Rifle"
	
	if dir.y >= 0:
		if dir.y > 0:
			if dir.x > 0:
				anim_name = "Strafe Right Rifle"
			elif dir.x < 0:
				anim_name = "Strafe Left Rifle"
			else:
				anim_name = "Run Backward Rifle"
		else:
			if dir.x > 0:
				anim_name = "Strafe Right Rifle"
			elif dir.x < 0:
				anim_name = "Strafe Left Rifle"
	else:
		if dir.x > 0:
			anim_name = "Strafe Right Rifle"
		elif dir.x < 0:
			anim_name = "Strafe Left Rifle"
			
	
	if animation_player.current_animation.get_basename() == anim_name:
		return
	print(anim_name)
	animation_player.play(anim_name)

func update_third_person_camera(delta):
	var point = $ThirdPersonView/SubViewport/DebugCameraPoint
	point.global_position = Vector3(global_position.x, global_position.y + 2, global_position.z + 2)

func play_way_animation(dir: Vector2, animations_map: Dictionary[Vector2, String]):
	var int_dir = Vector2i(dir)
	
	for v in animations_map:
		var approx_y = Utils.approximate(v.y, dir.y)
		var approx_x = Utils.approximate(v.x, dir.x)
		var approx2 = animations_map.get(v)
		
		#print("%s %s %s" % [approx_y && approx_x, approx2, v])
	
	dir.x = snappedf(dir.x, 0.1)
	dir.y = snappedf(dir.y, 0.1)
	#print(dir)
	var anim_name = animations_map.get(dir)
	
	if !anim_name:
		print("invalid name: %s" % anim_name)
		return
	if animation_player.current_animation.get_basename() == anim_name:
		return
	print(anim_name)
	animation_player.play(anim_name)

@rpc("any_peer", "call_local")
func update_animation_position(anim_name, start_time):
	print("animation called at: %s" % [name])
	animation_player.play_section(anim_name, start_time)

func _on_ranged_weapon_controller_ammo_updated(value: int, pack_value) -> void:
	ammo_label.text = "%s/%s" % [value, pack_value]

func pickup_ammo(value: int):
	ranged_weapon_controller.add_ammo_in_pack(value)

func pickup_bag(bag):
	pass
