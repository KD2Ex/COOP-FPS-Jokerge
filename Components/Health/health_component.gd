extends Node
class_name HealthComponent

signal value_changed(current: int, max: int)

@export var value: int = 50
@export var max_value: int = 100
@export var restore_on_ready: bool = true

var f_value: float
var f_m_value: float

func _ready():
	if restore_on_ready:
		value = max_value
	
	f_value = float(value)
	f_m_value = float(max_value)

@rpc("any_peer", "call_local", "reliable")
func update_value(value: int):
	
	self.value += value
	self.value = clampi(self.value, 0, max_value)
	
	value_changed.emit(self.value, max_value)
	
	f_value = float(self.value)

func get_ratio():
	var ratio = f_value / f_m_value
	return ratio 
