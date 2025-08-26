extends CharacterBody2D

var movement: MovementComponent
var health: HealthComponent  
var weapon: WeaponComponent
var magnet: MagnetComponent
var is_active := true

func _ready():
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
	
	EntityManager.register_entity(self, "player")
	
	collision_layer = 1
	collision_mask = 2
	
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = GameConfig.player_data.collision_radius
	collision_shape.shape = circle_shape
	add_child(collision_shape)

func _physics_process(delta):
	if not is_active:
		return
	
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	movement.set_direction(input)
	movement.update(delta)
	weapon.update(delta)
	magnet.update(delta)

func _draw():
	draw_circle(Vector2.ZERO, GameConfig.player_data.collision_radius, Color.CYAN)

func get_component(name: String) -> Node:
	return get_node_or_null(name)

func _on_died():
	EventBus.player_died.emit()
	is_active = false