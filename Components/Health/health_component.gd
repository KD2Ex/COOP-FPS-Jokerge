extends Node
class_name HealthComponent

signal value_changed(current: int, max: int)

@export var value: int = 50
@export var max_value: int = 100
@export var restore_on_ready: bool = true

func _ready():
	if restore_on_ready:
		value = max_value

func update_value(value: int):
	
	self.value += value
	self.value = clampi(self.value, 0, max_value)
	
	value_changed.emit(self.value, max_value)
