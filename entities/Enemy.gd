extends CharacterBody2D

var movement: MovementComponent
var health: HealthComponent
var ai: AIComponent
var hitbox: HitboxComponent
var is_active := false
var enemy_data: EnemyResource
var flash_timer := 0.0

func configure(data: EnemyResource):
	enemy_data = data
	
	if not movement:
		movement = MovementComponent.new()
		movement.name = "movement"
		add_child(movement)
	movement.initialize(self, data.speed)
	
	if not health:
		health = HealthComponent.new()
		health.name = "health"
		add_child(health)
	health.initialize(data.health)
	health.died.connect(deactivate)
	
	if not ai:
		ai = AIComponent.new()
		ai.name = "ai"
		add_child(ai)
	ai.initialize(self, "chase_player")
	ai.xp_value = data.xp_value
	
	if not hitbox:
		hitbox = HitboxComponent.new()
		hitbox.name = "hitbox"
		add_child(hitbox)
	hitbox.initialize(self, data.damage, "enemy")
	hitbox.hit_detected.connect(_on_hit_detected)
	
	# Setup collision shape for hitbox
	if not hitbox.has_node("CollisionShape2D"):
		var hitbox_collision = CollisionShape2D.new()
		var hitbox_shape = RectangleShape2D.new()
		hitbox_shape.size = data.size * 1.1  # Slightly larger than visual
		hitbox_collision.shape = hitbox_shape
		hitbox.add_child(hitbox_collision)
	
	collision_layer = 2
	collision_mask = 1
	
	if not has_node("CollisionShape2D"):
		var collision_shape = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = data.size
		collision_shape.shape = rect_shape
		add_child(collision_shape)

func activate(pos: Vector2):
	position = pos
	is_active = true
	visible = true
	set_physics_process(true)
	
	if health:
		health.current = health.max_health
	
	EntityManager.register_entity(self, "enemy")

func deactivate():
	is_active = false
	visible = false
	set_physics_process(false)
	EntityManager.unregister_entity(self)

func _physics_process(delta):
	if not is_active:
		return
	
	# Update flash timer
	if flash_timer > 0:
		flash_timer -= delta
	
	ai.update(delta)
	movement.update(delta)
	
	# Always redraw enemies so they're visible!
	queue_redraw()  # Add this line - was missing!

func _draw():
	if enemy_data:
		if flash_timer > 0:
			draw_rect(Rect2(-enemy_data.size/2, enemy_data.size), Color.WHITE)
		else:
			draw_rect(Rect2(-enemy_data.size/2, enemy_data.size), enemy_data.color)

func get_component(name: String) -> Node:
	return get_node_or_null(name)

func _on_hit_detected(target: Node2D):
	if target.has_method("get_component"):
		var target_health = target.get_component("health")
		if target_health:
			CombatSystem.apply_damage(target, enemy_data.damage, self)

func flash_white():
	flash_timer = 0.1
	queue_redraw()
