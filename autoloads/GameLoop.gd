extends Node

enum State {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state := State.MENU
var game_time := 0.0
var wave_number := 0
var player_level := 1
var player_xp := 0
var xp_required := 5
var spawning_enabled := true
var next_spawn_time := 0.0
var spawn_interval := 2.0

func _ready():
	EventBus.game_started.connect(_on_game_started)
	EventBus.player_died.connect(_on_player_died)
	CombatSystem.xp_gained.connect(_on_xp_gained)
	
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				spawning_enabled = !spawning_enabled
				print("Spawning: ", spawning_enabled)
			KEY_F2:
				_spawn_enemies(10)
				print("Spawned 10 enemies")
			KEY_F3:
				EntityManager.clear_all()
				print("Killed all enemies")
			KEY_F4:
				_on_xp_gained(10)
				print("Added 10 XP")
			KEY_F5:
				var stats = PoolManager.get_pool_stats()
				print("Pool stats: ", stats)

func _process(delta):
	if current_state == State.PLAYING:
		game_time += delta
		
		if spawning_enabled and Time.get_time_dict_from_system().second % spawn_interval < delta:
			if EntityManager.get_entity_count() < GameConfig.game_settings.max_enemies:
				_spawn_enemies(1)

func start_game():
	current_state = State.PLAYING
	game_time = 0.0
	wave_number = 0
	player_level = 1
	player_xp = 0
	xp_required = GameConfig.game_settings.base_xp_requirements[0]
	EntityManager.clear_all()
	EventBus.game_started.emit()

func _on_game_started():
	current_state = State.PLAYING
	print("Game started!")

func _on_player_died():
	current_state = State.GAME_OVER
	EventBus.game_over.emit()
	print("Game Over!")

func _on_xp_gained(amount: int):
	player_xp += amount
	
	while player_xp >= xp_required:
		player_xp -= xp_required
		player_level += 1
		
		var level_index = min(player_level - 1, GameConfig.game_settings.base_xp_requirements.size() - 1)
		xp_required = GameConfig.game_settings.base_xp_requirements[level_index]
		
		EventBus.player_leveled_up.emit(player_level)
		print("Level up! Now level ", player_level)

func _spawn_enemies(count: int):
	for i in count:
		var enemy = PoolManager.get_enemy("zombie")
		if enemy:
			var spawn_pos = _get_spawn_position()
			enemy.activate(spawn_pos)

func _get_spawn_position() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	var margin = 50.0
	var side = randi() % 4
	
	match side:
		0: # Top
			return Vector2(randf() * viewport_size.x, -margin)
		1: # Right
			return Vector2(viewport_size.x + margin, randf() * viewport_size.y)
		2: # Bottom
			return Vector2(randf() * viewport_size.x, viewport_size.y + margin)
		_: # Left
			return Vector2(-margin, randf() * viewport_size.y)

func get_game_stats() -> Dictionary:
	return {
		"time": game_time,
		"level": player_level,
		"xp": player_xp,
		"xp_required": xp_required,
		"enemies": EntityManager.get_entity_count(),
		"wave": wave_number
	}