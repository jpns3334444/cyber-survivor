extends Node

signal damage_dealt(target: Node2D, amount: float)
signal entity_killed(entity: Node2D)
signal xp_gained(amount: int)

func calculate_damage(base: float, attacker_mods: Dictionary = {}) -> float:
	var final = base
	if attacker_mods.has("damage_mult"):
		final *= attacker_mods.damage_mult
	return final

func apply_damage(target: Node2D, damage: float, source: Node2D = null):
	if not target.has_method("get_component"):
		return
	
	var health = target.get_component("health")
	if health and health.has_method("take_damage"):
		health.take_damage(damage)
		damage_dealt.emit(target, damage)
		
		if health.get("current") <= 0:
			entity_killed.emit(target)
			_handle_death(target)

func _handle_death(entity: Node2D):
	if entity.has_method("get_component"):
		var ai = entity.get_component("ai")
		if ai and ai.get("xp_value") > 0:
			_spawn_xp_orb(entity.position, ai.xp_value)
	
	if entity.get("enemy_data"):
		var data = entity.enemy_data
		if data and data.get("xp_value") > 0:
			_spawn_xp_orb(entity.position, data.xp_value)
	
	if entity.has_method("deactivate"):
		entity.deactivate()

func _spawn_xp_orb(pos: Vector2, value: int):
	var orb = PoolManager.get_xp_orb()
	if orb and orb.has_method("activate"):
		orb.activate(pos, value)

func add_xp(amount: int):
	xp_gained.emit(amount)