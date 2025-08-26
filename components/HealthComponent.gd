class_name HealthComponent extends Node

signal damaged(amount: float)
signal died()
signal health_changed(current: float, max_health: float)

var max_health: float = 100.0
var current: float = 100.0

func initialize(max_hp: float):
	max_health = max_hp
	current = max_hp

func take_damage(amount: float):
	if current <= 0:
		return
	
	current = max(0, current - amount)
	damaged.emit(amount)
	health_changed.emit(current, max_health)
	
	if current <= 0:
		died.emit()

func heal(amount: float):
	current = min(max_health, current + amount)
	health_changed.emit(current, max_health)

func is_alive() -> bool:
	return current > 0