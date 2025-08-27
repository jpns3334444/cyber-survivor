extends CharacterBody2D

var movement: MovementComponent
var health: HealthComponent
var ai: AIComponent
var is_active := false
var enemy_data: EnemyResource
var flash_timer := 0.0

# Visual properties
var color := Color.RED
var size := Vector2(24, 24)

# Direct movement control (backup for when components fail)
var move_speed := 80.0
var target_position := Vector2.ZERO

func configure(data: EnemyResource):
	enemy_data = data
	if data:
		color = data.color
		size = data.size
		move_speed = data.speed
	else:
		color = Color.RED
		size = Vector2(24, 24)
		move_speed = 80.0
	
	# Setup components
	_setup_components(data)

func _setup_components(data: EnemyResource):
	# Clean up old components
	for child in get_children():
		if child.name in ["movement", "health", "ai"]:
			child.queue_free()
	
	# Create fresh components
	movement = MovementComponent.new()
	movement.name = "movement"
	add_child(movement)
	movement.initialize(self, data.speed if data else 80.0)
	
	health = HealthComponent.new()
	health.name = "health"
	add_child(health)
	health.initialize(data.health if data else 20.0)
	health.died.connect(deactivate)
	
	ai = AIComponent.new()
	ai.name = "ai"
	add_child(ai)
	ai.initialize(self, "chase_player")
	ai.xp_value = data.xp_value if data else 1
	
	# Setup collision
	_setup_collision(size)

func _setup_collision(enemy_size: Vector2):
	# Set up collision layers - MUST be on layer 2 for projectiles to hit
	collision_layer = 2  # Enemy layer
	collision_mask = 1   # Collide with player
	
	# Remove old collision shape if it exists
	for child in get_children():
		if child is CollisionShape2D:
			child.queue_free()
	
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = enemy_size
	collision_shape.shape = rect_shape
	add_child(collision_shape)

func activate(pos: Vector2):
	position = pos
	is_active = true
	visible = true
	set_physics_process(true)
	set_process(true)
	
	# Make sure we're on the right collision layer
	collision_layer = 2
	collision_mask = 1
	
	# Reset health
	if health:
		health.current = health.max_health
	
	# Register with entity manager
	EntityManager.register_entity(self, "enemy")
	
	queue_redraw()

func deactivate():
	is_active = false
	visible = false
	set_physics_process(false)
	set_process(false)
	EntityManager.unregister_entity(self)

func _ready():
	set_physics_process(false)
	set_process(false)

func _physics_process(delta):
	if not is_active:
		return
	
	# Update flash timer
	if flash_timer > 0:
		flash_timer -= delta
		queue_redraw()
	
	# Get the player directly
	var player = EntityManager.get_player()
	if player and is_instance_valid(player):
		# Calculate direction to player manually
		var direction = (player.position - position).normalized()
		
		# Move towards player
		velocity = direction * move_speed
		move_and_slide()
		
		# Check for collision with player
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider and collider.has_method("get_component"):
				var player_health = collider.get_component("health")
				if player_health and enemy_data:
					CombatSystem.apply_damage(collider, enemy_data.damage, self)

func _process(_delta):
	if is_active:
		queue_redraw()

func _draw():
	if not is_active:
		return
		
	var draw_color = color
	if flash_timer > 0:
		draw_color = Color.WHITE
	
	# Draw enemy square
	draw_rect(Rect2(-size / 2, size), draw_color)
	
	# Draw border for visibility
	draw_rect(Rect2(-size / 2, size), Color.BLACK, false, 2.0)

func get_component(name: String) -> Node:
	return get_node_or_null(name)

func flash_white():
	flash_timer = 0.1
	queue_redraw()

# Make the enemy take damage from projectiles
func take_damage(amount: float):
	if health:
		health.take_damage(amount)
		flash_white()
