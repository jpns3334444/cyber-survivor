extends Node

var _projectile_pool := []
var _enemy_pool := []
var _pickup_pool := []

# Store reference to the game world where entities should be added
var world_container: Node2D = null

func _ready():
	# Don't create pools immediately - wait for the world to be ready
	call_deferred("_setup_pools")

func _setup_pools():
	# Find the main scene to add entities to
	var main_scene = get_tree().current_scene
	if main_scene:
		world_container = main_scene
		_create_pools()
	else:
		push_error("[PoolManager] Could not find main scene!")

func _create_pools():
	if not world_container:
		push_error("[PoolManager] No world container set!")
		return
		
	print("[PoolManager] Creating object pools in world container...")
	
	# Create projectiles
	print("[PoolManager] Creating projectile pool...")
	for i in 50:
		var proj = Area2D.new()
		proj.set_script(preload("res://entities/Projectile.gd"))
		proj.set("is_active", false)
		proj.visible = false
		proj.set_physics_process(false)
		proj.set_process(false)
		_projectile_pool.append(proj)
		world_container.add_child(proj)  # Add to world, not PoolManager!
	print("[PoolManager] Created ", _projectile_pool.size(), " projectiles")
	
	# Create enemies
	print("[PoolManager] Creating enemy pool...")
	for i in 100:
		var enemy = CharacterBody2D.new()
		enemy.set_script(preload("res://entities/Enemy.gd"))
		enemy.set("is_active", false)
		enemy.visible = false
		enemy.set_physics_process(false)
		enemy.set_process(false)
		_enemy_pool.append(enemy)
		world_container.add_child(enemy)  # Add to world, not PoolManager!
	print("[PoolManager] Created ", _enemy_pool.size(), " enemies")
		
	# Create XP orbs
	print("[PoolManager] Creating XP orb pool...")
	for i in 200:
		var orb = Area2D.new()
		orb.set_script(preload("res://entities/XPOrb.gd"))
		orb.set("is_active", false)
		orb.visible = false
		orb.set_physics_process(false)
		orb.set_process(false)
		_pickup_pool.append(orb)
		world_container.add_child(orb)  # Add to world, not PoolManager!
	print("[PoolManager] Created ", _pickup_pool.size(), " xp orbs")
	
	print("[PoolManager] All pools created successfully!")

func get_projectile() -> Node2D:
	for p in _projectile_pool:
		if not p.get("is_active"):
			return p
	push_warning("[PoolManager] Projectile pool exhausted!")
	return null

func get_enemy(type: String) -> CharacterBody2D:
	for e in _enemy_pool:
		if not e.get("is_active"):
			if e.has_method("configure"):
				e.configure(GameConfig.get_enemy_data(type))
				return e
	push_warning("[PoolManager] Enemy pool exhausted!")
	return null

func get_xp_orb() -> Area2D:
	for orb in _pickup_pool:
		if not orb.get("is_active"):
			return orb
	push_warning("[PoolManager] XP orb pool exhausted!")
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

func clear_all_pools():
	"""Clear all pools when restarting the game"""
	for p in _projectile_pool:
		if p and is_instance_valid(p):
			p.queue_free()
	_projectile_pool.clear()
	
	for e in _enemy_pool:
		if e and is_instance_valid(e):
			e.queue_free()
	_enemy_pool.clear()
	
	for o in _pickup_pool:
		if o and is_instance_valid(o):
			o.queue_free()
	_pickup_pool.clear()
	
	# Recreate pools after clearing
	if world_container:
		_create_pools()