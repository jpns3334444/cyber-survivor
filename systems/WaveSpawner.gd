extends Node
class_name WaveSpawner

# Spawn configuration
var spawn_patterns := {
	"basic": {
		"enemies": ["zombie"],
		"weights": [1.0],
		"count": 3,
		"interval": 2.0
	},
	"mixed": {
		"enemies": ["zombie", "fast_zombie", "tank_zombie"],
		"weights": [0.6, 0.3, 0.1],
		"count": 5,
		"interval": 1.5
	}
}

var current_pattern := "basic"
var spawn_timer := 0.0
var spawn_interval := 2.0
var enemies_per_spawn := 3
var max_enemies := 50
var spawning_enabled := true

# Difficulty scaling
var time_elapsed := 0.0
var difficulty_multiplier := 1.0

func _ready():
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_over.connect(_on_game_over)

func _process(delta):
	if not spawning_enabled:
		return
		
	if GameLoop.current_state != GameLoop.State.PLAYING:
		return
	
	time_elapsed += delta
	spawn_timer += delta
	
	# Scale difficulty every 30 seconds
	difficulty_multiplier = 1.0 + (time_elapsed / 30.0) * 0.5
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_wave()

func _spawn_wave():
	var current_enemies = EntityManager.get_entity_count()
	if current_enemies >= max_enemies:
		return
	
	var pattern = spawn_patterns.get(current_pattern, spawn_patterns["basic"])
	var to_spawn = min(pattern["count"], max_enemies - current_enemies)
	
	for i in to_spawn:
		var enemy_type = _select_enemy_type(pattern)
		_spawn_enemy(enemy_type)

func _select_enemy_type(pattern: Dictionary) -> String:
	var enemies = pattern.get("enemies", ["zombie"])
	var weights = pattern.get("weights", [1.0])
	
	if enemies.size() == 1:
		return enemies[0]
	
	# Weighted random selection
	var total_weight = 0.0
	for w in weights:
		total_weight += w
	
	var random = randf() * total_weight
	var accumulated = 0.0
	
	for i in enemies.size():
		accumulated += weights[min(i, weights.size() - 1)]
		if random <= accumulated:
			return enemies[i]
	
	return enemies[0]

func _spawn_enemy(enemy_type: String):
	var enemy = PoolManager.get_enemy(enemy_type)
	if not enemy:
		push_warning("[WaveSpawner] Failed to get enemy from pool")
		return
	
	var spawn_pos = _get_spawn_position()
	enemy.activate(spawn_pos)
	
	# Scale enemy stats based on difficulty
	if difficulty_multiplier > 1.0 and enemy.has_method("get_component"):
		var health = enemy.get_component("health")
		if health:
			health.max_health *= difficulty_multiplier
			health.current = health.max_health
	
	EventBus.enemy_spawned.emit(enemy)

func _get_spawn_position() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	var margin = 100.0
	var side = randi() % 4
	
	match side:
		0: # Top
			return Vector2(randf_range(margin, viewport_size.x - margin), -margin)
		1: # Right
			return Vector2(viewport_size.x + margin, randf_range(margin, viewport_size.y - margin))
		2: # Bottom
			return Vector2(randf_range(margin, viewport_size.x - margin), viewport_size.y + margin)
		_: # Left
			return Vector2(-margin, randf_range(margin, viewport_size.y - margin))

func set_spawn_pattern(pattern_name: String):
	if pattern_name in spawn_patterns:
		current_pattern = pattern_name
		var pattern = spawn_patterns[pattern_name]
		spawn_interval = pattern.get("interval", 2.0)
		enemies_per_spawn = pattern.get("count", 3)

func set_spawning_enabled(enabled: bool):
	spawning_enabled = enabled

func _on_game_started():
	time_elapsed = 0.0
	difficulty_multiplier = 1.0
	spawn_timer = 0.0
	spawning_enabled = true
	current_pattern = "basic"

func _on_game_over():
	spawning_enabled = false