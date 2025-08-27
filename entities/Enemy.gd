extends CharacterBody2D

var movement: MovementComponent
var health: HealthComponent
var ai: AIComponent
var hitbox: HitboxComponent
var is_active := false
var enemy_data: EnemyResource
var flash_timer := 0.0

# Visual properties
var color := Color.RED
var size := Vector2(24, 24)

# Debug
var debug_draw_calls := 0

func configure(data: EnemyResource):
	print("[Enemy] Configuring with data: ", data)
	enemy_data = data
	if data:
		color = data.color
		size = data.size
		print("[Enemy] Set color: ", color, " size: ", size)
	else:
		print("[Enemy] WARNING: No data provided, using defaults")
		color = Color.RED
		size = Vector2(24, 24)
	
	# Setup components
	_setup_movement(data.speed if data else 80.0)
	_setup_health(data.health if data else 20.0)
	_setup_ai(data.xp_value if data else 1)
	_setup_hitbox(data.damage if data else 5.0)
	_setup_collision(size)

func _setup_movement(speed: float):
	if not movement:
		movement = MovementComponent.new()
		movement.name = "movement"
		add_child(movement)
	movement.initialize(self, speed)

func _setup_health(hp: float):
	if not health:
		health = HealthComponent.new()
		health.name = "health"
		add_child(health)
		health.died.connect(deactivate)
	health.initialize(hp)

func _setup_ai(xp: int):
	if not ai:
		ai = AIComponent.new()
		ai.name = "ai"
		add_child(ai)
	ai.initialize(self, "chase_player")
	ai.xp_value = xp

func _setup_hitbox(damage: float):
	if not hitbox:
		hitbox = HitboxComponent.new()
		hitbox.name = "hitbox"
		add_child(hitbox)
		hitbox.hit_detected.connect(_on_hit_detected)
	hitbox.initialize(self, damage, "enemy")
	
	if not hitbox.has_node("CollisionShape2D"):
		var hitbox_collision = CollisionShape2D.new()
		var hitbox_shape = RectangleShape2D.new()
		hitbox_shape.size = size * 1.1
		hitbox_collision.shape = hitbox_shape
		hitbox.add_child(hitbox_collision)

func _setup_collision(enemy_size: Vector2):
	collision_layer = 2
	collision_mask = 1
	
	if not has_node("CollisionShape2D"):
		var collision_shape = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = enemy_size
		collision_shape.shape = rect_shape
		add_child(collision_shape)

func activate(pos: Vector2):
	print("[Enemy] ACTIVATING:")
	print("  - Position: ", pos)
	print("  - Parent: ", get_parent())
	print("  - Scene tree path: ", get_path())
	
	position = pos
	is_active = true
	visible = true
	set_physics_process(true)
	set_process(true)
	
	# Debug checks
	print("  - Is active: ", is_active)
	print("  - Is visible: ", visible)
	print("  - Is inside tree: ", is_inside_tree())
	print("  - Can process: ", can_process())
	print("  - Global position: ", global_position)
	print("  - Z-index: ", z_index)
	print("  - Modulate: ", modulate)
	print("  - Self modulate: ", self_modulate)
	print("  - Show behind parent: ", show_behind_parent)
	
	if health:
		health.current = health.max_health
	
	EntityManager.register_entity(self, "enemy")
	
	# Force immediate draw
	queue_redraw()
	
	# Try setting a higher z_index
	z_index = 10
	
	print("[Enemy] Activation complete")

func deactivate():
	print("[Enemy] Deactivating at position: ", position)
	is_active = false
	visible = false
	set_physics_process(false)
	set_process(false)
	EntityManager.unregister_entity(self)

func _ready():
	set_process(true)
	print("[Enemy] Ready - parent: ", get_parent())

func _physics_process(delta):
	if not is_active:
		return
	
	if flash_timer > 0:
		flash_timer -= delta
	
	if ai:
		ai.update(delta)
	if movement:
		movement.update(delta)
	
	# Debug position every 60 frames
	if Engine.get_physics_frames() % 60 == 0:
		print("[Enemy] Physics - Pos: ", position, " Visible: ", visible, " Active: ", is_active)

func _process(_delta):
	if is_active:
		queue_redraw()

func _draw():
	debug_draw_calls += 1
	
	# Always try to draw something for debugging
	if debug_draw_calls % 60 == 0:  # Log every 60 draw calls
		print("[Enemy] _draw() called #", debug_draw_calls, " Pos: ", position, " Active: ", is_active, " Visible: ", visible)
	
	# Draw regardless of state for debugging
	var draw_color = color if is_active else Color(1, 1, 1, 0.3)
	
	if flash_timer > 0:
		draw_color = Color.WHITE
	
	# Draw multiple things for visibility
	# 1. Filled rectangle
	draw_rect(Rect2(-size / 2, size), draw_color)
	
	# 2. Border
	draw_rect(Rect2(-size / 2, size), Color.BLACK, false, 2.0)
	
	# 3. Debug circle at origin
	draw_circle(Vector2.ZERO, 5, Color.YELLOW)
	
	# 4. Draw a large debug circle
	draw_circle(Vector2.ZERO, 30, Color(1, 0, 0, 0.3))
	
	# 5. Draw position text (might not be visible but worth trying)
	draw_string(ThemeDB.fallback_font, Vector2(-20, -30), "ENEMY", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

func get_component(name: String) -> Node:
	return get_node_or_null(name)

func _on_hit_detected(target: Node2D):
	if not enemy_data:
		return
		
	if target.has_method("get_component"):
		var target_health = target.get_component("health")
		if target_health:
			CombatSystem.apply_damage(target, enemy_data.damage, self)

func flash_white():
	flash_timer = 0.1
	queue_redraw()
