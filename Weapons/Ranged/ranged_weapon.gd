extends Resource
class_name RangedWeapon

@export_subgroup("Model")
@export var model: PackedScene
@export var position: Vector3
@export var rotation: Vector3
@export var muzzle_position: Vector3

@export_subgroup("Stats")
@export_range(0.05, 1) var cooldown: float = 0.1 # Firerate
@export var reload: float = 1.5 # Realod time
@export var damage: int = 25
@export_range(5, 150) var max_distance: float = 20
@export_range(0, 5) var spread: float = 0
@export var shots_count: int = 1
@export var ammo_size: int = 30
@export var ammo_pack_size: int = 90

@export_subgroup("Sounds")
@export var shot: String # Path

@export_subgroup("Crosshair")
@export var crosshair: Texture2D
