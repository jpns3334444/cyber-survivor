extends Area2D

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
	
	# Setup Area2D collision
	monitoring = true
	monitorable = false
	set_collision_layer_value(3, true)  # Projectile layer
	set_collision_mask_value(2, true)   # Hit enemies layer
	
	# Setup collision shape
	if not has_node("CollisionShape2D"):
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 4.0
		collision_shape.shape = circle_shape
		add_child(collision_shape)
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
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

func _on_body_entered(body):
	if not is_active:
		return
	
	if body.has_method("get_component"):
		var ai = body.get_component("ai")
		if ai and body.get("enemy_data"):  # Confirm it's an enemy
			CombatSystem.apply_damage(body, damage, self)
			hits += 1
			if hits >= pierce_count:
				deactivate()

func _draw():
	draw_circle(Vector2.ZERO, 4, Color.YELLOW)