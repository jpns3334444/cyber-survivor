extends CharacterBody2D

var movement: MovementComponent
var health: HealthComponent  
var weapon: WeaponComponent
var magnet: MagnetComponent
var damage_detector: Area2D
var is_active := true
var damage_cooldown := 0.0
var flash_timer := 0.0

func _ready():
	# Reset active state
	is_active = true
	damage_cooldown = 0.0
	flash_timer = 0.0
	
	# Create all components fresh
	movement = MovementComponent.new()
	movement.name = "movement"
	movement.initialize(self, GameConfig.player_data.move_speed)
	add_child(movement)
	
	health = HealthComponent.new()
	health.name = "health"
	health.initialize(GameConfig.player_data.max_health)
	health.died.connect(_on_died)
	add_child(health)
	
	weapon = WeaponComponent.new()
	weapon.name = "weapon"
	weapon.initialize(self, GameConfig.get_weapon("pistol"))
	add_child(weapon)
	
	magnet = MagnetComponent.new()
	magnet.name = "magnet"
	magnet.initialize(self, GameConfig.game_settings.base_pickup_range)
	add_child(magnet)
	
	# Clear any previous registration
	EntityManager.unregister_entity(self)
	EntityManager.register_entity(self, "player")
	
	# Setup collision
	collision_layer = 1
	collision_mask = 2
	
	# Create collision shape if it doesn't exist
	if not has_node("CollisionShape2D"):
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = GameConfig.player_data.collision_radius
		collision_shape.shape = circle_shape
		add_child(collision_shape)
	
	# Setup damage detector Area2D
	if not has_node("damage_detector"):
		damage_detector = Area2D.new()
		damage_detector.name = "damage_detector"
		damage_detector.monitoring = true
		damage_detector.monitorable = false
		damage_detector.set_collision_layer_value(1, false)
		damage_detector.set_collision_mask_value(2, true)
		
		var detect_shape = CollisionShape2D.new()
		var detect_circle = CircleShape2D.new()
		detect_circle.radius = GameConfig.player_data.collision_radius
		detect_shape.shape = detect_circle
		damage_detector.add_child(detect_shape)
		damage_detector.body_entered.connect(_on_enemy_contact)
		add_child(damage_detector)
	
	print("[Player] Initialized successfully")

func _physics_process(delta):
	if not is_active:
		return
	
	# Update damage cooldown
	if damage_cooldown > 0:
		damage_cooldown -= delta
	
	# Update flash timer
	if flash_timer > 0:
		flash_timer -= delta
		queue_redraw()
	
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	movement.set_direction(input)
	movement.update(delta)
	weapon.update(delta)
	magnet.update(delta)

func _draw():
	if flash_timer > 0:
		# Draw white flash when taking damage
		draw_circle(Vector2.ZERO, GameConfig.player_data.collision_radius, Color.WHITE)
	else:
		draw_circle(Vector2.ZERO, GameConfig.player_data.collision_radius, Color.CYAN)

func get_component(name: String) -> Node:
	return get_node_or_null(name)

func _on_died():
	EventBus.player_died.emit()
	is_active = false

func _on_enemy_contact(body):
	if damage_cooldown <= 0 and body.has_method("get_component"):
		var ai = body.get_component("ai")
		if ai and body.get("enemy_data"):  # Confirm it's an enemy
			var damage_amount = body.enemy_data.damage
			health.take_damage(damage_amount)
			damage_cooldown = 0.5  # 0.5s invincibility frames
			flash_timer = 0.1      # Brief white flash
			
			# Add hit pause effect
			if Engine.time_scale == 1.0:
				Engine.time_scale = 0.1
				await get_tree().create_timer(0.05, true, false, true).timeout
				Engine.time_scale = 1.0

func flash_white():
	flash_timer = 0.1
	queue_redraw()