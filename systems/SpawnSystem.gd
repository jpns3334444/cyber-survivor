class_name SpawnSystem extends Node

var spawn_timer: float = 0.0
var spawn_interval: float = 2.0
var max_enemies: int = 100
var current_wave: int = 0

func _ready():
	EventBus.game_started.connect(_on_game_started)

func _process(delta):
	if GameLoop.current_state != GameLoop.State.PLAYING:
		return
	
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_try_spawn_enemies()

func _try_spawn_enemies():
	var current_enemies = EntityManager.get_entity_count()
	if current_enemies >= max_enemies:
		return
	
	var enemies_to_spawn = min(3, max_enemies - current_enemies)
	
	for i in enemies_to_spawn:
		var enemy = PoolManager.get_enemy("zombie")
		if enemy:
			var spawn_pos = _get_spawn_position()
			enemy.activate(spawn_pos)

func _get_spawn_position() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	var margin = 100.0
	var side = randi() % 4
	
	match side:
		0: # Top
			return Vector2(randf_range(0, viewport_size.x), -margin)
		1: # Right  
			return Vector2(viewport_size.x + margin, randf_range(0, viewport_size.y))
		2: # Bottom
			return Vector2(randf_range(0, viewport_size.x), viewport_size.y + margin)
		_: # Left
			return Vector2(-margin, randf_range(0, viewport_size.y))

func _on_game_started():
	spawn_timer = 0.0
	current_wave = 0