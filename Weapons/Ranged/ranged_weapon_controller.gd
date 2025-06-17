extends Node3D
class_name RangedWeaponController

var debug_impact: PackedScene = preload("res://Debug/impact_point.tscn")

@export var raycast: RayCast3D
@export var weapon: RangedWeapon

@onready var cooldown: Timer = $Cooldown

var current_ammo: int
var current_ammo_pack: int

var parent: Node3D
var is_ready: bool = true

func _ready():
	current_ammo = weapon.ammo_size
	current_ammo_pack = weapon.ammo_pack_size
	
	parent = get_parent_node_3d()

func shoot(): 
	
	if !cooldown.is_stopped(): return false
	cooldown.start(weapon.cooldown)
	current_ammo -= 1
	raycast.force_raycast_update()
	
	if !raycast.is_colliding(): return true
	
	var collider = raycast.get_collider()
	
	var impact_position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
	var impact_inst = debug_impact.instantiate()
	get_tree().root.add_child(impact_inst)
	impact_inst.position = impact_position
	
	if collider.has_method("take_damage"): 
		var msg = DamageMessage.new()
		msg.damage = weapon.damage
		msg.owner = get_parent_node_3d()
		
		var hit_dir: Vector3
		if parent:
			msg.owner = parent
			hit_dir = (collider.global_position - parent.global_position)
		else:
			msg.owner = null
			hit_dir = Vector3.ZERO
		
		msg.hit_direction = hit_dir
		msg.type = "Gun"
		collider.take_damage(msg)
		
		print("Hit: %s. Dealt: %s" % [collider.name, msg.damage])
	
	return true


func update_weapon_data(): 
	raycast.target_position = Vector3(0, 0, -1) * weapon.max_distance
