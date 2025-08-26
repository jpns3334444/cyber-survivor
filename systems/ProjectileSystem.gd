class_name ProjectileSystem extends Node

var projectiles: Array[Node2D] = []

func _ready():
	pass

func _process(delta):
	cleanup_inactive_projectiles()

func register_projectile(projectile: Node2D):
	if projectile not in projectiles:
		projectiles.append(projectile)

func unregister_projectile(projectile: Node2D):
	projectiles.erase(projectile)

func cleanup_inactive_projectiles():
	var to_remove = []
	for proj in projectiles:
		if not proj.get("is_active"):
			to_remove.append(proj)
	
	for proj in to_remove:
		projectiles.erase(proj)

func get_active_projectile_count() -> int:
	var count = 0
	for proj in projectiles:
		if proj.get("is_active"):
			count += 1
	return count