extends Area2D

var velocity: Vector2
var damage: float
var speed: float
var lifetime: float = 5.0
var time_alive: float = 0.0
var is_active := false
var pierce_count := 1
var hits := 0
var hit_enemies := []  # Track which enemies we've already hit

func activate(start_pos: Vector2, direction: Vector2, proj_damage: float, proj_speed: float):
	position = start_pos
	velocity = direction.normalized() * proj_speed
	damage = proj_damage
	speed = proj_speed
	is_active = true
	visible = true
	set_physics_process(true)
	set_process(true)
	time_alive = 0.0
	hits = 0
	hit_enemies.clear()
	
	# Setup Area2D collision
	monitoring = true
	monitorable = false
	set_collision_layer_value(4, true)  # Projectile layer
	set_collision_mask_value(2, true)   # Hit enemies layer
	
	# Setup collision shape if it doesn't exist
	if not has_node("CollisionShape2D"):
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 4.0
		collision_shape.shape = circle_shape
		add_child(collision_shape)
	
	# Connect signals
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	
	EntityManager.register_entity(self, "projectile")
	
	queue_redraw()

func deactivate():
	is_active = false
	visible = false
	set_physics_process(false)
	set_process(false)
	monitoring = false
	hit_enemies.clear()
	EntityManager.unregister_entity(self)

func _physics_process(delta):
	if not is_active:
		return
	
	position += velocity * delta
	time_alive += delta
	
	if time_alive >= lifetime:
		deactivate()
		return
	
	# Check if out of bounds
	var viewport_rect = get_viewport().get_visible_rect()
	viewport_rect = viewport_rect.grow(100)  # Add margin
	if not viewport_rect.has_point(position):
		deactivate()
		return

func _on_body_entered(body):
	if not is_active:
		return
	
	# Check if it's an enemy we haven't hit yet
	if body in hit_enemies:
		return
		
	if body.has_method("get_component"):
		var ai = body.get_component("ai")
		if ai and body.get("enemy_data"):  # Confirm it's an enemy
			_hit_enemy(body)

func _on_area_entered(area):
	if not is_active:
		return
		
	# Check if the area belongs to an enemy
	var parent = area.get_parent()
	if parent and parent != self and parent in hit_enemies:
		return
		
	if parent and parent.has_method("get_component"):
		var ai = parent.get_component("ai")
		if ai and parent.get("enemy_data"):  # Confirm it's an enemy
			_hit_enemy(parent)

func _hit_enemy(enemy):
	if enemy in hit_enemies:
		return
		
	hit_enemies.append(enemy)
	CombatSystem.apply_damage(enemy, damage, self)
	hits += 1
	
	if hits >= pierce_count:
		deactivate()

func _process(_delta):
	if is_active:
		queue_redraw()

func _draw():
	if not is_active:
		return
	# Draw projectile as a yellow circle
	draw_circle(Vector2.ZERO, 4, Color.YELLOW)
	# Add a small glow effect
	draw_circle(Vector2.ZERO, 6, Color(1, 1, 0, 0.3))
