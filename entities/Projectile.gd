extends Node2D

var velocity: Vector2
var damage: float
var speed: float
var lifetime: float = 5.0
var time_alive: float = 0.0
var is_active := false
var pierce_count := 1
var hits := 0

func activate(start_pos: Vector2, direction: Vector2, proj_damage: float, proj_speed: float):
	position = start_pos
	velocity = direction.normalized() * proj_speed
	damage = proj_damage
	speed = proj_speed
	is_active = true
	visible = true
	set_physics_process(true)
	time_alive = 0.0
	hits = 0
	
	EntityManager.register_entity(self, "projectile")

func deactivate():
	is_active = false
	visible = false
	set_physics_process(false)
	EntityManager.unregister_entity(self)

func _physics_process(delta):
	if not is_active:
		return
	
	position += velocity * delta
	time_alive += delta
	
	if time_alive >= lifetime:
		deactivate()
		return
	
	var viewport_rect = get_viewport().get_visible_rect()
	if not viewport_rect.has_point(position):
		deactivate()
		return
	
	var enemies = EntityManager.get_enemies_in_range(position, 20.0)
	for enemy in enemies:
		if enemy.has_method("get_component"):
			var health = enemy.get_component("health")
			if health and health.has_method("take_damage"):
				health.take_damage(damage)
				hits += 1
				
				if hits >= pierce_count:
					deactivate()
					return

func _draw():
	draw_circle(Vector2.ZERO, 4, Color.YELLOW)