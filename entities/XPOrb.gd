extends Area2D

var xp_value: int = 1
var is_active := false
var is_magnetized := false
var magnet_target: Vector2
var magnet_speed: float = 200.0
var collection_range: float = 30.0

func activate(pos: Vector2, value: int):
	position = pos
	xp_value = value
	is_active = true
	visible = true
	is_magnetized = false
	
	monitoring = true   # Detect others
	monitorable = false # Don't be detected
	set_collision_layer_value(4, true)  # Pickup layer
	set_collision_mask_value(1, true)   # Detect player layer
	
	if not has_node("CollisionShape2D"):
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 8.0
		collision_shape.shape = circle_shape
		add_child(collision_shape)
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	EntityManager.register_entity(self, "pickup")

func deactivate():
	is_active = false
	visible = false
	is_magnetized = false
	EntityManager.unregister_entity(self)

func set_magnetized(magnetized: bool, target_pos: Vector2 = Vector2.ZERO, speed: float = 200.0):
	is_magnetized = magnetized
	magnet_target = target_pos
	magnet_speed = speed

# In XPOrb.gd, update _physics_process:
func _physics_process(delta):
	if not is_active:
		return
	
	if is_magnetized:
		var direction = (magnet_target - position).normalized()
		var distance = position.distance_to(magnet_target)
		
		# Accelerate as it gets closer
		var speed = magnet_speed * (1.0 + (100.0 - min(distance, 100.0)) / 50.0)
		position += direction * speed * delta
		
		# Collect if very close
		if distance < 10:
			var player = EntityManager.get_player()
			if player:
				_on_body_entered(player)
	
	queue_redraw()  # Add this line!

func _on_body_entered(body: Node2D):
	if not is_active:
		return
	
	# Check if it's the player
	if body.has_method("get_component"):
		var player_health = body.get_component("health")
		if player_health and player_health.max_health > 0:  # Confirm it's the player
			CombatSystem.add_xp(xp_value)
			deactivate()

func _draw():
	var size = 6.0 + sin(Time.get_ticks_msec() / 1000.0 * 5.0) * 2.0
	draw_circle(Vector2.ZERO, size, Color.GREEN)
