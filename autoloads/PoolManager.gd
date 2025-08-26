extends Node

var _projectile_pool := []
var _enemy_pool := []
var _pickup_pool := []

var _projectile_scene: PackedScene
var _enemy_scene: PackedScene
var _xporb_scene: PackedScene

func _ready():
	_projectile_scene = preload("res://entities/Projectile.tscn") if ResourceLoader.exists("res://entities/Projectile.tscn") else null
	_enemy_scene = preload("res://entities/Enemy.tscn") if ResourceLoader.exists("res://entities/Enemy.tscn") else null
	_xporb_scene = preload("res://entities/XPOrb.tscn") if ResourceLoader.exists("res://entities/XPOrb.tscn") else null
	_create_pools()

func _create_pools():
	for i in 50:
		var proj = Node2D.new()
		proj.set_script(preload("res://entities/Projectile.gd"))
		proj.set("is_active", false)
		proj.visible = false
		proj.set_physics_process(false)
		_projectile_pool.append(proj)
		add_child(proj)
	
	for i in 100:
		var enemy = CharacterBody2D.new()
		enemy.set_script(preload("res://entities/Enemy.gd"))
		enemy.set("is_active", false)
		enemy.visible = false
		enemy.set_physics_process(false)
		_enemy_pool.append(enemy)
		add_child(enemy)
		
	for i in 200:
		var orb = Area2D.new()
		orb.set_script(preload("res://entities/XPOrb.gd"))
		orb.set("is_active", false)
		orb.visible = false
		orb.set_physics_process(false)
		_pickup_pool.append(orb)
		add_child(orb)

func get_projectile() -> Node2D:
	for p in _projectile_pool:
		if not p.get("is_active"):
			return p
	push_warning("Projectile pool exhausted!")
	return null

func get_enemy(type: String) -> CharacterBody2D:
	for e in _enemy_pool:
		if not e.get("is_active"):
			if e.has_method("configure"):
				e.configure(GameConfig.get_enemy_data(type))
			return e
	push_warning("Enemy pool exhausted!")
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