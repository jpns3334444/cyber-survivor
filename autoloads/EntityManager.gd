extends Node

var _entities := {}
var _player: CharacterBody2D
var _enemies := []
var _projectiles := []
var _pickups := []

func register_entity(entity: Node2D, type: String) -> int:
	var id = entity.get_instance_id()
	_entities[id] = entity
	
	match type:
		"player":
			_player = entity
		"enemy":
			if entity not in _enemies:
				_enemies.append(entity)
		"projectile":
			if entity not in _projectiles:
				_projectiles.append(entity)
		"pickup":
			if entity not in _pickups:
				_pickups.append(entity)
	
	return id

func unregister_entity(entity: Node2D):
	var id = entity.get_instance_id()
	_entities.erase(id)
	_enemies.erase(entity)
	_projectiles.erase(entity)
	_pickups.erase(entity)

func get_player() -> CharacterBody2D:
	return _player

func get_enemies() -> Array:
	var active = []
	for e in _enemies:
		if e.get("is_active"):
			active.append(e)
	return active

func get_enemies_in_range(pos: Vector2, range: float) -> Array:
	var result := []
	var range_sq := range * range
	for e in _enemies:
		if e.get("is_active") and e.position.distance_squared_to(pos) < range_sq:
			result.append(e)
	return result

func get_nearest_enemy(pos: Vector2) -> Node2D:
	var nearest = null
	var min_dist = INF
	for e in _enemies:
		if not e.get("is_active"):
			continue
		var dist = e.position.distance_squared_to(pos)
		if dist < min_dist:
			min_dist = dist
			nearest = e
	return nearest

func get_pickups_in_range(pos: Vector2, range: float) -> Array:
	var result := []
	var range_sq := range * range
	for p in _pickups:
		if p.get("is_active") and p.position.distance_squared_to(pos) < range_sq:
			result.append(p)
	return result

func clear_all():
	for e in _enemies:
		if e.has_method("deactivate"):
			e.deactivate()
	for p in _projectiles:
		if p.has_method("deactivate"):
			p.deactivate()
	for pickup in _pickups:
		if pickup.has_method("deactivate"):
			pickup.deactivate()
	_enemies.clear()
	_projectiles.clear()
	_pickups.clear()
	_entities.clear()

func get_entity_count() -> int:
	return get_enemies().size()