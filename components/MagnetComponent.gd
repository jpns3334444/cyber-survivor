class_name MagnetComponent extends Node

var entity: Node2D
var magnet_range: float = 100.0
var magnet_speed: float = 200.0
var target_types: Array[String] = ["pickup"]

func initialize(owner: Node2D, range: float = 100.0, speed: float = 200.0):
	entity = owner
	magnet_range = range
	magnet_speed = speed

func update(delta: float):
	if not entity:
		return
	
	var pickups = EntityManager.get_pickups_in_range(entity.position, magnet_range)
	
	for pickup in pickups:
		if pickup.has_method("set_magnetized"):
			pickup.set_magnetized(true, entity.position, magnet_speed)