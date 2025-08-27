class_name WeaponComponent extends Node

var weapon_data: WeaponResource
var cooldown: float = 0.0
var entity: Node2D

func initialize(owner: Node2D, data: WeaponResource):
	entity = owner
	weapon_data = data

func update(delta: float):
	cooldown = max(0, cooldown - delta)
	
	if cooldown <= 0:
		_try_shoot()

func _try_shoot():
	if not entity or not weapon_data:
		print("[Weapon] Cannot shoot - missing entity or weapon_data")
		return
	
	var target = EntityManager.get_nearest_enemy(entity.position)
	if not target:
		# Don't spam this message - only print occasionally
		if Engine.get_frames_drawn() % 60 == 0:
			print("[Weapon] No enemies to target")
		return
	
	var proj = PoolManager.get_projectile()
	if proj and proj.has_method("activate"):
		var dir = (target.position - entity.position).normalized()
		proj.activate(entity.position, dir, weapon_data.damage, weapon_data.projectile_speed)
		cooldown = weapon_data.fire_rate
		print("[Weapon] Shot projectile at enemy")
	else:
		print("[Weapon] Failed to get projectile from pool")