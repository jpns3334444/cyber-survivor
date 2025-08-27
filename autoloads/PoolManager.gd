extends Node

var _projectile_pool := []
var _enemy_pool := []
var _pickup_pool := []


func _ready():
	_create_pools()

func _create_pools():
	print("[PoolManager] Creating object pools...")
	
	# Create projectiles - MUST be Area2D since Projectile extends Area2D
	print("[PoolManager] Creating projectile pool...")
	for i in 50:
		var proj = Area2D.new()  # FIXED: was Node2D, must be Area2D
		proj.set_script(preload("res://entities/Projectile.gd"))
		proj.set("is_active", false)
		proj.visible = false
		proj.set_physics_process(false)
		proj.set_process(false)  # Also disable process
		_projectile_pool.append(proj)
		add_child(proj)
	print("[PoolManager] Created ", _projectile_pool.size(), " projectiles")
	
	# Create enemies - CharacterBody2D is correct
	print("[PoolManager] Creating enemy pool...")
	for i in 100:
		var enemy = CharacterBody2D.new()
		enemy.set_script(preload("res://entities/Enemy.gd"))
		enemy.set("is_active", false)
		enemy.visible = false
		enemy.set_physics_process(false)
		_enemy_pool.append(enemy)
		add_child(enemy)
	print("[PoolManager] Created ", _enemy_pool.size(), " enemies")
		
	# Create XP orbs - Area2D is correct
	print("[PoolManager] Creating XP orb pool...")
	for i in 200:
		var orb = Area2D.new()
		orb.set_script(preload("res://entities/XPOrb.gd"))
		orb.set("is_active", false)
		orb.visible = false
		orb.set_physics_process(false)
		orb.set_process(false)  # Also disable process
		_pickup_pool.append(orb)
		add_child(orb)
	print("[PoolManager] Created ", _pickup_pool.size(), " xp orbs")
	
	print("[PoolManager] All pools created successfully!")

func get_projectile() -> Node2D:
	var inactive_count = 0
	for p in _projectile_pool:
		if not p.get("is_active"):
			inactive_count += 1
			print("[PoolManager] Activated projectile from pool (", inactive_count, " available)")
			return p
	push_warning("[PoolManager] Projectile pool exhausted! All ", _projectile_pool.size(), " projectiles are active")
	return null

func get_enemy(type: String) -> CharacterBody2D:
	var inactive_count = 0
	for e in _enemy_pool:
		if not e.get("is_active"):
			inactive_count += 1
			if e.has_method("configure"):
				e.configure(GameConfig.get_enemy_data(type))
				print("[PoolManager] Activated enemy from pool (", inactive_count, " available)")
				return e
	push_warning("[PoolManager] Enemy pool exhausted! All ", _enemy_pool.size(), " enemies are active")
	return null

func get_xp_orb() -> Area2D:
	for orb in _pickup_pool:
		if not orb.get("is_active"):
			return orb
	push_warning("XP orb pool exhausted!")
	return null

func get_pool_stats() -> Dictionary:
	var stats = {}
	
	var active_proj = 0
	for p in _projectile_pool:
		if p.get("is_active"):
			active_proj += 1
	stats["projectiles"] = "%d/%d" % [active_proj, _projectile_pool.size()]
	
	var active_enemies = 0
	for e in _enemy_pool:
		if e.get("is_active"):
			active_enemies += 1
	stats["enemies"] = "%d/%d" % [active_enemies, _enemy_pool.size()]
	
	var active_orbs = 0
	for o in _pickup_pool:
		if o.get("is_active"):
			active_orbs += 1
	stats["xp_orbs"] = "%d/%d" % [active_orbs, _pickup_pool.size()]
	
	return stats